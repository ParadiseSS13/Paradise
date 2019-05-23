#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin

/datum/species/zombie
	// 1spooky
	name = "High-Functioning Zombie"
	name_plural = "High-Functioning Zombies"
	icobase = 'icons/mob/human_races/r_zombie.dmi'
	deform = 'icons/mob/human_races/r_def_zombie.dmi'
	dies_at_threshold = TRUE
	species_traits = list(NO_BLOOD,NOZOMBIE,NOTRANSSTING,NO_BREATHE, RADIMMUNE, NO_SCAN)
	var/static/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	warning_low_pressure = 50
	hazard_low_pressure = 0
	flesh_color = "#00FF00" // for green examine text
	bodyflags = HAS_SKIN_COLOR
	dietflags = DIET_CARN
	has_organ = list(	
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes,
		"ears" = 	/obj/item/organ/internal/ears,
		"zombie_infection" = /obj/item/organ/internal/zombie_infection)


/datum/species/zombie/infectious
	name = "Infectious Zombie"
	mutanthands = /obj/item/zombie_hand
	icobase = 'icons/mob/human_races/r_zombie.dmi'
	deform = 'icons/mob/human_races/r_def_zombie.dmi'
	armor = 20 // 120 damage to KO a zombie, which kills it
	speedmod = 1.6
	default_language = "Zombie"
	language = "Zombie"
	var/heal_rate = 1
	var/regen_cooldown = 0
	flesh_color = "#00FF00" // for green examine text

/datum/species/zombie/infectious/handle_dna(mob/living/carbon/human/H, remove)
	. = ..()

/datum/species/zombie/infectious/spec_stun(mob/living/carbon/human/H,amount)
	. = min(20, amount)

/datum/species/zombie/infectious/spec_attacked_by(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/datum/species/zombie/infectious/handle_life(mob/living/carbon/human/C)
	. = ..()
	//Zombies never actually die, they just fall down until they regenerate enough to rise back up.
	//They must be restrained, beheaded or gibbed to stop being a threat.
	if(regen_cooldown < world.time)
		var/heal_amt = heal_rate
		if(C.InCritical())
			heal_amt *= 5
		C.heal_overall_damage(heal_amt,heal_amt)
		C.adjustToxLoss(-heal_amt)
	if(!C.InCritical() && prob(4))
		playsound(C, pick(spooks), 50, TRUE, 10)
		
//Congrats you somehow died so hard you stopped being a zombie
/datum/species/zombie/infectious/spec_death(mob/living/carbon/C)
	. = ..()
	var/obj/item/organ/internal/zombie_infection/infection
	infection = C.get_organ_slot("zombie_infection")
	if(infection)
		qdel(infection)

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/human/C, datum/species/old_species)
	. = ..()
	// Deal with the source of this zombie corruption
	//  Infection organ needs to be handled separately from mutant_organs
	//  because it persists through species transitions
	if(mutanthands)
		C.drop_l_hand()
		C.drop_r_hand()
		C.put_in_hands(new mutanthands())
		C.put_in_hands(new mutanthands())
	var/obj/item/organ/internal/zombie_infection/infection
	infection = C.get_organ_slot("zombie_infection")
	if(!infection)
		infection = new()
		infection.insert(C)

/datum/species/zombie/infectious/on_species_loss(mob/living/carbon/human/C, datum/species/old_species)
	qdel(C.r_hand)
	qdel(C.l_hand)
	return ..()

#undef REGENERATION_DELAY
