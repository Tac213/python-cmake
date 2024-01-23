set(WIN32_BUILTIN )
if(WIN32)
    set(WIN32_BUILTIN BUILTIN)
endif()

set(PY3_BUILTIN )
set(PY3_ALWAYS_BUILTIN )
if(IS_PY3)
    set(PY3_BUILTIN BUILTIN)
    set(PY3_ALWAYS_BUILTIN ALWAYS_BUILTIN)
endif()

add_python_extension(array ${WIN32_BUILTIN} SOURCES arraymodule.c)
add_python_extension(audioop ${WIN32_BUILTIN} REQUIRES HAVE_LIBM SOURCES audioop.c LIBRARIES ${M_LIBRARIES})
add_python_extension(_bisect ${WIN32_BUILTIN} SOURCES _bisectmodule.c)
if(PY_VERSION VERSION_GREATER_EQUAL "3.11")
    add_python_extension(cmath REQUIRES HAVE_LIBM ${WIN32_BUILTIN} SOURCES cmathmodule.c LIBRARIES ${M_LIBRARIES})
else()
    add_python_extension(cmath REQUIRES HAVE_LIBM ${WIN32_BUILTIN} SOURCES _math.c cmathmodule.c LIBRARIES ${M_LIBRARIES})
endif()
add_python_extension(_codecs_cn ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_cn.c)
add_python_extension(_codecs_hk ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_hk.c)
add_python_extension(_codecs_iso2022 ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_iso2022.c)
add_python_extension(_codecs_jp ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_jp.c)
add_python_extension(_codecs_kr ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_kr.c)
add_python_extension(_codecs_tw ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_tw.c)
add_python_extension(_collections ${WIN32_BUILTIN} ${PY3_BUILTIN} SOURCES _collectionsmodule.c) # Container types
add_python_extension(_crypt REQUIRES HAVE_LIBCRYPT SOURCES _cryptmodule.c LIBRARIES ${HAVE_LIBCRYPT})
add_python_extension(_csv ${WIN32_BUILTIN} SOURCES _csv.c)
# add_python_extension(_ctypes_test NEVER_BUILTIN REQUIRES HAVE_LIBM SOURCES _ctypes/_ctypes_test.c LIBRARIES ${M_LIBRARIES})
add_python_extension(_datetime ${WIN32_BUILTIN} REQUIRES HAVE_LIBM SOURCES _datetimemodule.c LIBRARIES ${M_LIBRARIES})
add_python_extension(_functools ${WIN32_BUILTIN} ${PY3_BUILTIN} SOURCES _functoolsmodule.c DEFINITIONS Py_BUILD_CORE) # Tools for working with functions and callable objects
add_python_extension(_heapq ${WIN32_BUILTIN} SOURCES _heapqmodule.c)

set(_io_SOURCES
    _io/_iomodule.c
    _io/bufferedio.c
    _io/bytesio.c
    _io/fileio.c
    _io/iobase.c
    _io/stringio.c
    _io/textio.c
    )
if(WIN32 AND EXISTS ${SRC_DIR}/Modules/_io/winconsoleio.c)
    list(APPEND _io_SOURCES
        ${SRC_DIR}/Modules/_io/winconsoleio.c
        )
endif()
add_python_extension(_io ${WIN32_BUILTIN} ${PY3_ALWAYS_BUILTIN} SOURCES ${_io_SOURCES} DEFINITIONS Py_BUILD_CORE)

add_python_extension(itertools ${WIN32_BUILTIN} ${PY3_BUILTIN} SOURCES itertoolsmodule.c) # Functions creating iterators for efficient looping
add_python_extension(_json ${WIN32_BUILTIN} SOURCES _json.c)
add_python_extension(_locale ${WIN32_BUILTIN} ${PY3_BUILTIN} SOURCES _localemodule.c) # access to ISO C locale support
add_python_extension(_lsprof ${WIN32_BUILTIN} SOURCES _lsprof.c rotatingtree.c)
if(PY_VERSION VERSION_GREATER_EQUAL "3.11")
    add_python_extension(math ${WIN32_BUILTIN} REQUIRES HAVE_LIBM SOURCES mathmodule.c LIBRARIES ${M_LIBRARIES})
else()
    add_python_extension(math ${WIN32_BUILTIN} REQUIRES HAVE_LIBM SOURCES _math.c mathmodule.c LIBRARIES ${M_LIBRARIES})
endif()
add_python_extension(mmap ${WIN32_BUILTIN} SOURCES mmapmodule.c)
add_python_extension(_multibytecodec ${WIN32_BUILTIN} SOURCES cjkcodecs/multibytecodec.c)
if(PY_VERSION VERSION_LESS "3.10")
    add_python_extension(parser ${WIN32_BUILTIN} SOURCES parsermodule.c)
endif()
add_python_extension(_random ${WIN32_BUILTIN} SOURCES _randommodule.c)
add_python_extension(_struct ${WIN32_BUILTIN} SOURCES _struct.c)
# add_python_extension(_testcapi NEVER_BUILTIN SOURCES _testcapimodule.c)

set(thread_REQUIRES)
if(PY_VERSION VERSION_LESS "3.7")
  list(APPEND thread_REQUIRES WITH_THREAD)
