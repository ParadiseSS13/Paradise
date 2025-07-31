/mob/living/basic/netherworld/blankbody
	name = "blank body"
	desc = "This looks human enough, but its flesh has an ashy texture, and it's face is featureless save an eerie smile."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	health = 100
	maxHealth = 100
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

/mob/living/basic/netherworld/blankbody/death(gibbed)
	. = ..()
	if(held_body)
		held_body.forceMove(loc)
		qdel(src)
