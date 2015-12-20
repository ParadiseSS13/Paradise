/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	req_tech = list("combat" = 4, "materials" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_URANIUM = 2000)
	reliability = 76
	build_path = /obj/item/weapon/gun/energy/gun/nuclear
	locked = 1
	category = list("Weapons")

/datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list("combat" = 6, "materials" = 7, "biotech" = 5, "powerstorage" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000,MAT_URANIUM = 10000)
	reagents = list("mutagen" = 40)
	build_path = /obj/item/weapon/gun/energy/decloner
	locked = 1
	category = list("Weapons")

/datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A reverse-engineered energy crossbow favored by syndicate infiltration teams and carp hunters."
	id = "largecrossbow"
	req_tech = list("combat" = 5, "materials" = 5, "engineering" = 3, "biotech" = 4, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1500, MAT_URANIUM = 1500, MAT_SILVER = 1500)
	build_path = /obj/item/weapon/gun/energy/kinetic_accelerator/crossbow/large
	locked = 1
	category = list("Weapons")
	reliability = 76

/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list("materials" = 2, "biotech" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500)
	reagents = list("radium" = 20)
	build_path = /obj/item/weapon/gun/energy/floragun
	category = list("Weapons")

/datum/design/ioncarbine
	name = "Ion Carbine"
	desc = "How to dismantle a cyborg : The gun."
	id = "ioncarbine"
	req_tech = list("combat" = 5, "materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 4000, MAT_METAL = 6000, MAT_URANIUM = 1000)
	build_path = /obj/item/weapon/gun/energy/ionrifle/carbine
	locked = 1
	category = list("Weapons")

/datum/design/wormhole_projector
	name = "Bluespace Wormhole Projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	id = "wormholeprojector"
	req_tech = list("combat" = 6, "materials" = 6, "bluespace" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 1000, MAT_METAL = 5000, MAT_DIAMOND = 3000)
	build_path = /obj/item/weapon/gun/energy/wormhole_projector
	category = list("Weapons")

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	reliability = 79
	build_path = /obj/item/weapon/grenade/chem_grenade/large
	category = list("Weapons")

/datum/design/tele_shield
	name = "Telescopic Riot Shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	id = "tele_shield"
	req_tech = list("combat" = 4, "materials" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 5000, MAT_SILVER = 300)
	build_path = /obj/item/weapon/shield/riot/tele
	category = list("Weapons")

/datum/design/lasercannon
	name = "Laser Cannon"
	desc = "A heavy duty laser cannon."
	id = "lasercannon"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000, MAT_DIAMOND = 2000)
	build_path = /obj/item/weapon/gun/energy/lasercannon
	locked = 1
	category = list("Weapons")

/datum/design/receiver
	name = "Modular Receiver"
	desc = "A prototype modular receiver and trigger assembly for a variety of firearms."
	id = "receiver"
	req_tech = list("combat" = 5, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6500, MAT_SILVER = 500)
	build_path = /obj/item/weaponcrafting/receiver
	category = list("Weapons")

/datum/design/plasmapistol
	name = "Plasma Pistol"
	desc = "A specialized firearm designed to fire lethal bolts of toxins."
	id = "ppistol"
	req_tech = list("combat" = 5, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_PLASMA = 3000)
	build_path = /obj/item/weapon/gun/energy/toxgun
	locked = 1
	category = list("Weapons")

/datum/design/smg
	name = "Nanotrasen Saber SMG"
	desc = "A prototype weapon made using lightweight materials on a traditional frame, designed to fire standard 9mm rounds."
	id = "smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_SILVER = 2000, MAT_DIAMOND = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic/proto
	locked = 1
	category = list("Weapons")

/datum/design/mag_smg
	name = "Saber Submachine Gun Magazine (9mm)"
	desc = "A 30-round magazine for the Saber submachine gun."
	id = "mag_smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000)
	build_path = /obj/item/ammo_box/magazine/smgm9mm
	category = list("Weapons")

/datum/design/mag_smg/ap_mag
	name = "Saber Submachine Gun Magazine (9mmAP)"
	desc = "A 30-round armour piercing magazine for the Saber submachine gun. Deals slightly less damage but bypasses most armor."
	id = "mag_smg_ap"
	materials = list(MAT_METAL = 3000, MAT_SILVER = 100)
	build_path = /obj/item/ammo_box/magazine/smgm9mm/ap

/datum/design/mag_smg/incin_mag
	name = "Saber Submachine Gun Magazine (9mmIC)"
	desc = "A 30-round incendiary round magazine for the Saber submachine gun. Deals significantly less damage but sets the target on fire."
	id = "mag_smg_ic"
	materials = list(MAT_METAL = 3000, MAT_SILVER = 100, MAT_GLASS = 400)
	build_path = /obj/item/ammo_box/magazine/smgm9mm/fire

/datum/design/mag_smg/incin_tox
	name = "Saber Submachine Gun Magazine (9mmTX)"
	desc = "A 30-round uranium tipped round magazine for the Saber submachine gun. Deals toxin damage, but less overall damage."
	id = "mag_smg_tx"
	materials = list(MAT_METAL = 3000, MAT_GLASS = 200, MAT_URANIUM = 1000)
	build_path = /obj/item/ammo_box/magazine/smgm9mm/toxin

/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/gun/syringe/rapidsyringe
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
	name = "Stun Revolver"
	desc = "A high-tech revolver that fires internal, reusable stun cartidges in a revolving cylinder. The stun cartridges can be recharged using a conventional energy weapon recharger."
	id = "stunrevolver"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/gun/energy/stunrevolver
	locked = 1
	category = list("Weapons")

/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that changes the body temperature of its targets."
	id = "temp_gun"
	req_tech = list("combat" = 3, "materials" = 4, "powerstorage" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 500, MAT_SILVER = 3000)
	build_path = /obj/item/weapon/gun/energy/temperature
	category = list("Weapons")

/datum/design/suppressor
	name = "Universal Suppressor"
	desc = "A reverse-engineered universal suppressor that fits on most small arms with threaded barrels."
	id = "suppressor"
	req_tech = list("combat" = 6, "engineering" = 5, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 500)
	build_path = /obj/item/weapon/suppressor
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
	req_tech = list("combat" = 6, "materials" = 5, "biotech" = 5, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000,MAT_URANIUM = 10000, MAT_METAL = 4000)
	build_path = /obj/item/weapon/gun/energy/xray
	locked = 1
	category = list("Weapons")