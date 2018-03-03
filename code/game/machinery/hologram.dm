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

var/const/HOLOPAD_MODE = RANGE_BASED

var/list/holopads = list()

/obj/machinery/hologram/holopad
	name = "holopad"
	desc = "It's a floor-mounted device for projecting holographic images."
	icon_state = "holopad0"
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	layer = TURF_LAYER+0.1 //Preventing mice and drones from sneaking under them.

	var/list/masters = list()//List of living mobs that use the holopad
	var/list/holorays = list()//Holoray-mob link.
	var/last_request = 0 //to prevent request spam. ~Carn
	var/holo_range = 5 // Change to change how far the AI can move away from the holopad before deactivating.
	var/temp = ""
	var/list/holo_calls	//array of /datum/holocalls
	var/datum/holocall/outgoing_call	//do not modify the datums only check and call the public procs
	var/static/force_answer_call = FALSE	//Calls will be automatically answered after a couple rings, here for debugging
	var/static/list/holopads = list()
	var/obj/effect/overlay/holoray/ray

/obj/machinery/hologram/holopad/New()
	..()
	holopads += src
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/holopad(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/hologram/holopad/Destroy()
	if(outgoing_call)
		outgoing_call.ConnectionFailure(src)

	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		HC.ConnectionFailure(src)

	for(var/I in masters)
		clear_holo(I)
	holopads -= src
	return ..()

/obj/machinery/hologram/holopad/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
		if(outgoing_call)
			outgoing_call.ConnectionFailure(src)

/obj/machinery/hologram/holopad/RefreshParts()
	var/holograph_range = 4
	for(var/obj/item/weapon/stock_parts/capacitor/B in component_parts)
		holograph_range += 1 * B.rating
	holo_range = holograph_range

/obj/machinery/hologram/holopad/attackby(obj/item/P as obj, mob/user as mob, params)
	if(default_deconstruction_screwdriver(user, "holopad_open", "holopad0", P))
		return

	if(exchange_parts(user, P))
		return

	if(default_unfasten_wrench(user, P))
		return

	default_deconstruction_crowbar(P)


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
			for(var/mob/living/silicon/ai/AI in ai_list)
				if(!AI.client)
					continue
				to_chat(AI, "<span class='info'>Your presence is requested at <a href='?src=\ref[AI];jumptoholopad=[UID()]'>\the [area]</a>.</span>")
		else
			temp = "A request for AI presence was already sent recently.<br>"
			temp += "<a href='?src=[UID()];mainmenu=1'>Main Menu</a>"

	else if(href_list["Holocall"])
		if(outgoing_call)
			return

		temp = "You must stand on the holopad to make a call!<br>"
		temp += "<a href='?src=[UID()];mainmenu=1'>Main Menu</a>"
		if(usr.loc == loc)
			var/list/callnames = list()
			for(var/I in holopads)
				var/area/A = get_area(I)
				if(A)
					LAZYADD(callnames[A], I)
			callnames -= get_area(src)

			var/result = input(usr, "Choose an area to call", "Holocall") as null|anything in callnames

			if(qdeleted(usr) || !result || outgoing_call)
				return

			if(usr.loc == loc)
				temp = "Dialing...<br>"
				temp += "<a href='?src=[UID()];mainmenu=1'>Main Menu</a>"
				new /datum/holocall(usr, src, callnames[result])

	else if(href_list["connectcall"])
		var/datum/holocall/call_to_connect = locateUID(href_list["connectcall"])
		if(!qdeleted(call_to_connect) && (call_to_connect in holo_calls))
			call_to_connect.Answer(src)
		temp = ""

	else if(href_list["disconnectcall"])
		var/datum/holocall/call_to_disconnect = locateUID(href_list["disconnectcall"])
		if(exists(call_to_disconnect) && (call_to_disconnect in holo_calls))
			call_to_disconnect.Disconnect(src)
		temp = ""

	else if(href_list["mainmenu"])
		temp = ""
		if(outgoing_call)
			outgoing_call.Disconnect()

	updateDialog()

//do not allow AIs to answer calls or people will use it to meta the AI sattelite
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
		var/mob/living/silicon/ai/AI = master
		if(!istype(AI))
			AI = null

		if(!qdeleted(master) && !master.incapacitated() && master.client && (!AI || AI.eyeobj))//If there is an AI attached, it's not incapacitated, it has a client, and the client eye is centered on the projector.
			if(!(stat & NOPOWER))//If the  machine has power
				if(AI)	//ais are range based
					if(HOLOPAD_MODE == RANGE_BASED)
						if(get_dist(AI.eyeobj, src) <= holo_range)
							continue

					if(!(AI.current))//if the ai jumped to core
						clear_holo(AI)
						return 1

					var/obj/machinery/hologram/holopad/pad_close = get_closest_atom(/obj/machinery/hologram/holopad, holopads, AI.eyeobj)
					if(get_dist(pad_close, AI.eyeobj) <= pad_close.holo_range)
						clear_holo(AI)
						if(!pad_close.outgoing_call)
							pad_close.activate_holo(AI, 1)
				else
					continue

		clear_holo(master)//If is a non AI holo clear it.

	if(outgoing_call)
		outgoing_call.Check()

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

/obj/machinery/hologram/holopad/proc/move_hologram(mob/living/user, turf/new_turf)
	if(masters[user])
		var/obj/effect/overlay/holo_pad_hologram/H = masters[user]
		H.setDir(get_dir(H.loc, new_turf))
		H.forceMove(new_turf)
		update_holoray(user, new_turf)
		if(ishuman(user))
			var/area/holo_area = get_area(src)
			var/area/eye_area = get_area(new_turf.loc)

			if(eye_area != holo_area)
				clear_holo(user)
	return 1

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

		hologram.mouse_opacity = 0//So you can't click on it.
		hologram.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
		hologram.anchored = 1//So space wind cannot drag it.
		hologram.name = "[user.name] (hologram)"//If someone decides to right click.
		hologram.set_light(2)	//hologram lighting
		move_hologram()

		set_holo(user, hologram)

		if(!masters[user])//If there is not already a hologram.
			visible_message("A holographic image of [user] flicks to life right before your eyes!")

		return hologram

	else
		to_chat(user, "<span class='danger'>ERROR:</span> Hologram Projection Malfunction.")
		clear_holo(user)//safety check

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/hologram/holopad/hear_talk(atom/movable/speaker, message, verb, datum/language/message_language)
	if(speaker && masters.len)//Master is mostly a safety in case lag hits or something. Radio_freq so AIs dont hear holopad stuff through radios.
		for(var/mob/living/silicon/ai/master in masters)
			if(masters[master] && speaker != master)
				master.relay_speech(speaker, message, verb, message_language)

	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		if(HC.connected_holopad == src && speaker != HC.hologram)
			HC.hologram.hear_message(speaker, message, verb, message_language)

	if(outgoing_call && speaker == outgoing_call.user)
		outgoing_call.hologram.atom_say(message)



/obj/machinery/hologram/holopad/proc/SetLightsAndPower()
	var/total_users = masters.len + LAZYLEN(holo_calls)
	use_power = HOLOPAD_PASSIVE_POWER_USAGE + HOLOGRAM_POWER_USAGE * total_users
	if(total_users)
		set_light(2)
		icon_state = "holopad1"
	else
		set_light(0)
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
	if(get_dist(get_turf(holo),new_turf) <= 1)
		animate(ray, transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle),time = 1)
	else
		ray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle)


/obj/effect/overlay/holo_pad_hologram
	var/mob/living/Impersonation
	var/datum/holocall/HC

/obj/effect/overlay/holo_pad_hologram/Destroy()
	Impersonation = null
	if(HC)
		HC.Disconnect(HC.calling_holopad)
	return ..()

/obj/effect/overlay/holo_pad_hologram/Process_Spacemove(movement_dir = 0)
	return 1

/obj/effect/overlay/holo_pad_hologram/examine(mob/user)
	if(Impersonation)
		return Impersonation.examine(user)
	return ..()


/obj/effect/overlay/holoray
	name = "holoray"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "holoray"
	layer = FLY_LAYER
	density = FALSE
	anchored = TRUE
	mouse_opacity = 1
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
