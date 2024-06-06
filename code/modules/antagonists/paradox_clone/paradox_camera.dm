/mob/camera/paradox
	name = "Paradox"
	invisibility = INVISIBILITY_OBSERVER
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	see_in_dark = 12
	icon = 'icons/effects/effects.dmi'
	icon_state = "static"
	alpha = 120
	var/live_span = 40 SECONDS
	var/alive_time = 0 SECONDS
	var/mob/living/carbon/human/the_original

/mob/camera/paradox/Login()
	..()
	to_chat(src, "<span class='danger'>Something is wrong with your body.. What is happening? Everything looks so familiar and not at the same time...</span>")
	to_chat(src, "<span class='danger'>You are unstable, as if you are about to be transported to another universe very soon!</span>")
	to_chat(src, "<span class='danger'>Quick! Find some remote and lonely place!</span>")

/mob/camera/paradox/say(message)
	return

/mob/camera/paradox/proc/warning()
	to_chat(src, "<span class='biggerdanger'>Ten seconds left.</span>")

/mob/camera/paradox/proc/expire()
	if(!the_original)
		to_chat(src, "<span class='biggerdanger'>The Original disappeared... Aborting...</span>")
		qdel(src)
		return

	var/list/main_objectives = list("Kill" = 9, "Protect" = 1)
	var/list/escape_objectives = list("Escape" = 4, "Survive" = 6)

	var/datum/spell/paradox_spell/objective_spell

	do_sparks(rand(1, 2), FALSE, get_turf(src))
	var/mob/living/carbon/human/clone = do_clone(the_original, src)
	clone.set_nutrition(NUTRITION_LEVEL_FULL)

	var/mob/camera/paradox/the_camera = src

	var/mob/dead/observer/G = the_camera.ghostize()
	qdel(the_camera)

	clone.key = G.key

	clone.mind.add_antag_datum(/datum/antagonist/paradox_clone)
	qdel(src)
	var/datum/antagonist/paradox_clone/para_clone_datum = clone.mind.has_antag_datum(/datum/antagonist/paradox_clone)
	var/mob/living/carbon/human/para = para_clone_datum.owner.current
	var/datum/mind/para_mind = para_clone_datum.owner
	para_clone_datum.original = the_original

	if(the_original.mind.martial_art)
		for(var/datum/martial_art/MA as anything in the_original.mind.known_martial_arts)
			if(!istype(MA, /datum/martial_art/krav_maga) || !istype(MA, /datum/martial_art/judo))
				MA.teach(para_mind.current)

	if(the_original.mind.spell_list)
		for(var/datum/spell/S as anything in the_original.mind.spell_list)
			if(istype(S, /datum/spell/vampire))
				return
			para_mind.AddSpell(S)
			para_mind.spell_list += S

	if(length(the_original.mind.job_objectives))
		para_mind.job_objectives += the_original.mind.job_objectives

	var/obj/item/organ/internal/body_egg/egg = para_mind.current.get_int_organ(/obj/item/organ/internal/body_egg) // OH NO WHY I AM ALREADY INFESTED WITH XENOMORPH EGG!??!??
	if(egg)
		egg.remove(para_mind.current)
		qdel(egg)

	para_mind.current.reagents.add_reagent("mutadone", 1)
	for(var/datum/disease/D in para_mind.current.viruses) // OH NO WHY I AM ALREADY INFESTED WITH GBS
		D.cure()

	para_mind.miming = the_original.mind.miming

	para_mind.memory = the_original.mind.memory

	para_mind.isblessed = the_original.mind.isblessed
	para_mind.num_blessed = the_original.mind.num_blessed

	if(the_original.mind.assigned_role)
		para_mind.assigned_role = the_original.mind.assigned_role

	if(the_original.mind.role_alt_title)
		para_mind.role_alt_title = the_original.mind.role_alt_title

	if(the_original.mind.initial_account)
		para_mind.initial_account = the_original.mind.initial_account

	if(the_original.mind.learned_recipes)
		para_mind.learned_recipes = the_original.mind.learned_recipes

	for(var/obj/item/organ/internal/I in para.internal_organs)
		I.heal_internal_damage(400) // I'm not using rejuvenate cus it can break some things

	if(para.wear_id)
		var/obj/item/card/id/W = para.wear_id
		W.owner_ckey = para.key

	if(the_original.mind.assigned_role == "Clown")
		var/datum/outfit/job/clown/clo = new()
		clo.post_equip(clone, FALSE)
		para_clone_datum.handle_clown_mutation(para, granting_datum = TRUE)

	var/main_objective = pickweight(main_objectives)

	var/escape_objective = pickweight(escape_objectives)

	if(main_objective == "Kill")
		var/datum/objective/paradox_replace/kill = new()
		make_owner_and_target(kill, para_clone_datum, the_original.mind)
		para_clone_datum.add_antag_objective(kill)
		objective_spell = /datum/spell/paradox_spell/click_target/replace

	if(main_objective == "Protect")
		var/datum/objective/protect/paradox_shield = new()
		make_owner_and_target(paradox_shield, para_clone_datum, the_original.mind)
		paradox_shield.explanation_text += " Check your ability 'United Bonds'. It can help you with this objective."
		para_clone_datum.add_antag_objective(paradox_shield)
		objective_spell = /datum/spell/paradox_spell/self/united_bonds // yes, I know this power is kinda useless, but I love even numbers and sometimes it can help...

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	if(escape_objective == "Escape")
		var/datum/objective/escape/esc = new()
		esc.owner = para_mind
		para_clone_datum.add_antag_objective(esc)

	if(escape_objective == "Survive")
		var/datum/objective/survive/minecraft_mode = new()
		minecraft_mode.owner = para_mind
		para_clone_datum.add_antag_objective(minecraft_mode)

	para_mind.objective_holder.objective_owner = para_mind

	para_mind.AddSpell(new objective_spell(para_mind.current))
	para_mind.spell_list += objective_spell
	para_clone_datum.current_powers += objective_spell

	var/list/messages = list()
	messages.Add("<span class='userdanger'>You are a Paradox Clone!</span>")
	messages.Add(para_clone_datum.greet())
	messages.Add(para_mind.prepare_announce_objectives())
	messages.Add("<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/[para_clone_datum.wiki_page_name])</span>")

	to_chat(para, chat_box_red(messages.Join("<br>")))

