#define WAND_OPEN "Open Door"
#define WAND_BOLT "Toggle Bolts"
#define WAND_EMERGENCY "Toggle Emergency Access"
#define WAND_SPEED "Change Closing Speed"

/obj/item/door_remote
	name = "control wand"
	desc = "Remotely controls airlocks."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-white"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_TINY
	flags = NOBLUDGEON
	var/mode = WAND_OPEN
	var/region_access = list()
	var/additional_access = list()
	var/obj/item/card/id/ID
	new_attack_chain = TRUE

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	ID = new /obj/item/card/id
	for(var/region in region_access)
		ID.access += get_region_accesses(region)
	ID.access += additional_access
	ID.access = uniquelist(ID.access)

/obj/item/door_remote/Destroy()
	QDEL_NULL(ID)
	return ..()

/obj/item/door_remote/activate_self(mob/user)
	if(..())
		return

	var/list/options = list(WAND_OPEN = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_open"),
									WAND_BOLT = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_bolt"),
									WAND_EMERGENCY = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_ea"),
									WAND_SPEED = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_speed"))
	var/image/part_image = options[mode]
	// scuffed, but allows you to easily show whats the currently selected one
	part_image.underlays += image(icon = 'icons/mob/radial.dmi', icon_state = "radial_slice_focus")
	var/choice = show_radial_menu(user, src, options)
	if(!choice || user.stat || !in_range(user, src) || QDELETED(src))
		return
	if(choice == mode) // they didn't change their choice, don't do the to_chat
		return
	mode = choice

	to_chat(user, "<span class='notice'>Now in mode: [mode].</span>")

/obj/item/door_remote/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's current mode is: [mode]</span>"

/obj/item/door_remote/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(istype(target, /obj/machinery/door/airlock))
		access_airlock(target, user)
		return ITEM_INTERACT_COMPLETE
	if(istype(target, /obj/machinery/door/window))
		access_windoor(target, user)
		return ITEM_INTERACT_COMPLETE

/obj/item/door_remote/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(istype(target, /obj/machinery/door/airlock))
		access_airlock(target, user)
		return ITEM_INTERACT_COMPLETE
	if(istype(target, /obj/machinery/door/window))
		access_windoor(target, user)
		return ITEM_INTERACT_COMPLETE

/obj/item/door_remote/proc/access_airlock(obj/machinery/door/airlock/D, mob/user)
	if(HAS_TRAIT(D, TRAIT_CMAGGED))
		to_chat(user, "<span class='danger'>The door doesn't respond to [src]!</span>")
		return

	if(!(D.arePowerSystemsOn()))
		to_chat(user, "<span class='danger'>[D] has no power!</span>")
		return

	if(!D.requiresID())
		to_chat(user, "<span class='danger'>[D]'s ID scan is disabled!</span>")
		return

	if(!D.check_access(src.ID))
		to_chat(user, "<span class='danger'>[src] does not have access to this door.</span>")
		return

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
			D.emergency = !D.emergency
			D.update_icon()
		if(WAND_SPEED)
			D.normalspeed = !D.normalspeed
			to_chat(user, "<span class='notice'>[D] is now in [D.normalspeed ? "normal" : "fast"] mode.</span>")

/obj/item/door_remote/proc/access_windoor(obj/machinery/door/window/D, mob/user)
	if(HAS_TRAIT(D, TRAIT_CMAGGED))
		to_chat(user, "<span class='danger'>The door doesn't respond to [src]!</span>")
		return

	if(!D.has_power())
		to_chat(user, "<span class='danger'>[D] has no power!</span>")
		return

	if(!D.requiresID())
		to_chat(user, "<span class='danger'>[D]'s ID scan is disabled!</span>")
		return

	if(!D.check_access(ID))
		to_chat(user, "<span class='danger'>[src] does not have access to this door.</span>")
		return

	D.add_hiddenprint(user)
	switch(mode)
		if(WAND_OPEN)
			if(D.density)
				D.open()
			else
				D.close()
		if(WAND_BOLT)
			to_chat(user, "<span class='danger'>[D] has no bolting functionality.</span>")
		if(WAND_EMERGENCY)
			to_chat(user, "<span class='danger'>[D] has no emergency access functionality.</span>")
		if(WAND_SPEED)
			to_chat(user, "<span class='danger'>[D] has no speed change functionality.</span>")

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	region_access = list(REGION_ALL)

/obj/item/door_remote/captain
	name = "command door remote"
	icon_state = "gangtool-blue"
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
	icon_state = "gangtool-brown"
	region_access = list(REGION_SUPPLY)

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	region_access = list(REGION_MEDBAY)

/obj/item/door_remote/civillian
	name = "civilian door remote"
	icon_state = "gangtool-green"
	region_access = list(REGION_GENERAL)
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
	inhand_icon_state = "hacktool"
	var/hack_speed = 1.5 SECONDS
	var/busy = FALSE
	/// How far can we use this. Leave `null` for infinite range
	var/range

/obj/item/door_remote/omni/access_tuner/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(hack(target, user))	// if the hack is successful, calls the parent proc and does the door stuff
		return ..()

/obj/item/door_remote/omni/access_tuner/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(hack(target, user))
		return ..()

/obj/item/door_remote/omni/access_tuner/proc/hack(atom/target, mob/user)
	if(!istype(target, /obj/machinery/door/airlock) && !istype(target, /obj/machinery/door/window))
		return
	if(!isnull(range) && get_dist(src, target) > range)
		return

	if(busy)
		to_chat(user, "<span class='warning'>[src] is alreading interfacing with a door!</span>")
		return
	icon_state = "hacktool-g"
	busy = TRUE
	to_chat(user, "<span class='notice'>[src] is attempting to interface with [target]...</span>")
	if(do_after(user, hack_speed, target = target, hidden = TRUE))
		busy = FALSE
		icon_state = "hacktool"
		return TRUE
	busy = FALSE
	icon_state = "hacktool"

/obj/item/door_remote/omni/access_tuner/flayer
	name = "integrated access tuner"
	hack_speed = 5 SECONDS
	range = 10

/// How long before you can "jangle" your keyring again (to prevent spam)
#define JANGLE_COOLDOWN 10 SECONDS

/obj/item/door_remote/janikeyring
	name = "janitor's keyring"
	desc = "An absolutely unwieldy set of keys attached to a metal ring. The keys on the ring allow you to access most Departmental entries and the Service Department!"
	icon_state = "keyring"
	inhand_icon_state = null
	/// Are you already using the keyring?
	var/busy = FALSE
	/// This prevents spamming the key-shake.
	var/cooldown = 0
	/// How fast does the keyring open an airlock. It is not set here so that it can be set via the user's role.
	var/hack_speed
	/// Stores the last airlock opened, opens faster on repeated use
	var/last_airlock_uid
	additional_access = list(ACCESS_MEDICAL, ACCESS_RESEARCH, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_MINING, ACCESS_KITCHEN, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CHAPEL_OFFICE)

/obj/item/door_remote/janikeyring/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ACTIVATE_SELF, TYPE_PROC_REF(/datum, signal_cancel_activate_self))

