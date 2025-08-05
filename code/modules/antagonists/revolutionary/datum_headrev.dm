RESTRICT_TYPE(/datum/antagonist/rev/head)

/datum/antagonist/rev/head
	name = "Head Revolutionary"
	antag_hud_name = "hudheadrevolutionary"
	converted = FALSE
	var/should_equip = TRUE

/datum/antagonist/rev/head/on_gain()
	..()
	if(should_equip)
		equip_revolutionary()

/datum/antagonist/rev/head/on_cryo()
	var/datum/team/revolution/revolting = get_team()
	INVOKE_ASYNC(revolting, TYPE_PROC_REF(/datum/team/revolution, process_promotion), REVOLUTION_PROMOTION_AT_LEAST_ONE)

/datum/antagonist/rev/head/greet()
	return "<span class='userdanger'>You are a member of the revolutionaries' leadership! Mutiny against the station's command and take control!</span>"

/datum/antagonist/rev/head/add_owner_to_gamemode()
	SSticker.mode.head_revolutionaries |= owner

/datum/antagonist/rev/head/remove_owner_from_gamemode()
	SSticker.mode.head_revolutionaries -= owner


/datum/antagonist/rev/head/proc/equip_revolutionary(give_flash = TRUE, give_hud = TRUE)
	var/mob/living/carbon/human/revolutionary = owner.current
	if(!istype(revolutionary))
		return

	var/list/slots = list(
		"backpack" = ITEM_SLOT_IN_BACKPACK,
		"left pocket" = ITEM_SLOT_LEFT_POCKET,
		"right pocket" = ITEM_SLOT_RIGHT_POCKET,
		"left hand" = ITEM_SLOT_LEFT_HAND,
		"right hand" = ITEM_SLOT_RIGHT_HAND,
	)

	var/flashloc_name
	if(give_flash)
		var/obj/item/flash/T = new(get_turf(revolutionary))
		flashloc_name = revolutionary.equip_in_one_of_slots(T, slots)
		to_chat(revolutionary, "The flash in your [flashloc_name] will help you to persuade the crew to join your cause.")

	if(give_hud)
		var/obj/item/organ/internal/cyberimp/eyes/hud/security/hidden/O = new /obj/item/organ/internal/cyberimp/eyes/hud/security/hidden
		O.insert(revolutionary)
		to_chat(revolutionary, "The security HUD implant in your head will help you keep track of who is mindshield-implanted, and unable to be recruited.")

	revolutionary.update_icons()
	return flashloc_name

/datum/antagonist/rev/head/promote()
	return

/datum/antagonist/rev/head/proc/demote()
	var/datum/mind/old_owner = owner
	owner.remove_antag_datum(/datum/antagonist/rev/head, silent_removal = TRUE)

	var/datum/antagonist/rev/demoted = new()
	demoted.silent = TRUE
	demoted.converted = FALSE
	old_owner.add_antag_datum(demoted, SSticker.mode.get_rev_team())
	demoted.silent = FALSE
	to_chat(old_owner.current, "<span class='userdanger'>The Revolution is disappointed in your leadership! You are a regular revolutionary now!</span>")

