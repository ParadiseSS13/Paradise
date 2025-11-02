
/datum/heretic_knowledge_tree_column/main/moon
	neighbour_type_left = /datum/heretic_knowledge_tree_column/ash_to_moon
	neighbour_type_right = /datum/heretic_knowledge_tree_column/moon_to_lock

	route = PATH_MOON
	ui_bgr = "node_moon"

	start = /datum/heretic_knowledge/limited_amount/starting/base_moon
	grasp = /datum/heretic_knowledge/moon_grasp
	tier1 = /datum/heretic_knowledge/spell/moon_smile
	mark = /datum/heretic_knowledge/mark/moon_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/moon
	unique_ability = /datum/heretic_knowledge/spell/moon_parade
	tier2 = /datum/heretic_knowledge/moon_amulet
	blade = /datum/heretic_knowledge/blade_upgrade/moon
	tier3 =	/datum/heretic_knowledge/spell/moon_ringleader
	ascension = /datum/heretic_knowledge/ultimate/moon_final

/datum/heretic_knowledge/limited_amount/starting/base_moon
	name = "Moonlight Troupe"
	desc = "Opens up the Path of Moon to you. \
		Allows you to transmute 2 sheets of iron and a knife into an Lunar Blade. \
		You can only create three at a time."
	gain_text = "Under the light of the moon the laughter echoes."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/stack/sheet/metal = 2,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/moon)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "moon_blade"

/datum/heretic_knowledge/moon_grasp
	name = "Grasp of Lunacy"
	desc = "Your Mansus Grasp will cause your victims to hallucinate everyone as lunar mass, \
		and hides your identity for a short duration."
	gain_text = "The troupe on the side of the moon showed me truth, and I took it."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_moon"

/datum/heretic_knowledge/moon_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/moon_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/moon_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER
	if(target.can_block_magic(MAGIC_RESISTANCE_MIND))
		to_chat(target, "<span class='danger'>You hear echoing laughter from above..but it is dull and distant.</span>")
		return

	source.apply_status_effect(/datum/status_effect/moon_grasp_hide)

	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	to_chat(carbon_target, "<span class='danger'>You hear echoing laughter from above</span>")
	new /obj/effect/hallucination/delusion(get_turf(carbon_target), carbon_target, 'icons/effects/eldritch.dmi', "heretic")
	carbon_target.adjustBrainLoss(15)

/datum/heretic_knowledge/spell/moon_smile
	name = "Smile of the moon"
	desc = "Grants you Smile of the moon, a ranged spell muting, blinding, and deafening the target for a\
		duration based on their sanity, and knocks down the victim with sufficient sanity loss."
	gain_text = "The moon smiles upon us all and those who see its true side can bring its joy."

	action_to_add = /datum/spell/pointed/moon_smile
	cost = 1

/datum/heretic_knowledge/mark/moon_mark
	name = "Mark of Moon"
	desc = "Your Mansus Grasp now applies the Mark of Moon, pacifying the victim until attacked. \
		The mark can also be triggered from an attack with your Moon Blade, leaving the victim confused."
	gain_text = "The troupe on the moon would dance all day long \
		and in that dance the moon would smile upon us \
		but when the night came its smile would dull forced to gaze on the earth."
	mark_type = /datum/status_effect/eldritch/moon

/datum/heretic_knowledge/knowledge_ritual/moon

/datum/heretic_knowledge/spell/moon_parade
	name = "Lunar Parade"
	desc = "Grants you Lunar Parade, a spell that - after a short charge - sends a carnival forward \
		when hitting someone they are forced to join the parade and suffer hallucinations."
	gain_text = "The music like a reflection of the soul compelled them, like moths to a flame they followed"
	action_to_add = /datum/spell/fireball/moon_parade
	cost = 1

/datum/heretic_knowledge/moon_amulet
	name = "Moonlight Amulet"
	desc = "Allows you to transmute 2 sheets of glass, a heart and a tie to create a Moonlight Amulet. \
			If the item is used on someone with low sanity they go berserk attacking everyone around them."
	gain_text = "At the head of the parade he stood, the moon condensed into one mass, a reflection of the soul."

	required_atoms = list(
		/obj/item/organ/internal/heart = 1,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/clothing/neck/tie = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus/moon_amulet)
	cost = 1


	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "moon_amulette"
	research_tree_icon_frame = 9

/datum/heretic_knowledge/blade_upgrade/moon
	name = "Moonlight Blade"
	desc = "Your blade now deals brain damage, causes random hallucinations and does sanity damage."
	gain_text = "His wit was sharp as a blade, cutting through the lie to bring us joy."


	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_moon"

/datum/heretic_knowledge/blade_upgrade/moon/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	if(target.can_block_magic(MAGIC_RESISTANCE_MIND))
		return

	target.adjustBrainLoss(10)
	target.Hallucinate(10 SECONDS)
	target.emote(pick("giggle", "laugh"))

/datum/heretic_knowledge/spell/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Grants you Ringleaders Rise, an AoE spell that deals more brain damage the lower the sanity of everyone in the AoE \
			and causes hallucinations, with those who have less sanity getting more. \
			If their sanity is low enough this turns them insane, the spell then halves their sanity."
	gain_text = "I grabbed his hand and we rose, those who saw the truth rose with us. \
		The ringleader pointed up and the dim light of truth illuminated us further."

	action_to_add = /datum/spell/aoe/moon_ringleader
	cost = 1


	research_tree_icon_frame = 5

/datum/heretic_knowledge/ultimate/moon_final
	name = "The Last Act"
	desc = "The ascension ritual of the Path of Moon. \
		Bring 3 corpses with more than 50 brain damage to a transmutation rune to complete the ritual. \
		When completed, you become a harbinger of madness gaining and aura of passive sanity decrease, \
		confusion increase and, if their sanity is low enough, brain damage and blindness. \
		1/5th of the crew will turn into acolytes and follow your command, they will all receive moonlight amulets."
	gain_text = "We dived down towards the crowd, his soul splitting off in search of greater venture \
		for where the Ringleader had started the parade, I shall continue it unto the suns demise \
		WITNESS MY ASCENSION, THE MOON SMILES ONCE MORE AND FOREVER MORE IT SHALL!"

	announcement_text = "%SPOOKY% Laugh, for the ringleader %NAME% has ascended! \
						The truth shall finally devour the lie! %SPOOKY%"
	announcement_sound = 'sound/ambience/antag/heretic/ascend_moon.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "moonascend"

/datum/heretic_knowledge/ultimate/moon_final/is_valid_sacrifice(mob/living/sacrifice)
//Qwertodo: redo this entire ultimate lmaoooo
	var/brain_damage = sacrifice.getBrainLoss()
	// Checks if our target has enough brain damage
	if(brain_damage < 50)
		return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/moon_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	. = ..()
	message_admins("QWERTODO: THIS")

/datum/heretic_knowledge/ultimate/moon_final/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
///	var/obj/effect/moon_effect = /obj/effect/temp_visual/moon_ringleader
	SIGNAL_HANDLER
	message_admins("QWERTODO: THIS")
