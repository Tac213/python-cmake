include(CheckIncludeFiles)
include(CheckTypeSize)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(cmake/PlatformTest.cmake)

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

    macro(add_cond var cond item)
        if(${cond})
            set(${var} ${${var}} ${item})
        endif()
    endmacro()

    set(CMAKE_REQUIRED_DEFINITIONS )

    # Convenient macro allowing to conditonally update CMAKE_REQUIRED_DEFINITIONS
    macro(set_required_def var value)
        set(${var} ${value})
        list(APPEND CMAKE_REQUIRED_DEFINITIONS "-D${var}=${value}")
    endmacro()

    # Emulate AC_HEADER_DIRENT
    check_include_files(dirent.h HAVE_DIRENT_H)
    if(NOT HAVE_DIRENT_H)
        check_include_files(sys/ndir.h HAVE_SYS_NDIR_H)
        set(CMAKE_EXTRA_INCLUDE_FILES "sys/dir.h")
        check_type_size(DIR HAVE_SYS_DIR_H)
        check_include_files(ndir.h HAVE_NDIR_H)
    endif()
    check_symbol_exists("dirfd" "sys/types.h;dirent.h" HAVE_DIRFD)

    check_include_files(alloca.h HAVE_ALLOCA_H) # libffi and cpython
    check_include_files(asm/types.h HAVE_ASM_TYPES_H)
    check_include_files(arpa/inet.h HAVE_ARPA_INET_H)
    check_include_files(bluetooth/bluetooth.h HAVE_BLUETOOTH_BLUETOOTH_H)
    check_include_files(bluetooth.h HAVE_BLUETOOTH_H)
    check_include_files(conio.h HAVE_CONIO_H)
    check_include_files(crypt.h HAVE_CRYPT_H)
    check_include_files(curses.h HAVE_CURSES_H)
    check_include_files(direct.h HAVE_DIRECT_H)
    check_include_files(dlfcn.h HAVE_DLFCN_H) # libffi and cpython
    check_include_files(errno.h HAVE_ERRNO_H)
    check_include_files(fcntl.h HAVE_FCNTL_H)
    check_include_files(fpu_control.h HAVE_FPU_CONTROL_H)
    check_include_files(grp.h HAVE_GRP_H)
    check_include_files(ieeefp.h HAVE_IEEEFP_H)
    check_include_files(inttypes.h HAVE_INTTYPES_H) # libffi and cpython
    check_include_files(io.h HAVE_IO_H)
    check_include_files(langinfo.h HAVE_LANGINFO_H)
    check_include_files(libintl.h HAVE_LIBINTL_H)
    check_include_files(libutil.h HAVE_LIBUTIL_H)
    check_include_files(linux/tipc.h HAVE_LINUX_TIPC_H)
    check_include_files(locale.h HAVE_LOCALE_H)

    check_include_files(sys/socket.h HAVE_SYS_SOCKET_H)

    set(LINUX_NETLINK_HEADERS)
    add_cond(LINUX_NETLINK_HEADERS HAVE_ASM_TYPES_H  asm/types.h)
    add_cond(LINUX_NETLINK_HEADERS HAVE_SYS_SOCKET_H sys/socket.h)
    set(LINUX_NETLINK_HEADERS ${LINUX_NETLINK_HEADERS} linux/netlink.h)
    check_include_files("${LINUX_NETLINK_HEADERS}" HAVE_LINUX_NETLINK_H)

    set(LINUX_QRTR_HEADERS)
    add_cond(LINUX_QRTR_HEADERS HAVE_ASM_TYPES_H  asm/types.h)
    add_cond(LINUX_QRTR_HEADERS HAVE_SYS_SOCKET_H sys/socket.h)
    set(LINUX_QRTR_HEADERS ${LINUX_QRTR_HEADERS} linux/qrtr.h)
    check_include_files("${LINUX_QRTR_HEADERS}" HAVE_LINUX_QRTR_H)

    # On Linux, can.h and can/raw.h require sys/socket.h
    set(LINUX_CAN_HEADERS)
    add_cond(LINUX_CAN_HEADERS HAVE_SYS_SOCKET_H sys/socket.h)
    check_include_files("${LINUX_CAN_HEADERS};linux/can.h" HAVE_LINUX_CAN_H)
    check_include_files("${LINUX_CAN_HEADERS};linux/can/bcm.h" HAVE_LINUX_CAN_BCM_H)
    check_include_files("${LINUX_CAN_HEADERS};linux/can/j1939.h" HAVE_LINUX_CAN_J1939_H)
    check_include_files("${LINUX_CAN_HEADERS};linux/can/raw.h" HAVE_LINUX_CAN_RAW_H)

    set(LINUX_VM_SOCKETS_HEADERS)
    add_cond(LINUX_VM_SOCKETS_HEADERS HAVE_SYS_SOCKET_H sys/socket.h)
    check_include_files("${LINUX_VM_SOCKETS_HEADERS};linux/vm_sockets.h" HAVE_LINUX_VM_SOCKETS_H)

    check_include_files(mach-o/dyld.h HAVE_MACH_O_DYLD_H)
    check_include_files(memory.h HAVE_MEMORY_H) # libffi and cpython
    check_include_files(minix/config.h HAVE_MINIX_CONFIG_H)
    check_include_files(ncurses.h HAVE_NCURSES_H)
    check_include_files(ncurses/panel.h HAVE_NCURSES_PANEL_H)
    check_include_files(netdb.h HAVE_NETDB_H)
    check_include_files(netinet/in.h HAVE_NETINET_IN_H)
    check_include_files(netpacket/packet.h HAVE_NETPACKET_PACKET_H)
    check_include_files(panel.h HAVE_PANEL_H)
    check_include_files(poll.h HAVE_POLL_H)
    check_include_files(process.h HAVE_PROCESS_H)
    check_include_files(pthread.h HAVE_PTHREAD_H)
    check_include_files(pty.h HAVE_PTY_H)
    check_include_files(pwd.h HAVE_PWD_H)
    check_include_files("stdio.h;readline/readline.h" HAVE_READLINE_READLINE_H)
    check_include_files(semaphore.h HAVE_SEMAPHORE_H)
    check_include_files(shadow.h HAVE_SHADOW_H)
    check_include_files(signal.h HAVE_SIGNAL_H)
    check_include_files(spawn.h HAVE_SPAWN_H)
    check_include_files(stdint.h HAVE_STDINT_H)   # libffi and cpython
    check_include_files(stdlib.h HAVE_STDLIB_H)   # libffi and cpython
    check_include_files(strings.h HAVE_STRINGS_H) # libffi and cpython
    check_include_files(string.h HAVE_STRING_H)   # libffi and cpython
    check_include_files(stropts.h HAVE_STROPTS_H)
    check_include_files(sysexits.h HAVE_SYSEXITS_H)
    check_include_files(sys/audioio.h HAVE_SYS_AUDIOIO_H)
    check_include_files(sys/bsdtty.h HAVE_SYS_BSDTTY_H)
    check_include_files(sys/epoll.h HAVE_SYS_EPOLL_H)
    check_include_files(sys/event.h HAVE_SYS_EVENT_H)
    check_include_files(sys/file.h HAVE_SYS_FILE_H)
    check_include_files(sys/loadavg.h HAVE_SYS_LOADAVG_H)
    check_include_files(sys/lock.h HAVE_SYS_LOCK_H)
    check_include_files(sys/sysmacros.h HAVE_SYS_SYSMACROS_H)
    check_include_files(sys/mkdev.h HAVE_SYS_MKDEV_H)
    check_include_files(sys/mman.h HAVE_SYS_MMAN_H) # libffi and cpython
    check_include_files(sys/modem.h HAVE_SYS_MODEM_H)
    check_include_files(sys/param.h HAVE_SYS_PARAM_H)
    check_include_files(sys/poll.h HAVE_SYS_POLL_H)
    check_include_files(sys/random.h HAVE_SYS_RANDOM_H)
    check_include_files(sys/resource.h HAVE_SYS_RESOURCE_H)
    check_include_files(sys/select.h HAVE_SYS_SELECT_H)
    check_include_files(sys/statvfs.h HAVE_SYS_STATVFS_H)
    check_include_files(sys/stat.h HAVE_SYS_STAT_H) # libffi and cpython
    check_include_files(sys/timeb.h HAVE_SYS_TIMEB_H)
    check_include_files(sys/termio.h HAVE_SYS_TERMIO_H)
    check_include_files(sys/times.h HAVE_SYS_TIMES_H)
    check_include_files(sys/time.h HAVE_SYS_TIME_H)
    check_include_files(sys/types.h HAVE_SYS_TYPES_H) # libffi and cpython
    check_include_files(sys/un.h HAVE_SYS_UN_H)
    check_include_files(sys/utsname.h HAVE_SYS_UTSNAME_H)
    check_include_files(sys/wait.h HAVE_SYS_WAIT_H)
    check_include_files(termios.h HAVE_TERMIOS_H)
    check_include_files(term.h HAVE_TERM_H)

    check_include_files(unistd.h HAVE_UNISTD_H) # libffi and cpython
    check_include_files(util.h HAVE_UTIL_H)
    check_include_files(utime.h HAVE_UTIME_H)
    check_include_files(wchar.h HAVE_WCHAR_H)
    check_include_files("stdlib.h;stdarg.h;string.h;float.h" STDC_HEADERS) # libffi and cpython

    check_include_files(stdarg.h HAVE_STDARG_PROTOTYPES)

    check_include_files(endian.h HAVE_ENDIAN_H)
    check_include_files(sched.h HAVE_SCHED_H)
    check_include_files(linux/memfd.h HAVE_LINUX_MEMFD_H)
    check_include_files(linux/random.h HAVE_LINUX_RANDOM_H)
    check_include_files(sys/devpoll.h HAVE_SYS_DEVPOLL_H)
    check_include_files(sys/endian.h HAVE_SYS_ENDIAN_H)
    check_include_files(sys/ioctl.h HAVE_SYS_IOCTL_H)
    check_include_files(sys/memfd.h HAVE_SYS_MEMFD_H)
    check_include_files("sys/types.h;sys/kern_control.h" HAVE_SYS_KERN_CONTROL_H)
    check_include_files(sys/sendfile.h HAVE_SYS_SENDFILE_H)
    check_include_files(sys/syscall.h HAVE_SYS_SYSCALL_H)
    check_include_files(sys/sys_domain.h HAVE_SYS_SYS_DOMAIN_H)
    check_include_files(sys/uio.h HAVE_SYS_UIO_H)
    check_include_files(sys/xattr.h HAVE_SYS_XATTR_H)

    # On Darwin (OS X) net/if.h requires sys/socket.h to be imported first.
    set(NET_IF_HEADERS stdio.h)
    if(STDC_HEADERS)
        set(NET_IF_HEADERS stdlib.h stddef.h)
    else()
        add_cond(NET_IF_HEADERS HAVE_STDLIB_H stdlib.h)
    endif()
    add_cond(NET_IF_HEADERS HAVE_SYS_SOCKET_H sys/socket.h)
    list(APPEND NET_IF_HEADERS net/if.h)
    check_include_files("${NET_IF_HEADERS}" HAVE_NET_IF_H)

    find_file(HAVE_DEV_PTMX NAMES /dev/ptmx PATHS / NO_DEFAULT_PATH)
    find_file(HAVE_DEV_PTC  NAMES /dev/ptc  PATHS / NO_DEFAULT_PATH)
    message(STATUS "ptmx: ${HAVE_DEV_PTMX} ptc: ${HAVE_DEV_PTC}")

    find_library(HAVE_LIBCURSES curses)
    find_library(HAVE_LIBCRYPT crypt)
    if(NOT DEFINED HAVE_LIBDL)
        set(HAVE_LIBDL ${CMAKE_DL_LIBS} CACHE STRING "Name of library containing dlopen and dlcose.")
    endif()
    find_library(HAVE_LIBDLD dld)
    find_library(HAVE_LIBINTL intl)

    set(M_LIBRARIES )
    check_function_exists("acosh" HAVE_BUILTIN_ACOSH)
    if(HAVE_BUILTIN_ACOSH)
        # Math functions are builtin the environment (e.g emscripten)
        set(M_LIBRARIES )
        set(HAVE_LIBM 1)
    else()
        find_library(HAVE_LIBM m)
        set(M_LIBRARIES ${HAVE_LIBM})
    endif()

    find_library(HAVE_LIBNCURSES ncurses)
    find_library(HAVE_LIBNSL nsl)
    find_library(HAVE_LIBREADLINE readline)

    find_library(HAVE_LIBSENDFILE sendfile)

    find_library(HAVE_LIBTERMCAP termcap)

    set(LIBUTIL_LIBRARIES )
    set(LIBUTIL_EXPECTED 1)

    if(CMAKE_SYSTEM MATCHES "VxWorks\\-7$")
        set(LIBUTIL_EXPECTED 0)
        set(HAVE_LIBUTIL 0)
    endif()

    if(LIBUTIL_EXPECTED)
        check_function_exists("openpty" HAVE_BUILTIN_OPENPTY)
        if(HAVE_BUILTIN_OPENPTY)
            # Libutil functions are builtin the environment (e.g emscripten)
            set(LIBUTIL_LIBRARIES )
            set(HAVE_LIBUTIL 1)
        else()
            message(${HAVE_LIBUTIL})
            if(NOT DEFINED HAVE_LIBUTIL OR "${HAVE_LIBUTIL}" STREQUAL "" OR "${HAVE_LIBUTIL}" STREQUAL "HAVE_LIBUTIL-NOTFOUND")
                find_library(HAVE_LIBUTIL util)
                message(STATUS "Found libutil: ${HAVE_LIBUTIL}")
            endif()
            if(HAVE_LIBUTIL)
                set(LIBUTIL_LIBRARIES ${HAVE_LIBUTIL})
            endif()
        endif()
            message(${HAVE_LIBUTIL})
        if(NOT HAVE_LIBUTIL)
            message(FATAL_ERROR "Could NOT find libutil (missing: HAVE_LIBUTIL)")
        endif()
    endif()

    if(APPLE)
        find_library(HAVE_LIBCOREFOUNDATION CoreFoundation)
        find_library(HAVE_LIBSYSTEMCONFIGURATION SystemConfiguration)
    endif()

    set(CMAKE_HAVE_PTHREAD_H ${HAVE_PTHREAD_H}) # Skip checking for header a second time.
    find_package(Threads)
    if(CMAKE_HAVE_LIBC_CREATE)
        set_required_def(_REENTRANT 1)
    endif()

    set(check_src ${PROJECT_BINARY_DIR}/CMakeFiles/ac_cv_lib_crypto_RAND_egd.c)
    file(WRITE ${check_src} "/* Override any GCC internal prototype to avoid an error.
      Use char because int might match the return type of a GCC
      builtin and then its argument prototype would still apply.  */
    #ifdef __cplusplus
    extern \"C\"
    #endif
    char RAND_egd ();
    int main () { return RAND_egd (); }
    ")
    cmake_push_check_state()
    python_platform_test(
        HAVE_RAND_EGD
        "Checking for RAND_egd in -lcrypto"
        ${check_src}
        DIRECT
    )
    cmake_pop_check_state()

    set_required_def(_POSIX_THREADS 1)    # Define on Linux as it is required for threading
    set_required_def(_POSIX_SOURCE 1)     # Define on Linux in order for 'stat' and other things to work.
    set_required_def(_GNU_SOURCE 1)       # Define on Linux to activate all library features
    set_required_def(_NETBSD_SOURCE 1)    # Define on NetBSD to activate all library features
    set_required_def(__BSD_VISIBLE 1)     # Define on FreeBSD to activate all library features
    set_required_def(_BSD_TYPES 1)        # Define on Irix to enable u_int
    set_required_def(_DARWIN_C_SOURCE 1)  # Define on Darwin to activate all library features

    set_required_def(_ALL_SOURCE 1)       # Enable extensions on AIX 3, Interix.
    set_required_def(_POSIX_PTHREAD_SEMANTICS 1) # Enable threading extensions on Solaris.
    set_required_def(_TANDEM_SOURCE 1)    # Enable extensions on HP NonStop.

    set_required_def(__EXTENSIONS__ 1)    # Defined on Solaris to see additional function prototypes.


    if(HAVE_MINIX_CONFIG_H)
        set_required_def(_POSIX_1_SOURCE 2) # Define to 2 if the system does not provide POSIX.1 features except with this defined.
        set_required_def(_MINIX 1)          # Define to 1 if on MINIX.
    endif()

    message(STATUS "Checking for XOPEN_SOURCE")

    # Some systems cannot stand _XOPEN_SOURCE being defined at all; they
    # disable features if it is defined, without any means to access these
    # features as extensions. For these systems, we skip the definition of
    # _XOPEN_SOURCE. Before adding a system to the list to gain access to
    # some feature, make sure there is no alternative way to access this
    # feature. Also, when using wildcards, make sure you have verified the
    # need for not defining _XOPEN_SOURCE on all systems matching the
    # wildcard, and that the wildcard does not include future systems
    # (which may remove their limitations).
    set(define_xopen_source 1)

    # On OpenBSD, select(2) is not available if _XOPEN_SOURCE is defined,
    # even though select is a POSIX function. Reported by J. Ribbens.
    # Reconfirmed for OpenBSD 3.3 by Zachary Hamm, for 3.4 by Jason Ish.
    # In addition, Stefan Krah confirms that issue #1244610 exists through
    # OpenBSD 4.6, but is fixed in 4.7.
    if(CMAKE_SYSTEM MATCHES "OpenBSD\\-2\\."
       OR CMAKE_SYSTEM MATCHES "OpenBSD\\-3\\."
       OR CMAKE_SYSTEM MATCHES "OpenBSD\\-4\\.[0-6]$")

        #OpenBSD/2.* | OpenBSD/3.* | OpenBSD/4.@<:@0123456@:>@

        set(define_xopen_source 0)

        # OpenBSD undoes our definition of __BSD_VISIBLE if _XOPEN_SOURCE is
        # also defined. This can be overridden by defining _BSD_SOURCE
        # As this has a different meaning on Linux, only define it on OpenBSD
        set_required_def(_BSD_SOURCE 1)     # Define on OpenBSD to activate all library features

    elseif(CMAKE_SYSTEM MATCHES OpenBSD)

        # OpenBSD/*

        # OpenBSD undoes our definition of __BSD_VISIBLE if _XOPEN_SOURCE is
        # also defined. This can be overridden by defining _BSD_SOURCE
        # As this has a different meaning on Linux, only define it on OpenBSD
        set_required_def(_BSD_SOURCE 1)     # Define on OpenBSD to activate all library features

    elseif(CMAKE_SYSTEM MATCHES "NetBSD\\-1\\.5$"
           OR CMAKE_SYSTEM MATCHES "NetBSD\\-1\\.5\\."
           OR CMAKE_SYSTEM MATCHES "NetBSD\\-1\\.6$"
           OR CMAKE_SYSTEM MATCHES "NetBSD\\-1\\.6\\."
           OR CMAKE_SYSTEM MATCHES "NetBSD\\-1\\.6[A-S]$")

        # NetBSD/1.5 | NetBSD/1.5.* | NetBSD/1.6 | NetBSD/1.6.* | NetBSD/1.6@<:@A-S@:>@

        # Defining _XOPEN_SOURCE on NetBSD version prior to the introduction of
        # _NETBSD_SOURCE disables certain features (eg. setgroups). Reported by
        # Marc Recht
        set(define_xopen_source 0)

    elseif(CMAKE_SYSTEM MATCHES SunOS)

        # SunOS/*)

        # From the perspective of Solaris, _XOPEN_SOURCE is not so much a
        # request to enable features supported by the standard as a request
        # to disable features not supported by the standard.  The best way
        # for Python to use Solaris is simply to leave _XOPEN_SOURCE out
        # entirely and define __EXTENSIONS__ instead.

        set(define_xopen_source 0)

    elseif(CMAKE_SYSTEM MATCHES "OpenUNIX\\-8\\.0\\.0$"
           OR CMAKE_SYSTEM MATCHES "UnixWare\\-7\\.1\\.[0-4]$")

        # OpenUNIX/8.0.0| UnixWare/7.1.@<:@0-4@:>@

        # On UnixWare 7, u_long is never defined with _XOPEN_SOURCE,
        # but used in /usr/include/netinet/tcp.h. Reported by Tim Rice.
        # Reconfirmed for 7.1.4 by Martin v. Loewis.

        set(define_xopen_source 0)

    elseif(CMAKE_SYSTEM MATCHES "SCO_SV\\-3\\.2$")

        # SCO_SV/3.2

        # On OpenServer 5, u_short is never defined with _XOPEN_SOURCE,
        # but used in struct sockaddr.sa_family. Reported by Tim Rice.

        set(define_xopen_source 0)

    elseif(CMAKE_SYSTEM MATCHES "FreeBSD\\-4\\.")

        # FreeBSD/4.*

        # On FreeBSD 4, the math functions C89 does not cover are never defined
        # with _XOPEN_SOURCE and __BSD_VISIBLE does not re-enable them.

        set(define_xopen_source 0)

    elseif(CMAKE_SYSTEM MATCHES "Darwin\\-[6789]\\."
           OR CMAKE_SYSTEM MATCHES "Darwin\\-1[0-9]\\.")

        # Darwin/@<:@6789@:>@.*)
        # Darwin/1@<:@0-9@:>@.*

        # On MacOS X 10.2, a bug in ncurses.h means that it craps out if
        # _XOPEN_EXTENDED_SOURCE is defined. Apparently, this is fixed in 10.3, which
        # identifies itself as Darwin/7.*
        # On Mac OS X 10.4, defining _POSIX_C_SOURCE or _XOPEN_SOURCE
        # disables platform specific features beyond repair.
        # On Mac OS X 10.3, defining _POSIX_C_SOURCE or _XOPEN_SOURCE
        # has no effect, don't bother defining them

        set(define_xopen_source 0)

    elseif(CMAKE_SYSTEM MATCHES "AIX\\-4$"
           OR CMAKE_SYSTEM MATCHES "AIX\\-5\\.1$")
        # On AIX 4 and 5.1, mbstate_t is defined only when _XOPEN_SOURCE == 500 but
        # used in wcsnrtombs() and mbsnrtowcs() even if _XOPEN_SOURCE is not defined
        # or has another value. By not (re)defining it, the defaults come in place.

        set(define_xopen_source 0)

    elseif(CMAKE_SYSTEM MATCHES "QNX\\-6\\.3\\.2$")

        # QNX/6.3.2

        # On QNX 6.3.2, defining _XOPEN_SOURCE prevents netdb.h from
        # defining NI_NUMERICHOST.

        set(define_xopen_source 0)

    elseif(CMAKE_SYSTEM MATCHES "VxWorks\\-7$")

        # VxWorks-7

        # On VxWorks-7, defining _XOPEN_SOURCE or _POSIX_C_SOURCE
        # leads to a failure in select.h because sys/types.h fails
        # to define FD_SETSIZE.
        # Reported by Martin Oberhuber as V7COR-4651.

        set(define_xopen_source 0)

    endif()

    if(define_xopen_source)
        message(STATUS "Checking for XOPEN_SOURCE - yes")
        set_required_def(_XOPEN_SOURCE_EXTENDED 1) # Define to activate Unix95-and-earlier features
        set_required_def(_XOPEN_SOURCE 700)        # Define to the level of X/Open that your system supports
        set_required_def(_POSIX_C_SOURCE 200809L)  # Define to activate features from IEEE Stds 1003.1-2008
    else()
        message(STATUS "Checking for XOPEN_SOURCE - no")
    endif()


    message(STATUS "Checking for Large File Support")
    set(use_lfs 1)  # Consider disabling "lfs" if porting to Solaris (2.6 to 9) with gcc 2.95.
                    # See associated test in configure.in
    if(use_lfs)
        message(STATUS "Checking for Large File Support - yes")
        if(CMAKE_SYSTEM MATCHES AIX)
            set_required_def(_LARGE_FILES 1)        # This must be defined on AIX systems to enable large file support.
        endif()
        set_required_def(_LARGEFILE_SOURCE 1)     # This must be defined on some systems to enable large file support.
        set_required_def(_FILE_OFFSET_BITS 64)    # This must be set to 64 on some systems to enable large file support.
    else()
        message(STATUS "Checking for Large File Support - no")
    endif()

endif()  # if(WIN32)