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
add_python_extension(_ctypes_test NEVER_BUILTIN REQUIRES HAVE_LIBM SOURCES _ctypes/_ctypes_test.c LIBRARIES ${M_LIBRARIES})
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
add_python_extension(_testcapi NEVER_BUILTIN SOURCES _testcapimodule.c)

set(thread_REQUIRES)
if(PY_VERSION VERSION_LESS "3.7")
  list(APPEND thread_REQUIRES WITH_THREAD)
endif()
add_python_extension(_thread ALWAYS_BUILTIN REQUIRES ${thread_REQUIRES} SOURCES _threadmodule.c DEFINITIONS Py_BUILD_CORE)
add_python_extension(time ${WIN32_BUILTIN} ${PY3_BUILTIN} REQUIRES HAVE_LIBM SOURCES timemodule.c DEFINITIONS Py_BUILD_CORE LIBRARIES ${M_LIBRARIES} ${TIMEMODULE_LIB})
add_python_extension(unicodedata SOURCES unicodedata.c)

add_python_extension(atexit BUILTIN REQUIRES IS_PY3 SOURCES atexitmodule.c) # Register functions to be run at interpreter-shutdown
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
    add_python_extension(_uuid REQUIRES UUID_LIBRARY "HAVE_UUID_H OR HAVE_UUID_UUID_H" SOURCES _uuidmodule.c LIBRARIES ${UUID_LIBRARY})
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

# FIX ME: test code, print all builtin extension source files
# List of builtin extensions
get_property(builtin_extensions GLOBAL PROPERTY builtin_extensions)

# Collect builtin extension sources
set(builtin_extension_sources)
foreach(name ${builtin_extensions})
    get_property(extension_${name}_sources GLOBAL PROPERTY extension_${name}_sources)
    list(APPEND builtin_extension_sources ${extension_${name}_sources})
endforeach()
foreach(source_file ${builtin_extension_sources})
    message(STATUS ${source_file})
endforeach()
