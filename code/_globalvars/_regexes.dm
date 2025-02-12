GLOBAL_DATUM_INIT(filename_forbidden_chars, /regex, regex(@{""|[\\\n\t/?%*:|<>]|\.\."}, "g"))
GLOBAL_DATUM_INIT(is_color, /regex, regex("^#\[0-9a-fA-F]{6}$"))
GLOBAL_DATUM_INIT(regex_rgb_text, /regex, regex(@"^#?(([0-9a-fA-F]{8})|([0-9a-fA-F]{6})|([0-9a-fA-F]{3}))$"))
GLOBAL_PROTECT(filename_forbidden_chars)
