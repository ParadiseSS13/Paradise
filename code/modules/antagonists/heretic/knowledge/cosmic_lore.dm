
/datum/heretic_knowledge_tree_column/main/cosmic
	neighbour_type_left = /datum/heretic_knowledge_tree_column/rust_to_cosmic
	neighbour_type_right = /datum/heretic_knowledge_tree_column/cosmic_to_ash

	route = PATH_COSMIC
	ui_bgr = "node_cosmos"

	start = /datum/heretic_knowledge/limited_amount/starting/base_cosmic
	grasp = /datum/heretic_knowledge/cosmic_grasp
	tier1 = /datum/heretic_knowledge/spell/cosmic_runes
	mark = /datum/heretic_knowledge/mark/cosmic_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/cosmic
	unique_ability = /datum/heretic_knowledge/spell/star_touch
	tier2 = /datum/heretic_knowledge/spell/star_blast
	blade = /datum/heretic_knowledge/blade_upgrade/cosmic
	tier3 =	 /datum/heretic_knowledge/spell/cosmic_expansion
	ascension = /datum/heretic_knowledge/ultimate/cosmic_final

/datum/heretic_knowledge/limited_amount/starting/base_cosmic
	name = "Eternal Gate"
	desc = "Opens up the Path of Cosmos to you. \
		Allows you to transmute a sheet of plasma and a knife into an Cosmic Blade. \
		You can only create three at a time."
	gain_text = "A nebula appeared in the sky, its infernal birth shone upon me. This was the start of a great transcendence."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/cosmic)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "cosmic_blade"

/datum/heretic_knowledge/cosmic_grasp
	name = "Grasp of Cosmos"
	desc = "Your Mansus Grasp will give people a star mark (cosmic ring) and create a cosmic field where you stand. \
		People with a star mark can not pass cosmic fields."
	gain_text = "Some stars dimmed, others' magnitude increased. \
		With newfound strength I could channel the nebula's power into myself."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_cosmos"

/datum/heretic_knowledge/cosmic_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/cosmic_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/// Aplies the effect of the mansus grasp when it hits a target.
/datum/heretic_knowledge/cosmic_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	to_chat(target, "<span class='danger'>A cosmic ring appeared above your head!</span>")
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	new /obj/effect/forcefield/cosmic_field(get_turf(source))

/datum/heretic_knowledge/spell/cosmic_runes
	name = "Cosmic Runes"
	desc = "Grants you Cosmic Runes, a spell that creates two runes linked with each other for easy teleportation. \
		Only the entity activating the rune will get transported, and it can be used by anyone without a star mark. \
		However, people with a star mark will get transported along with another person using the rune."
	gain_text = "The distant stars crept into my dreams, roaring and screaming without reason. \
		I spoke, and heard my own words echoed back."
	action_to_add = /datum/spell/cosmic_rune
	cost = 1


/datum/heretic_knowledge/mark/cosmic_mark
	name = "Mark of Cosmos"
	desc = "Your Mansus Grasp now applies the Mark of Cosmos. The mark is triggered from an attack with your Cosmic Blade. \
		When triggered, the victim is returned to the location where the mark was originally applied to them, \
		leaving a cosmic field in their place. \
		They will then be paralyzed for 2 seconds."
	gain_text = "The Beast now whispered to me occasionally, only small tidbits of their circumstances. \
		I can help them, I have to help them."
	mark_type = /datum/status_effect/eldritch/cosmic

/datum/heretic_knowledge/knowledge_ritual/cosmic

/datum/heretic_knowledge/spell/star_touch
	name = "Star Touch"
	desc = "Grants you Star Touch, a spell which places a star mark upon your target \
		and creates a cosmic field at your feet and to the turfs next to you. Targets which already have a star mark \
		will be forced to sleep for 4 seconds. When the victim is hit it also creates a beam that burns them. \
		The beam lasts a minute, until the beam is obstructed or until a new target has been found."
	gain_text = "After waking in a cold sweat I felt a palm on my scalp, a sigil burned onto me. \
		My veins now emitted a strange purple glow, the Beast knows I will surpass its expectations."
	action_to_add = /datum/spell/touch/star_touch
	cost = 1

