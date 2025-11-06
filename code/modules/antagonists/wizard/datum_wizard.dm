//Greetings from the Wizard Federation!!
/datum/antagonist/wizard
	name = "Wizard"
	roundend_category = "wizards"
	job_rank = ROLE_WIZARD
	special_role = SPECIAL_ROLE_WIZARD
	antag_hud_name = "hudwizard"
	antag_hud_type = ANTAG_HUD_WIZ
	clown_gain_text = "Your new magical powers has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
	clown_removal_text = "You lose your magical powers and return to your own clumsy, clownish self."
	wiki_page_name = "Wizard"
	var/should_equip_wizard = TRUE
	var/should_name_pick = TRUE
	var/additional_text

/datum/antagonist/wizard/on_gain()
	. = ..()
	owner.current.faction -= "neutral"
	owner.current.faction |= "wizard"
	owner.offstation_role = TRUE
	if(should_name_pick)
		name_wizard()
	SEND_SOUND(owner.current, 'sound/ambience/antag/ragesmages.ogg')

/datum/antagonist/wizard/greet()
	. = ..()
	if(additional_text)
		. += additional_text

/datum/antagonist/wizard/finalize_antag()
	var/list/messages = list()
	if(should_equip_wizard)
		messages = equip_wizard()
	if(full_on_wizard())
		messages += "Remember to bring your magical Mugwort Tea, it will slowly heal you when you drink it."
	return messages

/datum/antagonist/wizard/detach_from_owner()
	owner.current.faction |= "neutral"
	owner.current.faction -= "wizard"
	owner.offstation_role = FALSE
	owner.current.spellremove()
	return ..()

/datum/antagonist/wizard/farewell()
	if(owner?.current)
		to_chat(owner.current, "<span class='warning'><font size = 3><b>You have been brainwashed! You are no longer a [name]!</b></font></span>")

/datum/antagonist/wizard/add_owner_to_gamemode()
	SSticker.mode.wizards |= owner

/datum/antagonist/wizard/remove_owner_from_gamemode()
	SSticker.mode.wizards -= owner

/datum/antagonist/wizard/give_objectives()
	add_antag_objective(/datum/objective/wizchaos)

/datum/antagonist/wizard/proc/name_wizard()
	INVOKE_ASYNC(src, PROC_REF(_name_wizard))

/datum/antagonist/wizard/proc/_name_wizard()
	PRIVATE_PROC(TRUE)
	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/newname = sanitize(copytext(input(owner.current, "You are the Space Wizard. Would you like to change your name to something else?", "Name change", randomname) as null|text,1,MAX_NAME_LEN))

	if(!newname)
		newname = randomname
	owner.current.rename_character(owner.current.real_name, newname)

/datum/antagonist/wizard/proc/equip_wizard()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/new_wiz = owner.current

	//So zards properly get their items when they are admin-made.
	qdel(new_wiz.wear_suit)
	qdel(new_wiz.head)
	qdel(new_wiz.shoes)
	qdel(new_wiz.r_hand)
	qdel(new_wiz.r_store)
	qdel(new_wiz.l_store)

	if(isplasmaman(new_wiz))
		new_wiz.equipOutfit(new /datum/outfit/plasmaman/wizard)
		new_wiz.internal = new_wiz.r_hand
		new_wiz.update_action_buttons_icon()
	else
		new_wiz.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(new_wiz), ITEM_SLOT_JUMPSUIT)
		new_wiz.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(new_wiz), ITEM_SLOT_HEAD)
		new_wiz.dna.species.after_equip_job(null, new_wiz)
	new_wiz.rejuvenate() //fix any damage taken by naked vox/plasmamen/etc while round setups
	new_wiz.equip_to_slot_or_del(new /obj/item/radio/headset(new_wiz), ITEM_SLOT_LEFT_EAR)
	new_wiz.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(new_wiz), ITEM_SLOT_SHOES)
	new_wiz.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(new_wiz), ITEM_SLOT_OUTER_SUIT)
	new_wiz.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(new_wiz), ITEM_SLOT_BACK)
	if(new_wiz.dna.species.speciesbox)
		new_wiz.equip_to_slot_or_del(new new_wiz.dna.species.speciesbox(new_wiz), ITEM_SLOT_IN_BACKPACK)
	else
		new_wiz.equip_to_slot_or_del(new /obj/item/storage/box/survival(new_wiz), ITEM_SLOT_IN_BACKPACK)
	new_wiz.equip_to_slot_or_del(new /obj/item/teleportation_scroll(new_wiz), ITEM_SLOT_RIGHT_POCKET)
	var/obj/item/spellbook/spellbook = new /obj/item/spellbook(new_wiz)
	spellbook.owner = new_wiz
	new_wiz.equip_to_slot_or_del(spellbook, ITEM_SLOT_LEFT_HAND)

	var/list/reading = list()
	reading += "You will find a list of available spells in your spell book. Choose your magic arsenal carefully."
	reading += "The spellbook is bound to you, and others cannot use it."
	reading += "In your pockets you will find a teleport scroll. Use it as needed."
	new_wiz.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	new_wiz.update_icons()
	new_wiz.gene_stability += DEFAULT_GENE_STABILITY //magic
	return reading

/datum/antagonist/wizard/proc/full_on_wizard()
	return TRUE

/datum/antagonist/wizard/proc/wizard_is_alive() // fun fact did you know underscore make proc calls slower?
	for(var/datum/spell/lichdom/S in owner.spell_list)
		if(S.is_revive_possible()) // This must occur before the == DEAD check
			return TRUE
	if(!iscarbon(owner.current) || owner.current.stat == DEAD)
		return FALSE
	return TRUE
