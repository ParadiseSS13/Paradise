// NUCLEAR AGENT ONLY GEAR

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous/aps
	name = "Stechkin APS Pistol"
	reference = "APS"
	desc = "The automatic machine pistol version of the FK-69 'Stechkin' chambered in 10mm Auto with a detachable 20-round box magazine. Perfect for dual wielding or as backup."
	item = /obj/item/gun/projectile/automatic/pistol/APS
	cost = 40
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/smg
	name = "C-20r Submachine Gun"
	reference = "SMG"
	desc = "A fully-loaded Scarborough Arms bullpup submachine gun that fires .45 rounds with a 20-round magazine and is compatible with suppressors."
	item = /obj/item/gun/projectile/automatic/c20r
	cost = 70
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40

/datum/uplink_item/dangerous/carbine
	name = "M-90gl Carbine"
	desc = "A fully-loaded three-round burst carbine that uses 30-round 5.56mm magazines with a togglable underslung 40mm grenade launcher."
	reference = "AR"
	item = /obj/item/gun/projectile/automatic/m90
	cost = 90
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 50

/datum/uplink_item/dangerous/machinegun
	name = "L6 Squad Automatic Weapon"
	desc = "A fully-loaded Aussec Armory belt-fed machine gun. This deadly weapon has a massive 50-round magazine of devastating 7.62x51mm ammunition."
	reference = "LMG"
	item = /obj/item/gun/projectile/automatic/l6_saw
	cost = 200
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/dangerous/sniper
	name = "Sniper Rifle"
	desc = "Ranged fury, Syndicate style. guaranteed to cause shock and awe or your TC back!"
	reference = "SSR"
	item = /obj/item/gun/projectile/automatic/sniper_rifle/syndicate
	cost = 80
	surplus = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/rocket_launcher
	name = "Rocket Launcher"
	desc = "Not many things can survive a direct hit from this. (Ammunition sold separately, keep away from children.)"
	reference = "RL"
	item = /obj/item/gun/rocketlauncher
	cost = 40
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/flamethrower
	name = "Flamethrower"
	desc = "A flamethrower, fuelled by a portion of highly flammable bio-toxins stolen previously from Nanotrasen stations. Make a statement by roasting the filth in their own greed. Use with caution."
	reference = "FT"
	item = /obj/item/flamethrower/full/tank
	cost = 3
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 40

/datum/uplink_item/dangerous/combat_defib
	name = "Combat Defibrillator Module"
	desc = "A lifesaving device turned dangerous weapon. Click on someone with the paddles on harm intent to instantly stop their heart. Can be used as a regular defib as well. Installs in a modsuit."
	reference = "CD"
	item = /obj/item/mod/module/defibrillator/combat
	cost = 60
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/dangerous/foamsmg
	name = "Toy Submachine Gun"
	desc = "A fully-loaded Donksoft bullpup submachine gun that fires riot grade rounds with a 20-round magazine."
	reference = "FSMG"
	item = /obj/item/gun/projectile/automatic/c20r/toy
	cost = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/dangerous/foammachinegun
	name = "Toy Machine Gun"
	desc = "A fully-loaded Donksoft belt-fed machine gun. This weapon has a massive 50-round magazine of devastating riot grade darts, that can briefly incapacitate someone in just one volley."
	reference = "FLMG"
	item = /obj/item/gun/projectile/automatic/l6_saw/toy
	cost = 50
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

// SUPPORT AND MECHAS

/datum/uplink_item/support
	category = "Support and Mechanized Exosuits"
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/support/gygax
	name = "Gygax Exosuit"
	desc = "A lightweight exosuit, painted in a dark scheme. Its speed and equipment selection make it excellent for hit-and-run style attacks. \
	This model lacks a method of space propulsion, and therefore it is advised to repair the mothership's teleporter if you wish to make use of it."
	reference = "GE"
	item = /obj/mecha/combat/gygax/dark/loaded
	cost = 400

