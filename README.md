# discord-ext-speedups
Cython speedups for various parts of discord.py

## Installation
`pip install discord-ext-speedups`

## Usage
```py
import discord
from discord.ext import speedups
speedups.install()
```
This monkeypatches all available C extensions into discord.py, replacing the existing ones.  This is best done immediately after `import discord`.  To only install specific patches, pass the names to `install()`.  For more info, see the reference section below.

To revert patches, simply call `speedups.uninstall()` to restore all modules to normal.  This function also takes specific module names as arguments.  **Note**: You should probably avoid doing this while you're using the modules or objects this library alters.

## Available patches
### `copus`
Cython bindings for libopus.  This was written as an experiment in cython and doesn't produce that much of a speedup.  A benchmark indicated a 10% speedup of `Encoder.encode()`, but this also works out to a mere 0.5% of the total time window for this call (20ms/frame).

## Reference
### `install(*install_modules, ignore=False)`
Patches in replacement modules.

- `*install_modules` (`str`)

  Module names to install.  The list of available module names can be found above, or by calling `get_available_patches()`.

- `ignore` (`bool`)

  If True, install all available modules *except* the given modules.

 Returns a `list[str]` of module names.

### `uninstall(*uninstall_modules, ignore=False)`
Undo patching and restore the original modules.
- `*uninstall_modules` (`str`)

  Modules names to uninstall.  The list of installed module names can be found by calling `get_installed_patches()`.

- `ignore` (`bool`)

  If True, uninstall all available modules *except* the given modules.

### `get_available_patches()`
Returns a `tuple[str]` of available module names.

### `get_installed_patches()`
Returns a `tuple[str]` of installed module names.

## Requirements
- Python 3.6.4+
- `discord.py`

Compiling from source requires:
- `cython` 0.27.3
