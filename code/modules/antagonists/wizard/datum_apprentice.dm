/datum/antagonist/wizard/apprentice
	name = "Wizard Apprentice"
	special_role = SPECIAL_ROLE_WIZARD_APPRENTICE
	antag_hud_name = "apprentice"
	antag_datum_blacklist = list(/datum/antagonist/wizard/construct)

	/// Temporary reference to a mob for purposes of objectives, and general text for the apprentice.
	var/mob/living/my_teacher
	/// The class type of this apprentice,
	var/class_type

/datum/antagonist/wizard/apprentice/greet()
	. = ..()
	. += "<span class='danger'>You are [my_teacher.real_name]'s apprentice! You are bound by magic contract to follow [my_teacher.p_their()] orders and help [my_teacher.p_them()] in accomplishing [my_teacher.p_their()] goals.</span>"

/datum/antagonist/wizard/apprentice/give_objectives()
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.target = my_teacher.mind
	new_objective.explanation_text = "Protect and obey [my_teacher.real_name], your teacher."
	add_antag_objective(new_objective)

/datum/antagonist/wizard/apprentice/on_gain()
	. = ..()
	my_teacher = null // all uses of my_teacher come before this, so lets clean up the reference.

/datum/antagonist/wizard/apprentice/add_owner_to_gamemode()
	SSticker.mode.apprentices |= owner

/datum/antagonist/wizard/apprentice/remove_owner_from_gamemode()
	SSticker.mode.apprentices -= owner

/datum/antagonist/wizard/apprentice/equip_wizard()
	if(!class_type)
		CRASH("/datum/antagonist/wizard/apprentice was never assigned a class_type")
	var/mob/living/carbon/human/new_wiz = owner.current
	new_wiz.equip_to_slot_or_del(new /obj/item/radio/headset(new_wiz), ITEM_SLOT_LEFT_EAR)
	if(class_type == "stealth")
		new_wiz.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(new_wiz), ITEM_SLOT_JUMPSUIT)
	else
		new_wiz.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(new_wiz), ITEM_SLOT_JUMPSUIT)
	new_wiz.equip_to_slot_or_del(new /obj/item/storage/backpack(new_wiz), ITEM_SLOT_BACK)
	new_wiz.equip_to_slot_or_del(new /obj/item/storage/box(new_wiz), ITEM_SLOT_IN_BACKPACK)
	new_wiz.equip_to_slot_or_del(new /obj/item/teleportation_scroll/apprentice(new_wiz), ITEM_SLOT_RIGHT_POCKET)

	var/list/messages = list()
	switch(class_type)
		if("fire")
			new_wiz.mind.AddSpell(new /datum/spell/fireball/apprentice(null))
			new_wiz.mind.AddSpell(new /datum/spell/sacred_flame(null))
			ADD_TRAIT(new_wiz, TRAIT_RESISTHEAT, MAGIC_TRAIT)
			ADD_TRAIT(new_wiz, TRAIT_RESISTHIGHPRESSURE, MAGIC_TRAIT)
			new_wiz.mind.AddSpell(new /datum/spell/ethereal_jaunt(null))
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(new_wiz), ITEM_SLOT_SHOES)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(new_wiz), ITEM_SLOT_OUTER_SUIT)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(new_wiz), ITEM_SLOT_HEAD)
			messages += "<b>Your service has not gone unrewarded. Under the tutelage of [my_teacher.real_name], you've acquired proficiency in the fundamentals of Firebending, enabling you to cast spells like Fireball, Sacred Flame, and Ethereal Jaunt.</b>"
			messages += "<b>You are immune to fire, but you are NOT immune to the explosions caused by your fireballs. Neither is your teacher, for that matter. Be careful!</b>"
		if("translocation")
			new_wiz.mind.AddSpell(new /datum/spell/area_teleport/teleport(null))
			new_wiz.mind.AddSpell(new /datum/spell/turf_teleport/blink(null))
			new_wiz.mind.AddSpell(new /datum/spell/ethereal_jaunt(null))
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(new_wiz), ITEM_SLOT_SHOES)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(new_wiz), ITEM_SLOT_OUTER_SUIT)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(new_wiz), ITEM_SLOT_HEAD)
			messages += "<b>Your service has not gone unrewarded. While studying under [my_teacher.real_name], you mastered reality-bending mobility spells, allowing you to cast Teleport, Blink, and Ethereal Jaunt.</b>"
		if("restoration")
			new_wiz.mind.AddSpell(new /datum/spell/charge(null))
			new_wiz.mind.AddSpell(new /datum/spell/aoe/knock(null))
			var/datum/spell/return_to_teacher/S = new /datum/spell/return_to_teacher(null)
			S.teacher = my_teacher.mind
			new_wiz.mind.AddSpell(S)
			new_wiz.equip_to_slot_or_del(new /obj/item/gun/magic/staff/healing(new_wiz), ITEM_SLOT_RIGHT_HAND)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/marisa(new_wiz), ITEM_SLOT_SHOES)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/marisa(new_wiz), ITEM_SLOT_OUTER_SUIT)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/marisa(new_wiz), ITEM_SLOT_HEAD)
			messages += "<b>Your service has not gone unrewarded. Under the guidance of [my_teacher.real_name], you've acquired life-saving survival spells. You can now cast Charge and Knock, and possess the ability to teleport back to your mentor.</b>"
			messages += "<b>Your Charge spell can be used to recharge your Staff of Healing or reduce the cooldowns of your teacher, if you are grabbing them with empty hands.</b>"
		if("stealth")
			new_wiz.mind.AddSpell(new /datum/spell/mind_transfer(null))
			new_wiz.mind.AddSpell(new /datum/spell/aoe/knock(null))
			new_wiz.mind.AddSpell(new /datum/spell/fireball/toolbox(null))
			new_wiz.mind.AddSpell(new /datum/spell/disguise_self(null))
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_wiz), ITEM_SLOT_SHOES)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(new_wiz), ITEM_SLOT_MASK)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(new_wiz), ITEM_SLOT_GLOVES)
			new_wiz.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(new_wiz), ITEM_SLOT_BELT)
			messages += "<b>Your service has not gone unrewarded. Under the mentorship of [my_teacher.real_name], you've mastered stealthy, robeless spells. You can now cast Mindswap, Knock, Homing Toolbox, and Disguise Self without the need for wizard robes.</b>"
		if("honk")
			new_wiz.mind.AddSpell(new /datum/spell/touch/banana/apprentice(null))
			new_wiz.mind.AddSpell(new /datum/spell/ethereal_jaunt(null))
			new_wiz.mind.AddSpell(new /datum/spell/summonitem(null))
			new_wiz.equip_to_slot_or_del(new /obj/item/gun/magic/staff/slipping(new_wiz), ITEM_SLOT_RIGHT_HAND)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes/magical/nodrop(new_wiz), ITEM_SLOT_SHOES)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/clown(new_wiz), ITEM_SLOT_OUTER_SUIT)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/clown(new_wiz), ITEM_SLOT_HEAD)
			new_wiz.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clownwiz(new_wiz), ITEM_SLOT_MASK)
			messages += "<b>Your dedication pays off! Under [my_teacher.real_name]'s guidance, you've mastered magical honkings, seamlessly casting spells like Banana Touch, Ethereal Jaunt, and Instant Summons, while skillfully wielding a Staff of Slipping. Honk!</b>"

	return messages

/datum/antagonist/wizard/apprentice/full_on_wizard()
	return FALSE
