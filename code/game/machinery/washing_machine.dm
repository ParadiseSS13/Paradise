#define DEFAULT_TUB_CAPACITY 20

#define WM_STATE_EMPTY				1
#define WM_STATE_FULL				2
#define WM_STATE_RUNNING			3
#define WM_STATE_BLOODY				4
#define WM_STATE_RUNNING_BLOODY		5

/obj/machinery/washing_machine
	name = "washing machine"
	desc = "Gets rid of those pesky bloodstains, or your money back!"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = TRUE
	anchored = TRUE

	var/washing_state = WM_STATE_EMPTY

	/// LAZYLIST of insert obj/item's inside the washer tub
	var/list/inserted_items
	/// LAZYLIST of inserted mob/living's inside the washer tube
	var/list/inserted_mobs

	/// Is the washer in the middle of a wash cycle? Used to regulate certain interactions with the washer
	var/washing = FALSE
	/// Is the washer currently open?
	var/door_open = FALSE
	/// How much shit is currently in this laundry machine? Used to cap how much stuff you can put in here
	var/current_tub_capacity = 0
	/// The cap for how much stuff you can shove in here
	var/max_tub_capacity = DEFAULT_TUB_CAPACITY
	/// Is the washing machine tub filled with gibs/blood? Effects the sprite it uses
	var/bloody_mess = FALSE
	/// Where is our DYE color coming from?
	var/obj/item/color_source
	/// What DYE color are we dyeing stuff?
	var/wash_color

/obj/machinery/washing_machine/Destroy()
	eject_tub_contents() // cleans up refs & signals
	return ..()

/obj/machinery/washing_machine/update_icon_state()
	icon_state = "wm_[washing_state][door_open ? 1 : 0][panel_open ? "_panel" : ""]"

/// Determines which "WM state" to apply based on if the machine is a bloody mess, full/empty, washing, etc and then updates the icon state accordingly
/obj/machinery/washing_machine/proc/update_washing_state()
	if(bloody_mess)
		washing_state = washing ? WM_STATE_RUNNING_BLOODY : WM_STATE_BLOODY
		update_appearance(UPDATE_ICON_STATE)
		return
	if(washing)
		washing_state = WM_STATE_RUNNING
		update_appearance(UPDATE_ICON_STATE)
		return
	washing_state = current_tub_capacity ? WM_STATE_FULL : WM_STATE_EMPTY
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/washing_machine/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Its door is currently [door_open ? "open" : "closed"].</span>"
	if(washing)
		. += "<span class='notice'>It is currently in its wash cycle.</span>"
	else
		. += "<span class='notice'>You can <b>Alt-Click</b> [src] to start its washing cycle.</span>"
	if(bloody_mess)
		. += "<span class='warning'>The inside is covered in blood and gibs, you will need to clean it out with soap first.</span>"
	else
		var/total_contents = LAZYLEN(inserted_items) + LAZYLEN(inserted_mobs)
		. += "<span class='notice'>It has [total_contents] item\s inside.</span>"

/obj/machinery/washing_machine/AltClick(mob/user)
	if(user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!washing && !door_open)
		start_wash_cycle()

/obj/machinery/washing_machine/attack_hand(mob/user)
	if(washing && !door_open)
		to_chat(user, "<span class='warning'>[src]'s door is shut, you will need to wait until the end of the cycle.</span>")
		return
	toggle_door()

/obj/machinery/washing_machine/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(default_unfasten_wrench(user, used))
		return ITEM_INTERACT_COMPLETE
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, used))
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_COMPLETE
	if(default_deconstruction_crowbar(user, used, FALSE))
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/soap))
		return ..() // need to be able to clean washing machine without putting stuff into the washing machine :D
	if(istype(used, /obj/item/grab))
		var/obj/item/grab/G = used
		if(isliving(G.assailant))
			if(attempt_insert(user, G.affecting))
				qdel(G)
		return ITEM_INTERACT_COMPLETE
	if(istype(used))
		if(attempt_insert(user, used))
			return ITEM_INTERACT_COMPLETE

	return ..()