/datum/heretic_knowledge/spell/star_blast
	name = "Star Blast"
	desc = "Fires a projectile that moves very slowly, raising a short-lived wall of cosmic fields where it goes. \
		Anyone hit by the projectile will receive burn damage, a knockdown, and give people in a three tile range a star mark."
	gain_text = "The Beast was behind me now at all times, with each sacrifice words of affirmation coursed through me."
	action_to_add = /datum/spell/fireball/star_blast
	cost = 1

/datum/heretic_knowledge/blade_upgrade/cosmic
	name = "Cosmic Blade"
	desc = "Your blade now deals damage to people's organs through cosmic radiation. \
		Your attacks will chain bonus damage to up to two previous victims. \
		The combo is reset after two seconds without making an attack, \
		or if you attack someone already marked. If you combo more than four attacks you will receive, \
		a cosmic trail and increase your combo timer up to ten seconds."
	gain_text = "The Beast took my blades in their hand, I kneeled and felt a sharp pain. \
		The blades now glistened with fragmented power. I fell to the ground and wept at the beast's feet."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_cosmos"
	/// Storage for the second target.
	var/second_target
	/// Storage for the third target.
	var/third_target
	/// When this timer completes we reset our combo.
	var/combo_timer
	/// The active duration of the combo.
	var/combo_duration = 3 SECONDS
	/// The duration of a combo when it starts.
	var/combo_duration_amount = 3 SECONDS
	/// The maximum duration of the combo.
	var/max_combo_duration = 10 SECONDS
	/// The amount the combo duration increases.
	var/increase_amount = 0.5 SECONDS
	/// The hits we have on a mob with a mind.
	var/combo_counter = 0

