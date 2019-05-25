import cython

ctypedef fused int_or_ptr:
    int
    cython.p_int

ctypedef fused int_or_str:
    int
    str
