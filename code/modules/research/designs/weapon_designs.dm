/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/nuclear_gun
	name = "Advanced Energy Gun Parts Kit"
	desc = "A kit for an energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	req_tech = list("combat" = 5, "magnets" = 5, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000, MAT_URANIUM = 3000, MAT_TITANIUM = 1000)
	build_path = /obj/item/weaponcrafting/gunkit/nuclear
	category = list("Weapons")

/datum/design/decloner
	name = "Decloner Parts Kit"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list("combat" = 5, "materials" = 5, "biotech" = 6, "plasmatech" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000,MAT_URANIUM = 10000)
	build_path = /obj/item/weaponcrafting/gunkit/decloner
	category = list("Weapons")

/datum/design/largecrossbow
	name = "Energy Crossbow Parts Kit"
	desc = "A kit to reverse-engineer a laser gun into an energy crossbow, favored by syndicate infiltration teams and carp hunters."
	id = "largecrossbow"
	req_tech = list("combat" = 5, "engineering" = 3, "magnets" = 5, "syndicate" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1500, MAT_URANIUM = 1500, MAT_SILVER = 1500)
	build_path = /obj/item/weaponcrafting/gunkit/ebow
	category = list("Weapons")

/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list("materials" = 2, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500)
	reagents_list = list("radium" = 20)
	build_path = /obj/item/gun/energy/floragun
	category = list("Weapons")

/datum/design/ioncarbine
	name = "Ion Carbine Parts Kit"
	desc = "How to dismantle a cyborg: The gun."
	id = "ioncarbine"
	req_tech = list("combat" = 5, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 6000, MAT_METAL = 8000, MAT_URANIUM = 2000)
	build_path = /obj/item/weaponcrafting/gunkit/ion
	category = list("Weapons")

