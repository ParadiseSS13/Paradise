/obj/item/weapon/staff/storm
	name = "staff of storms"
	desc = "An ancient staff retrieved from the remains of Legion. The wind stirs as you move it."
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	item_state = "staffofstorms"
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	var/storm_type = /datum/weather/ash_storm
	var/storm_cooldown = 0

/obj/item/weapon/staff/storm/attack_self(mob/user)
	if(storm_cooldown > world.time)
		to_chat(user, "<span class='warning'>The staff is still recharging!</span>")
		return

	var/area/user_area = get_area(user)
	var/datum/weather/A
	var/z_level_name = space_manager.levels_by_name[user.z]
	for(var/V in weather_master.existing_weather)
		var/datum/weather/W = V
		if(W.target_z == z_level_name && W.area_type == user_area.type)
			A = W
			break
	if(A)

		if(A.stage != END_STAGE)
			if(A.stage == WIND_DOWN_STAGE)
				to_chat(user, "<span class='warning'>The storm is already ending! It would be a waste to use the staff now.</span>")
				return
			user.visible_message("<span class='warning'>[user] holds [src] skywards as an orange beam travels into the sky!</span>", \
			"<span class='notice'>You hold [src] skyward, dispelling the storm!</span>")
			playsound(user, 'sound/magic/Staff_Change.ogg', 200, 0)
			A.wind_down()
			return
	else
		A = new storm_type
		A.name = "staff storm"
		A.area_type = user_area.type
		A.target_z = z_level_name
		A.telegraph_duration = 100
		A.end_duration = 100

	user.visible_message("<span class='warning'>[user] holds [src] skywards as red lightning crackles into the sky!</span>", \
	"<span class='notice'>You hold [src] skyward, calling down a terrible storm!</span>")
	playsound(user, 'sound/magic/Staff_Change.ogg', 200, 0)
	A.telegraph()
	storm_cooldown = world.time + 200
