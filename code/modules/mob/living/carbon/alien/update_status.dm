// NOTE(crazylemon): Not sure why you're not using carbon update_sight like the rest of us
/mob/living/carbon/alien/update_sight()
	// No need to update sight flags if no one's there to appreciate
	if(!client)
		return
	if(stat == DEAD)
		sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
		return

	sight = SEE_MOBS
	if(nightvision)
		see_in_dark = 8
		// Doesn't actually use SEE_INVISIBLE_NOLIGHTING?
		see_invisible = SEE_INVISIBLE_MINIMUM
	else
		see_in_dark = 4
		see_invisible = SEE_INVISIBLE_LIVING

	if(client.eye != src)
		var/atom/A = client.eye
		// 1 means sight updates are overridden
		if(A.update_remote_sight(src))
			return

	// Look at me with your special eyes
	// for(var/obj/item/organ/cyberimp/eyes/E in internal_organs)
	// 	sight |= E.vision_flags
	// 	if(E.dark_view)
	// 		see_in_dark = max(see_in_dark, E.dark_view)
	// 	if(E.see_invisible)
	// 		// This is strange, since reducing see_invisible lets you get night vision
	// 		see_invisible = min(see_invisible, E.see_invisible)

	if(see_override)
		see_invisible = see_override