/*
	* # attempt_insert
	*
	* First part in the insert chain for putting items into the laundry machine, does some sanity checks on both the user and atom
	* moveable that's about to be shoved inside. Makes sure the user can actually perform this action and then calls the next proper
	* proc in the insert chain depending if they're a mob or obj/item
*/
/obj/machinery/washing_machine/proc/attempt_insert(mob/user, atom/movable/atom_to_insert)
	if(!anchored || (stat & BROKEN) || (stat & NOPOWER))
		return FALSE
	if(!door_open)
		to_chat(user, "<span class='warning'>[src]'s door is closed!</span>")
		return FALSE // simply not possible (or is it?)
	if(!istype(atom_to_insert) || !istype(user))
		return FALSE
	if(user.stat != CONSCIOUS || !Adjacent(user) || !atom_to_insert.Adjacent(user))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='notice'>You try to insert [atom_to_insert] into [src] but your hands are blocked!</span>")
		return FALSE
	if(isliving(atom_to_insert)) // not ismob() b/c we only want living creatures, ghosts could just float out of the washing machine whenever they wanted
		var/mob/living/sacrifice = atom_to_insert
		if(sacrifice.mob_size >= MOB_SIZE_HUMAN) // prevents some most mobs from being washed even if it would be really really funny
			to_chat(user, "<span class='notice'>You try to insert [sacrifice] into [src] but [sacrifice.p_theyre()] too large to fit inside!</span>")
			return FALSE
		if(sacrifice.buckled)
			to_chat(user, "<span class='notice'>You try to insert [sacrifice] into [src] but [sacrifice.p_theyre()] still buckled to something!</span>")
			return FALSE
		return insert_mob_into_tub(user, sacrifice)
	if(isitem(atom_to_insert)) // Restricting this to only item types prevents a lot of issues, you really only wanna shove items in here anyway...
		var/obj/item/item_to_insert = atom_to_insert
		if(item_to_insert.anchored)
			return FALSE
		if(item_to_insert.w_class >= WEIGHT_CLASS_HUGE)
			to_chat(user, "<span class='notice'>You try to insert [item_to_insert] into [src] but [item_to_insert.p_them()] is too large to fit inside!</span>")
			return FALSE
		return insert_item_into_tub(user, item_to_insert)

/// Handles inserting mobs into the washing machines, checks machines capacity, does a do_after, and then applys appropriate signals and updates machines state
/obj/machinery/washing_machine/proc/insert_mob_into_tub(mob/user, mob/living/mob_to_insert)
	var/mob_content_size = mob_to_insert.mob_size
	if(max_tub_capacity < (mob_content_size * 2) + current_tub_capacity)
		to_chat(user, "<span class='warning'>You try to insert [mob_to_insert] into [src] but it is too full for [mob_to_insert.p_them()]!</span>")
		return FALSE
	mob_to_insert.visible_message("<span class='warning'>[user] starts shoving [mob_to_insert] into [src]!</span>", "<span class='userdanger'>[user] starts shoving you into [src]!</span>")
	if(!do_after_once(user, (3 SECONDS * mob_content_size), target = src, attempt_cancel_message = "You stop inserting [mob_to_insert] into [src]."))
		return FALSE
	mob_to_insert.forceMove(src)
	RegisterSignal(mob_to_insert, COMSIG_PARENT_QDELETING, PROC_REF(check_tub_contents))
	RegisterSignal(mob_to_insert, COMSIG_MOVABLE_MOVED, PROC_REF(check_tub_contents))
	LAZYADD(inserted_mobs, mob_to_insert)
	calculate_tub_capacity()
	update_washing_state()
	add_attack_logs(user, mob_to_insert, "Shoved into washing machine.")
	to_chat(mob_to_insert, "<span class='userdanger'>[user] shoves you into [src]. Oh shit!</span>")
	mob_to_insert.visible_message("<span class='danger'>[user] shoves [mob_to_insert] into [src].</span>", "<span class='danger'>You shove [mob_to_insert] into [src].</span>")
	return TRUE

/// Handles inserting obj/items into the washing machines, checks machines capacity, does a do_after, and then applys appropriate signals and updates machines state
/obj/machinery/washing_machine/proc/insert_item_into_tub(mob/user, obj/item/item_to_insert)
	var/item_content_size = item_to_insert.w_class
	if(max_tub_capacity < (item_content_size + current_tub_capacity))
		to_chat(user, "<span class='warning'>You try to insert [item_to_insert] into [src] but [src] is too full for [item_to_insert.p_them()]!</span>")
		return FALSE
	if(!do_after_once(user, (1 SECONDS * (item_to_insert.w_class / 3)), target = src, attempt_cancel_message = "You stop inserting [item_to_insert] into [src]."))
		return FALSE
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[item_to_insert] is stuck to your hand!</span>")
		return FALSE
	item_to_insert.forceMove(src)
	RegisterSignal(item_to_insert, COMSIG_PARENT_QDELETING, PROC_REF(check_tub_contents))
	RegisterSignal(item_to_insert, COMSIG_MOVABLE_MOVED, PROC_REF(check_tub_contents))
	LAZYADD(inserted_items, item_to_insert)
	calculate_tub_capacity()
	update_washing_state()
	to_chat(user, "<span class='notice'>You insert [item_to_insert] into [src].</span>")
	return TRUE

