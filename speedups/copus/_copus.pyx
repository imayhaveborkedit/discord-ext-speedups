import sys
import cython

from cpython cimport array

cimport speedups.copus.opus as opus

from speedups.copus._utils cimport int_or_ptr, int_or_str

__all__ = ['Encoder', 'Decoder', 'OpusError', 'OpusNotLoaded']

_band_ctl = {
    'narrow':    opus.BANDWIDTH_NARROWBAND,
    'medium':    opus.BANDWIDTH_MEDIUMBAND,
    'wide':      opus.BANDWIDTH_WIDEBAND,
    'superwide': opus.BANDWIDTH_SUPERWIDEBAND,
    'full':      opus.BANDWIDTH_FULLBAND,
}

_signal_ctl = {
    'auto':  opus.AUTO,
    'voice': opus.SIGNAL_VOICE,
    'music': opus.SIGNAL_MUSIC,
}

_app_ctl = [
    opus.APPLICATION_VOIP,
    opus.APPLICATION_AUDIO
]

discord = sys.modules.get('discord')
ExceptionBase = Exception

try:
    if isinstance(discord.DiscordException, Exception):
        ExceptionBase = discord.DiscordException
except:
    pass

class OpusError(ExceptionBase):
    """An exception that is thrown for libopus related errors.

    Attributes
    ----------
    code: :class:`int`
        The error code returned.
    """

    def __init__(self, code, extra=''):
        self.code = code
        msg = opus.strerror(code).decode('utf-8') + extra
        # log.info('"%s" has happened', msg)
        super().__init__(msg)

class OpusNotLoaded(ExceptionBase):
    """An exception that is thrown for when libopus is not loaded."""
    pass


cdef inline void _raise_for_error(int err, str extra='') except *:
    if err < 0:
        raise OpusError(err, extra)


cdef class _OpusAudio:
    def __cinit__(self):
        self.SAMPLING_RATE = 48000
        self.CHANNELS = 2
        self.FRAME_LENGTH = 20
        self.SAMPLE_SIZE = 4
        self.SAMPLES_PER_FRAME = self.SAMPLING_RATE // 1000 * self.FRAME_LENGTH
        self.FRAME_SIZE = self.SAMPLES_PER_FRAME * self.SAMPLE_SIZE

cdef class Encoder(_OpusAudio):
    def __cinit__(self, int application=opus.APPLICATION_AUDIO):
        self.application = application
        self._create_state()
        self.set_bitrate(128)
        self.set_fec(True)
        self.set_expected_packet_loss_percent(0.15)
        self.set_bandwidth('full')
        self._output_template = array.array('b', [])

    def __dealloc__(self):
        if self.state is not NULL:
            opus.encoder_destroy(self.state)

    cdef int _create_state(self) except *:
        cdef int err = 0
        self.state = opus.encoder_create(self.SAMPLING_RATE, self.CHANNELS, self.application, &err)

        if self.state is NULL:
            extra = ''
            if self.application not in _app_ctl:
                extra = " ({} is not a valid application type, try one of: {})".format(
                    self.application, ', '.join(map(str, _app_ctl))) # TODO: nice text or something
            _raise_for_error(err, extra)

        return err

    cdef int _ctl(self, int option, int_or_ptr value) except *:
        ret = opus.encoder_ctl(self.state, option, value)
        _raise_for_error(ret)

        if int_or_ptr is int:
            return ret
        elif int_or_ptr is cython.p_int:
            return value[0]

    cpdef int set_bitrate(self, int kbps) except *:
        kbps = min(128, max(16, kbps)) * 1024
        self._ctl(opus.SET_BITRATE_REQUEST, kbps)
        return kbps

    cpdef int set_bandwidth(self, bandwidth) except *:
        if isinstance(bandwidth, str):
            bandwidth = _band_ctl.get(bandwidth)
            if bandwidth is None:
                raise KeyError('{!r} is not a valid bandwidth setting. Try one of: {}'.format(
                    bandwidth, ','.join(_band_ctl)))

        return self._ctl(opus.SET_BANDWIDTH_REQUEST, <int>bandwidth)

    cpdef int set_signal_type(self, signal) except *:
        if isinstance(signal, str):
            signal = _signal_ctl.get(signal)
            if signal is None:
                raise KeyError('{!r} is not a valid signal setting. Try one of: {}'.format(
                    signal, ','.join(_signal_ctl)))

        return self._ctl(opus.SET_SIGNAL_REQUEST, <int>signal)

    cpdef int set_fec(self, bint enabled) except *:
        return self._ctl(opus.SET_INBAND_FEC_REQUEST, enabled)

    cpdef int set_expected_packet_loss_percent(self, percentage) except *:
        cdef int perc = min(100, max(0, int(percentage * 100)))
        self._ctl(opus.SET_PACKET_LOSS_PERC_REQUEST, perc)
        return perc

    cpdef bytes encode(self, pcm, int frame_size):
        cdef int max_size = len(pcm)
        cdef array.array _pcm = array.array('h', pcm)
        cdef array.array data = array.clone(self._output_template, max_size//4, zero=False)

        ret = self._encode(_pcm.data.as_shorts, frame_size, data.data.as_uchars, max_size)
        _raise_for_error(ret)

        array.resize(data, ret)
        return data.tobytes()

    cdef int _encode(self, short *pcm, int frame_size, unsigned char *data, int max_size) nogil:
        return opus.encode(self.state, pcm, frame_size, data, max_size)


cdef class Decoder:
    pass
