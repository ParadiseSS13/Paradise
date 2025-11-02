// Heretic starting knowledge.

/// Global list of all heretic knowledge that have is_starting_knowledge = TRUE. List of PATHS.
GLOBAL_LIST_INIT(heretic_start_knowledge, initialize_starting_knowledge())

/**
 * Returns a list of all heretic knowledge TYPEPATHS
 * that have route set to PATH_START.
 */
/proc/initialize_starting_knowledge()
	. = list()
	for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
		if(initial(knowledge.is_starting_knowledge) == TRUE)
			. += knowledge

/*
 * The base heretic knowledge. Grants the Mansus Grasp spell.
 */
/datum/heretic_knowledge/spell/basic
	name = "Break of Dawn"
	desc = "Starts your journey into the Mansus. \
		Grants you the Mansus Grasp, a powerful and upgradable \
		disabling spell that can be cast regardless of having a focus."
	action_to_add = /datum/spell/touch/mansus_grasp
	is_starting_knowledge = TRUE

/**
 * The Living Heart heretic knowledge.
 *
 * Gives the heretic a living heart.
 * Also includes a ritual to turn their heart into a living heart.
 */
/datum/heretic_knowledge/living_heart
	name = "The Living Heart"
	desc = "Grants you a Living Heart, allowing you to track sacrifice targets. \
		Should you lose your heart, you can transmute a poppy and a pool of blood \
		to awaken your heart into a Living Heart. If your heart is cybernetic, \
		you will additionally require a usable organic heart in the transmutation."
	required_atoms = list(
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/food/grown/poppy = 1,
	)
	priority = MAX_KNOWLEDGE_PRIORITY - 1 // Knowing how to remake your heart is important
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "living_heart"
	/// The typepath of the organ type required for our heart.
	var/required_organ_type = /obj/item/organ/internal/heart

/datum/heretic_knowledge/living_heart/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()

	var/obj/item/organ/where_to_put_our_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	// Our heart slot is not valid to put a heart
	if(!is_valid_heart(where_to_put_our_heart))
		where_to_put_our_heart = null

	// If a heretic is made from a species without a heart, we need to find a backup.
	if(!where_to_put_our_heart)
		var/static/list/backup_organs = list(
			ORGAN_SLOT_LUNGS = /obj/item/organ/internal/lungs,
			ORGAN_SLOT_LIVER = /obj/item/organ/internal/liver,
			ORGAN_SLOT_BRAIN = /obj/item/organ/internal/brain/mmi_holder/posibrain
		)

		for(var/backup_slot in backup_organs)
			var/obj/item/organ/look_for_backup = user.get_organ_slot(backup_slot)
			// This backup slot is not a valid slot to put a heart
			if(!is_valid_heart(look_for_backup))
				continue

			// We found a replacement place to put our heart
			where_to_put_our_heart = look_for_backup
			our_heretic.living_heart_organ_slot = backup_slot
			required_organ_type = backup_organs[backup_slot]
			to_chat(user, "<span class='boldnotice'>As your species does not have a heart, your Living Heart is located in your [look_for_backup.name].</span>")
			break

	if(where_to_put_our_heart)
		where_to_put_our_heart.AddComponent(/datum/component/living_heart)
		desc = "Grants you a Living Heart, tied to your [where_to_put_our_heart.name], \
			allowing you to track sacrifice targets. \
			Should you lose your [where_to_put_our_heart.name], you can transmute a poppy and a pool of blood \
			to awaken your replacement [where_to_put_our_heart.name] into a Living Heart. \
			If your [where_to_put_our_heart.name] is cybernetic, \
			you will additionally require a usable organic [where_to_put_our_heart.name] in the transmutation."

	else
		to_chat(user, "<span class='boldnotice'>You don't have a heart, or any chest organs for that matter. You didn't get a Living Heart because of it.</span>")
		message_admins("Oh fuck me, [user] did not have a heart, lungs, or liver. give [user] some organic lungs or something, then have them use the ritual again, then report this to me")

