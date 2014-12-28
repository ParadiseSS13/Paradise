/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	req_tech = list("combat" = 3, "materials" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$uranium" = 2000)
	reliability_base = 76
	build_path = /obj/item/weapon/gun/energy/gun/nuclear
	locked = 1
	category = list("Weapons")

/datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list("combat" = 6, "materials" = 7, "biotech" = 5, "powerstorage" = 6)
	build_type = PROTOLATHE
	materials = list("$gold" = 5000,"$uranium" = 10000, "mutagen" = 40)
	build_path = /obj/item/weapon/gun/energy/decloner
	locked = 1
	category = list("Weapons")	
	
/datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A reverse-engineered energy crossbow favored by syndicate infiltration teams and carp hunters."
	id = "largecrossbow"
	req_tech = list("combat" = 5, "materials" = 5, "engineering" = 3, "biotech" = 4, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1500, "$uranium" = 1500, "$silver" = 1500)
	build_path = /obj/item/weapon/gun/energy/crossbow/largecrossbow
	locked = 1
	category = list("Weapons")
	
/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list("materials" = 2, "biotech" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$glass" = 500, "radium" = 20)
	build_path = /obj/item/weapon/gun/energy/floragun
	category = list("Weapons")
	
/datum/design/ionrifle
	name = "Ion Rifle"
	desc = "How to dismantle a cyborg : The gun."
	id = "ionrifle"
	req_tech = list("combat" = 5, "materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list("$silver" = 4000, "$metal" = 6000, "$uranium" = 1000)
	build_path = /obj/item/weapon/gun/energy/ionrifle
	locked = 1
	category = list("Weapons")

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000)
	reliability_base = 79
	build_path = /obj/item/weapon/grenade/chem_grenade/large
	category = list("Weapons")
	
/datum/design/lasercannon
	name = "Laser Cannon"
	desc = "A heavy duty laser cannon."
	id = "lasercannon"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 10000, "$glass" = 2000, "$diamond" = 2000)
	build_path = /obj/item/weapon/gun/energy/lasercannon
	locked = 1
	category = list("Weapons")	
	
/datum/design/plasmapistol
	name = "Plasma Pistol"
	desc = "A specialized firearm designed to fire lethal bolts of toxins."
	id = "ppistol"
	req_tech = list("combat" = 5, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$plasma" = 3000)
	build_path = /obj/item/weapon/gun/energy/toxgun
	locked = 1
	category = list("Weapons")
	
/datum/design/smg
	name = "Prototype Submachine Gun"
	desc = "A prototype weapon made using lightweight materials on a traditional frame, designed to fire standard 9mm rounds."
	id = "smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 8000, "$silver" = 2000, "$diamond" = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic
	locked = 1
	category = list("Weapons")	
	
/datum/design/mag_smg
	name = "Prototype Submachine Gun Magazine (9mm)"
	desc = "A 20-round magazine for the prototype submachine gun."
	id = "mag_smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000)
	build_path = /obj/item/ammo_box/magazine/smgm9mm
	category = list("Weapons")

/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000)
	build_path = /obj/item/weapon/gun/syringe/rapidsyringe
	locked = 1
	category = list("Weapons")
	
/datum/design/stunshell
	name = "Stun Shell"
	desc = "A stunning shell for a shotgun."
	id = "stunshell"
	req_tech = list("combat" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 200)
	build_path = /obj/item/ammo_casing/shotgun/stunslug
	category = list("Weapons")	
	
/datum/design/stunrevolver
	name = "Stun Revolver"
	desc = "A high-tech revolver that fires internal, reusable stun cartidges in a revolving cylinder. The stun cartridges can be recharged using a conventional energy weapon recharger."
	id = "stunrevolver"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 4000)
	build_path = /obj/item/weapon/gun/energy/stunrevolver
	locked = 1
	category = list("Weapons")

/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that shoots temperature bullet energy things to change temperature."//Change it if you want
	id = "temp_gun"
	req_tech = list("combat" = 3, "materials" = 4, "powerstorage" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 500, "$silver" = 3000)
	build_path = /obj/item/weapon/gun/energy/temperature
	locked = 1
	category = list("Weapons")

/datum/design/suppressor
	name = "Universal Suppressor"
	desc = "A reverse-engineered universal suppressor that fits on most small arms with threaded barrels."
	id = "suppressor"
	req_tech = list("combat" = 6, "engineering" = 5, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$silver" = 500)
	build_path = /obj/item/weapon/suppressor
	category = list("Weapons")	
	
/datum/design/techshell
	name = "Unloaded Technological Shotshell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	id = "techshotshell"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 4, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 1000, "$glass" = 200, "$silver" = 300)
	build_path = /obj/item/ammo_casing/shotgun/techshell
	category = list("Weapons")

/datum/design/xray
	name = "Xray Laser Gun"
	desc = "Not quite as menacing as it sounds"
	id = "xray"
	req_tech = list("combat" = 6, "materials" = 5, "biotech" = 5, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list("$gold" = 5000,"$uranium" = 10000, "$metal" = 4000)
	build_path = /obj/item/weapon/gun/energy/xray
	locked = 1
	category = list("Weapons")