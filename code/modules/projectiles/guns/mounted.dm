/obj/item/weapon/gun/energy/gun/advtaser/mounted
	name = "mounted taser"
	desc = "An arm mounted dual-mode weapon that fires electrodes and disabler shots."
	icon_state = "armcannon"
	force = 5
	flags = NODROP
	w_class = 5
	can_flashlight = 0
	selfcharge = 1
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // Has no trigger at all, uses neural signals instead

/obj/item/weapon/gun/energy/gun/advtaser/mounted/dropped()//if somebody manages to drop this somehow...
	..()
	loc = null//send it to nullspace to get retrieved by the implant later on. gotta cover those edge cases.

/obj/item/weapon/gun/energy/laser/mounted
	name = "mounted laser"
	desc = "An arm mounted cannon that fires lethal lasers. Doesn't come with a charge beam."
	icon_state = "armcannon"
	item_state = "armcannonlase"
	force = 5
	flags = NODROP
	w_class = 5
	materials = null
	selfcharge = 1
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/weapon/gun/energy/laser/mounted/dropped()
	..()
	loc = null
