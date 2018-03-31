/datum/species/wryn
	name = "Wryn"
	name_plural = "Wryn"
	icobase = 'icons/mob/human_races/r_wryn.dmi'
	deform = 'icons/mob/human_races/r_wryn.dmi'
	language = "Wryn Hivemind"
	tail = "wryntail"
	unarmed_type = /datum/unarmed_attack/punch/weak
	punchdamagelow = 0
	punchdamagehigh = 1
	//primitive = /mob/living/carbon/monkey/wryn
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

	oxy_mod = 0

	reagent_tag = PROCESS_ORG
	base_color = "#704300"
	flesh_color = "#704300"
	blood_color = "#FFFF99"
	//Default styles for created mobs.
	default_hair = "Antennae"


/datum/species/wryn/handle_death(var/mob/living/carbon/human/H)
	for(var/mob/living/carbon/C in living_mob_list)
		if(C.get_int_organ(/obj/item/organ/internal/wryn/hivenode))
			to_chat(C, "<span class='danger'><B>Your antennae tingle as you are overcome with pain...</B></span>")
			to_chat(C, "<span class='danger'>It feels like part of you has died.</span>")

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

/datum/species/nucleation
	name = "Nucleation"
	name_plural = "Nucleations"
	icobase = 'icons/mob/human_races/r_nucleation.dmi'
	unarmed_type = /datum/unarmed_attack/punch
	blurb = "A sub-race of unfortunates who have been exposed to too much supermatter radiation. As a result, \
	supermatter crystal clusters have begun to grow across their bodies. Research to find a cure for this ailment \
	has been slow, and so this is a common fate for veteran engineers. The supermatter crystals produce oxygen, \
	negating the need for the individual to breathe. Their massive change in biology, however, renders most medicines \
	obselete. Ionizing radiation seems to cause resonance in some of their crystals, which seems to encourage regeneration \
	and produces a calming effect on the individual. Nucleations are highly stigmatized, and are treated much in the same \
	way as lepers were back on Earth."
	language = "Sol Common"
	burn_mod = 4 // holy shite, poor guys wont survive half a second cooking smores
	brute_mod = 2 // damn, double wham, double dam
	oxy_mod = 0
	species_traits = list(LIPS, IS_WHITELISTED, NO_BREATHE, NO_BLOOD, NO_PAIN, NO_SCAN, RADIMMUNE)
	dietflags = DIET_OMNI		//still human at their core, so they maintain their eating habits and diet

	//Default styles for created mobs.
	default_hair = "Nucleation Crystals"

	reagent_tag = PROCESS_ORG
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"crystallized brain" =    /obj/item/organ/internal/brain/crystal,
		"eyes" =     /obj/item/organ/internal/eyes/luminescent_crystal, //Standard darksight of 2.
		"strange crystal" = /obj/item/organ/internal/nucleation/strange_crystal
		)
	vision_organ = /obj/item/organ/internal/eyes/luminescent_crystal

/datum/species/nucleation/handle_post_spawn(var/mob/living/carbon/human/H)
	H.light_color = "#1C1C00"
	H.set_light(2)
	return ..()

/datum/species/nucleation/handle_death(var/mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	H.visible_message("<span class='warning'>[H]'s body explodes, leaving behind a pile of microscopic crystals!</span>")
	explosion(T, 0, 0, 2, 2) // Create a small explosion burst upon death
//	new /obj/item/shard/supermatter( T )
	qdel(H)