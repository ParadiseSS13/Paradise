
/datum/spell/paradox/self/united_bonds //objective protect
	name = "United Bonds"
	desc = "You are straining very hard to find out the directon of your original and their condition. Works once."
	action_icon_state = "united_bonds"
	base_cooldown = 4 SECONDS

/datum/spell/paradox/self/united_bonds/cast(list/targets, mob/user = usr)
	if(!do_after(user, 4 SECONDS, target = user))
		revert_cast()
		return

	pc = user.mind.has_antag_datum(/datum/antagonist/paradox_clone)
	var/mob/living/carbon/human/us = user
	var/mob/living/carbon/human/orig = pc.original
	do_sparks(rand(2,4), FALSE, us)
	do_sparks(rand(4,8), FALSE, orig)
	us.adjustStaminaLoss(rand(20,30))

	var/message = "[orig.real_name] is somewhere [dir2text(get_dir(us, orig))] of you."
	if(orig.get_damage_amount() >= 40 && orig.stat != DEAD)
		message += " <i>[orig.real_name] is wounded...</i>"
	if(orig.stat == DEAD)
		message += " <i>[orig.real_name] is dead!</i>"

	to_chat(user, "<span class='warning'>[message]</span>")
	orig.heal_overall_damage(10,10, FALSE)

	var/datum/spell/paradox/self/united_bonds/UB = locate() in pc.owner.spell_list
	user.mind.RemoveSpell(UB)
