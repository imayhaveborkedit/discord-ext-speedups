from . import copus

_modules = {
    'copus': copus
}

_installed = []

def install(*install_modules, ignore=False):
    """
    Patches in replacement modules.

    Parameters
    -----------
    \*install_modules
        An argument list of strings of modules to install.
    ignore: :class:`bool`
        If True, install all available modules *except* the given modules.
    """

    if ignore:
        install_modules = tuple(set(install_modules).symmetric_difference(_modules))

    for mod in install_modules:
        patch = _modules.get(mod)
        if patch and patch not in _installed:
            patch.install()
            _installed.append(patch)

def uninstall(*uninstall_modules, ignore=False):
    """
    Undo patching and restore the original modules.

    Parameters
    -----------
    \*uninstall_modules
        An argument list of strings of modules to uninstall.
    ignore: :class:`bool`
        If True, uninstall all available modules *except* the given modules.
    """

    if ignore:
        uninstall_modules = tuple(set(uninstall_modules).symmetric_difference(_installed))

    for mod in uninstall_modules:
        patch = _modules.get(mod)
        if patch and patch in _installed:
            patch.uninstall()
            _installed.remove(patch)

def get_installed_patches():
    """
    Returns a tuple of installed modules.
    """
    return tuple(_installed)
