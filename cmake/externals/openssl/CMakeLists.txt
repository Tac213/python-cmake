# Add imported libraries of openssl on Win32

set(openssl_include ${_win32_openssl_folder}/${_win32_arch_name}/include)
set(libcrypto_dll ${_win32_openssl_folder}/${_win32_arch_name}/libcrypto-3.dll)
set(libcrypto_lib ${_win32_openssl_folder}/${_win32_arch_name}/libcrypto.lib)
set(libssl_dll ${_win32_openssl_folder}/${_win32_arch_name}/libssl-3.dll)
set(libssl_lib ${_win32_openssl_folder}/${_win32_arch_name}/libssl.lib)

add_library( OpenSSL::Crypto SHARED IMPORTED GLOBAL)
set_target_properties( OpenSSL::Crypto PROPERTIES
    IMPORTED_LOCATION ${libcrypto_dll} 
    IMPORTED_IMPLIB ${libcrypto_lib}
)

add_library( OpenSSL::SSL SHARED IMPORTED GLOBAL )
set_target_properties( OpenSSL::SSL PROPERTIES 
    IMPORTED_LOCATION ${libssl_dll}
    IMPORTED_IMPLIB ${libssl_lib}
)
target_include_directories(OpenSSL::SSL
    INTERFACE
        ${openssl_include}
)

target_include_directories(OpenSSL::Crypto
    INTERFACE
        ${openssl_include}
)
