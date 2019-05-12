//////////////////////////////Mech Version///////////////////////////////
/obj/item/gun/medbeam/mech

/obj/item/gun/medbeam/mech/Initialize()
	. = ..()
	STOP_PROCESSING(SSobj, src) //Mech mediguns do not process until installed, and are controlled by the holder obj