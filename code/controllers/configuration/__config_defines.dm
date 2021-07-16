// Config protection states
#define PROTECTION_PRIVATE "PRIVATE"
#define PROTECTION_READONLY "READONLY"
#define PROTECTION_NONE "NONE"
/// Wrapper to not overwrite a variable if a list key doesnt exist. Auto casts to bools.
#define CONFIG_LOAD_BOOL(target, input) \
	if(!isnull(input)) {\
		target = ((input == 1) ? TRUE : FALSE)\
	}

/// Wrapper to not overwrite a variable if a list key doesnt exist. Auto casts to number.
#define CONFIG_LOAD_NUM(target, input) \
	if(!isnull(input)) {\
		target = text2num(input)\
	}

/// Wrapper to not overwrite a variable if a list key doesnt exist. Auto casts to number, and accepts a macro argument for number maths (ds to min for example)
#define CONFIG_LOAD_NUM_MULT(target, input, multiplier) \
	if(!isnull(input)) {\
		target = text2num(input) multiplier\
	}

/// Wrapper to not overwrite a variable if a list key doesnt exist. Auto casts to string.
#define CONFIG_LOAD_STR(target, input) \
	if(!isnull(input)) {\
		target = "[input]"\
	}

/// Wrapper to not overwrite a variable if a list key doesnt exist. No casting done.
#define CONFIG_LOAD_RAW(target, input) \
	if(!isnull(input)) {\
		target = input\
	}

/// Wrapper to not overwrite a variable if a list key doesnt exist. Ensures target is a list.
#define CONFIG_LOAD_LIST(target, input) \
	if(islist(input)) {\
		target = input\
	}