endif()
add_python_extension(_thread ALWAYS_BUILTIN REQUIRES ${thread_REQUIRES} SOURCES _threadmodule.c DEFINITIONS Py_BUILD_CORE)
add_python_extension(time ${WIN32_BUILTIN} ${PY3_ALWAYS_BUILTIN} REQUIRES HAVE_LIBM SOURCES timemodule.c DEFINITIONS Py_BUILD_CORE LIBRARIES ${M_LIBRARIES} ${TIMEMODULE_LIB})
add_python_extension(unicodedata SOURCES unicodedata.c)

add_python_extension(atexit ALWAYS_BUILTIN REQUIRES IS_PY3 SOURCES atexitmodule.c) # Register functions to be run at interpreter-shutdown
add_python_extension(_codecs BUILTIN SOURCES _codecsmodule.c) # access to the builtin codecs and codec registry
add_python_extension(faulthandler ALWAYS_BUILTIN REQUIRES IS_PY3 SOURCES faulthandler.c)
add_python_extension(_opcode ${WIN32_BUILTIN} REQUIRES IS_PY3 SOURCES _opcode.c)
add_python_extension(_operator BUILTIN REQUIRES IS_PY3 SOURCES _operator.c)
add_python_extension(_pickle ${WIN32_BUILTIN} REQUIRES IS_PY3 SOURCES _pickle.c)
if(PY_VERSION VERSION_GREATER_EQUAL "3.11")
    add_python_extension(_sre BUILTIN SOURCES _sre/sre.c) # Fredrik Lundh's new regular expressions
else()
    add_python_extension(_sre BUILTIN SOURCES _sre.c) # Fredrik Lundh's new regular expressions
endif()
add_python_extension(_stat BUILTIN REQUIRES IS_PY3 SOURCES _stat.c) # stat.h interface
add_python_extension(_symtable BUILTIN SOURCES symtablemodule.c)
# Python PEP-3118 (buffer protocol) test module
add_python_extension(_testbuffer REQUIRES IS_PY3 SOURCES _testbuffer.c)
# Test loading multiple modules from one compiled file (http://bugs.python.org/issue16421)
add_python_extension(_testimportmultiple REQUIRES IS_PY3 SOURCES _testimportmultiple.c)
# Test multi-phase extension module init (PEP 489)
add_python_extension(_testmultiphase REQUIRES IS_PY3 SOURCES _testmultiphase.c)
# debug tool to trace memory blocks allocated by Python
set(_tracemalloc_SOURCES _tracemalloc.c)
if(PY_VERSION VERSION_GREATER "3.9")
    list(APPEND _tracemalloc_SOURCES
        ${SRC_DIR}/Python/hashtable.c
        )
else()
    list(APPEND _tracemalloc_SOURCES
        ${SRC_DIR}/Modules/hashtable.c
        )
endif()
add_python_extension(_tracemalloc ALWAYS_BUILTIN REQUIRES IS_PY3 SOURCES ${_tracemalloc_SOURCES})
add_python_extension(_weakref ALWAYS_BUILTIN SOURCES _weakref.c)
math(EXPR _limited_api_version "${PY_VERSION_MAJOR} * 100 + ${PY_VERSION_MINOR}")
add_python_extension(xxlimited REQUIRES IS_PY3 BUILD_TESTING
    SOURCES xxlimited.c
    DEFINITIONS Py_LIMITED_API=0x${_limited_api_version}0000
    NO_INSTALL
)
add_python_extension(xxsubtype BUILTIN SOURCES xxsubtype.c)
if(PY_VERSION VERSION_LESS "3.8")
    # The zipimport module is always imported at startup. Having it as a
    # builtin module avoids some bootstrapping problems and reduces overhead.
    add_python_extension(zipimport ALWAYS_BUILTIN SOURCES zipimport.c DEFINITIONS Py_BUILD_CORE)
endif()

if(PY_VERSION VERSION_GREATER_EQUAL "3.6")
    # asyncio speedups
    add_python_extension(_asyncio SOURCES _asynciomodule.c)
    # blake module
    set(_blake2_SOURCES
        _blake2/blake2module.c
        _blake2/blake2b_impl.c
        _blake2/blake2s_impl.c
    )
    add_python_extension(_blake2 ${WIN32_BUILTIN} SOURCES ${_blake2_SOURCES})
    if(PY_VERSION VERSION_GREATER_EQUAL "3.12")
        add_python_extension(_sha3 ${WIN32_BUILTIN}
            SOURCES sha3module.c _hacl/Hacl_Hash_SHA3.c
            DEFINITIONS _BSD_SOURCE _DEFAULT_SOURCE
            INCLUDEDIRS ${SRC_DIR}/Modules/_hacl/include
        )
    else()
        add_python_extension(_sha3 ${WIN32_BUILTIN} SOURCES _sha3/sha3module.c)
    endif()
    add_python_extension(_testconsole ${WIN32_BUILTIN} REQUIRES WIN32 SOURCES ../PC/_testconsole.c)
endif()

