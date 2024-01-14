cmake_minimum_required(VERSION 3.13.5)

set(PYTHON_VERSION "3.12.1" CACHE STRING "The version of Python to build.")

string(REPLACE "." ";" VERSION_LIST ${PYTHON_VERSION})
list(GET VERSION_LIST 0 PY_VERSION_MAJOR)
list(GET VERSION_LIST 1 PY_VERSION_MINOR)
list(GET VERSION_LIST 2 PY_VERSION_PATCH)
set(PY_VERSION "${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${PY_VERSION_PATCH}")

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES Release CACHE STRING "Release configuration" FORCE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Release")
endif()

if(APPLE)
    set(_msg "Checking which MACOSX_DEPLOYMENT_TARGET to use")
    message(STATUS "${_msg}")
    include(cmake/PythonAutoDetectOSX.cmake)
    set(MACOSX_DEPLOYMENT_TARGET ${CMAKE_OSX_DEPLOYMENT_TARGET})
    message(STATUS "${_msg} - ${MACOSX_DEPLOYMENT_TARGET}")
endif()

project(Python C ASM)

# Include helper functions
include(cmake/Extensions.cmake)

option(BUILD_LIBPYTHON_SHARED "Build libpython as a shared library" ON)
option(BUILD_EXTENSIONS_AS_BUILTIN "Default all modules as builtin to libpython" ON)
option(INSTALL_DEVELOPMENT "Install files required to develop C extensions" ON)

# Append an item to a string if it does not already contain it.  Any additional
# arguments are treated as extra "set" arguments
macro(append_if_absent VARNAME VALUE)
    if(NOT ${VARNAME} MATCHES "(^| )${VALUE}($| )")
        if(${VARNAME})
            set(${VARNAME} "${${VARNAME}} ${VALUE}" ${ARGN})
        else()
            set(${VARNAME} "${VALUE}" ${ARGN})
        endif()
    endif()
endmacro()


set(Py_DEBUG OFF)
set(WITH_DOC_STRINGS 1)
set(WITH_PYMALLOC 1)

# Detect source directory
set(_landmark "pyconfig.h.in") # CMake will look for this file.
if(NOT (SRC_DIR AND EXISTS ${SRC_DIR}/${_landmark}))
    foreach(dirname
        ${CMAKE_CURRENT_SOURCE_DIR}/cpython-${PY_VERSION}
        ${CMAKE_CURRENT_SOURCE_DIR}/Python-${PY_VERSION})
        set(SRC_DIR ${dirname})
        if(EXISTS ${SRC_DIR}/${_landmark})
            break()
        endif()
    endforeach()
endif()

# Download sources
get_filename_component(_parent_dir ${CMAKE_CURRENT_BINARY_DIR} PATH)
string(REGEX REPLACE "[a-z]+[1-9]$" "" _py_version_patch_no_rc ${PY_VERSION_PATCH})
set(_py_version_no_rc "${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}.${_py_version_patch_no_rc}")
set(_download_link "https://www.python.org/ftp/python/${_py_version_no_rc}/Python-${PY_VERSION}.tgz")

set(_download_3.12.0_md5 "d6eda3e1399cef5dfde7c4f319b0596c")
set(_download_3.12.1_md5 "51c5c22dcbc698483734dff5c8028606")

set(_extracted_dir "Python-${PY_VERSION}")

if(NOT EXISTS ${SRC_DIR}/${_landmark})
    get_filename_component(_filename ${_download_link} NAME)
    set(_archive_filepath ${CMAKE_CURRENT_SOURCE_DIR}/${_filename})
    if(EXISTS "${_archive_filepath}")
        message(STATUS "${_filename} already downloaded")
    else()
        message(STATUS "Downloading ${_download_link}")
        if(NOT DEFINED _download_${PY_VERSION}_md5)
            message(FATAL_ERROR "Selected PY_VERSION [${PY_VERSION}] is not associated with any checksum. Consider updating this CMakeLists.txt setting _download_${PY_VERSION}_md5 variable")
        endif()
        file(
          DOWNLOAD ${_download_link} ${_archive_filepath}
          EXPECTED_MD5 ${_download_${PY_VERSION}_md5}
          SHOW_PROGRESS
          )
    endif()

    message(STATUS "Extracting ${_filename}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xfz ${_archive_filepath}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        RESULT_VARIABLE rv)
    if(NOT rv EQUAL 0)
        message(FATAL_ERROR "error: extraction of '${_filename}' failed")
        file(REMOVE ${_archive_filepath})
    endif()
    set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${_extracted_dir})
    file(REMOVE ${_archive_filepath})
