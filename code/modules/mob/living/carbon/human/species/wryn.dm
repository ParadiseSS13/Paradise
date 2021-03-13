/datum/species/wryn
	name = "Wryn"
	name_plural = "Wryn"
	icobase = 'icons/mob/human_races/r_wryn.dmi'
	blacklisted = TRUE
	language = "Wryn Hivemind"
	tail = "wryntail"
	punchdamagelow = 0
	punchdamagehigh = 1
	speed_mod = 1
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

	species_traits = list(LIPS, IS_WHITELISTED, NO_CLONESCAN, HIVEMIND)
	inherent_traits = list(TRAIT_NOBREATH)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR
	dietflags = DIET_HERB		//bees feed off nectar, so bee people feed off plants too

	dies_at_threshold = TRUE

	reagent_tag = PROCESS_ORG
	base_color = "#704300"
	flesh_color = "#704300"
	blood_color = "#FFFF99"
	//Default styles for created mobs.
	default_hair = "Antennae"

	var/datum/action/innate/wryn_sting/wryn_sting

/datum/species/wryn/on_species_gain(mob/living/carbon/human/H)
	..()
	wryn_sting = new
	wryn_sting.Grant(H)

/datum/species/wryn/on_species_loss(mob/living/carbon/human/H)
	..()
	if(wryn_sting)
		wryn_sting.Remove(H)

/* Wryn Sting Action Begin */

//Define the Sting Action
/datum/action/innate/wryn_sting
	name = "Wryn Sting"
	desc = "Readies Wryn Sting for stinging."
	button_icon_state = "wryn_sting_off"		//Default Button State
	check_flags = AB_CHECK_LYING | AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED
	var/button_on = FALSE

//What happens when you click the Button?
/datum/action/innate/wryn_sting/Trigger()
	if(!..())
		return
	var/mob/living/carbon/user = owner
	if((user.restrained() && user.pulledby) || user.buckled) //Is your Wryn restrained, pulled, or buckled? No stinging!
		to_chat(user, "<span class='notice'>You need freedom of movement to sting someone!</span>")
		return
	if(user.wear_suit)	//Is your Wryn wearing a Hardsuit or a Laboat that's blocking their Stinger?
		to_chat(user, "<span class='notice'>You must remove your hardsuit, labcoat, or jacket before using your Wryn stinger.</span>")
		return
	if(user.getStaminaLoss() >= 50)	//Does your Wryn have enough Stamina to sting?
		to_chat(user, "<span class='notice'>You feel too tired to use your Wryn Stinger at the moment.</span>")
		return
	else
		button_on = TRUE
		UpdateButtonIcon()
		select_target(user)

//Update the Button Icon
/datum/action/innate/wryn_sting/UpdateButtonIcon()
	if(button_on)
		button_icon_state = "wryn_sting_on"
		name = "Wryn Stinger \[READY\]"
		button.name = name
	else
		button_icon_state = "wryn_sting_off"
		name = "Wryn Stinger"
		button.name = name
	..()

//Select a Target from a List
/datum/action/innate/wryn_sting/proc/select_target(mob/living/carbon/human/user)
	var/list/names = list()
	for(var/mob/living/carbon/human/M in orange(1))
		names += M
	var/target = input("Select a Target: ", "Sting Target", null) as null|anything in names
	if(!target)		//No one's around!
		to_chat(user, "<span class='warning'>There's no one around to sting so you retract your stinger.</span>")
		user.visible_message("<span class='warning'[user] retracts their stinger.</span>")
		button_on = FALSE
		UpdateButtonIcon()
		return
	else			//Get ready, aim, fire!
		user.visible_message("<span class='warning'> [user] prepares to use their Wryn stinger!</span>")
		sting_target(user, target)
	return

//What does the Wryn Sting do?
/datum/action/innate/wryn_sting/proc/sting_target(mob/living/carbon/human/user, mob/living/carbon/human/target)
	button_on = FALSE					//For when we Update the Button Icon
	if(!(target in orange(1, user)))	//Dang, did they get away?
		to_chat(user, "<span class='warning'>You are no longer adjacent to [target]. You retract your stinger for now.</span>")
		user.visible_message("<span class='warning'[user] retracts their stinger.</span>")
		UpdateButtonIcon()
		return
	else								//Nah, that chump is still here! Sting 'em! Sting 'em good!
		var/obj/item/organ/external/organ = target.get_organ(pick("l_leg", "r_leg", "l_foot", "r_foot", "groin"))
		to_chat(user, "<span class='danger'> You sting [target] in their [organ] with your stinger!</span>")
		user.visible_message("<span class='danger'>[user] stings [target] in [organ] with their stinger! </span>")
		user.adjustStaminaLoss(20)		//You can't sting infinitely, Wryn - take some Stamina loss
		var/dam = rand(3, 7)
		target.apply_damage(dam, BRUTE, organ)
		playsound(user.loc, 'sound/weapons/bladeslice.ogg', 50, 0)
		add_attack_logs(user, target, "Stung by Wryn Stinger - [dam] Brute damage to [organ].")
		if(target.restrained())			//Apply tiny BURN damage if target is restrained
			if(prob(50))
				user.apply_damage(2, BURN, target)
				to_chat(target, "<span class='danger'>You feel a little burnt! Yowch!</span>")
				user.visible_message("<span class='danger'>[user] is looking a little burnt!</span>")
		UpdateButtonIcon()
		return

/* Wryn Sting Action End */

/datum/species/wryn/handle_death(gibbed, mob/living/carbon/human/H)
	for(var/mob/living/carbon/C in GLOB.alive_mob_list)
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
