/obj/item/staff/storm
	name = "staff of storms"
	desc = "An ancient staff retrieved from the remains of Legion. The wind stirs as you move it."
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/weapons/magic.dmi'
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
		to_chat(user, "<span class='warning'>The staff is still recharging!</span>")
		return

	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)
	if(!user_area || !user_turf)
		to_chat(user, "<span class='warning'>Something is preventing you from using the staff here.</span>")
		return

	var/datum/weather/storm
	for(var/V in SSweather.processing)
		var/datum/weather/storm_processed = V
		if((user_turf.z in storm_processed.impacted_z_levels) && storm_processed.area_type == user_area.type)
			storm = storm_processed
			break

	if(storm)
		if(storm.stage != END_STAGE)
			if(storm.stage == WIND_DOWN_STAGE)
				to_chat(user, "<span class='warning'>The storm is already ending! It would be a waste to use the staff now.</span>")
				return
			user.visible_message("<span class='warning'>[user] holds [src] skywards as an orange beam travels into the sky!</span>", \
			"<span class='notice'>You hold [src] skyward, dispelling the storm!</span>")
			add_attack_logs(user, src, "dispelled a storm", ATKLOG_FEW)
			playsound(user, 'sound/magic/staff_change.ogg', 200, 0)
			storm.wind_down()
			return
	else
		storm = new storm_type(list(user_turf.z))
		storm.name = "staff storm"
		storm.area_type = user_area.type
		storm.telegraph_duration = 100
		storm.end_duration = 100

	user.visible_message("<span class='warning'>[user] holds [src] skywards as red lightning crackles into the sky!</span>", \
	"<span class='notice'>You hold [src] skyward, calling down a terrible storm!</span>")
	add_attack_logs(user, src, "created a storm", ATKLOG_FEW)
	playsound(user, 'sound/magic/staff_change.ogg', 200, 0)
	storm.telegraph()
	storm_cooldown = world.time + 200
