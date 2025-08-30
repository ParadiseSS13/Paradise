/* holograms!
 * Contains:
 *		Holopad
 *		hologram
 *		Other stuff
 */

/*
Revised. Original based on space ninja hologram code. Which is also mine. /N
How it works:
AI clicks on holopad in camera view. View centers on holopad.
AI clicks again on the holopad to display a hologram. hologram stays as long as AI is looking at the pad and it (the hologram) is in range of the pad.
AI can use the directional keys to move the hologram around, provided the above conditions are met and the AI in question is the holopad's master.
Only one AI may project from a holopad at any given time.
AI may cancel the hologram at any time by clicking on the holopad once more.
Possible to do for anyone motivated enough:
	Give an AI variable for different hologram icons.
	Itegrate EMP effect to disable the unit.
*/


/*
 * Holopad
 */

// HOLOPAD MODE
// 0 = RANGE BASED
// 1 = AREA BASED
#define HOLOPAD_PASSIVE_POWER_USAGE 1
#define HOLOGRAM_POWER_USAGE 2
#define RANGE_BASED 0
#define AREA_BASED 1

#define HOLOPAD_MODE RANGE_BASED

GLOBAL_LIST_EMPTY(holopads)

/**
 * A stationary holopad for projecting hologram and making and receiving holocalls.
 *
 * Holopads are floor-plane machines similar, in appearance and interactive function, to quantum pads. They can be
 * used by crew members to make and answer holocalls, or by the AI to project holograms autonomously.
 *
 * Holopads are machines which can project a hologram up to `holo_range` tiles away. They do this in one of two modes:
 * holocalls, and AI holograms. Holocalls require a user to stand on a holopad, use its menu to select a remote holopad,
 * and make a call. Holocalls must be answered by the receiving holopad, or they will fail. Holopads can be configured
 * globally to auto-accept instead of failing, with the debug static variable `force_answer_call`. They can also be
 * individually configured to auto-accept calls immediately by setting their public mode option (`public_mode`),
 * which can be done in-game by using a screwdriver and then a multitool on a holopad. Holocalls will automatically end
 * if power goes out, the caller moves off the calling holopad, the caller projects outside the receiving holopad's
 * range, the caller is killed or incapacitated, the caller ghosts or disconnects, or the caller is QDELETED. AI
 * holograms require the AI to focus on the originating holopad and click on it; no answer is required. If the AI moves
 * out of a holopad's range and into the range of another, it will attempt to transfer its hologram to the next holopad.
 * Otherwise, AI holograms will stop projecting if power goes out for the originating holopad, the AI clicks on its
 * origin holopad, or, like holocalls, if the AI is killed, incapacitated, disconnected, QDELETED, or ghosts.
 * Holopads relay speech from the caller made with the :h radio key, and relay all speech on the answering end to the
 * caller or AI.
 */

/obj/machinery/hologram/holopad
	name = "holopad"
	desc = "It's a floor-mounted device for projecting holographic images."
	icon_state = "holopad0"
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 100
	layer = HOLOPAD_LAYER //Preventing mice and drones from sneaking under them.
	plane = FLOOR_PLANE
	max_integrity = 300
	armor = list(MELEE = 50, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, RAD = 0, FIRE = 50, ACID = 0)

	/// List of living mobs currently using the holopad
	var/list/masters = list()
	/// Holoray-mob link.
	var/list/holorays = list()
	/// Last request time, to prevent request spam. ~Carn
	var/last_request = 0
	/// The range, in tiles, that a holopad can project a hologram.
	var/holo_range = 5
	var/temp = ""
	/// A list of holocalls associated with this holopad.
	var/list/holo_calls
	/// The outgoing holocall currently being processed by this holopad.
	var/datum/holocall/outgoing_call
	/// Universal debug toggle for whether holopads will automatically answer calls after a few rings.
	var/static/force_answer_call = FALSE
	/// Toggle for auto-answering calls immediately, set via multitool.
	var/public_mode = FALSE
	/// The ray effect emanating from this holopad to the produced hologram.
	var/obj/effect/overlay/holoray/ray
	/// Whether or not this holopad is currently ringing, from being called by another pad.
	var/ringing = FALSE
	/// Whether or not the user is currently selecting where to send their call.
	var/dialling_input = FALSE
	var/mob/camera/eye/hologram/eye

