import os
import struct
import sys
import logging

__all__ = ['install', 'uninstall', 'libopus_loader', 'load_opus', 'is_loaded']

log = logging.getLogger(__name__)

# Fix PATH on windows
if sys.platform == 'win32':
    _arch = struct.calcsize('P') * 8
    _basepath = os.path.dirname(__file__)
    _binpath = os.path.abspath(os.path.normpath(os.path.join(_basepath, 'bin', f'x{_arch}')))
    log.info("Adding %r to os.environ['PATH']", _binpath)
    os.environ["PATH"] += os.pathsep + _binpath

_clib = None

# Copy functions from opus.py for compat

def libopus_loader(name=None):
    """Compat function.  The `name` argument is ignored."""

    try:
        from . import _copus
        return _copus
    except Exception as e:
        err = e

    try:
        import _copus
        return _copus
    except:
        raise err # from None?

def load_opus(name=None):
    """Compat function."""

    try:
        global _clib
        _clib = libopus_loader(name)
    except:
        raise
    else:
        self = sys.modules[__name__]
        __install_to_module(self)
    finally:
        ... # TODO: pop added path in finally?

def is_loaded():
    """Compat function."""

    return _clib is not None

# New functions

def install(module=None):
    """Monkeypatches the given module (defaults to discord) to use the extension objects.
    Basically it's just a setattr loop for this module's __all__.
    """

    if module is None:
        discord = sys.modules.get('discord')
        if discord:
            module = discord.opus
        else:
            raise TypeError("Could not find discord and no module parameter provided")

    __install_to_module(module)

def __install_to_module(module):
    _nothing = object()
    module._copus = _clib
    module._copus_monkeypatched = True

    for attr in _clib.__all__:
        old = getattr(module, attr, _nothing)
        new = getattr(_clib, attr)
        if old is not _nothing:
            setattr(module, '__copus__old__'+attr, old)
        setattr(module, attr, new)

def uninstall(module=None):
    """Attempts to undo previous monkeypatching."""

    if module is None:
        discord = sys.modules.get('discord')
        if discord:
            module = discord.opus
        else:
            raise TypeError("Could not find discord and no module parameter provided")

    if not getattr(module, '_copus_monkeypatched', False):
        raise RuntimeError("Module {} has not been installed to.".format(module))

    __uninstall_from_module(module)

def __uninstall_from_module(module):
    _nothing = object()
    del module._copus
    del module._copus_monkeypatched

    for attr in _clib.__all__:
        orig = getattr(module, '__copus__old__'+attr, _nothing)

        if orig is not _nothing:
            setattr(module, attr, orig)
            delattr(module, '__copus__old__'+attr)

try:
    load_opus()
except Exception as e:
    log.warning("Unable to load opus lib, %s", e)
