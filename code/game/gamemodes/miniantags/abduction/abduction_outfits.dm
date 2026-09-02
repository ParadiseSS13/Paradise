/datum/outfit/abductor
	name = "Abductor Basic"
	uniform = /obj/item/clothing/under/abductor
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	l_ear = /obj/item/radio/headset/abductor

/datum/outfit/abductor/proc/get_team_console(team_number)
	for(var/obj/machinery/abductor/console/C in SSmachines.get_by_type(/obj/machinery/abductor/console))
		if(C.team == team_number)
			return C

/datum/outfit/abductor/proc/link_to_console(mob/living/carbon/human/H, team_number)
	if(!team_number && isabductor(H))
		var/datum/species/abductor/S = H.dna.species
		team_number = S.team

	if(!team_number)
		team_number = 1

	var/obj/machinery/abductor/console/console = get_team_console(team_number)
	if(console)
		var/obj/item/clothing/suit/armor/abductor/vest/V = locate() in H
		if(V)
			console.vest = V
			V.set_nodrop(TRUE, H)

		var/obj/item/abductor/gizmo/G = locate() in H.get_item_by_slot(ITEM_SLOT_BACK)
		if(G)
			console.gizmo = G
			G.console = console

/datum/outfit/abductor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(!visualsOnly)
		link_to_console(H)


/datum/outfit/abductor/agent
	name = "Abductor Agent"
	head = /obj/item/clothing/head/helmet/abductor
	suit = /obj/item/clothing/suit/armor/abductor/vest
	belt = /obj/item/storage/belt/military/abductor/full

	backpack_contents = list(
		/obj/item/abductor_baton = 1,
		/obj/item/gun/energy/alien = 1,
		/obj/item/abductor/silencer = 1
		)

/datum/outfit/abductor/scientist
	name = "Abductor Scientist"
	suit = /obj/item/clothing/suit/storage/labcoat/abductor

	backpack_contents = list(
		/obj/item/abductor/gizmo = 1
		)

/datum/outfit/abductor/scientist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(!visualsOnly)
		var/obj/item/bio_chip/abductor/beamplant = new /obj/item/bio_chip/abductor(H)
		beamplant.implant(H)
