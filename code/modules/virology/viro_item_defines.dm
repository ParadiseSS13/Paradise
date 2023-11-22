/obj/item/healthanalyzer/virus_analyzer
	name = "virus analyzer"
	desc = "A scanner used to evaluate a virus's various properties and basic vitals of patients."
	icon = 'icons/obj/device.dmi'
	icon_state = "viro"
	item_state = "analyzer"
	origin_tech = "magnets=1;biotech=2"
	materials = list(MAT_METAL = 210, MAT_GLASS = 40)
	mode = 0

/obj/item/healthanalyzer/virus_analyzer/attack_self(mob/user)
	return

/obj/item/healthanalyzer/virus_analyzer/attacked_by(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/healthupgrade))
		return
	return ..()