/datum/uplink_item/support/mauler
	name = "Mauler Exosuit"
	desc = "A massive and incredibly deadly Syndicate exosuit. Features long-range targeting, thrust vectoring, and deployable smoke."
	reference = "ME"
	item = /obj/mecha/combat/marauder/mauler/loaded
	cost = 599 // Today only 599 TC! Get yours today!

/datum/uplink_item/support/reinforcement
	name = "Reinforcement"
	desc = "Call in an additional team member. They won't come with any gear, so you'll have to save some telecrystals \
			to arm them as well."
	reference = "REINF"
	item = /obj/item/antag_spawner/nuke_ops
	refund_path = /obj/item/antag_spawner/nuke_ops
	cost = 100
	refundable = TRUE
	cant_discount = TRUE

/datum/uplink_item/support/reinforcement/assault_borg
	name = "Syndicate Assault Cyborg"
	desc = "A cyborg designed and programmed for systematic extermination of non-Syndicate personnel. \
			Comes equipped with a self-resupplying LMG, a grenade launcher, energy sword, emag, pinpointer, flash and crowbar."
	reference = "SAC"
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	cost = 250

/datum/uplink_item/support/reinforcement/medical_borg
	name = "Syndicate Medical Cyborg"
	desc = "A combat medical cyborg. Has limited offensive potential, but makes more than up for it with its support capabilities. \
			It comes equipped with a nanite hypospray, a medical beamgun, combat defibrillator, full surgical kit including an energy saw, an emag, pinpointer and flash. \
			Thanks to its organ storage bag, it can perform surgery as well as any humanoid."
	reference = "SMC"
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	cost = 175

/datum/uplink_item/support/reinforcement/saboteur_borg
	name = "Syndicate Saboteur Cyborg"
	desc = "A streamlined engineering cyborg, equipped with covert modules and engineering equipment. Also incapable of leaving the welder in the shuttle. \
			Its chameleon projector lets it disguise itself as a Nanotrasen cyborg, on top it has thermal vision and a pinpointer."
	reference = "SSC"
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	refund_path = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	cost = 125

// AMMUNITION