/datum/heretic_knowledge/living_heart/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	var/obj/item/organ/our_living_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	if(our_living_heart)
		qdel(our_living_heart.GetComponent(/datum/component/living_heart))

// Don't bother letting them invoke this ritual if they have a Living Heart already in their chest
/datum/heretic_knowledge/living_heart/can_be_invoked(datum/antagonist/heretic/invoker)
	if(invoker.has_living_heart() == HERETIC_HAS_LIVING_HEART)
		return FALSE
	return TRUE

/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/our_turf)
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	var/obj/item/organ/our_living_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)
	// For sanity's sake, check if they've got a living heart -
	// even though it's not invokable if you already have one,
	// they may have gained one unexpectantly in between now and then
	if(!QDELETED(our_living_heart))
		if(HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
			to_chat(user, "<span class='hierophant'>The ritual failed, you already have a living heart!</span>")
			return FALSE

		// By this point they are making a new heart
		// If their current heart is organic / not synthetic, we can continue the ritual as normal
		if(is_valid_heart(our_living_heart))
			return TRUE


	// Otherwise, seek out a replacement in our atoms
	for(var/obj/item/organ/nearby_organ in atoms)
		if(!istype(nearby_organ, required_organ_type))
			continue
		if(!is_valid_heart(nearby_organ))
			continue

		selected_atoms += nearby_organ
		return TRUE

	to_chat(user, "<span class='hierophant'>The ritual failed, you need a replacement [our_heretic.living_heart_organ_slot]!") // "need a replacement heart!"
	return FALSE

/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	var/obj/item/organ/internal/our_new_heart = user.get_organ_slot(our_heretic.living_heart_organ_slot)

	// Our heart is robotic or synthetic - we need to replace it, and we fortunately should have one by here
	if(!is_valid_heart(our_new_heart))
		var/obj/item/organ/internal/our_replacement_heart = locate(required_organ_type) in selected_atoms
		if(!our_replacement_heart)
			CRASH("[type] required a replacement organic heart in on_finished_recipe, but did not find one.")
		// Repair the organic heart, if needed, to just below the high threshold
		if(our_replacement_heart.damage >= our_replacement_heart.min_broken_damage)
			our_replacement_heart.damage = our_replacement_heart.min_broken_damage - 1
		// And now, put our organic heart in its place
		our_replacement_heart.insert(user, TRUE)
		if(our_new_heart)
			// Throw our current heart out of our chest, violently
			user.visible_message("<span class='boldwarning'>[user]'s [our_new_heart.name] bursts suddenly out of [user.p_their()] chest!</span>")
			INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, emote), "scream")
			user.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
			selected_atoms -= our_new_heart // so we don't delete our old heart while we dramatically toss is out
			our_new_heart.throw_at(get_edge_target_turf(user, pick(GLOB.alldirs)), 2, 2)
		our_new_heart = our_replacement_heart

	if(!our_new_heart)
		CRASH("[type] somehow made it to on_finished_recipe without a heart. What?")

	// Snowflakey, but if the user used a heart that wasn't beating
	// they'll immediately collapse into a heart attack. Funny but not ideal.
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.set_heartattack(FALSE)

	// Don't delete our shiny new heart
	selected_atoms -= our_new_heart
	// Make it the living heart
	our_new_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, "<span class='warning'>You feel your [our_new_heart.name] begin pulse faster and faster as it awakens!</span>")
	playsound(user, 'sound/misc/demon_consume.ogg', 50, TRUE)
	return TRUE

/// Checks if the passed heart is a valid heart to become a living heart
/datum/heretic_knowledge/living_heart/proc/is_valid_heart(obj/item/organ/new_heart)
	if(QDELETED(new_heart))
		return FALSE
	if(new_heart.status & (ORGAN_ROBOT|ORGAN_DEAD) && !istype(new_heart, /obj/item/organ/internal/brain/mmi_holder/posibrain)) //posibrains are living enough I guess
		return FALSE

	return TRUE

/**
 * Allows the heretic to craft a spell focus.
 * They require a focus to cast advanced spells.
 */
