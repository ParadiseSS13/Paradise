#define WAND_OPEN "Open Door"
#define WAND_BOLT "Toggle Bolts"
#define WAND_EMERGENCY "Toggle Emergency Access"
#define WAND_SPEED "Change Closing Speed"
#define WAND_ELECTRIFY "Electrify Door"

/obj/item/door_remote
	icon_state = "gangtool-white"
	item_state = "electronic"
	icon = 'icons/obj/device.dmi'
	name = "control wand"
	desc = "Remotely controls airlocks."
	w_class = WEIGHT_CLASS_TINY
	flags = NOBLUDGEON
	var/mode = WAND_OPEN
	var/region_access = list()
	var/additional_access = list()
	var/obj/item/card/id/ID
	var/emagged = FALSE

/obj/item/door_remote/New()
	..()
	ID = new /obj/item/card/id
	for(var/region in region_access)
		ID.access += get_region_accesses(region)
	ID.access += additional_access
	ID.access = uniquelist(ID.access)

/obj/item/door_remote/Destroy()
	QDEL_NULL(ID)
	return ..()

/obj/item/door_remote/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		if(user)
			to_chat(user, "<span class='warning'>you short out the safeties on [src]</span>")

/obj/item/door_remote/attack_self(mob/user)
	if(emagged)
		switch(mode)
			if(WAND_OPEN)
				mode = WAND_BOLT
			if(WAND_BOLT)
				mode = WAND_EMERGENCY
			if(WAND_EMERGENCY)
				mode = WAND_SPEED
			if(WAND_SPEED)
				mode = WAND_ELECTRIFY
			if(WAND_ELECTRIFY)
				mode = WAND_OPEN
	else
		switch(mode)
			if(WAND_OPEN)
				mode = WAND_BOLT
			if(WAND_BOLT)
				mode = WAND_EMERGENCY
			if(WAND_EMERGENCY)
				mode = WAND_SPEED
			if(WAND_SPEED)
				mode = WAND_OPEN

	to_chat(user, "<span class='notice'>Now in mode: [mode].</span>")

/obj/item/door_remote/afterattack(obj/machinery/door/airlock/D, mob/user)
	if(!istype(D))
		D = locate() in get_turf(D)
	if(!istype(D))
		return
	if(HAS_TRAIT(D, TRAIT_CMAGGED))
		to_chat(user, "<span class='danger'>The door doesn't respond to [src]!</span>")
		return
	if(D.is_special)
		to_chat(user, "<span class='danger'>[src] cannot access this kind of door!</span>")
		return
	if(!(D.arePowerSystemsOn()))
		to_chat(user, "<span class='danger'>[D] has no power!</span>")
		return
	if(!D.requiresID())
		to_chat(user, "<span class='danger'>[D]'s ID scan is disabled!</span>")
		return
	if(D.check_access(src.ID))
		D.add_hiddenprint(user)
		if(emagged)
			switch(mode)
				if(WAND_OPEN)
					if(D.density)
						D.open()
						add_attack_logs(user, D, "opened")
					else
						D.close()
						add_attack_logs(user, D, "closed")
				if(WAND_BOLT)
					if(D.locked)
						D.unlock()
						add_attack_logs(user, D, "unlocked")
					else
						D.lock()
						add_attack_logs(user, D, "locked")
				if(WAND_EMERGENCY)
					if(D.emergency)
						D.emergency = FALSE
						add_attack_logs(user, D, "toggled off emergency access")
					else
						D.emergency = TRUE
						add_attack_logs(user, D, "toggled on emergency access")
					D.update_icon()
				if(WAND_SPEED)
					D.normalspeed = !D.normalspeed
					to_chat(user, "<span class='notice'>[D] is now in [D.normalspeed ? "normal" : "fast"] mode.</span>")
					add_attack_logs(user, D, "changed speed mode")
				if(WAND_ELECTRIFY)
					if(D.electrified_until == -1)
						D.electrified_until = 0
						to_chat(user, "<span class='notice'>[D] is no longer electrified.</span>")
						add_attack_logs(user, D, "un-electrified")
					else
						D.electrified_until = -1
						to_chat(user, "<span class='notice'>You electrify [D].</span>")
						add_attack_logs(user, D, "electrified")
		if(emagged == FALSE)
			switch(mode)
				if(WAND_OPEN)
					if(D.density)
						D.open()
						add_attack_logs(user, D, "opened")
					else
						D.close()
						add_attack_logs(user, D, "closed")
				if(WAND_BOLT)
					if(D.locked)
						D.unlock()
						add_attack_logs(user, D, "unlocked")
					else
						D.lock()
						add_attack_logs(user, D, "locked")
				if(WAND_EMERGENCY)
					if(D.emergency)
						D.emergency = FALSE
						add_attack_logs(user, D, "toggled off emergency access")
					else
						D.emergency = TRUE
						add_attack_logs(user, D, "toggled on emergency access")
					D.update_icon()
				if(WAND_SPEED)
					D.normalspeed = !D.normalspeed
					to_chat(user, "<span class='notice'>[D] is now in [D.normalspeed ? "normal" : "fast"] mode.</span>")
					add_attack_logs(user, D, "changed speed mode")
	else
		to_chat(user, "<span class='danger'>[src] does not have access to this door.</span>")

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	region_access = list(REGION_ALL)

/obj/item/door_remote/captain
	name = "command door remote"
	icon_state = "gangtool-yellow"
	region_access = list(REGION_COMMAND)

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	icon_state = "gangtool-orange"
	region_access = list(REGION_ENGINEERING)

/obj/item/door_remote/research_director
	name = "research door remote"
	icon_state = "gangtool-purple"
	region_access = list(REGION_RESEARCH)

/obj/item/door_remote/head_of_security
	name = "security door remote"
	icon_state = "gangtool-red"
	region_access = list(REGION_SECURITY)

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	icon_state = "gangtool-green"
	region_access = list(REGION_SUPPLY)

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	icon_state = "gangtool-blue"
	region_access = list(REGION_MEDBAY)

/obj/item/door_remote/civillian
	name = "civillian door remote"
	icon_state = "gangtool-white"
	region_access = list(REGION_GENERAL, REGION_SUPPLY)
	additional_access = list(ACCESS_HOP)

/obj/item/door_remote/centcomm
	name = "centcomm door remote"
	desc = "High-ranking NT officials only."
	icon_state = "gangtool-blue"
	region_access = list(REGION_CENTCOMM)

/obj/item/door_remote/taipan
	name = "Taipan door remote"
	desc = "High-ranking Syndicate officials only."
	icon_state = "gangtool-syndie"
	region_access = list(REGION_TAIPAN)

/obj/item/door_remote/omni/access_tuner
	name = "access tuner"
	desc = "A device used for illegally interfacing with doors."
	icon_state = "hacktool"
	item_state = "hacktool"
	emagged = TRUE
	var/hack_speed = 30
	var/busy = FALSE

/obj/item/door_remote/omni/access_tuner/afterattack(obj/machinery/door/airlock/D, mob/user)
	if(!istype(D))
		return
	if(HAS_TRAIT(D, TRAIT_CMAGGED))
		to_chat(user, "<span class='danger'>The door doesn't respond to [src]!</span>")
		return
	if(busy)
		to_chat(user, "<span class='warning'>[src] is alreading interfacing with a door!</span>")
		return
	icon_state = "hacktool-g"
	busy = TRUE
	to_chat(user, "<span class='notice'>[src] is attempting to interface with [D]...</span>")
	if(do_after(user, hack_speed, target = D))
		. = ..()
	busy = FALSE
	icon_state = "hacktool"

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
#undef WAND_SPEED
