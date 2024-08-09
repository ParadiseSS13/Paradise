/datum/antagonist/wizard/apprentice/partymember
	name = "Wizard Party Member"
	var/greeting_text = "<span class='danger'>You have been recruited as the Wizard's party member! \
		You are bound by magic contract to follow their orders and help them in accomplishing their goals.</span>"

/datum/antagonist/wizard/apprentice/partymember/give_objectives()
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.target = my_teacher.mind
	new_objective.explanation_text = "Protect and obey [my_teacher.real_name], your party leader."
	add_antag_objective(new_objective)

/datum/antagonist/wizard/apprentice/equip_wizard()
	if(!class_type)
		CRASH("/datum/antagonist/wizard/apprentice/partymember was never assigned a class_type")
	var/mob/living/carbon/human/new_wiz = owner.current
	new_wiz.equip_to_slot_or_del(new /obj/item/radio/headset(new_wiz), SLOT_HUD_LEFT_EAR)
	new_wiz.equip_to_slot_or_del(new /obj/item/storage/backpack(new_wiz), SLOT_HUD_BACK)
	new_wiz.equip_to_slot_or_del(new /obj/item/storage/box(new_wiz), SLOT_HUD_IN_BACKPACK)
	new_wiz.equip_to_slot_or_del(new /obj/item/teleportation_scroll/apprentice(new_wiz), SLOT_HUD_IN_BACKPACK)

	var/list/messages = list()
	switch(class_type)
		if("cleric")
			//equip cleric outfit
			messages += "<b>You are equipped with an armored labcoat, a variety of medical supplies and a surgery tools implant. Keep your party healthy!</b>"
		if("paladin")
			//equip pally outfit
			messages += "<b>You are a Paladin, equipped with reinforced armor, a sword, a whetstone, and some medical supplies. Sharpen your sword, keep your party healthy and smite the heretics!</b>"
		if("barbarian")
			//equip barb outfit
			messages += "<b>You are a Barbarian, equipped with fireproof armor, an axe, a whetstone, a short-range fire spray, and a fire extinguisher. Sharpen your axe, and charge at your enemies!</b>"
		if("warrior")
			//equip warrior outfit
			messages += "<b>You are a Warrior, equipped with reinforced riot armor and a variety of combat gear including a stun baton and riot shotgun. Get in the fight!</b>"

	return messages
