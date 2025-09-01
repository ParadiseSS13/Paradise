/*
	* # Slime Management Console
	*
	* Camera overview console for xenobiology, handles slime management and xenobio actions
*/
/obj/machinery/computer/camera_advanced/xenobio
	name = "slime management console"
	desc = "A computer used for remotely handling slimes."
	icon_screen = "slime_comp"
	icon_keyboard = "rd_key"
	networks = list("SS13")
	circuit = /obj/item/circuitboard/xenobiology


	var/datum/action/innate/slime_place/slime_place_action = new
	var/datum/action/innate/slime_pick_up/slime_up_action = new
	var/datum/action/innate/feed_slime/feed_slime_action = new
	var/datum/action/innate/monkey_recycle/monkey_recycle_action = new
	var/datum/action/innate/slime_scan/scan_action = new
	var/datum/action/innate/feed_potion/potion_action = new
	var/datum/action/innate/hotkey_help/hotkey_help = new

	var/list/stored_slimes = list()
	var/max_slimes = 6
	var/monkeys = 0
	var/obj/item/slimepotion/slime/current_potion
	var/obj/machinery/monkey_recycler/connected_recycler

/obj/machinery/computer/camera_advanced/xenobio/Initialize(mapload)
	. = ..()
	if(!connected_recycler)
		locate_recycler()

/obj/machinery/computer/camera_advanced/xenobio/CreateEye()
	eyeobj = new /mob/camera/eye/xenobio(loc, name, src, current_user)
	give_eye_control(current_user)

/obj/machinery/computer/camera_advanced/xenobio/proc/locate_recycler()
	for(var/obj/machinery/monkey_recycler/recycler in GLOB.monkey_recyclers)
		if(get_area(recycler) == get_area(loc))
			connected_recycler = recycler
			connected_recycler.connected |= src
			break

/obj/machinery/computer/camera_advanced/xenobio/Destroy()
	QDEL_NULL(current_potion)
	for(var/thing in stored_slimes)
		var/mob/living/simple_animal/slime/S = thing
		S.forceMove(drop_location())
	stored_slimes.Cut()
	if(connected_recycler)
		connected_recycler.connected -= src
	connected_recycler = null
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/handle_atom_del(atom/A)
	if(A == current_potion)
		current_potion = null
	if(A in stored_slimes)
		stored_slimes -= A
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/GrantActions(mob/living/carbon/user)
	..()

	if(slime_up_action)
		slime_up_action.target = src
		slime_up_action.Grant(user)
		actions += slime_up_action

	if(slime_place_action)
		slime_place_action.target = src
		slime_place_action.Grant(user)
		actions += slime_place_action

	if(feed_slime_action)
		feed_slime_action.target = src
		feed_slime_action.Grant(user)
		actions += feed_slime_action

	if(monkey_recycle_action)
		monkey_recycle_action.target = src
		monkey_recycle_action.Grant(user)
		actions += monkey_recycle_action

	if(scan_action)
		scan_action.target = src
		scan_action.Grant(user)
		actions += scan_action

	if(potion_action)
		potion_action.target = src
		potion_action.Grant(user)
		actions += potion_action

	if(hotkey_help)
		hotkey_help.target = src
		hotkey_help.Grant(user)
		actions += hotkey_help

	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_CTRL, PROC_REF(XenoSlimeClickCtrl))
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_ALT, PROC_REF(XenoSlimeClickAlt))
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT, PROC_REF(XenoSlimeClickShift))
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT, PROC_REF(XenoTurfClickShift))
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_CTRL, PROC_REF(XenoTurfClickCtrl))
	RegisterSignal(user, COMSIG_XENO_MONKEY_CLICK_CTRL, PROC_REF(XenoMonkeyClickCtrl))

	if(!connected_recycler)
		locate_recycler()

/obj/machinery/computer/camera_advanced/xenobio/remove_eye_control(mob/living/user)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_CTRL)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_ALT)
	UnregisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT)
	UnregisterSignal(user, COMSIG_XENO_TURF_CLICK_CTRL)
	UnregisterSignal(user, COMSIG_XENO_MONKEY_CLICK_CTRL)
	..()

/obj/machinery/computer/camera_advanced/xenobio/proc/insert_potion(obj/item/slimepotion/slime/potion)
	clear_potion()
	potion.forceMove(src)
	current_potion = potion
	RegisterSignal(current_potion, COMSIG_PARENT_QDELETING, PROC_REF(clear_potion))

/obj/machinery/computer/camera_advanced/xenobio/proc/clear_potion()
	if(!QDELETED(current_potion))
		current_potion.forceMove(drop_location())
		UnregisterSignal(current_potion, COMSIG_PARENT_QDELETING)
	current_potion = null

