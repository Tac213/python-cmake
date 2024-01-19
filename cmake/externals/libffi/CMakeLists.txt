# Add an imported library of libffi on Win32

set(libffi_include ${_win32_libffi_folder}/${_win32_arch_name}/include)
set(libffi_dll ${_win32_libffi_folder}/${_win32_arch_name}/libffi-8.dll)
set(libffi_lib ${_win32_libffi_folder}/${_win32_arch_name}/libffi-8.lib)

add_library( libffi SHARED IMPORTED GLOBAL )
set_target_properties( libffi PROPERTIES 
    IMPORTED_LOCATION ${libffi_dll}
    IMPORTED_IMPLIB ${libffi_lib}
)
target_include_directories(libffi
    INTERFACE
        ${libffi_include}
)

