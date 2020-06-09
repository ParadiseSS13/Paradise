# Renderer Executables For NanoMaps

This directory contains executables that the server uses for rendering the games NanoMaps at runtime.

Thankfully due to some magic (And rust), these dont have to be compiled as 32-bit applications because they are spawned processes, not extensions of BYOND.

If you ever update or edit them, **MAKE SURE YOU KEEP THE SAME FILE NAMES**, as the DLL requires these exact names for the platforms. Renaming these will break stuff hard, so be careful.

- `renderer-windows.exe` for the Windows Executable
- `renderer-linux` for the Linux Executable