if(PY_VERSION VERSION_GREATER_EQUAL "3.7")
    add_python_extension(_abc BUILTIN SOURCES _abc.c)
    add_python_extension(_contextvars ${WIN32_BUILTIN} SOURCES _contextvarsmodule.c)
    add_python_extension(_queue SOURCES _queuemodule.c)
    if(WIN32)
        add_python_extension(_uuid SOURCES _uuidmodule.c)
    else()
        add_python_extension(_uuid REQUIRES UUID_LIBRARY "HAVE_UUID_H OR HAVE_UUID_UUID_H" SOURCES _uuidmodule.c LIBRARIES ${UUID_LIBRARY})
    endif()
    add_python_extension(_xxtestfuzz SOURCES _xxtestfuzz/_xxtestfuzz.c
                                             _xxtestfuzz/fuzzer.c
    )
endif()

if(PY_VERSION VERSION_GREATER_EQUAL "3.8")
    add_python_extension(_testinternalcapi SOURCES _testinternalcapi.c DEFINITIONS "PY3_DLLNAME=\"${PY3_DLLNAME}\"")
endif()

if(PY_VERSION VERSION_EQUAL "3.9")
    add_python_extension(_peg_parser ALWAYS_BUILTIN SOURCES _peg_parser.c)
endif()

if(PY_VERSION VERSION_GREATER_EQUAL "3.11")
    add_python_extension(_typing ${WIN32_BUILTIN} SOURCES _typingmodule.c)
endif()

# UNIX-only extensions
add_python_extension(fcntl REQUIRES UNIX SOURCES fcntlmodule.c)
add_python_extension(grp REQUIRES UNIX SOURCES grpmodule.c)

if(PY_VERSION VERSION_LESS "3.13")
    set(nis_REQUIRES UNIX HAVE_LIBNSL)
    set(nis_LIBRARIES ${HAVE_LIBNSL})
    set(nis_INCLUDEDIRS )
    if(TIRPC_LIBRARY AND TIRPC_RPC_INCLUDE_PATH)
        # if rpc.h is provided by libtirpc (instead of being provided by glibc). See python/cpython#5137
        list(APPEND nis_LIBRARIES ${TIRPC_LIBRARY})
        list(APPEND nis_INCLUDEDIRS ${TIRPC_RPC_INCLUDE_PATH}/../)
        if(TIRPC_LIBRARY_STATIC_DEPENDENCY_REQUIRED)
            list(APPEND nis_REQUIRES TIRPC_STATIC_LIBRARIES)
            list(APPEND nis_LIBRARIES ${TIRPC_STATIC_LIBRARIES})
        endif()
    endif()
    add_python_extension(nis
        REQUIRES ${nis_REQUIRES}
        SOURCES nismodule.c
        LIBRARIES ${nis_LIBRARIES}
        INCLUDEDIRS ${nis_INCLUDEDIRS}
    )
endif()

add_python_extension(posix REQUIRES UNIX ALWAYS_BUILTIN SOURCES posixmodule.c DEFINITIONS Py_BUILD_CORE)
add_python_extension(pwd REQUIRES UNIX BUILTIN SOURCES pwdmodule.c) # this is needed to find out the user's home dir if $HOME is not set
add_python_extension(resource REQUIRES UNIX SOURCES resource.c)
add_python_extension(spwd REQUIRES UNIX HAVE_GETSPNAM HAVE_GETSPENT SOURCES spwdmodule.c)
add_python_extension(syslog REQUIRES UNIX SOURCES syslogmodule.c)
add_python_extension(termios REQUIRES UNIX SOURCES termios.c)

add_python_extension(errno BUILTIN UNIX SOURCES errnomodule.c)
add_python_extension(_posixsubprocess REQUIRES IS_PY3 UNIX SOURCES _posixsubprocess.c)

# MacOSX-only extensions
set(_scproxy2_SOURCES ${SRC_DIR}/Mac/Modules/_scproxy.c)
set(_scproxy3_SOURCES ${SRC_DIR}/Modules/_scproxy.c)
add_python_extension(_scproxy
    REQUIRES APPLE HAVE_LIBCOREFOUNDATION HAVE_LIBSYSTEMCONFIGURATION
    SOURCES ${_scproxy${PY_VERSION_MAJOR}_SOURCES}
    LIBRARIES ${HAVE_LIBSYSTEMCONFIGURATION} ${HAVE_LIBCOREFOUNDATION}
)

# Linux-only extensions
add_python_extension(ossaudiodev REQUIRES LINUX SOURCES ossaudiodev.c)

# Python 3.8: UNIX-only extensions
if(PY_VERSION VERSION_GREATER_EQUAL "3.8")
    set(_posixshmem_LIBRARIES)
    if(HAVE_SHM_OPEN_IN_RT)
        list(APPEND _posixshmem_LIBRARIES rt)
    endif()
    add_python_extension(_posixshmem REQUIRES UNIX SOURCES _multiprocessing/posixshmem.c LIBRARIES ${_posixshmem_LIBRARIES} INCLUDEDIRS ${SRC_DIR}/Modules/_multiprocessing)
endif()

# Windows-only extensions
add_python_extension(_msi
    REQUIRES WIN32
    SOURCES ${SRC_DIR}/PC/_msi.c
    LIBRARIES cabinet.lib msi.lib rpcrt4.lib
)
if(WIN32 AND (PY_VERSION VERSION_LESS "3.12") AND NOT BUILTIN_MSI)
    set_property(
        SOURCE ${SRC_DIR}/PC/_msi.c
        PROPERTY COMPILE_DEFINITIONS
            NEEDS_PY_IDENTIFIER
    )
