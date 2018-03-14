//If you're looking for spawners like ash walker eggs, check ghost_role_spawners.dm

var/list/barometers = list()

/obj/machinery/lavaland_controller
	name = "weather control machine"
	desc = "Dont use this ya shit."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"



/obj/structure/fans/tiny/invisible //For blocking air in ruin doorways
	invisibility = INVISIBILITY_ABSTRACT

//lavaland_surface_seed_vault.dmm
//Seed Vault

/obj/effect/spawner/lootdrop/seed_vault
	name = "seed vault seeds"
	lootcount = 1

	loot = list(/obj/item/seeds/gatfruit = 10,
				/obj/item/seeds/cherry = 15,
				/obj/item/seeds/berry/glow = 10,
				/obj/item/seeds/sunflower/moonflower = 8
				)


//Free Golems

/obj/item/weapon/disk/design_disk/golem_shell
	name = "Golem Creation Disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"
	max_blueprints = 1

/obj/item/weapon/disk/design_disk/golem_shell/New()
	..()
	var/datum/design/golem_shell/G = new
	blueprints[1] = G

/datum/design/golem_shell
	name = "Golem Shell Construction"
	desc = "Allows for the construction of a Golem Shell."
	id = "golem"
	req_tech = list("materials" = 12)
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 40000)
	build_path = /obj/item/golem_shell
	category = list("Imported")

/obj/item/golem_shell
	name = "incomplete golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem. Add ten sheets of any mineral to finish."

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/species
	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/O = I

		if(istype(O, /obj/item/stack/sheet/metal))
			species = /datum/species/golem

		if(istype(O, /obj/item/stack/sheet/mineral/plasma))
			species = /datum/species/golem/plasma

		if(istype(O, /obj/item/stack/sheet/mineral/diamond))
			species = /datum/species/golem/diamond

		if(istype(O, /obj/item/stack/sheet/mineral/gold))
			species = /datum/species/golem/gold

		if(istype(O, /obj/item/stack/sheet/mineral/silver))
			species = /datum/species/golem/silver

		if(istype(O, /obj/item/stack/sheet/mineral/uranium))
			species = /datum/species/golem/uranium

		if(species)
			if(O.use(10))
				user << "You finish up the golem shell with ten sheets of [O]."
				var/obj/effect/mob_spawn/human/golem/G = new(get_turf(src))
				G.mob_species = species
				qdel(src)
			else
				user << "You need at least ten sheets to finish a golem."
		else
			user << "You can't build a golem out of this kind of material."


///Syndicate Listening Post

/obj/effect/mob_spawn/human/lavaland_syndicate
	name = "Syndicate Bioweapon Scientist"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/toggle/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset/syndicate/alt
	back = /obj/item/weapon/storage/backpack
	pocket2 = /obj/item/weapon/gun/projectile/automatic/pistol
	has_id = 1
	id_job = "Syndicate Researcher"
	id_access = "syndicate"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_s"
	flavour_text = "<font size=3>You are a syndicate agent, employed in a top secret research facility developing biological weapons. Unfortunatley, your hated enemy, Nanotrasen, has begun mining in this sector. <b>Continue your research as best you can, and try to keep a low profile. Do not abandon the base without good cause.</b> The base is rigged with explosives should the worst happen, do not let the base fall into enemy hands!</b>"
	jobban_type = "lavaland"

/obj/effect/mob_spawn/human/lavaland_syndicate/special(mob/living/L)
	L.add_memory("You are a syndicate agent, employed in a top secret research facility developing biological weapons. Unfortunatley, your hated enemy, Nanotrasen, has begun mining in this sector. Continue your research as best you can, and try to keep a low profile. Do not abandon the base unless it is uninhabitable. The base is rigged with explosives should the worst happen, do not let the base fall into enemy hands!")


/obj/effect/mob_spawn/human/lavaland_syndicate/comms
	name = "Syndicate Comms Agent"
	r_hand = /obj/item/weapon/melee/energy/sword/saber
	mask = /obj/item/clothing/mask/chameleon
	suit = /obj/item/clothing/suit/armor/vest
	flavour_text = "<font size=3>You are a syndicate agent, employed in a top secret research facility developing biological weapons. Unfortunatley, your hated enemy, Nanotrasen, has begun mining in this sector. <b>Monitor enemy activity as best you can, and try to keep a low profile. Do not abandon the base unless it is uninhabitable.</b> Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!</b>"
	pocket2 = /obj/item/weapon/gun/projectile/automatic/pistol
	id_job = "Syndicate Comms Agent"

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/special(mob/living/L)
	L.add_memory("You are a syndicate agent, employed in a top secret research facility developing biological weapons. Unfortunatley, your hated enemy, Nanotrasen, has begun mining in this sector. Monitor enemy activity as best you can, and try to keep a low profile. Do not abandon the base without good cause. Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!")


