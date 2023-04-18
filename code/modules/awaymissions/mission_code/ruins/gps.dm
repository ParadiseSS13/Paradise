//local gps units to let the ruins be found easier.

/obj/item/gps/ruin
	name = "navigation console"
	desc = "A console for navigation in local space, gives off a weak signal that can be picked up if sufficiently close."
	icon = 'icons/obj/machines/terminals.dmi'
	icon_state = "gps_console"
	anchored = TRUE
	local = TRUE
	gpstag = "Unknown Signal"

/obj/item/gps/ruin/attack_hand(mob/user)
	attack_self(user)
