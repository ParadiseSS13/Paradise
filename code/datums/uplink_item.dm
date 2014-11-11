var/list/uplink_items = list()

/proc/get_uplink_items(var/job = null)
	// If not already initialized..
	if(!uplink_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

		var/list/last = list()
		for(var/item in typesof(/datum/uplink_item))

			var/datum/uplink_item/I = new item()
			if(!I.item)
				continue
			if(I.gamemodes.len && ticker && !(ticker.mode.name in I.gamemodes))
				continue
			if(I.excludefrom.len && ticker && (ticker.mode.name in I.excludefrom))
				continue
			if(I.last)
				last += I
				continue

			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

		for(var/datum/uplink_item/I in last)
			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

	return uplink_items

// You can change the order of the list by putting datums before/after one another OR
// you can use the last variable to make sure it appears last, well have the category appear last.

/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "Item Description"
	var/item = null
	var/cost = 0
	var/last = 0 // Appear last
	var/abstract = 0
	var/list/gamemodes = list() // Empty list means it is in all the gamemodes. Otherwise place the gamemode name here.
	var/list/excludefrom = list() //Empty list does nothing. Place the name of gamemode you don't want this item to be available in here. This is so you dont have to list EVERY mode to exclude something.
	var/list/job = null

/datum/uplink_item/proc/spawn_item(var/turf/loc, var/obj/item/device/uplink/U)
	if(item)
		U.uses -= max(cost, 0)
		U.used_TC += cost
		feedback_add_details("traitor_uplink_items_bought", name)
		return new item(loc)

/datum/uplink_item/proc/buy(var/obj/item/device/uplink/hidden/U, var/mob/user)

	..()
	if(!istype(U))
		return 0

	if (user.stat || user.restrained())
		return 0

	if (!( istype(user, /mob/living/carbon/human)))
		return 0

	// If the uplink's holder is in the user's contents
	if ((U.loc in user.contents || (in_range(U.loc, user) && istype(U.loc.loc, /turf))))
		user.set_machine(U)
		if(cost > U.uses)
			return 0

		var/obj/I = spawn_item(get_turf(user), U)

		if(ishuman(user))
			var/mob/living/carbon/human/A = user
			A.put_in_any_hand_if_possible(I)

			if(istype(I,/obj/item/weapon/storage/box/) && I.contents.len>0)
				for(var/atom/o in I)
					U.purchase_log += "<BIG>\icon[o]</BIG>"
			else
				U.purchase_log += "<BIG>\icon[I]</BIG>"

		U.interact(user)
		return 1
	return 0

/*
//
//	UPLINK ITEMS
//
*/
//Work in Progress, job specific antag tools

/datum/uplink_item/jobspecific
	category = "Job Specific Tools"

//Clown
/datum/uplink_item/jobspecific/clowngrenade
	name = "1 Banana Grenade"
	desc = "A grenade that explodes into HONK! brand banana peels that are genetically modified to be extra slippery and extrude caustic acid when stepped on"
	item = /obj/item/weapon/grenade/clown_grenade
	cost = 8
	job = list("Clown")

//Detective
/datum/uplink_item/jobspecific/evidenceforger
	name = "Evidence Forger"
	desc = "An evidence scanner that allows you forge evidence by setting the output before scanning the item."
	item = /obj/item/device/detective_scanner/forger
	cost = 6
	job = list("Detective")

/datum/uplink_item/jobspecific/conversionkit
	name = "Conversion Kit Bundle"
	desc = "A bundle that comes with a professional revolver conversion kit and 1 box of .357 ammo. The kit allows you to convert your revolver to fire lethal rounds or vice versa, modification is nearly perfect and will not result in catastrophic failure."
	item = /obj/item/weapon/storage/box/syndie_kit/conversion
	cost = 12
	job = list("Detective")

//Chef
/datum/uplink_item/jobspecific/specialsauce
	name = "Chef Excellence's Special Sauce"
	desc = "A custom made sauce made from the toxin glands of 1000 space carp, if somebody ingests enough they'll be dead in 3 minutes or less guaranteed."
	item = /obj/item/weapon/reagent_containers/food/condiment/syndisauce
	cost = 4
	job = list("Chef")

/datum/uplink_item/jobspecific/meatcleaver
	name = "Meat Cleaver"
	desc = "A mean looking meat cleaver that does damage comparable to an Energy Sword but with the added benefit of chopping your victim into hunks of meat after they've died and the chance to stun when thrown."
	item = /obj/item/weapon/butch/meatcleaver
	cost = 10
	job = list("Chef")

//Janitor

/datum/uplink_item/jobspecific/cautionsign
	name = "Proximity Mine"
	desc = "An Anti-Personnel proximity mine cleverly disguised as a wet floor caution sign that is triggered by running past it, activate it to start the 15 second timer and activate again to disarm."
	item = /obj/item/weapon/caution/proximity_sign
	cost = 4
	job = list("Janitor")

//Medical


/datum/uplink_item/jobspecific/rad_laser
	name = "Radiation Laser"
	desc = "A radiation laser concealed inside of a Health Analyser,  After a moderate delay, causes temporary collapse and radiation.  Has adjustable controls, but will not function as a regular health analyzer, only appears like one.  May not function correctly on radiation resistent humanoids!"
	item = /obj/item/device/rad_laser
	cost = 6
	job = list(
		"Chief Medical Officer",
		"Medical Doctor",
		"Geneticist",
		"Psychiatrist",
		"Chemist",
		"Paramedic",
		"Virologist",
		"Brig Physician"
	)

//Assistant

/datum/uplink_item/jobspecific/pickpocketgloves
	name = "Pickpocket's Gloves"
	desc = "A pair of sleek gloves to aid in pickpocketing, while wearing these you can see inside the pockets of any unsuspecting mark, loot the ID or pockets without them knowing, and pickpocketing puts the item directly into your hand."
	item = /obj/item/clothing/gloves/black/thief
	cost = 6
	job = list("Civilian")

/*
/datum/uplink_item/jobspecific/greytide
	name = "Greytide Implant"
	desc = "A box containing an implanter filled with a greytide implant when injected into another person makes them loyal to the greytide and your cause, unless of course they're already implanted by someone else. Loyalty ends if the implant is no longer in their system."
	item = /obj/item/weapon/storage/box/syndie_kit/greytide
	cost = 7
	job = list("Civilian") */
//Bartender

/datum/uplink_item/jobspecific/drunkbullets
	name = "Boozey Shotgun Shells"
	desc = "A box containing 6 shotgun shells that simulate the effects of extreme drunkeness on the target, more effective for each type of alcohol in the target's system."
	item = /obj/item/weapon/storage/box/syndie_kit/boolets
	cost = 6
	job = list("Bartender")

//Engineer

/datum/uplink_item/jobspecific/powergloves
	name = "Power Gloves"
	desc = "Insulated gloves that can utilize the power of the station to deliver a short arc of electricity at a target. Must be standing on a powered cable to use."
	item = /obj/item/clothing/gloves/yellow/power
	cost = 14
	job = list("Station Engineer","Chief Engineer")

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Highly Visible and Dangerous Weapons"

/datum/uplink_item/dangerous/revolver
	name = "Fully Loaded Revolver"
	desc = "A traditional handgun which fires .357 rounds. Has 7 chambers. Can down an unarmoured target with two shots."
	item = /obj/item/weapon/gun/projectile/revolver
	cost = 13

/datum/uplink_item/dangerous/pistol
	name = "Stechkin Pistol"
	desc = "A small, easily concealable handgun that uses 10mm magazines and is compatible with suppressors."
	item = /obj/item/weapon/gun/projectile/automatic/pistol
	cost = 9

/datum/uplink_item/dangerous/smg
	name = "C-20r Submachine Gun"
	desc = "A fully-loaded Scarborough Arms-developed submachine gun that fires 12mm automatic rounds with a 20-round magazine."
	item = /obj/item/weapon/gun/projectile/automatic/c20r
	cost = 14
	gamemodes = list("nuclear emergency")

/datum/uplink_item/dangerous/machinegun
	name = "L6 Squad Automatic Weapon"
	desc = "A traditionally constructed machine gun made by AA-2531. This deadly weapon has a massive 50-round magazine of 7.62×51mm ammunition."
	item = /obj/item/weapon/gun/projectile/automatic/l6_saw
	cost = 40
	gamemodes = list("nuclear emergency")

/datum/uplink_item/dangerous/crossbow
	name = "Energy Crossbow"
	desc = "A miniature energy crossbow that is small enough both to fit into a pocket and to slip into a backpack unnoticed by observers. Fires bolts tipped with toxin, a poisonous substance that is the product of a living organism. Stuns enemies for a short period of time. Recharges automatically."
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 12
	excludefrom = list("nuclear emergency")

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The esword is an edged weapon with a blade of pure energy. The sword is small enough to be pocketed when inactive. Activating it produces a loud, distinctive noise."
	item = /obj/item/weapon/melee/energy/sword
	cost = 8

/datum/uplink_item/dangerous/manhacks
	name = "Viscerator Delivery Grenade"
	desc = "A unique grenade that deploys a swarm of viscerators upon activation, which will chase down and shred any non-operatives in the area."
	item = /obj/item/weapon/grenade/spawnergrenade/manhacks
	cost = 8
	gamemodes = list("nuclear emergency")

/datum/uplink_item/dangerous/bioterror
	name = "Biohazardous Chemical Sprayer"
	desc = "A chemical sprayer that allows a wide dispersal of selected chemicals. Especially tailored by the Tiger Cooperative, the deadly blend it comes stocked with will disorient, damage, and disable your foes... \
	Use with extreme caution, to prevent exposure to yourself and your fellow operatives."
	item = /obj/item/weapon/reagent_containers/spray/chemsprayer/bioterror
	cost = 20
	gamemodes = list("nuclear emergency")

/datum/uplink_item/dangerous/emp
	name = "5 EMP Grenades"
	desc = "A box that contains 5 EMP grenades. Useful to disrupt communication and silicon lifeforms."
	item = /obj/item/weapon/storage/box/emps
	cost = 5

/datum/uplink_item/dangerous/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The Minibomb is a grenade with a five-second fuse."
	item = /obj/item/weapon/grenade/syndieminibomb
	cost = 6

/datum/uplink_item/dangerous/gygax
	name = "Gygax Exosuit"
	desc = "A lightweight exosuit, painted in a dark scheme. Its speed and equipment selection make it excellent for hit-and-run style attacks. \
	This model lacks a method of space propulsion, and therefore it is advised to repair the mothership's teleporter if you wish to make use of it."
	item = /obj/mecha/combat/gygax/dark/loaded
	cost = 90
	gamemodes = list("nuclear emergency")

/datum/uplink_item/dangerous/mauler
	name = "Mauler Exosuit"
	desc = "A massive and incredibly deadly Syndicate exosuit. Features long-range targetting, thrust vectoring, and deployable smoke."
	item = /obj/mecha/combat/marauder/mauler/loaded
	cost = 140
	gamemodes = list("nuclear emergency")

// Ammunition

/datum/uplink_item/ammo
	category = "Ammunition"

/datum/uplink_item/ammo/revolver
	name = "Ammo-357"
	desc = "A box that contains seven additional rounds for the revolver, made using an automatic lathe."
	item = /obj/item/ammo_box/a357
	cost = 4

/datum/uplink_item/ammo/pistol
	name = "Ammo-10mm"
	desc = "An additional 8-round 10mm magazine for use in the Stetchkin pistol."
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 1

/datum/uplink_item/ammo/smg
	name = "Ammo-12mm"
	desc = "A 20-round 12mm magazine for use in the C-20r submachine gun."
	item = /obj/item/ammo_box/magazine/m12mm
	cost = 2
	gamemodes = list("nuclear emergency")

/datum/uplink_item/ammo/machinegun
	name = "Ammo-7.62×51mm"
	desc = "A 50-round magazine of 7.62×51mm ammunition for use in the L6 SAW machinegun. By the time you need to use this, you'll already be on a pile of corpses."
	item = /obj/item/ammo_box/magazine/m762
	cost = 12
	gamemodes = list("nuclear emergency")

/datum/uplink_item/ammo/bullstun
	name = "Ammo-12g Stun Slug"
	desc = "An additional 8-round stun slug magazine for use in the Bulldog shotgun. Saying that they're non-lethal would be lying."
	item = /obj/item/ammo_box/magazine/m12g
	cost = 2
	gamemodes = list("nuclear emergency")

/datum/uplink_item/ammo/bullbuck
	name = "Ammo-12g Buckshot"
	desc = "An alternative 8-round buckshot magazine for use in the Bulldog shotgun. Front towards enemy."
	item = /obj/item/ammo_box/magazine/m12g/buckshot
	cost = 2
	gamemodes = list("nuclear emergency")

/datum/uplink_item/ammo/bulldragon
	name = "Ammo-12g Dragon's Breath"
	desc = "An alternative 8-round dragon's breath magazine for use in the Bulldog shotgun. I'm a fire starter, twisted fire starter!"
	item = /obj/item/ammo_box/magazine/m12g/dragon
	cost = 3
	gamemodes = list("nuclear emergency")


// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/para_pen
	name = "Paralysis Pen"
	desc = "A syringe disguised as a functional pen, filled with a neuromuscular-blocking drug that renders a target mute on injection that will eventually cause them to pass out. The pen holds one dose of paralyzing agent,though it can be refilled."
	item = /obj/item/weapon/pen/paralysis
	cost = 8
	excludefrom = list("nuclear emergency")

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. You can also drop it underfoot to slip people."
	item = /obj/item/weapon/soap/syndie
	cost = 1

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "When inserted into a personal digital assistant, this cartridge gives you five opportunities to detonate PDAs of crewmembers who have their message feature enabled. The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer. It has a chance to detonate your PDA."
	item = /obj/item/weapon/cartridge/syndicate
	cost = 6

// Commented out until a fix can be found, currently doesn't work with the PDA NanoUI and people keep wasting Telecrystals on it. -- Dave

/datum/uplink_item/stealthy_weapons/silencer
	name = "Stetchkin Silencer"
	desc = "Fitted for use on the Stetchkin pistol, this silencer will make its shots quieter when equipped onto it."
	item = /obj/item/weapon/silencer
	cost = 3

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	desc = "A jumpsuit used to imitate the uniforms of Nanotrasen crewmembers."
	item = /obj/item/clothing/under/chameleon
	cost = 4

/datum/uplink_item/stealthy_tools/chameleon_stamp
	name = "Chameleon Stamp"
	desc = "A stamp that can be activated to imitate an official Nanotrasen Stamp™. The disguised stamp will work exactly like the real stamp and will allow you to forge false documents to gain access or equipment; \
	it can also be used in a washing machine to forge clothing."
	item = /obj/item/weapon/stamp/chameleon
	cost = 1

/datum/uplink_item/stealthy_tools/syndigolashes
	name = "No-Slip Syndicate Shoes"
	desc = "These allow you to run on wet floors. They do not work on lubricated surfaces."
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 4

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent ID Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and can copy access from other identification cards. The access is cumulative, so scanning one card does not erase the access gained from another."
	item = /obj/item/weapon/card/id/syndicate
	cost = 3

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	desc = "A conspicuous gas mask that mimics the voice named on your identification card. When no identification is worn, the mask will render your voice unrecognizable."
	item = /obj/item/clothing/mask/gas/voice
	cost = 5

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't move the projector from their hand. The disguised user cannot run and rojectiles pass over them."
	item = /obj/item/device/chameleon
	cost = 7

/datum/uplink_item/stealthy_tools/dnascrambler
	name = "DNA Scrambler"
	desc = "A syringe with one injection that randomizes appearance and name upon use. A cheaper but less versatile alternative to an agent card and voice changer."
	item = /obj/item/weapon/dnascrambler
	cost = 4

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "This satchel is thin enough to be hidden in the gap between plating and tiling, great for stashing your stolen goods. Comes with a crowbar and a floor tile inside."
	item = /obj/item/weapon/storage/backpack/satchel_flat
	cost = 2

// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"
	abstract = 1

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The emag is a small card that unlocks hidden functions in electronic devices, subverts intended functions and characteristically breaks security mechanisms."
	item = /obj/item/weapon/card/emag
	cost = 6

/datum/uplink_item/device_tools/toolbox
	name = "Fully Loaded Toolbox"
	desc = "The syndicate toolbox is a suspicious black and red. Aside from tools, it comes with cable and a multitool. Insulated gloves are not included."
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1


/datum/uplink_item/device_tools/medkit
	name = "Syndicate Medical Supply Kit"
	desc = "The syndicate medkit is a suspicious black and red. Included is a combat stimulant injector for rapid healing, a medical hud for quick identification of injured comrades, \
	and other medical supplies helpful for a medical field operative."
	item = /obj/item/weapon/storage/firstaid/tactical
	cost = 9
	gamemodes = list("nuclear emergency")

/datum/uplink_item/device_tools/space_suit
	name = "Space Suit"
	desc = "The red and black syndicate space suit is less encumbering than Nanotrasen variants, fits inside bags, and has a weapon slot. Nanotrasen crewmembers are trained to report red space suit sightings."
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 5

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "These glasses are thermals disguised as engineers' optical meson scanners. They allow you to see organisms through walls by capturing the upper portion of the infrared light spectrum, emitted as heat and light by objects. Hotter objects, such as warm bodies, cybernetic organisms and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 6

/datum/uplink_item/device_tools/surveillance
	name = "Camera Surveillance Kit"
	desc = "This kit contains 5 Camera bugs and one mobile receiver. Attach camera bugs to a camera to enable remote viewing."
	item = /obj/item/weapon/storage/box/syndie_kit/surveillance
	cost = 5

/datum/uplink_item/device_tools/camerabugs
	name = "Camera Bugs"
	desc = "This is a Camera bug resupply giving you 5 more camera bugs."
	item = /obj/item/weapon/storage/box/surveillance
	cost = 4

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to and talk with artificial intelligences and cybernetic organisms in binary."
	item = /obj/item/device/encryptionkey/binary
	cost = 5

/datum/uplink_item/device_tools/cipherkey
	name = "Centcomm Encryption Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to and talk on all known radio channels."
	item = /obj/item/device/encryptionkey/syndicate/hacked
	cost = 4

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. Be careful with their wording, as artificial intelligences may look for loopholes to exploit."
	item = /obj/item/weapon/aiModule/syndicate
	cost = 14

/datum/uplink_item/device_tools/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls or connect a signaler to its wiring to make it remotely detonable. It has a modifiable timer with a minimum setting of 10 seconds."
	item = /obj/item/weapon/plastique
	cost = 1

/datum/uplink_item/device_tools/powersink
	name = "Power sink"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device places excessive load on the grid, causing a stationwide blackout. The sink cannot be carried because of its excessive size. Ordering this sends you a small beacon that will teleport the power sink to your location on activation."
	item = /obj/item/device/powersink
	cost = 10

/datum/uplink_item/device_tools/singularity_beacon
	name = "Singularity Beacon"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device pulls the singularity towards it. Does not work when the singularity is still in containment. A singularity beacon can cause catastrophic damage to a space station, leading to an emergency evacuation. Because of its size, it cannot be carried. Ordering this sends you a small beacon that will teleport the larger beacon to your location on activation."
	item = /obj/item/device/radio/beacon/syndicate
	cost = 14

/datum/uplink_item/device_tools/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "The Syndicate Bomb has an adjustable timer with a minimum setting of 60 seconds. Ordering the bomb sends you a small beacon, which will teleport the explosive to your location when you activate it. \
	You can wrench the bomb down to prevent removal. The crew may attempt to defuse the bomb."
	item = /obj/item/device/radio/beacon/syndicate/bomb
	cost = 11

/datum/uplink_item/device_tools/syndicate_detonator
	name = "Syndicate Detonator"
	desc = "The Syndicate Detonator is a companion device to the Syndicate Bomb. Simply press the included button and an encrypted radio frequency will instruct all live syndicate bombs to detonate. \
	Useful for when speed matters or you wish to synchronize multiple bomb blasts. Be sure to stand clear of the blast radius before using the detonator."
	item = /obj/item/device/syndicatedetonator
	cost = 3
	gamemodes = list("nuclear emergency")

/datum/uplink_item/device_tools/pdapinpointer
	name = "PDA Pinpointer"
	desc = "A pinpointer that tracks any PDA on the station. Useful for locating assassination targets or other high-value targets that you can't find. WARNING: Can only set once."
	item = /obj/item/weapon/pinpointer/pdapinpointer
	cost = 4

/datum/uplink_item/device_tools/ai_detector
	name = "Artificial Intelligence Detector" // changed name in case newfriends thought it detected disguised ai's
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it or its holder. Knowing when an artificial intelligence is watching you is useful for knowing when to maintain cover."
	item = /obj/item/device/multitool/ai_detect
	cost = 1

/datum/uplink_item/device_tools/teleporter
	name = "Teleporter Circuit Board"
	desc = "A printed circuit board that completes the teleporter onboard the mothership. Advise you test fire the teleporter before entering it, as malfunctions can occur."
	item = /obj/item/weapon/circuitboard/teleporter
	cost = 40
	gamemodes = list("nuclear emergency")

/datum/uplink_item/device_tools/shield
	name = "Energy Shield"
	desc = "An incredibly useful personal shield projector, capable of reflecting energy projectiles and defending against other attacks."
	item = /obj/item/weapon/shield/energy
	cost = 16
	gamemodes = list("nuclear emergency")

// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant injected into the body and later activated using a bodily gesture to attempt to slip restraints."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 5

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to open an uplink with 5 telecrystals. The ability for an agent to open an uplink after their posessions have been stripped from them makes this implant excellent for escaping confinement."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 20

/datum/uplink_item/implants/explosive
	name = "Explosive Implant"
	desc = "An implant injected into the body, and later activated using a vocal command to cause a large explosion from the implant."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_explosive
	cost = 12

/datum/uplink_item/implants/compression
	name = "Compressed Matter Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to retrieve an item that was earlier compressed."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_compress
	cost = 8

/datum/uplink_item/implants/mindslave
	name = "Mindslave Implant"
	desc = "A box containing an implanter filled with a mindslave implant that when injected into another person makes them loyal to you and your cause, unless of course they're already implanted by someone else. Loyalty ends if the implant is no longer in their system."
	item = /obj/item/weapon/storage/box/syndie_kit/mindslave
	cost = 10

/datum/uplink_item/implants/adrenal
	name = "Adrenal Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to inject a chemical cocktail, which has a mild healing effect along with removing all stuns and increasing his speed."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_adrenal
	cost = 8

// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "Syndicate Bundles are specialised groups of items that arrive in a plain box. These items are collectively worth more than 10 telecrystals, but you do not know which specialisation you will receive."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 20
	excludefrom = list("nuclear emergency")

/datum/uplink_item/badass/syndiecards
	name = "Syndicate Playing Cards"
	desc = "A special deck of space-grade playing cards with a mono-molecular edge and metal reinforcement, making them lethal weapons both when wielded as a blade and when thrown. \
	You can also play card games with them."
	item = /obj/item/toy/cards/deck/syndicate
	cost = 1
	excludefrom = list("nuclear emergency")

/datum/uplink_item/badass/balloon
	name = "For showing that you are The Boss"
	desc = "A useless red balloon with the syndicate logo on it, which can blow the deepest of covers."
	item = /obj/item/toy/syndicateballoon
	cost = 20

/datum/uplink_item/badass/random
	name = "Random Item"
	desc = "Picking this choice will send you a random item from the list. Useful for when you cannot think of a strategy to finish your objectives with."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 0

/datum/uplink_item/badass/random/spawn_item(var/turf/loc, var/obj/item/device/uplink/U)

	var/list/buyable_items = get_uplink_items()
	var/list/possible_items = list()

	for(var/category in buyable_items)
		for(var/datum/uplink_item/I in buyable_items[category])
			if(I == src)
				continue
			if(I.cost > U.uses)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		U.uses -= max(0, I.cost)
		feedback_add_details("traitor_uplink_items_bought","RN")
		return new I.item(loc)
