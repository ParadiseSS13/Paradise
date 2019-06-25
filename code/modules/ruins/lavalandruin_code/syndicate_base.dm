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
	flavour_text = "<span class='big bold'>Eres un agente del sindicato,</span><b> empleado para desarrollar armas biológicas en una estación de investigación secreta. Deasfortunadamente, tu detestable enemigo, Nanotrasen, ha comenzado a minar en este sector. <b>Continúa con tu trabajo lo mejor que puedas, manteniendo un bajo perfil. La base está cargada con explosivos, no dejes que caiga en manos del enemigo ni la abandones.</b> \
	<br><i>Eres libre de atacar a cualquiera que no esté alineado en las cercanías alrededor de la base. <font size=6>NO</font> trabajes con agentes del sindicator (como traidores u operativos nucleares). Puedes trabajar con otros antagonistas dependiendo del caso. <font size=6>NO</font> abandones la base sin permiso de un admin.</i>"
	outfit = /datum/outfit/lavaland_syndicate
	assignedrole = "Lavaland Syndicate"

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
	flavour_text = "<span class='big bold'>Eres un agente del sindicato,</span><b> empleado para desarrollar armas biológicas en una estación de investigación secreta. Deasfortunadamente, tu detestable enemigo, Nanotrasen, ha comenzado a minar en este sector.<b>Tu trabajo es monitorear las comunicaciones enemigas lo mejor que puedas. NO abandones la base.</b> Usa el equipo de comunicaciones para apoyar agentes en el campo, recopilar inteligencia, y emitir desinformación para engañar a Nanotrasen. No dejes que la base caiga en manos enemigas!</b> \
	<br><i>Eres libre de atacar a cualquiera que no esté alineado en las cercanías alrededor de la base. <font size=6>NO</font> trabajes con agentes del sindicator (como traidores u operativos nucleares). Puedes trabajar con otros antagonistas dependiendo del caso. <font size=6>NO</font> abandones la base sin permiso de un admin.</i>"
	outfit = /datum/outfit/lavaland_syndicate/comms

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space
	flavour_text = "<span class='big bold'>Eres un agente del sindicato,</span><b> asignado a un pequeño puesto de escucha cerca de una estación enemiga, Hispania. <b>Tu trabajo es monitorear las comunicaciones enemigas lo mejor que puedas. NO abandones la base.</b> Usa el equipo de comunicaciones para apoyar agentes en el campo y recopilar inteligencia, y emitir desinformación para engañar a Nanotrasen. No dejes que la base caiga en manos enemigas!</b>\
	<br><i>Eres libre de atacar a cualquiera que no esté alineado en las cercanías alrededor de la base. <font size=6>NO</font> trabajes con agentes del sindicator (como traidores u operativos nucleares). Puedes trabajar con otros antagonistas dependiendo del caso. <font size=6>NO</font> abandones la base sin permiso de un admin.</i>"

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