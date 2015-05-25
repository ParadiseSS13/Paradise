/datum/species/wryn
	name = "Wryn"
	icobase = 'icons/mob/human_races/r_wryn.dmi'
	deform = 'icons/mob/human_races/r_wryn.dmi'
	language = "Wryn Hivemind"
	tail = "wryntail"
	unarmed_type = /datum/unarmed_attack/punch/weak
	//primitive = /mob/living/carbon/monkey/wryn
	darksight = 3
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
		"heart" =    /obj/item/organ/heart,
		"brain" =    /obj/item/organ/brain,
		"eyes" =     /obj/item/organ/eyes,
		"appendix" = /obj/item/organ/appendix,
		"antennae" =    /obj/item/organ/wryn/hivenode
		)

	flags = IS_WHITELISTED | HAS_LIPS | HAS_UNDERWEAR | NO_BREATHE | HAS_SKIN_COLOR | NO_SCAN | NO_SCAN | HIVEMIND
	dietflags = DIET_HERB		//bees feed off nectar, so bee people feed off plants too

	base_color = "#704300"
	flesh_color = "#704300"
	blood_color = "#FFFF99"


/datum/species/wryn/handle_death(var/mob/living/carbon/human/H)
	for(var/mob/living/carbon/C in living_mob_list)
		if(locate(/obj/item/organ/wryn/hivenode) in C.internal_organs)
			C << "<span class='danger'><B>Your antennae tingle as you are overcome with pain...</B></span>"
			C << "<span class='danger'>It feels like part of you has died.</span>"

/datum/species/wryn/handle_attack_hand(var/mob/living/carbon/human/H, var/mob/living/carbon/human/M)
	if(M.a_intent == "harm")
		if(H.handcuffed)
			if(!(locate(H.internal_organs_by_name["antennae"]) in H.internal_organs))	return
			var/turf/p_loc = M.loc
			var/turf/p_loc_m = H.loc

			M.visible_message("<span class='notice'>[M] begins to violently pull off [H]'s antennae.</span>")
			H << "<span class='danger'><B>[M] grips your antennae and starts violently pulling!<B></span>"
			do_after(H, 250)
			if(p_loc == M.loc && p_loc_m == H.loc)
				del(H.internal_organs_by_name["antennae"])
				H.remove_language("Wryn Hivemind")
				new /obj/item/organ/wryn/hivenode(M.loc)
				M << "<span class='notice'>You hear a loud crunch as you mercilessly pull off [H]'s antennae.</span>"
				H << "<span class='danger'><B>You hear a loud crunch as your antennae is ripped off your head by [M].</span></B>"
				H << "<span class='danger'><span class='danger'><B>It's so quiet...</B></span>"
				H.h_style = "Bald"
				H.update_hair()

				M.attack_log += text("\[[time_stamp()]\] <font color='red'>removed antennae [H.name] ([H.ckey])</font>")
				H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their antennae removed by [M.name] ([M.ckey])</font>")
				msg_admin_attack("[key_name(M)] removed [key_name(H)]'s antennae")
			return 0

/datum/species/nucleation
	name = "Nucleation"
	icobase = 'icons/mob/human_races/r_nucleation.dmi'
	unarmed_type = /datum/unarmed_attack/punch
	blurb = "A sub-race of unforunates who have been exposed to too much supermatter radiation. As a result, \
	supermatter crystal clusters have begun to grow across their bodies. Research to find a cure for this ailment \
	has been slow, and so this is a common fate for veteran engineers. The supermatter crystals produce oxygen, \
	negating the need for the individual to breath. Their massive change in biology, however, renders most medicines \
	obselete. Ionizing radiation seems to cause resonance in some of their crystals, which seems to encourage regeneration \
	and produces a calming effect on the individual. Nucleations are highly stigmatized, and are treated much in the same \
	way as lepers were back on Earth."
	language = "Sol Common"
	burn_mod = 4 // holy shite, poor guys wont survive half a second cooking smores
	brute_mod = 2 // damn, double wham, double dam
	flags = IS_WHITELISTED | NO_BREATHE | NO_BLOOD | NO_PAIN | HAS_LIPS | NO_SCAN
	dietflags = DIET_OMNI		//still human at their core, so they maintain their eating habits and diet

	has_organ = list(
		"heart" =    /obj/item/organ/heart,
		"crystalized brain" =    /obj/item/organ/brain/crystal,
		"eyes" =     /obj/item/organ/eyes/luminescent_crystal,
		"strange crystal" = /obj/item/organ/nucleation/strange_crystal,
		"resonant crystal" = /obj/item/organ/nucleation/resonant_crystal
		)

/datum/species/nucleation/handle_post_spawn(var/mob/living/carbon/human/H)
	H.light_color = "#1C1C00"
	H.set_light(2)
	return ..()

/datum/species/nucleation/handle_death(var/mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	H.visible_message("\red[H]'s body explodes, leaving behind a pile of microscopic crystals!")
	supermatter_delamination(T, 2, 0, 0) // Create a small supermatter burst upon death
	new /obj/item/weapon/shard/supermatter( T )
	del(H)