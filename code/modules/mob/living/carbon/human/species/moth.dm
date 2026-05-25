#define COCOON_HARM_AMOUNT 50
#define COCOON_NUTRITION_AMOUNT -200

/datum/species/moth
	name = "Nian"
	name_plural = "Nianae"
	language = "Tkachi"
	icobase = 'icons/mob/human_races/nian/r_moth.dmi'
	inherent_factions = list("nian")
	species_traits = list()
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_HEAD_ACCESSORY | HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS | HAS_WING | SHAVED | HAS_ICON_SKIN_TONE
	reagent_tag = PROCESS_ORG
	dietflags = DIET_HERB
	tox_mod = 1.5

	blood_color = "#b9ae9c"

	unarmed_type = /datum/unarmed_attack/claws
	scream_verb = "buzzes"
	male_scream_sound = 'sound/voice/scream_moth.ogg'
	female_scream_sound = 'sound/voice/scream_moth.ogg'
	default_headacc = "Plain Antennae"
	default_bodyacc = "Plain Wings"
	wing = "plain"
	eyes = "moth_eyes_s"
	butt_sprite = "nian"
	siemens_coeff = 1.5
	blurb = "Nians are large bipedal invertebrates that come from an unknown homeworld. \
	Known for spendthrift behavior, the Nian civilization has been pressed to the fore of developed space in an effort to resolve material shortages in homeworld sectors.<br/><br/> \
	Unlike most species in the galactic fold, Nian do not recognize the authority of the Trans-Solar Federation: \
	having instead established close diplomatic relationships with their splinter faction, the USSP."

	icon_skin_tones = alist(
		1 = "Default Biege",
		2 = "Lighter",
		3 = "Darker",
		4 = "Purple"
	)

	meat_type = /obj/item/food/meat/human
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/nian,
		"lungs" =    /obj/item/organ/internal/lungs/nian,
		"liver" =    /obj/item/organ/internal/liver/nian,
		"kidneys" =  /obj/item/organ/internal/kidneys/nian,
		"brain" =    /obj/item/organ/internal/brain/nian,
		"eyes" =     /obj/item/organ/internal/eyes/nian
	)

	primitive_form = /datum/species/monkey/nian_worme

	optional_body_accessory = FALSE

	suicide_messages = list(
		"is attempting to nibble their antenna off!",
		"is twisting their own abdomen!",
		"is cracking their exoskeleton!",
		"is ripping their wings off!",
		"is holding their breath!"
	)

	plushie_type = /obj/item/toy/plushie/nianplushie

