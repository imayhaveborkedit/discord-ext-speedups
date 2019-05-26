from cpython cimport array

cimport speedups.copus.opus as opus

from speedups.copus._utils cimport int_or_ptr, int_or_str


cdef void _raise_for_error(int err, str extra=?) except *

cdef class _OpusAudio:
    cdef readonly int SAMPLING_RATE
    cdef readonly int CHANNELS
    cdef readonly int FRAME_LENGTH
    cdef readonly int SAMPLE_SIZE
    cdef readonly int SAMPLES_PER_FRAME
    cdef readonly int FRAME_SIZE

cdef class Encoder(_OpusAudio):
    cdef dict __dict__
    cdef readonly int application
    cdef opus.OpusEncoder *state
    cdef array.array _output_template

    cdef int _create_state(self) except *
    cdef int _ctl(self, int option, int_or_ptr value) except *
    cpdef int set_bitrate(self, int kbps) except *
    cpdef int set_bandwidth(self, bandsidth) except *
    cpdef int set_signal_type(self, signal) except *
    cpdef int set_fec(self, bint enabled) except *
    cpdef int set_expected_packet_loss_percent(self, percentage) except *
    cpdef bytes encode(self, pcm, int frame_size)
    cdef int _encode(self, short *pcm, int frame_size, unsigned char *data, int max_size) nogil

cdef class Decoder:
    pass