/datum/uplink_item/ammo/aps
	name = "Stechkin APS - 10mm Magazine"
	desc = "An additional 20-round 10mm magazine for use in the Stechkin APS machine pistol, loaded with rounds that are cheap but around half as effective as .357"
	reference = "10MMAPS"
	item = /obj/item/ammo_box/magazine/apsm10mm
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/apsap
	name = "Stechkin APS - 10mm Armour Piercing Magazine"
	desc = "An additional 20-round 10mm magazine for use in the Stechkin APS machine pistol, loaded with rounds that are less effective at injuring the target but penetrate protective gear."
	reference = "10MMAPSAP"
	item = /obj/item/ammo_box/magazine/apsm10mm/ap
	cost = 15
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/apsfire
	name = "Stechkin APS - 10mm Incendiary Magazine"
	desc = "An additional 20-round 10mm magazine for use in the Stechkin APS machine pistol, loaded with incendiary rounds which ignite the target."
	reference = "10MMAPSFIRE"
	item = /obj/item/ammo_box/magazine/apsm10mm/fire
	cost = 15
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/apshp
	name = "Stechkin APS - 10mm Hollow Point Magazine"
	desc = "An additional 20-round 10mm magazine for use in the Stechkin APS machine pistol, loaded with rounds which are more damaging but ineffective against armour."
	reference = "10MMAPSHP"
	item = /obj/item/ammo_box/magazine/apsm10mm/hp
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bullslug
	name = "Bulldog - 12g Slug Magazine"
	desc = "An additional 8-round slug magazine for use in the Bulldog shotgun. Now 8 times less likely to shoot your pals."
	reference = "12BSG"
	item = /obj/item/ammo_box/magazine/m12g
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bullbuck
	name = "Bulldog - 12g Buckshot Magazine"
	desc = "An additional 8-round buckshot magazine for use in the Bulldog shotgun. Front towards enemy."
	reference = "12BS"
	item = /obj/item/ammo_box/magazine/m12g/buckshot
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bullmeteor
	name = "12g Meteorslug Shells"
	desc = "An alternative 8-round meteorslug magazine for use in the Bulldog shotgun. Great for blasting airlocks off their frames and knocking down enemies."
	reference = "12MS"
	item = /obj/item/ammo_box/magazine/m12g/meteor
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldragon
	name = "Bulldog - 12g Dragon's Breath Magazine"
	desc = "An alternative 8-round dragon's breath magazine for use in the Bulldog shotgun. I'm a fire starter, twisted fire starter!"
	reference = "12DB"
	item = /obj/item/ammo_box/magazine/m12g/dragon
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldog_ammobag
	name = "Bulldog - 12g Ammo Duffel Bag"
	desc = "A duffel bag filled with enough 12g ammo to supply an entire team, at a discounted price."
	reference = "12ADB"
	item = /obj/item/storage/backpack/duffel/syndie/shotgun
	cost = 60 // normally 90
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/bulldog_XLmagsbag
	name = "Bulldog - 12g XL Magazine Duffel Bag"
	desc = "A duffel bag containing three 16 round drum magazines(Slug, Buckshot, Dragon's Breath)."
	reference = "12XLDB"
	item = /obj/item/storage/backpack/duffel/syndie/shotgunXLmags
	cost = 60 // normally 90
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/smg
	name = "C-20r - .45 Magazine"
	desc = "An additional 20-round .45 magazine for use in the C-20r submachine gun. These bullets pack a lot of punch that can knock most targets down, but do limited overall damage."
	reference = "45"
	item = /obj/item/ammo_box/magazine/smgm45
	cost = 15
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/smg_ammobag
	name = "C-20r - .45 Ammo Duffel Bag"
	desc = "A duffel bag filled with enough .45 ammo to supply an entire team, at a discounted price."
	reference = "45ADB"
	item = /obj/item/storage/backpack/duffel/syndie/smg
	cost = 105 // Normally 150, so 30% off
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/carbine
	name = "Carbine - 5.56 Toploader Magazine"
	desc = "An additional 30-round 5.56 magazine for use in the M-90gl carbine. These bullets don't have the punch to knock most targets down, but dish out higher overall damage."
	reference = "556"
	item = /obj/item/ammo_box/magazine/m556
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/a40mm
	name = "Carbine - 40mm Grenade Ammo Box"
	desc = "A box of 4 additional 40mm HE grenades for use the C-90gl's underbarrel grenade launcher. Your teammates will thank you to not shoot these down small hallways."
	reference = "40MM"
	item = /obj/item/ammo_box/a40mm
	cost = 20
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/rocket
	name = "Rocket Launcher Shell"
	desc = "An extra shell for your RPG. Make sure your bestie isn't standing in front of you."
	reference = "HE"
	item = /obj/item/ammo_casing/rocket
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/machinegun
	name = "L6 SAW - 5.56x45mm Box Magazine"
	desc = "A 50-round magazine of 5.56x45mm ammunition for use in the L6 SAW machine gun. By the time you need to use this, you'll already be on a pile of corpses."
	reference = "762"
	item = /obj/item/ammo_box/magazine/mm556x45
	cost = 60
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/ammo/sniper
	cost = 15
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/sniper/basic
	name = "Sniper - .50 Magazine"
	desc = "An additional standard 6-round magazine for use with .50 sniper rifles."
	reference = "50M"
	item = /obj/item/ammo_box/magazine/sniper_rounds

