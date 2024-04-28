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
	var/mob/living/carbon/human/orig

/mob/camera/paradox/Login()
	..()
	to_chat(src, "<span class='danger'>Something is wrong with your body.. What is happening? Everything looks so familiar and not at the same time...</span>")
	to_chat(src, "<span class='danger'>You are unstable, as if you are about to be transported to another universe very soon!</span>")
	to_chat(src, "<span class='danger'>Quick! Find some remote and lonely place</span>")

/mob/camera/paradox/say(message)
	return

/mob/camera/paradox/proc/warning()
	to_chat(src, "<span class='biggerdanger'>Ten seconds left.</span>")

/mob/camera/paradox/proc/expire()
	if(!orig)
		to_chat(src, "<span class='biggerdanger'>The Original disappeared... Aborting...</span>")
		qdel(src)
		return

	var/list/main_objectives = list("Kill" = 8, "Protect" = 2)
	var/list/escape_objectives = list("Escape" = 5, "Survive" = 5)

	var/datum/spell/paradox_spell/objective_spell

	do_sparks(rand(1, 2), FALSE, get_turf(src))
	var/mob/living/carbon/human/clone = do_clone(orig, src)
	clone.set_nutrition(NUTRITION_LEVEL_FULL)

	var/mob/camera/paradox/no = src

	var/mob/dead/observer/G = no.ghostize()
	qdel(no)

	clone.key = G.key

	clone.mind.add_antag_datum(/datum/antagonist/paradox_clone)
	qdel(src)
	var/datum/antagonist/paradox_clone/pc = clone.mind.has_antag_datum(/datum/antagonist/paradox_clone)
	pc.original = orig

	if(orig.mind.martial_art)
		for(var/datum/martial_art/MA as anything in orig.mind.known_martial_arts)
			MA.teach(pc.owner.current)

	if(orig.mind.spell_list)
		for(var/datum/spell/S as anything in orig.mind.spell_list)
			if(istype(S, /datum/spell/vampire))
				continue
			pc.owner.AddSpell(S)
			pc.owner.spell_list += S

	if(length(orig.mind.job_objectives))
		pc.owner.job_objectives += orig.mind.job_objectives

	var/obj/item/organ/internal/body_egg/egg = pc.owner.current.get_int_organ(/obj/item/organ/internal/body_egg) //OH NO WHY I AM ALREADY INFESTED WITH XENOMORPH EGG!??!??
	if(egg)
		egg.remove(pc.owner.current)
		qdel(egg)

	pc.owner.current.reagents.add_reagent("mutadone", 1)
	for(var/datum/disease/D in pc.owner.current.viruses) //OH NO WHY I AM ALREADY INFESTED WITH GBS
		D.cure()

	pc.owner.miming = orig.mind.miming

	pc.owner.memory = orig.mind.memory

	pc.owner.isblessed = orig.mind.isblessed
	pc.owner.num_blessed = orig.mind.num_blessed

	if(orig.mind.assigned_role)
		pc.owner.assigned_role = orig.mind.assigned_role

	if(orig.mind.role_alt_title)
		pc.owner.role_alt_title = orig.mind.role_alt_title

	if(orig.mind.initial_account)
		pc.owner.initial_account = orig.mind.initial_account

	if(orig.mind.learned_recipes)
		pc.owner.learned_recipes = orig.mind.learned_recipes

	var/mob/living/carbon/human/para = pc.owner.current

	for(var/obj/item/organ/internal/I in para.internal_organs)
		I.heal_internal_damage(400) //I'm not using rejuvenate cus it can break some things

	if(para.wear_id)
		var/obj/item/card/id/W = para.wear_id
		W.owner_ckey = para.key

	if(orig.mind.assigned_role == "Clown")
		var/datum/outfit/job/clown/clo = new()
		clo.post_equip(clone, FALSE)
		pc.handle_clown_mutation(para, granting_datum = TRUE)

	var/main_objective = pickweight(main_objectives)

	var/escape_objective = pickweight(escape_objectives)

	if(main_objective == "Kill")
		var/datum/objective/paradox_replace/kill = new()
		make_owner_and_target(kill, pc, orig.mind)
		pc.add_antag_objective(kill)
		objective_spell = /datum/spell/paradox_spell/click_target/replace

	if(main_objective == "Protect")
		var/datum/objective/protect/paradox_shield = new()
		make_owner_and_target(paradox_shield, pc, orig.mind)
		paradox_shield.explanation_text += " Check your ability 'United Bonds'. It can help you with this objective."
		pc.add_antag_objective(paradox_shield)
		objective_spell = /datum/spell/paradox_spell/self/united_bonds //yes, I know this power is kinda useless, but I love even numbers and sometimes it can help...

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	if(escape_objective == "Escape")
		var/datum/objective/escape/esc = new()
		esc.owner = pc.owner
		pc.add_antag_objective(esc)

	if(escape_objective == "Survive")
		var/datum/objective/survive/minecraft_mode = new()
		minecraft_mode.owner = pc.owner
		pc.add_antag_objective(minecraft_mode)

	pc.owner.objective_holder.objective_owner = pc.owner

	pc.owner.AddSpell(new objective_spell(pc.owner.current))
	pc.owner.spell_list += objective_spell
	pc.current_powers += objective_spell

	var/list/messages = list()
	messages.Add("<span class='userdanger'>You are a Paradox Clone!</span>")
	messages.Add(pc.greet())
	messages.Add(pc.owner.prepare_announce_objectives())
	messages.Add("<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/[pc.wiki_page_name])</span>")

	to_chat(pc.owner.current, chat_box_red(messages.Join("<br>")))

	var/datum/language/paradox/P = new()
	to_chat(pc.owner.current, "<span class='danger'><B><center>Use :[P.key] to commune with other paradox clones.</center></b></span>")

	var/datum/status_effect/internal_pinpointer/paradox_stalking/PS = para.apply_status_effect(/datum/status_effect/internal_pinpointer/paradox_stalking)
	PS.target_brain = orig.get_int_organ(/obj/item/organ/internal/brain)

	addtimer(CALLBACK(SSjobs, TYPE_PROC_REF(/datum/controller/subsystem/jobs, show_location_blurb), pc.owner.current.client, pc.owner), 1 SECONDS)

/mob/camera/paradox/proc/make_owner_and_target(datum/objective/O, datum/antagonist/paradox_clone/pc, datum/mind/orig)
	O.owner = pc.owner
	if(orig)
		O.target = orig

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
		//P.ttone = "interference" I decided to avoid meta like secs asking everyone to see their pda beeps
		P.start_program(P.find_program(/datum/data/pda/app/main_menu))
		P.owner = paradox_clone

		var/datum/data/pda/app/messenger/M = P.find_program(/datum/data/pda/app/messenger)
		if(M)
			M.m_hidden = 1

	if(paradox_clone.wear_id)
		var/obj/item/card/id/W = paradox_clone.wear_id
		var/obj/item/card/id/HW = H.wear_id
		W.photo = get_id_photo(paradox_clone) //for some reason after serializing ID doesn't have a photo in it.
		W.mining_points = HW.mining_points
		W.total_mining_points = HW.total_mining_points
		W.assignment = HW.assignment
		W.rank = HW.rank
		W.owner_uid = paradox_clone.UID()

	H.update_icons()

	return paradox_clone

/mob/camera/paradox/Move(NewLoc, Dir = 0) //can't leave station Z
	if(istype(get_area(NewLoc), /area/station))
		loc = NewLoc
	else
		return FALSE
