/mob/living/simple_animal/possessed_object/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/possessed_object(src)

/datum/hud/possessed_object/New(mob/living/simple_animal/possessed_object/user)
	..()

	zone_select = new /obj/screen/zone_sel()
	zone_select.update_icon(mymob)
	static_inventory += zone_select
