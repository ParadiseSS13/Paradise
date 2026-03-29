

/*
 * Simple helper to generate a string of
 * garbled symbols up to [length] characters.
 *
 * Used in creating spooky-text for heretic ascension announcements.
 */
/proc/generate_heretic_text(length = 25)
	if(!isnum(length)) // stupid thing so we can use this directly in replacetext
		length = 25
	. = ""
	for(var/i in 1 to length)
		. += pick("!", "$", "^", "@", "&", "#", "*", "(", ")", "?")

/// The heretic antagonist itself.
/datum/antagonist/heretic
	name = "\improper Heretic"
	roundend_category = "Heretics"

	job_rank = ROLE_HERETIC
	special_role = SPECIAL_ROLE_HERETIC
	antag_hud_name = "hudheretic"
	clown_gain_text = "Ancient knowledge described to you has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
	antag_hud_type = ANTAG_HUD_HERETIC

	/// Whether we've ascended! (Completed one of the final rituals)
	var/ascended = FALSE
	/// The path our heretic has chosen. Mostly used for flavor.
	var/heretic_path = PATH_START
	/// A sum of how many knowledge points this heretic CURRENTLY has. Used to research.
	var/knowledge_points = 1
	/// The time between gaining influence passively. The heretic gain +1 knowledge points every this duration of time.
	var/passive_gain_timer = 20 MINUTES
	/// Assoc list of [typepath] = [knowledge instance]. A list of all knowledge this heretic's reserached.
	var/list/researched_knowledge = list()
	/// The organ slot we place our Living Heart in.
	var/living_heart_organ_slot = "heart"
	/// A list of TOTAL how many sacrifices completed. (Includes high value sacrifices)
	var/total_sacrifices = 0
	/// A list of TOTAL how many high value sacrifices completed. (Heads of staff)
	var/high_value_sacrifices = 0
	/// Lazy assoc list of [refs to humans] to [image previews of the human]. Humans that we have as sacrifice targets.
	var/list/mob/living/carbon/human/sac_targets
	/// List of all sacrifice target's names, used for end of round report
	var/list/all_sac_targets = list()
	/// Whether we're drawing a rune or not
	var/drawing_rune = FALSE
	/// A static typecache of all tools we can scribe with.
	var/static/list/scribing_tools = typecacheof(list(/obj/item/pen, /obj/item/toy/crayon))
	/// A blacklist of turfs we cannot scribe on.
	var/static/list/blacklisted_rune_turfs = typecacheof(list(/turf/space, /turf/simulated/floor/lava, /turf/simulated/floor/chasm))
	/// Controls what types of turf we can spread rust to, increases as we unlock more powerful rust abilites
	var/rust_strength = 0
	/// Wether we are allowed to ascend
	var/feast_of_owls = FALSE
	/// Our research menu
	var/datum/action/heretic_menu/our_menu
	/// A list of all the monsters the heretic has active.
	var/list/list_of_our_monsters = list()
	/// The maximum mindslave limit. Applies to berserks as well
	var/mindslave_limit = 2
	/// What is the limit of monsters we can have as a heretic?
	var/monster_limit = 2
	/// Who do we currently have under our mindslavery?
	var/list/mindslaves = list()

	/// List that keeps track of which items have been gifted to the heretic after a cultist was sacrificed. Used to alter drop chances to reduce dupes.
	var/list/unlocked_heretic_items = list(
		/obj/item/melee/sickly_blade/cursed = 0,
		/obj/item/clothing/neck/heretic_focus/crimson_medallion = 0,
		/mob/living/simple_animal/hostile/construct/harvester/heretic = 0,
	)
	/// Simpler version of above used to limit amount of loot that can be hoarded
	var/rewards_given = 0
	/// A variable for admins to tweak to allow ascending.
	var/force_unlock_ascension = FALSE

/datum/antagonist/heretic/Destroy()
	LAZYNULL(sac_targets)
	return ..()


/datum/antagonist/heretic/add_owner_to_gamemode()
	SSticker.mode.heretics += owner

/datum/antagonist/heretic/remove_owner_from_gamemode()
	SSticker.mode.heretics -= owner

/datum/antagonist/heretic/add_antag_hud(mob/living/antag_mob)
	if(locate(/datum/objective/hijack) in owner.get_all_objectives())
		antag_hud_name = "hudheretichijack"
	return ..()

