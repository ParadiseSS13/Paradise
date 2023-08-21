// Settings for the error handler and error viewer

#define ERROR_COOLDOWN 600 // The "cooldown" time for each occurrence of a unique error
#define ERROR_LIMIT 9 // How many occurrences before the next will silence them
#define ERROR_MAX_COOLDOWN (ERROR_COOLDOWN * ERROR_LIMIT)
#define ERROR_SILENCE_TIME 6000 // How long a unique error will be silenced for

// How long to wait between messaging admins about occurrences of a unique error
#define ERROR_MSG_DELAY 50
