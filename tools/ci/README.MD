# Info

All scripts utilised by CI should be placed into this folder for the sake of maintainability, and knowing where stuff is

# NOTE
Do not move the `dm.sh` script without **VERY** good reason, as the server backend relies on it for updating, and moving this file **WILL** break server updating, but make the server appear to still be updated. TLDR: Dont move it or break its existing functionality, without advancing changes to the server host.
