


#define DEFAULT_TUB_CAPACITY 20

#define WM_STATE_EMPTY				1
#define WM_STATE_FULL				2
#define WM_STATE_RUNNING			3
#define WM_STATE_BLOODY			4
#define WM_STATE_RUNNING_BLOODY	8



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

	/// static Typecache of items that are blacklists
	var/static/list/washing_blacklist = list(
		/obj/item/clothing/gloves/color/black/krav_maga/sec,
	)

	/// Is the washing machine tub filled with gibs/blood? Effects the sprite it uses
	var/bloody_mess = FALSE
	/// Where is our DYE color coming from?
	var/obj/item/color_source
	/// What DYE color are we dyeing stuff?
	var/wash_color

/obj/machinery/washing_machine/Initialize(mapload)
	. = ..()
	washing_blacklist = typecacheof(washing_blacklist)

/obj/machinery/washing_machine/Destroy()
	eject_tub_contents() // cleans up refs & signals
	return ..()

/obj/machinery/washing_machine/update_icon_state()
	icon_state = "wm_[washing_state][door_open ? 1 : 0][panel_open ? "_panel" : ""]"

/obj/machinery/washing_machine/proc/update_washing_state()
	if(bloody_mess)
		washing_state = washing ? WM_STATE_RUNNING_BLOODY : WM_STATE_BLOODY
		return
	if(current_tub_capacity)
		washing_state = washing ? WM_STATE_RUNNING : WM_STATE_FULL
		return
	washing_state = washing ? WM_STATE_RUNNING : WM_STATE_EMPTY
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/washing_machine/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's door is currently [door_open ? "open" : "closed"]."
	if(washing)
		. += "<span class='notice'>It is currently in it's wash cycle."
	else
		. += "<span class='notice'>You can <b>Alt-Click</b> [src] to start its washing cycle."
	if(bloody_mess)
		. += "<span class='warning'>The tub is covered in blood and gibs, you will need to clean it out with soap first."

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


/obj/machinery/washing_machine/attackby(obj/item/W, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(default_unfasten_wrench(user, W))
		return
	if(default_deconstruction_screwdriver(user, null, null, W))
		return
	if(default_deconstruction_crowbar(user, W, FALSE))
		return
	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(isliving(G.assailant))
			if(attempt_insert(user, G.assailant))
				qdel(G)
		return
	if(istype(W))
		if(attempt_insert(user, W))
			return
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
			to_chat(user, "<span class='notice'>You try to insert [sacrifice] into [src] but [sacrifice.p_theyre()] too large to fit inside the tub!</span>")
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
			to_chat(user, "<span class='notice'>You try to insert [item_to_insert] into [src] but [item_to_insert.p_them()] is too large for the tub!</span>")
			return FALSE
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[item_to_insert] is stuck to your hand!</span>")
			return FALSE
		return insert_item_into_tub(user, item_to_insert)
	return FALSE // how did we get here?

/obj/machinery/washing_machine/proc/insert_mob_into_tub(mob/user, mob/living/mob_to_insert)
	var/mob_content_size = mob_to_insert.mob_size
	if(max_tub_capacity < ((mob_content_size * 2) + current_tub_capacity))
		to_chat(user, "<span class='warning'>You try to insert [mob_to_insert] into [src] but the tub is too full for [mob_to_insert.p_them()]!</span>")
		return FALSE
	to_chat(mob_to_insert, "<span class='userdanger'>[user] starts shoving you into [src]!</span>")
	visible_message("<span class='warning'>[user] starts shoving [mob_to_insert] into [src]!</span>")
	if(!do_after_once(user, (3 SECONDS * mob_content_size), target = src, attempt_cancel_message = "You stop inserting [mob_to_insert] into [src]."))
		return FALSE
	mob_to_insert.forceMove(src)
	RegisterSignal(mob_to_insert, COMSIG_PARENT_QDELETING, PROC_REF(check_tub_contents))
	calculate_tub_capacity()
	update_washing_state()
	add_attack_logs(user, mob_to_insert, "Shoved into washing machine.")
	to_chat(mob_to_insert, "<span class='userdanger'>[user] shoves you into [src]. Oh shit!</span>")
	to_chat(user, "<span class='danger'>You shove [mob_to_insert] into [src].</span>")
	return TRUE

/obj/machinery/washing_machine/proc/insert_item_into_tub(mob/user, obj/item/item_to_insert)
	var/item_content_size = item_to_insert.w_class
	if(max_tub_capacity < (item_content_size + current_tub_capacity))
		to_chat(user, "<span class='warning'>You try to insert [item_to_insert] into [src] but the tub is too full for [item_to_insert.p_them()]!</span>")
		return FALSE
	if(!do_after_once(user, (1 SECONDS * (item_to_insert.w_class / 3)), target = src, attempt_cancel_message = "You stop inserting [item_to_insert] into [src]."))
		return FALSE
	item_to_insert.forceMove(src)
	RegisterSignal(item_to_insert, COMSIG_PARENT_QDELETING, PROC_REF(check_tub_contents))
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
	if(LAZYLEN(inserted_items))
		for(var/obj/item/I in inserted_items)
			if(QDELETED(I) || I.loc != src)
				LAZYREMOVE(inserted_items, I)
	if(LAZYLEN(inserted_mobs))
		for(var/mob/living/L in inserted_mobs)
			if(QDELETED(L) || L.loc != src)
				LAZYREMOVE(inserted_mobs, L)
	for(var/obj/item/I in contents)
		if(!LAZYIN(inserted_items, I))
			LAZYADD(inserted_items, I)
	for(var/mob/living/L in contents)
		if(!LAZYIN(inserted_mobs, L))
			LAZYADD(inserted_mobs, L)
	calculate_tub_capacity()
	update_washing_state()

/// Moves all Items/Mobs out of the laundry machine onto the Washing Machine's Loc, unregisters signals, then nulls the tracking lists
/obj/machinery/washing_machine/proc/eject_tub_contents()
	if(bloody_mess)
		playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
	if(LAZYLEN(inserted_items))
		for(var/obj/item/I in inserted_items)
			if(bloody_mess)
				I.add_blood() // what a mess!
			I.forceMove(loc)
			UnregisterSignal(I, COMSIG_PARENT_QDELETING)
		LAZYNULL(inserted_items)
	if(LAZYLEN(inserted_mobs))
		for(var/mob/living/L in inserted_items)
			L.forceMove(loc)
			UnregisterSignal(L, COMSIG_PARENT_QDELETING)
		LAZYNULL(inserted_mobs)
	calculate_tub_capacity()
	update_washing_state()

/// Calculates the total capacity of the contents of the tub,
/obj/machinery/washing_machine/proc/calculate_tub_capacity()
	var/new_capacity = 0
	if(LAZYLEN(inserted_items))
		for(var/obj/item/I in inserted_items)
			I += I.w_class
	if(LAZYLEN(inserted_mobs))
		for(var/mob/living/L in inserted_items)
			new_capacity += L.mob_size * 2
	current_tub_capacity = new_capacity

/obj/machinery/washing_machine/proc/toggle_door()
	door_open = !door_open
	update_washing_state()
	if(door_open)
		eject_tub_contents()
		return

/// Attempts to locate stamps or crayons for dyeing purposes
/obj/machinery/washing_machine/proc/locate_color_source()
	var/list/color_sources = list()
	for(var/obj/item/toy/crayon/C in contents)
		color_sources += C
	for(var/obj/item/stamp/S in contents)
		color_sources += S
	color_source = pick(color_sources)
	if(istype(color_source, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C
		wash_color = C.dye_color
	if(istype(color_source, /obj/item/stamp))
		var/obj/item/stamp/S
		wash_color = S.dye_color

/obj/machinery/washing_machine/proc/start_wash_cycle()
	locate_color_source()
	washing = TRUE
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	sleep(1 SECONDS)
	update_washing_state()
	use_power(100)
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(wash_cycle)), 15 SECONDS)

/obj/machinery/washing_machine/proc/wash_cycle()
	for(var/atom/movable/AM in contents)
		AM.machine_wash(src)

	update_washing_state()
	use_power(50 * current_tub_capacity)
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(end_wash_cycle)), 15 SECONDS)

