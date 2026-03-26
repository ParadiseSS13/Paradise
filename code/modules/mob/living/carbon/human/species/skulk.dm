/datum/species/skulk
	name = "Skkulakin"
	name_plural = "Skkulakin"
	max_age = 70
	icobase = 'icons/mob/human_races/skulk/r_skulkbrown.dmi'
	language = "Skkula-Runespeak"
	unarmed_type = /datum/unarmed_attack/claws

	blurb = "The Skkulakin are a species of psionically-attuned furred arthropods hailing from the Western Orion Spur. \
	Originating from the planet Votum-Accorium, an arctic world ruled by the brutal theocratic government known as the Silver Collective.<br/><br/> \
	Despite owning a large amount of territory in the western arm of the sector, the plasma supply their empire relies on is being stretched thin. \
	This has forced the once-proud species to desperately branch out and seek a solution to their critical shortage."

	cold_level_1 = 240
	cold_level_2 = 180
	cold_level_3 = 100

	heat_level_1 = 340
	heat_level_2 = 380
	heat_level_3 = 440

	brain_mod = 0.8

	species_traits = list()
	inherent_traits = list(TRAIT_BRITTLE_BONES)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_BODY_MARKINGS | HAS_BACK_SPINES | HAS_ICON_SKIN_TONE | SHAVED | HAS_BODY_ACCESSORY
	dietflags = DIET_OMNI
	flesh_color = "#e3e2dd"

	default_hair = "Scribe"
	default_bodyacc = "Illusive"
	spines = "Illusive1"

	eyes = "skulk_eyes_s"
	butt_sprite = "nian"

	optional_body_accessory = FALSE

	reagent_tag = PROCESS_ORG

	icon_skin_tones = alist(
		1 = "Blackgate",
		2 = "Talwyrm",
		3 = "Valcore",
		4 = "Ossya",
		5 = "Highfield",
		6 = "Votum-Accorium"
	)

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/skulk,
		"lungs" =    /obj/item/organ/internal/lungs/skulk,
		"liver" =    /obj/item/organ/internal/liver/skulk,
		"kidneys" =  /obj/item/organ/internal/kidneys/skulk,
		"brain" =    /obj/item/organ/internal/brain/skulk,
		"eyes" =     /obj/item/organ/internal/eyes/skulk
	)

	suicide_messages = list(
		"is attempting to blow up their mind with their mind!",
		"is jamming their claws into their eye sockets!",
		"is tearing open their arm with their fangs!",
		"is twisting their own neck!",
		"is holding their breath!")

/datum/species/skulk/on_species_gain(mob/living/carbon/human/H)
	..()
	updatespeciescolor(H)
	H.update_icons()
	var/datum/action/innate/spin_silk/spin_silk = new()
	spin_silk.Grant(H)

/datum/species/skulk/on_species_loss(mob/living/carbon/human/H)
	..()
	for(var/datum/action/innate/spin_silk/spin_silk in H.actions)
		spin_silk.Remove(H)

/datum/species/skulk/updatespeciescolor(mob/living/carbon/human/H, owner_sensitive = 1) // Handling species-specific skin-tones for the Skulk race.
	if(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/new_icobase = 'icons/mob/human_races/skulk/r_skulkblack.dmi' // Default Blackgate Skkulakin.
		var/current_spine_type = null
		if(H.body_accessory)
			current_spine_type = lowertext("[H.body_accessory.name]")

		var/chosen_spine_color = 1
		switch(H.s_tone)
			if(1) // Blackgate Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkblack.dmi'
				chosen_spine_color = 1
			if(2) // Talwyrm Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkbrown.dmi'
				chosen_spine_color = 2
			if(3) // Valcore Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkred.dmi'
				chosen_spine_color = 3
			if(4) // Ossya Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkblue.dmi'
				chosen_spine_color = 4
			if(5) // Highfield Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkgreen.dmi'
				chosen_spine_color = 5
			if(6) // Votum-Accorium Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkwhite.dmi'
				chosen_spine_color = 6
		if(H.body_accessory && current_spine_type)
			H.spines = "[current_spine_type][chosen_spine_color]"

		H.change_icobase(new_icobase, owner_sensitive)

/datum/action/innate/spin_silk
	name = "Spin Silk"
	desc = "Use your spinnerets to create a spool of silk that can be used for crafting."
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_STUNNED | AB_CHECK_RESTRAINED | AB_CHECK_CONSCIOUS
	button_icon = 'icons/obj/stacks/organic.dmi'
	button_icon_state = "sheet-silk"
	var/cooldown = 0
	var/cooldown_duration = 10 SECONDS

#define SILK_NUTRITION_AMOUNT 90

/datum/action/innate/spin_silk/Activate()
	var/mob/living/carbon/human/user = owner
	if(world.time <= cooldown)
		to_chat(user, SPAN_WARNING("You are still recovering from spinning silk. Wait [round((cooldown - world.time) / 10)] seconds and try again."))
		return
	var/mob/living/carbon/human/skulk/H = owner
	if(H.nutrition < SILK_NUTRITION_AMOUNT)
		to_chat(user, SPAN_WARNING("You are too hungry to spin silk right now."))
		return
	var/obj/item/stack/sheet/silk/silk
	if(user.get_active_hand() && user.get_inactive_hand())
		to_chat(user, SPAN_WARNING("You don't have any free hands!"))
		return
	H.visible_message(SPAN_WARNING("[H] begins spinning a small amount of silk..."), SPAN_WARNING("You begin spinning a small amount of silk... (This will take [5] seconds, and you must hold still.)"))
	if(!do_after_once(H, 5 SECONDS, TRUE, H, attempt_cancel_message = "You stop spinning silk."))
		if(H.incapacitated())
			to_chat(user, SPAN_WARNING("You cannot spin silk in your current state!"))
		return
	silk = new(get_turf(H), 1)
	user.put_in_hands(silk)
	cooldown = world.time + cooldown_duration
	H.adjust_nutrition(-SILK_NUTRITION_AMOUNT)
	to_chat(user, SPAN_WARNING("You spin a small amount of silk."))

#undef SILK_NUTRITION_AMOUNT
