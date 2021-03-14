/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam
	name = "exosuit beamgun"
	desc = "Equipment for medical exosuits. Generates a focused beam of medical nanites."
	icon = 'icons/hispania/mecha/mecha_equipment.dmi'
	icon_state = "mecha_medigun"
	energy_drain = 200
	range = MECHA_MELEE|MECHA_RANGED
	equip_cooldown = 10
	var/last_check = 0
	var/mode = 0
	origin_tech = "materials=6;biotech=6;magnets=5;engineering=7"
	var/obj/item/gun/medbeam/mech/medigun

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Initialize()
	. = ..()
	medigun = new(src)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Destroy()
	qdel(medigun)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Topic(href,href_list)
	..()
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		switch(mode)
			if(0)
				occupant_message("Prototype Beamgun on.")
			if(1)
				occupant_message("Prototype Beamgun off.")
				medigun.LoseTarget()
				set_ready_state(1)


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/get_equip_info()
	return "[..()] \[<a href='?src=[UID()];mode=0'>on</a>|<a href='?src=[UID()];mode=1'>off</a>\]"


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/process()
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

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/action(atom/target)
	switch(mode)
		if(0)
			if(chassis.has_charge(energy_drain))
				medigun.process_fire(target, loc)
				if(medigun.active)
					set_ready_state(0)
			else
				if(istype(target, /mob/living))
					occupant_message("insufficient energy")
		if(1)
			if(istype(target, /mob/living))
				occupant_message("Prototype Beamgun is off")

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	medigun.LoseTarget()
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/protomechmedbeam
	name = "exosuit prototype beamgun"
	desc = "Equipment for medical exosuits. Generates a focused beam of medical nanites. This prototype consumes excessive energy."
	energy_drain = 800
	origin_tech = "materials=6;biotech=6;magnets=5;engineering=6"

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/protomechmedbeam/Initialize()
	. = ..()
	medigun.upgrade = FALSE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/large
	name = "exosuit large syringe gun"
	desc = "Equipment for medical exosuits. A upgraded exosuit syringe gun"
	icon = 'icons/hispania/obj/guns/projectile.dmi'
	icon_state = "rapidsyringegun"
	max_syringes = 20
	max_volume = 150
	energy_drain = 100
	origin_tech = "materials=4;biotech=5;magnets=4,engineering=4"