endif()
add_python_extension(msvcrt REQUIRES MSVC BUILTIN SOURCES ${SRC_DIR}/PC/msvcrtmodule.c)
add_python_extension(nt REQUIRES WIN32 ALWAYS_BUILTIN SOURCES posixmodule.c)

add_python_extension(winreg REQUIRES WIN32 ALWAYS_BUILTIN SOURCES ${SRC_DIR}/PC/winreg.c)

# Python3: Windows-only extensions
add_python_extension(_overlapped
    REQUIRES WIN32 IS_PY3
    SOURCES ${SRC_DIR}/Modules/overlapped.c
    LIBRARIES ws2_32 $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.9>:pathcch>
)
add_python_extension(_winapi REQUIRES WIN32 IS_PY3 BUILTIN SOURCES ${SRC_DIR}/Modules/_winapi.c)

set(HAS_DISTUTILS_FINDVS_MODULE_SRC 0)
set(module_src ${SRC_DIR}/PC/_findvs.cpp)
if(EXISTS ${module_src})
  set(HAS_DISTUTILS_FINDVS_MODULE_SRC 1)
endif()
add_python_extension(_distutils_findvs REQUIRES WIN32 IS_PY3 HAS_DISTUTILS_FINDVS_MODULE_SRC SOURCES ${module_src})

# Multiprocessing is different on unix and windows
if(UNIX)
    set(_multiprocessing2_SOURCES
        _multiprocessing/socket_connection.c
    )
    set(_multiprocessing3_SOURCES )
    if(HAVE_SEM_OPEN AND NOT POSIX_SEMAPHORES_NOT_ENABLED)
        list(APPEND _multiprocessing${PY_VERSION_MAJOR}_SOURCES
            _multiprocessing/semaphore.c
        )
    endif()
    set(_multiprocessing_REQUIRES)
    if(PY_VERSION VERSION_LESS "3.7")
      list(APPEND _multiprocessing_REQUIRES WITH_THREAD)
    endif()
    add_python_extension(_multiprocessing
        SOURCES _multiprocessing/multiprocessing.c
                ${_multiprocessing${PY_VERSION_MAJOR}_SOURCES}
        REQUIRES ${_multiprocessing_REQUIRES}
        INCLUDEDIRS ${SRC_DIR}/Modules/_multiprocessing
    )
elseif(WIN32)
    set(_multiprocessing2_SOURCES
        _multiprocessing/pipe_connection.c
        _multiprocessing/socket_connection.c
        _multiprocessing/win32_functions.c
    )
    set(_multiprocessing3_SOURCES )
    add_python_extension(_multiprocessing
        SOURCES _multiprocessing/multiprocessing.c
                _multiprocessing/semaphore.c
                ${_multiprocessing${PY_VERSION_MAJOR}_SOURCES}
        LIBRARIES ws2_32
    )
endif()

# Select needs winsock on Windows
if(WIN32)
    add_python_extension(select SOURCES selectmodule.c LIBRARIES ws2_32)
else()
    add_python_extension(select SOURCES selectmodule.c)
endif()

# Socket is different on Windows
set(_socket_SOURCES socketmodule.c)
if(WIN32)
    add_python_extension(_socket
        REQUIRES HAVE_LIBM
        SOURCES ${_socket_SOURCES}
        DEFINITIONS EAI_ADDRFAMILY
                    # HAVE_SOCKADDR_STORAGE
                    # HAVE_ADDRINFO
        LIBRARIES ws2_32 ${M_LIBRARIES} $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:iphlpapi>
    )
else()
    if(PY_VERSION VERSION_GREATER_EQUAL "2.7.4" AND PY_VERSION VERSION_LESS "3")
        list(APPEND _socket_SOURCES timemodule.c)
    endif()
    add_python_extension(_socket
        REQUIRES HAVE_LIBM
        SOURCES ${_socket_SOURCES}
        LIBRARIES ${M_LIBRARIES}
    )
endif()

# _ctypes
# Common ctypes sources
set(ctypes_COMMON_SOURCES
    _ctypes/_ctypes.c
    _ctypes/callbacks.c
    _ctypes/callproc.c
    _ctypes/stgdict.c
    _ctypes/cfield.c
)
if(WIN32)
    add_python_extension(_ctypes
        # REQUIRES LibFFI_INCLUDE_DIR LibFFI_LIBRARY
        SOURCES ${ctypes_COMMON_SOURCES}
                _ctypes/malloc_closure.c
        DEFINITIONS USING_MALLOC_CLOSURE_DOT_C
        INCLUDEDIRS ${LibFFI_INCLUDE_DIR}
        LIBRARIES libffi
    )
elseif(APPLE)
    add_python_extension(_ctypes
        REQUIRES LibFFI_INCLUDE_DIR LibFFI_LIBRARY
        SOURCES ${ctypes_COMMON_SOURCES}
                _ctypes/malloc_closure.c
        DEFINITIONS Py_BUILD_CORE_MODULE FFI_BUILDING USING_MALLOC_CLOSURE_DOT_C MACOSX
        INCLUDEDIRS ${LibFFI_INCLUDE_DIR}
        LIBRARIES ${LibFFI_LIBRARY}
    )
