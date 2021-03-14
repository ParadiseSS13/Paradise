/obj/item/gun/medbeam/equipped(mob/user)
	..()
	LoseTarget()

/obj/item/gun/medbeam/mech
	mounted = TRUE

/obj/item/gun/medbeam/mech/Initialize()
	. = ..()
	STOP_PROCESSING(SSobj, src) //Mech mediguns do not process until installed, and are controlled by the holder obj
