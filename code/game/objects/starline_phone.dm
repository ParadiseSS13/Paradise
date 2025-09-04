#define NO_CALLS 	1
#define RINGING 	2
#define ACTIVE_CALL	3

/obj/machinery/phone
	name = "starline telephone"
	desc = "A direct phone line for receiving calls from Central Command. It would be best for everyone if this never rang."
	icon = 'icons/obj/starline_phone.dmi'
	icon_state = "base"
	anchored = TRUE
	resistance_flags = ACID_PROOF | FIRE_PROOF | FREEZE_PROOF
	idle_power_consumption = 0
	power_state = NO_POWER_USE
	pass_flags = PASSTABLE
	new_attack_chain = TRUE
	/// Holds the handheld
	var/obj/item/phone_receiver/handheld
	/// Is the handheld currently picked up
	var/phone_state = NO_CALLS
	/// Is this a centcomm telephone?
	var/centcomm_phone = FALSE
	/// what phone is this one conencted with
	var/obj/machinery/phone/connected_line

/obj/machinery/phone/centcomm
	centcomm_phone = TRUE

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
	phone_choice = available_phones[phone_choice]
	crew.put_in_active_hand(handheld)
	icon_state = "answered"
	phone_state = ACTIVE_CALL
	connected_line = phone_choice
	connected_line.phone_state = RINGING
	connected_line.connected_line = src
	INVOKE_ASYNC(connected_line, PROC_REF(ring_loop))

/obj/machinery/phone/Initialize(mapload)
	. = ..()
	handheld = new
	handheld.parent_phone = src
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
			to_chat(user, "<span class='warning'>[src] is already in use!</span>")
			return
		if(RINGING)
			crew.put_in_active_hand(handheld)
			icon_state = "answered"
			start_call()
		if(ACTIVE_CALL)
			to_chat(user, "<span class='warning'>There are no incomming calls at the moment.</span>")
			return

/obj/machinery/phone/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/phone_receiver))
		if(phone_state == ACTIVE_CALL)
			to_chat(user, "<span class='information'>You hang up the call.</span>")
			end_call()
		user.transfer_item_to(handheld, src)
		icon_state = "base"
		return ITEM_INTERACT_COMPLETE

/obj/machinery/phone/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/machinery/phone/crowbar_act(mob/living/user, obj/item/I)
	return

/obj/machinery/phone/proc/ring_loop()
	var/ring_duration = 0.3 SECONDS
	var/ring_rest_duration = 2.5 SECONDS
	while(phone_state == RINGING)
		playsound(src, 'sound/weapons/ring.ogg', 50, 0, 4, ignore_walls = TRUE)
		icon_state = "ringing"
		sleep(ring_duration)
		icon_state = "base"
		sleep(ring_rest_duration)

/obj/machinery/phone/proc/start_call()
	phone_state = ACTIVE_CALL
	handheld.radio.listening = TRUE
	connected_line.handheld.radio.listening = TRUE
	connected_line.connected_line.audible_message("<span class='information'>The receiver clicks as the other picks up.</span>", hearing_distance = 1)

/obj/machinery/phone/proc/end_call()
	handheld.radio.listening = FALSE
	handheld.radio.broadcasting = FALSE
	phone_state = NO_CALLS
	if(connected_line)
		connected_line.audible_message("<span class='information'>The receiver clicks as the other line hangs up</span>", hearing_distance = 1)
		connected_line.connected_line = null
		connected_line.handheld.radio.listening = FALSE
		connected_line.phone_state = NO_CALLS
		connected_line = null

/obj/item/phone_receiver
	name = "phone receiver"
	desc = "A device for speaking into and listening to a connected starlink phone. "
	icon = 'icons/obj/starline_phone.dmi'
	icon_state = "receiver"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_BULKY // no putting this in bags
	/// the starline phone this receiver conencts to
	var/obj/machinery/phone/parent_phone
	/// The radio we're going to use for the "secure connection"
	var/obj/item/radio/radio

/obj/item/phone_receiver/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.listening = FALSE
	radio.broadcasting = TRUE
	radio.loudspeaker = TRUE
	radio.set_frequency(STARLINE_FREQ)
	radio.requires_tcomms = FALSE
	radio.instant = TRUE
	radio.canhear_range = 1
	radio.freqlock = TRUE

/obj/item/phone_receiver/dropped(mob/user, silent)
	. = ..()
	visible_message("<span class='information'>The receiver snaps back into its dock.</span>")
	forceMove(parent_phone)
	parent_phone.icon_state = "base"
	if(parent_phone.phone_state == ACTIVE_CALL)
		parent_phone.end_call()
	return // no child behavior

/obj/item/phone_receiver/on_mob_move(dir, mob/user)
	var/distance = get_dist(user.loc, parent_phone.loc)
	if(distance > 2)
		dropped()

#undef NO_CALLS
#undef RINGING
#undef ACTIVE_CALL
