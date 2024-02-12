# python-cmake

Build python as a library that can be embeded to another application, using cmake.

## Dependencies

Mac OS:

```bash
brew install openssl xz zlib libffi tcl-tk
```

Arch Linux:

```bash
sudo pacman -S bzip2 ncurses expat openssl libffi editline readline sqlite gdbm db5.3 xz tcl tk mpdecimal
```

Ubuntu:

```bash
sudo apt install libssl-dev zlib1g-dev libncurses5-dev \
  libncursesw5-dev libreadline-dev libsqlite3-dev libgdbm-dev \
  libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev libffi-dev
```

## Build manual

If you use VSCode, it is quite simple:

1. Open the folder with VSCode
2. Download all recommended extensions if VSCode prompts you whether to install them
3. Select a kit if VSCode prompts you, if it doesn't prompt you, use VSCode command: `CMake: Select a Kit`
4. On Windows, select `MSVC amd64`; on Linux, select `GCC x86_64` or `Clang x86_64`; on Mac OSX, select `Apple Clang`
5. After you select a kit, the CMake Tools extension will run `CMake: Configure` command automatically, wait until it is executed successfully
6. Press `F5`, select `python` as your debug target, python will be built and run in the VSCode integrated terminal (Use `CMake: Set Debug Target` if you set a wrong debug target)

Windows build commands:

```bash
cd python-cmake
mkdir build
mkdir install
cd build
cmake -B . -S .. -G "Visual Studio 17 2022" -DCMAKE_INSTALL_PREFIX:STRING=../install
cmake --build . --config Release
# python.exe is located at: build/bin/Release/python.exe
```

Linux build commands:

```bash
cd python-cmake
mkdir build
mkdir install
cd build
cmake -B . -S .. -G "Ninja" -DCMAKE_INSTALL_PREFIX:STRING=../install -DCMAKE_BUILD_TYPE:STRING=Release
cmake --build . --config Release
# python is located at: build/bin/python
```

Mac OSX build commands:

```bash
cd python-cmake
mkdir build
mkdir install
cd build
cmake -B . -S .. -G "Ninja" -DCMAKE_INSTALL_PREFIX:STRING=../install -DCMAKE_BUILD_TYPE:STRING=Release
cmake --build . --config Release
# python is located at: build/bin/python
```

## Python Embed Example

https://github.com/Tac213/python_embed

```cmake
# Set python version, >= 3.8.0
set(PYTHON_VERSION "3.12.2")
# Set your embedded application name, it will be used by PC/python3dll.c if you build pythoncore as a static library on Windows
set(WIN32_EMBEDED_APPLICATION_NAME "python_embed.exe")
# Build pythoncore as a static library or shared library
# Static library name: libpython-static
# Shared library name: libpython-shared
option(BUILD_LIBPYTHON_SHARED "" OFF)
# Build all extension modules as built-in modules
option(BUILD_EXTENSIONS_AS_BUILTIN "" ON)
# Enable load of normal extension modules download from pip on Windows (Otherwise python will try to load extensions with `_d` suffix when `CMAKE_BUILD_TYPE` is `Debug`)
option(LOAD_NORMAL_EXTENSIONS_IN_DEBUG "" ON)
# Disable _ssl module, you can also use `ENABLE_<extension>` options, where <extension> is the name of the extension in upper case, and without any leading underscore (_).
option(ENABLE_SSL "" OFF)
add_subdirectory(python-cmake)
```