/datum/uplink_item/ammo/sniper/antimatter
	name = "Sniper - .50 Antimatter Magazine"
	desc = "A 6-round magazine of antimatter ammo for use with .50 sniper rifles. \
	Able to heavily damage objects, and delimb people. Requires zooming in for accurate aiming."
	reference = "50A"
	item = /obj/item/ammo_box/magazine/sniper_rounds/antimatter
	cost = 30

/datum/uplink_item/ammo/sniper/soporific
	name = "Sniper - .50 Soporific Magazine"
	desc = "A 3-round magazine of soporific ammo designed for use with .50 sniper rifles. Put your enemies to sleep today!"
	reference = "50S"
	item = /obj/item/ammo_box/magazine/sniper_rounds/soporific

/datum/uplink_item/ammo/sniper/haemorrhage
	name = "Sniper - .50 Haemorrhage Magazine"
	desc = "A 5-round magazine of haemorrhage ammo designed for use with .50 sniper rifles; causes heavy bleeding \
			in the target."
	reference = "50B"
	item = /obj/item/ammo_box/magazine/sniper_rounds/haemorrhage

/datum/uplink_item/ammo/sniper/penetrator
	name = "Sniper - .50 Penetrator Magazine"
	desc = "A 5-round magazine of penetrator ammo designed for use with .50 sniper rifles. \
			Can pierce walls and multiple enemies."
	reference = "50P"
	item = /obj/item/ammo_box/magazine/sniper_rounds/penetrator
	cost = 20

/datum/uplink_item/ammo/bioterror
	name = "Box of Bioterror Syringes"
	desc = "A box full of preloaded syringes, containing various chemicals that seize up the victim's motor and broca system , making it impossible for them to move or speak while in their system."
	reference = "BTS"
	item = /obj/item/storage/box/syndie_kit/bioterror
	cost = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/ammo/toydarts
	name = "Box of Riot Darts"
	desc = "A box of 40 Donksoft foam riot darts, for reloading any compatible foam dart gun. Don't forget to share!"
	reference = "FOAM"
	item = /obj/item/ammo_box/foambox/riot
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

// STEALTHY WEAPONS

// EXPLOSIVES

/datum/uplink_item/explosives/c4bag
	name = "Bag of C-4 explosives"
	desc = "Because sometimes quantity is quality. Contains 10 C-4 plastic explosives."
	reference = "C4B"
	item = /obj/item/storage/backpack/duffel/syndie/c4
	cost = 40 //20% discount!
	cant_discount = TRUE
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/breaching_charge
	name = "Composition X-4"
	desc = "X-4 is a shaped charge designed to be safe to the user while causing maximum damage to the occupants of the room beach breached. It has a modifiable timer with a minimum setting of 10 seconds."
	reference = "X4"
	item = /obj/item/grenade/plastic/c4/x4
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/x4bag
	name = "Bag of X-4 explosives"
	desc = "Contains 3 X-4 shaped plastic explosives. Similar to C4, but with a stronger blast that is directional instead of circular. \
			X-4 can be placed on a solid surface, such as a wall or window, and it will blast through the wall, injuring anything on the opposite side, while being safer to the user. \
			For when you want a controlled explosion that leaves a wider, deeper, hole."
	reference = "X4B"
	item = /obj/item/storage/backpack/duffel/syndie/x4
	cost = 20
	cant_discount = TRUE
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/grenadier
	name = "Grenadier's belt"
	desc = "A belt containing 26 lethally dangerous and destructive grenades."
	reference = "GRB"
	item = /obj/item/storage/belt/grenade/full
	cost = 120
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/explosives/manhacks
	name = "Viscerator Delivery Grenade"
	desc = "A unique grenade that deploys a swarm of viscerators upon activation, which will chase down and shred any non-operatives in the area."
	reference = "VDG"
	item = /obj/item/grenade/spawnergrenade/manhacks
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 35

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools/clownkit
	name = "Honk Brand Infiltration Kit"
	desc = "All the tools you need to play the best prank Nanotrasen has ever seen. Includes a voice changer mask, magnetic clown shoes, and standard clown outfit, tools, and backpack."
	reference = "HBIK"
	item = /obj/item/storage/backpack/clown/syndie
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

