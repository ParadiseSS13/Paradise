/datum/spell/touch/flesh_surgery
	name = "Knit Flesh"
	desc = "A touch spell that allows you to either harvest or restore flesh of target. \
		Left-clicking will extract the organs of a victim without needing to complete surgery or disembowel. \
		Right-clicking, if done on summons or minions, will restore health. Can also be used to heal damaged organs."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "mad_touch"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = null

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 20 SECONDS
	invocation = "CL'M M'N!" // "CLAIM MINE", but also almost "KALI MA"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	hand_path = /obj/item/melee/touch_attack/flesh_surgery

	/// If used on an organ, how much percent of the organ's HP do we restore
	var/organ_percent_healing = 0.5
	/// If used on a heretic mob, how much brute do we heal
	var/monster_brute_healing = 10
	/// If used on a heretic mob, how much burn do we heal
	var/monster_burn_healing = 5

/obj/item/melee/touch_attack/flesh_surgery
	name = "\improper knit flesh"
	desc = "Let's go practice medicine."
//qwertodo: this had 99 errors and I am very close. We can do this later (before tm)
