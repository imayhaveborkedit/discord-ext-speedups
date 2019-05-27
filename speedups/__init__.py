__title__ = 'discord.ext.speedups'
__author__ = 'Imayhaveborkedit'
__license__ = 'MIT'
__copyright__ = 'Copyright 2019 Imayhaveborkedit'
__version__ = '0.0.1'

import logging

from . import copus

__all__ = []

log = logging.getLogger(__name__)

_modules = {
    'copus': copus
}

_installed = []

def _module_basename(module):
    return module.__name__.rsplit('.', 1)[-1]

def install(*install_modules, ignore=False):
    """
    Patches in replacement modules.

    Parameters
    -----------
    \*install_modules: :class:`str`
        An argument list of strings of modules to install.
    ignore: :class:`bool`
        If True, install all available modules *except* the given modules.

    Returns
    --------
    :class:`list`[:class:`str`]
        A list of module names that were installed from this function call.
    """

    if ignore:
        install_modules = tuple(set(install_modules).symmetric_difference(_modules))
    elif not install_modules:
        install_modules = tuple(_modules)

    installed_now = []

    for mod in install_modules:
        patch = _modules.get(mod)
        if patch and patch not in _installed:
            try:
                patch.install()
            except:
                log.exception("Failed to patch in %s", patch)
            else:
                _installed.append(patch)
                installed_now.append(mod)

    return installed_now

def uninstall(*uninstall_modules, ignore=False):
    """
    Undo patching and restore the original modules.

    Parameters
    -----------
    \*uninstall_modules: :class:`str`
        An argument list of strings of modules to uninstall.
    ignore: :class:`bool`
        If True, uninstall all available modules *except* the given modules.

    Returns
    --------
    :class:`list`[:class:`str`]
        A list of module names that were uninstalled from this function call.
    """

    if ignore:
        uninstall_modules = tuple(set(uninstall_modules).symmetric_difference(_installed))
    elif not uninstall_modules:
        uninstall_modules = tuple(_module_basename(m) for m in _installed)

    uninstalled_now = []

    for mod in uninstall_modules:
        patch = _modules.get(mod)
        if patch and patch in _installed:
            try:
                patch.uninstall()
            except:
                log.exception("Failed to undo patch for %s", patch)
            else:
                _installed.remove(patch)
                uninstalled_now.append(mod)

    return uninstalled_now

def get_available_patches():
    """
    Returns a tuple of available module names.
    """
    return tuple(_modules)

def get_installed_patches():
    """
    Returns a tuple of installed module names.
    """
    return tuple(_installed)
