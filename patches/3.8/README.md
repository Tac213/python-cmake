## `0001-Prevent-incorrect-include-of-io.h-found-in-libmpdec.patch`

Rename header files found in `Modules/_decimal/libmpdec` directory to avoid conflicts with system headers of the same name.

Conflict header: io.h

If this patch is not applied, when the module `_decimal` is compiled as a builtin module on Windows, the following error occurs:

```
Modules\posixmodule.c(3649): error C2065: '_commit': undeclared identifier
```

## `0002-Undefine-_DEBUG-to-enable-extension-site-packages-loading-in-debug-build[LOAD_NORMAL_EXTENSIONS_IN_DEBUG].patch`

Undefine _DEBUG to enable to load extensions (pyd) installed by pip. Otherwise libpython will try to find extensions with `_d.pyd` suffix.

`LOAD_NORMAL_EXTENSIONS_IN_DEBUG` is needed to apply this patch.

## `0003-Prevent-duplicated-OverlappedType-symbols[BUILD_EXTENSIONS_AS_BUILTIN].patch`

Rename `OverlappedType` in `Modules/_winapi.c` to avoid multiply defined symbols.

If this patch is not applied, when the module `_overlapped` and `_winapi` are both built as builtin modules on Windows, the following error occurs:

```
_winapi.c.obj : error LNK2005: OverlappedType already defined in overlapped.c.obj
```
