/obj/vehicle/bike
	name = "bicycle"
	desc = "Two wheels of FURY!"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "bicycle"
	vehicle_move_delay = 1
	var/mutable_appearance/bicycle_overlay

/obj/vehicle/bike/Initialize(mapload)
	. = ..()
	bicycle_overlay = mutable_appearance(icon, "bicycle_overlay", ABOVE_MOB_LAYER)

/obj/vehicle/bike/relaymove(mob/user, direction)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/driver = user
	var/obj/item/organ/external/l_hand = driver.get_organ("l_hand")
	var/obj/item/organ/external/r_hand = driver.get_organ("r_hand")
	if(!l_hand && !r_hand)
		vehicle_move_delay += 0.5 // I can ride my bike with no handlebars... (but it's slower)
	for(var/organ_name in list("l_leg", "r_leg", "l_foot", "r_foot"))
		var/obj/item/organ/external/E = driver.get_organ(organ_name)
		if(!E)
			return // Bikes need both feet/legs to work. missing even one makes it so you can't ride the bike
		if(E.status & ORGAN_SPLINTED)
			vehicle_move_delay += 0.5
		else if(E.status & ORGAN_BROKEN)
			vehicle_move_delay += 1.5

/obj/vehicle/bike/post_buckle_mob(mob/living/M)
	. = ..()
	var/datum/action/bicycle_bell/bell_action = new(src)
	bell_action.Grant(M)
	add_overlay(bicycle_overlay)

/obj/vehicle/bike/post_unbuckle_mob(mob/living/M)
	for(var/datum/action/bicycle_bell/bell_action in M.actions)
		bell_action.Remove(M)
	cut_overlay(bicycle_overlay)
	return ..()

/obj/vehicle/bike/handle_vehicle_layer()
	return

/datum/action/bicycle_bell
	name = "Ring Bell"
	desc = "Go on, ring your bicycle bell!"
	icon_icon = 'icons/obj/bureaucracy.dmi'
	button_icon_state = "desk_bell"
	COOLDOWN_DECLARE(ring_cooldown)

/datum/action/bicycle_bell/Trigger(left_click)
	. = ..()
	if(!COOLDOWN_FINISHED(src, ring_cooldown))
		return
	var/obj/vehicle/bike/B = target
	playsound(B, 'sound/machines/bell.ogg', 70, TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	COOLDOWN_START(src, ring_cooldown, 1 SECONDS)
