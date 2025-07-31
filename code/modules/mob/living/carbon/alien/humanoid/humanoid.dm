#define XENO_TOTAL_LAYERS 6
/mob/living/carbon/alien/humanoid
	icon_state = "alien_s"

	butcher_results = list(/obj/item/food/monstermeat/xenomeat = 5, /obj/item/stack/sheet/animalhide/xeno = 1)
	var/caste = ""
	var/alt_icon = 'icons/mob/alienleap.dmi' //used to switch between the two alien icon files.
	var/custom_pixel_x_offset = 0 //for admin fuckery.
	var/custom_pixel_y_offset = 0
	var/alien_disarm_damage = 30 //Aliens deal a good amount of stamina damage on disarm intent
	var/alien_slash_damage = 20 //Aliens deal a good amount of damage on harm intent
	var/alien_movement_delay = 0 //This can be + or -, how fast an alien moves
	var/temperature_resistance = T0C+75
	var/list/overlays_standing[XENO_TOTAL_LAYERS]
	pass_flags = PASSTABLE
	hud_type = /datum/hud/alien

GLOBAL_LIST_INIT(strippable_alien_humanoid_items, create_strippable_list(list(
	/datum/strippable_item/hand/left,
	/datum/strippable_item/hand/right,
	/datum/strippable_item/mob_item_slot/handcuffs,
	/datum/strippable_item/mob_item_slot/legcuffs,
)))

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/Initialize(mapload)
	if(name == "alien")
		name = "alien ([rand(1, 1000)])"
	real_name = name
	add_language("Xenomorph")
	add_language("Hivemind")
	AddSpell(new /datum/spell/alien_spell/regurgitate)
	. = ..()
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_CLAW, 0.5, -11)

/mob/living/carbon/alien/humanoid/get_strippable_items(datum/source, list/items)
	items |= GLOB.strippable_alien_humanoid_items

/mob/living/carbon/alien/humanoid/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	if(..())
		return TRUE
	return FALSE

/mob/living/carbon/alien/humanoid/ex_act(severity)
	..()

	var/shielded = 0

	var/b_loss = null
	var/f_loss = null
	switch(severity)
		if(1.0)
			gib()
			return

		if(2.0)
			if(!shielded)
				b_loss += 60

			f_loss += 60

			Deaf(2 MINUTES)
		if(3.0)
			b_loss += 30
			if(prob(50) && !shielded)
				Paralyse(2 SECONDS)
			Deaf(1 MINUTES)

	take_overall_damage(b_loss, f_loss)

/mob/living/carbon/alien/humanoid/restrained()
	if(handcuffed)
		return TRUE
	return FALSE

/mob/living/carbon/alien/humanoid/movement_delay() //Aliens have a varied movespeed
	. = ..()
	. += alien_movement_delay

/mob/living/carbon/alien/humanoid/resist_restraints(attempt_breaking)
	playsound(src, 'sound/voice/hiss5.ogg', 40, TRUE, 1)  //Alien roars when starting to break free
	attempt_breaking = TRUE
	return ..()

/mob/living/carbon/alien/humanoid/get_standard_pixel_y_offset()
	if(leaping)
		return -32
	else if(custom_pixel_y_offset)
		return custom_pixel_y_offset
	else
		return initial(pixel_y)

/mob/living/carbon/alien/humanoid/get_standard_pixel_x_offset(lying = 0)
	if(leaping)
		return -32
	else if(custom_pixel_x_offset)
		return custom_pixel_x_offset
	else
		return initial(pixel_x)

/mob/living/carbon/alien/humanoid/get_permeability_protection()
	return 0.8

#undef XENO_TOTAL_LAYERS
