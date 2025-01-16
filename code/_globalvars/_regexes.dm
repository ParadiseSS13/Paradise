GLOBAL_DATUM_INIT(filename_forbidden_chars, /regex, regex(@{""|[\\\n\t/?%*:|<>]|\.\."}, "g"))
GLOBAL_DATUM_INIT(is_color, /regex, regex("^#\[0-9a-fA-F]{6}$"))
GLOBAL_PROTECT(filename_forbidden_chars)