/obj/machinery/washing_machine/proc/end_wash_cycle()
	if(color_source)
		qdel(color_source)
		color_source = null
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
	washing = FALSE
	sleep(1 SECONDS)
	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	update_washing_state()

/obj/machinery/washing_machine/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	if(I.tool_behaviour != TOOL_SCREWDRIVER)
		return FALSE
	if(!I.use_tool(src, user, 0, volume = 0))
		return FALSE
	if(!panel_open)
		panel_open = TRUE
		to_chat(user, "<span class='notice'>You open the maintenance hatch of [src].</span>")
	else
		panel_open = FALSE
		to_chat(user, "<span class='notice'>You close the maintenance hatch of [src].</span>")
		I.play_tool_sound(user, I.tool_volume)
	update_icon_state(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/washing_machine/deconstruct(disassembled = TRUE)
	eject_tub_contents()
	new /obj/item/stack/sheet/metal(drop_location(), 2)
	if(washing)
		chem_splash(loc, 3, list("water"))
	qdel(src)

/obj/machinery/washing_machine/cleaning_act(mob/user, atom/cleaner, cleanspeed, text_verb, text_description, text_targetname)
	bloody_mess = FALSE
	return ..()

/obj/item/clothing/machine_wash(obj/machinery/washing_machine/washer)
	if(washer.color_source)
		dye_item(washer.wash_color)

/obj/item/bedsheet/machine_wash(obj/machinery/washing_machine/washer)
	if(washer.color_source)
		dye_item(washer.wash_color)

/obj/item/holder/machine_wash(obj/machinery/washing_machine/washer)
	. = ..()
	for(var/mob/living/held_mob in contents)
		held_mob.machine_wash(washer)

/obj/item/stack/sheet/hairlesshide/machine_wash(obj/machinery/washing_machine/washer)
	new /obj/item/stack/sheet/wetleather(loc, amount)
	qdel(src)

/mob/living/basic/pet/machine_wash(obj/machinery/washing_machine/washer)
	washer.bloody_mess = TRUE
	add_attack_logs(washer, src, "gibbed by washing machine")
	gib()