else()
    if(HAVE_LIBDL)
        add_python_extension(_ctypes
            REQUIRES LibFFI_INCLUDE_DIR LibFFI_LIBRARY
            SOURCES ${ctypes_COMMON_SOURCES}
            DEFINITIONS Py_BUILD_CORE_MODULE FFI_BUILDING HAVE_FFI_PREP_CIF_VAR HAVE_FFI_PREP_CLOSURE_LOC HAVE_FFI_CLOSURE_ALLOC
            INCLUDEDIRS ${LibFFI_INCLUDE_DIR}
            LIBRARIES ${LibFFI_LIBRARY} ${HAVE_LIBDL}
        )
    else()
        add_python_extension(_ctypes
            REQUIRES LibFFI_INCLUDE_DIR LibFFI_LIBRARY
            SOURCES ${ctypes_COMMON_SOURCES}
            DEFINITIONS Py_BUILD_CORE_MODULE FFI_BUILDING
            INCLUDEDIRS ${LibFFI_INCLUDE_DIR}
            LIBRARIES ${LibFFI_LIBRARY}
        )
    endif()
endif()

# _decimal
set(libmpdec_config_x64          CONFIG_64 ASM)
set(libmpdec_config_uint128      CONFIG_64 ANSI HAVE_UINT128_T)
set(libmpdec_config_ansi64       CONFIG_64 ANSI)
set(libmpdec_config_ppro         CONFIG_32 PPRO ASM)
set(libmpdec_config_ansi32       CONFIG_32 PPRO) # XXX Is ANSI needed here ?
set(libmpdec_config_ansi_legacy  CONFIG_32 ANSI LEGACY_COMPILER)
set(libmpdec_config_universal    UNIVERSAL)

if(SYSTEM_LIBMPDEC_FOUND)
    set(_decimal_REQUIRES REQUIRES LIBMPDEC_LIBRARIES)
    set(_decimal_LIBRARIES LIBRARIES ${LIBMPDEC_LIBRARIES})
    set(_decimal_EXTRA_SOURCES )
    set(_decimal_INCLUDEDIRS )
