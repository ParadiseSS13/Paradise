////////////////////////////////////////
/////////// Mecha Equpment /////////////
////////////////////////////////////////

datum/design/mech_scattershot
	name = "Exosuit Weapon Design (LBX AC 10 \"Scattershot\")"
	desc = "Allows for the construction of LBX AC 10."
	id = "mech_scattershot"
	build_type = MECHFAB
	req_tech = list("combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	category = "Exosuit Equipment"

datum/design/mech_carbine
	name = "Exosuit Weapon Design (FNX-66 Carbine)"
	desc = "Allows for the construction of FNX-66 Carbine."
	id = "mech_carbine"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "materials" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	category = "Exosuit Equipment"

datum/design/mech_ion
	name = "Exosuit Weapon Design (MKIV Ion Heavy Cannon)"
	desc = "Allows for the construction of MKIV Ion Heavy Cannon."
	id = "mech_ion"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "magnets" = 5, "materials" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	category = "Exosuit Equipment"

datum/design/mech_laser
	name = "Exosuit Weapon Design (CH-PS \"Immolator\" Laser)"
	desc = "Allows for the construction of CH-PS Laser."
	id = "mech_laser"
	build_type = MECHFAB
	req_tech = list("combat" = 3, "magnets" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	category = "Exosuit Equipment"

datum/design/mech_laser_heavy
	name = "Exosuit Weapon Design (CH-LC \"Solaris\" Laser Cannon)"
	desc = "Allows for the construction of CH-LC Laser Cannon."
	id = "mech_laser_heavy"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "magnets" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	category = "Exosuit Equipment"

datum/design/mech_grenade_launcher
	name = "Exosuit Weapon Design (SGL-6 Grenade Launcher)"
	desc = "Allows for the construction of SGL-6 Grenade Launcher."
	id = "mech_grenade_launcher"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	category = "Exosuit Equipment"

datum/design/mech_missile_rack
	name = "Exosuit Weapon Design (SRM-8 Missile Rack)"
	desc = "Allows for the construction of SRM-8 Missile Rack."
	id = "mech_missile_rack"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "materials" = 6)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	category = "Exosuit Equipment"

datum/design/clusterbang_launcher
	name = "Exosuit Module Design (SOB-3 Clusterbang Launcher)"
	desc = "A weapon that violates the Geneva Convention at 3 rounds per minute"
	id = "clusterbang_launcher"
	build_type = MECHFAB
	req_tech = list("combat"= 5, "materials" = 5, "syndicate" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang
	category = "Exosuit Equipment"

datum/design/mech_wormhole_gen
	name = "Exosuit Module Design (Localized Wormhole Generator)"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	id = "mech_wormhole_gen"
	build_type = MECHFAB
	req_tech = list("bluespace" = 3, "magnets" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	category = "Exosuit Equipment"

datum/design/mech_teleporter
	name = "Exosuit Module Design (Teleporter Module)"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	id = "mech_teleporter"
	build_type = MECHFAB
	req_tech = list("bluespace" = 10, "magnets" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	category = "Exosuit Equipment"

datum/design/mech_rcd
	name = "Exosuit Module Design (RCD Module)"
	desc = "An exosuit-mounted Rapid Construction Device."
	id = "mech_rcd"
	build_type = MECHFAB
	req_tech = list("materials" = 4, "bluespace" = 3, "magnets" = 4, "powerstorage"=4, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/rcd
	category = "Exosuit Equipment"

datum/design/mech_gravcatapult
	name = "Exosuit Module Design (Gravitational Catapult Module)"
	desc = "An exosuit mounted Gravitational Catapult."
	id = "mech_gravcatapult"
	build_type = MECHFAB
	req_tech = list("bluespace" = 2, "magnets" = 3, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	category = "Exosuit Equipment"

datum/design/mech_repair_droid
	name = "Exosuit Module Design (Repair Droid Module)"
	desc = "Automated Repair Droid. BEEP BOOP"
	id = "mech_repair_droid"
	build_type = MECHFAB
	req_tech = list("magnets" = 3, "programming" = 3, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	category = "Exosuit Equipment"

datum/design/mech_plasma_generator
	name = "Exosuit Module Design (Plasma Converter Module)"
	desc = "Exosuit-mounted plasma converter."
	id = "mech_plasma_generator"
	build_type = MECHFAB
	req_tech = list("plasmatech" = 2, "powerstorage"= 2, "engineering" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	category = "Exosuit Equipment"

datum/design/mech_energy_relay
	name = "Exosuit Module Design (Tesla Energy Relay)"
	desc = "Tesla Energy Relay"
	id = "mech_energy_relay"
	build_type = MECHFAB
	req_tech = list("magnets" = 4, "powerstorage" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	category = "Exosuit Equipment"

datum/design/mech_ccw_armor
	name = "Exosuit Module Design(Reactive Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_ccw_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	category = "Exosuit Equipment"

datum/design/mech_proj_armor
	name = "Exosuit Module Design(Reflective Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_proj_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 5, "engineering"=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	category = "Exosuit Equipment"

datum/design/mech_syringe_gun
	name = "Exosuit Module Design(Syringe Gun)"
	desc = "Exosuit-mounted syringe gun and chemical synthesizer."
	id = "mech_syringe_gun"
	build_type = MECHFAB
	req_tech = list("materials" = 3, "biotech"=4, "magnets"=4, "programming"=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/syringe_gun
	category = "Exosuit Equipment"

datum/design/mech_diamond_drill
	name = "Exosuit Module Design (Diamond Mining Drill)"
	desc = "An upgraded version of the standard drill"
	id = "mech_diamond_drill"
	build_type = MECHFAB
	req_tech = list("materials" = 4, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	category = "Exosuit Equipment"

datum/design/mech_generator_nuclear
	name = "Exosuit Module Design (ExoNuclear Reactor)"
	desc = "Compact nuclear reactor module"
	id = "mech_generator_nuclear"
	build_type = MECHFAB
	req_tech = list("powerstorage"= 3, "engineering" = 3, "materials" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/generator/nuclear
	category = "Exosuit Equipment"
