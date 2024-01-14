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

set(Py_DEBUG OFF)

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
