/obj/item/staff/storm
	name = "staff of storms"
	desc = "An ancient staff retrieved from the remains of Legion. The wind stirs as you move it."
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	needs_permit = TRUE
	var/storm_type = /datum/weather/ash_storm
	var/storm_cooldown = 0

/obj/item/staff/storm/attack_self(mob/user)
	if(storm_cooldown > world.time)
		to_chat(user, span_warning("The staff is still recharging!"))
		return

	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)
	if(!user_area || !user_turf)
		to_chat(user, span_warning("Something is preventing you from using the staff here."))
		return
	var/datum/weather/A
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if((user_turf.z in W.impacted_z_levels) && W.area_type == user_area.type)
			A = W
			break

	if(A)
		if(A.stage != END_STAGE)
			if(A.stage == WIND_DOWN_STAGE)
				to_chat(user, span_warning("The storm is already ending! It would be a waste to use the staff now."))
				return
			user.visible_message(span_warning("[user] holds [src] skywards as an orange beam travels into the sky!"), \
			span_notice("You hold [src] skyward, dispelling the storm!"))
			playsound(user, 'sound/magic/staff_change.ogg', 200, 0)
			A.wind_down()
			return
	else
		A = new storm_type(list(user_turf.z))
		A.name = "staff storm"
		A.area_type = user_area.type
		A.telegraph_duration = 100
		A.end_duration = 100

	user.visible_message(span_warning("[user] holds [src] skywards as red lightning crackles into the sky!"), \
	span_notice("You hold [src] skyward, calling down a terrible storm!"))
	playsound(user, 'sound/magic/staff_change.ogg', 200, 0)
	A.telegraph()
	storm_cooldown = world.time + 200
