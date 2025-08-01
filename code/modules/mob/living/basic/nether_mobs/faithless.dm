/mob/living/basic/netherworld/faithless
	name = "Faithless"
	desc = "The Wish Granter's faith in humanity, incarnate."
	speak_emote = list("wails", "growls")
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	melee_damage_lower = 15
	melee_damage_upper = 15
	harm_intent_damage = 10
	obj_damage = 50
	attack_verb_simple = "grip"
	attack_verb_continuous = "grips"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	speed = 0
	faction = "faithless"

/mob/living/basic/netherworld/faithless/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE
