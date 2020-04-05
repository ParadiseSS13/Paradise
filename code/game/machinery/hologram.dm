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

/obj/machinery/hologram/holopad
	name = "holopad"
	desc = "It's a floor-mounted device for projecting holographic images."
	icon_state = "holopad0"
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	layer = TURF_LAYER+0.1 //Preventing mice and drones from sneaking under them.
	plane = FLOOR_PLANE
	max_integrity = 300
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 0)
	var/list/masters = list()//List of living mobs that use the holopad
	var/list/holorays = list()//Holoray-mob link.
	var/last_request = 0 //to prevent request spam. ~Carn
	var/holo_range = 5 // Change to change how far the AI can move away from the holopad before deactivating.
	var/temp = ""
	var/list/holo_calls	//array of /datum/holocalls
	var/datum/holocall/outgoing_call	//do not modify the datums only check and call the public procs
	var/static/force_answer_call = FALSE	//Calls will be automatically answered after a couple rings, here for debugging
	var/obj/effect/overlay/holoray/ray
	var/ringing = FALSE
	var/dialling_input = FALSE //The user is currently selecting where to send their call

/obj/machinery/hologram/holopad/New()
	..()
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
	if(powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
		if(outgoing_call)
			outgoing_call.ConnectionFailure(src)

/obj/machinery/hologram/holopad/obj_break()
	. = ..()
	if(outgoing_call)
		outgoing_call.ConnectionFailure(src)

/obj/machinery/hologram/holopad/RefreshParts()
	var/holograph_range = 4
	for(var/obj/item/stock_parts/capacitor/B in component_parts)
		holograph_range += 1 * B.rating
	holo_range = holograph_range

/obj/machinery/hologram/holopad/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return
	return ..()

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

	user.set_machine(src)
	interact(user)

/obj/machinery/hologram/holopad/AltClick(mob/living/carbon/human/user)
	if(..())
		return
	if(isAI(user))
		hangup_all_calls()
		return

//Stop ringing the AI!!
/obj/machinery/hologram/holopad/proc/hangup_all_calls()
	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		HC.Disconnect(src)

/obj/machinery/hologram/holopad/interact(mob/living/carbon/human/user) //Carn: hologram requests.
	if(!istype(user))
		return
	if(!anchored)
		return

	var/dat
	if(temp)
		dat = temp
	else
		dat = "<a href='?src=[UID()];AIrequest=1'>Request an AI's presence.</a><br>"
		dat += "<a href='?src=[UID()];Holocall=1'>Call another holopad.</a><br>"

		if(LAZYLEN(holo_calls))
			dat += "=====================================================<br>"

		var/one_answered_call = FALSE
		var/one_unanswered_call = FALSE
		for(var/I in holo_calls)
			var/datum/holocall/HC = I
			if(HC.connected_holopad != src)
				dat += "<a href='?src=[UID()];connectcall=[HC.UID()]'>Answer call from [get_area(HC.calling_holopad)].</a><br>"
				one_unanswered_call = TRUE
			else
				one_answered_call = TRUE

		if(one_answered_call && one_unanswered_call)
			dat += "=====================================================<br>"
		//we loop twice for formatting
		for(var/I in holo_calls)
			var/datum/holocall/HC = I
			if(HC.connected_holopad == src)
				dat += "<a href='?src=[UID()];disconnectcall=[HC.UID()] '>Disconnect call from [HC.user].</a><br>"

	var/area/area = get_area(src)
	var/datum/browser/popup = new(user, "holopad", "[area] holopad", 400, 300)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/hologram/holopad/Topic(href, href_list)
	if(..() || isAI(usr))
		return
	add_fingerprint(usr)
	if(stat & NOPOWER)
		return
	if(href_list["AIrequest"])
		if(last_request + 200 < world.time)
			last_request = world.time
			temp = "You requested an AI's presence.<br>"
			temp += "<a href='?src=[UID()];mainmenu=1'>Main Menu</a>"
			var/area/area = get_area(src)
			for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
				if(!AI.client)
					continue
				to_chat(AI, "<span class='info'>Your presence is requested at <a href='?src=\ref[AI];jumptoholopad=[UID()]'>\the [area]</a>.</span>")
		else
			temp = "A request for AI presence was already sent recently.<br>"
			temp += "<a href='?src=[UID()];mainmenu=1'>Main Menu</a>"

	else if(href_list["Holocall"])
		if(outgoing_call)
			return
		if(dialling_input)
			to_chat(usr, "<span class='notice'>Finish dialling first!</span>")
			return
		temp = "You must stand on the holopad to make a call!<br>"
		temp += "<a href='?src=[UID()];mainmenu=1'>Main Menu</a>"
		if(usr.loc == loc)
			var/list/callnames = list()
			for(var/I in GLOB.holopads)
				var/area/A = get_area(I)
				if(A)
					LAZYADD(callnames[A], I)
			callnames -= get_area(src)
			var/list/sorted_callnames = sortAtom(callnames)
			dialling_input = TRUE
			var/result = input(usr, "Choose an area to call", "Holocall") as null|anything in sorted_callnames
			dialling_input = FALSE
			if(QDELETED(usr) || !result || outgoing_call)
				return

			if(usr.loc == loc)
				temp = "Dialing...<br>"
				temp += "<a href='?src=[UID()];mainmenu=1'>Main Menu</a>"
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

//do not allow AIs to answer calls or people will use it to meta the AI satellite
/obj/machinery/hologram/holopad/attack_ai(mob/living/silicon/ai/user)
	if(!istype(user))
		return
	if(outgoing_call)
		return
	/*There are pretty much only three ways to interact here.
	I don't need to check for client since they're clicking on an object.
	This may change in the future but for now will suffice.*/
	if(user.eyeobj.loc != loc)//Set client eye on the object if it's not already.
		user.eyeobj.setLoc(get_turf(src))
	else if(!LAZYLEN(masters) || !masters[user])//If there is no hologram, possibly make one.
		activate_holo(user, 1)
	else//If there is a hologram, remove it.
		clear_holo(user)

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
			if(force_answer_call && world.time > (HC.call_start_time + (HOLOPAD_MAX_DIAL_TIME / 2)))
				HC.Answer(src)
				break
			if(outgoing_call)
				HC.Disconnect(src)//can't answer calls while calling
			else
				playsound(src, 'sound/machines/twobeep.ogg', 100)	//bring, bring!
				ringing = TRUE

	update_icon()


//Try to transfer hologram to another pad that can project on T
/obj/machinery/hologram/holopad/proc/transfer_to_nearby_pad(turf/T, mob/holo_owner)
	if(!isAI(holo_owner))
		return
	for(var/pad in GLOB.holopads)
		var/obj/machinery/hologram/holopad/another = pad
		if(another == src)
			continue
		if(another.validate_location(T))
			var/obj/effect/overlay/holo_pad_hologram/h = masters[holo_owner]
			unset_holo(holo_owner)
			another.set_holo(holo_owner, h)
			return TRUE
	return FALSE

/obj/machinery/hologram/holopad/proc/validate_user(mob/living/user)
	if(QDELETED(user) || user.incapacitated() || !user.client)
		return FALSE

	if(istype(user, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = user
		if(!AI.current)
			return FALSE
	return TRUE

//Can we display holos there
//Area check instead of line of sight check because this is a called a lot if AI wants to move around.
/obj/machinery/hologram/holopad/proc/validate_location(turf/T,check_los = FALSE)
	if(T.z == z && get_dist(T, src) <= holo_range && T.loc == get_area(src))
		return TRUE
	return FALSE


/obj/machinery/hologram/holopad/proc/move_hologram(mob/living/user, turf/new_turf)
	if(masters[user])
		var/obj/effect/overlay/holo_pad_hologram/holo = masters[user]
		var/transfered = FALSE
		if(!validate_location(new_turf))
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

/obj/machinery/hologram/holopad/proc/activate_holo(mob/living/user, var/force = 0)
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
		if(isAI(user))
			hologram.icon = AI.holo_icon
		else	//make it like real life
			hologram.icon = getHologramIcon(get_id_photo(user))
			hologram.icon_state = user.icon_state
			hologram.alpha = 100
			hologram.Impersonation = user

		hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
		hologram.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
		hologram.anchored = 1//So space wind cannot drag it.
		hologram.name = "[user.name] (hologram)"//If someone decides to right click.
		hologram.set_light(2)	//hologram lighting
		move_hologram()

		set_holo(user, hologram)

		if(!masters[user])//If there is not already a hologram.
			visible_message("A holographic image of [user] flicks to life right before your eyes!")

		return hologram


	to_chat(user, "<span class='danger'>ERROR:</span> Hologram Projection Malfunction.")
	clear_holo(user)//safety check

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/hologram/holopad/hear_talk(atom/movable/speaker, list/message_pieces, verb)
	if(speaker && masters.len)//Master is mostly a safety in case lag hits or something. Radio_freq so AIs dont hear holopad stuff through radios.
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
	var/total_users = masters.len + LAZYLEN(holo_calls)
	use_power = total_users > 0 ? ACTIVE_POWER_USE : IDLE_POWER_USE
	active_power_usage = HOLOPAD_PASSIVE_POWER_USAGE + (HOLOGRAM_POWER_USAGE * total_users)
	if(total_users)
		set_light(2)
		icon_state = "holopad1"
	else
		set_light(0)
		icon_state = "holopad0"
	update_icon()

/obj/machinery/hologram/holopad/update_icon()
	var/total_users = LAZYLEN(masters) + LAZYLEN(holo_calls)
	if(icon_state == "holopad_open")
		return
	else if(ringing)
		icon_state = "holopad_ringing"
	else if(total_users)
		icon_state = "holopad1"
	else
		icon_state = "holopad0"


/obj/machinery/hologram/holopad/proc/set_holo(mob/living/user, var/obj/effect/overlay/holo_pad_hologram/h)
	masters[user] = h
	holorays[user] = new /obj/effect/overlay/holoray(loc)
	var/mob/living/silicon/ai/AI = user
	if(istype(AI))
		AI.current = src
	SetLightsAndPower()
	update_holoray(user, get_turf(loc))
	return TRUE

/obj/machinery/hologram/holopad/proc/clear_holo(mob/living/user)
	qdel(masters[user]) // Get rid of user's hologram
	unset_holo(user)
	return TRUE

/obj/machinery/hologram/holopad/proc/unset_holo(mob/living/user)
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

/obj/effect/overlay/holo_pad_hologram/Destroy()
	Impersonation = null
	if(!QDELETED(HC))
		HC.Disconnect(HC.calling_holopad)
	return ..()

/obj/effect/overlay/holo_pad_hologram/Process_Spacemove(movement_dir = 0)
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
	density = FALSE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_ICON
	pixel_x = -32
	pixel_y = -32
	alpha = 100

/*
 * Other Stuff: Is this even used?
 */
/obj/machinery/hologram/projector
	name = "hologram projector"
	desc = "It makes a hologram appear...with magnets or something..."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "hologram0"

#undef HOLOPAD_PASSIVE_POWER_USAGE
#undef HOLOGRAM_POWER_USAGE
