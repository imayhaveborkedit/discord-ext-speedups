cdef extern from "opus/opus.h":
    ctypedef struct OpusEncoder:
        pass

    ctypedef struct OpusDecoder:
        pass

    OpusEncoder* encoder_create "opus_encoder_create" (int sample_rate, int channels, int application, int *error)
    void encoder_destroy "opus_encoder_destroy" (OpusEncoder *st) # except *
    int encoder_ctl "opus_encoder_ctl" (OpusEncoder *st, int request, ...) except *
    int encode "opus_encode" (OpusEncoder *st, const short *pcm, int frame_size, unsigned char *data, int max_data_bytes) nogil except *

    OpusDecoder* decoder_create "opus_decoder_create" (int sample_rate, int channels, int *error)
    void decoder_destroy "opus_decoder_destroy" (OpusDecoder *st) # except *
    int decoder_ctl "opus_decoder_ctl" (OpusDecoder *st, int request, ...) except *
    int decode "opus_decode" (OpusDecoder *st, const unsigned char *data, int len, int *pcm, int frame_size, bint decode_fec) except *
    int decoder_get_nb_samples "opus_decoder_get_nb_samples" (const OpusDecoder *dec, const unsigned char[] packet, int len) except *

    int packet_get_bandwidth "opus_packet_get_bandwidth" (const unsigned char *data) except *
    int packet_get_nb_channels "opus_packet_get_nb_channels" (const unsigned char *data) except *
    int packet_get_nb_frames "opus_packet_get_nb_frames" (const unsigned char[] packet, int len) except *
    # int opus_packet_get_samples_per_frame(const unsigned char *data, int sample_rate)

cdef extern from "opus/opus_defines.h":
    const char* strerror "opus_strerror" (int error) except *
    const char* get_version_info "opus_get_version_info" ()

    # Error codes
    int OK "OPUS_OK"
    int BAD_ARG "OPUS_BAD_ARG"

    # Encoder CTLs
    int APPLICATION_VOIP "OPUS_APPLICATION_VOIP"
    int APPLICATION_AUDIO "OPUS_APPLICATION_AUDIO"

    int AUTO "OPUS_AUTO"

    # Signal types
    int SIGNAL_VOICE "OPUS_SIGNAL_VOICE"
    int SIGNAL_MUSIC "OPUS_SIGNAL_MUSIC"

    # Bandwidths
    int BANDWIDTH_NARROWBAND "OPUS_BANDWIDTH_NARROWBAND"
    int BANDWIDTH_MEDIUMBAND "OPUS_BANDWIDTH_MEDIUMBAND"
    int BANDWIDTH_WIDEBAND "OPUS_BANDWIDTH_WIDEBAND"
    int BANDWIDTH_SUPERWIDEBAND "OPUS_BANDWIDTH_SUPERWIDEBAND"
    int BANDWIDTH_FULLBAND "OPUS_BANDWIDTH_FULLBAND"

    int SET_BITRATE_REQUEST "OPUS_SET_BITRATE_REQUEST"
    int SET_BANDWIDTH_REQUEST "OPUS_SET_BANDWIDTH_REQUEST"
    int SET_INBAND_FEC_REQUEST "OPUS_SET_INBAND_FEC_REQUEST"
    int SET_PACKET_LOSS_PERC_REQUEST "OPUS_SET_PACKET_LOSS_PERC_REQUEST"
    int SET_SIGNAL_REQUEST "OPUS_SET_SIGNAL_REQUEST"

    int SET_GAIN_REQUEST "OPUS_SET_GAIN_REQUEST"
    int GET_LAST_PACKET_DURATION_REQUEST "OPUS_GET_LAST_PACKET_DURATION_REQUEST"
