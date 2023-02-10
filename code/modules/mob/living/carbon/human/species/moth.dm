#define COCOON_WEAVE_DELAY 5 SECONDS
#define COCOON_EMERGE_DELAY 15 SECONDS
#define COCOON_HARM_AMOUNT 50
#define COCOON_NUTRITION_REQUIREMENT 201
#define COCOON_NUTRITION_AMOUNT -200
#define FLYSWATTER_DAMAGE_MULTIPLIER 9

/datum/species/moth
	name = "Nian"
	name_plural = "Nianae"
	language = "Tkachi"
	icobase = 'icons/mob/human_races/r_moth.dmi'
	deform = 'icons/mob/human_races/r_moth.dmi'
	inherent_factions = list("moth")
	species_traits = list(IS_WHITELISTED)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT
	bodyflags = HAS_HEAD_ACCESSORY | HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS | HAS_WING | HAS_SKIN_COLOR
	reagent_tag = PROCESS_ORG
	tox_mod = 1.5
	blood_species = "Nian"
	blood_color = "#b9ae9c"
	unarmed_type = /datum/unarmed_attack/claws
	scream_verb = "жужжит"
	female_giggle_sound = 'sound/voice/mothchitter.ogg'
	male_giggle_sound = 'sound/voice/mothchitter.ogg'
	male_scream_sound = 'sound/voice/scream_moth.ogg'
	female_scream_sound = 'sound/voice/scream_moth.ogg'
	male_sneeze_sound = 'sound/effects/mob_effects/mothsneeze.ogg'
	female_sneeze_sound = 'sound/effects/mob_effects/mothsneeze.ogg'
	female_laugh_sound = 'sound/voice/mothlaugh.ogg'
	male_laugh_sound = 'sound/voice/mothlaugh.ogg'
	female_cough_sounds = 'sound/effects/mob_effects/mothcough.ogg'
	male_cough_sounds = 'sound/effects/mob_effects/mothcough.ogg'
	default_headacc = "Plain Antennae"
	default_headacc_colour = "#F7D896"
	default_bodyacc = "Plain Wings"
	wing = "plain"
	eyes = "moth_eyes_s"
	butt_sprite = "nian"
	siemens_coeff = 1.5

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/nian,
		"lungs" =    /obj/item/organ/internal/lungs/nian,
		"liver" =    /obj/item/organ/internal/liver/nian,
		"kidneys" =  /obj/item/organ/internal/kidneys/nian,
		"brain" =    /obj/item/organ/internal/brain/nian,
		"eyes" =     /obj/item/organ/internal/eyes/nian
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
		"wing" =   list("path" = /obj/item/organ/external/wing/nian))

	optional_body_accessory = FALSE

	var/datum/action/innate/cocoon/cocoon

	suicide_messages = list(
		"откусывает свои усики!",
		"вспарывает себе живот!",
		"отрывает себе крылья!",
		"заддерживает своё дыхание!"
	)
	toxic_food = MEAT | JUNKFOOD
	disliked_food = FRIED | RAW | EGG
	liked_food = SUGAR | GROSS | FRUIT | VEGETABLES

/datum/species/moth/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_flap
	var/datum/action/innate/cocoon/cocoon = locate() in H.actions
	if(!cocoon)
		cocoon = new
		cocoon.Grant(H)
	RegisterSignal(H, COMSIG_LIVING_FIRE_TICK, .proc/check_burn_wings)
	RegisterSignal(H, COMSIG_LIVING_AHEAL, .proc/on_aheal)
	RegisterSignal(H, COMSIG_HUMAN_CHANGE_BODY_ACCESSORY, .proc/on_change_body_accessory)
	RegisterSignal(H, COMSIG_HUMAN_CHANGE_HEAD_ACCESSORY, .proc/on_change_head_accessory)

/datum/species/moth/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_flap
	var/datum/action/innate/cocoon/cocoon = locate() in H.actions
	if(cocoon)
		cocoon.Remove(H)
	UnregisterSignal(H, COMSIG_LIVING_FIRE_TICK)
	UnregisterSignal(H, COMSIG_LIVING_AHEAL)
	UnregisterSignal(H, COMSIG_HUMAN_CHANGE_BODY_ACCESSORY)
	UnregisterSignal(H, COMSIG_HUMAN_CHANGE_HEAD_ACCESSORY)
	H.remove_status_effect(STATUS_EFFECT_BURNT_WINGS)

/datum/species/moth/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return TRUE

	return ..()

/datum/species/moth/get_species_runechat_color(mob/living/carbon/human/H)
	return H.m_colours["body"]

/datum/species/moth/spec_attacked_by(obj/item/I, mob/living/user, obj/item/organ/external/affecting, intent, mob/living/carbon/human/H)
	if(istype(I, /obj/item/melee/flyswatter) && I.force)
		apply_damage(I.force * FLYSWATTER_DAMAGE_MULTIPLIER, I.damtype, affecting, FALSE, H) //making flyswatters do 10x damage to moff

/datum/species/moth/spec_Process_Spacemove(mob/living/carbon/human/H)
	var/turf/A = get_turf(H)
	if(isspaceturf(A))
		return FALSE
	if(H.has_status_effect(STATUS_EFFECT_BURNT_WINGS) || !H.bodypart_wing)
		return FALSE
	var/datum/gas_mixture/current = A.return_air()
	if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85))//as long as there's reasonable pressure and no gravity, flight is possible
		return TRUE

/datum/species/moth/spec_thunk(mob/living/carbon/human/H)
	if(!H.has_status_effect(STATUS_EFFECT_BURNT_WINGS))
		return TRUE

/datum/species/moth/spec_movement_delay()
	return FALSE