/datum/antagonist/heretic/proc/get_icon_of_knowledge(datum/heretic_knowledge/knowledge)
	//basic icon parameters
	var/icon_path = 'icons/mob/actions/actions_ecult.dmi'
	var/icon_state = "eye"
	var/icon_frame = knowledge.research_tree_icon_frame
	var/icon_dir = knowledge.research_tree_icon_dir
	//can't imagine why you would want this one, so it can't be overridden by the knowledge
	var/icon_moving = 0

	//item transmutation knowledge does not generate its own icon due to implementation difficulties, the icons have to be specified in the override vars

	//if the knowledge has a special icon, use that
	if(!isnull(knowledge.research_tree_icon_path))
		icon_path = knowledge.research_tree_icon_path
		icon_state = knowledge.research_tree_icon_state

	//if the knowledge is a spell, use the spell's button
	else if(ispath(knowledge, /datum/heretic_knowledge/spell))
		var/datum/heretic_knowledge/spell/spell_knowledge = knowledge
		var/datum/spell/result_action = spell_knowledge.action_to_add
		icon_path = result_action.action_background_icon
		icon_state = result_action.action_icon_state

	//if the knowledge is a summon, use the mob sprite
	else if(ispath(knowledge, /datum/heretic_knowledge/summon))
		var/datum/heretic_knowledge/summon/summon_knowledge = knowledge
		var/mob/living/result_mob = summon_knowledge.mob_to_summon
		icon_path = result_mob.icon
		icon_state = result_mob.icon_state

	//if the knowledge is an eldritch mark, use the mark sprite
	else if(ispath(knowledge, /datum/heretic_knowledge/mark))
		var/datum/heretic_knowledge/mark/mark_knowledge = knowledge
		var/datum/status_effect/eldritch/mark_effect = mark_knowledge.mark_type
		icon_path = mark_effect.effect_icon
		icon_state = mark_effect.effect_icon_state



	var/list/result_parameters = list()
	result_parameters["icon"] = icon_path
	result_parameters["state"] = icon_state
	result_parameters["frame"] = icon_frame
	result_parameters["dir"] = icon_dir
	result_parameters["moving"] = icon_moving
	return result_parameters

/datum/antagonist/heretic/proc/get_knowledge_data(datum/heretic_knowledge/knowledge, done)

	var/list/knowledge_data = list()

	knowledge_data["path"] = knowledge
	knowledge_data["icon_params"] = get_icon_of_knowledge(knowledge)
	knowledge_data["name"] = initial(knowledge.name)
	knowledge_data["gainFlavor"] = initial(knowledge.gain_text)
	knowledge_data["cost"] = initial(knowledge.cost)
	knowledge_data["disabled"] = (!done) && (initial(knowledge.cost) > knowledge_points)
	knowledge_data["bgr"] = GLOB.heretic_research_tree[knowledge][HKT_UI_BGR]
	knowledge_data["finished"] = done
	knowledge_data["ascension"] = ispath(knowledge,/datum/heretic_knowledge/ultimate)

	//description of a knowledge might change, make sure we are not shown the initial() value in that case
	if(done)
		var/datum/heretic_knowledge/knowledge_instance = researched_knowledge[knowledge]
		knowledge_data["desc"] = knowledge_instance.desc
	else
		knowledge_data["desc"] = initial(knowledge.desc)

	return knowledge_data

/datum/antagonist/heretic/ui_data(mob/user)
	var/list/data = list()

	data["charges"] = knowledge_points
	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended

	var/list/tiers = list()

	// This should be cached in some way, but the fact that final knowledge
	// has to update its disabled state based on whether all objectives are complete,
	// makes this very difficult. I'll figure it out one day maybe
	for(var/datum/heretic_knowledge/knowledge as anything in researched_knowledge)
		var/list/knowledge_data = get_knowledge_data(knowledge,TRUE)

		while(GLOB.heretic_research_tree[knowledge][HKT_DEPTH] > tiers.len)
			tiers += list(list("nodes"=list()))

		tiers[GLOB.heretic_research_tree[knowledge][HKT_DEPTH]]["nodes"] += list(knowledge_data)

	for(var/datum/heretic_knowledge/knowledge as anything in get_researchable_knowledge())
		var/list/knowledge_data = get_knowledge_data(knowledge, FALSE)

		// Final knowledge can't be learned until all objectives are complete.
		if(ispath(knowledge, /datum/heretic_knowledge/ultimate))
			knowledge_data["disabled"] ||= !can_ascend()

		while(GLOB.heretic_research_tree[knowledge][HKT_DEPTH] > tiers.len)
			tiers += list(list("nodes"=list()))

		tiers[GLOB.heretic_research_tree[knowledge][HKT_DEPTH]]["nodes"] += list(knowledge_data)

	data["knowledge_tiers"] = tiers

	return data

/datum/antagonist/heretic/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AntagInfoHeretic", name)
		ui.open()

