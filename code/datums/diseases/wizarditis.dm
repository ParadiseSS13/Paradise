/datum/disease/wizarditis
	name = "Wizarditis"
	desc = "Some speculate that this virus is the cause of Wizard Federation existence. Subjects affected show signs of dementia, yelling obscure sentences or total gibberish. In late stages, subjects sometime express feelings of inner power, and cite 'the ability to control the forces of cosmos themselves!' A gulp of strong, manly spirits usually reverts them to normal, humanlike condition."
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "The Manly Dorf"
	cures = list("manlydorf")
	cure_chance = 100
	agent = "Rincewindus Vulgaris"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	severity = VIRUS_MINOR
	/// A mapping of `num2text(ITEM_SLOT_XYZ)` -> item path
	var/list/magic_fashion = list()


/datum/disease/wizarditis/New()
	. = ..()

	var/list/magic_fashion_slot_IDs = list(
		ITEM_SLOT_LEFT_HAND,
		ITEM_SLOT_RIGHT_HAND,
		ITEM_SLOT_HEAD,
		ITEM_SLOT_OUTER_SUIT,
		ITEM_SLOT_SHOES
	)
	var/list/magic_fashion_items = list(
		/obj/item/staff,
		/obj/item/staff,
		/obj/item/clothing/head/wizard,
		/obj/item/clothing/suit/wizrobe,
		/obj/item/clothing/shoes/sandal
	)
	for(var/i in 1 to length(magic_fashion_slot_IDs))
		var/slot = num2text(magic_fashion_slot_IDs[i])
		var/item = magic_fashion_items[i]
		magic_fashion[slot] = item

/datum/disease/wizarditis/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2, 3)
			if(prob(2)) // Low prob. since everyone else will also be spouting this
				affected_mob.say(pick("You shall not pass!", "Expeliarmus!", "By Merlin's beard!", "Feel the power of the Dark Side!", "A wizard is never late!", "50 points for Security!", "NEC CANTIO!", "STI KALY!", "AULIE OXIN FIERA!", "GAR YOK!", "DIRI CEL!"))
			if(prob(8)) // Double the stage advancement prob. so each player has a chance to catch a couple
				to_chat(affected_mob, "<span class='danger'>You feel [pick("that you don't have enough mana", "that the winds of magic are gone", "that this location gives you a +1 to INT", "an urge to summon familiar")].</span>")
		if(4)
			if(prob(1))
				affected_mob.say(pick("FORTI GY AMA!", "GITTAH WEIGH!", "TOKI WO TOMARE!", "TARCOL MINTI ZHERI!", "ONI SOMA!", "EI NATH!", "BIRUZ BENNAR!", "NWOLC EGNEVER!"))
			if(prob(3)) // Last stage, so we'll have plenty of time to show these off even with a lower prob.
				to_chat(affected_mob, "<span class='danger'>You feel [pick("the tidal wave of raw power building inside", "that this location gives you a +2 to INT and +1 to WIS", "an urge to teleport", "the magic bubbling in your veins", "an urge to summon familiar")].</span>")
			if(prob(3)) // About 1 minute per item on average
				spawn_wizard_clothes()
			if(prob(0.033)) // Assuming 50 infected, someone should teleport every ~2 minutes on average
				teleport()

/datum/disease/wizarditis/proc/spawn_wizard_clothes()
	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return // Woe, wizard xeno upon ye

	// Which slots can we replace?
	var/list/eligible_slot_IDs = list()
	for(var/slot in magic_fashion)
		var/slot_ID = text2num(slot) // Convert back to numeric defines

		if((locate(magic_fashion[slot]) in H) || !H.has_organ_for_slot(slot_ID) || !H.canUnEquip(H.get_item_by_slot(slot_ID)))
			continue

		switch(slot_ID) // Extra filtering for specific slots
			if(ITEM_SLOT_HEAD)
				if(isplasmaman(H))
					continue // We want them to spread the magical joy, not burn to death in agony

		eligible_slot_IDs.Add(slot_ID)
	if(!length(eligible_slot_IDs))
		return

	// Pick the magical winner and apply
	var/chosen_slot_ID = pick(eligible_slot_IDs)
	var/chosen_fashion = magic_fashion[num2text(chosen_slot_ID)]

	H.drop_item_to_ground(H.get_item_by_slot(chosen_slot_ID))
	var/obj/item/magic_attire = new chosen_fashion
	magic_attire.flags |= DROPDEL
	H.equip_to_slot_or_del(magic_attire, chosen_slot_ID)

/datum/disease/wizarditis/proc/teleport()
	if(!is_teleport_allowed(affected_mob.z))
		return
	if(SEND_SIGNAL(affected_mob, COMSIG_MOVABLE_TELEPORTING, get_turf(affected_mob)) & COMPONENT_BLOCK_TELEPORT)
		return FALSE

	var/list/possible_areas = get_areas_in_range(80, affected_mob)
	for(var/area/space/S in possible_areas)
		possible_areas -= S

	if(!length(possible_areas))
		return

	var/area/chosen_area = pick(possible_areas)

	var/list/teleport_turfs = list()
	for(var/turf/T in get_area_turfs(chosen_area.type))
		if(isspaceturf(T))
			continue
		if(!T.density)
			var/clear = TRUE
			for(var/obj/O in T)
				if(O.density)
					clear = FALSE
					break
			if(clear)
				teleport_turfs += T

	if(!length(teleport_turfs))
		return

	affected_mob.say("SCYAR NILA [uppertext(chosen_area.name)]!")
	affected_mob.forceMove(pick(teleport_turfs))
