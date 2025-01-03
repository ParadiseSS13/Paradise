/obj/effect/lock_portal
	name = "crack in reality"
	desc = "A crack in space, impossibly deep and painful to the eyes. Definitely not safe."
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "realitycrack"
	light_power = 1
	light_color = COLOR_GREEN
	light_range = 3
	opacity = TRUE
	density = FALSE //so we dont block doors closing
	layer = OBJ_LAYER //under doors
	///The knock portal we teleport to
	var/obj/effect/lock_portal/destination
	///The airlock we are linked to, we delete if it is destroyed
	var/obj/machinery/door/our_airlock
	/// if true the heretic is teleported to a random airlock, nonheretics are sent to the target
	var/inverted = FALSE

/obj/effect/lock_portal/Initialize(mapload, target, invert = FALSE)
	. = ..()
	if(target)
		our_airlock = target
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(delete_on_door_delete))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	inverted = invert

///Deletes us and our destination portal if our_airlock is destroyed
/obj/effect/lock_portal/proc/delete_on_door_delete(datum/source)
	SIGNAL_HANDLER
	qdel(src)

///Signal handler for when our location is entered, calls teleport on the victim, if their old_loc didnt contain a portal already (to prevent loops)
/obj/effect/lock_portal/proc/on_entered(datum/source, mob/living/loser, atom/old_loc)
	SIGNAL_HANDLER
	if(istype(loser) && !(locate(type) in old_loc))
		teleport(loser)

/obj/effect/lock_portal/Destroy()
	if(!isnull(destination) && !QDELING(destination))
		QDEL_NULL(destination)

	destination = null
	our_airlock = null
	return ..()

///Teleports the teleportee, to a random airlock if the teleportee isnt a heretic, or the other portal if they are one
/obj/effect/lock_portal/proc/teleport(mob/living/teleportee)
	if(isnull(destination)) //dumbass
		qdel(src)
		return

	if(!is_teleport_allowed(destination.z) || !is_teleport_allowed(z))
		qdel(src)
		return

	//get it?
	var/obj/machinery/door/doorstination = (inverted ? !IS_HERETIC_OR_MONSTER(teleportee) : IS_HERETIC_OR_MONSTER(teleportee)) ? destination.our_airlock : find_random_airlock()
	if(SEND_SIGNAL(teleportee, COMSIG_MOVABLE_TELEPORTING, get_turf(teleportee)) & COMPONENT_BLOCK_TELEPORT)
		return FALSE
	teleportee.forceMove(destination)

	teleportee.client?.move_delay = 0 //make moving through smoother

	if(!IS_HERETIC_OR_MONSTER(teleportee))
		teleportee.apply_damage(20, BRUTE) //so they dont roll it like a jackpot machine to see if they can land in the armory
		to_chat(teleportee, "<span class='userdanger'>You stumble through [src], battered by forces beyond your comprehension, landing anywhere but where you thought you were going.</span>")

	INVOKE_ASYNC(src, PROC_REF(async_opendoor), doorstination)

///Returns a random airlock on the same Z level as our portal, that isnt our airlock
/obj/effect/lock_portal/proc/find_random_airlock()
	var/list/turf/possible_destinations = list()
	for(var/obj/machinery/door/airlock in GLOB.airlocks)
		if(airlock.z != z)
			continue
		if(airlock.loc == loc)
			continue
		var/area/airlock_area = get_area(airlock)
		if(airlock_area.tele_proof)
			continue
		possible_destinations += airlock
	return pick(possible_destinations)

///Asynchronous proc to unbolt, then open the passed door
/obj/effect/lock_portal/proc/async_opendoor(obj/machinery/door/door)
	if(istype(door, /obj/machinery/door/airlock)) //they can create portals on ANY door, but we should unlock airlocks so they can actually open
		var/obj/machinery/door/airlock/as_airlock = door
		as_airlock.unlock(TRUE)
	door.open()

///An ID card capable of shapeshifting to other IDs given by the Key Keepers Burden knowledge
/obj/item/card/id/heretic
	///List of IDs this card consumed
	var/list/obj/item/card/id/fused_ids = list()
	///The first portal in the portal pair, so we can clear it later
	var/obj/effect/lock_portal/portal_one
	///The second portal in the portal pair, so we can clear it later
	var/obj/effect/lock_portal/portal_two
	///The first door we are linking in the pair, so we can create a portal pair
	var/link
	/// are our created portals inverted? (heretics get sent to a random airlock, crew get sent to the target)
	var/inverted = FALSE
	can_id_flash = FALSE

