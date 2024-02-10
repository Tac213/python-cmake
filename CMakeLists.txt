cmake_minimum_required(VERSION 3.21)

set(PYTHON_VERSION "3.12.2" CACHE STRING "The version of Python to build.")

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

if(NOT(SRC_DIR AND EXISTS ${SRC_DIR}/${_landmark}))
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

set(_download_3.11.0_md5 "c5f77f1ea256dc5bdb0897eeb4d35bb0")
set(_download_3.11.1_md5 "5c986b2865979b393aa50a31c65b64e8")
set(_download_3.11.2_md5 "f6b5226ccba5ae1ca9376aaba0b0f673")
set(_download_3.11.3_md5 "016ba65bc80411f9ec20c614ab385e81")
set(_download_3.11.4_md5 "bf6ec50f2f3bfa6ffbdb385286f2c628")
set(_download_3.11.5_md5 "b628f21aae5e2c3006a12380905bb640")
set(_download_3.11.6_md5 "ed23dadb9f1b9fd2e4e7d78619685c79")
set(_download_3.11.7_md5 "ef61f81ec82c490484219c7f0ec96783")
set(_download_3.11.8_md5 "7fb0bfaa2f6aae4aadcdb51abe957825")
set(_download_3.12.0_md5 "d6eda3e1399cef5dfde7c4f319b0596c")
set(_download_3.12.1_md5 "51c5c22dcbc698483734dff5c8028606")
set(_download_3.12.2_md5 "4e64a004f8ad9af1a75607cfd0d5a8c8")

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

# Apply patches
option(PYTHON_APPLY_PATCHES "Apply patches" ON)

if(PYTHON_APPLY_PATCHES)
    include(cmake/PythonApplyPatches.cmake)
