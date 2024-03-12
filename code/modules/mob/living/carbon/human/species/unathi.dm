/datum/species/unathi
	name = "Unathi"
	name_plural = "Unathi"
	article_override = "a"  // it's pronounced "you-nah-thee"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	language = "Sinta'unathi"
	tail = "sogtail"
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	unarmed_type = /datum/unarmed_attack/claws
	primitive_form = /datum/species/monkey/unathi

	blurb = "Unathi are a scaled species of reptilian beings from the desert world of Moghes, within the Uuosa-Eso system. \
	Organizing themselves in highly competitive feudal kingdoms, the Unathi lack any sort of wide-scale unification, and their culture and history consist of centuries of internal conflict and struggle.<br/><br/> \
	Despite clans having a sizeable military force, inter-clan rivalries and constant civil war prevent the Unathi from achieving much more in the wider galactic scene."

	species_traits = list(LIPS)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_REPTILE
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_BODY_MARKINGS | HAS_HEAD_MARKINGS | HAS_SKIN_COLOR | HAS_ALT_HEADS | TAIL_WAGGING | TAIL_OVERLAPPED
	dietflags = DIET_CARN
	taste_sensitivity = TASTE_SENSITIVITY_SHARP

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 140 //Default 120

	heat_level_1 = 505 //Default 360 - Higher is better
	heat_level_2 = 540 //Default 400
	heat_level_3 = 600 //Default 460

	flesh_color = "#34AF10"
	reagent_tag = PROCESS_ORG
	base_color = "#066000"
	//Default styles for created mobs.
	default_headacc = "Simple"
	default_headacc_colour = "#404040"
	butt_sprite = "unathi"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/unathi,
		"lungs" =    /obj/item/organ/internal/lungs/unathi,
		"liver" =    /obj/item/organ/internal/liver/unathi,
		"kidneys" =  /obj/item/organ/internal/kidneys/unathi,
		"brain" =    /obj/item/organ/internal/brain/unathi,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/unathi //3 darksight.
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/lizard, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
								/mob/living/simple_animal/crab, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/hostile/poison/bees)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

/datum/species/unathi/on_species_gain(mob/living/carbon/human/H)
	..()
	var/datum/action/innate/ignite/fire = new()
	fire.Grant(H)

/datum/species/unathi/on_species_loss(mob/living/carbon/human/H)
	..()
	for(var/datum/action/innate/ignite/fire in H.actions)
		fire.Remove(H)

/datum/action/innate/ignite
	name = "Ignite"
	desc = "A fire forms in your mouth, fierce enough to... light a cigarette. Requires you to drink welding fuel beforehand."
	icon_icon = 'icons/obj/cigarettes.dmi'
	button_icon_state = "match_unathi"
	var/cooldown = 0
	var/cooldown_duration = 20 SECONDS
	var/welding_fuel_used = 3 //one sip, with less strict timing
	check_flags = AB_CHECK_HANDS_BLOCKED

/datum/action/innate/ignite/Activate()
	var/mob/living/carbon/human/user = owner
	if(world.time <= cooldown)
		to_chat(user, "<span class='warning'>Your throat hurts too much to do it right now. Wait [round((cooldown - world.time) / 10)] seconds and try again.</span>")
		return
	if(!welding_fuel_used || user.reagents.has_reagent("fuel", welding_fuel_used))
		if((user.head?.flags_cover & HEADCOVERSMOUTH) || (user.wear_mask?.flags_cover & MASKCOVERSMOUTH) && !user.wear_mask?.up)
			to_chat(user, "<span class='warning'>Your mouth is covered.</span>")
			return
		var/obj/item/match/unathi/fire = new(user.loc, src)
		if(user.put_in_hands(fire))
			to_chat(user, "<span class='notice'>You ignite a small flame in your mouth.</span>")
			user.reagents.remove_reagent("fuel", 50) //slightly high, but I'd rather avoid it being TOO spammable.
			cooldown = world.time + cooldown_duration
		else
			qdel(fire)
			to_chat(user, "<span class='warning'>You don't have any free hands.</span>")
	else
		to_chat(user, "<span class='warning'>You need to drink welding fuel first.</span>")


/datum/species/unathi/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()

/datum/species/unathi/ashwalker
	name = "Ash Walker"
	name_plural = "Ash Walkers"
	sprite_sheet_name = "Unathi" // We have the same sprite sheets as unathi
	article_override = null

	blurb = "These reptillian creatures appear to be related to the Unathi, but seem significantly less evolved. \
	They roam the wastes of Lavaland, worshipping a dead city and capturing unsuspecting miners."

	language = "Sinta'unathi"
	default_language = "Sinta'unathi"

	speed_mod = -0.80
	species_traits = list(LIPS, NOT_SELECTABLE)
	inherent_traits = list(TRAIT_CHUNKYFINGERS)

	has_organ = list( // same as unathi's organs, aside for the lungs as they need to be able to breathe on lavaland.
		"heart" =    /obj/item/organ/internal/heart/unathi,
		"lungs" =    /obj/item/organ/internal/lungs/unathi/ash_walker,
		"liver" =    /obj/item/organ/internal/liver/unathi,
		"kidneys" =  /obj/item/organ/internal/kidneys/unathi,
		"brain" =    /obj/item/organ/internal/brain/unathi,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/unathi
		)

/datum/species/unathi/ashwalker/on_species_gain(mob/living/carbon/human/H)
	..()
	for(var/datum/action/innate/ignite/fire in H.actions)
		fire.Remove(H)
	var/datum/action/innate/ignite/ash_walker/fire = new()
	fire.Grant(H)

/datum/species/unathi/ashwalker/on_species_loss(mob/living/carbon/human/H)
	..()
	for(var/datum/action/innate/ignite/ash_walker/fire in H.actions)
		fire.Remove(H)

/datum/species/unathi/ashwalker/movement_delay(mob/living/carbon/human/H)
	. = ..()
	var/turf/our_turf = get_turf(H)
	if(!is_mining_level(our_turf.z))
		. -= speed_mod

/datum/action/innate/ignite/ash_walker
	desc = "You form a fire in your mouth, fierce enough to... light a cigarette."
	cooldown_duration = 3 MINUTES
	welding_fuel_used = 0 // Ash walkers dont need welding fuel to use ignite
