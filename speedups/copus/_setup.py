import pathlib
import struct
import sys

# System info
platform = sys.platform
arch = struct.calcsize('P') * 8

# Paths
cwd = pathlib.Path('.')
extension_path = pathlib.Path(__file__).parent
binary_path = extension_path / 'bin' / f'x{arch}'

# Compile options
include_dirs = [extension_path]
library_dirs = [binary_path]
runtime_lib_dirs = [binary_path]

libraries = {
    'win32': ['opus'],
    'linux': ['opus']
}

if platform == 'win32':
    runtime_lib_dirs = []
    include_dirs.append(cwd / 'include')

def get_extension_data():
    return {
        'name': 'discord.ext.copus._copus',
        'sources': [extension_path / '_copus.pyx'],
        'libraries': libraries[platform],
        'include_dirs': include_dirs,
        'library_dirs': library_dirs,
        'runtime_library_dirs': runtime_lib_dirs
    }
