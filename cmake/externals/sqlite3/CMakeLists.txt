# Translation of PCbuild/sqlite3.vcxproj

set(sqlite3_source_dir ${_win32_sqlite_folder})
get_filename_component(sqlite3_folder_name ${sqlite3_source_dir} NAME)
string(REGEX MATCHALL "[0-9]+" sqlite3_version_list ${sqlite3_folder_name})
list(JOIN sqlite3_version_list . sqlite3_version)
list(GET sqlite3_version_list 0 sqlite3_version_major)
list(GET sqlite3_version_list 1 sqlite3_version_minor)
list(GET sqlite3_version_list 2 sqlite3_version_micro)
list(GET sqlite3_version_list 3 sqlite3_version_patch)

set(sqlite3_sources
    ${sqlite3_source_dir}/sqlite3.c
)

set(sqlite3_headers
    ${sqlite3_source_dir}/sqlite3.h
    ${sqlite3_source_dir}/sqlite3ext.h
)

set(sqlite3_resources
    ${SRC_DIR}/PC/sqlite3.rc
)

add_library(sqlite3 SHARED
    ${sqlite3_sources}
    ${sqlite3_headers}
    # ${sqlite3_resources}
)
add_library(sqlite3::sqlite3 ALIAS sqlite3)

target_include_directories(sqlite3
PUBLIC
    ${sqlite3_source_dir}
)

target_compile_definitions(sqlite3
PUBLIC
    SQLITE_ENABLE_MATH_FUNCTIONS
    SQLITE_ENABLE_FTS4
    SQLITE_ENABLE_FTS5
    SQLITE_ENABLE_RTREE
    SQLITE_OMIT_AUTOINIT
    "SQLITE_API=__declspec(dllexport)"
PRIVATE
    SQLITE_VERSION=${sqlite3_version}
    SQLITE_MAJOR_VERSION=${sqlite3_version_major}
    SQLITE_MINOR_VERSION=${sqlite3_version_minor}
    SQLITE_MICRO_VERSION=${sqlite3_version_micro}
    SQLITE_PATCH_VERSION=${sqlite3_version_patch}
)
