/datum/job/syndicateofficer
	title = "Syndicate Officer"
	flag = SYNDICATE
	department_flag = SYNDICATE
	total_positions = 5
	spawn_positions = 5
	supervisors = "the admins"
	selection_color = "#ff0000"
	access = list()
	minimal_access = list()
	admin_only = 1
	syndicate_command = 1
	outfit = /datum/outfit/job/syndicateofficer

/datum/job/syndicateofficer/get_access()
	return get_syndicate_access(title)

/datum/outfit/job/syndicateofficer
	name = "Syndicate Officer"
	jobtype = /datum/job/syndicateofficer

	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/storage/backpack
	head = /obj/item/clothing/head/beret
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	belt = /obj/item/gun/projectile/automatic/pistol/deagle/camo
	l_ear = /obj/item/radio/headset/syndicate/alt/syndteam
	pda = /obj/item/pinpointer/advpinpointer
	id = /obj/item/card/id/syndicate/command
	box = /obj/item/storage/box/survival_syndi
	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/reagent_containers/food/snacks/syndidonkpocket = 1,
		/obj/item/ammo_box/magazine/m50 = 2,
		/obj/item/clothing/shoes/magboots/syndie/advance = 1,
		/obj/item/lighter/zippo/gonzofist = 1,
		/obj/item/storage/box/matches = 1
	)
	implants = list(
		/obj/item/implant/dust
	)

/datum/outfit/job/syndicateofficer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/implant/uplink/admin/U = new /obj/item/implant/uplink/admin(H)
	U.implant(H)
	U.hidden_uplink.uses = 500
	H.faction += "syndicate"
	var/datum/atom_hud/antag/opshud = huds[ANTAG_HUD_OPS]
	opshud.join_hud(H.mind.current)
	H.mind.offstation_role = TRUE
	set_antag_hud(H.mind.current, "hudoperative")
	H.regenerate_icons()