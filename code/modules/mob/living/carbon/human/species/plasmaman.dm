/datum/species/plasmaman // /vg/
	name = "Plasmaman"
	name_plural = "Plasmamen"
	icobase = 'icons/mob/human_races/r_plasmaman_sb.dmi'
	deform = 'icons/mob/human_races/r_plasmaman_pb.dmi'  // TODO: Need deform.
	dangerous_existence = TRUE //So so much
	//language = "Clatter"

	species_traits = list(IS_WHITELISTED, NO_BLOOD, NOTRANSSTING)
	skinned_type = /obj/item/stack/sheet/mineral/plasma // We're low on plasma, R&D! *eyes plasmaman co-worker intently*
	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG

	//default_mutations=list(SKELETON) // This screws things up

	butt_sprite = "plasma"

	breathid = "tox"

	heat_level_1 = 350  // Heat damage level 1 above this point.
	heat_level_2 = 400  // Heat damage level 2 above this point.
	heat_level_3 = 500  // Heat damage level 3 above this point.

	//Has default darksight of 2.

	suicide_messages = list(
		"is twisting their own neck!",
		"is letting some O2 in!",
		"realizes the existential problem of being made out of plasma!",
		"shows their true colors, which happens to be the color of plasma!")

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs/plasmaman,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes
		)

	speciesbox = /obj/item/storage/box/survival_plasmaman

/datum/species/plasmaman/say_filter(mob/M, message, datum/language/speaking)
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "s", stutter("ss"))
	return message

/datum/species/plasmaman/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	var/assigned_role = H.mind && H.mind.assigned_role ? H.mind.assigned_role : "Civilian"
	// Unequip existing suits and hats.
	H.unEquip(H.wear_suit)
	H.unEquip(H.head)
	if(assigned_role != "Clown")
		H.unEquip(H.wear_mask)

	H.equip_or_collect(new /obj/item/clothing/mask/breath(H), slot_wear_mask)
	var/suit=/obj/item/clothing/suit/space/eva/plasmaman/assistant
	var/helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/assistant
	var/tank_slot = slot_s_store
	var/tank_slot_name = "suit storage"

	switch(assigned_role)
		if("Scientist","Roboticist")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/science
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/science
		if("Geneticist")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/science/geneticist
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/science/geneticist
		if("Research Director")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/science/rd
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/science/rd
		if("Station Engineer", "Mechanic")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/engineer
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/engineer
		if("Chief Engineer")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/engineer/ce
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/engineer/ce
		if("Life Support Specialist")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/atmostech
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/atmostech
		if("Detective")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/security
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/security
		if("Warden","Security Officer","Security Pod Pilot")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/security
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/security
		if("Internal Affairs Agent")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/lawyer
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/lawyer
		if("Magistrate")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/magistrate
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/magistrate
		if("Head of Security", "Special Operations Officer")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/security/hos
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/security/hos
		if("Captain", "Blueshield")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/security/captain
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/security/captain
		if("Head of Personnel")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/security/hop
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/security/hop
		if("Nanotrasen Representative", "Nanotrasen Navy Officer")
			suit = /obj/item/clothing/suit/space/eva/plasmaman/nt_rep
			helm = /obj/item/clothing/head/helmet/space/eva/plasmaman/nt_rep
		if("Medical Doctor","Brig Physician","Virologist")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/medical
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/medical
		if("Paramedic")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/medical/paramedic
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/paramedic
		if("Chemist")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/medical/chemist
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/chemist
		if("Chief Medical Officer")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/medical/cmo
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/cmo
		if("Coroner")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/medical/coroner
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/coroner
		if("Virologist")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/medical/virologist
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/virologist
		if("Bartender", "Chef")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/service
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/service
		if("Cargo Technician", "Quartermaster")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/cargo
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/cargo
		if("Shaft Miner")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/miner
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/miner
		if("Botanist")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/botanist
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/botanist
		if("Chaplain")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/chaplain
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/chaplain
		if("Janitor")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/janitor
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/janitor
		if("Civilian", "Barber")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/assistant
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/assistant
		if("Clown")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/clown
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/clown
		if("Mime")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/mime
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/mime
		if("Syndicate Officer")
			suit=/obj/item/clothing/suit/space/eva/plasmaman/nuclear
			helm=/obj/item/clothing/head/helmet/space/eva/plasmaman/nuclear

	if((H.mind.special_role == SPECIAL_ROLE_WIZARD) || (H.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE))
		H.equip_to_slot(new /obj/item/clothing/suit/space/eva/plasmaman/wizard(H), slot_wear_suit)
		H.equip_to_slot(new /obj/item/clothing/head/helmet/space/eva/plasmaman/wizard(H), slot_head)
	else
		H.equip_or_collect(new suit(H), slot_wear_suit)
		H.equip_or_collect(new helm(H), slot_head)
	H.equip_or_collect(new /obj/item/tank/plasma/plasmaman(H), tank_slot) // Bigger plasma tank from Raggy.
	H.equip_or_collect(new /obj/item/plasmensuit_cartridge(H), slot_in_backpack)
	H.equip_or_collect(new /obj/item/plasmensuit_cartridge(H), slot_in_backpack) //Two refill cartridges for their suit. Can fit in boxes.
	to_chat(H, "<span class='notice'>You are now running on plasma internals from the [H.s_store] in your [tank_slot_name]. You must breathe plasma in order to survive, and are extremely flammable.</span>")
	H.internal = H.get_item_by_slot(tank_slot)
	H.update_action_buttons_icon()

/datum/species/plasmaman/handle_life(mob/living/carbon/human/H)
	if(!istype(H.wear_suit, /obj/item/clothing/suit/space/eva/plasmaman) || !istype(H.head, /obj/item/clothing/head/helmet/space/eva/plasmaman))
		var/datum/gas_mixture/environment = H.loc.return_air()
		if(environment && environment.oxygen && environment.oxygen >= OXYCONCEN_PLASMEN_IGNITION) //Plasmamen so long as there's enough oxygen (0.5 moles, same as it takes to burn gaseous plasma).
			H.adjust_fire_stacks(0.5)
			if(!H.on_fire && H.fire_stacks > 0)
				H.visible_message("<span class='danger'>[H]'s body reacts with the atmosphere and bursts into flames!</span>","<span class='userdanger'>Your body reacts with the atmosphere and bursts into flame!</span>")
			H.IgniteMob()
	else
		if(H.on_fire && H.fire_stacks > 0)
			var/obj/item/clothing/suit/space/eva/plasmaman/P = H.wear_suit
			if(istype(P))
				P.Extinguish(H)
	H.update_fire()
	..()

/datum/species/plasmaman/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "plasma")
		H.adjustBruteLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustFireLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
		H.adjustPlasma(20)
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return 0 //Handling reagent removal on our own. Prevents plasma from dealing toxin damage to Plasmamen.

	return ..()