/datum/antagonist/heretic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("research")
			var/datum/heretic_knowledge/researched_path = text2path(params["path"])
			if(!ispath(researched_path, /datum/heretic_knowledge))
				if(isnull(researched_path))
					CRASH("Heretic attempted to learn a non-existant path! (Got: [params["path"]])")
				CRASH("Heretic attempted to learn non-heretic_knowledge path! (Got: [researched_path])")


			if(!(researched_path in get_researchable_knowledge()))
				log_and_message_admins("attempted to href exploit to skip heretic progression! ([researched_path])")
				return FALSE

			if(ispath(researched_path, /datum/heretic_knowledge/ultimate) && !can_ascend())
				log_and_message_admins("attempted to href exploit to get the ascend ritual! ([researched_path])")
				return FALSE
			if(initial(researched_path.cost) > knowledge_points)
				return FALSE
			if(!gain_knowledge(researched_path))
				return FALSE

			log_heretic_knowledge("[key_name(owner)] gained knowledge: [initial(researched_path.name)]")
			knowledge_points -= initial(researched_path.cost)
			return TRUE

/datum/antagonist/heretic/ui_status(mob/user, datum/ui_state/state)
	if(user.stat == DEAD)
		return UI_CLOSE
	return ..()

/datum/antagonist/heretic/ui_state(mob/user)
	return GLOB.always_state

/datum/antagonist/heretic/on_gain()
	if(!GLOB.heretic_research_tree)
		GLOB.heretic_research_tree = generate_heretic_research_tree()
	our_menu = new()
	our_menu.Grant(owner.current)

	if(give_objectives)
		forge_primary_objectives()

	for(var/starting_knowledge in GLOB.heretic_start_knowledge)
		gain_knowledge(starting_knowledge)
	SEND_SOUND(owner.current, sound('sound/ambience/antag/heretic/heretic_gain.ogg'))


	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer) // Gain +1 knowledge every 20 minutes.
	return ..()

/datum/antagonist/heretic/farewell()
	if(!silent)
		to_chat(owner.current, SPAN_USERDANGER("Your mind begins to flare as the otherwordly knowledge escapes your grasp!"))
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(owner.current, src)
	our_menu.Remove(owner.current)

	QDEL_LIST_ASSOC_VAL(researched_knowledge)

	return ..()

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	our_mob.faction |= "heretic"

	if(!issilicon(our_mob))
		GLOB.reality_smash_track.add_tracked_mind(owner)
	var/datum/atom_hud/data/heretic/h_hud = GLOB.huds[DATA_HUD_HERETIC]
	h_hud.add_hud_to(our_mob)
	ADD_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, src.UID())
	RegisterSignal(our_mob, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(on_cult_sacrificed))
	RegisterSignal(our_mob, COMSIG_MOB_BEFORE_SPELL_CAST, PROC_REF(on_spell_cast))
	RegisterSignal(our_mob, COMSIG_INTERACT_USER, PROC_REF(on_item_use))

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	our_mob.faction -= "heretic"

	if(owner in GLOB.reality_smash_track.tracked_heretics)
		GLOB.reality_smash_track.remove_tracked_mind(owner)
	var/datum/atom_hud/data/heretic/h_hud = GLOB.huds[DATA_HUD_HERETIC]
	h_hud.remove_hud_from(our_mob)

	REMOVE_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, src.UID())
	UnregisterSignal(our_mob, list(
		COMSIG_MOB_BEFORE_SPELL_CAST,
		COMSIG_INTERACT_USER,
		COMSIG_LIVING_CULT_SACRIFICED,
	))

/datum/antagonist/heretic/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(old_body == new_body) // if they were using a temporary body
		return

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(old_body, src)
		knowledge.on_gain(new_body, src)

/*
 * Signal proc for [COMSIG_MOB_BEFORE_SPELL_CAST] and [COMSIG_MOB_SPELL_ACTIVATED].
 *
 * Checks if our heretic has [TRAIT_ALLOW_HERETIC_CASTING] or is ascended.
 * If so, allow them to cast like normal.
 * If not, cancel the cast, and returns [SPELL_CANCEL_CAST].
 */
/datum/antagonist/heretic/proc/on_spell_cast(mob/living/source, datum/spell/spell, show_message = TRUE)
	SIGNAL_HANDLER

	// Heretic spells are of the forbidden school, otherwise we don't care
	if(!spell.is_a_heretic_spell)
		return FALSE

	// We dont want to cast spells in the void
	if(istype(source.loc, /obj/effect/dummy/slaughter) && !istype(spell, /datum/spell/bloodcrawl/space_crawl))
		if(show_message)
			to_chat(source, SPAN_HIEROPHANT_WARNING("You cannot cast spells space phased!"))
		return SPELL_CANCEL_CAST

	// If we've got the trait, we don't care
	if(HAS_TRAIT(source, TRAIT_ALLOW_HERETIC_CASTING))
		return FALSE
	// All powerful, don't care
	if(ascended)
		return FALSE

	// We shouldn't be able to cast this! Cancel it.
	if(show_message)
		to_chat(source, SPAN_HIEROPHANT_WARNING("You need a focus to cast this spell!"))
	return SPELL_CANCEL_CAST

