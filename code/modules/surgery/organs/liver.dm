/obj/item/organ/internal/liver
	name = "liver"
	icon_state = "liver"
	organ_tag = "liver"
	parent_organ = "groin"
	slot = "liver"
	/// How hard does alcohol hit? This is a multiplier, so 2 would be twice as strong
	var/alcohol_intensity = 1
	/// Amount of ticks that we have been at a damaged state. Never goes down.
	var/damaged_ticks = 0
	/// Heal multiplier
	var/heal_multiplier = 1
	/// Is this liver immune to high toxin damage?
	var/tox_damage_immune = FALSE

/obj/item/organ/internal/liver/rejuvenate()
	. = ..()
	damaged_ticks = 0

#define THRESHOLD_FAINT 180 SECONDS

/obj/item/organ/internal/liver/on_life()
	if(!owner)
		return
	if(status & ORGAN_DEAD)
		owner.adjustToxLoss(2)
		// Dead liver? That's not good
		return

	var/datum/wound/cirrhosis = get_wound(/datum/wound/cirrhosis)
	if(cirrhosis)
		// Not as bad as having a dead liver but you're close
		cirrhosis.do_effect()
		return

	if(!is_robotic() &&  damage >= (max_damage / 2))
		damaged_ticks++

	// Cirrhosis happens when you run around for more than 3 minutes with a very damaged liver
	if(!is_robotic() && damaged_ticks >= 100 && !get_wound(/datum/wound/cirrhosis))
		add_wound(/datum/wound/cirrhosis)

	var/toxloss = owner.getToxLoss()
	switch(toxloss)
		if(0)
			var/datum/status_effect/transient/drunkenness/drunk = owner.has_status_effect(STATUS_EFFECT_DRUNKENNESS)
			if(drunk?.cached_strength >= THRESHOLD_FAINT)
				return

			if(damage < min_bruised_damage)
				// 0.1 damage healing per second
				heal_internal_damage(0.2)

		if(0 to 40)
			// Very minor healing
			owner.adjustToxLoss(-0.2 * heal_multiplier)
		if(40 to 80)
			// Still low healing, but slightly higher
			owner.adjustToxLoss(-0.4 * heal_multiplier)
		if(80 to INFINITY)
			// The liver is overwhelmed, less healing and also liver damage
			owner.adjustToxLoss(-0.2 * heal_multiplier)
			if(!tox_damage_immune)
				receive_damage(0.4)

#undef THRESHOLD_FAINT

/obj/item/organ/internal/liver/cybernetic
	name = "cybernetic liver"
	icon_state = "liver-c"
	desc = "An electronic device designed to mimic the functions of a human liver. It has no benefits over an organic liver, but is easy to produce."
	origin_tech = "biotech=4"
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	status = ORGAN_ROBOT
	alcohol_intensity = 0.5

/obj/item/organ/internal/liver/cybernetic/upgraded
	name = "upgraded cybernetic liver"
	icon_state = "liver-c-u"
	desc = "An electronic device designed to mimic the functions of a human liver. It works better than a normal liver."
	origin_tech = "biotech=5"
	alcohol_intensity = 0.25
	heal_multiplier = 2
	tox_damage_immune = TRUE
