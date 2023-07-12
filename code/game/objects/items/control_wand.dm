#define WAND_OPEN "Open Door"
#define WAND_BOLT "Toggle Bolts"
#define WAND_EMERGENCY "Toggle Emergency Access"
#define WAND_SPEED "Change Closing Speed"

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

/obj/item/door_remote/attack_self(mob/user)
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

/obj/item/door_remote/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's current mode is: [mode]</span>"

/obj/item/door_remote/afterattack(obj/machinery/door/airlock/D, mob/user)
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
		switch(mode)
			if(WAND_OPEN)
				if(D.density)
					D.open()
				else
					D.close()
			if(WAND_BOLT)
				if(D.locked)
					D.unlock()
				else
					D.lock()
			if(WAND_EMERGENCY)
				if(D.emergency)
					D.emergency = FALSE
				else
					D.emergency = TRUE
				D.update_icon()
			if(WAND_SPEED)
				D.normalspeed = !D.normalspeed
				to_chat(user, "<span class='notice'>[D] is now in [D.normalspeed ? "normal" : "fast"] mode.</span>")
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

/obj/item/door_remote/omni/access_tuner
	name = "access tuner"
	desc = "A device used for illegally interfacing with doors."
	icon_state = "hacktool"
	item_state = "hacktool"
	var/hack_speed = 30
	var/busy = FALSE

/obj/item/door_remote/omni/access_tuner/afterattack(obj/machinery/door/airlock/D, mob/user)
	if(!istype(D))
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

/// How long before you can "jangle" your keyring again (to prevent spam)
#define JANGLE_COOLDOWN 10 SECONDS

/obj/item/door_remote/janikeyring
	name = "janitor's keyring"
	desc = "An absolutely unwieldy set of keys attached to a metal ring. The keys on the ring allow you to access most Departmental entries and the Service Department!"
	icon_state = "keyring"
	item_state = "keyring"
	/// Are you already using the keyring?
	var/busy = FALSE
	/// This prevents spamming the key-shake.
	var/cooldown = 0
	/// How fast does the keyring open an airlock. It is not set here so that it can be set via the user's role.
	var/hack_speed
	additional_access = list(ACCESS_MEDICAL, ACCESS_RESEARCH, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_MINING, ACCESS_KITCHEN, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CHAPEL_OFFICE)

/obj/item/door_remote/janikeyring/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This keyring has access to Medbay, Science, Engineering, Cargo, the Bar and the Kitchen!</span>"

/obj/item/door_remote/janikeyring/attack_self(mob/user)
	if(cooldown > world.time)
		return
	to_chat(user, "<span class='warning'>You shake [src]!</span>")
	playsound(src, 'sound/items/keyring_shake.ogg', 50)
	cooldown = world.time + JANGLE_COOLDOWN

/obj/item/door_remote/janikeyring/afterattack(obj/machinery/door/airlock/D, mob/user, proximity)
	if(!proximity)
		return
	if(!istype(D))
		return
	if(busy)
		to_chat(user, "<span class='warning'>You are already using [src] on the [D] airlock's access panel!</span>")
		return
	busy = TRUE
	to_chat(user, "<span class='notice'>You fiddle with [src], trying different keys to open the [D] airlock...</span>")
	playsound(src, 'sound/items/keyring_unlock.ogg', 50)

	var/mob/living/carbon/human/H = user
	if(H.mind.assigned_role != "Janitor")
		hack_speed = rand(30, 60) SECONDS
	else
		hack_speed = rand(5, 20) SECONDS

	if(!do_after(user, hack_speed, target = D, progress = 0))
		busy = FALSE
		return
	busy = FALSE

	if(!istype(D))
		return

	if(HAS_TRAIT(D, TRAIT_CMAGGED))
		to_chat(user, "<span class='danger'>[src] won't fit in the [D] airlock's access panel, there's slime everywhere!</span>")
		return

	if(D.is_special)
		to_chat(user, "<span class='danger'>[src] cannot fit in the [D] airlock's access panel!</span>")
		return

	if(!D.arePowerSystemsOn())
		to_chat(user, "<span class='danger'>The [D] airlock has no power!</span>")
		return

	if(D.check_access(ID))
		D.add_hiddenprint(user)
		if(D.density)
			D.open()
		else
			to_chat(user, "<span class='danger'>The [D] airlock is already open!</span>")

	else
		to_chat(user, "<span class='danger'>[src] does not seem to have a key for the [D] airlock's access panel!</span>")

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
#undef WAND_SPEED
#undef JANGLE_COOLDOWN
