#define GLOBAL_PROC	"some_magic_bullshit"

#define CALLBACK new /datum/callback
#define INVOKE_ASYNC ImmediateInvokeAsync

/// like CALLBACK but specifically for verb callbacks
#define VERB_CALLBACK new /datum/callback/verb_callback

// This is used to delay a callback until the end of the tick or later, to ensure that some arbitrary specification is met first. (i.e. spawners spawning stuff)
#define END_OF_TICK(callback) addtimer(callback, 0)
