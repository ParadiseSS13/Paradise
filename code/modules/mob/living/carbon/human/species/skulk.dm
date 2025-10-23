#define SILK_NUTRITION_AMOUNT 90

/datum/species/skulk

	name = "Skkulakin"
	name_plural = "Skkulakin"
	max_age = 70
	icobase = 'icons/mob/human_races/skulk/r_skulkbrown.dmi'
	language = "Skkula-Runespeak"
	unarmed_type = /datum/unarmed_attack/claws

	blurb = "The Skkulakin are a species of psionically-attuned furred arthropods hailing from the Western Orion Spur. \
	Originating from the planet Votum-Accorium, an artic world ruled by the brutal theocratic government known as the Silver Collective.<br/><br/> \
	Despite owning a large amount of territory in the western arm of the sector, the lack of plasma of which their empire relies on is being stretched thin. \
	This has forced the once-proud species to branch out and desperate seek out a solution to their critical shortage."

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
	clothing_flags = HAS_SOCKS
	bodyflags = HAS_BODY_MARKINGS | HAS_BACK_SPINES | HAS_ICON_SKIN_TONE | SHAVED
	dietflags = DIET_OMNI
	flesh_color = "#e3e2dd"

	default_hair = "Scribe"
	default_bodyacc = "Illusive"
	spines = "illusive2"

	eyes = "skulk_eyes_s"


	optional_body_accessory = FALSE

	reagent_tag = PROCESS_ORG

	icon_skin_tones = list(
		1 = "Blackgate",
		2 = "Talwyrm",
		3 = "Valcore",
		4 = "Ossya",
		5 = "Highfield",
		6 = "Votum-Accorium"
	)

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

/datum/species/skulk/updatespeciescolor(mob/living/carbon/human/H, owner_sensitive = 1) //Handling species-specific skin-tones for the Skulk race.
	if(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/new_icobase = 'icons/mob/human_races/skulk/r_skulkbrown.dmi' //Default Talwyrm Skkulakin.
		switch(H.s_tone)
			if(6) //Blackgate Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkblack.dmi'
			if(5) //Ossya Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkblue.dmi'
			if(4) //Highfield Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkgreen.dmi'
			if(3) //Valcore Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkred.dmi'
			if(2) //Votum-Accorium Skkulakin.
				new_icobase = 'icons/mob/human_races/skulk/r_skulkwhite.dmi'
			else
		H.change_icobase(new_icobase, owner_sensitive)

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

/datum/action/innate/spin_silk
	name = "Spin Silk"
	desc = "Use your spinnerets to create a spool of silk that can be used for crafting."
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_STUNNED|AB_CHECK_RESTRAINED|AB_CHECK_CONSCIOUS
	button_icon = 'icons/obj/cigarettes.dmi'
	button_icon_state = "match_unathi"
	var/cooldown = 0
	var/cooldown_duration = 10 SECONDS

/datum/action/innate/spin_silk/Activate()
	var/mob/living/carbon/human/user = owner
	if(world.time <= cooldown)
		to_chat(user, "<span class='warning'>You are still recovering from spinning silk. Wait [round((cooldown - world.time) / 10)] seconds and try again.</span>")
		return
	var/mob/living/carbon/human/skulk/H = owner
	if(H.nutrition < SILK_NUTRITION_AMOUNT)
		to_chat(H, "<span class='warning'>You are too hungry to spin silk right now.</span>")
		return
	var/obj/item/stack/sheet/silk/silk
	if(user.get_active_hand() && user.get_inactive_hand())
		to_chat(H, "<span class='warning'>You don't have any free hands!</span>")
		return
	H.visible_message("<span class='notice'>[H] placeholder...</span>", "<span class='notice'>Placeholder... (This will take [5] seconds, and you must hold still.)</span>")
	if(!do_after_once(H, 5 SECONDS, TRUE, H, attempt_cancel_message = "You stop spinning silk."))
		if(H.incapacitated())
			to_chat(H, "<span class='warning'>You cannot spin silk in your current state!</span>")
		return
	silk = new(get_turf(H), 1)
	user.put_in_hands(silk)
	cooldown = world.time + cooldown_duration
	H.adjust_nutrition(-SILK_NUTRITION_AMOUNT)
	to_chat(user, "<span class='notice'>You spin a small amount of silk.</span>")