endif()

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

    if(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
        enable_language(ASM_MASM)
    endif()
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
set(BIN_INSTALL_DIR bin) # Contains the python executable
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

set(ARCHIVEDIR "libs") # Contains the static (*.a) and import libraries (*.lib)

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
    if((PY_VERSION VERSION_GREATER_EQUAL "3.6") AND(PY_VERSION VERSION_LESS "3.11"))
        append_if_absent(CMAKE_C_FLAGS "-std=c99")
    elseif(PY_VERSION VERSION_GREATER_EQUAL "3.11")
        append_if_absent(CMAKE_C_FLAGS "-std=c11")
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
set(PYTHON_WRAPPER_COMMAND)

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

# Add other subdirectories
add_subdirectory(cmake/libpython CMakeBuild/libpython)
add_subdirectory(cmake/python CMakeBuild/python)
add_subdirectory(cmake/include CMakeBuild/include)
add_subdirectory(cmake/lib CMakeBuild/lib)
add_subdirectory(cmake/tools CMakeBuild/tools)

# Add target to run "Argument Clinic" over all source files
add_custom_target(clinic
    COMMAND ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:python> ${SRC_DIR}/Tools/clinic/clinic.py --make
    DEPENDS python
    WORKING_DIRECTORY ${SRC_DIR}
    COMMENT "Running 'Argument Clinic' over all source files"
    VERBATIM
)

# Add target to generate 'Include/graminit.h' and 'Python/graminit.c'
if(PY_VERSION VERSION_GREATER_EQUAL "3.8")
    set(generate_graminit_command $<TARGET_FILE:python> -m Parser.pgen)
else()
    set(generate_graminit_command $<TARGET_FILE:pgen>)
endif()

add_custom_target(generate_graminit
    COMMAND ${CMAKE_CROSSCOMPILING_EMULATOR} ${generate_graminit_command}
    ${SRC_DIR}/Grammar/Grammar
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:${SRC_DIR}/Grammar/Tokens>
    ${PROJECT_BINARY_DIR}/CMakeFiles/graminit.h
    ${PROJECT_BINARY_DIR}/CMakeFiles/graminit.c
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${PROJECT_BINARY_DIR}/CMakeFiles/graminit.h
    ${SRC_DIR}/Include/graminit.h
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${PROJECT_BINARY_DIR}/CMakeFiles/graminit.c
    ${SRC_DIR}/Python/graminit.c
    DEPENDS $<IF:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>,python,pgen>
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating '${SRC_DIR}/Include/graminit.h' and '${SRC_DIR}/Python/graminit.c'."
    VERBATIM
)

if(PY_VERSION VERSION_GREATER_EQUAL "3.9")
    # Add target to generate `Tools/peg_generator/pegen/grammar_parser.py`
    add_custom_target(generate_pegen_metaparser
        COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${SRC_DIR}/Tools/peg_generator
        ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:python> -m pegen
        -q python
        ${SRC_DIR}/Tools/peg_generator/pegen/metagrammar.gram
        -o ${PROJECT_BINARY_DIR}/CMakeFiles/grammar_parser.py
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${PROJECT_BINARY_DIR}/CMakeFiles/grammar_parser.py
        ${SRC_DIR}/Tools/peg_generator/pegen/grammar_parser.py
        DEPENDS python
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        COMMENT "Generating '${SRC_DIR}/Tools/peg_generator/pegen/grammar_parser.py'"
        VERBATIM
    )

    # Add target to generate `Parser/pegen/parse.c`
    add_custom_target(generate_pegen_parse
        COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${SRC_DIR}/Tools/peg_generator
        ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:python> -m pegen
        -q c
        ${SRC_DIR}/Grammar/python.gram
        ${SRC_DIR}/Grammar/Tokens
        -o ${PROJECT_BINARY_DIR}/CMakeFiles/parse.c
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${PROJECT_BINARY_DIR}/CMakeFiles/parse.c
        ${SRC_DIR}/Parser/pegen/parse.c
        DEPENDS python
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        COMMENT "Generating '${SRC_DIR}/Parser/pegen/parse.c'"
        VERBATIM
    )
endif() # PY_VERSION >= 3.9

# Add target to generate 'opcode.h' header file
add_custom_target(generate_opcode_h
    COMMAND ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:python> ${SRC_DIR}/Tools/scripts/generate_opcode_h.py
    ${SRC_DIR}/Lib/opcode.py
    ${PROJECT_BINARY_DIR}/CMakeFiles/opcode.h
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${PROJECT_BINARY_DIR}/CMakeFiles/opcode.h
    ${SRC_DIR}/Include/opcode.h
    DEPENDS python
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating '${SRC_DIR}/Include/opcode.h'."
    VERBATIM
)

# Add target to generate 'Include/Python-ast.h' from 'Python.asdl'
add_custom_target(generate_python_ast_h
    COMMAND ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:python> ${SRC_DIR}/Parser/asdl_c.py
    -h ${SRC_DIR}/Include
    ${SRC_DIR}/Parser/Python.asdl
    DEPENDS python
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating '${SRC_DIR}/Include/Python-ast.h'"
    VERBATIM
)

# Add target to generate 'Python/Python-ast.c' from 'Python.asdl'
add_custom_target(generate_python_ast_c
    COMMAND ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:python> ${SRC_DIR}/Parser/asdl_c.py
    -c ${SRC_DIR}/Python
    ${SRC_DIR}/Parser/Python.asdl
    DEPENDS python
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating '${SRC_DIR}/Python/Python-ast.c'"
    VERBATIM
)

# If needed, copy 'asdl.py' and 'Python.asdl' into build directory so that 'test_asdl_parser' passes.
set(_asdl_subdir ${LIBDIR})

if(WIN32)
    set(_asdl_subdir)
endif()

file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/${LIBDIR}/Parser)
configure_file(
    ${SRC_DIR}/Parser/Python.asdl
    ${PROJECT_BINARY_DIR}/${_asdl_subdir}/Parser/Python.asdl
    COPYONLY
)
configure_file(
    ${SRC_DIR}/Parser/asdl.py
    ${PROJECT_BINARY_DIR}/${_asdl_subdir}/Parser/asdl.py
    COPYONLY
)

show_extension_summary()

if(UNIX)
    # python.pc
    configure_file(cmake/python.pc.in
        ${PROJECT_BINARY_DIR}/Misc/python-${LIBPYTHON_VERSION}.pc @ONLY)
    configure_file(cmake/python.pc.in
        ${PROJECT_BINARY_DIR}/Misc/python-${PY_VERSION_MAJOR}.pc @ONLY)
    configure_file(cmake/python.pc.in
        ${PROJECT_BINARY_DIR}/Misc/python.pc @ONLY)

    if(INSTALL_DEVELOPMENT)
        install(FILES
            ${PROJECT_BINARY_DIR}/Misc/python-${LIBPYTHON_VERSION}.pc
            ${PROJECT_BINARY_DIR}/Misc/python-${PY_VERSION_MAJOR}.pc
            ${PROJECT_BINARY_DIR}/Misc/python.pc
            DESTINATION lib/pkgconfig
            COMPONENT Development)
    endif()

    # Makefile
    set(MAKEFILE_LDSHARED_FLAGS "-shared")

    if(APPLE)
        set(MAKEFILE_LDSHARED_FLAGS "-dynamiclib -headerpad_max_install_names -undefined dynamic_lookup")
    endif()

    configure_file(cmake/makefile-variables.in
        ${BIN_BUILD_DIR}/Makefile @ONLY)

    if(INSTALL_DEVELOPMENT)
        install(FILES ${BIN_BUILD_DIR}/Makefile
            DESTINATION ${LIB_CONFIG_INSTALL_DIR}
            RENAME Makefile
            COMPONENT Development)
    endif()

    # Utility scripts
    if(INSTALL_DEVELOPMENT)
        install(FILES ${SRC_DIR}/install-sh ${SRC_DIR}/Modules/makesetup
            DESTINATION ${LIB_CONFIG_INSTALL_DIR}
            COMPONENT Development)
    endif()

    # Install manual
    if(INSTALL_MANUAL)
        set(_install_man FILES ${SRC_DIR}/Misc/python.man DESTINATION share/man/man1 COMPONENT Runtime)
        install(${_install_man} RENAME python${LIBPYTHON_VERSION}.1)
        install(${_install_man} RENAME python${PY_VERSION_MAJOR}.1)
    endif()