/*
 * Signal proc for [COMSIG_USER_ITEM_INTERACTION].
 *
 * If a heretic is holding a pen in their main hand,
 * and have mansus grasp active in their offhand,
 * they're able to draw a transmutation rune.
 */
/datum/antagonist/heretic/proc/on_item_use(mob/living/source, atom/target, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(!is_type_in_typecache(tool, scribing_tools))
		return NONE
	if(!isturf(target) || !isliving(source))
		return NONE

	var/obj/item/offhand = source.get_inactive_hand()
	if(QDELETED(offhand) || !istype(offhand, /obj/item/melee/touch_attack/mansus_fist))
		return NONE

	try_draw_rune(source, target, additional_checks = CALLBACK(src, PROC_REF(check_mansus_grasp_offhand), source))
	return ITEM_INTERACT_COMPLETE

/**
 * Attempt to draw a rune on [target_turf].
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/try_draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if(!isfloorturf(nearby_turf) || is_type_in_typecache(nearby_turf, blacklisted_rune_turfs))
			to_chat(user, SPAN_HIEROPHANT_WARNING("This is not a valid placement for a rune."))
			return

	if(locate(/obj/effect/heretic_rune) in range(3, target_turf))
		to_chat(user, SPAN_HIEROPHANT_WARNING("This is too close to another rune."))
		return

	if(drawing_rune)
		to_chat(user, SPAN_HIEROPHANT_WARNING("You are already drawing a rune."))
		return

	INVOKE_ASYNC(src, PROC_REF(draw_rune), user, target_turf, drawing_time, additional_checks)

/**
 * The actual process of drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	drawing_rune = TRUE

	var/rune_colour = GLOB.heretic_path_to_color[heretic_path]
	var/obj/effect/temp_visual/drawing_heretic_rune/drawing_effect
	if(drawing_time <= (10 SECONDS))
		drawing_effect = new /obj/effect/temp_visual/drawing_heretic_rune/fast(target_turf, rune_colour)
	else
		drawing_effect = new(target_turf, rune_colour)

	if(!do_after(user, drawing_time, target_turf, extra_checks = list(additional_checks)))
		new /obj/effect/temp_visual/drawing_heretic_rune/fail(target_turf, rune_colour)
		qdel(drawing_effect)
		drawing_rune = FALSE
		return
	to_chat(user, SPAN_HIEROPHANT("The rune is complete."))
	qdel(drawing_effect)
	new /obj/effect/heretic_rune/big(target_turf, rune_colour)
	drawing_rune = FALSE

/**
 * Callback to check that the user's still got their Mansus Grasp out when drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 */
/datum/antagonist/heretic/proc/check_mansus_grasp_offhand(mob/living/user)
	var/obj/item/offhand = user.get_inactive_hand()
	return !(!QDELETED(offhand) && istype(offhand, /obj/item/melee/touch_attack/mansus_fist))


/// Signal proc for [COMSIG_LIVING_CULT_SACRIFICED] to reward cultists for sacrificing a heretic
/datum/antagonist/heretic/proc/on_cult_sacrificed(mob/living/source, list/invokers)
	SIGNAL_HANDLER

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list) // uhh let's find the guy to shove him back in
		if((ghost.mind?.current == source) && ghost.client) // is it the same guy and do they have the same client
			ghost.reenter_corpse() // shove them in! it doesnt do it automatically

	// Drop all items and splatter them around messily.
	var/list/dustee_items = source.unequip_everything()
	for(var/obj/item/loot as anything in dustee_items)
		loot.throw_at(get_step_rand(source), 2, 4, pick(invokers), TRUE)

	// Create the blade, give it the heretic and a randomly-chosen master for the soul sword component
	var/obj/item/melee/cultblade/haunted/haunted_blade = new(get_turf(source), source, pick(invokers))

	// Cool effect for the rune as well as the item
	var/obj/effect/rune/convert/conversion_rune = locate() in get_turf(source)
	if(conversion_rune)
		conversion_rune.gender_reveal(
			outline_color = COLOR_HERETIC_GREEN,
			ray_color = null,
			do_float = FALSE,
			do_layer = FALSE,
		)

	haunted_blade.gender_reveal(outline_color = null, ray_color = COLOR_HERETIC_GREEN)

	for(var/mob/living/culto as anything in invokers)
		to_chat(culto, SPAN_CULTLARGE("\"A follower of the forgotten gods! You must be rewarded for such a valuable sacrifice.\""))

	// Locate a cultist team (Is there a better way??)
	var/mob/living/random_cultist = pick(invokers)
	var/datum/antagonist/cultist/antag = random_cultist.mind.has_antag_datum(/datum/antagonist/cultist)
	ASSERT(antag)
	var/datum/team/cult/cult_team = antag.get_team()

	// Unlock one of 3 special items!
	var/list/possible_unlocks
	for(var/i in cult_team.unlocked_heretic_items)
		if(cult_team.unlocked_heretic_items[i])
			continue
		LAZYADD(possible_unlocks, i)
	if(length(possible_unlocks))
		var/result = pick(possible_unlocks)
		cult_team.unlocked_heretic_items[result] = TRUE

		for(var/datum/mind/mind as anything in cult_team.members)
			if(mind.current)
				SEND_SOUND(mind.current, 'sound/magic/narsie_attack.ogg')
				to_chat(mind.current, SPAN_CULTLARGE("Arcane and forbidden knowledge floods your forges and archives. The cult has learned how to create the [result]!"))

	return SILENCE_SACRIFICE_MESSAGE|DUST_SACRIFICE