/datum/design/wormhole_projector
	name = "Bluespace Wormhole Projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	id = "wormholeprojector"
	req_tech = list("combat" = 5, "engineering" = 5, "bluespace" = 7, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 2000, MAT_METAL = 5000, MAT_DIAMOND = 2000, MAT_BLUESPACE = 3000)
	build_path = /obj/item/gun/energy/wormhole_projector
	locked = TRUE
	access_requirement = list(ACCESS_RD) //screw you, HoS, this aint yours; this is only for a man of science---and trouble.
	category = list("Weapons")

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	req_tech = list("combat" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/grenade/chem_grenade/large
	category = list("Weapons")

/datum/design/pyro_grenade
	name = "Pyro Grenade"
	desc = "An advanced grenade that is able to self ignite its mixture."
	id = "pyro_Grenade"
	req_tech = list("combat" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 500)
	build_path = /obj/item/grenade/chem_grenade/pyro
	category = list("Weapons")

/datum/design/cryo_grenade
	name = "Cryo Grenade"
	desc = "An advanced grenade that rapidly cools its contents upon detonation."
	id = "cryo_Grenade"
	req_tech = list("combat" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 500)
	build_path = /obj/item/grenade/chem_grenade/cryo
	category = list("Weapons")

/datum/design/adv_grenade
	name = "Advanced Release Grenade"
	desc = "An advanced grenade that can be detonated several times, best used with a repeating igniter."
	id = "adv_Grenade"
	req_tech = list("combat" = 3, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 500)
	build_path = /obj/item/grenade/chem_grenade/adv_release
	category = list("Weapons")

/datum/design/tele_shield
	name = "Telescopic Riot Shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	id = "tele_shield"
	req_tech = list("combat" = 4, "materials" = 3, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 4000, MAT_SILVER = 300, MAT_TITANIUM = 200)
	build_path = /obj/item/shield/riot/tele
	category = list("Weapons")

/datum/design/lasercannon
	name = "Accelerator Laser Cannon Parts Kit"
	desc = "Parts for a heavy duty laser cannon. It does more damage the farther away the target is."
	id = "lasercannon"
	req_tech = list("combat" = 5, "magnets" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 3000, MAT_DIAMOND = 3000)
	build_path = /obj/item/weaponcrafting/gunkit/accelerator
	category = list("Weapons")

/datum/design/lwap
	name = "LWAP Laser Sniper Parts Kit"
	desc = "Parts for a scoped laser sniper. It does more damage the farther away the target is, and can knock them down if it goes far enough."
	id = "lwap"
	req_tech = list("combat" = 7, "magnets" = 7, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000, MAT_GLASS = 8000, MAT_GOLD = 5000, MAT_DIAMOND = 8000)
	build_path = /obj/item/weaponcrafting/gunkit/lwap
	category = list("Weapons")

/datum/design/plasmapistol
	name = "Plasma Pistol Parts Kit"
	desc = "A kit for a specialized firearm designed to fire heated bolts of plasma. Can be charged up for a shield breaking shot."
	id = "ppistol"
	req_tech = list("combat" = 5, "magnets" = 5, "powerstorage" = 5, "plasmatech" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_PLASMA = 3000)
	build_path = /obj/item/weaponcrafting/gunkit/plasma
	category = list("Weapons")

/datum/design/sparker
	name = "SPRK-12 Pistol Parts Kit"
	desc = "A small, pistol-sized laser gun designed to regain charges from EMPs. Energy efficient, though it's beams are weaker. Good at dual wielding, however."
	id = "sparker"
	req_tech = list("combat" = 5, "magnets" = 5, "powerstorage" = 5, "plasmatech" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1000, MAT_SILVER = 1500)
	build_path = /obj/item/weaponcrafting/gunkit/sparker
	category = list("Weapons")

//WT550 Mags
/datum/design/mag_oldsmg
	name = "WT-550 PDW Magazine (4.6x30mm)"
	desc = "A 20 round magazine for the WT-550 PDW."
	id = "mag_oldsmg"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/empty
	category = list("Weapons")

/datum/design/box_oldsmg
	name = "WT-550 PDW Ammo Box (4.6x30mm)"
	desc = "A box of 20 rounds for the WT-550 PDW."
	id = "box_oldsmg"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_box/wt550
	category = list("Weapons")

/datum/design/box_oldsmg/ap_box
	name = "WT-550 PDW Armour Piercing Ammo Box (4.6x30mm AP)"
	desc = "A box of 20 armour piercing rounds for the WT-550 PDW."
	id = "box_oldsmg_ap"
	materials = list(MAT_METAL = 6000, MAT_SILVER = 600)
	build_path = /obj/item/ammo_box/wt550/wtap
	category = list("Weapons")

/datum/design/box_oldsmg/ic_box
	name = "WT-550 PDW Incendiary Ammo Box (4.6x30mm IC)"
	desc = "A box of 20 incendiary rounds for the WT-550 PDW."
	id = "box_oldsmg_ic"
	materials = list(MAT_METAL = 6000, MAT_SILVER = 600, MAT_GLASS = 1000)
	build_path = /obj/item/ammo_box/wt550/wtic
	category = list("Weapons")

/datum/design/box_oldsmg/tx_box
	name = "WT-550 PDW Uranium Ammo Box (4.6x30mm TX)"
	desc = "A box of 20 uranium tipped rounds for the WT-550 PDW."
	id = "box_oldsmg_tx"
	materials = list(MAT_METAL = 6000, MAT_SILVER = 600, MAT_URANIUM = 2000)
	build_path = /obj/item/ammo_box/wt550/wttx
	category = list("Weapons")

/datum/design/laser_rifle_magazine
	name = "Laser Rifle Projector Magazine"
	desc = "A 20 round encased projector magazine for the IK Laser Rifle series."
	id = "mag_laser"
	build_type = PROTOLATHE
	req_tech = list("combat" = 4, "powerstorage" = 4)
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 600)
	build_path = /obj/item/ammo_box/magazine/laser
	category = list("Weapons")

/datum/design/laser_rifle_ammo_box
	name = "Laser Rifle Projector Ammunition"
	desc = "A 20 round encased projector box for the IK Laser Rifle series."
	id = "box_laser"
	build_type = PROTOLATHE
	req_tech = list("combat" = 4, "powerstorage" = 4)
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 600)
	build_path = /obj/item/ammo_box/laser
	category = list("Weapons")

