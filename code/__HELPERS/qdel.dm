#define QDEL_IN(item, time) addtimer(GLOBAL_PROC, "qdel", time, FALSE, item)
#define QDEL_NULL(item) if(item) { qdel(item); item = null }