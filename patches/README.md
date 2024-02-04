# CPython Patches

Apply patches to CPython source code to prevent compile error.

Each patch is documented by adding an entry to the README.md file found in the same directory.

By default, patches are applied at configuration time. Setting the option `PYTHON_APPLY_PATCHES` to `OFF` allows to change this. Note that the build system keep track which patches have been applied.

Patches are organized per python version. Patches specific to a system, a system+compiler, or a system+compiler+compiler_version are organized in corresponding sub-directories:

```
patches/<PY_VERSION_MAJOR>.<PY_VERSION_MINOR>
patches/<PYTHON_VERSION>
patches/<PYTHON_VERSION>/<CMAKE_SYSTEM_NAME>
patches/<PYTHON_VERSION>/<CMAKE_SYSTEM_NAME>-<CMAKE_C_COMPILER_ID>
patches/<PYTHON_VERSION>/<CMAKE_SYSTEM_NAME>-<CMAKE_C_COMPILER_ID>/<compiler_version>
```

where

- `<PYTHON_VERSION>` is of the form `X.Y.Z`
- `<CMAKE_SYSTEM_NAME>` is a value like `Darwin`, `Linux` or `Windows`. See corresponding CMake documentation for more details.
- `<CMAKE_C_COMPILER_ID>` is a valid like `Clang`, `GNU` or `MSVC`. See corresponding CMake documentation for more details.
- `<compiler_version>` is set to the value of `CMAKE_C_COMPILER_VERSION` (e.g `5.2.1`) except when using Microsoft compiler where it is set to the value of `MSVC_VERSION` (e.g `1900`).

Before being applied, patches are sorted alphabetically. This ensures that patch starting with 0001- is applied before the one starting with 0002-.

If there is a pair of square brackets in the patch file name, it means that the patch need an extra option to be applied, where the option name is the string within the square brackets.

## How to generate patches

Simplest way:

1. Download cpython source code from: https://www.python.org/ftp/python/
2. Execute `git init` command under the cpython source folder, then commit all files as the initial commit.
3. Make changes and `git commit` the changes.
4. Execute this command to generate patch: `git format-patch HEAD~<N>`, where `<N>` is number of last commits to save as patches.