else()
    set(_decimal_REQUIRES )
    set(_decimal_EXTRA_SOURCES
        _decimal/libmpdec/basearith.c
        _decimal/libmpdec/constants.c
        _decimal/libmpdec/context.c
        _decimal/libmpdec/convolute.c
        _decimal/libmpdec/crt.c
        _decimal/libmpdec/difradix2.c
        _decimal/libmpdec/fnt.c
        _decimal/libmpdec/fourstep.c
        _decimal/libmpdec/io.c
        _decimal/libmpdec/mpdecimal.c
        _decimal/libmpdec/numbertheory.c
        _decimal/libmpdec/sixstep.c
        _decimal/libmpdec/transpose.c
    )
    if(PY_VERSION VERSION_GREATER_EQUAL "3.9")
        list(APPEND _decimal_EXTRA_SOURCES
            _decimal/libmpdec/mpalloc.c
        )
    else()
        list(APPEND _decimal_EXTRA_SOURCES
            _decimal/libmpdec/memory.c
        )
    endif()
    if(WIN32)
        if(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
            list(APPEND _decimal_EXTRA_SOURCES
                _decimal/libmpdec/vcdiv64.asm
            )
        endif()
    endif()
    set(_decimal_INCLUDEDIRS INCLUDEDIRS ${SRC_DIR}/Modules/_decimal/libmpdec)
endif()

set(libmpdec_config )
set(_decimal_compile_flags )
if(APPLE)
    # Universal here means: build with the same options Python
    # was built with.
    set(libmpdec_config universal)
elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
    if(HAVE_GCC_ASM_FOR_X64)
        set(libmpdec_config x64)
    elseif(HAVE_GCC_UINT128_T)
        set(libmpdec_config uint128)
    else()
        set(libmpdec_config ansi64)
    endif()
elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
    if(HAVE_GCC_ASM_FOR_X87 AND
        (CMAKE_C_COMPILER_ID MATCHES "GNU" OR CMAKE_C_COMPILER_ID MATCHES "Clang")
        AND NOT CMAKE_SYSTEM MATCHES SunOS
    )
        # solaris: problems with register allocation.
        # icc >= 11.0 works as well.
        set(libmpdec_config ppro)
        list(APPEND _decimal_compile_flags "-Wno-unknown-pragmas")
    else()
      set(libmpdec_config ansi32)
    endif()
else()
    message(FATAL_ERROR "extension_decimal: unsupported architecture")
endif()

# Workarounds for toolchain bugs:
if(HAVE_IPA_PURE_CONST_BUG)
    # Some versions of gcc miscompile inline asm:
    # http://gcc.gnu.org/bugzilla/show_bug.cgi?id=46491
    # http://gcc.gnu.org/ml/gcc/2010-11/msg00366.html
    list(APPEND _decimal_compile_flags "-fno-ipa-pure-const")
endif()
if(HAVE_GLIBC_MEMMOVE_BUG)
    # _FORTIFY_SOURCE wrappers for memmove and bcopy are incorrect:
    # http://sourceware.org/ml/libc-alpha/2010-12/msg00009.html
    # XXX Implement missing logic
#    undef_macros.append('_FORTIFY_SOURCE')
endif()

if(NOT WITH_THREAD AND PY_VERSION VERSION_LESS "3.7")
    # Faster version without thread local contexts:
    list(APPEND libmpdec_config_${libmpdec_config}
        WITHOUT_THREADS
    )
endif()

if(WIN32)
    list(APPEND libmpdec_config_${libmpdec_config}
        _CRT_SECURE_NO_WARNINGS MASM
    )
endif()

# Uncomment for extra functionality:
#list(APPEND libmpdec_config_${libmpdec_config} EXTRA_FUNCTIONALITY)

if(ENABLE_DECIMAL)
    message(STATUS "extension_decimal: libmpdec_config [${libmpdec_config}]")
endif()
add_python_extension(_decimal
    SOURCES
        _decimal/_decimal.c
        _decimal/docstrings.h
        ${_decimal_EXTRA_SOURCES}
    DEFINITIONS ${libmpdec_config_${libmpdec_config}}
    ${_decimal_REQUIRES}
    ${_decimal_LIBRARIES}
    ${_decimal_INCLUDEDIRS}
)
if(_decimal_compile_flags AND ENABLE_DECIMAL AND NOT BUILTIN_DECIMAL)
    set_target_properties(extension_decimal PROPERTIES COMPILE_FLAGS ${_decimal_compile_flags})
endif()

# Build expat using the system expat if it's installed, otherwise use the
# builtin version.
if(EXPAT_LIBRARIES AND EXPAT_INCLUDE_DIRS)
    add_python_extension(pyexpat
        SOURCES pyexpat.c
        LIBRARIES ${EXPAT_LIBRARIES}
        INCLUDEDIRS ${EXPAT_INCLUDE_DIRS}
    )
    add_python_extension(_elementtree
        SOURCES _elementtree.c
        LIBRARIES ${EXPAT_LIBRARIES}
        INCLUDEDIRS ${EXPAT_INCLUDE_DIRS}
    )
else()
    set(_pyexpat_definitions XML_STATIC)
    set(_pyexpat_SOURCES
        pyexpat.c
        expat/xmlparse.c
        expat/xmlrole.c
        expat/xmltok.c
        )
    if(UNIX)
        list(APPEND _pyexpat_definitions HAVE_EXPAT_CONFIG_H)
        # bpo-30947: Python uses best available entropy sources to
        # call XML_SetHashSalt(), expat entropy sources are not needed
        list(APPEND _pyexpat_definitions XML_POOR_ENTROPY)
    elseif(WIN32)
        list(APPEND _pyexpat_definitions COMPILED_FROM_DSP)
        if(EXISTS "${SRC_DIR}/Modules/expat/loadlibrary.c")
            list(APPEND _pyexpat_SOURCES "${SRC_DIR}/Modules/expat/loadlibrary.c")
        endif()
    endif()
    add_python_extension(pyexpat
        SOURCES ${_pyexpat_SOURCES}
        DEFINITIONS ${_pyexpat_definitions}
        INCLUDEDIRS ${SRC_DIR}/Modules/expat
    )
    set(_elementtree_definitions USE_PYEXPAT_CAPI)
    if(WIN32)
        list(APPEND _elementtree_definitions COMPILED_FROM_DSP)
    endif()
    add_python_extension(_elementtree
        SOURCES _elementtree.c
        DEFINITIONS ${_elementtree_definitions}
        INCLUDEDIRS ${SRC_DIR}/Modules/expat
    )
endif()

# We always compile these even when OpenSSL is available (issue #14693).
# It's harmless and the object code is tiny (40-50 KB per module,
# only loaded when actually used).
if(PY_VERSION VERSION_GREATER_EQUAL "3.12")
    add_python_extension(_md5 ${WIN32_BUILTIN}
        SOURCES md5module.c _hacl/Hacl_Hash_MD5.c
        DEFINITIONS _BSD_SOURCE _DEFAULT_SOURCE
        INCLUDEDIRS ${SRC_DIR}/Modules/_hacl/include
    )
    add_python_extension(_sha1 ${WIN32_BUILTIN}
        SOURCES sha1module.c _hacl/Hacl_Hash_SHA1.c
        DEFINITIONS _BSD_SOURCE _DEFAULT_SOURCE
        INCLUDEDIRS ${SRC_DIR}/Modules/_hacl/include
    )
else()
    add_python_extension(_md5 ${WIN32_BUILTIN} SOURCES md5module.c)
    add_python_extension(_sha1 ${WIN32_BUILTIN} SOURCES sha1module.c)
    add_python_extension(_sha256 ${WIN32_BUILTIN} SOURCES sha256module.c)
    add_python_extension(_sha512 ${WIN32_BUILTIN} SOURCES sha512module.c)
endif()

if(PY_VERSION VERSION_GREATER_EQUAL "3.12")
    add_python_extension(_sha2 ${WIN32_BUILTIN}
        SOURCES sha2module.c _hacl/Hacl_Hash_SHA2.c
        DEFINITIONS _BSD_SOURCE _DEFAULT_SOURCE
        INCLUDEDIRS ${SRC_DIR}/Modules/_hacl/include
    )
endif()

# Extensions that depend on other libraries
set(binascii_REQUIRES "")
set(binascii_DEFINITIONS "")
set(binascii_LIBRARIES "")
set(binascii_INCLUDEDIRS "")
if(ZLIB_LIBRARY)
    list(APPEND binascii_REQUIRES ZLIB_INCLUDE_DIR)
    list(APPEND binascii_DEFINITIONS USE_ZLIB_CRC32)
    list(APPEND binascii_LIBRARIES ${ZLIB_LIBRARY})
    list(APPEND binascii_INCLUDEDIRS ${ZLIB_INCLUDE_DIR})
endif()
add_python_extension(binascii
    REQUIRES ${binascii_REQUIRES}
    ${WIN32_BUILTIN}
    SOURCES binascii.c
    DEFINITIONS ${binascii_DEFINITIONS}
    LIBRARIES ${binascii_LIBRARIES}
    INCLUDEDIRS ${binascii_INCLUDEDIRS}
)

# _bz2
if(WIN32)
    add_python_extension(_bz2
        SOURCES _bz2module.c
                ${BZIP2_INCLUDE_DIR}/blocksort.c
                ${BZIP2_INCLUDE_DIR}/bzlib.c
                ${BZIP2_INCLUDE_DIR}/compress.c
                ${BZIP2_INCLUDE_DIR}/crctable.c
                ${BZIP2_INCLUDE_DIR}/decompress.c
                ${BZIP2_INCLUDE_DIR}/huffman.c
                ${BZIP2_INCLUDE_DIR}/randtable.c
                ${BZIP2_INCLUDE_DIR}/bzlib.h
                ${BZIP2_INCLUDE_DIR}/bzlib_private.h
        INCLUDEDIRS ${BZIP2_INCLUDE_DIR}
    )
else()
    add_python_extension(_bz2
        REQUIRES BZIP2_LIBRARIES BZIP2_INCLUDE_DIR
        SOURCES _bz2module.c
        LIBRARIES ${BZIP2_LIBRARIES}
        INCLUDEDIRS ${BZIP2_INCLUDE_DIR}
    )
endif()

# _curses
set(curses_common_REQUIRES CURSES_LIBRARIES)
set(curses_common_LIBRARIES ${CURSES_LIBRARIES})
add_python_extension(_curses_panel
    REQUIRES ${curses_common_REQUIRES} PANEL_LIBRARIES "HAVE_PANEL_H OR HAVE_NCURSES_PANEL_H"
    SOURCES _curses_panel.c
    LIBRARIES ${curses_common_LIBRARIES} ${PANEL_LIBRARIES}
)
add_python_extension(_curses
    REQUIRES ${curses_common_REQUIRES}
    SOURCES _cursesmodule.c
    LIBRARIES ${curses_common_LIBRARIES}
)

# _dbm
add_python_extension(_dbm
    REQUIRES NDBM_TAG GDBM_LIBRARY GDBM_COMPAT_LIBRARY
    SOURCES _dbmmodule.c
    DEFINITIONS HAVE_${NDBM_TAG}_H
    LIBRARIES ${GDBM_LIBRARY} ${GDBM_COMPAT_LIBRARY}
    INCLUDEDIRS ${${NDBM_TAG}_INCLUDE_PATH}
)

# _gdbm
add_python_extension(_gdbm
    REQUIRES GDBM_INCLUDE_PATH GDBM_LIBRARY GDBM_COMPAT_LIBRARY
    SOURCES _gdbmmodule.c
    DEFINITIONS HAVE_GDBM_DASH_NDBM_H
    LIBRARIES ${GDBM_LIBRARY}
    INCLUDEDIRS ${GDBM_INCLUDE_PATH}
)

# _hashlib
if(WIN32)
    add_python_extension(_hashlib
        REQUIRES OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES
        SOURCES _hashopenssl.c
        LIBRARIES OpenSSL::Crypto OpenSSL::SSL
        INCLUDEDIRS ${OPENSSL_INCLUDE_DIR}
    )
else()
    add_python_extension(_hashlib
        REQUIRES OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES
        SOURCES _hashopenssl.c
        LIBRARIES ${OPENSSL_LIBRARIES}
        INCLUDEDIRS ${OPENSSL_INCLUDE_DIR}
    )
endif()
if(ENABLE_HASHLIB AND CMAKE_C_COMPILER_ID MATCHES GNU)
    set_property(SOURCE ${SRC_DIR}/Modules/_hashopenssl.c PROPERTY COMPILE_FLAGS -Wno-deprecated-declarations)
endif()

# _lzma
if(WIN32)
    add_python_extension(_lzma
        SOURCES _lzmamodule.c
        DEFINITIONS MODULE_NAME="lzma" LZMA_API_STATIC=1
        INCLUDEDIRS ${LIBLZMA_INCLUDE_DIRS}
        LIBRARIES liblzma::liblzma
    )
else()
    add_python_extension(_lzma
        REQUIRES LIBLZMA_INCLUDE_DIRS LIBLZMA_LIBRARIES
        SOURCES _lzmamodule.c
        DEFINITIONS MODULE_NAME="lzma" LZMA_API_STATIC=1
        INCLUDEDIRS ${LIBLZMA_INCLUDE_DIRS}
        LIBRARIES ${LIBLZMA_LIBRARIES}
    )
endif()

# readline
add_python_extension(readline
    REQUIRES READLINE_INCLUDE_PATH READLINE_LIBRARY CURSES_LIBRARIES HAVE_READLINE_READLINE_H
    SOURCES readline.c
    LIBRARIES ${READLINE_LIBRARY} ${CURSES_LIBRARIES}
    INCLUDEDIRS ${READLINE_INCLUDE_PATH}
)

# _sqlite3
set(_sqlite3_SOURCES
    _sqlite/connection.c
    _sqlite/cursor.c
    _sqlite/microprotocols.c
    _sqlite/module.c
    _sqlite/prepare_protocol.c
    _sqlite/row.c
    _sqlite/statement.c
    _sqlite/util.c
)
if(PY_VERSION VERSION_GREATER_EQUAL "3.11")
    list(APPEND _sqlite3_SOURCES _sqlite/blob.c)
else()
    list(APPEND _sqlite3_SOURCES _sqlite/cache.c)
endif()
if(WIN32)
    add_python_extension(_sqlite3
        SOURCES ${_sqlite3_SOURCES}
        DEFINITIONS MODULE_NAME="sqlite3" SQLITE_OMIT_LOAD_EXTENSION=1
        INCLUDEDIRS ${SQLite3_INCLUDE_DIRS}
        LIBRARIES sqlite3::sqlite3
    )
else()
    add_python_extension(_sqlite3
        REQUIRES SQLite3_INCLUDE_DIRS SQLite3_LIBRARIES
        SOURCES ${_sqlite3_SOURCES}
        DEFINITIONS MODULE_NAME="sqlite3" SQLITE_OMIT_LOAD_EXTENSION=1
        INCLUDEDIRS ${SQLite3_INCLUDE_DIRS}
        LIBRARIES ${SQLite3_LIBRARIES}
    )
    if(ENABLE_SQLITE3 AND CMAKE_C_COMPILER_ID MATCHES GNU)
        set_property(SOURCE ${SRC_DIR}/Modules/_sqlite/module.c PROPERTY COMPILE_FLAGS -Wno-deprecated-declarations)
    endif()
endif()

# _ssl
set(_ssl_LIBRARIES ${OPENSSL_LIBRARIES})
if(WIN32)
    set(_ssl_LIBRARIES ws2_32 Crypt32 OpenSSL::Crypto OpenSSL::SSL)
endif()
set(_ssl_SOURCES _ssl.c)
if(WIN32)
    list(APPEND _ssl_SOURCES ${OPENSSL_INCLUDE_DIR}/applink.c)
endif()
add_python_extension(_ssl
    REQUIRES OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES
    SOURCES ${_ssl_SOURCES}
    LIBRARIES ${_ssl_LIBRARIES}
    INCLUDEDIRS ${OPENSSL_INCLUDE_DIR}
)

# _tkinter
set(_tkinter_REQUIRES TCL_LIBRARY TK_LIBRARY TCL_INCLUDE_PATH TK_INCLUDE_PATH)
set(_tkinter_LIBRARIES ${TCL_LIBRARY} ${TK_LIBRARY})
set(_tkinter_INCLUDEDIRS ${TCL_INCLUDE_PATH} ${TK_INCLUDE_PATH})
if(WIN32)
    set(_tkinter_LIBRARIES TclTk::Tcl TclTk::Tk)
endif()
if(UNIX)
    list(APPEND _tkinter_REQUIRES X11_INCLUDE_DIR X11_LIBRARIES)
    list(APPEND _tkinter_LIBRARIES ${X11_LIBRARIES})
    list(APPEND _tkinter_INCLUDEDIRS ${X11_INCLUDE_DIR})
endif()
add_python_extension(_tkinter
    REQUIRES ${_tkinter_REQUIRES}
    SOURCES _tkinter.c tkappinit.c
    DEFINITIONS WITH_APPINIT=1
    LIBRARIES ${_tkinter_LIBRARIES}
    INCLUDEDIRS ${_tkinter_INCLUDEDIRS}
)

# zlib
if(WIN32)
    add_python_extension(zlib BUILTIN
        SOURCES
            zlibmodule.c
            ${ZLIB_INCLUDE_DIRS}/adler32.c
            ${ZLIB_INCLUDE_DIRS}/compress.c
            ${ZLIB_INCLUDE_DIRS}/crc32.c
            ${ZLIB_INCLUDE_DIRS}/deflate.c
            ${ZLIB_INCLUDE_DIRS}/infback.c
            ${ZLIB_INCLUDE_DIRS}/inffast.c
            ${ZLIB_INCLUDE_DIRS}/inflate.c
            ${ZLIB_INCLUDE_DIRS}/inftrees.c
            ${ZLIB_INCLUDE_DIRS}/trees.c
            ${ZLIB_INCLUDE_DIRS}/uncompr.c
            ${ZLIB_INCLUDE_DIRS}/zutil.c
        INCLUDEDIRS ${ZLIB_INCLUDE_DIRS}
    )
else()
    add_python_extension(zlib
        REQUIRES ZLIB_LIBRARIES ZLIB_INCLUDE_DIRS
        SOURCES zlibmodule.c
        LIBRARIES ${ZLIB_LIBRARIES}
        INCLUDEDIRS ${ZLIB_INCLUDE_DIRS}
    )
endif()
