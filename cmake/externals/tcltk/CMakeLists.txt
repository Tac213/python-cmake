# Add imported libraries of tcl/tk on Win32

set(tcltk_include ${_win32_tcltk_folder}/${_win32_arch_name}/include)
set(tcl_dll ${_win32_tcltk_folder}/${_win32_arch_name}/bin/tcl${_win32_tcltk_major_version}${_win32_tcltk_minor_version}t.dll)
set(tcl_lib ${_win32_tcltk_folder}/${_win32_arch_name}/lib/tcl${_win32_tcltk_major_version}${_win32_tcltk_minor_version}t.lib)
set(tk_dll ${_win32_tcltk_folder}/${_win32_arch_name}/bin/tk${_win32_tcltk_major_version}${_win32_tcltk_minor_version}t.dll)
set(tk_lib ${_win32_tcltk_folder}/${_win32_arch_name}/lib/tk${_win32_tcltk_major_version}${_win32_tcltk_minor_version}t.lib)
set(tcltk_zlib_dll ${_win32_tcltk_folder}/${_win32_arch_name}/bin/zlib1.dll)

add_library(TclTk::Zlib INTERFACE IMPORTED
    ${tcltk_zlib_dll}
)
# set_target_properties( TclTk::Zlib PROPERTIES
#     IMPORTED_LOCATION ${tcltk_zlib_dll}
# )

add_library( TclTk::Tcl SHARED IMPORTED GLOBAL)
set_target_properties( TclTk::Tcl PROPERTIES
    IMPORTED_LOCATION ${tcl_dll} 
    IMPORTED_IMPLIB ${tcl_lib}
    # IMPORTED_LINK_INTERFACE_LIBRARIES TclTk::Zlib
)

add_library( TclTk::Tk SHARED IMPORTED GLOBAL)
set_target_properties( TclTk::Tk PROPERTIES
    IMPORTED_LOCATION ${tk_dll} 
    IMPORTED_IMPLIB ${tk_lib}
    # IMPORTED_LINK_INTERFACE_LIBRARIES TclTk::Zlib
    # IMPORTED_LINK_INTERFACE_LIBRARIES ${tcltk_zlib_dll}
)

target_include_directories(TclTk::Tcl
    INTERFACE
        ${tcltk_include}
)

target_include_directories(TclTk::Tk
    INTERFACE
        ${tcltk_include}
)

target_link_libraries(TclTk::Tcl
    INTERFACE
        TclTk::Zlib
)

target_link_libraries(TclTk::Tk
    INTERFACE
        TclTk::Zlib
)
