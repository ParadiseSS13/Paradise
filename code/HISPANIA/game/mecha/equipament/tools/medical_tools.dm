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
	// var/health_boost = 1 // va con el agregado 2. evan agrego esto esperando que se consuma la energia periodicamente
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


	//agregado 2. agragado por evan esperando que funcione el consumo de nergia
//	if(!chassis)
//		STOP_PROCESSING(SSobj, src)
//		set_ready_state(1)
//		medigun.LoseTarget()
//		return
//	var/h_boost = health_boost
//	var/repaired = 0
//	if(medigun.active == TRUE)
//		h_boost *= -2
//		set_ready_state(0)
//	else
//		set_ready_state(1)
//	if(health_boost<0)
//		repaired = 1
//	return
//	if(repaired)
//		if(!chassis.use_power(energy_drain))
//			STOP_PROCESSING(SSobj, src)
//			set_ready_state(1)
	// fin agregado 2

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	medigun.LoseTarget()
	return ..()
