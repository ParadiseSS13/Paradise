/obj/item/mecha_parts/mecha_equipment/medical/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/protomechmedbeam
	name = "exosuit prototype beamgun"
	desc = "Equipment for medical exosuits. Generates a focused beam of medical nanites. This prototype consumes excessive energy."
	icon = 'icons/hispania/mecha/mecha_equipment.dmi'
	icon_state = "mecha_medigun"
	energy_drain = 8000
	range = MELEE|RANGED
	equip_cooldown = 1
	origin_tech = "materials=6;biotech=6;magnets=5;engineering=6"
	var/obj/item/gun/medbeamtg/mech/medigun

/obj/item/mecha_parts/mecha_equipment/medical/protomechmedbeam/Initialize()
	. = ..()
	medigun = new(src)


/obj/item/mecha_parts/mecha_equipment/medical/protomechmedbeam/Destroy()
	qdel(medigun)
	return ..()


/obj/item/mecha_parts/mecha_equipment/medical/protomechmedbeam/process()
	if(..())
		return
	medigun.process()


/obj/item/mecha_parts/mecha_equipment/medical/protomechmedbeam/action(atom/target)
	if(chassis.has_charge(energy_drain))
		medigun.process_fire(target, loc)
	//modifiacion de evan. esto hace que consuma energia al seleccionar a alguien.
	if(medigun.active == TRUE)
		chassis.use_power(energy_drain)
		set_ready_state(0)
	else
		set_ready_state(1)
	// fin

/obj/item/mecha_parts/mecha_equipment/medical/protomechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	medigun.LoseTarget()
	return ..()
