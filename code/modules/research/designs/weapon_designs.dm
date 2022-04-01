/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	req_tech = list("combat" = 5, "magnets" = 5, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000, MAT_URANIUM = 3000, MAT_TITANIUM = 1000)
	build_path = /obj/item/gun/energy/gun/nuclear
	locked = 1
	category = list("Weapons")

/datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list("combat" = 5, "materials" = 5, "biotech" = 6, "plasmatech" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000,MAT_URANIUM = 10000)
	reagents_list = list("mutagen" = 40)
	build_path = /obj/item/gun/energy/decloner
	locked = 1
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
	name = "Ion Carbine"
	desc = "How to dismantle a cyborg : The gun."
	id = "ioncarbine"
	req_tech = list("combat" = 5, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 6000, MAT_METAL = 8000, MAT_URANIUM = 2000)
	build_path = /obj/item/gun/energy/ionrifle/carbine
	locked = 1
	category = list("Weapons")

/datum/design/wormhole_projector
	name = "Bluespace Wormhole Projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	id = "wormholeprojector"
	req_tech = list("combat" = 5, "engineering" = 5, "bluespace" = 7, "plasmatech" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 2000, MAT_METAL = 5000, MAT_DIAMOND = 2000, MAT_BLUESPACE = 3000)
	build_path = /obj/item/gun/energy/wormhole_projector
	locked = 1
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
	name = "Accelerator Laser Cannon"
	desc = "A heavy duty laser cannon. It does more damage the farther away the target is."
	id = "lasercannon"
	req_tech = list("combat" = 5, "magnets" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 3000, MAT_DIAMOND = 3000)
	build_path = /obj/item/gun/energy/lasercannon
	locked = 1
	category = list("Weapons")

/datum/design/plasmapistol
	name = "Plasma Pistol"
	desc = "A specialized firearm designed to fire lethal bolts of toxins."
	id = "ppistol"
	req_tech = list("combat" = 5, "magnets" = 5, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_PLASMA = 3000)
	build_path = /obj/item/gun/energy/toxgun
	locked = 1
	category = list("Weapons")

//WT550 Mags