/**
 * Creates an animation of the item slowly lifting up from the floor with a colored outline, then slowly drifting back down.
 * Arguments:
 * * outline_color: Default is between pink and light blue, is the color of the outline filter.
 * * ray_color: Null by default. If not set, just copies outline. Used for the ray filter.
 * * anim_time: Total time of the animation. Split into two different calls.
 * * do_float: Lets you disable the sprite floating up and down.
 * * do_layer: Lets you disable the layering increase.
 */
/obj/proc/gender_reveal(
	outline_color = null,
	ray_color = null,
	anim_time = 10 SECONDS,
	do_float = TRUE,
	do_layer = TRUE,
)

	var/og_layer = layer
	if(do_layer)
		// Layering above to stand out!
		layer = ABOVE_MOB_LAYER

	// Slowly floats up, then slowly goes down.
	if(do_float)
		animate(src, pixel_y = 12, time = anim_time * 0.5, easing = QUAD_EASING | EASE_OUT)
		animate(pixel_y = 0, time = anim_time * 0.5, easing = QUAD_EASING | EASE_IN)

	// Adding a cool outline effect
	if(outline_color)
		add_filter("gender_reveal_outline", 3, list("type" = "outline", "color" = outline_color, "size" = 0.5))
		// Animating it!
		var/gay_filter = get_filter("gender_reveal_outline")
		animate(gay_filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
		animate(alpha = 40, time = 2.5 SECONDS)

	// Adding a cool ray effect
	if(ray_color)
		add_filter(name = "gender_reveal_ray", priority = 1, params = list(
				type = "rays",
				size = 45,
				color = ray_color,
				density = 6
			))
		// Animating it!
		var/ray_filter = get_filter("gender_reveal_ray")
		// I understand nothing but copypaste saves lives
		animate(ray_filter, offset = 100, time = 30 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(remove_gender_reveal_fx), og_layer), anim_time)

/**
 * Removes the non-animate effects from above proc
 */
/obj/proc/remove_gender_reveal_fx(og_layer)
	remove_filter(list("gender_reveal_outline", "gender_reveal_ray"))
	layer = og_layer

/**
 * Create our objectives for our heretic.
 */
/datum/antagonist/heretic/proc/forge_primary_objectives()
	var/datum/objective/heretic_research/research_objective = new()
	add_antag_objective(research_objective)

	var/num_heads = 0
	var/list/heads = SSticker.mode.get_all_heads()
	for(var/datum/mind/head in heads)
		if(ishuman(head.current))
			num_heads++

	var/datum/objective/minor_sacrifice/sac_objective = new()
	if(num_heads < 2) // They won't get major sacrifice, so bump up minor sacrifice a bit
		sac_objective.target_amount += 2
		sac_objective.update_explanation_text()
	add_antag_objective(sac_objective)

	if(num_heads >= 2)
		var/datum/objective/major_sacrifice/other_sac_objective = new()
		add_antag_objective(other_sac_objective)
	if(prob(5))
		add_antag_objective(/datum/objective/hijack)
	else
		add_antag_objective(/datum/objective/escape)

/**
 * Add [target] as a sacrifice target for the heretic.
 * Generates a preview image and associates it with a weakref of the mob.
 */
/datum/antagonist/heretic/proc/add_sacrifice_target(mob/living/carbon/human/target)

	var/image/target_image = image(icon = target.icon, icon_state = target.icon_state)
	target_image.overlays = target.overlays

	LAZYSET(sac_targets, target, target_image)
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_deleted))
	all_sac_targets += target.real_name

/**
 * Removes [target] from the heretic's sacrifice list.
 * Returns FALSE if no one was removed, TRUE otherwise
 */
