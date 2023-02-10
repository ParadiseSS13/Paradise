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
		"antennae" = /obj/item/organ/internal/wryn/hivenode,
		"glands" = 	 /obj/item/organ/internal/wryn/glands
		)

	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest),
		"groin" =  list("path" = /obj/item/organ/external/groin),
		"head" =   list("path" = /obj/item/organ/external/head),
		"l_arm" =  list("path" = /obj/item/organ/external/arm),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right),
		"l_leg" =  list("path" = /obj/item/organ/external/leg),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right),
		"l_hand" = list("path" = /obj/item/organ/external/hand),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right),
		"l_foot" = list("path" = /obj/item/organ/external/foot),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right),
		"tail" =   list("path" = /obj/item/organ/external/tail/wryn))

	species_traits = list(LIPS, IS_WHITELISTED, NO_BREATHE, NO_SCAN, HIVEMIND)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR

	dies_at_threshold = TRUE

	reagent_tag = PROCESS_ORG
	base_color = "#704300"
	flesh_color = "#704300"
	blood_color = "#FFFF99"
	blood_species = "Wryn"
	//Default styles for created mobs.
	default_hair = "Antennae"

/datum/species/wryn/on_species_gain(mob/living/carbon/human/H)
	..()
	var/datum/action/innate/wryn_sting/wryn_sting = locate() in H.actions
	if(!wryn_sting)
		wryn_sting = new
		wryn_sting.Grant(H)

/datum/species/wryn/on_species_loss(mob/living/carbon/human/H)
	..()
	var/datum/action/innate/wryn_sting/wryn_sting = locate() in H.actions
	if(wryn_sting)
		wryn_sting.Remove(H)

/* Wryn Sting Action Begin */

//Define the Sting Action
/datum/action/innate/wryn_sting
	name = "Жало врина"
	desc = "Подготовка жала к ужаливанию."
	button_icon_state = "wryn_sting_off"		//Default Button State
	check_flags = AB_CHECK_LYING | AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED
	var/button_on = FALSE

//What happens when you click the Button?
/datum/action/innate/wryn_sting/Trigger()
	if(!..())
		return
	var/mob/living/carbon/user = owner
	if((user.restrained() && user.pulledby) || user.buckled) //Is your Wryn restrained, pulled, or buckled? No stinging!
		to_chat(user, "<span class='notice'>Вам нужна свобода передвижения, чтобы ужалить кого-то!</span>")
		return
	if(user.wear_suit)	//Is your Wryn wearing a Hardsuit or a Laboat that's blocking their Stinger?
		to_chat(user, "<span class='notice'>Для использования жала нужно снять верхнюю одежду.</span>")
		return
	if(user.getStaminaLoss() >= 50)	//Does your Wryn have enough Stamina to sting?
		to_chat(user, "<span class='notice'>Вы слишком устали для использования жала.</span>")
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
/datum/action/innate/wryn_sting/proc/select_target(var/mob/living/carbon/human/user)
	var/list/names = list()
	for(var/mob/living/carbon/human/M in orange(1))
		names += M
	var/target = input("Select a Target: ", "Sting Target", null) as null|anything in names
	if(!target)		//No one's around!
		to_chat(user, "<span class='warning'>Вокруг некого жалить! Жало втягивается обратно.</span>")
		user.visible_message("<span class='warning'[user] втягивает своё жало.</span>")
		button_on = FALSE
		UpdateButtonIcon()
		return
	else			//Get ready, aim, fire!
		user.visible_message("<span class='warning'> [user] собирается применить жало!</span>")
		sting_target(user, target)
	return

