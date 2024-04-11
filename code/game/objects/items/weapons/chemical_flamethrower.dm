/obj/item/chemical_flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags = CONDUCT
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 5000)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=1;plasmatech=2;engineering=2"

	var/lit = FALSE	// On or off
	var/canister_max = 1
	var/obj/item/chemical_canister/canister
	var/obj/item/chemical_canister/canister_2 // In case we accept more than one canister

	var/warned_admins = FALSE //for the message_admins() when lit

/obj/item/chemical_flamethrower/Initialize(mapload)
	. = ..()
	canister = new()

/obj/item/chemical_flamethrower/attack_self(mob/user)
	. = ..()
	if(canister)
		unequip_canisters()

/obj/item/chemical_flamethrower/proc/unequip_canisters()
	if(canister_2)
		canister_2.forceMove(get_turf(src))
		canister_2.put_in_hands()
		canister_2 = null
		return

	if(canister)
		canister.forceMove(get_turf(src))
		canister.put_in_hands()
		canister = null
		return

/obj/item/chemical_canister
	name = "Chemical canister"
	desc = "A simple canister of fuel. Does not accept any pyrotechnics."
	icon = 'icons/obj/tank.dmi'
	icon_state = "oxygen"
	var/list/accepted_chemicals = list()