/datum/species/moth/updatespeciescolor(mob/living/carbon/human/H, owner_sensitive = 1) //Handling species-specific skin-tones for the nian race.
	if(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/new_icobase = 'icons/mob/human_races/nian/r_moth.dmi' //Default nian.
		switch(H.s_tone)
			if(4) //Purple Nian.
				new_icobase = 'icons/mob/human_races/nian/r_moth_purple.dmi'
			if(3) //Darker Nian.
				new_icobase = 'icons/mob/human_races/nian/r_moth_dark.dmi'
			if(2) //Lighter Nian.
				new_icobase = 'icons/mob/human_races/nian/r_moth_cream.dmi'
			else  //Default.
				new_icobase = 'icons/mob/human_races/nian/r_moth.dmi'

		H.change_icobase(new_icobase, owner_sensitive) //Update the icobase of all our organs, but make sure we don't mess with frankenstein limbs in doing so.

/datum/species/moth/on_species_gain(mob/living/carbon/human/H)
	..()
	var/datum/action/innate/cocoon/cocoon = new()
	cocoon.Grant(H)
	var/datum/action/innate/toggle_wings/wings_toggle = new()
	wings_toggle.Grant(H)
	RegisterSignal(H, COMSIG_LIVING_FIRE_TICK, PROC_REF(check_burn_wings))
	RegisterSignal(H, COMSIG_LIVING_AHEAL, PROC_REF(on_aheal))
	RegisterSignal(H, COMSIG_HUMAN_CHANGE_BODY_ACCESSORY, PROC_REF(on_change_body_accessory))
	RegisterSignal(H, COMSIG_HUMAN_CHANGE_HEAD_ACCESSORY, PROC_REF(on_change_head_accessory))

/datum/species/moth/on_species_loss(mob/living/carbon/human/H)
	..()
	for(var/datum/action/innate/cocoon/cocoon in H.actions)
		cocoon.Remove(H)
	for(var/datum/action/innate/toggle_wings/wings_toggle in H.actions)
		wings_toggle.Remove(H)
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

/datum/species/moth/spec_attacked_by(obj/item/I, mob/living/user, obj/item/organ/external/affecting, intent, mob/living/carbon/human/H)
	if(istype(I, /obj/item/melee/flyswatter) && I.force)
		apply_damage(I.force * FLYSWATTER_DAMAGE_MULTIPLIER, I.damtype, affecting, FALSE, H) //making flyswatters do 10x damage to moff

/datum/species/moth/spec_Process_Spacemove(mob/living/carbon/human/H)
	var/turf/A = get_turf(H)
	if(isspaceturf(A))
		return FALSE
	if(H.has_status_effect(STATUS_EFFECT_BURNT_WINGS))
		return FALSE
	if(isobj(H.loc))
		// Can't fly if you're in a box/mech/whatever.
		return FALSE
	// Open your wings to fly
	if(H.body_accessory && istype(H.body_accessory, /datum/body_accessory/wing))
		var/datum/body_accessory/wing/wings = H.body_accessory
		if(!wings.is_open)
			return FALSE
	var/turf/T = get_turf(H)
	var/datum/gas_mixture/current = T.get_readonly_air()
	if(current && (current.return_pressure() >= ONE_ATMOSPHERE * 0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
		return TRUE

/datum/species/moth/spec_thunk(mob/living/carbon/human/H)
	if(H.has_status_effect(STATUS_EFFECT_BURNT_WINGS))
		return FALSE

	if(H.body_accessory && istype(H.body_accessory, /datum/body_accessory/wing))
		var/datum/body_accessory/wing/wings = H.body_accessory
		if(!wings.is_open)
			return FALSE

	return TRUE

/datum/species/moth/spec_movement_delay()
	return FALSE

/datum/species/moth/spec_WakeUp(mob/living/carbon/human/H)
	if(H.has_status_effect(STATUS_EFFECT_COCOONED))
		return TRUE //Cocooned mobs dont get to wake up

/datum/species/moth/proc/check_burn_wings(mob/living/carbon/human/H) //do not go into the extremely hot light. you will not survive
	SIGNAL_HANDLER
	if(H.on_fire && !H.has_status_effect(STATUS_EFFECT_BURNT_WINGS) && H.bodytemperature >= 400 && H.fire_stacks > 0)
		to_chat(H, SPAN_WARNING("Your precious wings burn to a crisp!"))
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
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "cocoon1"

/datum/action/innate/cocoon/Activate()
	var/mob/living/carbon/human/moth/H = owner
	if(H.nutrition < COCOON_NUTRITION_AMOUNT)
		to_chat(H, SPAN_WARNING("You are too hungry to cocoon!"))
		return
	H.visible_message(SPAN_NOTICE("[H] begins to hold still and concentrate on weaving a cocoon..."), SPAN_NOTICE("You begin to focus on weaving a cocoon... (This will take [COCOON_WEAVE_DELAY / 10] seconds, and you must hold still.)"))
	if(do_after(H, COCOON_WEAVE_DELAY, FALSE, H))
		if(H.incapacitated())
			to_chat(H, SPAN_WARNING("You cannot weave a cocoon in your current state."))
			return
		H.visible_message(SPAN_NOTICE("[H] finishes weaving a cocoon!"), SPAN_NOTICE("You finish weaving your cocoon."))
		var/obj/structure/moth_cocoon/C = new(get_turf(H))
		H.forceMove(C)
		C.preparing_to_emerge = TRUE
		H.apply_status_effect(STATUS_EFFECT_COCOONED)
		H.KnockOut()
		H.create_log(MISC_LOG, "has woven a cocoon")
		addtimer(CALLBACK(src, PROC_REF(emerge), C), COCOON_EMERGE_DELAY, TIMER_UNIQUE)
	else
		to_chat(H, SPAN_WARNING("You need to hold still in order to weave a cocoon!"))

/datum/action/innate/toggle_wings
	name = "Toggle Wings"
	desc = "Open or close your wings! While your wings are open, you can fly in pressurized 0G environments!"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/sprite_accessories/moth/moth_wings.dmi'
	button_icon_state = "monarch_BEHIND"

/datum/action/innate/toggle_wings/Activate()
	owner.emote("wings")

/**
 * Removes moth from cocoon, restores burnt wings
 */
/datum/action/innate/cocoon/proc/emerge(obj/structure/moth_cocoon/C)
	for(var/mob/living/carbon/human/H in C.contents)
		H.remove_status_effect(STATUS_EFFECT_COCOONED)
		H.remove_status_effect(STATUS_EFFECT_BURNT_WINGS)
	C.preparing_to_emerge = FALSE
	qdel(C)

/obj/structure/moth_cocoon
	name = "\improper Nian cocoon"
	desc = "Someone wrapped in a Nian cocoon."
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon1"
	color = COLOR_PALE_YELLOW //So tiders (hopefully) don't decide to immediately bust them open
	max_integrity = 60
	var/preparing_to_emerge

/obj/structure/moth_cocoon/Initialize(mapload)
	. = ..()
	icon_state = pick("cocoon1", "cocoon2", "cocoon3")

/obj/structure/moth_cocoon/Destroy()
	if(!preparing_to_emerge)
		visible_message(SPAN_DANGER("[src] splits open from within!"))
	else
		visible_message(SPAN_DANGER("[src] is smashed open, harming the Nian within!"))
		for(var/mob/living/carbon/human/H in contents)
			H.adjustBruteLoss(COCOON_HARM_AMOUNT)
			H.adjustFireLoss(COCOON_HARM_AMOUNT)
			H.AdjustWeakened(10 SECONDS)

	for(var/mob/living/carbon/human/H in contents)
		H.remove_status_effect(STATUS_EFFECT_COCOONED)
		H.adjust_nutrition(COCOON_NUTRITION_AMOUNT)
		H.WakeUp()
		H.forceMove(loc)
		H.create_log(MISC_LOG, "has emerged from their cocoon with the nutrition level of [H.nutrition][H.nutrition <= NUTRITION_LEVEL_STARVING ? ", now starving" : ""]")
	return ..()

/datum/status_effect/burnt_wings
	id = "burnt_wings"
	alert_type = null

/datum/status_effect/burnt_wings/on_creation(mob/living/new_owner, ...)
	var/mob/living/carbon/human/H = new_owner
	if(istype(H))
		H.change_body_accessory("Burnt Off Wings")
		H.change_head_accessory("Burnt Off Antennae")
	return ..()

/datum/status_effect/burnt_wings/on_remove()
	owner.UpdateAppearance()
	return ..()

/datum/status_effect/cocooned
	id = "cocooned"
	alert_type = null

#undef COCOON_HARM_AMOUNT
#undef COCOON_NUTRITION_AMOUNT

/datum/species/moth/generate_random_appearance(mob/living/carbon/human/body, prosthesis_prob = 5)
	var/obj/item/organ/external/head/head_organ = body.get_organ("head")
	var/datum/robolimb/robohead
	if(head_organ)
		if(head_organ.dna.species.bodyflags & ALL_RPARTS)
			robohead = GLOB.all_robolimbs[head_organ.model]

	if(prob(prosthesis_prob))
		var/list/prostheses = randomize_chassis_brands()
		for(var/organ_name in prostheses)
			var/obj/item/organ/external/each_organ = body.bodyparts_by_name[organ_name]
			if(each_organ)
				each_organ.robotize(prostheses[organ_name].company)

	// Markings.
	body.m_styles["head"] = randomize_head_markings()
	body.m_colours["head"] = randomize_head_markings_color(body.m_styles["head"])
	// should get just "Reddish" from "Reddish Head Markings"
	var/marking_style = copytext(body.m_styles["head"], 1, -14)

	body.m_styles["body"] = "[marking_style] Markings"
	body.m_colours["body"] = body.m_colours["head"]

	// Accessories.
	body.m_styles["tail"] = "None"
	body.body_accessory = GLOB.body_accessory_by_name[randomize_body_accessory(100, marking_style)]
	var/accessory_style = copytext(body.body_accessory.name, 1, -6)

	head_organ.ha_style = randomize_head_accessory(50, marking_style, accessory_style)
	head_organ.headacc_colour = randomize_head_accessory_color(head_organ.ha_style)

	// Skin.
	body.s_tone = randomize_skin_tone(marking_style, accessory_style)

	// Hair
	head_organ.h_style = randomize_hair_style(robohead)
	var/list/hair_colors = randomize_hair_colors(robohead, body.s_tone, body.m_colours["head"])
	head_organ.hair_colour = hair_colors["h1"]
	head_organ.sec_hair_colour = hair_colors["h2"]
	head_organ.facial_colour = hair_colors["f1"]
	head_organ.sec_facial_colour = hair_colors["f2"]

	body.regenerate_icons()
	body.update_body()
	body.update_dna()

/datum/species/moth/randomize_skin_tone(marking_style, accessory_style)
	var/style_determiner = (marking_style && marking_style != "None") ? marking_style : accessory_style

	// If you know a better way of making skin tone determined by marking/accessory, do tell.
	switch(style_determiner)
		if("Atlas")
			return 1
		if("Brown")
			return pick(1, 2, 3)
		if("Deathshead")
			return pick(2, 3)
		if("Feathery")
			return 2
		if("Firewatch")
			return pick(1, 2)
		if("Gothic")
			return pick(2, 3, 4)
		if("Jungle")
			return 1
		if("Lightbearer")
			return pick(1, 2)
		if("Lovers")
			return pick(2, 4)
		if("Luna")
			return 1
		if("Monarch")
			return 1
		if("Moon Fly")
			return pick(2, 3, 4)
		if("Mothra")
			return pick(1, 2, 3)
		if("Oak Worm")
			return 1
		if("Plain")
			return 1
		if("Plasmafire")
			return pick(1, 4)
		if("Poison")
			return pick(2, 4)
		if("Ragged")
			return 1
		if("Reddish")
			return pick(1, 4)
		if("Rosy")
			return 1
		if("Royal")
			return 2
		if("Snow")
			return pick(2, 3)
		if("White Fly")
			return 2
	return ..()

/datum/species/moth/randomize_eye_color()
	if(prob(80))
		return COLOR_BLACK
	if(prob(1))
		return rand_hex_color()
	return rgb(rand(0, 360), rand(0, 70), rand(0, 20))

/datum/species/moth/randomize_hair_style(datum/robolimb/robohead, species_bald_prob = 70)
	return ..()

/datum/species/moth/randomize_hair_colors(datum/robolimb/robohead, body_color = null, marking_color = null)
	var/list/hair_colors = list(
		"h1" = "#e5cd99",
		"h2" = rand_hex_color(),
		"f1" = COLOR_BLACK,
		"f2" = COLOR_BLACK
	)
	switch(body_color)
		if(2)
			hair_colors["h1"] = "#cdcdc6"
		if(3)
			hair_colors["h1"] = "#6c6c6c"
		if(4)
			hair_colors["h1"] = "#d37ed8"
	if(marking_color)
		var/list/marking_rgb = rgb2num(marking_color)
		var/list/hair_rgb = rgb2num(hair_colors["h1"])
		hair_colors["h1"] = rgb(
			hair_rgb[1] + marking_rgb[1],
			hair_rgb[2] + marking_rgb[2],
			hair_rgb[3] + marking_rgb[3])
	return hair_colors

/datum/species/moth/randomize_body_accessory(prob_to_apply = 100, marking_style = null)
	var/list/valid_body_accessories = list_valid_body_accessories(name, FALSE)
	if(prob(95) && marking_style && ("[marking_style] Wings" in valid_body_accessories))
		return "[marking_style] Wings"
	var/list/unique_accessories = list()
	var/list/head_marking_styles = list_valid_marking_styles("head", name)
	for(var/each_accessory in valid_body_accessories)
		var/corresponding_head_marking = "[copytext(each_accessory, 1, -6)] Head Markings"
		if(!(corresponding_head_marking in head_marking_styles))
			unique_accessories |= list(each_accessory)
	return pick(unique_accessories)

/datum/species/moth/randomize_head_accessory(prob_to_apply = 100, marking_style = null, accessory_style = null)
	var/list/valid_head_accessories = list_valid_head_accessories(name)
	if(accessory_style)
		if("[accessory_style] Antennae" in valid_head_accessories)
			return "[accessory_style] Antennae"
		return "Burnt Off Antennae"
	if(marking_style && ("[marking_style] Antennae" in valid_head_accessories))
		return "[marking_style] Antennae"
	var/list/unique_accessories = list()
	var/list/head_marking_styles = list_valid_marking_styles("head", name)
	for(var/each_accessory in valid_head_accessories)
		var/corresponding_head_marking = "[copytext(each_accessory, 1, -9)] Head Markings"
		if(!(corresponding_head_marking in head_marking_styles))
			unique_accessories |= list(each_accessory)
	return pick(unique_accessories)

/datum/species/moth/randomize_head_accessory_color(head_accessory = "None", body_color = null, hair_color = null)
	if(prob(70))
		return COLOR_BLACK
	return rgb(rand(0, 306), rand(0, 60), rand(0, 20), space = COLORSPACE_HSL)

/datum/species/moth/randomize_head_markings(prob_to_apply = 70)
	return ..()

/datum/species/moth/randomize_body_markings(prob_to_apply = 70, body_color = null, skin_tone = null, head_markings = null)
	if(!head_markings)
		return ..()
	var/marking_style = copytext(head_markings, 1, -14)
	return "[marking_style] Markings"

/datum/species/moth/randomize_head_markings_color(head_markings = null, body_markings_color = null)
	return body_markings_color ? body_markings_color : rgb(rand(0, 360), rand(0, 60), rand(0, 15), space = COLORSPACE_HSL)

/datum/species/moth/randomize_body_markings_color(body_markings = null, head_markings_color = null)
	return head_markings_color ? head_markings_color : rgb(rand(0, 360), rand(0, 60), rand(0, 15), space = COLORSPACE_HSL)