//What does the Wryn Sting do?
/datum/action/innate/wryn_sting/proc/sting_target(mob/living/carbon/human/user, mob/living/carbon/human/target)
	button_on = FALSE					//For when we Update the Button Icon
	if(!(target in orange(1, user)))	//Dang, did they get away?
		to_chat(user, "<span class='warning'>Вы слишком далеко от [target]. Жало втягивается.</span>")
		user.visible_message("<span class='warning'[user] убирает свое жало.</span>")
		UpdateButtonIcon()
		return
	else								//Nah, that chump is still here! Sting 'em! Sting 'em good!
		var/obj/item/organ/external/organ = target.get_organ(pick("l_leg", "r_leg", "l_foot", "r_foot", "groin"))
		to_chat(user, "<span class='danger'> Вы жалите [target] в [organ]!</span>")
		user.visible_message("<span class='danger'>[user] жалит [target] в [organ]! </span>")
		user.adjustStaminaLoss(20)		//You can't sting infinitely, Wryn - take some Stamina loss
		var/dam = rand(3, 7)
		target.apply_damage(dam, BRUTE, organ)
		playsound(user.loc, 'sound/weapons/bladeslice.ogg', 50, 0)
		add_attack_logs(user, target, "Stung by Wryn Stinger - [dam] Brute damage to [organ].")
		if(target.restrained())			//Apply tiny BURN damage if target is restrained
			if(prob(50))
				user.apply_damage(2, BURN, target)
				to_chat(target, "<span class='danger'>Вы ощущаете небольшое жжение! Ауч!</span>")
				user.visible_message("<span class='danger'>[user] выглядит ужаленным!</span>")
		UpdateButtonIcon()
		return

/* Wryn Sting Action End */

/datum/species/wryn/handle_death(gibbed, mob/living/carbon/human/H)
	for(var/mob/living/carbon/C in GLOB.alive_mob_list)
		if(C.get_int_organ(/obj/item/organ/internal/wryn/hivenode))
			to_chat(C, "<span class='danger'><B>Ваши усики дрожат, когда вас одолевает боль...</B></span>")
			to_chat(C, "<span class='danger'>Такое ощущение, что часть вас умерла.</span>") // This is bullshit -- Да, согласен.

/datum/species/wryn/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	var/obj/item/organ/internal/wryn/hivenode/node = target.get_int_organ(/obj/item/organ/internal/wryn/hivenode)
	if(target.handcuffed && node && user.zone_selected == "head")
		switch(alert(user, "Вы хотите вырвать усики этому существу?", "OH SHIT", "Да", "Нет"))
			if("Да")
				user.visible_message("<span class='notice'>[user] начина[pluralize_ru(user.gender,"ет","ют")] яростно отрывать усики [target].</span>")
				to_chat(target, "<span class='danger'><B>[user] схватил[genderize_ru(user.gender,"","а","о","и")] ваши усики и яростно тян[pluralize_ru(user.gender,"ет","ут")] их!<B></span>")
				if(do_mob(user, target, 250))
					target.remove_language("Wryn Hivemind")
					node.remove(target)
					node.forceMove(get_turf(target))
					to_chat(user, "<span class='notice'>Вы слышите громкий хруст, когда безжалостно отрываете усики [target].</span>")
					to_chat(target, "<span class='danger'>Вы слышите невыносимый хруст, когда [user] вырыва[pluralize_ru(user.gender,"ет","ют")] усики из вашей головы.</span>")
					to_chat(target, "<span class='danger'><B>Стало так тихо...</B></span>")
					var/obj/item/organ/external/head/head_organ = target.get_organ("head")
					head_organ.h_style = "Bald"
					target.update_hair()

					add_attack_logs(user, target, "Antennae removed")
				return 0
			if("Нет")
				..()
	else
		..()

/mob/living/carbon/human/proc/adjustWax(amount)
 	var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
 	if(!glands) return
 	glands.wax = clamp(glands.wax + amount, 0, 75)
 	return 1

/mob/living/carbon/human/proc/getWax()
 	var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
 	if(!glands) return 0
 	return glands.wax

/mob/living/carbon/human/proc/toggle_producing()
	var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
	if(glands)
		to_chat(usr, "<span class='notice'>Вы [glands.producing ? "расслабляете" : "напрягаете"] восковые железы</span>")
		glands.producing = !glands.producing

/mob/living/carbon/human/proc/get_producing()
 	var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
 	return glands ? glands.producing : FALSE