endif()

message(STATUS "SRC_DIR: ${SRC_DIR}")

# Extract version string from python source (Copied from FindPythonLibs.cmake)
file(STRINGS "${SRC_DIR}/Include/patchlevel.h" python_version_str
    REGEX "^#define[ \t]+PY_VERSION[ \t]+\"[^\"]+\"")
string(REGEX REPLACE "^#define[ \t]+PY_VERSION[ \t]+\"([^\"]+)\".*" "\\1"
      PY_VERSION_LONG "${python_version_str}")

include(cmake/PythonExtractVersionInfo.cmake)
python_extract_version_info(
    VERSION_STRING "${PY_VERSION_LONG}"
)
message(STATUS "PY_VERSION     : ${PY_VERSION}")
message(STATUS "PY_VERSION_LONG: ${PY_VERSION_LONG}")

# Check version
if(NOT DEFINED _download_${PY_VERSION_LONG}_md5)
    message(WARNING "warning: selected python version '${PY_VERSION_LONG}' is not tested. Tested versions match '2.7.[3-14]' or '3.5.[1-5]' or `3.6.[0-4]`")
endif()
if(NOT "${PYTHON_VERSION}" STREQUAL "${PY_VERSION}")
    message(STATUS "Overwriting PYTHON_VERSION with value read from 'patchlevel.h': ${PYTHON_VERSION} -> ${PY_VERSION}")
    set(PYTHON_VERSION "${PY_VERSION}" CACHE STRING "The version of Python to build." FORCE)
endif()

# TODO: Apply patches

# Convenience boolean variables to easily test python version
set(IS_PY3 0)
set(IS_PY2 1)
if(PY_VERSION_MAJOR VERSION_GREATER 2)
    set(IS_PY3 1)
    set(IS_PY2 0)
endif()

set(PY3_DLLNAME python3)
if(Py_DEBUG)
    set(PY3_DLLNAME ${PY3_DLLNAME}_d)
endif()

if(WIN32)
    enable_language(CXX)
endif()

# This is the major version number of Python
set(LIBPYTHON_VERSION ${PY_VERSION_MAJOR}.${PY_VERSION_MINOR})
if(WIN32)
    set(LIBPYTHON_VERSION ${PY_VERSION_MAJOR}${PY_VERSION_MINOR})
endif()
set(LIBPYTHON python${LIBPYTHON_VERSION})

# Proceed to the configure checks
include(cmake/ConfigureChecks.cmake)

# Set PYTHONHOME
set(LIBDIR "Lib") # See Lib/distutils/sysconfig.py - function 'get_python_lib'
if(UNIX)
    set(LIBDIR "lib")
endif()
set(PYTHONHOME "${LIBDIR}")
if(UNIX)
    set(PYTHONHOME "${PYTHONHOME}/${LIBPYTHON}")
endif()

# Install tree directory
set(BIN_INSTALL_DIR bin)                         # Contains the python executable
set(LD_VERSION ${LIBPYTHON_VERSION}${ABIFLAGS})
set(CONFIG_INSTALL_DIR share/${LIBPYTHON})
set(EXTENSION_INSTALL_DIR ${PYTHONHOME}/lib-dynload)
set(LIB_CONFIG_INSTALL_DIR ${PYTHONHOME}/config-${LD_VERSION})
set(INCLUDE_INSTALL_DIR include/python${LD_VERSION})
if(WIN32)
    set(INCLUDE_INSTALL_DIR include)
endif()

# Build tree directory
set(BIN_BUILD_DIR ${PROJECT_BINARY_DIR}/bin)
set(CONFIG_BUILD_DIR ${PROJECT_BINARY_DIR}/${CONFIG_INSTALL_DIR})
set(EXTENSION_BUILD_DIR ${PROJECT_BINARY_DIR}/${PYTHONHOME}/lib-dynload)
set(INCLUDE_BUILD_DIR ${SRC_DIR}/Include)

set(ARCHIVEDIR "libs")      # Contains the static (*.a) and import libraries (*.lib)