/obj/machinery/hologram/holopad/Initialize(mapload)
	. = ..()
	GLOB.holopads += src
	component_parts = list()
	component_parts += new /obj/item/circuitboard/holopad(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/hologram/holopad/Destroy()
	if(outgoing_call)
		outgoing_call.ConnectionFailure(src)

	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		HC.ConnectionFailure(src)

	for(var/I in masters)
		clear_holo(I)
	GLOB.holopads -= src
	return ..()

/obj/machinery/hologram/holopad/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		if(outgoing_call)
			outgoing_call.ConnectionFailure(src)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/hologram/holopad/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	var/total_users = LAZYLEN(masters) + LAZYLEN(holo_calls)
	if(ringing)
		underlays += emissive_appearance(icon, "holopad_ringing_lightmask")
	else if(total_users)
		underlays += emissive_appearance(icon, "holopad1_lightmask")

/obj/machinery/hologram/holopad/obj_break()
	. = ..()
	if(outgoing_call)
		outgoing_call.ConnectionFailure(src)

/obj/machinery/hologram/holopad/RefreshParts()
	var/holograph_range = 4
	for(var/obj/item/stock_parts/capacitor/B in component_parts)
		holograph_range += 1 * B.rating
	holo_range = holograph_range

/obj/machinery/hologram/holopad/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	public_mode = !public_mode
	to_chat(user, "<span class='notice'>You [public_mode ? "enable" : "disable"] the holopad's public mode setting.</span>")

/obj/machinery/hologram/holopad/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "holopad_open", "holopad0", I)


/obj/machinery/hologram/holopad/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/hologram/holopad/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/hologram/holopad/attack_hand(mob/living/carbon/human/user)
	if(..())
		return

	if(outgoing_call)
		return

	if(user.a_intent != INTENT_HELP)
		return

	user.set_machine(src)
	interact(user)

/obj/machinery/hologram/holopad/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Its maintenance panel can be <b>screwed [panel_open ? "closed" : "open"]</b>.</span>"
	. += "<span class='notice'>Its public mode indicator reads <b>[public_mode ? "on" : "off"]</b>. It can be <b>turned [public_mode ? "off" : "on"]</b> by using a multitool while the maintenance panel is open.</span>"

/obj/machinery/hologram/holopad/AltClick(mob/living/carbon/human/user)
	if(..())
		return
	if(is_ai(user))
		hangup_all_calls()
		return

//Stop ringing the AI!!
/obj/machinery/hologram/holopad/proc/hangup_all_calls()
	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		HC.Disconnect(src)

/obj/machinery/hologram/holopad/interact(mob/living/user)
	if(!istype(user))
		return
	if(!anchored)
		return

	var/dat
	if(temp)
		dat = temp
	else
		dat = "<a href='byond://?src=[UID()];AIrequest=1'>Request an AI's presence.</a><br>"
		dat += "<a href='byond://?src=[UID()];Holocall=1'>Call another holopad.</a><br>"

		if(LAZYLEN(holo_calls))
			dat += "=====================================================<br>"

		var/one_answered_call = FALSE
		var/one_unanswered_call = FALSE
		for(var/I in holo_calls)
			var/datum/holocall/HC = I
			if(HC.connected_holopad != src)
				dat += "<a href='byond://?src=[UID()];connectcall=[HC.UID()]'>Answer call from [get_area(HC.calling_holopad)].</a><br>"
				one_unanswered_call = TRUE
			else
				one_answered_call = TRUE

		if(one_answered_call && one_unanswered_call)
			dat += "=====================================================<br>"
		//we loop twice for formatting
		for(var/I in holo_calls)
			var/datum/holocall/HC = I
			if(HC.connected_holopad == src)
				dat += "<a href='byond://?src=[UID()];disconnectcall=[HC.UID()] '>Disconnect call from [HC.user].</a><br>"

	var/area/area = get_area(src)
	var/datum/browser/popup = new(user, "holopad", "[area] holopad", 400, 300)
	popup.set_content(dat)
	popup.open()

