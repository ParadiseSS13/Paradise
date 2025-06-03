RESTRICT_TYPE(/datum/antagonist/cultist)

/datum/antagonist/cultist
	name = "Cultist"
	job_rank = ROLE_CULTIST
	special_role = SPECIAL_ROLE_CULTIST
	give_objectives = FALSE
	antag_hud_name = "hudcultist"
	antag_hud_type = ANTAG_HUD_CULT
	clown_gain_text = "A dark power has allowed you to overcome your clownish nature, letting you wield weapons without harming yourself."
	clown_removal_text = "You are free of the dark power suppressing your clownish nature. You are clumsy again! Honk!"
	clown_text_span_class = "cultitalic"
	wiki_page_name = "Cultist"
	var/remove_gear_on_removal = FALSE

/datum/antagonist/cultist/on_gain()
	create_team() // make sure theres a global cult team
	..()
	owner.current.faction |= "cult"
	add_cult_actions()
	SEND_SOUND(owner.current, sound('sound/ambience/antag/bloodcult.ogg'))
	owner.current.create_log(CONVERSION_LOG, "Converted to the cult")
	owner.current.create_attack_log("<span class='danger'>Has been converted to the cult!</span>")

	var/datum/team/cult/cult = get_team()
	ASSERT(cult)
	if(cult.cult_risen)
		rise()
	if(cult.cult_ascendant)
		ascend()
	cult.study_objectives(owner.current)

/datum/antagonist/cultist/detach_from_owner()
	if(!owner.current)
		return ..()
	owner.current.faction -= "cult"
	owner.current.create_log(CONVERSION_LOG, "Deconverted from the cult") // yes, this is its own log, instead of the default MISC_LOG
	for(var/datum/action/innate/cult/C in owner.current.actions)
		qdel(C)

	if(!ishuman(owner.current))
		return ..()
	var/mob/living/carbon/human/H = owner.current
	REMOVE_TRAIT(H, CULT_EYES, null)
	H.change_eye_color(H.original_eye_color, FALSE)
	H.update_eyes()
	H.remove_overlay(HALO_LAYER)
	H.update_body()

	if(remove_gear_on_removal)
		for(var/I in H.contents)
			if(is_type_in_list(I, CULT_CLOTHING))
				H.drop_item_to_ground(I)
	return ..()


/datum/antagonist/cultist/greet()
	return "<span class='cultlarge'>You catch a glimpse of the Realm of [GET_CULT_DATA(entity_name, "this is a bug at this point")], [GET_CULT_DATA(entity_title3, "I dont know what else to write")]. \
						You now see how flimsy the world is, you see that it should be open to the knowledge of [GET_CULT_DATA(entity_name, "making a bug report")].</span>"

/datum/antagonist/cultist/farewell()
	if(owner && owner.current)
		owner.current.visible_message("<span class='cult'>[owner.current] looks like [owner.current.p_they()] just reverted to [owner.current.p_their()] old faith!</span>",
			"<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of [GET_CULT_DATA(entity_title1, "Nar'Sie")] and the memories of your time as their servant with it.</span>")

/datum/antagonist/cultist/create_team(team)
	return SSticker.mode.get_cult_team()

/datum/antagonist/cultist/get_team()
	return SSticker.mode.cult_team

/datum/antagonist/cultist/on_body_transfer(old_body, new_body)
	var/datum/team/cult/cult = get_team()
	cult.cult_body_transfer(old_body, new_body)
	add_cult_actions()

/datum/antagonist/cultist/proc/rise()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current
	if(!H.original_eye_color)
		H.original_eye_color = H.get_eye_color()
	H.change_eye_color(BLOODCULT_EYE, FALSE)
	ADD_TRAIT(H, CULT_EYES, CULT_TRAIT)
	H.update_eyes()
	H.update_body()

/datum/antagonist/cultist/proc/ascend()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current
	new /obj/effect/temp_visual/cult/sparks(get_turf(H), H.dir)
	H.update_halo_layer()

/datum/antagonist/cultist/proc/descend()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current
	new /obj/effect/temp_visual/cult/sparks(get_turf(H), H.dir)
	H.update_halo_layer()
	to_chat(H, "<span class='userdanger'>The halo above your head shatters!</span>")
	playsound(H, "shatter", 50, TRUE)

/datum/antagonist/cultist/proc/add_cult_actions()
	if(!owner.current)
		return
	var/datum/action/innate/cult/comm/communicate_spell = new
	var/datum/action/innate/cult/check_progress/progress_report = new
	communicate_spell.Grant(owner.current)
	progress_report.Grant(owner.current)
	if(ishuman(owner.current))
		var/datum/action/innate/cult/blood_magic/magic = new
		var/datum/action/innate/cult/use_dagger/dagger = new
		magic.Grant(owner.current)
		dagger.Grant(owner.current)

	owner.current.update_action_buttons(TRUE)

/datum/antagonist/cultist/proc/equip_roundstart_cultist()
	if(!ishuman(owner.current))
		return FALSE
	. |= cult_give_item(/obj/item/melee/cultblade/dagger)
	. |= cult_give_item(/obj/item/stack/sheet/runed_metal/ten)
	to_chat(owner.current, "<span class='cult'>These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>")

/datum/antagonist/cultist/proc/cult_give_item(obj/item/item_path)
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current
	var/list/slots = list(
		"backpack" = ITEM_SLOT_IN_BACKPACK,
		"left pocket" = ITEM_SLOT_LEFT_POCKET,
		"right pocket" = ITEM_SLOT_RIGHT_POCKET
	)

	var/where = H.equip_in_one_of_slots(new item_path(H), slots)
	if(where)
		to_chat(H, "<span class='danger'>You have \a [initial(item_path.name)] in your [where].</span>")
		if(H.s_active) // Update whatever inventory they have open
			H.s_active.orient2hud(H)
			H.s_active.show_to(H)
		return TRUE
	to_chat(H, "<span class='userdanger'>Unfortunately, you weren't able to get \a [initial(item_path.name)]. This is very bad and you should adminhelp immediately (press F1).</span>")
	return FALSE
