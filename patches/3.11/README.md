## `0001-Prevent-incorrect-include-of-io.h-found-in-libmpdec.patch`

Rename header files found in `Modules/_decimal/libmpdec` directory to avoid conflicts with system headers of the same name.

Conflict header: io.h

If this patch is not apply, when the module `_decimal` is compiled as a builtin module on Windows, the follow error occurs:

```
Modules\posixmodule.c(3649): error C2065: '_commit': undeclared identifier
```
