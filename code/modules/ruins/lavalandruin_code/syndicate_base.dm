// SyndiChem
/obj/machinery/vending/syndichem
	name = "\improper SyndiChem"
	desc = "A vending machine full of grenades and grenade accessories. Sponsored by DonkCo(tm)."
	req_access = list(ACCESS_SYNDICATE)
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
	slogan_list = list("It's not pyromania if you're getting paid!","You smell that? Plasma, son. Nothing else in the world smells like that.","I love the smell of Plasma in the morning.")
	resistance_flags = FIRE_PROOF

// Spawners
/obj/effect/mob_spawn/human/lavaland_syndicate
	name = "Syndicate Bioweapon Scientist sleeper"
	mob_name = "Syndicate Bioweapon Scientist"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper_s"
	important_info = "Do not work against Syndicate personnel (such as traitors or nuclear operatives). You may work with or against non-Syndicate antagonists on a case-by-case basis. Do not leave your base without admin permission."
	description = "Experiment with deadly chems and viruses in peace or help any visiting Syndicate Agent."
	flavour_text = "You are a syndicate agent, employed in a top secret research facility developing biological weapons. Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Continue your research as best you can, and try to keep a low profile. The base is rigged with explosives, do not abandon it or let it fall into enemy hands!\
	 It's been made clear to you that the Syndicate will make you regret it if you disappoint them."
	outfit = /datum/outfit/lavaland_syndicate
	assignedrole = "Lavaland Syndicate"
	del_types = list() // Necessary to prevent del_types from removing radio!
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
	r_ear = /obj/item/radio/headset/syndicate/alt/lavaland // See del_types above
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	id = /obj/item/card/id/syndicate/anyone
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/lavaland_syndicate/post_equip(mob/living/carbon/human/H)
	H.faction |= "syndicate"

/obj/effect/mob_spawn/human/lavaland_syndicate/comms
	name = "Syndicate Comms Agent sleeper"
	mob_name = "Syndicate Comms Agent"
	important_info = "Do not work against Syndicate personnel (such as traitors or nuclear operatives). You may work with or against non-Syndicate antagonists on a case-by-case basis. Do not leave your base without admin permission. Do not reveal the existence of yourself to NT."
	description = "Monitor comms and cameras and try to assist any agents on station while keeping your existence a secret."
	flavour_text = "You are a syndicate agent, employed in a top secret research facility developing biological weapons. Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Monitor enemy activity as best you can, and try to keep a low profile."
	outfit = /datum/outfit/lavaland_syndicate/comms

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space
	flavour_text = "You are a syndicate agent, employed in a small listening outpost. You'd be bored to death if you couldn't listen in on those NT idiots mess up all the time."

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space/Initialize(mapload)
	. = ..()
	if(prob(90)) //only has a 10% chance of existing, otherwise it'll just be a NPC syndie.
		new /mob/living/simple_animal/hostile/syndicate/ranged(get_turf(src))
		return INITIALIZE_HINT_QDEL

/datum/outfit/lavaland_syndicate/comms
	name = "Lavaland Syndicate Comms Agent"
	r_ear = /obj/item/radio/headset/syndicate/alt // See del_types above
	r_hand = /obj/item/melee/energy/sword/saber
	mask = /obj/item/clothing/mask/chameleon/gps
	suit = /obj/item/clothing/suit/armor/vest
	backpack_contents = list(
		/obj/item/paper/monitorkey = 1 // message console on lavaland does NOT spawn with this
	)

/obj/item/clothing/mask/chameleon/gps/New()
	. = ..()
	new /obj/item/gps/internal/lavaland_syndicate_base(src)

/obj/item/gps/internal/lavaland_syndicate_base
	gpstag = "Encrypted Signal"
