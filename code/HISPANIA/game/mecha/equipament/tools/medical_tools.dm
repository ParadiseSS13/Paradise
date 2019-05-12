/obj/item/mecha_parts/mecha_equipment/medical/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam
	name = "exosuit medical beamgun"
	desc = "Equipment for medical exosuits. Generates a focused beam of medical nanites."
	icon = 'icons/hispania/mecha/mecha_equipment.dmi'
	icon_state = "mecha_medigun"
	energy_drain = 200
	range = MELEE|RANGED
	equip_cooldown = 20
	origin_tech = "materials=3;biotech=6;magnets=4"
	var/obj/item/gun/medbeamtg/mech/medigun


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Initialize()
	. = ..()
	medigun = new(src)


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Destroy()
	qdel(medigun)
	return ..()


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/process()
	if(..())
		return
	medigun.process()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/action(atom/target)
	medigun.process_fire(target, loc)
	//modifiacion de evan, agregado 1. esto hace que consuma energia al seleccionar a alguien. esto funciona bien.
	if(medigun.active == TRUE)
		chassis.use_power(energy_drain)
		set_ready_state(0)
	else
		set_ready_state(1)
	// fin 1

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	medigun.LoseTarget()
	return ..()
