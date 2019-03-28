/datum/species/wryn
	name = "Wryn"
	name_plural = "Wryn"
	icobase = 'icons/mob/human_races/r_wryn.dmi'
	deform = 'icons/mob/human_races/r_wryn.dmi'
	blacklisted = TRUE
	language = "Wryn Hivemind"
	tail = "wryntail"
	punchdamagelow = 0
	punchdamagehigh = 1
	slowdown = 1
	warning_low_pressure = -300
	hazard_low_pressure = 1
	blurb = "The wryn (r-in, singular r-in) are a humanoid race that possess many bee-like features. Originating from Alveare they \
	have adapted extremely well to cold environments though have lost most of their muscles over generations.\
	In order to communicate and work with multi-species crew Wryn were forced to take on names. Wryn have tended towards using only \
	first names, these names are generally simplistic and easy to pronounce. Wryn have rarely had to communicate using their mouths, \
	so in order to integrate with the multi-species crew they have been taught broken sol?."

	cold_level_1 = 200 //Default 260 - Lower is better
	cold_level_2 = 150 //Default 200
	cold_level_3 = 115 //Default 120

	heat_level_1 = 300 //Default 360 - Higher is better
	heat_level_2 = 310 //Default 400
	heat_level_3 = 317 //Default 1000

	body_temperature = 286

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"brain" =    /obj/item/organ/internal/brain,
		"eyes" =     /obj/item/organ/internal/eyes/wryn, //3 darksight.
		"appendix" = /obj/item/organ/internal/appendix,
		"antennae" =    /obj/item/organ/internal/wryn/hivenode
		)

	species_traits = list(IS_WHITELISTED, NO_BREATHE, HAS_SKIN_COLOR, NO_SCAN, HIVEMIND)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	dietflags = DIET_HERB		//bees feed off nectar, so bee people feed off plants too

	dies_at_threshold = TRUE

	reagent_tag = PROCESS_ORG
	base_color = "#704300"
	flesh_color = "#704300"
	blood_color = "#FFFF99"
	//Default styles for created mobs.
	default_hair = "Antennae"


/datum/species/wryn/handle_death(mob/living/carbon/human/H)
	for(var/mob/living/carbon/C in GLOB.living_mob_list)
		if(C.get_int_organ(/obj/item/organ/internal/wryn/hivenode))
			to_chat(C, "<span class='danger'><B>Your antennae tingle as you are overcome with pain...</B></span>")
			to_chat(C, "<span class='danger'>It feels like part of you has died.</span>") // This is bullshit

/datum/species/wryn/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.handcuffed && target.get_int_organ(/obj/item/organ/internal/wryn/hivenode))

		user.visible_message("<span class='notice'>[user] begins to violently pull off [target]'s antennae.</span>")
		to_chat(target, "<span class='danger'><B>[user] grips your antennae and starts violently pulling!<B></span>")
		if(do_mob(user, target, 250))
			var/obj/item/organ/internal/wryn/hivenode/node = new /obj/item/organ/internal/wryn/hivenode
			target.remove_language("Wryn Hivemind")
			node.remove(target)
			node.forceMove(user.loc)
			to_chat(user, "<span class='notice'>You hear a loud crunch as you mercilessly pull off [target]'s antennae.</span>")
			to_chat(target, "<span class='danger'>You hear a loud crunch as your antennae is ripped off your head by [user].</span>")
			to_chat(target, "<span class='danger'><B>It's so quiet...</B></span>")
			var/obj/item/organ/external/head/head_organ = target.get_organ("head")
			head_organ.h_style = "Bald"
			target.update_hair()

			add_attack_logs(user, target, "Antennae removed")
		return 0
	else
		..()