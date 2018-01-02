#define QDEL_IN(item, time) addtimer(GLOBAL_PROC, "qdel", time, FALSE, item)
#define QDEL_NULL(item) if(item) { qdel(item); item = null }
#define QDEL_LIST(L) if(L) { for(var/I in L) qdel(I); L.Cut(); }
#define QDEL_LIST_ASSOC(L) if(L) { for(var/I in L) { qdel(L[I]); qdel(I); } L.Cut(); }
#define QDEL_LIST_ASSOC_VAL(L) if(L) { for(var/I in L) qdel(L[I]); L.Cut(); }
