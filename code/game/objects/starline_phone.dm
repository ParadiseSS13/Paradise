#define NO_CALLS 	1
#define RINGING 	2
#define ACTIVE_CALL	3
#define CALL_ENDED	4

/obj/machinery/phone
	name = "starline telephone"
	desc = "A direct phone line for receiving calls from Central Command. It would be best for everyone if this never rang."
	icon = 'icons/obj/starline_phone.dmi'
	icon_state = "base"
	anchored = TRUE
	resistance_flags = ACID_PROOF | FIRE_PROOF | FREEZE_PROOF
	power_state = NO_POWER_USE
	pass_flags = PASSTABLE
	/// Holds the handheld
	var/obj/item/radio/phone_receiver/handheld
	/// Is the handheld currently picked up
	var/phone_state = NO_CALLS
	/// Is this a centcomm telephone?
	var/centcomm_phone = FALSE
	/// what phone is this one conencted with
	var/obj/machinery/phone/connected_line

/obj/machinery/phone/centcomm
	centcomm_phone = TRUE
	name = "centcom master starline"

/obj/machinery/phone/centcomm/attack_hand(mob/user)
	var/mob/living/carbon/crew
	if(ishuman(user))
		crew = user
	else
		return // no stinky mobs/xenos allowed
	if(phone_state != NO_CALLS)
		to_chat(user, "<span class='warning'>There is already an ongoing call!</span>")
		return

	var/list/available_phones = list()
	for(var/obj/machinery/phone/phone in GLOB.landline_phones)
		available_phones[get_area_name(phone)] = phone
	var/phone_choice = tgui_input_list(user, "Select Destination Phone", "Phone:", available_phones)
	if(!phone_choice)
		return
	var/obj/machinery/phone/target_phone = available_phones[phone_choice]
	if(target_phone.phone_state != NO_CALLS)
		to_chat(user, "<span class='warning'>Call attemp failed: Line busy.</span>")
		return
	handheld = new
	handheld.parent_phone = src
	playsound(src, 'sound/machines/starline_pickup.ogg', 50, 0)
	crew.put_in_active_hand(handheld)
	icon_state = "answered"
	phone_state = ACTIVE_CALL
	connected_line = target_phone
	connected_line.phone_state = RINGING
	connected_line.connected_line = src
	INVOKE_ASYNC(connected_line, PROC_REF(ring_loop))

/obj/machinery/phone/Initialize(mapload)
	. = ..()
	if(!centcomm_phone) // we dont need to call CC phones
		GLOB.landline_phones += src

/obj/machinery/phone/attack_hand(mob/user)
	var/mob/living/carbon/crew
	if(ishuman(user))
		crew = user
	else
		return // no stinky mobs/xenos allowed

	switch(phone_state)
		if(NO_CALLS)
			to_chat(user, "<span class='warning'>There are no calls at the moment to pick up.</span>")
			return
		if(RINGING)
			handheld = new
			handheld.parent_phone = src
			playsound(src, 'sound/machines/starline_pickup.ogg', 50, 0)
			crew.put_in_active_hand(handheld)
			icon_state = "answered"
			start_call()
		else
			to_chat(user, "<span class='warning'>The receiver is already off the dock!</span>")
			return

/obj/machinery/phone/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/radio/phone_receiver))
		if(phone_state == ACTIVE_CALL)
			to_chat(user, "<span class='information'>You hang up the call.</span>")
			end_call()
		playsound(src, 'sound/machines/starline_hangup.ogg', 50, 0)
		handheld.dropped()
		icon_state = "base"
		phone_state = NO_CALLS
		return ITEM_INTERACT_COMPLETE

/obj/machinery/phone/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/machinery/phone/crowbar_act(mob/living/user, obj/item/I)
	return

/obj/machinery/phone/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)

/obj/machinery/phone/proc/ring_loop()
	var/ring_duration = 2 SECONDS
	var/ring_rest_duration = 3 SECONDS
	while(phone_state == RINGING)
		playsound(src, 'sound/machines/starline_ring.ogg', 50, 0, 2, ignore_walls = TRUE)
		icon_state = "ringing"
		sleep(ring_duration)
		if(phone_state == RINGING) // in case its answered mid ring
			icon_state = "base"
		sleep(ring_rest_duration)

/obj/machinery/phone/proc/start_call()
	phone_state = ACTIVE_CALL
	handheld.listening = TRUE
	connected_line.handheld.listening = TRUE
	connected_line.audible_message("<span class='information'>The receiver clicks as the other line picks up.</span>", hearing_distance = 3)

/obj/machinery/phone/proc/end_call()
	handheld.listening = FALSE
	phone_state = NO_CALLS
	if(connected_line)
		connected_line.audible_message("<span class='information'>The receiver clicks as the other line hangs up</span>", hearing_distance = 3)
		connected_line.connected_line = null
		if(connected_line.phone_state == RINGING)
			connected_line.phone_state = NO_CALLS
		else
			connected_line.phone_state = CALL_ENDED
			connected_line.handheld.listening = FALSE
		connected_line = null


/obj/item/radio/phone_receiver
	name = "phone receiver"
	desc = "A device for speaking into and listening to a connected starlink phone. "
	icon = 'icons/obj/starline_phone.dmi'
	icon_state = "receiver"
	flags = DROPDEL
	/// the starline phone this receiver conencts to
	var/obj/machinery/phone/parent_phone
	pixel_x = 4

/obj/item/radio/phone_receiver/Initialize(mapload)
	. = ..()
	on = TRUE
	listening = FALSE
	broadcasting = TRUE
	loudspeaker = TRUE
	set_frequency(STARLINE_FREQ)
	requires_tcomms = FALSE
	instant = TRUE
	canhear_range = 0
	freqlock = TRUE

/obj/item/radio/phone_receiver/dropped(mob/user, silent)
	visible_message("<span class='information'>The receiver snaps back into its dock.</span>")
	parent_phone.icon_state = "base"
	if(parent_phone.phone_state == ACTIVE_CALL)
		parent_phone.end_call()
	return ..()

/obj/item/radio/phone_receiver/on_mob_move(dir, mob/user)
	var/distance = get_dist(user.loc, parent_phone.loc)
	if(distance > 2)
		dropped()

/obj/item/radio/phone_receiver/can_enter_storage(obj/item/storage/S, mob/user)
	return FALSE

// we dont want them touching things
/obj/item/radio/phone_receiver/interact(mob/user)
	return

/obj/item/radio/phone_receiver/AltClick(mob/user)
	return

/obj/item/radio/phone_receiver/CtrlShiftClick(mob/user)
	return

#undef NO_CALLS
#undef RINGING
#undef ACTIVE_CALL
#undef CALL_ENDED
