/mob/living/carbon/alien/larva
	name = "alien larva"
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL

	maxHealth = 25
	health = 25
	butcher_results = list(/obj/item/food/monstermeat/xenomeat = 1)
	density = FALSE
	surgery_container = /datum/xenobiology_surgery_container/alien/larva

	var/temperature_resistance = T0C+75
	var/amount_grown = 0
	var/max_grown = 200
	death_message = "lets out a waning high-pitched cry."
	death_sound = null
	hud_type = /datum/hud/larva

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/larva/Initialize(mapload)
	. = ..()

	name = "alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	add_language("Xenomorph")
	add_language("Hivemind")
	AddSpell(new /datum/spell/alien_spell/evolve_larva)
	var/datum/action/innate/hide/alien_larva_hide/hide = new()
	hide.Grant(src)

/mob/living/carbon/alien/larva/Destroy()
	for(var/datum/action/innate/hide/alien_larva_hide/hide in actions)
		hide.Remove(src)
	return ..()


/mob/living/carbon/alien/larva/get_caste_organs()
	. = ..()
	. += /obj/item/organ/internal/alien/plasmavessel/larva


/mob/living/carbon/alien/larva/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Progress:", "[amount_grown]/[max_grown]")

/mob/living/carbon/alien/larva/add_plasma(amount)
	if(stat != DEAD && amount > 0)
		amount_grown = min(amount_grown + 1, max_grown)
	..(amount)

/mob/living/carbon/alien/larva/ex_act(severity)
	..()

	var/brute_loss = null
	var/fire_loss = null
	switch(severity)
		if(1.0)
			gib()
			return
		if(2.0)
			brute_loss += 60
			fire_loss += 60
			Deaf(2 MINUTES)
		if(3.0)
			brute_loss += 30
			if(prob(50))
				Paralyse(2 SECONDS)
			Deaf(1 MINUTES)

	adjustBruteLoss(brute_loss)
	adjustFireLoss(fire_loss)
	updatehealth()

//can't equip anything
/mob/living/carbon/alien/larva/attack_ui(slot_id)
	return

/mob/living/carbon/alien/larva/restrained()
	return FALSE

// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/living/carbon/alien/larva/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	return FALSE
