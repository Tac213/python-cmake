cmake_minimum_required(VERSION 3.21)

set(PYTHON_VERSION "3.12.7" CACHE STRING "The version of Python to build.")

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

set(_download_3.8.0_md5 "e18a9d1a0a6d858b9787e03fc6fdaa20")
set(_download_3.8.1_md5 "f215fa2f55a78de739c1787ec56b2bcd")
set(_download_3.8.2_md5 "f9f3768f757e34b342dbc06b41cbc844")
set(_download_3.8.3_md5 "a7c10a2ac9d62de75a0ca5204e2e7d07")
set(_download_3.8.4_md5 "387e63fe42c40a29e3408ce231315516")
set(_download_3.8.5_md5 "e2f52bcf531c8cc94732c0b6ff933ff0")
set(_download_3.8.6_md5 "ea132d6f449766623eee886966c7d41f")
set(_download_3.8.7_md5 "e1f40f4fc9ccc781fcbf8d4e86c46660")
set(_download_3.8.8_md5 "d3af3b87e134c01c7f054205703adda2")
set(_download_3.8.9_md5 "41a5eaa15818cee7ea59e578564a2629")
set(_download_3.8.10_md5 "83d71c304acab6c678e86e239b42fa7e")
set(_download_3.8.11_md5 "f22ef46ebf8d15d8e495a237277bf2fa")
set(_download_3.8.12_md5 "f7890dd43302daa5fcb7b0254b4d0f33")
set(_download_3.8.13_md5 "3c49180c6b43df3519849b7e390af0b9")
set(_download_3.8.14_md5 "a82168eb586e19122b747b84038825f2")
set(_download_3.8.15_md5 "28b111e1e97a9e5acb62e1d153f188d9")
set(_download_3.8.16_md5 "060040f864f1003b849b33393c9605df")
set(_download_3.8.17_md5 "d3e789ab828016927a122a0ae9b0e6b0")
set(_download_3.8.18_md5 "1c611d70ba4d0ec32da3a364490fc6f4")
set(_download_3.8.19_md5 "5e3188ce73865fa4545d9e3e89bcd26c")
set(_download_3.8.20_md5 "7e0ff9088be5a3c2fd9b7d8b4b632b5e")
set(_download_3.9.0_md5 "e19e75ec81dd04de27797bf3f9d918fd")
set(_download_3.9.1_md5 "429ae95d24227f8fa1560684fad6fca7")
set(_download_3.9.2_md5 "8cf053206beeca72c7ee531817dc24c7")
set(_download_3.9.3_md5 "d9886aeb5d15e33f63f75cb10c8b9bb3") # Python-3.9.3 has been recalled officially. See: https://www.python.org/downloads/release/python-393/
set(_download_3.9.4_md5 "cc8507b3799ed4d8baa7534cd8d5b35f")
set(_download_3.9.5_md5 "364158b3113cf8ac8db7868ce40ebc7b")
set(_download_3.9.6_md5 "798b9d3e866e1906f6e32203c4c560fa")
set(_download_3.9.7_md5 "5f463f30b1fdcb545f156583630318b3")
set(_download_3.9.8_md5 "83419bd73655813223c2cf2afb11f83c")
set(_download_3.9.9_md5 "a2da2a456c078db131734ff62de10ed5")
set(_download_3.9.10_md5 "1440acb71471e2394befdb30b1a958d1")
set(_download_3.9.11_md5 "daca49063ced330eb933a0fb437dee50")
set(_download_3.9.12_md5 "abc7f7f83ea8614800b73c45cf3262d3")
set(_download_3.9.13_md5 "eafda83543bad127cadef4d288fdab87")
set(_download_3.9.14_md5 "324a9dcaaa11b2b0dafe5614e8f01145")
set(_download_3.9.15_md5 "3e13283a5f4e089db508bf81b60a5cca")
set(_download_3.9.16_md5 "38c99c7313f416dcf3238f5cf444c6c2")
set(_download_3.9.17_md5 "ded6379983f364cf790793ca24dcfe3e")
set(_download_3.9.18_md5 "c3a3e67e35838cadca247237a5a279a7")
set(_download_3.9.19_md5 "b4d723903d0a8266b110c3da2f992416")
set(_download_3.9.20_md5 "896c19e5815ba990a3d1261502ea9f83")
set(_download_3.10.0_md5 "729e36388ae9a832b01cf9138921b383")
set(_download_3.10.1_md5 "91822157a97da16203877400c810d93e")
set(_download_3.10.2_md5 "67c92270be6701f4a6fed57c4530139b")
set(_download_3.10.3_md5 "f276ffcd05bccafe46da023d0a5bb04a")
set(_download_3.10.4_md5 "7011fa5e61dc467ac9a98c3d62cfe2be")
set(_download_3.10.5_md5 "d87193c077541e22f892ff1353fac76c")
set(_download_3.10.6_md5 "d76638ca8bf57e44ef0841d2cde557a0")
set(_download_3.10.7_md5 "1aea68575c0e97bc83ff8225977b0d46")
set(_download_3.10.8_md5 "fbe3fff11893916ad1756b15c8a48834")
set(_download_3.10.9_md5 "25eb3686327c157dcb8ac9f01105c306")
set(_download_3.10.10_md5 "6dbe644dd1a520d9853cf6648084c346")
set(_download_3.10.11_md5 "7e25e2f158b1259e271a45a249cb24bb")
set(_download_3.10.12_md5 "1d64320e0b0df6e9ab7e611bacb2178d")
set(_download_3.10.13_md5 "cbcad7f5e759176bf8ce8a5f9d487087")
set(_download_3.10.14_md5 "f67d78c8323a18fe6b945914c51a7aa6")
set(_download_3.10.15_md5 "b6a2b570ea75ef55f50bfe79d778eb01")
set(_download_3.11.0_md5 "c5f77f1ea256dc5bdb0897eeb4d35bb0")
set(_download_3.11.1_md5 "5c986b2865979b393aa50a31c65b64e8")
set(_download_3.11.2_md5 "f6b5226ccba5ae1ca9376aaba0b0f673")
set(_download_3.11.3_md5 "016ba65bc80411f9ec20c614ab385e81")
set(_download_3.11.4_md5 "bf6ec50f2f3bfa6ffbdb385286f2c628")
set(_download_3.11.5_md5 "b628f21aae5e2c3006a12380905bb640")
set(_download_3.11.6_md5 "ed23dadb9f1b9fd2e4e7d78619685c79")
set(_download_3.11.7_md5 "ef61f81ec82c490484219c7f0ec96783")
set(_download_3.11.8_md5 "7fb0bfaa2f6aae4aadcdb51abe957825")
set(_download_3.11.9_md5 "bfd4d3bfeac4216ce35d7a503bf02d5c")
set(_download_3.11.10_md5 "35c36069a43dd57a7e9915deba0f864e")
set(_download_3.12.0_md5 "d6eda3e1399cef5dfde7c4f319b0596c")
set(_download_3.12.1_md5 "51c5c22dcbc698483734dff5c8028606")
set(_download_3.12.2_md5 "4e64a004f8ad9af1a75607cfd0d5a8c8")
set(_download_3.12.3_md5 "3c5498a34d5226c9b746b1199f0bf2d9")
set(_download_3.12.4_md5 "ead819dab6d165937138daa9e51ccb54")
set(_download_3.12.5_md5 "d23d56b51d36a9d51b2b13d30c849d00")
set(_download_3.12.6_md5 "c2f1dd5c8807ee50b778684b7958ee28")
set(_download_3.12.7_md5 "5d0c0e4c6a022a87165a9addcd869109")

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

    if(PY_VERSION VERSION_GREATER_EQUAL "3.12")
        set(CMAKE_CXX_STANDARD 20) # required by _wmimodule.cpp
    endif()

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

    if(PY_VERSION VERSION_GREATER_EQUAL "3.7")
        append_if_absent(CMAKE_C_FLAGS "-Werror=implicit-function-declaration")
    endif()
elseif(CMAKE_C_COMPILER_ID MATCHES Clang)
    append_if_absent(CMAKE_C_FLAGS "-Wall")
    append_if_absent(CMAKE_C_FLAGS "-g")

    if(PY_VERSION VERSION_GREATER_EQUAL "3.7")
        append_if_absent(CMAKE_C_FLAGS "-Werror=implicit-function-declaration")
    endif()

    if(PY_VERSION VERSION_LESS "3.11")
        append_if_absent(CMAKE_C_FLAGS "-Wno-unused-but-set-variable")
    endif()

    if(PY_VERSION VERSION_GREATER_EQUAL "3.11")
        append_if_absent(CMAKE_C_FLAGS "-std=c11")
    endif()

    if(${BUILD_EXTENSIONS_AS_BUILTIN})
        append_if_absent(CMAKE_C_FLAGS "-Wno-macro-redefined")
    endif()
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
