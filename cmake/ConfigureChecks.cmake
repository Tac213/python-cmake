message(STATUS "The system name is ${CMAKE_SYSTEM_NAME}")
message(STATUS "The system processor is ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "The system version is ${CMAKE_SYSTEM_VERSION}")

if(WIN32)
    # download externals
    message(STATUS "Downloading externals...")
    execute_process(COMMAND cmd /c ${SRC_DIR}/PCBuild/get_externals.bat OUTPUT_VARIABLE _win32_get_externals)

    string(REGEX MATCH "bzip2-([0-9]+\.)+([0-9]+)" _win32_bzip2_folder_name ${_win32_get_externals})
    set(_win32_bzip2_folder ${SRC_DIR}/externals/${_win32_bzip2_folder_name})
    string(REGEX MATCH "sqlite-([0-9]+\.)+([0-9]+)" _win32_sqlite_folder_name ${_win32_get_externals})
    set(_win32_sqlite_folder ${SRC_DIR}/externals/${_win32_sqlite_folder_name})
    string(REGEX MATCH "xz-([0-9]+\.)+([0-9]+)" _win32_xz_folder_name ${_win32_get_externals})
    set(_win32_xz_folder ${SRC_DIR}/externals/${_win32_xz_folder_name})
    string(REGEX MATCH "zlib-([0-9]+\.)+([0-9]+)" _win32_zlib_folder_name ${_win32_get_externals})
    set(_win32_zlib_folder ${SRC_DIR}/externals/${_win32_zlib_folder_name})
    string(REGEX MATCH "libffi-([0-9]+\.)+([0-9]+)" _win32_libffi_folder_name ${_win32_get_externals})
    set(_win32_libffi_folder ${SRC_DIR}/externals/${_win32_libffi_folder_name})
    string(REGEX MATCH "openssl-bin-([0-9]+\.)+([0-9]+)" _win32_openssl_folder_name ${_win32_get_externals})
    set(_win32_openssl_folder ${SRC_DIR}/externals/${_win32_openssl_folder_name})
    string(REGEX MATCH "tcltk-([0-9]+\.)+([0-9]+)" _win32_tcltk_folder_name ${_win32_get_externals})
    set(_win32_tcltk_folder ${SRC_DIR}/externals/${_win32_tcltk_folder_name})
    string(REGEX MATCHALL "[0-9]+" _win32_tcltk_version ${_win32_tcltk_folder_name})
    list(GET _win32_tcltk_version 0 _win32_tcltk_major_version)
    list(GET _win32_tcltk_version 1 _win32_tcltk_minor_version)

    string(TOLOWER ${CMAKE_SYSTEM_PROCESSOR} _win32_arch_name)
endif()

# BZip2
if(WIN32)
    # import _bz2
    set(BZIP2_INCLUDE_DIR ${_win32_bzip2_folder})
else()
    find_package(BZip2) # https://cmake.org/cmake/help/latest/module/FindBZip2.html
endif()
message(STATUS "BZIP2_INCLUDE_DIR=${BZIP2_INCLUDE_DIR}")
message(STATUS "BZIP2_LIBRARIES=${BZIP2_LIBRARIES}")

# Curses
if(WIN32)
    # Not available on win32
else()
    # import _curses
    find_package(Curses) # https://cmake.org/cmake/help/latest/module/FindCurses.html
    find_library(PANEL_LIBRARY NAMES panel)
    set(PANEL_LIBRARIES ${PANEL_LIBRARY})
    message(STATUS "CURSES_LIBRARIES=${CURSES_LIBRARIES}")
    message(STATUS "PANEL_LIBRARIES=${PANEL_LIBRARIES}")
endif()

# EXPAT
if(WIN32)
    # import pyexpat
    set(EXPAT_INCLUDE_DIRS ${SRC_DIR}/Modules/expat)
else()
    find_package(EXPAT) # https://cmake.org/cmake/help/latest/module/FindEXPAT.html
endif()
message(STATUS "EXPAT_LIBRARIES=${EXPAT_LIBRARIES}")
message(STATUS "EXPAT_INCLUDE_DIRS=${EXPAT_INCLUDE_DIRS}")

# ffi
if(WIN32)
    # import _ctypes
    set(LibFFI_INCLUDE_DIR ${_win32_libffi_folder}/${_win32_arch_name}/include)
    set(LibFFI_LIBRARY
        ${_win32_libffi_folder}/libffi-8.dll
        ${_win32_libffi_folder}/libffi-8.lib
    )
else()
    find_path(LibFFI_INCLUDE_DIR ffi.h)
    find_library(LibFFI_LIBRARY NAMES ffi libffi)
    if(APPLE)
        execute_process(COMMAND brew --prefix libffi OUTPUT_VARIABLE _libffi_prefix)
        find_path(LibFFI_INCLUDE_DIR ffi.h
            HINT _libffi_prefix
        )
    endif()
endif()
message(STATUS "LibFFI_INCLUDE_DIR=${LibFFI_INCLUDE_DIR}")
message(STATUS "LibFFI_LIBRARY=${LibFFI_LIBRARY}")

# libmpdec
if(WIN32)
    # import _decimal
    # include dir: Modules/_decimal/libmpdec
else()
    find_library(LIBMPDEC_LIBRARY NAMES mpdec libmpdec)
    set(LIBMPDEC_LIBRARIES ${LIBMPDEC_LIBRARY})
endif()
message(STATUS "LIBMPDEC_LIBRARIES=${LIBMPDEC_LIBRARIES}")

# OpenSSL
if(WIN32)
    # import _ssl
    set(OPENSSL_INCLUDE_DIR ${_win32_openssl_folder}/${_win32_arch_name}/include)
    set(OPENSSL_LIBRARIES
        ${_win32_openssl_folder}/${_win32_arch_name}/libcrypto-3.cll
        ${_win32_openssl_folder}/${_win32_arch_name}/libcrypto-3.pdb
        ${_win32_openssl_folder}/${_win32_arch_name}/libcrypto.lib
        ${_win32_openssl_folder}/${_win32_arch_name}/libssl-3.cll
        ${_win32_openssl_folder}/${_win32_arch_name}/libssl-3.pdb
        ${_win32_openssl_folder}/${_win32_arch_name}/libssl.lib
    )
else()
    find_package(OpenSSL 0.9.7) # https://cmake.org/cmake/help/latest/module/FindOpenSSL.html
endif()
message(STATUS "OPENSSL_LIBRARIES=${OPENSSL_LIBRARIES}")
message(STATUS "OPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR}")

# Tcl/Tk
if(WIN32)
    # import _tkinter
    set(TCL_INCLUDE_PATH ${_win32_tcltk_folder}/${_win32_arch_name}/include)
    set(TK_INCLUDE_PATH ${_win32_tcltk_folder}/${_win32_arch_name}/include)
    set(TCL_LIBRARY ${_win32_tcltk_folder}/${_win32_arch_name}/bin/tcl${_win32_tcltk_major_version}${_win32_tcltk_minor_version}t.dll)
    set(TK_LIBRARY ${_win32_tcltk_folder}/${_win32_arch_name}/bin/tk${_win32_tcltk_major_version}${_win32_tcltk_minor_version}t.dll)
else()
    find_package(TCL) # https://cmake.org/cmake/help/latest/module/FindTCL.html
endif()
message(STATUS "TCL_LIBRARY=${TCL_LIBRARY}")
message(STATUS "TCL_INCLUDE_PATH=${TCL_INCLUDE_PATH}")
message(STATUS "TK_LIBRARY=${TK_LIBRARY}")
message(STATUS "TK_INCLUDE_PATH=${TK_INCLUDE_PATH}")

if(UNIX)
    # Only needed by _tkinter
    find_package(X11)
    message(STATUS "X11_LIBRARIES=${X11_LIBRARIES}")
    message(STATUS "X11_INCLUDE_DIR=${X11_INCLUDE_DIR}")
endif()

# ZLIB
if(WIN32)
    # import zlib
    # zlib in pythoncore
    set(ZLIB_INCLUDE_DIRS ${_win32_zlib_folder})
else()
    find_package(ZLIB) # https://cmake.org/cmake/help/latest/module/FindZLIB.html
endif()
message(STATUS "ZLIB_INCLUDE_DIRS=${ZLIB_INCLUDE_DIRS}")
message(STATUS "ZLIB_LIBRARIES=${ZLIB_LIBRARIES}")

# DB5.3
if(WIN32)
    # Not available on win32
else()
    # import _dbm
    find_path(DB_INCLUDE_PATH db.h)
    find_library(DB_LIBRARY NAMES db-5.3)
    message(STATUS "DB_INCLUDE_PATH=${DB_INCLUDE_PATH}")
    message(STATUS "DB_LIBRARY=${DB_LIBRARY}")
endif()

# GDBM
if(WIN32)
    # Not available on win32
else()
    # import _gdbm
    find_path(GDBM_INCLUDE_PATH gdbm.h)
    find_library(GDBM_LIBRARY gdbm)
    find_library(GDBM_COMPAT_LIBRARY gdbm_compat)
    find_path(NDBM_INCLUDE_PATH ndbm.h)

    if(NDBM_INCLUDE_PATH)
        set(NDBM_TAG NDBM)
    else()
        find_path(GDBM_NDBM_INCLUDE_PATH gdbm/ndbm.h)
        if(GDBM_NDBM_INCLUDE_PATH)
            set(NDBM_TAG GDBM_NDBM)
        else()
            find_path(GDBM_DASH_NDBM_INCLUDE_PATH gdbm-ndbm.h)
            if(GDBM_DASH_NDBM_INCLUDE_PATH)
                set(NDBM_TAG GDBM_DASH_NDBM)
            endif()
        endif()
    endif()
    message(STATUS "GDBM_INCLUDE_PATH=${GDBM_INCLUDE_PATH}")
    message(STATUS "GDBM_LIBRARY=${GDBM_LIBRARY}")
    message(STATUS "GDBM_COMPAT_LIBRARY=${GDBM_COMPAT_LIBRARY}")
    message(STATUS "NDBM_TAG=${NDBM_TAG}")
    message(STATUS "<NDBM_TAG>_INCLUDE_PATH=${${NDBM_TAG}_INCLUDE_PATH}")
endif()

# lzma
if(WIN32)
    # import _lzma
    # There is a liblzma.vcxproj in PCbuild folder, and _lzma.pyd depends on liblzma
    set(LIBLZMA_INCLUDE_DIRS
        ${_win32_xz_folder}/src/liblzma/api
    )
else()
    find_package(LibLZMA) # https://cmake.org/cmake/help/latest/module/FindLibLZMA.html
endif()
message(STATUS "LIBLZMA_INCLUDE_DIRS=${LIBLZMA_INCLUDE_DIRS}")
message(STATUS "LIBLZMA_INCLUDE_DIRS=${LIBLZMA_LIBRARIES}")

# readline
if(WIN32)
    # Not available on win32
else()
    # import readline
    find_path(READLINE_INCLUDE_PATH editline/readline.h)
    find_library(READLINE_LIBRARY edit)
    message(STATUS "READLINE_INCLUDE_PATH=${READLINE_INCLUDE_PATH}")
    message(STATUS "READLINE_LIBRARY=${READLINE_LIBRARY}")
endif()

# SQLite3
if(WIN32)
    # import _sqlite3
    # There is a sqlite3.vcxproj in PCbuild folder, and _sqlite3.pyd depends on liblzma
    set(SQLite3_INCLUDE_DIRS ${_win32_sqlite_folder})
else()
    find_package(SQLite3) # https://cmake.org/cmake/help/latest/module/FindSQLite3.html
endif()
message(STATUS "SQLite3_INCLUDE_DIRS=${SQLite3_INCLUDE_DIRS}")
message(STATUS "SQLite3_LIBRARIES=${SQLite3_LIBRARIES}")

# tirpc
if(WIN32)
    # Not available on win32
else()
    # import nis
    find_path(TIRPC_RPC_INCLUDE_PATH rpc.h PATHS "/usr/include/tirpc/rpc")
    find_library(TIRPC_LIBRARY tirpc)
    message(STATUS "TIRPC_RPC_INCLUDE_PATH=${TIRPC_RPC_INCLUDE_PATH}")
    message(STATUS "TIRPC_LIBRARY=${TIRPC_LIBRARY}")
endif()

# uuid
# import _uuid
include(cmake/FindUUID.cmake)
message(STATUS "UUID_INCLUDE_DIR=${UUID_INCLUDE_DIR}")
message(STATUS "UUID_LIBRARY=${UUID_LIBRARY}")

if(WIN32)
    set(M_LIBRARIES )
    set(HAVE_LIBM 1)
    # From PC/pyconfig.h:
    #  This is a manually maintained version used for the Watcom,
    #  Borland and Microsoft Visual C++ compilers.  It is a
    #  standard part of the Python distribution.
else()

    # default hash algorithm
    set(_msg "Checking with-hash-algorithm")
    set(Py_HASH_ALGORITHM 0)
    message(STATUS "${_msg} [default]")

    # ABI version string for Python extension modules.  This appears between the
    # periods in shared library file names, e.g. foo.<SOABI>.so.  It is calculated
    # from the following attributes which affect the ABI of this Python build (in
    # this order):
    #
    # * The Python implementation (always 'cpython-' for us)
    # * The major and minor version numbers
    # * --with-pydebug (adds a 'd')
    #
    # Thus for example, Python 3.2 built with wide unicode, pydebug, and pymalloc,
    # would get a shared library ABI version tag of 'cpython-32dmu' and shared
    # libraries would be named 'foo.cpython-32dmu.so'.
    #
    # In Python 3.2 and older, --with-wide-unicode added a 'u' flag.
    # In Python 3.7 and older, --with-pymalloc added a 'm' flag.

    set(_msg "Checking ABIFLAGS")
    set(ABIFLAGS )
    if(Py_DEBUG)
        set(ABIFLAGS "${ABIFLAGS}d")
    endif()
    message(STATUS "${_msg} - ${ABIFLAGS}")

    set(_msg "Checking SOABI")
    try_run(PLATFORM_RUN PLATFORM_COMPILE
            ${PROJECT_BINARY_DIR} ${PROJECT_SOURCE_DIR}/cmake/platform.c
            RUN_OUTPUT_VARIABLE PLATFORM_TRIPLET)
    if(NOT PLATFORM_COMPILE)
        message(FATAL_ERROR "We could not determine the platform. Please clean the ${CMAKE_PROJECT_NAME} environment and try again...")
    endif()
    set(SOABI "cpython-${PY_VERSION_MAJOR}${PY_VERSION_MINOR}${ABIFLAGS}-${PLATFORM_TRIPLET}")
    message(STATUS "${_msg} - ${SOABI}")
endif()
