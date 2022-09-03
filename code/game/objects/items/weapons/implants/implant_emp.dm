/obj/item/implant/emp
	name = "emp implant"
	desc = "Triggers an EMP."
	icon_state = "emp"
	origin_tech = "biotech=3;magnets=4;syndicate=1"
	uses = 2
	implant_data = /datum/implant_fluff/emp
	implant_state = "implant-syndicate"

/obj/item/implant/emp/activate()
	uses--
	INVOKE_ASYNC(GLOBAL_PROC, .proc/empulse, get_turf(imp_in), 3, 5, 1)
	if(!uses)
		qdel(src)

/obj/item/implanter/emp
	name = "implanter (EMP)"

/obj/item/implanter/emp/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/emp(src)

/obj/item/implantcase/emp
	name = "implant case - 'EMP'"
	desc = "A glass case containing an EMP implant."

/obj/item/implantcase/emp/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/emp(src)