/datum/antagonist/heretic/proc/remove_sacrifice_target(mob/living/carbon/human/target)
	if(!(target in sac_targets))
		return FALSE

	LAZYREMOVE(sac_targets, target)
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	return TRUE

/**
 * Signal proc for [COMSIG_PARENT_QDELETING] registered on sac targets
 * if sacrifice targets are deleted (gibbed, dusted, whatever), free their slot and reference
 */
/datum/antagonist/heretic/proc/on_target_deleted(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(owner.current)
	var/mob/living/new_target = reroll_target(owner.current, heretic_datum, source)
	if(new_target)
		to_chat(owner.current, SPAN_HIEROPHANT("We feel that [source] has gone beyond our reach. Our new sacrifice target is: [new_target]"))
	else
		to_chat(owner.current, SPAN_HIEROPHANT("We feel that [source] has gone beyond our reach, and we were unable to find a new target."))
	SEND_SOUND(owner.current, sound('sound/ambience/alarm4.ogg'))
	remove_sacrifice_target(source)

/datum/antagonist/heretic/proc/reroll_target(mob/living/user, datum/antagonist/heretic/heretic_datum, mob/living/target)
	var/datum/heretic_knowledge/hunt_and_sacrifice/knowledge = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	var/list/datum/mind/valid_targets = list()
	for(var/datum/mind/possible_target as anything in SSticker.minds)
		if(possible_target == user.mind)
			continue
		if(!possible_target.assigned_role)
			continue
		if(is_invalid_target(possible_target))
			continue
		if(knowledge && (possible_target in knowledge.target_blacklist))
			continue
		if(!ishuman(possible_target.current))
			continue
		if(possible_target.current in heretic_datum.sac_targets)
			continue
		if(possible_target.current.stat == DEAD)
			continue

		valid_targets += possible_target

	if(!valid_targets)
		return FALSE

	if(target && (target.mind.assigned_role in GLOB.command_head_positions))
		for(var/datum/mind/head_mind as anything in shuffle(valid_targets))
			if(head_mind.assigned_role in GLOB.command_head_positions)
				heretic_datum.add_sacrifice_target(head_mind.current)
				return head_mind.current

	if(target && (target.mind.assigned_role in GLOB.active_security_positions))
		for(var/datum/mind/sec_mind as anything in shuffle(valid_targets))
			if(sec_mind.assigned_role in GLOB.active_security_positions)
				heretic_datum.add_sacrifice_target(sec_mind.current)
				return sec_mind.current

	// just grab literally anyone else
	var/datum/mind/random_mind = pick(valid_targets)
	heretic_datum.add_sacrifice_target(random_mind.current)
	return random_mind


/**
 * Increments knowledge by one.
 * Used in callbacks for passive gain over time.
 */
/datum/antagonist/heretic/proc/passive_influence_gain()
	knowledge_points++
	if(owner.current.stat == CONSCIOUS)
		to_chat(owner.current, SPAN_HEAR("You hear a whisper... <span class='hierophant'>[pick_list(HERETIC_INFLUENCE_FILE, "drain_message")]"))
	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer)

/datum/game_mode/proc/auto_declare_completion_heretic()
	if(!length(heretics))
		log_debug("There are no heretics")
		return

	var/list/text = list("<br><font size=3>[SPAN_BOLD("The heretics were:")]</font>")
	for(var/datum/mind/heretic in heretics)
		var/datum/antagonist/heretic/heretic_datum = heretic.has_antag_datum(/datum/antagonist/heretic)
		// Skip heretic monster summons.
		if(!heretic_datum)
			continue
		text += "<br>[heretic.get_display_key()] was [heretic.name] ("
		if(heretic.current)
			if(heretic.current.stat == DEAD)
				text += "died"
			else
				text += "survived"
		else
			text += "body destroyed"
		text += ")"
		text += "<br><b>Sacrifices Made:</b> [heretic_datum.total_sacrifices]"
		text += "<br>The heretic's sacrifice targets were: [english_list(heretic_datum.all_sac_targets, nothing_text = "No one")]."
		var/list/all_objectives = heretic.get_all_objectives()

		if(length(all_objectives)) // If the traitor had no objectives, don't need to process this.
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				text += "<br><b>Objective #[count]</b>: [objective.explanation_text]</b></font>"
				count++
		if(heretic_datum.feast_of_owls)
			text += SPAN_GREENTEXT("<br>Ascension Forsaken")
		if(heretic_datum.ascended)
			text += SPAN_HIEROPHANT_WARNING("<br>THE HERETIC ASCENDED!")

		text += "<br><b>Knowledge Researched:</b> "

		var/list/string_of_knowledge = list()

		for(var/knowledge_index in heretic_datum.researched_knowledge)
			var/datum/heretic_knowledge/knowledge = heretic_datum.researched_knowledge[knowledge_index]
			string_of_knowledge += knowledge.name

		text += english_list(string_of_knowledge)

	return text.Join("")


