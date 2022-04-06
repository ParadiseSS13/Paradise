/obj/item/gun/energy/taser
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	origin_tech = "combat=3"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3
	can_holster = TRUE  // Pistol size

/obj/item/gun/energy/shock_revolver
	name = "tesla revolver"
	desc = "A high-tech revolver that fires internal, reusable shock cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers."
	icon_state = "stunrevolver"
	item_state = "gun"
	origin_tech = "combat=4;materials=4;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/shock_revolver)
	can_flashlight = 0
	shaded_charge = FALSE
	can_holster = TRUE


/obj/item/gun/energy/gun/advtaser
	name = "hybrid taser"
	desc = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	origin_tech = "combat=4"
	ammo_x_offset = 2
	flight_x_offset = 15
	shaded_charge = FALSE
	can_holster = TRUE  // Pistol size

/obj/item/gun/energy/gun/advtaser/detailed_examine()
	return "This is an energy weapon. To recharge this weapon, use a weapon recharger. \
			To switch between insta-stun and disabler beams, click the weapon in your hand. This weapon can only fire through glass if it is set to disabler beams."

/obj/item/gun/energy/gun/advtaser/cyborg
	name = "cyborg taser"
	desc = "An integrated hybrid taser that draws directly from a cyborg's power cell. The weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_flashlight = 0
	can_charge = 0

/obj/item/gun/energy/gun/advtaser/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	item_state = null
	origin_tech = "combat=3"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 10
	can_holster = TRUE

/obj/item/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/cyborg)
	can_charge = 0

/obj/item/gun/energy/disabler/cyborg/newshot()
	..()
	robocharge()
