/datum/species/teshari
	name = "Teshari"
	name_plural = "Tesharii"
	blurb = "A race of feathered raptors who developed alongside the Skrell, inhabiting \
	the polar tundral regions outside of Skrell territory. Extremely fragile, they developed \
	hunting skills that emphasized taking out their prey without themselves getting hit. They \
	are only recently becoming known on human stations after reaching space with Skrell assistance."

	icobase = 'icons/mob/human_races/r_seromi.dmi'
	deform = 'icons/mob/human_races/r_seromi.dmi'
	damage_overlays = 'icons/mob/human_races/masks/dam_seromi.dmi'
	damage_mask = 'icons/mob/human_races/masks/dam_mask_seromi.dmi'
	blood_mask = 'icons/mob/human_races/masks/blood_seromi.dmi'

	eyes = "seromi_eyes_s"

	bodyflags = HAS_TAIL | HAS_SKIN_COLOR
	dietflags = DIET_OMNI
	flags = HAS_LIPS

	secondary_langs = list("Schechi", "Skrellian")
	default_language = "Galactic Common"
	language = "Schechi"

	blood_color = "#D514F7"
	flesh_color = "#5F7BB0"
	base_color = "#001144"
	tail = "seromitail"

	slowdown = -1
	total_health = 50
	brute_mod = 1.35
	burn_mod = 1.35
	pass_flags = PASSTABLE
	reagent_tag = PROCESS_ORG

	cold_level_1 = 180
	cold_level_2 = 130
	cold_level_3 = 70
	heat_level_1 = 320
	heat_level_2 = 370
	heat_level_3 = 600

	species_abilities = list(
		/mob/living/carbon/human/proc/sonar_ping,
		/mob/living/carbon/human/proc/resomi_hide
	)

	unarmed_type = /datum/unarmed_attack/claws


/datum/species/teshari/can_push_atom(mob/M)
	if(ishuman(M) && !issmall(M))
		return FALSE
	return ..()


/mob/living/carbon/human
	var/next_sonar_ping = 0

/mob/living/carbon/human/proc/sonar_ping()
	set category = "IC"
	set name = "Listen In"
	set desc = "Allows you to listen in to movement and noises around you."

	if(incapacitated())
		to_chat(src, "<span class='warning'>You need to recover before you can use this ability.</span>")
		return
	if(world.time < next_sonar_ping)
		to_chat(src, "<span class='warning'>You need another moment to focus.</span>")
		return
	if(!can_hear() || is_below_sound_pressure(get_turf(src)))
		to_chat(src, "<span class='warning'>You are for all intents and purposes currently deaf!</span>")
		return

	next_sonar_ping = world.time + 10 SECONDS

	var/heard_something = FALSE
	to_chat(src, "<span class='notice'>You take a moment to listen in to your environment...</span>")
	for(var/mob/living/L in range(client.view, src))
		var/turf/T = get_turf(L)
		if(!T || L == src || L.stat == DEAD || is_below_sound_pressure(T))
			continue
		heard_something = TRUE

		var/feedback = list()
		feedback += "<span class='notice'>There are noises of movement "
		var/direction = get_dir(src, L)
		if(direction)
			feedback += "towards the [dir2text(direction)], "
			switch(get_dist(src, L) / client.view)
				if(0 to 0.2)
					feedback += "very close by."
				if(0.2 to 0.4)
					feedback += "close by."
				if(0.4 to 0.6)
					feedback += "some distance away."
				if(0.6 to 0.8)
					feedback += "further away."
				else
					feedback += "far away."
		else // No need to check distance if they're standing right on-top of us
			feedback += "right on top of you."
		feedback += "</span>"

		to_chat(src, jointext(feedback, null))

	if(!heard_something)
		to_chat(src, "<span class='notice'>You hear no movement but your own.</span>")

/mob/living/carbon/human/proc/resomi_hide()
	set category = "IC"
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."

	if(incapacitated())
		return

	if(layer != WIRE_TERMINAL_LAYER)
		layer = WIRE_TERMINAL_LAYER // just above cables
		to_chat(src, "<span class='notice'>You are now hiding.</span>")
	else
		layer = MOB_LAYER
		to_chat(src, "<span class='notice'>You are no longer hiding.</span>")