/obj/machinery/hologram/holopad/Topic(href, href_list)
	if(..() || is_ai(usr))
		return
	add_fingerprint(usr)
	if(stat & NOPOWER)
		return
	if(href_list["AIrequest"])
		if(last_request + 200 < world.time)
			last_request = world.time
			temp = "You requested an AI's presence.<br>"
			temp += "<a href='byond://?src=[UID()];mainmenu=1'>Main Menu</a>"
			var/area/area = get_area(src)
			for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
				if(!AI.client)
					continue
				to_chat(AI, "<span class='notice'>Your presence is requested at <a href='byond://?src=[AI.UID()];jumptoholopad=[UID()]'>\the [area]</a>.</span>")
		else
			temp = "A request for AI presence was already sent recently.<br>"
			temp += "<a href='byond://?src=[UID()];mainmenu=1'>Main Menu</a>"

	else if(href_list["Holocall"])
		if(outgoing_call)
			return
		if(dialling_input)
			to_chat(usr, "<span class='notice'>Finish dialling first!</span>")
			return
		temp = "You must stand on the holopad to make a call!<br>"
		temp += "<a href='byond://?src=[UID()];mainmenu=1'>Main Menu</a>"
		if(usr.loc == loc)
			var/list/callnames = list()
			for(var/I in GLOB.holopads)
				var/area/A = get_area(I)
				if(A)
					LAZYADD(callnames[A], I)
			callnames -= get_area(src)
			var/list/sorted_callnames = sortAtom(callnames)
			dialling_input = TRUE
			var/result = tgui_input_list(usr, "Choose an area to call", "Holocall", sorted_callnames)
			dialling_input = FALSE
			if(QDELETED(usr) || !result || outgoing_call)
				return

			if(usr.loc == loc)
				temp = "Dialing...<br>"
				temp += "<a href='byond://?src=[UID()];mainmenu=1'>Main Menu</a>"
				new /datum/holocall(usr, src, callnames[result])

	else if(href_list["connectcall"])
		var/datum/holocall/call_to_connect = locateUID(href_list["connectcall"])
		if(!QDELETED(call_to_connect) && (call_to_connect in holo_calls))
			call_to_connect.Answer(src)
		temp = ""

	else if(href_list["disconnectcall"])
		var/datum/holocall/call_to_disconnect = locateUID(href_list["disconnectcall"])
		if(!QDELETED(call_to_disconnect))
			call_to_disconnect.Disconnect(src)
		temp = ""

	else if(href_list["mainmenu"])
		temp = ""
		if(outgoing_call)
			outgoing_call.Disconnect()

	updateDialog()

// do not allow AIs to answer calls or people will use it to meta the AI satellite
/obj/machinery/hologram/holopad/attack_ai(mob/living/silicon/ai_or_robot)
	if(outgoing_call)
		return

	if(isrobot(ai_or_robot))
		interact(ai_or_robot)
		return
	if(!is_ai(ai_or_robot))
		return
	if(is_mecha_occupant(ai_or_robot)) // AIs must exit mechs before activating holopads.
		return

	var/mob/living/silicon/ai/ai = ai_or_robot
	if(ai.eyeobj.loc != loc) // Set client eye on the object if it's not already.
		ai.eyeobj.set_loc(get_turf(src))
	else if(!LAZYLEN(masters) || !masters[ai]) // If there is no hologram, possibly make one.
		activate_holo(ai, TRUE)
	else // If there is a hologram, remove it.
		clear_holo(ai)

/obj/machinery/hologram/holopad/process()
	for(var/I in masters)
		var/mob/living/master = I
		if((stat & NOPOWER) || !validate_user(master) || !anchored)
			clear_holo(master)

	if(outgoing_call)
		outgoing_call.Check()

	ringing = FALSE

	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		//Sanity check and skip if no longer valid call
		if(!HC.Check())
			atom_say("Call was terminated at remote terminal.")
			continue

		if(HC.connected_holopad != src)
			if((force_answer_call && world.time > (HC.call_start_time + (HOLOPAD_MAX_DIAL_TIME / 2))) || public_mode)
				HC.Answer(src)
				break
			if(outgoing_call)
				HC.Disconnect(src)//can't answer calls while calling
			else
				playsound(src, 'sound/machines/twobeep.ogg', 100)	//bring, bring!
				ringing = TRUE

	update_icon(UPDATE_ICON_STATE)