/datum/design/stunrevolver
	name = "Arc Revolver Parts Kit"
	desc = "A high-tech revolver that fires internal, reusable shock cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers. These shots charge whatever they hit, causing arcs of electricity to form between them."
	id = "stunrevolver"
	req_tech = list("combat" = 7, "materials" = 6, "powerstorage" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 10000, MAT_SILVER = 10000)
	build_path = /obj/item/weaponcrafting/gunkit/tesla
	category = list("Weapons")

/datum/design/temp_gun
	name = "Temperature Gun Parts Kit"
	desc = "A gun that changes the body temperature of its targets."
	id = "temp_gun"
	req_tech = list("combat" = 4, "materials" = 4, "powerstorage" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 500, MAT_SILVER = 3000)
	build_path = /obj/item/weaponcrafting/gunkit/temperature
	category = list("Weapons")

/datum/design/suppressor
	name = "Universal Suppressor"
	desc = "A reverse-engineered universal suppressor that fits on most small arms with threaded barrels."
	id = "suppressor"
	req_tech = list("combat" = 6, "engineering" = 5, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 500)
	build_path = /obj/item/suppressor
	category = list("Weapons")

/datum/design/techshell
	name = "Unloaded Technological Shotshell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	id = "techshotshell"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 4, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 200)
	build_path = /obj/item/ammo_casing/shotgun/techshell
	category = list("Weapons")

