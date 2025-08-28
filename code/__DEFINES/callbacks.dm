#define GLOBAL_PROC	"some_magic_bullshit"

#define CALLBACK new /datum/callback
#define INVOKE_ASYNC ImmediateInvokeAsync

/// like CALLBACK but specifically for verb callbacks
#define VERB_CALLBACK new /datum/callback/verb_callback

// Wait of 0, but this wont actually do anything until the MC is firing
#define END_OF_TICK(callback) addtimer(callback, 0)
