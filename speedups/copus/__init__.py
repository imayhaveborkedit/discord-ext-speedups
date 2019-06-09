import sys

if not getattr(sys, 'cython_building', False):
    from .copus import *

del sys