// DEVICES AND TOOLS

/datum/uplink_item/device_tools/diamond_drill
	name = "Amplifying Diamond Tipped Thermal Safe Drill"
	desc = "A diamond tipped thermal drill with magnetic clamps for the purpose of quickly drilling hardened objects. Comes with built in security detection and nanite system, to keep you up if security comes a-knocking."
	reference = "DDRL"
	item = /obj/item/thermal_drill/diamond_drill/syndicate
	cost = 5
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/medkit
	name = "Syndicate Combat Medic Kit"
	desc = "The syndicate medkit is a suspicious black and red. Included is a combat stimulant injector for rapid healing, a medical HUD for quick identification of injured comrades, \
	and other medical supplies helpful for a medical field operative."
	reference = "SCMK"
	item = /obj/item/storage/firstaid/tactical
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/vtec
	name = "Syndicate Cyborg Upgrade Module (VTEC)"
	desc = "Increases the movement speed of a Cyborg. Install into any Borg, Syndicate or subverted"
	reference = "VTEC"
	item = /obj/item/borg/upgrade/vtec
	cost = 30
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/magboots
	name = "Blood-Red Magboots"
	desc = "A pair of magnetic boots with a Syndicate paintjob that assist with freer movement in space or on-station during gravitational generator failures. \
	These reverse-engineered knockoffs of Nanotrasen's 'Advanced Magboots' slow you down in simulated-gravity environments much like the standard issue variety."
	reference = "BRMB"
	item = /obj/item/clothing/shoes/magboots/syndie
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/syndicate_detonator
	name = "Syndicate Detonator"
	desc = "The Syndicate Detonator is a companion device to the Syndicate Bomb. Simply press the included button and an encrypted radio frequency will instruct all live syndicate bombs to detonate. \
	Useful for when speed matters or you wish to synchronize multiple bomb blasts. Be sure to stand clear of the blast radius before using the detonator."
	reference = "SD"
	item = /obj/item/syndicatedetonator
	cost = 5
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/teleporter
	name = "Teleporter Circuit Board"
	desc = "A printed circuit board that completes the teleporter onboard the mothership. Advise you test fire the teleporter before entering it, as malfunctions can occur."
	item = /obj/item/circuitboard/teleporter
	reference = "TP"
	cost = 100
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/device_tools/assault_pod
	name = "Assault Pod Targetting Device"
	desc = "Use to select the landing zone of your assault pod."
	item = /obj/item/assault_pod
	reference = "APT"
	cost = 125
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 0

/datum/uplink_item/device_tools/shield
	name = "Energy Shield"
	desc = "An incredibly useful personal shield projector, capable of reflecting energy projectiles, but it cannot block other attacks. Pair with an Energy Sword for a killer combination."
	item = /obj/item/shield/energy
	reference = "ESD"
	cost = 40
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	surplus = 20

/datum/uplink_item/device_tools/dropwall
	name = "Dropwall generator box"
	desc = "A box of 5 dropwall shield generators, which can be used to make temporary directional shields that block projectiles, thrown objects, and reduce explosions. Configure the direction before throwing."
	item = /obj/item/storage/box/syndie_kit/dropwall
	reference = "DWG"
	cost = 50
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/device_tools/medgun
	name = "Medbeam Gun"
	desc = "Medical Beam Gun, useful in prolonged firefights. DO NOT CROSS THE BEAMS. Crossing beams with another medbeam or attaching two beams to one target will have explosive consequences."
	item = /obj/item/gun/medbeam
	reference = "MBG"
	cost = 75
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

// SPACE SUITS