/obj/item/card/id/heretic/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return
	. += "<span class='hierophant_warning'>Enchanted by the Mansus!</span>"
	. += "<span class='hierophant_warning'>Using an ID on this or using this ID on another ID will consume it and allow you to copy its accesses.</span>"
	. += "<span class='hierophant_warning'><b>Using this in-hand</b> allows you to change its appearance.</span>"
	. += "<span class='hierophant_warning'><b>Using this on a pair of doors</b>, allows you to link them together. Entering one door will transport you to the other, while heathens are instead teleported to a random airlock.</span>"
	. += "<span class='hierophant_warning'><b>Ctrl-clicking the ID</b>, makes the ID make inverted portals instead, which teleport you onto a random airlock onstation, while heathens are teleported to the destination.</span>"

/obj/item/card/id/heretic/activate_self(mob/user)
	if(..())
		return
	if(!IS_HERETIC(user))
		return flash_card()
	var/cardname = tgui_input_list(user, "Shapeshift into?", "Shapeshift", fused_ids)
	if(!cardname)
		to_chat(user, "<span class='hierophant'>There is no ID to shapeshift into!</span>")
		return ..()
	var/obj/item/card/id/card = fused_ids[cardname]
	shapeshift(card)

/obj/item/card/id/heretic/CtrlClick(mob/user)
	. = ..()
	if(loc != user) // Not being held
		return
	if(!IS_HERETIC(user))
		return
	inverted = !inverted
	to_chat(user, "<span class='hierophant'>[inverted ? "now" : "no longer"] creating inverted rifts.</span>")

///Changes our appearance to the passed ID card
/obj/item/card/id/heretic/proc/shapeshift(obj/item/card/id/card)
	icon_state = card.icon_state
	assignment = card.assignment
	age = card.age
	sex = card.sex
	registered_name = card.registered_name
	name = card.name
	update_icon()
	//Qwertodo: not done here

///Deletes and nulls our portal pair
/obj/item/card/id/heretic/proc/clear_portals()
	QDEL_NULL(portal_one)
	QDEL_NULL(portal_two)

///Clears portal references
/obj/item/card/id/heretic/proc/clear_portal_refs()
	SIGNAL_HANDLER
	portal_one = null
	portal_two = null

///Creates a portal pair at door1 and door2, displays a balloon alert to user
/obj/item/card/id/heretic/proc/make_portal(mob/user, obj/machinery/door/door1, obj/machinery/door/door2)
	var/message = "Door linked"
	if(portal_one || portal_two)
		clear_portals()
		message += ", previous cleared"

	portal_one = new(get_turf(door2), door2, inverted)
	portal_two = new(get_turf(door1), door1, inverted)
	portal_one.destination = portal_two
	RegisterSignal(portal_one, COMSIG_PARENT_QDELETING, PROC_REF(clear_portal_refs))  //we only really need to register one because they already qdel both portals if one is destroyed
	portal_two.destination = portal_one
	to_chat(user, "<span class='hierophant'>[message].</span>")

/obj/item/card/id/heretic/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/card/id) || !IS_HERETIC(user))
		return ..()
	eat_card(tool, user)
	return ITEM_INTERACT_COMPLETE

/obj/item/card/id/heretic/proc/eat_card(obj/item/card/id/card, mob/user)
	if(card == src)
		return //no self vore
	fused_ids[card.name] = card
	card.moveToNullspace()
	playsound(drop_location(), 'sound/items/eatfood.ogg', rand(10,30), TRUE)
	access += card.access

/obj/item/card/id/heretic/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!IS_HERETIC(user))
		return NONE
	if(istype(target, /obj/item/card/id))
		eat_card(target, user)
		return ITEM_INTERACT_COMPLETE
	if(istype(target, /obj/effect/lock_portal))
		clear_portals()
		return ITEM_INTERACT_COMPLETE
	if(!istype(target, /obj/machinery/door))
		return NONE
	if(!is_teleport_allowed(z))
		return NONE
	var/reference_resolved = locateUID(link)
	if(reference_resolved == target)
		return ITEM_INTERACT_COMPLETE

	if(reference_resolved)
		make_portal(user, reference_resolved, target)
		to_chat(user, "<span class='notice'>You use [src], to link [reference_resolved] and [target] together.</span>")
		link = null
		to_chat(user, "<span class='hierophant'>Link 2/2.</span>")
	else
		link = UID(target)
		to_chat(user, "<span class='hierophant'>Link 1/2.</span>")
	return ITEM_INTERACT_COMPLETE

/obj/item/card/id/heretic/Destroy()
	QDEL_LIST_ASSOC(fused_ids)
	link = null
	clear_portals()
	return ..()
