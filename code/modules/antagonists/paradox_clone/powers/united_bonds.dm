/datum/spell/paradox_spell/self/united_bonds // objective protect
	name = "United Bonds"
	desc = "Gets the direction and condition of your target. Works once. May alert your target."
	action_icon_state = "united_bonds"
	base_cooldown = 4 SECONDS

/datum/spell/paradox_spell/self/united_bonds/cast(list/targets, mob/living/user = usr)
	if(!do_after(user, 4 SECONDS, target = user))
		revert_cast()
		return

	var/datum/antagonist/paradox_clone/i_can_be_ur_angle = user.mind.has_antag_datum(/datum/antagonist/paradox_clone) // about variable's name - ask GDN, i dunno why he changed var/px to var/this thing
	if(!i_can_be_ur_angle)
		return
	var/mob/living/carbon/human/or_ur_devil = i_can_be_ur_angle.original
	do_sparks(rand(2, 4), FALSE, user)
	do_sparks(rand(4, 8), FALSE, or_ur_devil)
	user.adjustStaminaLoss(rand(20, 30))

	var/message = "[or_ur_devil.real_name] is somewhere [dir2text(get_dir(user, or_ur_devil))] of you."
	if(or_ur_devil.get_damage_amount() >= 40 && or_ur_devil.stat != DEAD)
		message += " <i>[or_ur_devil.real_name] is wounded...</i>"
	if(or_ur_devil.stat == DEAD)
		message += " <i>[or_ur_devil.real_name] is dead!</i>"

	to_chat(user, "<span class='warning'>[message]</span>")
	or_ur_devil.heal_overall_damage(10, 10, FALSE)

	var/datum/spell/paradox_spell/self/united_bonds/UB = locate() in i_can_be_ur_angle.owner.spell_list
	user.mind.RemoveSpell(UB)