//Try to transfer hologram to another pad that can project on T
/obj/machinery/hologram/holopad/proc/transfer_to_nearby_pad(turf/T, mob/holo_owner)
	if(!is_ai(holo_owner))
		return
	for(var/pad in GLOB.holopads)
		var/obj/machinery/hologram/holopad/another = pad
		if(another == src)
			continue
		if(T.loc != get_area(another))
			continue
		if(another.validate_location(T, holo_owner))
			var/obj/effect/overlay/holo_pad_hologram/h = masters[holo_owner]
			unset_holo(holo_owner)
			another.set_holo(holo_owner, h)
			return TRUE
	return FALSE

/obj/machinery/hologram/holopad/proc/validate_user(mob/living/user)
	if(QDELETED(user) || user.incapacitated() || !user.client)
		return FALSE

	if(is_ai(user))
		var/mob/living/silicon/ai/AI = user
		if(!AI.current)
			return FALSE
	return TRUE

//Can we display holos there
/obj/machinery/hologram/holopad/proc/validate_location(turf/T, mob/living/user)
	if(!is_ai(user) && T.loc != get_area(src)) //For AI, the area check is done on trying to find another holopad instead
		return FALSE
	if(T.z == z && (get_dist(T, src) <= holo_range))
		return TRUE
	return FALSE


/obj/machinery/hologram/holopad/proc/move_hologram(mob/living/user, turf/new_turf)
	if(masters[user])
		var/obj/effect/overlay/holo_pad_hologram/holo = masters[user]
		var/transfered = FALSE
		if(!validate_location(new_turf, user))
			if(!transfer_to_nearby_pad(new_turf,user))
				clear_holo(user)
				return FALSE
			else
				transfered = TRUE
		//All is good.
		holo.setDir(get_dir(holo.loc, new_turf))
		holo.forceMove(new_turf)
		if(!transfered)
			update_holoray(user,new_turf)
	return TRUE

/obj/machinery/hologram/holopad/proc/activate_holo(mob/living/user, force = 0)
	var/mob/living/silicon/ai/AI = user
	if(!istype(AI))
		AI = null
	if(AI && !force && AI.eyeobj.loc != loc) // allows holopads to pass off holograms to the next holopad in the chain
		to_chat(user, "<font color='red'>ERROR:</font> Unable to project hologram.")
	if(!(stat & NOPOWER) && (!AI || force))
		if(AI && (istype(AI.current, /obj/machinery/hologram/holopad)))
			to_chat(user, "<span class='danger'>ERROR:</span> Image feed in progress.")
			return

		var/obj/effect/overlay/holo_pad_hologram/hologram = new(loc)//Spawn a blank effect at the location.
		if(is_ai(user))
			hologram.icon = AI.holo_icon
		else	//make it like real life
			if(isrobot(user))
				var/mob/living/silicon/robot/robot = user
				hologram.icon = getHologramIcon(icon(robot.icon))
				hologram.icon_state = robot.icon_state
			else
				hologram.icon = getHologramIcon(get_id_photo(user))
				hologram.icon_state = user.icon_state
			hologram.alpha = 100
			hologram.Impersonation = user

		hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT //So you can't click on it.
		hologram.layer = FLY_LAYER //Above all the other objects/mobs. Or the vast majority of them.
		hologram.anchored = TRUE //So space wind cannot drag it.
		hologram.name = "[user.name] (hologram)" //If someone decides to right click.
		hologram.set_light(2)	//hologram lighting
		move_hologram()

		eye = new /mob/camera/eye/hologram(src, user.name, src, user)
		set_holo(user, hologram)

		if(!masters[user])//If there is not already a hologram.
			visible_message("A holographic image of [user] flicks to life right before your eyes!")

		return hologram


	to_chat(user, "<span class='danger'>ERROR:</span> Hologram Projection Malfunction.")
	clear_holo(user)//safety check

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/hologram/holopad/hear_talk(atom/movable/speaker, list/message_pieces, verb)
	if(speaker && length(masters))//Master is mostly a safety in case lag hits or something. Radio_freq so AIs dont hear holopad stuff through radios.
		for(var/mob/living/silicon/ai/master in masters)
			if(masters[master] && speaker != master)
				master.relay_speech(speaker, message_pieces, verb)

	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		if(HC.connected_holopad == src && speaker != HC.hologram)
			HC.user.hear_say(message_pieces, verb, speaker = speaker)

	if(outgoing_call && speaker == outgoing_call.user)
		outgoing_call.hologram.atom_say(multilingual_to_message(message_pieces))