/obj/effect/mob_spawn/human/lavaland_syndicate/comms/equip(mob/living/carbon/human/H)
	..()
	var/obj/item/clothing/mask/chameleon/M = H.wear_mask
	if(M && M.chameleon)
		M.chameleon.antag_only = FALSE
		addtimer(M.chameleon, "register", 1, , H) //this needs to be delayed because the mob does not have a mind yet


///Syndicate Xenobiologist

/obj/effect/mob_spawn/human/syndicate_xenobiologist
	name = "Syndicate Xenomorph Scientist"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/toggle/labcoat
	back = /obj/item/weapon/storage/backpack
	belt = /obj/item/weapon/gun/energy/gun/mini
	pocket1 = /obj/item/weapon/crowbar/red
	radio = /obj/item/device/radio/headset/syndicate/alt
	has_id = 1
	id_job = "Syndicate Researcher"
	id_access = "syndicate"
	flavour_text = "<font size=3><b></b></font><b>You have awoken from cryosleep, it is time to begin experimentation on these alien lifeforms known as 'xenomorphs' in the hopes of weaponising them against Nanotrasen and other corporate enemies. The egg chamber is located in the bottom right of the facility right beneath the prisoner cells, don't worry about them resisting; they have lost their will to think. The combat environment room is in the bottom left of the facility while surgery and containment is right below where your sleeper is installed. How you go about testing is up to you and your accomplices, however you are to exercise extreme caution, these lifeforms are not dumb animals; should any damage be sustained to the facility there is some spare construction materials in the observation room. DO NOT under any circumstances attempt to leave the Facility."
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_s"
	jobban_type = "lavaland"

/obj/effect/mob_spawn/human/syndicate_xenobiologist/special(mob/living/L)
	L.add_memory("You have awoken from cryosleep, it is time to begin experimentation on these alien lifeforms known as 'xenomorphs' in the hopes of weaponising them against Nanotrasen and other corporate enemies. The egg chamber is located in the bottom right of the facility right beneath the prisoner cells, don't worry about them resisting; they have lost their will to think. The combat environment room is in the bottom left of the facility while surgery and containment is right below where your sleeper is installed. How you go about testing is up to you and your accomplices, however you are to exercise extreme caution, these lifeforms are not dumb animals; should any damage be sustained to the facility there is some spare construction materials in the observation room. DO NOT under any circumstances attempt to leave the Facility.")

/obj/item/clothing/mask/facehugger/syndie
	hive_faction = "syndicate"

/obj/structure/alien/egg/syndie
	hive_faction = "syndicate"

///Space Mercenaries

/obj/effect/mob_spawn/human/space_mercenary
	name = "Space Mercenary"
	uniform = /obj/item/clothing/under/syndicate/tacticool
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset/headset_merc
	back = /obj/item/weapon/storage/backpack
	belt = /obj/item/weapon/gun/projectile/automatic/pistol/m1911
	glasses = /obj/item/clothing/glasses/sunglasses
	helmet = /obj/item/clothing/head/helmet/sec
	mask = /obj/item/clothing/mask/bandana/skull
	pocket1 = /obj/item/device/radio
	pocket2 = /obj/item/weapon/storage/wallet
	flavour_text = "You are a Space Mercenary! As a Space Mercenary your only objective is to complete tasks for space cash, coins and other forms of wealth. You are to listen to your leader, should your leader perish one of you may choose to replace him. You should always demand to be paid upfront before committing to a task or objective given to you by your employer/s, remember that the highest bidder always take priority. Follow the Mercenaries Code and ensure your corp profits from your actions. To talk on your private channel use :y"
	id_job = "Space mercenary"
	has_id = 1
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	jobban_type = "lavaland"

/obj/effect/mob_spawn/human/space_mercenary_leader
	name = "Space Mercenary Leader"
	uniform = /obj/item/clothing/under/syndicate/tacticool
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset/headset_merc
	back = /obj/item/weapon/storage/backpack
	belt = /obj/item/weapon/gun/projectile/automatic/wt550
	glasses = /obj/item/clothing/glasses/sunglasses
	helmet = /obj/item/clothing/head/helmet/sec
	mask = /obj/item/clothing/mask/bandana/skull
	pocket1 = /obj/item/device/radio
	pocket2 = /obj/item/weapon/hand_tele
	flavour_text = "You are the Space Mercenary Leader! YOU ARE IMPORTANT! You have the hand teleporter which allows you to open a one-way portal to your mercenary ship as long as a teleporter is locked onto your beacon. Ensure your mercenaries are following the code, failure to follow the code is clause for immediate termination. To talk on your private channel use :y"
	id_job = "Space mercenary Leader"
	has_id = 1
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	jobban_type = "lavaland"

