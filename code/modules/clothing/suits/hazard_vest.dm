/obj/item/clothing/suit/storage/hazardvest
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard"
	item_state = "hazard"
	blood_overlay_type = "armor"
	allowed = list (/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcd, /obj/item/rpd)
	resistance_flags = NONE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi'
		)

/obj/item/clothing/suit/storage/hazardvest/engi
	name = "engineering hazard vest"
	desc = "A high-visibility vest used in work zones. This one has engineering colors."
	icon_state = "hazard_engi"
	item_state = "hazard_engi"

/obj/item/clothing/suit/storage/hazardvest/atmos
	name = "atmospheric hazard vest"
	desc = "A high-visibility vest used in work zones. This one has atmospheric colors."
	icon_state = "hazard_atmos"
	item_state = "hazard_atmos"

/obj/item/clothing/suit/storage/hazardvest/ce
	name = "chief engineer's hazard vest"
	desc = "A high-visibility vest used in work zones. This one belongs to chief engineer. It's made out of strong material."
	icon_state = "hazard_CE"
	item_state = "hazard_CE"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 50, ACID = 50) // CE is special enough that they can probably get some minor armor
	allowed = list (/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcd, /obj/item/rpd, /obj/item/melee/classic_baton/telescopic) // Same as regular, but also can hold their telebaton

/obj/item/clothing/suit/storage/hazardvest/cargo
	name = "cargo hazard vest"
	desc = "A high-visibility vest used in work zones. This one has cargo colors."
	icon_state = "hazard_cargo"
	item_state = "hazard_cargo"
	allowed = list (/obj/item/flashlight, /obj/item/paper, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcs, /obj/item/destTagger)

/obj/item/clothing/suit/storage/hazardvest/qm
	name = "quartermaster's hazard vest"
	desc = "A high-visibility vest used in work zones. This one belongs to quartermaster."
	icon_state = "hazard_QM"
	item_state = "hazard_QM"
	allowed = list (/obj/item/flashlight, /obj/item/paper, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcs, /obj/item/destTagger, /obj/item/melee/classic_baton/telescopic)

/obj/item/clothing/suit/storage/hazardvest/sec
	name = "security hazard vest"
	desc = "A high-visibility vest used in work zones. This one has security colors. It does not look durable."
	icon_state = "hazard_sec"
	item_state = "hazard_sec"
	allowed = list (/obj/item/tank/internals/emergency_oxygen, /obj/item/gun/energy, /obj/item/reagent_containers/spray/pepper, /obj/item/gun/projectile, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/flashlight, /obj/item/melee/classic_baton/telescopic, /obj/item/clothing/accessory/holobadge)
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 20, ACID = 20) //weak armor, but you also get two pockets

/obj/item/clothing/suit/storage/hazardvest/paramed
	name = "paramedic's hazard vest"
	desc = "A high-visibility vest used in work zones. This one belongs to paramedic."
	icon_state = "hazard_paramed"
	item_state = "hazard_paramed"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe, /obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/radio, /obj/item/tank/internals/emergency_oxygen)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 50, ACID = 50)
