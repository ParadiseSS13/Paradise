/obj/item/mecha_parts/mecha_equipment/medical/protomechmedbeam
	name = "exosuit prototype beamgun"
	desc = "Equipment for medical exosuits. Generates a focused beam of medical nanites. This prototype consumes excessive energy."
	icon = 'icons/hispania/mecha/mecha_equipment.dmi'
	icon_state = "mecha_medigun"
	energy_drain = 800
	range = MELEE|RANGED
	equip_cooldown = 10
	var/last_check = 0
	origin_tech = "materials=6;biotech=6;magnets=5;engineering=6"
	var/obj/item/gun/medbeamtg/mech/protomedbeamtg/medigun

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

	if(!chassis.occupant)
		medigun.LoseTarget()
		set_ready_state(1)

	if(!chassis.has_charge(energy_drain))
		medigun.LoseTarget()
		set_ready_state(1)

	if(medigun.active)
		if(world.time <= last_check+equip_cooldown)
			return
		last_check = world.time
		chassis.use_power(energy_drain)
	else
		set_ready_state(1)

/obj/item/mecha_parts/mecha_equipment/medical/protomechmedbeam/action(atom/target)
	if(chassis.has_charge(energy_drain))
		medigun.process_fire(target, loc)
		if(medigun.active)
			set_ready_state(0)

/obj/item/mecha_parts/mecha_equipment/medical/protomechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	medigun.LoseTarget()
	return ..()
