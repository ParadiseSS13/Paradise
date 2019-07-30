/datum/antagonist/cult
	name = "Cult"
	roundend_category = "cultists"
	job_rank = ROLE_CULTIST
	var/datum/action/innate/cultcomm/communion = new()
	var/talisman = FALSE // to give starting cultists supply talismans

/datum/antagonist/cult/Destroy()
	qdel(communion)
	return ..()

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		. = is_convertable_to_cult(new_owner.current)

/datum/antagonist/cult/greet()
	to_chat(owner.current, "<span class='cultitalic'>You catch a glimpse of the Realm of [SSticker.cultdat.entity_name], [SSticker.cultdat.entity_title3]. You now see how flimsy the world is, you see that it should be open to the knowledge of [SSticker.cultdat.entity_name].</span>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/bloodcult.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/cult/proc/equip_cultist()
	if(!istype(owner))
		return

	if(owner)
		if(owner.assigned_role == "Clown")
			to_chat(owner.current, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			owner.current.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(owner)
	if(talisman)
		var/obj/item/paper/talisman/supply/T = new(owner.current)
		var/list/slots = list (
			"backpack" = slot_in_backpack,
			"left pocket" = slot_l_store,
			"right pocket" = slot_r_store,
			"left hand" = slot_l_hand,
			"right hand" = slot_r_hand,
		)
		var/where = owner.current.equip_in_one_of_slots(T, slots)
		if(!where)
			to_chat(owner.current, "<span class='danger'>Unfortunately, you weren't able to get a talisman. This is very bad and you should adminhelp immediately.</span>")
		else
			to_chat(owner.current, "<span class='cult'>You have a talisman in your [where], one that will help you start the cult on this station. Use it well and remember - there are others.</span>")
			owner.current.update_icons()
			return 1

/datum/antagonist/cult/on_gain()
	if(SSticker && SSticker.mode && owner)
		SSticker.mode.cult += owner
		SSticker.mode.update_cult_icons_added(owner)
		var/datum/game_mode/cult/cult_mode = SSticker.mode
		cult_mode.memorize_cult_objectives(owner)
		if(jobban_isbanned(owner, ROLE_CULTIST))
			addtimer(SSticker.mode, "replace_jobbaned_player", 0, FALSE, owner, ROLE_CULTIST, ROLE_CULTIST)
	equip_cultist(owner)
	owner.current.create_attack_log("<span class='cult'>Has been converted to the cult of Nar'Sie!</span>")
	..()

/datum/antagonist/cult/apply_innate_effects()
	owner.faction |= "cult"
	communion.Grant(owner)
	..()

/datum/antagonist/cult/remove_innate_effects()
	owner.faction -= "cult"
	..()

/datum/antagonist/cult/on_removal()
	if(SSticker && SSticker.mode && owner)
		SSticker.mode.cult -= owner
		SSticker.mode.update_cult_icons_removed(owner)
		owner.special_role = null
	owner << "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of the Dark One and all your memories as its servant.</span>"
	owner.memory = ""
	owner.current.create_attack_log("<span class='cult'>Has renounced the cult of Nar'Sie!</span>")
	owner.current.visible_message("<span class='big'>[owner] looks like they just reverted to their old faith!</span>")
	..()