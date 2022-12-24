/obj/effect/proc_holder/spell/touch/alien_spell/transfer_plasma
	name = "Transfer Plasma"
	desc = "Transfers 50 plasma to a nearby alien"
	hand_path = "/obj/item/melee/touch_attack/alien/transfer_plasma"
	action_icon_state = "alien_transfer"
	plasma_cost = 50

/obj/item/melee/touch_attack/alien/transfer_plasma
	name = "plasma transfer"
	desc = "Transfers 50 plasma to another alien."
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/touch_attack/alien/transfer_plasma/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !isalien(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //not exploding after touching yourself would be bad
		return
	var/mob/living/carbon/transfering_to = target
	transfering_to.add_plasma(50, user)
	to_chat(user, "<span class='noticealien'>You have transfered 50 plasma to [transfering_to].</span>")
	if(!user == transfering_to)
		to_chat(transfering_to, "<span class='noticealien'>[user] has transfered 50 plasma to you!</span>")
	..()