endif()

# Create an empty lib-dynload folder, even if we don't have any extensions
# to go in there.  bin/python uses this to auto-determine the exec_prefix
# and properly generate the _sysconfigdata.py
file(MAKE_DIRECTORY "${EXTENSION_BUILD_DIR}")
install(DIRECTORY DESTINATION ${EXTENSION_INSTALL_DIR})

include(CMakePackageConfigHelpers)

# Configure 'PythonConfig.cmake' for a build tree
set(CONFIG_DIR_CONFIG ${CONFIG_BUILD_DIR})
set(INCLUDE_DIR_CONFIG ${INCLUDE_BUILD_DIR})
set(PYTHON_CONFIG_CODE "####### Expanded from \@PYTHON_CONFIG_CODE\@ #######\n")
set(PYTHON_CONFIG_CODE "${PYTHON_CONFIG_CODE}list(APPEND PYTHON_INCLUDE_DIR \"${PYCONFIG_BUILD_DIR}\")\n")
set(PYTHON_CONFIG_CODE "${PYTHON_CONFIG_CODE}##################################################")
set(python_config ${CONFIG_BUILD_DIR}/PythonConfig.cmake)
configure_package_config_file(
    cmake/PythonConfig.cmake.in
    ${python_config}
    INSTALL_DESTINATION ${PROJECT_BINARY_DIR}
    PATH_VARS CONFIG_DIR_CONFIG INCLUDE_DIR_CONFIG
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

# Configure 'PythonConfig.cmake' for an install tree
set(CONFIG_DIR_CONFIG ${CONFIG_INSTALL_DIR})
set(INCLUDE_DIR_CONFIG ${INCLUDE_INSTALL_DIR})
set(PYTHON_CONFIG_CODE "")
set(python_install_config ${PROJECT_BINARY_DIR}/CMakeFiles/PythonConfig.cmake)
configure_package_config_file(
    cmake/PythonConfig.cmake.in
    ${python_install_config}
    INSTALL_DESTINATION ${CMAKE_INSTALL_PREFIX}/${CONFIG_INSTALL_DIR}
    PATH_VARS CONFIG_DIR_CONFIG INCLUDE_DIR_CONFIG
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

# Configure 'PythonTargets.cmake' and 'PythonConfigVersion.cmake
get_property(PYTHON_TARGETS GLOBAL PROPERTY PYTHON_TARGETS)
export(TARGETS ${PYTHON_TARGETS} APPEND FILE ${CONFIG_BUILD_DIR}/PythonTargets.cmake)

set(python_config_version ${CONFIG_BUILD_DIR}/PythonConfigVersion.cmake)
write_basic_package_version_file(
    ${python_config_version}
    VERSION ${PY_VERSION}
    COMPATIBILITY SameMajorVersion
)

if(INSTALL_DEVELOPMENT)
    # Install 'PythonTargets.cmake', 'PythonConfig.cmake' and 'PythonConfigVersion.cmake
    # install(EXPORT PythonTargets
    # FILE PythonTargets.cmake
    # DESTINATION ${CONFIG_INSTALL_DIR} COMPONENT Development)
    install(
        FILES ${python_install_config} ${python_config_version}
        DESTINATION ${CONFIG_INSTALL_DIR} COMPONENT Development)
endif()

# Install License
set(license_destination ${PYTHONHOME})
install(FILES ${SRC_DIR}/LICENSE DESTINATION ${license_destination} COMPONENT Runtime RENAME LICENSE.txt)