/obj/item/door_remote/janikeyring/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This keyring has access to Medbay, Science, Engineering, Cargo, the Bar and the Kitchen!</span>"

/obj/item/door_remote/janikeyring/activate_self(mob/user)
	if(..() || cooldown > world.time)
		return

	to_chat(user, "<span class='warning'>You shake [src]!</span>")
	playsound(src, 'sound/items/keyring_shake.ogg', 50)
	cooldown = world.time + JANGLE_COOLDOWN

/obj/item/door_remote/janikeyring/interact_with_atom(obj/machinery/door/target, mob/living/user, list/modifiers)
	if(unlock(target, user))
		return ..()

/obj/item/door_remote/janikeyring/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers) // THOSE AINT MAGICAL REMOTE KEYS
	return NONE


/obj/item/door_remote/janikeyring/proc/unlock(obj/machinery/door/target, mob/living/user)
	if(!istype(target, /obj/machinery/door/airlock) && !istype(target, /obj/machinery/door/window))
		return
	if(busy)
		to_chat(user, "<span class='warning'>You are already using [src] on the [target]'s access panel!</span>")
		return
	busy = TRUE
	var/mob/living/carbon/human/H = user
	if(H.mind.assigned_role == "Janitor" && last_airlock_uid == target.UID())
		to_chat(user, "<span class='notice'>You recognize [target] and look for the key you used...</span>")
		hack_speed = 5 SECONDS
	else
		to_chat(user, "<span class='notice'>You fiddle with [src], trying different keys to open [target]...</span>")
		if(H.mind.assigned_role != "Janitor")
			hack_speed = rand(30, 60) SECONDS
		else
			hack_speed = rand(5, 20) SECONDS
	playsound(src, 'sound/items/keyring_unlock.ogg', 50)
	if(do_after(user, hack_speed, target = target, progress = 0))
		if(target.check_access(ID))
			last_airlock_uid = target.UID()
		busy =  FALSE
		return TRUE
	busy = FALSE

/obj/item/door_remote/janikeyring/access_airlock(obj/machinery/door/airlock/D, mob/user)
	if(HAS_TRAIT(D, TRAIT_CMAGGED))
		to_chat(user, "<span class='danger'>[src] won't fit in the [D] airlock's access panel, there's slime everywhere!</span>")
		return

	if(!D.arePowerSystemsOn())
		to_chat(user, "<span class='danger'>The [D] airlock has no power!</span>")
		return

	if(!D.check_access(ID))
		to_chat(user, "<span class='danger'>[src] does not seem to have a key for the [D] airlock's access panel!</span>")
		return

	D.add_hiddenprint(user)
	if(D.density)
		D.open()
	else
		to_chat(user, "<span class='danger'>The [D] airlock is already open!</span>")

/obj/item/door_remote/janikeyring/access_windoor(obj/machinery/door/window/D, mob/user)
	if(!(D.has_power()))
		to_chat(user, "<span class='danger'>[D] has no power!</span>")
		return

	if(!D.check_access(ID))
		to_chat(user, "<span class='danger'>[src] does not seem to have a key for the [D]'s access panel!</span>")
		return

	D.add_hiddenprint(user)
	if(D.density)
		D.open()
	else
		to_chat(user, "<span class='danger'>The [D] is already open!</span>")

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
#undef WAND_SPEED
#undef JANGLE_COOLDOWN
