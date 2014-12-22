//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/***************************************************************
**						Design Datums						  **
**	All the data for building stuff and tracking reliability. **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials:
- $metal (/obj/item/stack/metal). One sheet = 3750 units.
- $glass (/obj/item/stack/glass). One sheet = 3750 units.
- $plasma (/obj/item/stack/plasma). One sheet = 3750 units.
- $plasteel (/obj/item/stack/sheet/plasteel). One sheet = 3750 units.
- $silver (/obj/item/stack/silver). One sheet = 3750 units.
- $gold (/obj/item/stack/gold). One sheet = 3750 units.
- $uranium (/obj/item/stack/uranium). One sheet = 3750 units.
- $diamond (/obj/item/stack/diamond). One sheet = 3750 units.
- $clown (/obj/item/stack/clown). One sheet = 3750 units. ("Bananium")
(Insert new ones here)

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidlines
- The reliability formula for all R&D built items is reliability_base (a fixed number) + total tech levels required to make it +
reliability_mod (starts at 0, gets improved through experimentation). Example: PACMAN generator. 79 base reliablity + 6 tech
(3 plasmatech, 3 powerstorage) + 0 (since it's completely new) = 85% reliability. Reliability is the chance it works CORRECTLY.
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 3750 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to


*/

/datum/design						//Datum for object designs, used in construction
	var/name = "Name"					//Name of the created object.
	var/desc = "Desc"					//Description of the created object.
	var/id = "id"						//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/list/req_tech = list()			//IDs of that techs the object originated from and the minimum level requirements.
	var/reliability_mod = 0				//Reliability modifier of the device at it's starting point.
	var/reliability_base = 100			//Base reliability of a device before modifiers.
	var/reliability = 100				//Reliability of the device.
	var/build_type = null				//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()			//List of materials. Format: "id" = amount.
	var/construction_time				//Amount of time required for building the object
	var/build_path = ""					//The file path of the object that gets created
	var/locked = 0						//If true it will spawn inside a lockbox with currently sec access
	var/category = null //Primarily used for Mech Fabricators, but can be used for anything


//A proc to calculate the reliability of a design based on tech levels and innate modifiers.
//Input: A list of /datum/tech; Output: The new reliabilty.
/datum/design/proc/CalcReliability(var/list/temp_techs)
	var/new_reliability
	for(var/datum/tech/T in temp_techs)
		if(T.id in req_tech)
			new_reliability += T.level
	new_reliability = Clamp(new_reliability, reliability, 100)
	reliability = new_reliability
	return

/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////

/datum/design/drill_diamond
	name = "Diamond Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	req_tech = list("materials" = 6, "powerstorage" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000, "$glass" = 1000, "$diamond" = 3750) //Yes, a whole diamond is needed.
	reliability_base = 79
	build_path = /obj/item/weapon/pickaxe/diamonddrill
	category = list("Mining")
	
/datum/design/pick_diamond
	name = "Diamond Pickaxe"
	desc = "A pickaxe with a diamond pick head, this is just like minecraft."
	id = "pick_diamond"
	req_tech = list("materials" = 6)
	build_type = PROTOLATHE
	materials = list("$diamond" = 3000)
	build_path = /obj/item/weapon/pickaxe/diamond
	category = list("Mining")

/datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	req_tech = list("materials" = 2, "powerstorage" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 6000, "$glass" = 1000)
	build_path = /obj/item/weapon/pickaxe/drill
	category = list("Mining")	
	
/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used for seeing walls, floors, and stuff through anything."
	id = "mesons"
	req_tech = list("materials" = 3, "magnets" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 200, "$glass" = 300, "$plasma" = 100)
	build_path = /obj/item/clothing/glasses/meson
	category = list("Mining")
	
/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	req_tech = list("materials" = 4, "plasmatech" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 1500, "$glass" = 500, "$gold" = 500, "$plasma" = 500)
	reliability_base = 79
	build_path = /obj/item/weapon/pickaxe/plasmacutter
	category = list("Mining")
	
/datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."
	id = "jackhammer"
	req_tech = list("materials" = 3, "powerstorage" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$glass" = 500, "$silver" = 500)
	build_path = /obj/item/weapon/pickaxe/jackhammer
	category = list("Mining")

/////////////////////////////////////////
/////////////////Misc Designs////////////
/////////////////////////////////////////
	
/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 30, "$glass" = 10)
	build_path = /obj/item/weapon/disk/design_disk
	category = list("Miscellaneous")
	
/datum/design/intellicard
	name = "Intellicard"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$glass" = 1000, "$gold" = 200)
	build_path = /obj/item/device/aicard
	category = list("Miscellaneous")
	
/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card"
	id = "paicard"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list("$glass" = 500, "$metal" = 500)
	build_path = /obj/item/device/paicard
	category = list("Miscellaneous")

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 30, "$glass" = 10)
	build_path = /obj/item/weapon/disk/tech_disk
	category = list("Miscellaneous")

/////////////////////////////////////////
//////////////Blue Space/////////////////
/////////////////////////////////////////

/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$diamond" = 1500, "$plasma" = 1500)
	reliability_base = 100
	build_path = /obj/item/bluespace_crystal/artificial
	category = list("Bluespace")	
	
/datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$gold" = 3000, "$diamond" = 1500, "$uranium" = 250)
	reliability_base = 80
	build_path = /obj/item/weapon/storage/backpack/holding
	category = list("Bluespace")

/datum/design/telesci_gps
	name = "GPS Device"
	desc = "A device that can track its position at all times."
	id = "telesci_Gps"
	req_tech = list("materials" = 2, "magnets" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 500, "$glass" = 1000)
	build_path = /obj/item/device/gps
	category = list("Bluespace")