/datum/heretic_knowledge/blade_upgrade/cosmic/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	var/static/list/valid_organ_slots = list(
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/ears,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/brain
	)
	if(source == target || !isliving(target))
		return
	if(combo_timer)
		deltimer(combo_timer)
	combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo), source), combo_duration, TIMER_STOPPABLE)
	var/mob/living/second_target_resolved = locateUID(second_target)
	var/mob/living/third_target_resolved = locateUID(third_target)
	var/need_mob_update = FALSE
	need_mob_update += target.adjustFireLoss(5, updating_health = FALSE)
	var/obj/item/organ/internal/organ_to_stab = target.get_int_organ(/obj/item/organ/internal/liver)
	if(organ_to_stab)
		organ_to_stab.receive_damage(8, TRUE)
	if(need_mob_update)
		target.updatehealth()
	if(target == second_target_resolved || target == third_target_resolved)
		reset_combo(source)
		return
	if(target.mind && target.stat != DEAD)
		combo_counter += 1
	if(second_target_resolved)
		new /obj/effect/temp_visual/cosmic_explosion(get_turf(second_target_resolved))
		playsound(get_turf(second_target_resolved), 'sound/magic/cosmic_energy.ogg', 25, FALSE)
		need_mob_update = FALSE
		need_mob_update += second_target_resolved.adjustFireLoss(14, updating_health = FALSE)
		var/obj/item/organ/internal/second_organ_to_stab = second_target_resolved.get_int_organ(/obj/item/organ/internal/liver)
		if(second_organ_to_stab)
			second_organ_to_stab.receive_damage(12, TRUE)
		if(need_mob_update)
			second_target_resolved.updatehealth()
		if(third_target_resolved)
			new /obj/effect/temp_visual/cosmic_domain(get_turf(third_target_resolved))
			playsound(get_turf(third_target_resolved), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
			need_mob_update = FALSE
			need_mob_update += third_target_resolved.adjustFireLoss(28, updating_health = FALSE)
			var/obj/item/organ/internal/third_organ_to_stab = third_target_resolved.get_int_organ(/obj/item/organ/internal/liver)
			if(third_organ_to_stab)
				third_organ_to_stab.receive_damage(14, TRUE)
			if(need_mob_update)
				third_target_resolved.updatehealth()
			if(combo_counter > 3)
				target.apply_status_effect(/datum/status_effect/star_mark, source)
				if(target.mind && target.stat != DEAD)
					increase_combo_duration()
					if(combo_counter == 4)
						source.AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
		third_target = second_target
	second_target = target.UID()

/// Resets the combo.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/reset_combo(mob/living/source)
	second_target = null
	third_target = null
	if(combo_counter > 3)
		source.RemoveElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
	combo_duration = combo_duration_amount
	combo_counter = 0
	new /obj/effect/temp_visual/cosmic_cloud(get_turf(source))
	if(combo_timer)
		deltimer(combo_timer)

/// Increases the combo duration.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/increase_combo_duration()
	if(combo_duration < max_combo_duration)
		combo_duration += increase_amount

/datum/heretic_knowledge/spell/cosmic_expansion
	name = "Cosmic Expansion"
	desc = "Grants you Cosmic Expansion, a spell that creates a 3x3 area of cosmic fields around you. \
		Nearby beings will also receive a star mark."
	gain_text = "The ground now shook beneath me. The Beast inhabited me, and their voice was intoxicating."
	action_to_add = /datum/spell/aoe/conjure/cosmic_expansion
	cost = 1

/datum/heretic_knowledge/ultimate/cosmic_final
	name = "Creators's Gift"
	desc = "The ascension ritual of the Path of Cosmos. \
		Bring sentient 3 corpses with bluespace dust in their body to a transmutation rune to complete the ritual. \
		When completed, you become the owner of a Star Gazer. \
		You will be able to command the Star Gazer with Alt+click. \
		You can also give it commands through speech. \
		The Star Gazer is a strong ally who can even break down reinforced walls. \
		The Star Gazer has an aura that will heal you and damage opponents. \
		Star Touch can now teleport you to the Star Gazer when activated in your hand. \
		Your cosmic expansion spell and your blades also become greatly empowered."
	gain_text = "The Beast held out its hand, I grabbed hold and they pulled me to them. Their body was towering, but it seemed so small and feeble after all their tales compiled in my head. \
		I clung on to them, they would protect me, and I would protect it. \
		I closed my eyes with my head laid against their form. I was safe. \
		WITNESS MY ASCENSION!"


	announcement_text = "%SPOOKY% A Star Gazer has arrived into the station, %NAME% has ascended! This station is the domain of the Cosmos! %SPOOKY%"
	announcement_sound = 'sound/ambience/antag/heretic/ascend_cosmic.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "cosmicascend"

/datum/heretic_knowledge/ultimate/cosmic_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE
	if(!sacrifice.mind)
		return FALSE
	if(!sacrifice.reagents.has_reagent("bluespace_dust"))
		return FALSE
	return TRUE

/datum/heretic_knowledge/ultimate/cosmic_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	. = ..()
	var/mob/living/basic/heretic_summon/star_gazer/star_gazer_mob = new /mob/living/basic/heretic_summon/star_gazer(our_turf)
	star_gazer_mob.master_commander = user
	star_gazer_mob.befriend(user)
	star_gazer_mob.maxHealth = INFINITY
	star_gazer_mob.health = INFINITY
	user.AddComponent(/datum/component/death_linked, star_gazer_mob)
	star_gazer_mob.AddComponent(/datum/component/damage_aura, range = 7, burn_damage = 0.5, simple_damage = 0.5, immune_factions = list("heretic"), current_owner = user)
	var/datum/spell/touch/star_touch/star_touch_spell = locate() in user.mob_spell_list
	if(star_touch_spell)
		star_touch_spell.set_star_gazer(star_gazer_mob)
		star_touch_spell.ascended = TRUE

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/blade_upgrade/cosmic/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/cosmic)
	blade_upgrade.combo_duration = 10 SECONDS
	blade_upgrade.combo_duration_amount = 10 SECONDS
	blade_upgrade.max_combo_duration = 30 SECONDS
	blade_upgrade.increase_amount = 2 SECONDS

	var/datum/spell/aoe/conjure/cosmic_expansion/cosmic_expansion_spell = locate() in user.mob_spell_list
	cosmic_expansion_spell?.ascended = TRUE
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a star gazer?", ROLE_HERETIC, TRUE, 10 SECONDS, min_hours = 100, source = star_gazer_mob)
	var/mob/chosen_one
	if(length(candidates))
		chosen_one = pick(candidates)
	if(!chosen_one)
		return
	star_gazer_mob.key = chosen_one.key

	star_gazer_mob.mind.add_antag_datum(new /datum/antagonist/mindslave/heretic_monster(user.mind))

