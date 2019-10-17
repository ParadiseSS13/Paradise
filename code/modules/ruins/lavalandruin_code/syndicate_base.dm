// SyndiChem
/obj/machinery/vending/syndichem
	name = "\improper SyndiChem"
	desc = "A vending machine full of grenades and grenade accessories. Sponsored by DonkCo(tm)."
	req_access = list(access_syndicate)
	products = list(/obj/item/stack/cable_coil/random = 5,
					/obj/item/assembly/igniter = 20,
					/obj/item/assembly/prox_sensor = 5,
					/obj/item/assembly/signaler = 5,
					/obj/item/assembly/timer = 5,
					/obj/item/assembly/voice = 5,
					/obj/item/assembly/health = 5,
					/obj/item/assembly/infra = 5,
					/obj/item/grenade/chem_grenade = 5,
	                /obj/item/grenade/chem_grenade/large = 5,
	                /obj/item/grenade/chem_grenade/pyro = 5,
	                /obj/item/grenade/chem_grenade/cryo = 5,
	                /obj/item/grenade/chem_grenade/adv_release = 5,
					/obj/item/reagent_containers/food/drinks/bottle/holywater = 1)
	product_slogans = "It's not pyromania if you're getting paid!;You smell that? Plasma, son. Nothing else in the world smells like that.;I love the smell of Plasma in the morning."
	resistance_flags = FIRE_PROOF

// Spawners
/obj/effect/mob_spawn/human/lavaland_syndicate
	name = "Syndicate Bioweapon Scientist sleeper"
	mob_name = "Syndicate Bioweapon Scientist"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper_s"
	flavour_text = "<span class='big bold'>You are a syndicate agent,</span><b> employed in a top secret research facility developing biological weapons. Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. <b>Continue your research as best you can, and try to keep a low profile. The base is rigged with explosives, do not abandon it or let it fall into enemy hands!</b> \
	<br><i>You are free to attack anyone not aligned with the Syndicate in the vicinity of your base. <font size=6>DO NOT</font> work against Syndicate personnel (such as traitors or nuclear operatives). You may work with or against non-Syndicate antagonists on a case-by-case basis. <font size=6>DO NOT</font> leave your base without admin permission.</i>"
	outfit = /datum/outfit/lavaland_syndicate
	assignedrole = "Lavaland Syndicate"
	allow_species_pick = TRUE

/obj/effect/mob_spawn/human/lavaland_syndicate/Destroy()
	var/obj/structure/fluff/empty_sleeper/syndicate/S = new /obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	S.setDir(dir)
	return ..()

/datum/outfit/lavaland_syndicate
	name = "Lavaland Syndicate Agent"
	r_hand = /obj/item/gun/projectile/automatic/sniper_rifle
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/syndicate/alt
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	id = /obj/item/card/id/syndicate/anyone
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/lavaland_syndicate/post_equip(mob/living/carbon/human/H)
	H.faction |= "syndicate"

/obj/effect/mob_spawn/human/lavaland_syndicate/comms
	name = "Syndicate Comms Agent sleeper"
	mob_name = "Syndicate Comms Agent"
	flavour_text = "<span class='big bold'>You are a syndicate agent,</span><b> employed in a top secret research facility developing biological weapons. Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. <b>Monitor enemy activity as best you can, and try to keep a low profile. Do not abandon the base.</b> Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!</b> \
	<br><i>You are free to attack anyone not aligned with the Syndicate in the vicinity of your base. <font size=6>DO NOT</font> work against Syndicate personnel (such as traitors or nuclear operatives). You may work with or against non-Syndicate antagonists on a case-by-case basis. <font size=6>DO NOT</font> leave your base without admin permission.</i>"
	outfit = /datum/outfit/lavaland_syndicate/comms

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space
	flavour_text = "<span class='big bold'>You are a syndicate agent,</span><b> assigned to a small listening post station situated near your hated enemy's top secret research facility: Space Station 13. <b>Monitor enemy activity as best you can, and try to keep a low profile. Do not abandon the base.</b> Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!</b> \
	<br><i>You are free to attack anyone not aligned with the Syndicate in the vicinity of your base. <font size=6>DO NOT</font> work against Syndicate personnel (such as traitors or nuclear operatives). You may work with or against non-Syndicate antagonists on a case-by-case basis. <font size=6>DO NOT</font> leave your base without admin permission.</i>"

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space/Initialize(mapload)
	. = ..()
	if(prob(90)) //only has a 10% chance of existing, otherwise it'll just be a NPC syndie.
		new /mob/living/simple_animal/hostile/syndicate/ranged(get_turf(src))
		return INITIALIZE_HINT_QDEL

/datum/outfit/lavaland_syndicate/comms
	name = "Lavaland Syndicate Comms Agent"
	r_hand = /obj/item/melee/energy/sword/saber
	mask = /obj/item/clothing/mask/chameleon/gps
	suit = /obj/item/clothing/suit/armor/vest

/obj/item/clothing/mask/chameleon/gps/New()
	. = ..()
	new /obj/item/gps/internal/lavaland_syndicate_base(src)

/obj/item/gps/internal/lavaland_syndicate_base
	gpstag = "Encrypted Signal"