/datum/heretic_knowledge/amber_focus
	name = "Amber Focus"
	desc = "Allows you to transmute a sheet of glass and a pair of eyes to create an Amber Focus. \
		A focus must be worn in order to cast more advanced spells."
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus)
	priority = MAX_KNOWLEDGE_PRIORITY - 2 // Not as important as making a heart or sacrificing, but important enough.
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'icons/obj/clothing/neck.dmi'
	research_tree_icon_state = "eldritch_necklace"

/datum/heretic_knowledge/spell/cloak_of_shadows
	name = "Cloak of Shadow"
	desc = "Grants you the spell Cloak of Shadow. This spell will completely conceal your identity in a purple smoke \
		for three minutes, assisting you in keeping secrecy. Requires a focus to cast."
	action_to_add = /datum/spell/shadow_cloak
	is_starting_knowledge = TRUE

/**
 * Codex Cicatrixi is available at the start:
 * This allows heretics to choose if they want to rush all the influences and take them stealthily, or
 * Construct a codex and take what's left with more points.
 * Another downside to having the book is strip searches, which means that it's not just a free nab, at least until you get exposed - and when you do, you'll probably need the faster drawing speed.
 * Overall, it's a tradeoff between speed and stealth or power.
 */
/datum/heretic_knowledge/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Allows you to transmute a book, any unique pen (anything but a generic pen, blue pen, or red pen), and your pick from any carcass (animal or human), leather, or hide to create a Codex Cicatrix. \
		The Codex Cicatrix can be used when draining influences to gain additional knowledge, but comes at greater risk of being noticed. \
		It can also be used to draw and remove transmutation runes easier, and as a spell focus in a pinch."
	gain_text = "The occult leaves fragments of knowledge and power anywhere and everywhere. The Codex Cicatrix is one such example. \
		Within the leather-bound faces and age old pages, a path into the Mansus is revealed."
	required_atoms = list(
		/obj/item/book = 1,
		/obj/item/pen = 1,
		list(/mob/living, /obj/item/stack/sheet/leather, /obj/item/stack/sheet/animalhide) = 1,
	)
	banned_atom_types = list(/obj/item/pen, /obj/item/pen/blue, /obj/item/pen/red)
	result_atoms = list(/obj/item/codex_cicatrix)
	cost = 1
	is_starting_knowledge = TRUE
	priority = MAX_KNOWLEDGE_PRIORITY - 3 // Least priority out of the starting knowledges, as it's an optional boon.
	var/static/list/non_mob_bindings = typecacheof(list(/obj/item/stack/sheet/leather, /obj/item/stack/sheet/animalhide))
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "book"

/datum/heretic_knowledge/codex_cicatrix/parse_required_item(atom/item_path, number_of_things)
	if(item_path == /obj/item/pen || item_path == /obj/item/pen/blue || item_path == /obj/item/pen/red)
		return "any type of pen that is not a basic, blue, or red pen"
	return ..()

/datum/heretic_knowledge/codex_cicatrix/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/our_turf)
	. = ..()
	if(!.)
		return FALSE

	for(var/thingy in atoms)
		if(is_type_in_typecache(thingy, non_mob_bindings))
			selected_atoms += thingy
			return TRUE
		else if(isliving(thingy))
			var/mob/living/body = thingy
			if(body.stat != DEAD)
				continue
			selected_atoms += body
			return TRUE
	return FALSE

