/obj/item/gun/energy/taser
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	origin_tech = "combat=3"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3
	can_holster = TRUE  // Pistol size

/obj/item/gun/energy/arc_revolver
	name = "arc revolver"
	desc = "A high-tech revolver that fires internal, reusable shock cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers. These shots charge whatever they hit, causing arcs of electricity to form between them."
	icon_state = "stunrevolver"
	item_state = "gun"
	origin_tech = "combat=4;materials=4;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/arc_revolver)
	can_flashlight = FALSE
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

/obj/item/gun/energy/gun/advtaser/cyborg
	name = "cyborg taser"
	desc = "An integrated hybrid taser that draws directly from a cyborg's power cell. The weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_flashlight = FALSE
	can_charge = FALSE

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
	execution_speed = 5 SECONDS

/obj/item/gun/energy/disabler/Initialize(mapload)
	. = ..()
	cell.maxcharge = 800
	cell.charge = 800

/obj/item/gun/energy/disabler/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	var/obj/item/gun/energy/disabler/offhand_disabler = user.get_inactive_hand()
	if(istype(offhand_disabler) && offhand_disabler.semicd && (user.a_intent != INTENT_HARM))
		return

	return ..()

/obj/item/gun/energy/disabler/smg
	name = "disabler smg"
	desc = "An automatic disabler variant, as opposed to the conventional model. Boasts a higher ammunition capacity at the cost of slightly reduced beam effectiveness."
	icon_state = "disabler_smg"
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/smg)
	shaded_charge = TRUE
	can_holster = FALSE
	fire_delay = 0

/obj/item/gun/energy/disabler/smg/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.15 SECONDS, allow_akimbo = FALSE)

/obj/item/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/cyborg)
	can_charge = FALSE

/obj/item/gun/energy/disabler/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/disabler/silencer
	name = "u-ION Silencer"
	desc = "Nanotrasen's take on silenced weapons. A quiet lethal disabler, designed to make the death look like a natural cause."
	icon_state = "tesla"
	item_state = "tesla"
	origin_tech = "combat=6;syndicate=2"
	shaded_charge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/silencer_ammo)
	suppressed = TRUE
	execution_speed = 4 SECONDS
