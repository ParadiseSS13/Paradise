/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	flags = EARBANGPROTECT
	flags_2 = HEALS_EARS_2
	strip_delay = 15
	put_on_delay = 25
	resistance_flags = FLAMMABLE

/obj/item/clothing/ears/headphones
	name = "headphones"
	desc = "Unce unce unce unce."
	var/on = 0
	icon_state = "headphones0"
	item_state = null
	actions_types = list(/datum/action/item_action/toggle_headphones)

/obj/item/clothing/ears/headphones/attack_self(mob/user)
	on = !on
	icon_state = "headphones[on]"

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

	user.update_inv_ears()