/datum/heretic_knowledge/codex_cicatrix/cleanup_atoms(list/selected_atoms)
	var/mob/living/body = locate() in selected_atoms
	if(!body)
		return ..()
	var/exterior_text = "skin"
	// If human, it's the limb. If not, it's the body.
	var/atom/movable/ripped_thing = body

	// We will check if it's a humann's body.
	// If it is, we will damage a random bodypart, and check that bodypart for its body type, to select between 'skin' or 'exterior'.
	if(ishuman(body))
		var/mob/living/carbon/human/carbody = body
		var/obj/item/organ/external/bodypart = pick(carbody.bodyparts)
		ripped_thing = bodypart
		carbody.apply_damage(25, BRUTE, bodypart, sharp = TRUE)
	else
		body.apply_damage(25, BRUTE, sharp = TRUE)
		// If it is not a carbon mob, we will just check biotypes and damage it directly.
		if(body.mob_biotypes & (MOB_MINERAL|MOB_ROBOTIC))
			exterior_text = "exterior"

	// Procure book for flavor text. This is why we call parent at the end.
	var/obj/item/book/le_book = locate() in selected_atoms
	if(!le_book)
		stack_trace("Somehow, no book in codex cicatrix selected atoms! [english_list(selected_atoms)]")
	playsound(body, 'sound/items/poster_ripped.ogg', 100, TRUE)
	body.do_jitter_animation()
	var/turf/our_turf = get_turf(body)
	our_turf.visible_message("<span class='danger'>An awful ripping sound is heard as [ripped_thing]'s [exterior_text] is ripped straight out, wrapping around [le_book || "the book"], turning into an eldritch shade of blue!</span>")
	return ..()

/datum/heretic_knowledge/feast_of_owls
	name = "Feast of Owls"
	desc = "Allows you to undergo a ritual that gives you 5 knowledge points but locks you out of ascension. This can only be done once and cannot be reverted. You can only do this with hijack, or at least 6 cultists around"
	gain_text = "Under the soft glow of unreason there is a beast that stalks the night. I shall bring it forth and let it enter my presence. It will feast upon my amibitions and leave knowledge in its wake."
	is_starting_knowledge = TRUE
	required_atoms = list()
	research_tree_icon_path = 'icons/mob/actions/actions_animal.dmi'
	research_tree_icon_state = "god_transmit"
	/// amount of research points granted
	var/reward = 5

/datum/heretic_knowledge/feast_of_owls/can_be_invoked(datum/antagonist/heretic/invoker)
	return !invoker.feast_of_owls

/datum/heretic_knowledge/feast_of_owls/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	var/has_hijack = FALSE
	for(var/datum/objective/is_it_hijack as anything in user.mind.get_all_objectives(include_team = FALSE))
		if(istype(is_it_hijack, /datum/objective/hijack))
			has_hijack = TRUE
	var/cult_players = 0
	var/datum/team/cult/cult_team = SSticker.mode.cult_team
	if(cult_team)
		cult_players = cult_team.get_cultists()
	if(!has_hijack && cult_players < 6)
		to_chat(user, "<span class='hierophant_warning'>You lack the ambition of hijacking to ascend, or there is not enough cultists!</span>")
		return FALSE
	var/alert = tgui_alert(user,"Do you really want to forsake your ascension? This action cannot be reverted.", "Feast of Owls", list("Yes I'm sure", "No"), 30 SECONDS)
	if(alert != "Yes I'm sure" || QDELETED(user) || QDELETED(src) || get_dist(user, our_turf) > 2)
		return FALSE
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(QDELETED(heretic_datum) || heretic_datum.feast_of_owls)
		return FALSE

	. = TRUE

	heretic_datum.feast_of_owls = TRUE
	user.playsound_local(get_turf(user), 'sound/ambience/antag/heretic/heretic_gain_intense.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	user.EyeBlind(reward * 1 SECONDS)
	user.Weaken(reward * 1 SECONDS)
	for(var/i in 1 to reward)
		user.emote("scream")
		playsound(our_turf, 'sound/items/eatfood.ogg', 100, TRUE)
		heretic_datum.knowledge_points++
		to_chat(user, "<span class='danger'>You feel something invisible tearing away at your very essence!</span>")
		user.do_jitter_animation()
		sleep(1 SECONDS)
		if(QDELETED(user) || QDELETED(heretic_datum))
			return FALSE

	to_chat(user, "<span class='danger'>Your ambition is ravaged, but something powerful remains in its wake...</span>")
	var/drain_message = pick_list(HERETIC_INFLUENCE_FILE, "drain_message")
	to_chat(user, "<span class='hierophant'>[drain_message]</span>")
	return .
