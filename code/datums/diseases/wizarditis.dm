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
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	permeability_mod = 0.75
	severity = HARMFUL
	required_organs = list(/obj/item/organ/external/head)

/*
BIRUZ BENNAR
SCYAR NILA - teleport
NEC CANTIO - dis techno
EI NATH - shocking grasp
AULIE OXIN FIERA - knock
TARCOL MINTI ZHERI - forcewall
STI KALY - blind
*/

/datum/disease/wizarditis/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2)
			if(prob(0.5))
				affected_mob.say(pick("You shall not pass!", "Expeliarmus!", "By Merlins beard!", "Feel the power of the Dark Side!"))
			if(prob(0.5))
				to_chat(affected_mob, "<span class='danger'>You feel [pick("that you don't have enough mana", "that the winds of magic are gone", "an urge to summon familiar")].</span>")


		if(3)
			if(prob(0.5))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!", "STI KALY!", "TARCOL MINTI ZHERI!"))
			if(prob(0.5))
				to_chat(affected_mob, "<span class='danger'>You feel [pick("the magic bubbling in your veins","that this location gives you a +1 to INT","an urge to summon familiar")].</span>")

		if(4)

			if(prob(1))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!","STI KALY!","EI NATH!"))
				return
			if(prob(0.5))
				to_chat(affected_mob, "<span class='danger'>You feel [pick("the tidal wave of raw power building inside","that this location gives you a +2 to INT and +1 to WIS","an urge to teleport")].</span>")
				spawn_wizard_clothes(50)
			if(prob(0.01))
				teleport()
	return



/datum/disease/wizarditis/proc/spawn_wizard_clothes(chance = 0)
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if(prob(chance) && !isplasmaman(H))
			if(!istype(H.head, /obj/item/clothing/head/wizard))
				if(!H.unEquip(H.head))
					qdel(H.head)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(H), slot_head)
			return
		if(prob(chance))
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(!H.unEquip(H.wear_suit))
					qdel(H.wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(H), slot_wear_suit)
			return
		if(prob(chance))
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
				if(!H.unEquip(H.shoes))
					qdel(H.shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
			return
	else
		var/mob/living/carbon/H = affected_mob
		if(prob(chance))
			if(!istype(H.r_hand, /obj/item/staff))
				H.drop_r_hand()
				H.put_in_r_hand( new /obj/item/staff(H) )
			return
	return



/datum/disease/wizarditis/proc/teleport()
	if(!is_teleport_allowed(affected_mob.z))
		return

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