/obj/machinery/computer/camera_advanced/xenobio/proc/capture_slime(mob/living/simple_animal/slime/slime)
	slime.visible_message("<span class='notice'>[slime] vanishes in a flash of light!</span>")
	slime.forceMove(src)
	stored_slimes += slime
	RegisterSignal(slime, COMSIG_PARENT_QDELETING, PROC_REF(clear_slime))

/obj/machinery/computer/camera_advanced/xenobio/proc/release_slime(mob/living/simple_animal/slime/slime, release_spot)
	slime.visible_message("<span class='notice'>[slime] warps in!</span>")
	clear_slime(slime)
	slime.forceMove(release_spot)

/obj/machinery/computer/camera_advanced/xenobio/proc/clear_slime(mob/living/simple_animal/slime/slime)
	UnregisterSignal(slime, COMSIG_PARENT_QDELETING)
	stored_slimes -= slime

/obj/machinery/computer/camera_advanced/xenobio/attack_hand(mob/user)
	if(!ishuman(user)) //AIs using it might be weird
		return
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/food/monkeycube))
		if(user.drop_item())
			monkeys++
			to_chat(user, "<span class='notice'>You feed [used] to [src]. It now has [monkeys] monkey cubes stored.</span>")
			qdel(used)
		return ITEM_INTERACT_COMPLETE
	else if(istype(used, /obj/item/slimepotion/slime))
		if(!user.drop_item())
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You load [used] in the console's potion slot[current_potion ? ", replacing the one that was there before" : ""].</span>")
		insert_potion(used, user)
		return ITEM_INTERACT_COMPLETE
	else if(istype(used, /obj/item/storage/bag) || istype(used, /obj/item/storage/box))
		var/obj/item/storage/P = used
		var/loaded = 0
		for(var/obj/item/food/monkeycube/MC in P.contents)
			loaded = 1
			monkeys++
			P.remove_from_storage(MC)
			qdel(MC)
		if(loaded)
			to_chat(user, "<span class='notice'>You fill [src] with the monkey cubes stored in [used]. [src] now has [monkeys] monkey cubes stored.</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/computer/camera_advanced/xenobio/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	if(istype(M.buffer, /obj/machinery/monkey_recycler))
		connected_recycler = M.buffer
		connected_recycler.connected += src
		to_chat(user, "<span class='notice'>You link [src] to the recycler stored in [M]'s buffer.</span>")

// === SLIME ACTION DATUMS ====
/datum/action/innate/slime_place
	name = "Place Slimes"
	button_icon_state = "slime_down"

/datum/action/innate/slime_place/Activate()
	if(!target || !ishuman(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/eye/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(iswallturf(remote_eye.loc))
		to_chat(owner, "You can't place slime here.")
		return
	else if(GLOB.cameranet.check_turf_vis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in X.stored_slimes)
			X.release_slime(S, remote_eye.loc)
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/innate/slime_pick_up
	name = "Pick up Slime"
	button_icon_state = "slime_up"

/datum/action/innate/slime_pick_up/Activate()
	if(!target || !ishuman(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/eye/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(GLOB.cameranet.check_turf_vis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			if(length(X.stored_slimes) >= X.max_slimes)
				break
			if(!S.ckey)
				if(S.buckled)
					S.Feedstop(silent = TRUE)
				X.capture_slime(S)
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/innate/feed_slime
	name = "Feed Slimes"
	button_icon_state = "monkey_down"

/datum/action/innate/feed_slime/Activate()
	if(!target || !ishuman(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/eye/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target
	var/obj/machinery/monkey_recycler/recycler = X.connected_recycler

	if(GLOB.cameranet.check_turf_vis(remote_eye.loc))
		if(LAZYLEN(SSmobs.cubemonkeys) >= GLOB.configuration.general.monkey_cube_cap)
			to_chat(owner, "<span class='warning'>Bluespace harmonics prevent the spawning of more than [GLOB.configuration.general.monkey_cube_cap] monkeys on the station at one time!</span>")
			return
		else if(iswallturf(remote_eye.loc))
			to_chat(owner, "You can't place monkey here.")
			return
		else if(!X.monkeys)
			to_chat(owner, "[X] doesn't have monkeys.")
			return
		else if(X.monkeys >= 1)
			var/mob/living/carbon/human/monkey/food
			switch(recycler.cube_type)
				if(/obj/item/food/monkeycube) 										// Regular monkey
					food = new /mob/living/carbon/human/monkey(remote_eye.loc)
				if(/obj/item/food/monkeycube/nian_wormecube) 						// Worme
					food = new /mob/living/carbon/human/nian_worme(remote_eye.loc)
				if(/obj/item/food/monkeycube/farwacube) 								// Farwa
					food = new /mob/living/carbon/human/farwa(remote_eye.loc)
				if(/obj/item/food/monkeycube/stokcube) 								// Stok
					food = new /mob/living/carbon/human/stok(remote_eye.loc)
				if(/obj/item/food/monkeycube/neaeracube) 							// Neara
					food = new /mob/living/carbon/human/neara(remote_eye.loc)
				if(/obj/item/food/monkeycube/wolpincube) 							// Wolpin
					food = new /mob/living/carbon/human/wolpin(remote_eye.loc)
			SSmobs.cubemonkeys += food
			X.monkeys --
			to_chat(owner, "[X] now has [X.monkeys] monkeys left.")
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/innate/monkey_recycle
	name = "Recycle Monkeys"
	button_icon_state = "monkey_up"

/datum/action/innate/monkey_recycle/Activate()
	if(!target || !ishuman(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/eye/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target
	var/obj/machinery/monkey_recycler/recycler = X.connected_recycler

	if(!recycler)
		to_chat(owner, "<span class='notice'>There is no connected monkey recycler.  Use a multitool to link one.</span>")
		return
	if(GLOB.cameranet.check_turf_vis(remote_eye.loc))
		for(var/mob/living/carbon/human/M in remote_eye.loc)
			if(issmall(M) && M.stat)
				M.visible_message("[M] vanishes as [M.p_theyre()] reclaimed for recycling!")
				recycler.use_power(500)
				X.monkeys = round(X.monkeys + recycler.cube_production / recycler.required_grind, 0.1)
				qdel(M)
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/innate/slime_scan
	name = "Scan Slime"
	button_icon_state = "slime_scan"

/datum/action/innate/slime_scan/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/C = owner
	var/mob/camera/eye/xenobio/remote_eye = C.remote_control

	if(GLOB.cameranet.check_turf_vis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			slime_scan(S, C)
	else
		to_chat(owner, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/innate/feed_potion
	name = "Apply Potion"
	button_icon_state = "slime_potion"

/datum/action/innate/feed_potion/Activate()
	if(!target || !ishuman(owner))
		return

	var/mob/living/carbon/human/C = owner
	var/mob/camera/eye/xenobio/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = target

	if(QDELETED(X.current_potion))
		to_chat(owner, "<span class='warning'>No potion loaded.</span>")
		return

	if(GLOB.cameranet.check_turf_vis(remote_eye.loc))
		for(var/mob/living/simple_animal/slime/S in remote_eye.loc)
			X.current_potion.interact_with_atom(S, C)
			break
	else
		to_chat(owner, "<span class='notice'>Target is not near a camera. Cannot proceed.</span>")

/datum/action/innate/hotkey_help
	name = "Hotkey Help"
	button_icon_state = "hotkey_help"

/datum/action/innate/hotkey_help/Activate()
	if(!target || !isliving(owner))
		return
	var/obj/machinery/computer/camera_advanced/xenobio/console = target
	to_chat(owner, "<b>Click shortcuts:</b>")
	to_chat(owner, "Shift-click a slime to pick it up, or the floor to drop all held slimes.")
	to_chat(owner, "Ctrl-click a slime to scan it.")
	to_chat(owner, "Alt-click a slime to feed it a potion.")
	to_chat(owner, "Ctrl-click or a dead monkey to recycle it, or the floor to place a new monkey.")
	to_chat(owner, "[console] now has [console.monkeys] monkey\s left.")

//
// Alternate clicks for slime, monkey and open turf if using a xenobio console

// Scans slime
/mob/living/simple_animal/slime/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_CTRL, src)
	..()

//Feeds a potion to slime
/mob/living/simple_animal/slime/AltClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_ALT, src)
	..()

//Picks up slime
/mob/living/simple_animal/slime/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_SHIFT, src)
	..()

//Place slimes
/turf/simulated/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_SHIFT, src)
	..()

//Place monkey
/turf/simulated/CtrlClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_CTRL, src)
	..()

//Pick up monkey
/mob/living/carbon/human/CtrlClick(mob/user)
	if(issmall(src))
		SEND_SIGNAL(user, COMSIG_XENO_MONKEY_CLICK_CTRL, src)
	..()

// Scans slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickCtrl(mob/living/user, mob/living/simple_animal/slime/S)
	if(!GLOB.cameranet.check_turf_vis(S.loc))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return
	var/mob/living/C = user
	var/mob/camera/eye/xenobio/E = C.remote_control
	var/area/mobarea = get_area(S.loc)
	if(mobarea.name == E.allowed_area || mobarea.xenobiology_compatible)
		slime_scan(S, C)

//Feeds a potion to slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickAlt(mob/living/user, mob/living/simple_animal/slime/S)
	if(!GLOB.cameranet.check_turf_vis(S.loc))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return
	var/mob/living/C = user
	var/mob/camera/eye/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(S.loc)
	if(!X.current_potion)
		to_chat(C, "<span class='warning'>No potion loaded.</span>")
		return
	if(mobarea.name == E.allowed_area || mobarea.xenobiology_compatible)
		X.current_potion.interact_with_atom(S, C)

//Picks up slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickShift(mob/living/user, mob/living/simple_animal/slime/S)
	if(!GLOB.cameranet.check_turf_vis(S.loc))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return
	var/mob/living/C = user
	var/mob/camera/eye/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(S.loc)
	if(mobarea.name == E.allowed_area || mobarea.xenobiology_compatible)
		if(length(X.stored_slimes) >= X.max_slimes)
			to_chat(C, "<span class='warning'>Slime storage is full.</span>")
			return
		if(S.ckey)
			to_chat(C, "<span class='warning'>The slime wiggled free!</span>")
			return
		if(S.buckled)
			S.Feedstop(silent = TRUE)

		X.capture_slime(S)

//Place slimes
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickShift(mob/living/user, turf/T)
	if(!GLOB.cameranet.check_turf_vis(T))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return
	var/mob/living/C = user
	var/mob/camera/eye/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/turfarea = get_area(T)
	if(iswallturf(T))
		to_chat(user, "You can't place slime here.")
		return
	else if(turfarea.name == E.allowed_area || turfarea.xenobiology_compatible)
		for(var/mob/living/simple_animal/slime/S in X.stored_slimes)
			X.release_slime(S, T)

//Place monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickCtrl(mob/living/user, turf/T)
	if(!GLOB.cameranet.check_turf_vis(T))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return
	var/mob/living/C = user
	var/mob/camera/eye/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/obj/machinery/monkey_recycler/recycler = X.connected_recycler
	var/area/turfarea = get_area(T)
	if(!recycler)
		to_chat(C, "<span class='notice'>There is no connected monkey recycler. Use a multitool to link one.</span>")
		return
	if(iswallturf(T))
		to_chat(user, "You can't place monkey here.")
		return
	else if(turfarea.name == E.allowed_area || turfarea.xenobiology_compatible)
		if(X.monkeys >= 1)
			switch(recycler.cube_type)
				if(/obj/item/food/monkeycube) 										// Regular monkey
					new /mob/living/carbon/human/monkey(T)
				if(/obj/item/food/monkeycube/nian_wormecube) 						// Worme
					new /mob/living/carbon/human/nian_worme(T)
				if(/obj/item/food/monkeycube/farwacube) 								// Farwa
					new /mob/living/carbon/human/farwa(T)
				if(/obj/item/food/monkeycube/stokcube) 								// Stok
					new /mob/living/carbon/human/stok(T)
				if(/obj/item/food/monkeycube/neaeracube) 							// Neara
					new /mob/living/carbon/human/neara(T)
				if(/obj/item/food/monkeycube/wolpincube) 							// Wolpin
					new /mob/living/carbon/human/wolpin(T)
			X.monkeys--
			X.monkeys = round(X.monkeys, 0.1)
			to_chat(user, "[X] now has [X.monkeys] monkeys left.")

//Pick up monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoMonkeyClickCtrl(mob/living/user, mob/living/carbon/human/M)
	if(!GLOB.cameranet.check_turf_vis(M.loc))
		to_chat(user, "<span class='warning'>Target is not near a camera. Cannot proceed.</span>")
		return
	var/mob/living/C = user
	var/mob/camera/eye/xenobio/E = C.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/X = E.origin
	var/area/mobarea = get_area(M.loc)
	var/obj/machinery/monkey_recycler/recycler = X.connected_recycler
	if(!recycler)
		to_chat(C, "<span class='notice'>There is no connected monkey recycler.  Use a multitool to link one.</span>")
		return
	if(mobarea.name == E.allowed_area || mobarea.xenobiology_compatible)
		if(issmall(M) && M.stat)
			M.visible_message("[M] vanishes as [M.p_theyre()] reclaimed for recycling!")
			recycler.use_power(500)
			X.monkeys = round(X.monkeys + recycler.cube_production/recycler.required_grind, 0.1)
			qdel(M)