/datum/design/xray
	name = "Xray Laser Gun Parts Kit"
	desc = "A full conversion kit for a laser gun allowing it to fire through walls."
	id = "xray"
	req_tech = list("combat" = 7, "magnets" = 5, "biotech" = 5, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000, MAT_URANIUM = 4000, MAT_METAL = 5000, MAT_TITANIUM = 2000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/weaponcrafting/gunkit/xray
	category = list("Weapons")

/datum/design/immolator
	name = "Immolator Laser Gun Parts Kit"
	desc = "Has fewer shots than a regular laser gun, but ignites the target on hit."
	id = "immolator"
	req_tech = list("combat" = 5, "magnets" = 5, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000, MAT_SILVER = 3000, MAT_PLASMA = 2000)
	build_path = /obj/item/weaponcrafting/gunkit/immolator
	category = list("Weapons")

/datum/design/reactive_armour
	name = "Reactive Armor Shell"
	desc = "A reactive armor shell, that can have an anomaly core inserted to make a reactive armor."
	id = "reactivearmor"
	req_tech = list("combat" = 6, "materials" = 7, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_PLASMA = 8000, MAT_TITANIUM = 14000, MAT_BLUESPACE = 6000) //Big strong armor needs big-ish investment
	build_path = /obj/item/reactive_armour_shell
	locked = TRUE
	access_requirement = list(ACCESS_RD)
	category = list("Weapons")

/datum/design/bsg
	name = "Blue Space Gun"
	desc = "A heavy hitting energy cannon, that fires destructive bluespace blasts with a decent area of effect."
	id = "bsg"
	req_tech = list("combat" = 7, "materials" = 7, "magnets" = 7, "powerstorage" = 7, "bluespace" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12000, MAT_GLASS = 2000, MAT_SILVER = 4000, MAT_PLASMA = 4000,  MAT_TITANIUM = 4000, MAT_BLUESPACE = 6000) // Big gun, big cost
	build_path = /obj/item/gun/energy/bsg
	locked = TRUE
	category = list("Weapons")

/datum/design/dropwall
	name = "Dropwall Generator"
	desc = "A prototype shield generator design that was inspired by shellguard munitions spartan division. Generates a directional shield to block projectiles and explosions."
	id = "drop_wall"
	req_tech = list("combat" = 5, "materials" = 5, "engineering" = 5, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1200, MAT_SILVER = 100, MAT_TITANIUM = 100, MAT_PLASMA = 100)
	build_path = /obj/item/grenade/barrier/dropwall
	category = list("Weapons")

/datum/design/pyroclaw
	name = "Fusion Gauntlets"
	desc = "A pair of gloves designed to make superheated claws capable of cutting through almost anything. Needs a pyro anomaly core"
	id = "pyro_gloves"
	req_tech = list("combat" = 7, "materials" = 7, "engineering" = 7, "plasmatech" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_SILVER = 4000, MAT_TITANIUM = 4000, MAT_PLASMA = 8000)
	build_path = /obj/item/clothing/gloves/color/black/pyro_claws
	category = list("Weapons")

/datum/design/silencer
	name = "u-ION Silencer Parts Kit"
	desc = "Nanotrasens take on silenced weapons. A quiet lethal disabler, designed to make the death look like a natural cause."
	id = "silencer"
	req_tech = list("combat" = 7, "magnets" = 6, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000, MAT_URANIUM = 4000, MAT_METAL = 5000, MAT_TITANIUM = 2000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/weaponcrafting/gunkit/u_ionsilencer
	category = list("Weapons")

/datum/design/v1_arm
	name = "Vortex arm implant shell"
	desc = "A shell to make an arm able to parry, reflect, and boost the power of incoming projectiles."
	id = "v1_arm"
	req_tech = list("combat" = 7, "magnets" = 6, "engineering" = 6, "biotech" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000, MAT_URANIUM = 4000, MAT_METAL = 10000, MAT_TITANIUM = 2000, MAT_BLUESPACE = 2000)
	reagents_list = list("blood" = 50)
	build_path = /obj/item/v1_arm_shell
	category = list("Weapons")

/datum/design/muscle_implant
	name = "Strong-arm Empowered Musculature Implant"
	desc = "An implant that enhances your muscles to punch harder and throw people back."
	id = "muscle_implant"
	req_tech = list("combat" = 7, "syndicate" = 4, "biotech" = 7)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_GOLD = 5000, MAT_METAL = 10000, MAT_TITANIUM = 3000, MAT_BLUESPACE = 2000)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/muscle
	category = list("Medical", "Weapons")

/datum/design/upgraded_chemical_flamethrower
	name = "Extended Capacity Chemical Flamethrower Parts"
	desc = "Parts for a flamethrower that accepts two chemical cartridges to create lasting fires."
	id = "chem_flamethrower_extended"
	req_tech = list("combat" = 6, "engineering" = 7, "plasmatech" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_TITANIUM = 7000, MAT_METAL = 13000, MAT_GOLD = 1000)
	build_path = /obj/item/weaponcrafting/gunkit/chemical_flamethrower
	category = list("Weapons")

// The normal and extended canisters can be obtained from cargo aswell, pyrotechnical ones are RnD exclusive
/datum/design/chemical_canister
	name = "Chemical Canister"
	desc = "A plain chemical canister, designed for use with a chemical flamethrower."
	id = "chemical_canister"
	req_tech = list("materials" = 3, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000)
	reagents_list = list("fuel" = 20)
	build_path = /obj/item/chemical_canister
	category = list("Weapons")

/datum/design/chemical_canister/extended
	name = "Extended Capacity Chemical Canister"
	desc = "A large chemical canister, designed for use with a chemical flamethrower."
	id = "chemical_canister_extended"
	req_tech = list("materials" = 5, "plasmatech" = 4)
	materials = list(MAT_METAL = 10000)
	reagents_list = list("fuel" = 40)
	build_path = /obj/item/chemical_canister/extended
	category = list("Weapons")

/datum/design/chemical_canister/pyrotechnics
	name = "Chemical Canister (Pyrotechnics)"
	desc = "A chemical canister designed to accept pyrotechnics."
	id = "chemical_canister_pyro"
	req_tech = list("materials" = 4, "plasmatech" = 6)
	materials = list(MAT_METAL = 7500)
	reagents_list = list("fuel" = 30)
	build_path = /obj/item/chemical_canister/pyrotechnics
	category = list("Weapons")

/datum/design/nt_mantis
	name = "'Scylla' mantis blade implant"
	desc = "A reverse-engineered mantis blade implant. While the monomolecular edge was lost, they remain deadly weapons."
	id = "mantis_blade_nt"
	req_tech = list("materials" = 7, "engineering" = 6, "combat" = 7, "syndicate" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 6 SECONDS
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2000, MAT_GOLD = 2000, MAT_TITANIUM = 3000, MAT_DIAMOND = 4000)
	build_path = /obj/item/organ/internal/cyberimp/arm/nt_mantis
	category = list("Medical", "Weapons")