/**
 * Admin proc for giving a heretic a Living Heart easily.
 */
/datum/antagonist/heretic/proc/give_living_heart(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, SPAN_WARNING("You shouldn't be using this!"))
		return

	var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
	if(!heart_knowledge)
		to_chat(admin, SPAN_WARNING("The heretic doesn't have a living heart knowledge for some reason. What?"))
		return

	heart_knowledge.on_research(owner.current, src)


/**
 * Admin proc for removing a mob from a heretic's sac list.
 */
/datum/antagonist/heretic/proc/remove_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, SPAN_WARNING("You shouldn't be using this!"))
		return

	var/list/removable = list()
	for(var/mob/living/carbon/human/old_target as anything in sac_targets)
		removable[old_target.name] = old_target

	var/name_of_removed = tgui_input_list(admin, "Choose a human to remove", "Who to Spare", removable)
	if(QDELETED(src) || !admin.client?.holder || isnull(name_of_removed))
		return
	var/mob/living/carbon/human/chosen_target = removable[name_of_removed]
	if(QDELETED(chosen_target) || !ishuman(chosen_target))
		return

	if(!remove_sacrifice_target(chosen_target))
		to_chat(admin, SPAN_WARNING("Failed to remove [name_of_removed] from [owner]'s sacrifice list. Perhaps they're no longer in the list anyways."))
		return

	if(tgui_alert(admin, "Let them know their targets have been updated?", "Whispers of the Mansus", list("Yes", "No")) == "Yes")
		to_chat(owner.current, SPAN_DANGER("The Mansus has modified your targets."))

/**
 * Admin proc for easily adding / removing knowledge points.
 */
/datum/antagonist/heretic/proc/admin_change_points(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, SPAN_WARNING("You shouldn't be using this!"))
		return

	var/change_num = tgui_input_number(admin, "Add or remove knowledge points", "Points", 0, 100, -100)
	if(!change_num || QDELETED(src))
		return

	knowledge_points += change_num

/**
 * Admin proc for giving a heretic a focus.
 */
/datum/antagonist/heretic/proc/admin_give_focus(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, SPAN_WARNING("You shouldn't be using this!"))
		return

	var/mob/living/pawn = owner.current
	pawn.equip_to_slot_if_possible(new /obj/item/clothing/neck/heretic_focus(get_turf(pawn)), ITEM_SLOT_NECK, TRUE, TRUE)
	to_chat(pawn, SPAN_HIEROPHANT_WARNING("The Mansus has manifested you a focus."))


/**
 * Learns the passed [typepath] of knowledge, creating a knowledge datum
 * and adding it to our researched knowledge list.
 *
 * Returns TRUE if the knowledge was added successfully. FALSE otherwise.
 */
/datum/antagonist/heretic/proc/gain_knowledge(datum/heretic_knowledge/knowledge_type)
	if(!ispath(knowledge_type))
		stack_trace("[type] gain_knowledge was given an invalid path! (Got: [knowledge_type])")
		return FALSE
	if(get_knowledge(knowledge_type))
		return FALSE
	var/datum/heretic_knowledge/initialized_knowledge = new knowledge_type()
	researched_knowledge[knowledge_type] = initialized_knowledge
	initialized_knowledge.on_research(owner.current, src)
	SStgui.update_uis(src)
	return TRUE

/**
 * Get a list of all knowledge TYPEPATHS that we can currently research.
 */
/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		researchable_knowledge |= GLOB.heretic_research_tree[knowledge_index][HKT_NEXT]
		banned_knowledge |= GLOB.heretic_research_tree[knowledge_index][HKT_BAN]
		banned_knowledge |= knowledge.type
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/**
 * Check if the wanted type-path is in the list of research knowledge.
 */
/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

/// Makes our heretic more able to rust things.
/// if side_path_only is set to TRUE, this function does nothing for rust heretics.
/datum/antagonist/heretic/proc/increase_rust_strength(side_path_only=FALSE)
	if(side_path_only && get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_rust))
		return

	rust_strength++

/**
 * Get a list of all rituals this heretic can invoke on a rune.
 * Iterates over all of our knowledge and, if we can invoke it, adds it to our list.
 *
 * Returns an associated list of [knowledge name] to [knowledge datum] sorted by knowledge priority.
 */
/datum/antagonist/heretic/proc/get_rituals()
	var/list/rituals = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(!knowledge.can_be_invoked(src))
			continue
		rituals[knowledge.name] = knowledge

	return sortTim(rituals, GLOBAL_PROC_REF(cmp_heretic_knowledge), associative = TRUE)

