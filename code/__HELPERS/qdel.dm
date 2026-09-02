#define QDEL_IN(item, time) addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), item), time, TIMER_STOPPABLE)
#define QDEL_IN_CLIENT_TIME(item, time) addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), item), time, TIMER_STOPPABLE | TIMER_CLIENT_TIME)
#define QDEL_NULL(item) if(item) { qdel(item); item = null }
#define QDEL_LIST_CONTENTS(L) do { \
	if(L) { \
		for(var/I in L) \
			qdel(I); \
		if(L) \
			L.Cut(); \
	} \
} while(FALSE)
#define QDEL_LIST_CONTENTS_IN(L, time) addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(______qdel_list_wrapper), L), time, TIMER_STOPPABLE)
#define QDEL_LIST_ASSOC(L) if(L) { for(var/I in L) { qdel(L[I]); qdel(I); } L.Cut(); }
#define QDEL_LIST_ASSOC_VAL(L) if(L) { for(var/I in L) qdel(L[I]); L.Cut(); }

/proc/______qdel_list_wrapper(list/L) //the underscores are to encourage people not to use this directly.
	QDEL_LIST_CONTENTS(L)

/**
 * # Signal qdel
 *
 * Proc intended to be used when someone wants the src datum to be qdeled when a certain signal is sent to them.
 *
 * Example usage:
 * RegisterSignal(item, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum, signal_qdel))
 */
/datum/proc/signal_qdel()
	SIGNAL_HANDLER
	qdel(src)
