/mob/living/basic/netherworld/blankbody
	name = "blank body"
	desc = "This looks human enough, but its flesh has an ashy texture, and it's face is featureless save an eerie smile."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	health = 100
	maxHealth = 100
	a_intent = INTENT_HARM
	obj_damage = 50
	melee_damage_lower = 5
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	melee_attack_cooldown_min = 0.5 SECONDS
	melee_attack_cooldown_max = 1.5 SECONDS
	speak_emote = list("screams")
	death_message = "falls apart into a fine dust."
	/// The body/brain of the player turned into a blank, if the blank was turned
	var/mob/living/held_body
	/// The held body's player is in control of the blank
	var/is_original_mob = FALSE

/mob/living/basic/netherworld/blankbody/death(gibbed)
	. = ..()
	if(held_body)
		held_body.forceMove(loc)
		if(is_original_mob)
			mind.transfer_to(held_body)
		qdel(src)
