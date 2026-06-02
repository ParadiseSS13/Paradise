/// Used to track warrior/servant deaths
GLOBAL_VAR_INIT(ragnarok_kill_count, 0)

/obj/structure/environmental_storytelling_holopad/ragnarok_ship
	speaking_name = "Princess Zrexx"
	loop_sleep_time = 8 SECONDS

/obj/structure/environmental_storytelling_holopad/ragnarok_ship/start_message(mob/living/carbon/human/H)
	activated = TRUE
	QDEL_NULL(proximity_monitor)
	icon_state = "holopad1"
	update_icon(UPDATE_OVERLAYS)
	var/obj/effect/overlay/hologram = new(get_turf(src))
	our_holo = hologram
	hologram.icon = getHologramIcon(icon('icons/mob/simple_human.dmi', "kidan_princess"), colour = null, opacity = 0.8, colour_blocking = TRUE)
	hologram.alpha = 166
	hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	hologram.layer = FLY_LAYER
	hologram.anchored = TRUE
	hologram.name = speaking_name
	hologram.set_light(2)
	hologram.bubble_icon = "swarmer"
	hologram.pixel_y = 16
	var/loops = 0
	for(var/I in things_to_say)
		loops++
		hologram.atom_say("[I]")
		sleep(loop_sleep_time)

/obj/structure/environmental_storytelling_holopad/ragnarok_ship/dining_hall
	things_to_say = list("Come, stranger, enjoy a feast. My servants have prepared a mighty banquet.",
		"My guards will ensure you have a secure time, but they are a bit touchy, alas.",
		"Do sit down and enjoy yourself, stranger.")

/obj/structure/environmental_storytelling_holopad/ragnarok_ship/gardens
	things_to_say = list("Explore my gardens, for they contain some of the final flora from our homeworld.",
		"Take a seat and have a drink, yes?",
		"If you don't stop to smell the flowers, you will find that the peaks in life come to dull your mind.")

/obj/structure/environmental_storytelling_holopad/ragnarok_ship/baths
	things_to_say = list("You're tense. Why don't you relax in the baths?",
		"Join my soldiers and servants in their revelry. Enjoy the view of the stars from my windows.",
		"The royal reagents infused in the waters will invigorate your body and mind. It is my honor for you to enjoy.")

/obj/structure/environmental_storytelling_holopad/ragnarok_ship/bridge
	things_to_say = list("There is a strangeness to this system. The proximity to the planet jams our navigation and sensor arrays.",
		"However, it is such a wonderful source of the all-important plasma. Quite useful for creating the royal nectar.",
		"Leave my soldiers to their work, stranger. You will not find opulence in such a place of focus.")

/obj/structure/environmental_storytelling_holopad/ragnarok_ship/vault
	things_to_say = list("Know this, stranger, that you have spilled royal blood this day.",
		"Take my yacht. Enjoy it as a trophy to your endeavors. There is much for us to learn from one another.",
		"Take my weapon, may it serve you well. I will have another made, to fit this fresh body.",
		"These gifts to you will be a reminder of my lineage and right to rule. Princess Zrexx has spoken.")
