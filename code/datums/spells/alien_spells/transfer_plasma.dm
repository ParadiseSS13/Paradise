/datum/spell/touch/alien_spell/transfer_plasma
	name = "Transfer Plasma"
	desc = "Transfers 50 plasma to a nearby alien"
	hand_path = "/obj/item/melee/touch_attack/alien/transfer_plasma"
	action_icon_state = "alien_transfer"
	plasma_cost = 50

/obj/item/melee/touch_attack/alien/transfer_plasma
	name = "plasma transfer"
	desc = "Transfers 50 plasma to another alien."
	icon_state = "alien_transfer"

/obj/item/melee/touch_attack/alien/transfer_plasma/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(target == user)
		to_chat(user, "<span class='noticealien'>You withdraw your readied plasma.</span>")
		..()
		return
	if(!proximity || !isalien(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!plasma_check(50, user))
		to_chat(user, "<span class='noticealien'>You don't have enough plasma to perform this action!</span>")
		return
	user.add_plasma(-50)
	var/mob/living/carbon/transfering_to = target
	transfering_to.add_plasma(50)
	to_chat(user, "<span class='noticealien'>You have transfered 50 plasma to [transfering_to].</span>")
	to_chat(transfering_to, "<span class='noticealien'>[user] has transfered 50 plasma to you!</span>")
	..()