/datum/design/mag_oldsmg
	name = "WT-550 Auto Gun Magazine (4.6x30mm)"
	desc = "A 20 round magazine for the out of date security WT-550 Auto Rifle"
	id = "mag_oldsmg"
	req_tech = list("combat" = 1, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_box/magazine/wt550m9
	category = list("Weapons")

/datum/design/mag_oldsmg/ap_mag
	name = "WT-550 Auto Gun Armour Piercing Magazine (4.6x30mm AP)"
	desc = "A 20 round armour piercing magazine for the out of date security WT-550 Auto Rifle"
	id = "mag_oldsmg_ap"
	materials = list(MAT_METAL = 6000, MAT_SILVER = 600)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtap

/datum/design/mag_oldsmg/ic_mag
	name = "WT-550 Auto Gun Incendiary Magazine (4.6x30mm IC)"
	desc = "A 20 round armour piercing magazine for the out of date security WT-550 Auto Rifle"
	id = "mag_oldsmg_ic"
	materials = list(MAT_METAL = 6000, MAT_SILVER = 600, MAT_GLASS = 1000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtic

/datum/design/mag_oldsmg/tx_mag
	name = "WT-550 Auto Gun Uranium Magazine (4.6x30mm TX)"
	desc = "A 20 round uranium tipped magazine for the out of date security WT-550 Auto Rifle"
	id = "mag_oldsmg_tx"
	materials = list(MAT_METAL = 6000, MAT_SILVER = 600, MAT_URANIUM = 2000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wttx

/datum/design/box_oldsmg
	name = "WT-550 Auto Gun Ammo box (4.6x30mm)"
	desc = "A 40 round ammo box for the out of date security WT-550 Auto Rifle"
	id = "box_oldsmg"
	req_tech = list("combat" = 2, "materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000)
	build_path = /obj/item/ammo_box/c46x30mm
	category = list("Weapons")
/datum/design/box_oldsmg/ap_box
	name = "WT-550 Auto Gun Armour Piercing Ammo box (4.6x30mm AP)"
	desc = "A 40 round armour piercing ammo box for the out of date security WT-550 Auto Rifle"
	id = "box_oldsmg_ap"
	materials = list(MAT_METAL = 12000, MAT_SILVER = 1200)
	build_path = /obj/item/ammo_box/ap46x30mm

/datum/design/box_oldsmg/ic_box
	name = "WT-550 Auto Gun Incendiary Ammo box (4.6x30mm IC)"
	desc = "A 40 round armour piercing ammo box for the out of date security WT-550 Auto Rifle"
	id = "box_oldsmg_ic"
	materials = list(MAT_METAL = 12000, MAT_SILVER = 1200, MAT_GLASS = 2000)
	build_path = /obj/item/ammo_box/inc46x30mm

/datum/design/box_oldsmg/tx_box
	name = "WT-550 Auto Gun Uranium Ammo box (4.6x30mm TX)"
	desc = "A 20 round uranium tipped ammo box for the out of date security WT-550 Auto Rifle"
	id = "box_oldsmg_tx"
	materials = list(MAT_METAL = 12000, MAT_SILVER = 1200, MAT_URANIUM = 4000)
	build_path = /obj/item/ammo_box/tox46x30mm

/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	req_tech = list("combat" = 2, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	build_path = /obj/item/gun/syringe/rapidsyringe
	category = list("Weapons")

/datum/design/stunshell
	name = "Stun Shell"
	desc = "A stunning shell for a shotgun."
	id = "stunshell"
	req_tech = list("combat" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/ammo_casing/shotgun/stunslug
	category = list("Weapons")

/datum/design/stunrevolver
	name = "Tesla Revolver"
	desc = "A high-tech revolver that fires internal, reusable shock cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers."
	id = "stunrevolver"
	req_tech = list("combat" = 4, "materials" = 4, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 10000, MAT_SILVER = 10000)
	build_path = /obj/item/gun/energy/shock_revolver
	locked = 1
	category = list("Weapons")

/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that changes the body temperature of its targets."
	id = "temp_gun"
	req_tech = list("combat" = 4, "materials" = 4, "powerstorage" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 500, MAT_SILVER = 3000)
	build_path = /obj/item/gun/energy/temperature
	category = list("Weapons")

/datum/design/techshell
	name = "Unloaded Technological Shotshell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	id = "techshotshell"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 4, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 200)
	build_path = /obj/item/ammo_casing/shotgun/techshell
	category = list("Weapons")

/datum/design/xray
	name = "Xray Laser Gun"
	desc = "Not quite as menacing as it sounds"
	id = "xray"
	req_tech = list("combat" = 7, "magnets" = 5, "biotech" = 5, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000, MAT_URANIUM = 4000, MAT_METAL = 5000, MAT_TITANIUM = 2000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/gun/energy/xray
	locked = 1
	category = list("Weapons")

/datum/design/immolator
	name = "Immolator Laser Gun"
	desc = "Has fewer shots than a regular laser gun, but ignites the target on hit"
	id = "immolator"
	req_tech = list("combat" = 5, "magnets" = 5, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000, MAT_SILVER = 3000, MAT_PLASMA = 2000)
	build_path = /obj/item/gun/energy/immolator
	locked = 1
	category = list("Weapons")

/datum/design/ipc_combat_upgrade
	name = "IPC combat upgrade"
	desc = "Advanced data storage designed to be compatible with positronic systems.This one include melee algorithms along with overwritten microbattery safety protocols."
	materials = list(MAT_METAL=800, MAT_GLASS=1000, MAT_GOLD=2800, MAT_DIAMOND=1650)
	id = "ipccombatupgrade"
	build_type = PROTOLATHE
	req_tech = list("combat" = 6, "magnets" = 5, "powerstorage" = 5, "engineering" = 4,"programming" = 5)
	build_path = /obj/item/ipc_combat_upgrade
	locked = 1
	category = list("Weapons")

/////////////////////////////////////////
////////////////ILLEGAL//////////////////
/////////////////////////////////////////

/datum/design/antimov_module
	name = "Core AI Module (Antimov)"
	desc = "Allows for the construction of a Antimov AI Core Module."
	id = "antimov_module"
	req_tech = list("programming" = 5, "syndicate" = 2, "materials" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/antimov
	locked = 1
	category = list("ILLEGAL")

/datum/design/tyrant_module
	name = "Core AI Module (T.Y.R.A.N.T.)"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
	id = "tyrant_module"
	req_tech = list("programming" = 5, "syndicate" = 2, "materials" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/tyrant
	locked = 1
	category = list("ILLEGAL")

/datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A reverse-engineered energy crossbow favored by syndicate infiltration teams and carp hunters."
	id = "largecrossbow"
	req_tech = list("combat" = 5, "engineering" = 3, "magnets" = 5, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1500, MAT_URANIUM = 1500, MAT_SILVER = 1500)
	build_path = /obj/item/gun/energy/kinetic_accelerator/crossbow/large
	locked = 1
	category = list("ILLEGAL")

/datum/design/suppressor
	name = "Universal Suppressor"
	desc = "A reverse-engineered universal suppressor that fits on most small arms with threaded barrels."
	id = "suppressor"
	req_tech = list("combat" = 6, "engineering" = 5, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 500)
	build_path = /obj/item/suppressor
	locked = 1
	category = list("ILLEGAL")

/datum/design/stechkin
	name = "Stechkin pistol"
	desc = "A reverse-engineered small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	id = "stechkin"
	req_tech = list("combat" = 6, "engineering" = 6, "syndicate" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_TITANIUM = 5000)
	build_path = /obj/item/gun/projectile/automatic/pistol
	locked = 1
	category = list("ILLEGAL")

/datum/design/chameleon_kit
	name = "Chameleon kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station." // "Набор хамелеона изученный с помощью реверс инженеринга."
	id = "chameleon_kit"
	req_tech = list("combat" = 4, "engineering" = 6, "syndicate" = 4, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_GLASS = 3000, MAT_SILVER = 2000, MAT_DIAMOND = 1000)
	build_path = /obj/item/storage/box/syndie_kit/chameleon
	locked = 1
	category = list("ILLEGAL")

/datum/design/adrenaline
	name = "Adrenaline implant"
	desc = "A glass case containing an adrenaline implant." // "Кейс с адреналин имплантом, который позволяет игнорировать шокеры, в течение котороткого времени."
	id = "implant_adrenaline"
	req_tech = list("syndicate" = 2, "programming" = 3, "biotech"= 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 50,)
	reagents_list = list("omnizine" = 10)
	build_path = /obj/item/implantcase/adrenaline
	locked = 1
	category = list("ILLEGAL")

/datum/design/Freedom
	name = "Freedom implant"
	desc = "A glass case containing a freedom implant." // "Кейс с имплантом, который позволяет освобождаться от наручников ограниченное количество раз."
	id = "implant_freedom"
	req_tech = list("syndicate" = 2, "programming" = 3, "biotech"= 4,"materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 3000,)
	build_path = /obj/item/implantcase/freedom
	locked = 1
	category = list("ILLEGAL")

/datum/design/encryptionkey_binary
	name = "Binary encryptionkey"
	desc = "An encryption key for a radio headset. To access the binary channel, use :+." // "Ключ шифрования, на которой переговариваеются борги и ИИ."
	id = "binarykey"
	req_tech = list("engineering" = 4, "syndicate" = 3, "programming" = 4,"materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000,)
	build_path = /obj/item/encryptionkey/binary
	locked = 1
	category = list("ILLEGAL")

/datum/design/encryptionkey_syndicate
	name = "Syndicate encryptionkey"
	desc = "An encyption key for a radio headset. Contains syndicate cypherkeys." // "Ключ шифрования синдиката, позволяющий перехватывать другие зашифрованные радиоволны."
	id = "syndicatekey"
	req_tech = list("engineering" = 4, "syndicate" = 4, "programming" = 4,"materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000,)
	build_path = /obj/item/encryptionkey/syndicate
	locked = 1
	category = list("ILLEGAL")

/datum/design/aiModule_syndicate
	name = "Hacked AI module"
	desc = "A hacked AI law module"
	id = "syndiaimodule"
	req_tech = list("syndicate" = 6, "programming" = 5, "materials" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/syndicate
	locked = 1
	category = list("ILLEGAL")

/datum/design/incendiary_10mm
	name = "pistol magazine 10mm incendiary"
	desc = "A gun magazine. Loaded with rounds which ignite the target."
	id = "10mminc"
	req_tech = list("combat" = 4, "syndicate" = 2, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_PLASMA = 10,)
	build_path = /obj/item/ammo_box/magazine/m10mm/fire
	locked = 1
	category = list("ILLEGAL")

/datum/design/radio_jammer
	name = "radio jammer"
	desc = "Device used to disrupt nearby radio communication."
	id = "jammer"
	req_tech = list("engineering" = 4, "syndicate" = 3, "programming" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000, MAT_SILVER = 500)
	build_path = /obj/item/jammer
	locked = 1
	category = list("ILLEGAL")

/datum/design/syndie_rcd
	name = "Syndicate RCD"
	desc = "A device used to rapidly build and deconstruct walls, floors and airlocks. This one is made by syndicate"
	id = "syndie_rcd"
	req_tech = list("materials" = 2, "engineering" = 4, "syndicate" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000, MAT_GLASS=8000, MAT_PLASMA = 10000, MAT_TITANIUM = 10000)
	build_path = /obj/item/rcd/syndicate
	locked = 1
	category = list("ILLEGAL")

/datum/design/syndie_rcd_ammo
	name = "suspicious matter cartridge"
	desc = "Highly compressed matter for the RCD."
	id = "syndie_rcd_ammo"
	req_tech = list("materials" = 3, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_GLASS = 4000, MAT_TITANIUM = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/rcd_ammo/syndicate
	locked = 0
	category = list("ILLEGAL")

/datum/design/syndie_rcd_ammo_large
	name = "large suspicious matter cartridge"
	desc = "Highly compressed matter for the RCD."
	id = "syndie_rcd_ammo_large"
	req_tech = list("materials" = 3, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 40000, MAT_GLASS = 20000, MAT_TITANIUM = 20000, MAT_PLASMA = 20000)
	build_path = /obj/item/rcd_ammo/syndicate/large
	locked = 0
	category = list("ILLEGAL")
