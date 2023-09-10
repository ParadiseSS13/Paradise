// Defines below to be used with the `power_type` var.
/// Denotes that this power is free and should be given to all changelings by default.
#define FLAYER_INNATE_POWER			1
/// Denotes that this power can only be obtained by purchasing it.
#define FLAYER_PURCHASABLE_POWER	2
/// Denotes that this power can not be obtained normally. Primarily used for base types such as [/obj/effect/proc_holder/spell/flayer/weapon].
#define FLAYER_UNOBTAINABLE_POWER	3

#define BRAIN_DRAIN_LIMIT 120
#define DRAIN_TIME 1/4 SECONDS

#define isspell(A)			(istype(A, /obj/effect/proc_holder/spell))
#define ispassive(A)		(istype(A, /datum/mindflayer_passive))
