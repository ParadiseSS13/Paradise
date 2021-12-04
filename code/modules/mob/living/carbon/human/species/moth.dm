#define COCOON_WEAVE_DELAY 5 SECONDS
#define COCOON_EMERGE_DELAY 15 SECONDS
#define COCOON_HARM_AMOUNT 50
#define COCOON_NUTRITION_REQUIREMENT 201
#define COCOON_NUTRITION_AMOUNT -200
#define FLYSWATTER_DAMAGE_MULTIPLIER 9

/datum/species/moth
	name = "Moth"
	name_plural = "Moths"
	language = "Moffic"
	icobase = 'icons/mob/human_races/r_moth.dmi'
	inherent_factions = list("moth")
	species_traits = list(IS_WHITELISTED, NO_HAIR)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT
	bodyflags = HAS_HEAD_ACCESSORY | HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS | HAS_TAIL
	reagent_tag = PROCESS_ORG
	dietflags = DIET_HERB
	tox_mod = 1.5
	blood_color = "#b9ae9c"
	unarmed_type = /datum/unarmed_attack/claws
	scream_verb = "buzzes"
	male_scream_sound = 'sound/voice/scream_moth.ogg'
	female_scream_sound = 'sound/voice/scream_moth.ogg'
	default_headacc = "Plain Antennae"
	tail = "plain"
	eyes = "moth_eyes_s"
	butt_sprite = "kidan"
	has_wings = TRUE

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/moth
		)
	var/datum/action/innate/cocoon/cocoon
	/// Is the moth in a cocoon? When TRUE moths cannot wake up
	var/cocooned
	/// Are the wings burnt off? Used to negate some buffs if TRUE
	var/burnt_wings

	suicide_messages = list(
		"is attempting to nibble their antenna off!",
		"is jamming their legs into their eye sockets!",
		"is twisting their own neck!",
		"is cracking their exoskeleton!",
		"is ripping their wings off!",
		"is holding their breath!")


/datum/species/moth/on_species_gain(mob/living/carbon/human/H)
	..()
	cocoon = new()
	cocoon.Grant(H)

/datum/species/moth/on_species_loss(mob/living/carbon/human/H)
	..()
	cocoon.Remove(H)

/datum/species/moth/handle_life(mob/living/carbon/human/H)
	. = ..()
	addtimer(CALLBACK(src, .proc/get_lamp_level, H), 5 SECONDS, TIMER_UNIQUE)

/**
 * Checks for light levels on current turf and cause confusion if too high
 */
/datum/species/moth/proc/get_lamp_level(mob/living/carbon/human/H)
	if(H.confused != 0)
		return
	var/turf/simulated/T = get_turf(H)
	if(!istype(T))
		return
	var/light_available = T.get_lumcount(maxlum = 5) * 10
	if(light_available < 3) //too close to lamp friends!
		return
	H.AdjustConfused(rand(5, 10))
	to_chat(H, "<span class='danger'>The lamp friends are too bright, and dazzle you!</span>")

/datum/species/moth/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	..()
	if(R.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)

/datum/species/moth/get_species_runechat_color(mob/living/carbon/human/H)
	return H.m_colours["body"]

/datum/species/moth/spec_attacked_by(obj/item/I, mob/living/user, obj/item/organ/external/affecting, intent, mob/living/carbon/human/H)
	if(istype(I, /obj/item/melee/flyswatter) && I.force)
		apply_damage(I.force * FLYSWATTER_DAMAGE_MULTIPLIER, I.damtype, affecting, FALSE, H) //making flyswatters do 10x damage to moff

/datum/species/moth/spec_handle_fire(mob/living/carbon/human/H) //do not go into the extremely hot light. you will not survive
	if(H.on_fire && !(burnt_wings) && H.bodytemperature >= 800 && H.fire_stacks > 0)
		to_chat(H, "<span class='warning'>Your precious wings burn to a crisp!</span>")
		destroywings(H)

/datum/species/moth/spec_Process_Spacemove(mob/living/carbon/human/H)
	var/turf/A = get_turf(H)
	if(isspaceturf(A))
		return FALSE
	if(burnt_wings)
		return FALSE
	var/datum/gas_mixture/current = A.return_air()
	if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
		return TRUE

/datum/species/moth/spec_thunk()
	if(burnt_wings)
		return TRUE

/datum/species/moth/spec_rejuvenate(mob/living/carbon/human/H)
	if(burnt_wings)
		restorewings(H)

/datum/species/moth/spec_movement_delay()
	return FALSE

/datum/species/moth/spec_WakeUp()
	if(cocooned)
		return TRUE //Cocooned mobs dont get to wake up

/**
 * Copies wing and antennae names to species datum vars
 */
/datum/species/moth/backupwings(mob/living/carbon/human/H)
	var/obj/item/organ/external/head/A = H.get_organ("head")
	if(A.ha_style)
		backed_up_antennae = A.ha_style
	if(H.body_accessory)
		backed_up_wings = H.body_accessory.name

