/mob/living/carbon/alien/larva
	name = "alien larva"
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL

	maxHealth = 25
	health = 25
	density = 0

	tts_seed = "Templar"

	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth
	death_message = "lets out a waning high-pitched cry."
	death_sound = null

	var/datum/action/innate/hide/alien_larva/hide_action


//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/larva/New()
	if(name == "alien larva")
		name = "alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	add_language("Xenomorph")
	add_language("Hivemind")
	hide_action = new
	hide_action.Grant(src)
	..()
	AddSpell(new /obj/effect/proc_holder/spell/alien_spell/evolve_larva)




/mob/living/carbon/alien/larva/Destroy()
	if(hide_action)
		hide_action.Remove(src)
		hide_action = null
	return ..()


/mob/living/carbon/alien/larva/get_caste_organs()
	. = ..()
	. += /obj/item/organ/internal/xenos/plasmavessel/larva


//This needs to be fixed
/mob/living/carbon/alien/larva/Stat()
	..()
	stat(null, "Progress: [amount_grown]/[max_grown]")

/mob/living/carbon/alien/larva/adjust_alien_plasma(amount)
	if(stat != DEAD && amount > 0)
		amount_grown = min(amount_grown + 1, max_grown)
	..(amount)

/mob/living/carbon/alien/larva/ex_act(severity)
	..()

	var/b_loss = null
	var/f_loss = null
	switch(severity)
		if(1.0)
			gib()
			return

		if(2.0)

			b_loss += 60

			f_loss += 60

			AdjustDeaf(120 SECONDS)

		if(3.0)
			b_loss += 30
			if(prob(50))
				Paralyse(2 SECONDS)
			AdjustDeaf(60 SECONDS)

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()

//can't equip anything
/mob/living/carbon/alien/larva/attack_ui(slot_id)
	return

/mob/living/carbon/alien/larva/restrained()
	return 0

/mob/living/carbon/alien/larva/var/temperature_resistance = T0C+75

// new damage icon system
// now constructs damage icon for each organ from mask * damage field


/mob/living/carbon/alien/larva/show_inv(mob/user as mob)
	return

/mob/living/carbon/alien/larva/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	return FALSE

/* Commented out because it's duplicated in life.dm
/mob/living/carbon/alien/larva/proc/grow() // Larvae can grow into full fledged Xenos if they survive long enough -- TLE
	if(icon_state == "larva_l" && !canmove) // This is a shit death check. It is made of shit and death. Fix later.
		return
	else
		var/mob/living/carbon/alien/humanoid/A = new(loc)
		A.key = key
		qdel(src) */
