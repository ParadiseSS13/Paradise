/datum/job/syndicateofficer
	title = "Syndicate Officer"
	flag = JOB_SYNDICATE
	department_flag = JOB_SYNDICATE // This gets its job as its own flag because admin jobs dont have flags
	total_positions = 5
	spawn_positions = 5
	supervisors = "the admins"
	selection_color = "#ff0000"
	access = list()
	minimal_access = list()
	admin_only = TRUE
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
	shoes = /obj/item/clothing/shoes/magboots/elite
	mask = /obj/item/clothing/mask/holo_cigar
	belt = /obj/item/storage/belt/military
	l_ear = /obj/item/radio/headset/syndicate/alt/syndteam
	pda = /obj/item/pinpointer/advpinpointer
	id = /obj/item/card/id/syndicate/command
	box = /obj/item/storage/box/survival_syndi
	backpack_contents = list(
		/obj/item/flashlight = 1,
		/obj/item/ammo_box/magazine/m50 = 2,
		/obj/item/gun/projectile/automatic/pistol/deagle/camo = 1,
		/obj/item/clothing/accessory/holster = 1
	)
	implants = list(
		/obj/item/implant/dust,
		/obj/item/implant/freedom,
		/obj/item/implant/adrenalin
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/eyes/cybernetic/xray/hardened
	)

/datum/outfit/job/syndicateofficer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/implant/uplink/admin/U = new /obj/item/implant/uplink/admin(H)
	U.implant(H)
	U.hidden_uplink.uses = 2500
	H.faction += "syndicate"
	var/datum/atom_hud/antag/opshud = GLOB.huds[ANTAG_HUD_OPS]
	opshud.join_hud(H.mind.current)
	H.mind.offstation_role = TRUE
	set_antag_hud(H.mind.current, "hudoperative")
	H.regenerate_icons()