#define NANOTRASEN 1
#define SYNDICATE 2

	var/datum/language/paradox/P = new()
	to_chat(para, "<span class='danger'><b><center>Use [P.key] to commune with other paradox clones.</center></b></span>")
	if(findtextEx(para_clone_datum.paradox_id, "Agent"))
		var/static/list/slots = list(
			"backpack" = SLOT_HUD_IN_BACKPACK,
			"left pocket" = SLOT_HUD_LEFT_STORE,
			"right pocket" = SLOT_HUD_RIGHT_STORE,
			"left hand" = SLOT_HUD_LEFT_HAND,
			"right hand" = SLOT_HUD_RIGHT_HAND,
		)

		var/obj/item/encryptionkey/key
		to_chat(para, "<span class='danger'><center>Welcome, [para_clone_datum.paradox_id].</center></span>")
		var/employer = rand(1,2)
		switch(employer)
			if(NANOTRASEN)
				to_chat(para, "<span class='warning'><center>We have discovered that someone does not meet our expectations in another universe. Replace them.</center></span>")
				to_chat(para, "<span class='warning'><center>NanoTrasen has given you an encryption key with access to all channels.</center></span>")
				key = new /obj/item/encryptionkey/heads/captain(para)
			if(SYNDICATE)
				to_chat(para, "<span class='warning'><center>It's time to help our partners from another universe.</center></span>")
				to_chat(para, "<span class='warning'><center>Syndicate has given you an encryption key.</center></span>")
				key = new /obj/item/encryptionkey/syndicate(para)

		para.equip_in_one_of_slots(key, slots)

#undef NANOTRASEN
#undef SYNDICATE

	var/datum/status_effect/internal_pinpointer/paradox_stalking/PS = para.apply_status_effect(/datum/status_effect/internal_pinpointer/paradox_stalking)
	PS.target_brain = the_original.get_int_organ(/obj/item/organ/internal/brain)

	addtimer(CALLBACK(SSjobs, TYPE_PROC_REF(/datum/controller/subsystem/jobs, show_location_blurb), para.client, para_mind), 1 SECONDS)

