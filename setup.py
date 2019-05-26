import os
import pathlib
import struct
import sys
import importlib
import logging

from setuptools import setup

from distutils.extension import Extension
from Cython.Build import cythonize

logging.disable(logging.WARNING)

# System info
platform = sys.platform
arch = struct.calcsize('P') * 8

# Paths
cwd = pathlib.Path('.')
readme_path = cwd / 'README.md'

def normalize(path_list, relative_to=None):
    """
    Converts a list of pathlib.Paths into a list of strings relative to a directory.
    """
    relative_to = relative_to or cwd
    return [(relative_to / x).as_posix() for x in path_list]

def normalize_ext_data(data):
    """
    Combine and normalize Extension data.  Passing a tuple for an item will ignore defaults.
    """
    normlist = ('sources', 'include_dirs', 'library_dirs', 'runtime_library_dirs')
    data.update({k: normalize(_build_list(k, v)) for k, v in data.items() if k in normlist})
    return data

def _build_list(k, v):
    if isinstance(k, list):
        return defaults(k) + v
    return v

_, _dirs, _ = next(os.walk(cwd / 'speedups'))
packages = [d for d in _dirs if not d.startswith('__')]

class defaults:
    def __new__(cls, *args, **kwargs):
        if not args:
            return cls
        return getattr(cls, str(args[0]), [])

    # Compile options
    include_dirs = [cwd]
    library_dirs = []
    runtime_lib_dirs = []
    extra_compile_args = ['-O2']
    extra_link_args = ['-O2']

    # Platform tweaks
    if platform == 'win32':
        # runtime_lib_dirs = []
        if arch == 64:
            extra_compile_args.append('-DMS_WIN64')

compiler_directives = {
    'language_level': 3,
    'embedsignature': True
}

# Generate extensions
c_extensions = []
print("Generating extensions for", ''.join(packages))
for extension_dir in packages:
    module = importlib.import_module(f'speedups.{extension_dir}._setup')
    ext_data = normalize_ext_data(module.get_extension_data())
    c_extensions.append(Extension(**ext_data))

# Package setup
with open(readme_path, 'r', encoding='utf-8') as fp:
    README = fp.read()

setup(
    name='discord-ext-speedups',
    author='imayhaveborkedit',
    url='https://github.com/imayhaveborkedit/discord-ext-speedups',

    license='MIT',
    description='Cython speedups for various parts of discord.py',
    long_description=README,
    long_description_content_type='text/markdown',
    project_urls={
        'Code': 'https://github.com/imayhaveborkedit/discord-ext-speedups',
        'Issue tracker': 'https://github.com/imayhaveborkedit/discord-ext-speedups/issues'
    },

    version='0.0.1',
    python_requires='>=3.6.4',
    setup_requires=['Cython==0.27.3'],
    zip_safe=False,

    packages=['discord.ext.speedups'],
    package_dir={'discord.ext.speedups': 'speedups'},

    ext_modules = cythonize(c_extensions,
        nthreads=3,
        annotate=True,
        compiler_directives=compiler_directives
    )
)