/datum/uplink_item/suits/hardsuit/elite
	name = "Elite Syndicate MODsuit"
	desc = "An advanced MODsuit with superior armor and mobility to the standard Syndicate MODsuit."
	item = /obj/item/mod/control/pre_equipped/elite
	cost = 40
	reference = "ESHS"
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/suits/hardsuit/shielded
	name = "Shielded Hardsuit"
	desc = "An advanced hardsuit with built in energy shielding. The shields will rapidly recharge when not under fire."
	item = /obj/item/clothing/suit/space/hardsuit/shielded/syndi
	cost = 150
	reference = "SHS"
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

// IMPLANTS

/datum/uplink_item/implants/krav_implant
	name = "Krav Maga Implant"
	desc = "A biochip that teaches you Krav Maga when implanted, great as a cheap backup weapon. Warning: the biochip will override any other fighting styles such as CQC while active."
	reference = "KMI"
	item = /obj/item/implanter/krav_maga
	cost = 25
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/implants/uplink/nuclear
	name = "Nuclear Uplink Bio-chip"
	reference = "UIN"
	item = /obj/item/implanter/nuclear
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/implants/microbomb
	name = "Microbomb Bio-chip"
	desc = "A bio-chip injected into the body, and later activated either manually or automatically upon death. The more implants inside of you, the higher the explosive power. \
	This will permanently destroy your body, however."
	reference = "MBI"
	item = /obj/item/implanter/explosive
	cost = 10
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/implants/macrobomb
	name = "Macrobomb Bio-chip"
	desc = "A bio-chip injected into the body, and later activated either manually or automatically upon death. Upon death, releases a massive explosion that will wipe out everything nearby."
	reference = "HAB"
	item = /obj/item/implanter/explosive_macro
	cost = 50
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)


// CYBERNETICS

/datum/uplink_item/cyber_implants
	category = "Cybernetic Implants"
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/cyber_implants/thermals
	name = "Thermal Vision Implant"
	desc = "These cybernetic eyes will give you thermal vision. Comes with an autosurgeon."
	reference = "CIT"
	item = /obj/item/autosurgeon/organ/syndicate/thermal_eyes
	cost = 40

/datum/uplink_item/cyber_implants/xray
	name = "X-Ray Vision Implant"
	desc = "These cybernetic eyes will give you X-ray vision. Comes with an autosurgeon."
	reference = "CIX"
	item = /obj/item/autosurgeon/organ/syndicate/xray_eyes
	cost = 50

/datum/uplink_item/cyber_implants/antistun
	name = "Hardened CNS Rebooter Implant"
	desc = "This implant will help you get back up on your feet faster after being fatigued. It is immune to EMP attacks. Comes with an autosurgeon."
	reference = "CIAS"
	item = /obj/item/autosurgeon/organ/syndicate/anti_stam
	cost = 60

/datum/uplink_item/cyber_implants/reviver
	name = "Hardened Reviver Implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. It is immune to EMP attacks. Comes with an autosurgeon."
	reference = "CIR"
	item = /obj/item/autosurgeon/organ/syndicate/reviver
	cost = 40

// BUNDLES

/datum/uplink_item/bundles_TC/bulldog
	name = "Bulldog Bundle"
	desc = "Lean and mean: Optimized for people that want to get up close and personal. Contains the popular \
			Bulldog shotgun, two 12g buckshot drums, and a pair of Thermal imaging goggles."
	reference = "BULB"
	item = /obj/item/storage/backpack/duffel/syndie/bulldogbundle
	cost = 45 // normally 60
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/c20r
	name = "C-20r Bundle"
	desc = "Old Faithful: The classic C-20r, bundled with three magazines and a (surplus) suppressor at discount price."
	reference = "C20B"
	item = /obj/item/storage/backpack/duffel/syndie/c20rbundle
	cost = 90 // normally 105
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/cyber_implants
	name = "Cybernetic Implants Bundle"
	desc = "A random selection of cybernetic implants. Guaranteed 5 high quality implants. Comes with an autosurgeon."
	reference = "CIB"
	item = /obj/item/storage/box/cyber_implants
	cost = 200
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/medical
	name = "Medical Bundle"
	desc = "The support specialist: Aid your fellow operatives with this medical bundle. Contains a tactical medkit, \
			a medical beam gun and a pair of syndicate magboots."
	reference = "MEDB"
	item = /obj/item/storage/backpack/duffel/syndie/med/medicalbundle
	cost = 80 // normally 105
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