/mob/camera/paradox/proc/make_owner_and_target(datum/objective/O, datum/antagonist/paradox_clone/pc, datum/mind/orig)
	O.owner = pc.owner
	if(orig)
		O.target = orig

	O.update_explanation_text()

/atom/movable/screen/alert/status_effect/internal_pinpointer/paradox_stalking/Click()
	if(attached_effect)
		var/datum/status_effect/internal_pinpointer/paradox_stalking/PS = attached_effect
		var/list/allowed_targets = list()
		var/mob/living/carbon/human/P = usr
		var/datum/antagonist/paradox_clone/para_clone_datum = P.mind.has_antag_datum(/datum/antagonist/paradox_clone)
		var/mob/living/carbon/human/para = para_clone_datum.owner.current
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			var/obj/item/organ/internal/brain/HB = H.get_int_organ(/obj/item/organ/internal/brain)
			if(H.z == P.z && H.mind && H.key && P != H && HB && H != PS.owner && H || is_paradox_clone(H) || H == para_clone_datum.original)
				allowed_targets += H
		if(!length(allowed_targets))
			to_chat(para, "<span class='notice'><b>No available targets.</b></span>")
			if(tgui_alert(P, "No available targets. Do you want to hide the alert?", "No targets.", list("Yes", "No")) == "Yes")
				src.icon_state = "null"
				to_chat(P, "<span class='notice'><b>To unhide the pinpointer, click on the empty space where it was previously located.</b></span>")
			return
		var/mob/living/carbon/human/target = input(usr,"Select target to track","Pinpointer") in allowed_targets
		if(target)
			var/obj/item/organ/internal/brain/B = target.get_int_organ(/obj/item/organ/internal/brain)
			if(!B)
				to_chat(para, "<span class='notice'>[target.real_name] doesn't have a brain! Can't sense...</b></span>")
				return
			icon_state = "pinon"
			PS.target_brain = B
	..()

/mob/camera/paradox/proc/do_clone(mob/living/carbon/human/H)
	var/mob/living/carbon/human/paradox_clone = new /mob/living/carbon/human(get_turf(src))
	var/orig_species = H.dna.species
	paradox_clone.set_species(orig_species)
	paradox_clone.change_gender(H.gender, TRUE)

	H.languages = paradox_clone.languages

	H.active_mutations = paradox_clone.active_mutations
	var/datum/dna/orig_dna = H.dna.Clone()

	paradox_clone.dna = orig_dna

	paradox_clone.heal_overall_damage(400, 400)
	for(var/obj/item/organ/internal/I in paradox_clone.internal_organs)
		I.heal_internal_damage(600)
		if(!(I.status & ORGAN_ROBOT))
			I.status |= 0
			I.germ_level = 0

	var/list/orig_data = H.serialize()
	paradox_clone.deserialize(orig_data)

	if(paradox_clone.w_uniform)
		var/obj/item/clothing/under/U = paradox_clone.w_uniform
		U.sensor_mode = SENSOR_OFF
		if(H.w_uniform)
			U.accessories = H.w_uniform.accessories

	if(paradox_clone.wear_pda)
		var/obj/item/pda/P = paradox_clone.wear_pda
		P.silent = TRUE
		P.start_program(P.find_program(/datum/data/pda/app/main_menu))
		P.owner = paradox_clone

		var/datum/data/pda/app/messenger/M = P.find_program(/datum/data/pda/app/messenger)
		if(M)
			M.m_hidden = 1

	if(paradox_clone.wear_id)
		var/obj/item/card/id/W = paradox_clone.wear_id
		var/obj/item/card/id/HW = H.wear_id
		W.photo = get_id_photo(paradox_clone) // for some reason after serializing ID doesn't have a photo in it.
		W.mining_points = HW.mining_points
		W.total_mining_points = HW.total_mining_points
		W.assignment = HW.assignment
		W.rank = HW.rank
		W.owner_uid = paradox_clone.UID()

	H.update_icons()

	return paradox_clone

/mob/camera/paradox/Move(NewLoc, Dir = 0) // can't leave station Z
	if(istype(get_area(NewLoc), /area/station))
		loc = NewLoc
	else
		return FALSE