# Directories specific to 'libpython'
set(LIBPYTHON_LIBDIR ${LIBDIR})
set(LIBPYTHON_ARCHIVEDIR ${LIBDIR})
set(LIBPYTHON_STATIC_ARCHIVEDIR ${LIBDIR})
if(WIN32)
    set(LIBPYTHON_LIBDIR ${BIN_INSTALL_DIR})
    set(LIBPYTHON_ARCHIVEDIR ${ARCHIVEDIR})
    set(LIBPYTHON_STATIC_ARCHIVEDIR static-${ARCHIVEDIR})
endif()

set(EXTRA_PYTHONPATH "" CACHE STRING
    "A colon (:) separated list of extra paths to add to the PYTHONPATH")

# Configure 'pyconfig.h'
if(UNIX)
    set(PYCONFIG_BUILD_DIR ${BIN_BUILD_DIR})
    configure_file(cmake/config-unix/pyconfig.h.in
                   ${PYCONFIG_BUILD_DIR}/pyconfig.h)
elseif(WIN32)
    set(PYCONFIG_BUILD_DIR ${SRC_DIR}/PC) # In a windows build tree, 'pyconfig.h' is NOT required to
                                          # live along side the python executable.
                                          # See function '_init_posix()' and '_init_non_posix()'
                                          # in 'Lib/sysconfig.py'
endif()

# Install 'pyconfig.h'
if(INSTALL_DEVELOPMENT)
    install(FILES ${PYCONFIG_BUILD_DIR}/pyconfig.h
            DESTINATION ${INCLUDE_INSTALL_DIR}/
            COMPONENT Development)
endif()

# Set include directories
include_directories(${INCLUDE_BUILD_DIR})
include_directories(${INCLUDE_BUILD_DIR}/internal)
include_directories(${PYCONFIG_BUILD_DIR})
include_directories(${SRC_DIR}/Python)

# Set cflags used by all components
if(CMAKE_C_COMPILER_ID MATCHES GNU)
    if(PY_VERSION VERSION_GREATER_EQUAL "3.6")
        append_if_absent(CMAKE_C_FLAGS "-std=c99")
    endif()
    append_if_absent(CMAKE_C_FLAGS "-Wall")
    append_if_absent(CMAKE_C_FLAGS "-Wstrict-prototypes")
    append_if_absent(CMAKE_C_FLAGS "-fno-strict-aliasing")
    append_if_absent(CMAKE_C_FLAGS "-fwrapv")
    append_if_absent(CMAKE_C_FLAGS "-g")
elseif(CMAKE_C_COMPILER_ID MATCHES Clang)
    append_if_absent(CMAKE_C_FLAGS "-Wall")
    append_if_absent(CMAKE_C_FLAGS "-g")
elseif(CMAKE_C_COMPILER_ID MATCHES Intel)
    append_if_absent(CMAKE_C_FLAGS "-Wall")
    append_if_absent(CMAKE_C_FLAGS "-no-ansi-alias")
elseif(CMAKE_C_COMPILER_ID MATCHES PGI)
    append_if_absent(CMAKE_C_FLAGS "-alias=traditional")
endif()

if(MSVC)
    append_if_absent(CMAKE_C_FLAGS "/Zm200")
    string(REPLACE "/Ob2" "/Ob1" CMAKE_C_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE}) # InlineFunctionExpansion=1
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING "Flags used by the compiler during release builds" FORCE)
endif()

# Useful additional variables that extensions can use.
if(CMAKE_SYSTEM MATCHES Linux)
    set(LINUX ON)
else()
    set(LINUX OFF)
endif()

# Clear PythonTargets.cmake
file(WRITE ${CONFIG_BUILD_DIR}/PythonTargets.cmake "")

# Define python executable wrapper command to ensure
# python executable resolves the expected python library.
set(PYTHON_WRAPPER_COMMAND )
if(BUILD_LIBPYTHON_SHARED AND UNIX)
    set(_envvar LD_LIBRARY_PATH)
    if(APPLE)
        set(_envvar DYLD_LIBRARY_PATH)
    endif()
    set(PYTHON_WRAPPER_COMMAND env ${_envvar}=${PROJECT_BINARY_DIR}/${LIBPYTHON_LIBDIR})
endif()

# Add extension modules
set(extensions_enabled "" CACHE INTERNAL "" FORCE)
set(extensions_disabled "" CACHE INTERNAL "" FORCE)
add_subdirectory(cmake/extensions CMakeBuild/extensions)

show_extension_summary()