/**
 * Checks to see if our heretic can currently ascend.
 *
 * Returns FALSE if not all of our objectives are complete, or TRUE otherwise.
 */
/datum/antagonist/heretic/proc/can_ascend()
	if(force_unlock_ascension)
		return TRUE
	if(feast_of_owls)
		return FALSE // We sold our ambition for immediate power :/
	var/has_hijack = FALSE
	for(var/datum/objective/must_be_done as anything in owner.get_all_objectives(include_team = FALSE))
		if(istype(must_be_done, /datum/objective/hijack) || SSticker.cult_tried_summon)
			has_hijack = TRUE
			continue
		if(istype(must_be_done, /datum/objective/escape))
			continue
		if(!must_be_done.check_completion())
			return FALSE
	return has_hijack

/**
 * Helper to determine if a Heretic
 * - Has a Living Heart
 * - Has a an organ in the correct slot that isn't a living heart
 * - Is missing the organ they need in the slot to make a living heart
 *
 * Returns HERETIC_NO_HEART_ORGAN if they have no heart (organ) at all,
 * Returns HERETIC_NO_LIVING_HEART if they have a heart (organ) but it's not a living one,
 * and returns HERETIC_HAS_LIVING_HEART if they have a living heart
 */
/datum/antagonist/heretic/proc/has_living_heart()
	var/obj/item/organ/our_living_heart = owner.current?.get_organ_slot(living_heart_organ_slot)
	if(!our_living_heart)
		return HERETIC_NO_HEART_ORGAN

	if(!HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		return HERETIC_NO_LIVING_HEART

	return HERETIC_HAS_LIVING_HEART

/// Heretic's minor sacrifice objective. "Minor sacrifices" includes anyone.
/datum/objective/minor_sacrifice
	name = "minor sacrifice"
	needs_target = FALSE

/datum/objective/minor_sacrifice/New()
	target_amount = rand(3, 4)
	update_explanation_text()
	return ..()

/datum/objective/minor_sacrifice/update_explanation_text()
	explanation_text = "Sacrifice at least [target_amount] crewmembers."

/datum/objective/minor_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (heretic_datum.total_sacrifices >= target_amount)

/// Heretic's major sacrifice objective. "Major sacrifices" are heads of staff.
/datum/objective/major_sacrifice
	name = "major sacrifice"
	target_amount = 1
	explanation_text = "Sacrifice 1 head of staff."
	needs_target = FALSE

/datum/objective/major_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (heretic_datum.high_value_sacrifices >= target_amount)

/// Heretic's research objective. "Research" is heretic knowledge nodes (You start with some).
/datum/objective/heretic_research
	name = "research"
	needs_target = FALSE
	/// The length of a main path. Calculated once in New().
	var/static/main_path_length = 0

/datum/objective/heretic_research/New()
	gen_amount_goal()
	return ..()

/datum/objective/heretic_research/proc/gen_amount_goal()
	if(!main_path_length)
		// Let's find the length of a main path. We'll use rust because it's the coolest.
		// (All the main paths are (should be) the same length, so it doesn't matter.)
		var/rust_paths_found = 0
		for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
			if(GLOB.heretic_research_tree[knowledge][HKT_ROUTE] == PATH_RUST)
				rust_paths_found++

		main_path_length = rust_paths_found

	// Factor in the length of the main path first.
	target_amount = main_path_length
	// Add in the base research we spawn with, otherwise it'd be too easy.
	target_amount += length(GLOB.heretic_start_knowledge)
	// And add in some buffer, to require some sidepathing, especially since heretics get some free side paths.
	target_amount += rand(2, 4)
	update_explanation_text()
	return target_amount

/datum/objective/heretic_research/update_explanation_text()
	explanation_text = "Research at least [target_amount] knowledge from the Mansus. You start with [length(GLOB.heretic_start_knowledge)] researched."

/datum/objective/heretic_research/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (length(heretic_datum.researched_knowledge) >= target_amount)

/datum/objective/heretic_summon
	name = "summon monsters"
	target_amount = 2
	explanation_text = "Summon 2 monsters from the Mansus into this realm. Monsters created or converted from corpses will do not count towards this objective."
	needs_target = FALSE
	/// The total number of summons the objective owner has done
	var/num_summoned = 0

/datum/objective/heretic_summon/check_completion()
	return completed || (num_summoned >= target_amount)

/datum/action/heretic_menu
	name = "Info And Research"
	desc = "Learn about the mansus and research your path"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	background_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "book"
	background_icon_state = "bg_heretic"

/datum/action/heretic_menu/Trigger(left_click)
	var/mob/living/L = owner
	var/datum/antagonist/heretic = IS_HERETIC(L)
	if(heretic)
		heretic.ui_interact(L)