/*
	* # check_tub_contents()
	*
	* Managing tons of contents inside the object is messy business, you never know when something is deleted, teleported, or moved into your obj
	* without your machine knowing, this clears bad references for GC/tracking purposes and adds references when something is added randomly to
	* our contents. This ensures we don't nullspace shit (such as a mob dropping a wrench or something) and spit it all back out afterwards even
	* if we didn't add it our selves!
	*
	* This proc is called via COMSIG_PARENT_QDELETING for objects we put inside through the insert proc
*/
/obj/machinery/washing_machine/proc/check_tub_contents()
	SIGNAL_HANDLER

	if(LAZYLEN(inserted_items))
		for(var/obj/item/I in inserted_items)
			if(QDELETED(I) || I.loc != src)
				if(!QDELETED(I))
					UnregisterSignal(I, COMSIG_PARENT_QDELETING)
					UnregisterSignal(I, COMSIG_MOVABLE_MOVED)
				LAZYREMOVE(inserted_items, I)
	if(LAZYLEN(inserted_mobs))
		for(var/mob/living/L in inserted_mobs)
			if(QDELETED(L) || L.loc != src)
				if(!QDELETED(L))
					UnregisterSignal(L, COMSIG_PARENT_QDELETING)
					UnregisterSignal(L, COMSIG_MOVABLE_MOVED)
				LAZYREMOVE(inserted_mobs, L)
	for(var/obj/item/I in contents)
		if(!LAZYIN(inserted_items, I))
			LAZYADD(inserted_items, I)
			RegisterSignal(I, COMSIG_PARENT_QDELETING, PROC_REF(check_tub_contents))
	for(var/mob/living/L in contents)
		if(!LAZYIN(inserted_mobs, L))
			LAZYADD(inserted_mobs, L)
			RegisterSignal(L, COMSIG_PARENT_QDELETING, PROC_REF(check_tub_contents))
	calculate_tub_capacity()
	update_washing_state()

/// Moves all Items/Mobs out of the laundry machine onto the Washing Machine's Loc, unregisters signals, then nulls the tracking lists
/obj/machinery/washing_machine/proc/eject_tub_contents()
	if(bloody_mess)
		playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
	check_tub_contents() // one last time, we wanna make sure nothing got teleported out
	if(LAZYLEN(inserted_items))
		for(var/obj/item/I in inserted_items)
			if(bloody_mess)
				I.add_blood() // what a mess!
			I.forceMove(loc)
			UnregisterSignal(I, COMSIG_PARENT_QDELETING)
			UnregisterSignal(I, COMSIG_MOVABLE_MOVED)
		LAZYNULL(inserted_items)
	if(LAZYLEN(inserted_mobs))
		for(var/mob/living/L in inserted_mobs)
			L.forceMove(loc)
			UnregisterSignal(L, COMSIG_PARENT_QDELETING)
			UnregisterSignal(L, COMSIG_MOVABLE_MOVED)
		LAZYNULL(inserted_mobs)
	calculate_tub_capacity()
	update_washing_state()

/// Calculates the total capacity of the contents of the tub,
/obj/machinery/washing_machine/proc/calculate_tub_capacity()
	var/new_capacity = 0
	if(LAZYLEN(inserted_items))
		for(var/obj/item/I in inserted_items)
			new_capacity += I.w_class
	if(LAZYLEN(inserted_mobs))
		for(var/mob/living/L in inserted_mobs)
			new_capacity += L.mob_size * 2
	current_tub_capacity = new_capacity

/obj/machinery/washing_machine/proc/toggle_door()
	door_open = !door_open
	if(door_open)
		eject_tub_contents()
	update_washing_state()