/**
 * Sets wings and antennae to burnt variants, removing some species buffs
 */
/datum/species/moth/destroywings(mob/living/carbon/human/H)
	burnt_wings = TRUE
	backupwings(H)
	H.change_body_accessory("Burnt Off Wings")
	H.change_head_accessory("Burnt Off Antennae")

/**
 * Restores wings and antennae from values in species datum vars
 */
/datum/species/moth/restorewings(mob/living/carbon/human/H)
	burnt_wings = FALSE
	H.change_head_accessory(backed_up_antennae)
	H.change_body_accessory(backed_up_wings)

/**
 * Gives wings and antennae if none exist
 */

/datum/species/moth/givewings(mob/living/carbon/human/H)
	if(!H.body_accessory)
		H.change_head_accessory(random_body_accessory("Moth"))
	var/obj/item/organ/external/head/HE = H.get_organ("head")
	if(HE && !HE.ha_style)
		H.change_body_accessory(random_head_accessory("Moth"))
	backupwings(H)

/**
 * Ramdomises wings and antennae
 */
/datum/species/moth/randomwings(mob/living/carbon/human/H)
	H.change_body_accessory(random_head_accessory("Moth"))
	H.change_head_accessory(random_body_accessory("Moth"))
	backupwings(H)

/datum/action/innate/cocoon
	name = "Cocoon"
	desc = "Restore your wings and antennae, and heal some damage. If your cocoon is broken externally you will take heavy damage!"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "cocoon1"

/datum/action/innate/cocoon/Activate()
	var/mob/living/carbon/human/moth/H = owner
	if(H.nutrition < COCOON_NUTRITION_REQUIREMENT)
		to_chat(H, "<span class='warning'>You are too hungry to cocoon!</span>")
		return
	H.visible_message("<span class='notice'>[H] begins to hold still and concentrate on weaving a cocoon...</span>", "<span class='notice'>You begin to focus on weaving a cocoon... (This will take [COCOON_WEAVE_DELAY / 10] seconds, and you must hold still.)</span>")
	if(do_after(H, COCOON_WEAVE_DELAY, FALSE, H))
		if(H.incapacitated(ignore_lying = TRUE))
			to_chat(H, "<span class='warning'>You cannot weave a cocoon in your current state.</span>")
			return
		H.visible_message("<span class='notice'>[H] finishes weaving a cocoon!</span>", "<span class='notice'>You finish weaving your cocoon.</span>")
		var/obj/structure/moth/cocoon/C = new(get_turf(H))
		H.forceMove(C)
		C.preparing_to_emerge = TRUE
		var/datum/species/moth/M = H.dna.species
		M.cocooned = TRUE
		H.KnockOut()
		addtimer(CALLBACK(src, .proc/emerge, C), COCOON_EMERGE_DELAY, TIMER_UNIQUE)
	else
		to_chat(H, "<span class='warning'>You need to hold still in order to weave a cocoon!</span>")

/**
 * Removes moth from cocoon, heals moth and restores burnt wings
 */
/datum/action/innate/cocoon/proc/emerge(obj/structure/moth/cocoon/C)
	for(var/mob/living/carbon/human/H in C.contents)
		var/datum/species/moth/M = H.dna.species
		M.cocooned = FALSE
		if(M.burnt_wings)
			M.restorewings(H)
	C.preparing_to_emerge = FALSE
	qdel(C)

/obj/structure/moth/cocoon
	name = "moth cocoon"
	desc = "Someone wrapped in a moth cocoon"
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon1"
	color = COLOR_PALE_YELLOW //So tiders (hopefully) don't decide to immediately bust them open
	max_integrity = 60
	var/preparing_to_emerge

/obj/structure/moth/cocoon/Initialize(mapload)
	. = ..()
	icon_state = pick("cocoon1","cocoon2","cocoon3")

/obj/structure/moth/cocoon/Destroy()
	if(!preparing_to_emerge)
		visible_message("<span class='danger'>[src] splits open from within.</span>")
	else
		visible_message("<span class='danger'>[src] is smashed open, harming the moth within!</span>")
		for(var/mob/living/carbon/human/H in contents)
			H.adjustBruteLoss(COCOON_HARM_AMOUNT)
			H.adjustFireLoss(COCOON_HARM_AMOUNT)
			H.AdjustWeakened(5)
	for(var/mob/living/carbon/human/H in contents)
		var/datum/species/moth/M = H.dna.species
		M.cocooned = FALSE
		H.adjust_nutrition(COCOON_NUTRITION_AMOUNT)
		H.WakeUp()
		H.forceMove(loc)
	return ..()


#undef COCOON_WEAVE_DELAY
#undef COCOON_EMERGE_DELAY
#undef COCOON_HARM_AMOUNT
#undef COCOON_NUTRITION_AMOUNT
#undef COCOON_NUTRITION_REQUIREMENT
#undef FLYSWATTER_DAMAGE_MULTIPLIER