/obj/machinery/hologram/holopad/proc/SetLightsAndPower()
	var/total_users = length(masters) + LAZYLEN(holo_calls)
	change_power_mode(total_users > 0 ? ACTIVE_POWER_USE : IDLE_POWER_USE)
	active_power_consumption = HOLOPAD_PASSIVE_POWER_USAGE + (HOLOGRAM_POWER_USAGE * total_users)
	if(total_users)
		set_light(2)
	else
		set_light(0)
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/machinery/hologram/holopad/update_icon_state()
	var/total_users = LAZYLEN(masters) + LAZYLEN(holo_calls)
	if(icon_state == "holopad_open")
		return
	else if(ringing)
		icon_state = "holopad_ringing"
	else if(total_users) {
		icon_state = "holopad0"
		var/icon/overlay_icon = new('icons/obj/stationobjs.dmi', "holopad1_lightmask")
		var/mob/living/silicon/ai/AI
		for(var/mob/living/user in masters)
			if(is_ai(user))
				AI = user
				break
		if(AI)
			overlay_icon.ColorTone(AI.hologram_color)
		overlays += overlay_icon
	} else {
		icon_state = "holopad0"
		overlays.Cut()
	}

/obj/machinery/hologram/holopad/proc/set_holo(mob/living/user, obj/effect/overlay/holo_pad_hologram/h)
	eye = user.remote_control
	eye.holopad = src
	masters[user] = h
	holorays[user] = new /obj/effect/overlay/holoray(loc)
	var/mob/living/silicon/ai/AI = user
	if(istype(AI))
		AI.current = src
		var/obj/effect/overlay/holoray = holorays[user]
		holoray.icon = getHologramIcon(icon('icons/effects/96x96.dmi', "holoray"), FALSE, AI.hologram_color, 1)
	SetLightsAndPower()
	update_holoray(user, get_turf(loc))
	return TRUE

/obj/machinery/hologram/holopad/proc/clear_holo(mob/living/user)
	qdel(masters[user]) // Get rid of user's hologram
	if(!QDELETED(eye))
		QDEL_NULL(eye)
	unset_holo(user)
	return TRUE

/obj/machinery/hologram/holopad/proc/unset_holo(mob/living/user)
	eye = null
	var/mob/living/silicon/ai/AI = user
	if(istype(AI) && AI.current == src)
		AI.current = null
	masters -= user // Discard AI from the list of those who use holopad
	qdel(holorays[user])
	holorays -= user
	SetLightsAndPower()
	return TRUE

/obj/machinery/hologram/holopad/proc/update_holoray(mob/living/user, turf/new_turf)
	var/obj/effect/overlay/holo_pad_hologram/holo = masters[user]
	var/obj/effect/overlay/holoray/ray = holorays[user]
	var/disty = holo.y - ray.y
	var/distx = holo.x - ray.x
	var/newangle
	if(!disty)
		if(distx >= 0)
			newangle = 90
		else
			newangle = 270
	else
		newangle = arctan(distx/disty)
		if(disty < 0)
			newangle += 180
		else if(distx < 0)
			newangle += 360
	var/matrix/M = matrix()
	if(get_dist(get_turf(holo), new_turf) <= 1)
		animate(ray, transform = turn(M.Scale(1, sqrt(distx*distx+disty*disty)), newangle), time = 1)
	else
		ray.transform = turn(M.Scale(1, sqrt(distx*distx+disty*disty)), newangle)


/obj/effect/overlay/holo_pad_hologram
	var/mob/living/Impersonation
	var/datum/holocall/HC
	flags_2 = HOLOGRAM_2

/obj/effect/overlay/holo_pad_hologram/Destroy()
	Impersonation = null
	if(!QDELETED(HC))
		HC.Disconnect(HC.calling_holopad)
	return ..()

/obj/effect/overlay/holo_pad_hologram/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 1

/obj/effect/overlay/holo_pad_hologram/examine(mob/user)
	if(Impersonation)
		. = Impersonation.examine(user)
	else
		. = ..()


/obj/effect/overlay/holoray
	name = "holoray"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "holoray"
	layer = FLY_LAYER
	pixel_x = -32
	pixel_y = -32
	alpha = 100

#undef HOLOPAD_PASSIVE_POWER_USAGE
#undef HOLOGRAM_POWER_USAGE

#undef RANGE_BASED
#undef AREA_BASED
#undef HOLOPAD_MODE