/datum/uplink_item/bundles_TC/sniper
	name = "Sniper bundle"
	desc = "Elegant and refined: Contains a collapsed sniper rifle in an expensive carrying case, \
			two soporific knockout magazines, a free surplus suppressor, and a sharp-looking tactical turtleneck suit. \
			We'll throw in a free red tie if you order NOW."
	reference = "SNPB"
	item = /obj/item/storage/briefcase/sniperbundle
	cost = 90 // normally 115
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)


// ---------------------------------
// PRICES OVERRIDE FOR TRAITOR ITEMS
// ---------------------------------

/datum/uplink_item/stealthy_weapons/cqc/nuke
	reference = "NCQC"
	cost = 40
	excludefrom = list(UPLINK_TYPE_TRAITOR, UPLINK_TYPE_SIT)

/datum/uplink_item/explosives/syndicate_bomb/nuke
	reference = "NSB"
	cost = 55
	excludefrom = list(UPLINK_TYPE_TRAITOR, UPLINK_TYPE_SIT)
	surplus = 0
	cant_discount = TRUE
	hijack_only = FALSE

/datum/uplink_item/explosives/emp_bomb/nuke
	reference = "NSBEMP"
	cost = 50
	excludefrom = list(UPLINK_TYPE_TRAITOR, UPLINK_TYPE_SIT)
	surplus = 0
	cant_discount = TRUE

/datum/uplink_item/explosives/atmosfiregrenades/nuke
	reference = "NAPG"
	hijack_only = FALSE
	cost = 60
	excludefrom = list(UPLINK_TYPE_TRAITOR, UPLINK_TYPE_SIT)
	surplus = 0
	cant_discount = TRUE

/datum/uplink_item/stealthy_tools/chameleon/nuke
	reference = "NCHAM"
	cost = 30
	excludefrom = list(UPLINK_TYPE_TRAITOR, UPLINK_TYPE_SIT)

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	reference = "NNSSS"
	cost = 20
	excludefrom = list(UPLINK_TYPE_TRAITOR, UPLINK_TYPE_SIT)

/datum/uplink_item/explosives/detomatix/nuclear
	desc = "When inserted into a personal digital assistant, this cartridge gives you five opportunities to detonate PDAs of crewmembers who have their message feature enabled. The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer. It has a chance to detonate your PDA. This version comes with a program to toggle your nuclear shuttle blast doors remotely."
	item = /obj/item/cartridge/syndicate/nuclear
	reference = "DEPCN"
	excludefrom = list()
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)

// ---------------------------------
// NUKIE ONLY POINTLESS BADASSERY
// ---------------------------------

/datum/uplink_item/badass/confettidrum
	name = "Bulldog - 12g party Magazine"
	desc = "An alternative 12-round confetti magazine for use in the Bulldog shotgun. Why? Because we can - Honkco Industries"
	item = /obj/item/ammo_box/magazine/m12g/confetti
	reference = "12CS"
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	cost = 5

/datum/uplink_item/badass/confetti_party_pack
	name = "Nuclear party pack"
	desc = "A dufflebag filled with hilarious equipment! Comes with free confetti grenades and a cap gun!"
	item = /obj/item/storage/backpack/duffel/syndie/party
	reference = "SPP"
	uplinktypes = list(UPLINK_TYPE_NUCLEAR, UPLINK_TYPE_SST)
	cost = 50