/datum/species/moth/spec_WakeUp(mob/living/carbon/human/H)
	if(H.has_status_effect(STATUS_EFFECT_COCOONED))
		return TRUE //Cocooned mobs dont get to wake up

/datum/species/moth/proc/check_burn_wings(mob/living/carbon/human/H) //do not go into the extremely hot light. you will not survive
	SIGNAL_HANDLER
	if(H.on_fire && !H.has_status_effect(STATUS_EFFECT_BURNT_WINGS) && H.bodytemperature >= 400 && H.fire_stacks > 0)
		to_chat(H, "<span class='warning'>Your precious wings burn to a crisp!</span>")
		H.apply_status_effect(STATUS_EFFECT_BURNT_WINGS)

/datum/species/moth/proc/on_aheal(mob/living/carbon/human/H)
	SIGNAL_HANDLER
	H.remove_status_effect(STATUS_EFFECT_BURNT_WINGS)

/datum/species/moth/proc/on_change_body_accessory(mob/living/carbon/human/H)
	SIGNAL_HANDLER
	if(H.has_status_effect(STATUS_EFFECT_BURNT_WINGS))
		return COMSIG_HUMAN_NO_CHANGE_APPEARANCE

/datum/species/moth/proc/on_change_head_accessory(mob/living/carbon/human/H)
	SIGNAL_HANDLER
	if(H.has_status_effect(STATUS_EFFECT_BURNT_WINGS))
		return COMSIG_HUMAN_NO_CHANGE_APPEARANCE

/datum/action/innate/cocoon
	name = "Cocoon"
	desc = "Restore your wings and antennae, and heal some damage. If your cocoon is broken externally you will take heavy damage!"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS|AB_CHECK_TURF
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "cocoon1"

/datum/action/innate/cocoon/Activate()
	var/mob/living/carbon/human/moth/H = owner
	if(H.nutrition < COCOON_NUTRITION_AMOUNT)
		to_chat(H, "<span class='warning'>You are too hungry to cocoon!</span>")
		return
	H.visible_message("<span class='notice'>[H] begins to hold still and concentrate on weaving a cocoon...</span>", "<span class='notice'>You begin to focus on weaving a cocoon... (This will take [COCOON_WEAVE_DELAY / 10] seconds, and you must hold still.)</span>")
	if(do_after(H, COCOON_WEAVE_DELAY, FALSE, H))
		if(H.incapacitated())
			to_chat(H, "<span class='warning'>You cannot weave a cocoon in your current state.</span>")
			return
		H.visible_message("<span class='notice'>[H] finishes weaving a cocoon!</span>", "<span class='notice'>You finish weaving your cocoon.</span>")
		add_game_logs("weaved [src] at [AREACOORD(H)].", H)
		var/obj/structure/moth/cocoon/C = new(get_turf(H))
		H.forceMove(C)
		C.preparing_to_emerge = TRUE
		H.apply_status_effect(STATUS_EFFECT_COCOONED)
		H.KnockOut()
		addtimer(CALLBACK(src, .proc/emerge, C), COCOON_EMERGE_DELAY, TIMER_UNIQUE)
	else
		to_chat(H, "<span class='warning'>You need to hold still in order to weave a cocoon!</span>")

/**
 * Removes moth from cocoon, restores burnt wings */

/datum/action/innate/cocoon/proc/emerge(obj/structure/moth/cocoon/C)
	for(var/mob/living/carbon/human/H in C.contents)
		H.remove_status_effect(STATUS_EFFECT_COCOONED)
		H.remove_status_effect(STATUS_EFFECT_BURNT_WINGS)
	C.preparing_to_emerge = FALSE
	qdel(C)

/obj/structure/moth/cocoon
	name = "\improper Nian cocoon"
	desc = "Someone wrapped in a Nian cocoon."
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon1"
	color = COLOR_PALE_YELLOW //So tiders (hopefully) don't decide to immediately bust them open
	max_integrity = 60
	var/preparing_to_emerge

/obj/structure/moth/cocoon/Initialize(mapload)
	. = ..()
	icon_state = pick("cocoon1", "cocoon2", "cocoon3")

/obj/structure/moth/cocoon/Destroy()
	if(!preparing_to_emerge)
		visible_message("<span class='danger'>[src] splits open from within!</span>")
	else
		visible_message("<span class='danger'>[src] is smashed open, harming the Nian within!</span>")
		for(var/mob/living/carbon/human/H in contents)
			H.adjustBruteLoss(COCOON_HARM_AMOUNT)
			H.adjustFireLoss(COCOON_HARM_AMOUNT)
			H.AdjustWeakened(5)

	for(var/mob/living/carbon/human/H in contents)
		H.remove_status_effect(STATUS_EFFECT_COCOONED)
		H.adjust_nutrition(COCOON_NUTRITION_AMOUNT)
		H.WakeUp()
		H.forceMove(loc)
	return ..()

/datum/status_effect/burnt_wings
	id = "burnt_wings"
	alert_type = null

/datum/status_effect/burnt_wings/on_creation(mob/living/new_owner, ...)
	var/mob/living/carbon/human/H = new_owner
	if(istype(H))
		H.change_head_accessory("Burnt Off Antennae")
		H.change_body_accessory("Burnt Off Wings", H)
	return ..()

/datum/status_effect/burnt_wings/on_remove()
	owner.UpdateAppearance()
	return ..()

/datum/status_effect/cocooned
	id = "cocooned"
	alert_type = null

#undef COCOON_WEAVE_DELAY
#undef COCOON_EMERGE_DELAY
#undef COCOON_HARM_AMOUNT
#undef COCOON_NUTRITION_AMOUNT
#undef FLYSWATTER_DAMAGE_MULTIPLIER