/datum/design/telepad_beacon
	name = "Telepad Beacon"
	desc = "Use to warp in a cargo telepad."
	id = "telepad_beacon"
	req_tech = list("bluespace" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list ("$metal" = 2000, "$glass" = 1750, "$silver" = 500)
	build_path = /obj/item/device/telepad_beacon
	category = list("Bluespace")

/datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list ("$metal" = 20, "$glass" = 10)
	build_path = /obj/item/device/radio/beacon
	category = list("Bluespace")

/////////////////////////////////////////
/////////////////Equipment///////////////
/////////////////////////////////////////

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Equipment")
	
/datum/design/magboots
	name = "Magnetic Boots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	id = "magboots"
	req_tech = list("materials" = 4, "magnets" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 4500, "$silver" = 1500, "$gold" = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")
	
/datum/design/night_vision_goggles
	name = "Night Vision Goggles"
	desc = "Goggles that let you see through darkness unhindered."
	id = "night_visision_goggles"
	req_tech = list("magnets" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 100, "$glass" = 100, "$uranium" = 1000)
	build_path = /obj/item/clothing/glasses/night
	category = list("Equipment")

/datum/design/health_hud_night
	name = "Night Vision Health Scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	id = "health_hud_night"
	req_tech = list("biotech" = 4, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 200, "$glass" = 200, "$uranium" = 1000, "$silver" = 250)
	build_path = /obj/item/clothing/glasses/hud/health/night
	category = list("Equipment")
	
/datum/design/security_hud_night
	name = "Night Vision Security HUD"
	desc = "A heads-up display which provides id data and vision in complete darkness."
	id = "security_hud_night"
	req_tech = list("magnets" = 5, "combat" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 200, "$glass" = 200, "$uranium" = 1000, "$gold" = 350)
	build_path = /obj/item/clothing/glasses/hud/security/night
	category = list("Equipment")

/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list("Equipment")

/////////////////////////////////////////
/////////////PDA and Radio stuff/////////
/////////////////////////////////////////

/datum/design/binaryencrypt
	name = "Binary Encryption Key"
	desc = "An encyption key for a radio headset. Contains cypherkeys."
	id = "binaryencrypt"
	req_tech = list("syndicate" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 300, "$glass" = 300)
	build_path = /obj/item/device/encryptionkey/binary
	category = list("Communication")
	
/datum/design/cart_atmos
	name = "BreatheDeep Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_atmos"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/atmos
	category = list("Communication")
	
/datum/design/cart_chemistry
	name = "ChemWhiz Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_chemistry"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/chemistry
	category = list("Communication")
	
/datum/design/cart_janitor
	name = "CustodiPRO Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_janitor"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/janitor
	category = list("Communication")
	
/datum/design/cart_mime
	name = "Gestur-O 1000 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_mime"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/mime
	category = list("Communication")	
	
/datum/design/cart_basic
	name = "Generic Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_basic"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge
	category = list("Communication")	
	
/datum/design/cart_clown
	name = "Honkworks 5.0 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_clown"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/clown
	category = list("Communication")
	
/datum/design/cart_hop
	name = "Human Resources 9001 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_hop"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/hop
	locked = 1
	category = list("Communication")
	
/datum/design/cart_medical
	name = "Med-U Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_medical"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/medical
	category = list("Communication")	
	
/datum/design/cart_cmo
	name = "Med-U DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_cmo"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/cmo
	locked = 1
	category = list("Communication")
	
/datum/design/pda
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	id = "pda"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/device/pda
	category = list("Communication")
	
/datum/design/cart_engineering
	name = "Power-ON Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_engineering"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/engineering
	category = list("Communication")
	
/datum/design/cart_ce
	name = "Power-On DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_ce"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/ce
	locked = 1
	category = list("Communication")

/datum/design/cart_security
	name = "R.O.B.U.S.T. Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_security"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = "/obj/item/weapon/cartridge/security"
	locked = 1
	category = list("Communication")
	
/datum/design/cart_hos
	name = "R.O.B.U.S.T. DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_hos"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/hos
	locked = 1
	category = list("Communication")
	
/datum/design/cart_toxins
	name = "Signal Ace 2 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_toxins"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/signal/toxins
	category = list("Communication")

/datum/design/cart_rd
	name = "Signal Ace DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_rd"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/rd
	locked = 1
	category = list("Communication")
	
/datum/design/cart_quartermaster
	name = "Space Parts & Space Vendors Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_quartermaster"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/quartermaster
	locked = 1
	category = list("Communication")
	
/datum/design/cart_captain
	name = "Value-PAK Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_captain"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/cartridge/captain
	locked = 1
	category = list("Communication")

/////////////////////////////////////////
////////////Janitor Designs//////////////
/////////////////////////////////////////
	
/datum/design/advmop
	name = "Advanced Mop"
	desc = "An upgraded mop with a large internal capacity for holding water or other cleaning chemicals."
	id = "advmop"
	req_tech = list("materials" = 4, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 2500, "$glass" = 200)
	build_path = /obj/item/weapon/mop/advanced
	category = list("Janitorial")

/datum/design/holosign
	name = "Holographic Sign Projector"
	desc = "A holograpic projector used to project various warning signs."
	id = "holosign"
	req_tech = list("magnets" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$glass" = 1000)
	build_path = /obj/item/weapon/holosign_creator
	category = list("Janitorial")
	
/datum/design/light_replacer
	name = "Light Replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."
	id = "light_replacer"
	req_tech = list("magnets" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 1500, "$silver" = 150, "$glass" = 3000)
	build_path = /obj/item/device/lightreplacer
	category = list("Janitorial")