/// Attempts to locate stamps or crayons for dyeing purposes
/obj/machinery/washing_machine/proc/locate_color_source()
	var/list/color_sources = list()
	for(var/obj/item/toy/crayon/C in contents)
		color_sources += C
	for(var/obj/item/stamp/S in contents)
		color_sources += S
	if(!length(color_sources))
		return
	color_source = pick(color_sources)
	if(istype(color_source, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = color_source
		wash_color = C.dye_color
	if(istype(color_source, /obj/item/stamp))
		var/obj/item/stamp/S = color_source
		wash_color = S.dye_color

/obj/machinery/washing_machine/proc/start_wash_cycle()
	if(stat & (NOPOWER|BROKEN))
		return
	locate_color_source()
	washing = TRUE
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	atom_say("Beginning Wash Cycle!")
	sleep(1 SECONDS)
	update_washing_state()
	use_power(100)
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(wash_cycle)), 15 SECONDS)

/obj/machinery/washing_machine/proc/wash_cycle()
	for(var/obj/item/I in inserted_items)
		I.machine_wash(src)
	for(var/mob/living/L in inserted_mobs)
		L.machine_wash(src)
	update_washing_state()
	use_power(50 * current_tub_capacity)
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(end_wash_cycle)), 15 SECONDS)

/obj/machinery/washing_machine/proc/end_wash_cycle()
	if(bloody_mess)
		for(var/obj/item/I in inserted_items)
			I.add_blood(I.blood_DNA)
	QDEL_NULL(color_source)
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
	washing = FALSE
	atom_say("Wash Cycle Complete!")
	sleep(1 SECONDS)
	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	update_washing_state()

/obj/machinery/washing_machine/container_resist(mob/living/L)
	. = ..()
	if(washing)
		return
	if(!door_open)
		toggle_door()
		return
	else
		L.forceMove(loc)


/obj/machinery/washing_machine/deconstruct(disassembled = TRUE)
	eject_tub_contents()
	new /obj/item/stack/sheet/metal(drop_location(), 5)
	new /obj/item/circuitboard/washing_machine(drop_location(), 2)
	qdel(src)

/obj/machinery/washing_machine/AllowDrop()
	return TRUE // so gibs and dropped items end up inside of the washing machine instead when dropped

/obj/machinery/washing_machine/cleaning_act(mob/user, atom/cleaner, cleanspeed, text_verb, text_description, text_targetname)
	if(washing)
		to_chat(user, "<span class='warning'>[src]'s door is shut, you will need to wait until the end of the cycle to clean it out.</span>")
		return
	. = ..()
	if(. && !washing)
		bloody_mess = FALSE
		update_washing_state()

/obj/item/machine_wash(obj/machinery/washing_machine/washer)
	. = ..()
	if(washer.color_source)
		dye_item(washer.wash_color)

/obj/item/holder/machine_wash(obj/machinery/washing_machine/washer)
	. = ..()
	for(var/mob/living/held_mob in contents)
		held_mob.machine_wash(washer)

/obj/item/stack/sheet/hairlesshide/machine_wash(obj/machinery/washing_machine/washer)
	. = ..()
	new /obj/item/stack/sheet/wetleather(loc, amount)
	qdel(src)

/mob/living/simple_animal/machine_wash(obj/machinery/washing_machine/washer)
	if(mob_size >= MOB_SIZE_HUMAN)
		return
	washer.bloody_mess = TRUE
	add_attack_logs(washer, src, "gibbed by washing machine")
	gib() //warcrime time!

#undef DEFAULT_TUB_CAPACITY
#undef WM_STATE_EMPTY
#undef WM_STATE_FULL
#undef WM_STATE_RUNNING
#undef WM_STATE_BLOODY
#undef WM_STATE_RUNNING_BLOODY

//
//    , ,, ,
//    | || |    ,/  _____  \.
//    \_||_/    ||_/     \_||
//      ||       \_| . . |_/
//      ||         |  L  |
//     ,||         |`==='|
//     |>|      ___`>  -<'___
//     |>|\    /             |
//    \>| \   /  ,    .    .  |
//      ||  \/  /| .  |  . |  |
//      ||\  ` / | ___|___ |  |     (
//   (( || `--'  | _______ |  |     ))  (
// (  )\|| (  )\ | - --- - | -| (  ( \  ))
// (\/  || ))/ ( | -- - -- |  | )) )  \((
//  ( ()||((( ())|         |  |( (( () )hjm
//
//	"Allow this Devil to stand testament to the
//    the shitcode that once haunted this file"
//