///Travelling Bard

/obj/effect/mob_spawn/human/travelling_bard
	name = "Travelling Bard"
	uniform = /obj/item/clothing/under/jester
	shoes = /obj/item/clothing/shoes/sneakers/green
	gloves = /obj/item/clothing/gloves/color/green
	back = /obj/item/weapon/storage/backpack/clown
	belt = /obj/item/weapon/pickaxe/drill/diamonddrill
	glasses = /obj/item/clothing/glasses/meson/night
	helmet = /obj/item/clothing/head/jester
	mask = /obj/item/clothing/mask/bandana/green
	pocket1 = /obj/item/weapon/tank/internals/emergency_oxygen/double
	r_hand = /obj/item/device/instrument/guitar
	flavour_text = "You are a travelling Bard! Your only purpose in life is to travel the galaxy, playing songs and telling epic tales of adventure, you have seen many things and you only wish to share your knowledge with all those who you pass. You are a very passive person and dislike the idea of killing another sentient person, if you cannot stop conflict through peace then you would rather remain neutral. Despite your peaceful demeanor, you are not immune to brainwashing or conversion techniques, if converted or brainwashed you are to follow the will of your masters."
	id_job = "Travelling Bard"
	has_id = 1
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	jobban_type = "lavaland"

/obj/effect/mob_spawn/human/travelling_bard/special(mob/living/L)
	L.add_memory("You are a travelling Bard! Your only purpose in life is to travel the galaxy, playing songs and telling epic tales of adventure, you have seen many things and you only wish to share your knowledge with all those who you pass. You are a very passive person and dislike the idea of killing another sentient person, if you cannot stop conflict through peace then you would rather remain neutral. Despite your peaceful demeanor, you are not immune to brainwashing or conversion techniques, if converted or brainwashed you are to follow the will of your masters.")

///Orion Medical Outpost Staff

/obj/effect/mob_spawn/human/orion_doctor
	name = "Orion Outpost Doctor"
	uniform = /obj/item/clothing/under/rank/medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/white
	back = /obj/item/weapon/storage/backpack/medic
	belt = /obj/item/weapon/storage/belt/medical
	glasses = /obj/item/clothing/glasses/hud/health
	flavour_text = "<font size=3><b>Y</b></font><b>ou were working on a medical outpost on Orion when a bluespace translocation was reported in the vicinity, it seems to have moved the outpost to some strange ashen wasteland, regardless of the situation the medical supplies are low and medical scanners report you aren't the first here, time to put your expertise to use and see if there's anyone out there who needs help</b>"
	id_job = "Medical Doctor"
	has_id = 1
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	jobban_type = "lavaland"

/obj/effect/mob_spawn/human/orion_doctor/special(mob/living/L)
	L.add_memory("You were working on a medical outpost on Orion when a bluespace translocation was reported in the vicinity, it seems to have moved the outpost to some strange ashen wasteland, regardless of the situation the medical supplies are low and medical scanners report you aren't the first here, time to put your expertise to use and see if there's anyone out there who needs help.")

/obj/effect/mob_spawn/human/orion_security
	name = "Orion Outpost Security Officer"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/armor/vest
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/weapon/gun/projectile/shotgun/lethal
	belt = /obj/item/weapon/gun/energy/gun/advtaser
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	helmet = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas
	flavour_text = "You are an Orion Spaceport officer, the outpost you were assigned to was moved due to a bluespace anomaly, you are to ensure that no harm comes to the outpost or its staff. You do not follow Space Law. You are the Law."
	id_job = "Security Officer"
	id_access = "Security Officer"
	pocket1 = /obj/item/weapon/tank/internals/emergency_oxygen/double
	pocket2 = /obj/item/device/flashlight/seclite
	has_id = 1
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_s"
	jobban_type = "lavaland"

/obj/effect/mob_spawn/human/orion_security/special(mob/living/L)
	L.add_memory("You are an Orion Spaceport officer, the outpost you were assigned to was moved due to a bluespace anomaly, you are to ensure that no harm comes to the outpost or its staff. You do not follow Space Law. You are the Law.")
