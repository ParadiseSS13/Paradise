/obj/item/mecha_parts/mecha_equipment/drill/makeshift
	name = "Makeshift exosuit drill"
	desc = "Cobbled together from likely stolen parts, this drill is nowhere near as effective as the real deal."
	equip_cooldown = 60
	force = 5
	energy_drain = 30 //three times as much as regular drill energy consumption

/obj/item/mecha_parts/mecha_equipment/drill/makeshift/can_attach(obj/mecha/M as obj)
	if(istype(M, /obj/mecha/working/ripley/makeshift))
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift
	name = "makeshift clamp"
	desc = "Loose arrangement of cobbled together bits ressembling a clamp."
	equip_cooldown = 25
	dam_force = 10

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift/can_attach(obj/mecha/M as obj)
	if(istype(M, /obj/mecha/working/ripley/makeshift))
		return TRUE
	return FALSE