/obj/structure/unsealed_art
	name = "Unsealed Art"
	desc = "A painting of unfathomable madness. Such a piece will never let down those who refuse to desert its wisdom."
	icon = 'icons/obj/antags/unsealed_arts.dmi'
	icon_state = "debug"
	pass_flags_self = LETPASSTHROW
	max_integrity = 200
	layer = ABOVE_LYING_MOB_LAYER
	armor = list(MELEE = 50, BULLET = 30, LASER = 0, ENERGY = 0, BOMB = 0, RAD = INFINITY, FIRE = 0, ACID = 0)
	/// is the painting curredly draped over
	var/covered = FALSE

/obj/structure/unsealed_art/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/unsealed_art/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(covered)
		new /obj/item/stack/sheet/cloth(loc, 3)
	return ..()

/obj/structure/unsealed_art/process()
	return

/obj/structure/unsealed_art/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(..())
		return
	if(istype(used, /obj/item/stack/sheet/cloth))
		var/obj/item/stack/sheet/cloth/coverings = used
		if(coverings.amount >= 3)
			if(do_after_once(user, 3 SECONDS, TRUE, src, TRUE, FALSE))
				on_cover()
		else
			to_chat(user, SPAN_WARNING("You need at least 3 sheets of cloth to cover this!"))
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/structure/unsealed_art/attack_hand(mob/living/user)
	if(..())
		return
	if(covered)
		if(do_after_once(user, 3 SECONDS, TRUE, src, TRUE, FALSE))
			on_uncover()
		return FINISH_ATTACK

/obj/structure/unsealed_art/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	default_unfasten_wrench(user, I, 3 SECONDS)

/// This proc triggers when the art has been covered by sheets, going inert
/obj/structure/unsealed_art/proc/on_cover()
	covered = TRUE
	icon_state = "covered"
	STOP_PROCESSING(SSprocessing, src)

/// This proc triggers when the art has been uncovered by sheets, becomming active again
/obj/structure/unsealed_art/proc/on_uncover()
	covered = FALSE
	icon_state = initial(icon_state)
	START_PROCESSING(SSprocessing, src)

// MARK: Beauty
/obj/structure/unsealed_art/beauty
	name = "\improper Lady of the Gates"
	desc = "A painting of an otherworldly being. Its thin, porcelain-coloured skin is stretched tight over its strange bone structure. It has a haunting beauty that you cant keep your eyes from."
	icon_state = "beauty"
	var/mob/camera/eye/beauty/eyeobj
	var/mob/living/carbon/charmed_creature
	/// Is the painting currently enchanting someone
	var/enchanting = FALSE

/obj/structure/unsealed_art/beauty/examine_more(mob/user)
	. = ..()
	. += "<span class='notice'>This unsealed art will bewitch any non-heretic that lays their eyes on it, forcing them to stare deeply upon its beauty. They cannot look away.</span"

/obj/structure/unsealed_art/beauty/Destroy()
	QDEL_NULL(eyeobj)
	return ..()

/obj/structure/unsealed_art/beauty/on_cover()
	. = ..()
	disenchant()

/obj/structure/unsealed_art/beauty/process()
	if(enchanting)
		return
	if(charmed_creature)
		if(!isInSight(charmed_creature, src) || get_dist(charmed_creature, src) > 7 || charmed_creature.stat == DEAD)
			disenchant(charmed_creature)
		return
	for(var/mob/living/carbon/creature in range(7, loc))
		if(is_ai(creature))
			continue
		if(creature.stat == DEAD)
			continue
		if(HAS_TRAIT(creature, TRAIT_ANTIMAGIC))
			continue
		if(IS_HERETIC(creature))
			continue
		if(creature.mind && creature.client)
			if(isInSight(creature, src) && creature.stat != DEAD)
				INVOKE_ASYNC(src, PROC_REF(pre_enchant), creature)
				break

/obj/structure/unsealed_art/beauty/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(eyeobj)
		eyeobj.loc = loc

/obj/structure/unsealed_art/beauty/proc/pre_enchant(mob/living/carbon/creature)
	enchanting = TRUE
	to_chat(creature, SPAN_DANGER("You can feel the painting pulling your gaze to it!"))
	creature.SetDizzy(3 MINUTES)
	creature.playsound_local(creature, 'sound/effects/curse/curse1.ogg', 30, FALSE)
	sleep(3 SECONDS)
	enchanting = FALSE
	creature.SetDizzy(0)
	if(isInSight(creature, src) && creature.stat != DEAD)
		enchant(creature)
	else
		to_chat(creature, SPAN_WARNING("You can feel your gaze return to normal."))

/obj/structure/unsealed_art/beauty/proc/enchant(mob/living/carbon/creature)
	to_chat(creature, SPAN_HIEROPHANT_WARNING("She's so beautiful. You can't look away!"))
	eyeobj = new /mob/camera/eye/beauty(loc, "Enchanted Eyes", src, creature)
	eyeobj.see_in_dark = creature.see_in_dark
	charmed_creature = creature

/obj/structure/unsealed_art/beauty/proc/disenchant()
	to_chat(charmed_creature, SPAN_WARNING("You can feel your gaze return to normal."))
	charmed_creature = null
	QDEL_NULL(eyeobj)

/mob/camera/eye/beauty
	sight = SEE_BLACKNESS
	static_visibility_range = 0

/mob/camera/eye/beauty/give_control(mob/new_user)
	. = ..()
	user.remote_control = null

/mob/camera/eye/beauty/relaymove(mob/user, direct) // no moving
	return

/mob/camera/eye/beauty/update_visibility()
	return

// MARK: Weeping
/obj/structure/unsealed_art/weeping
	name = "\improper He Who Wept"
	desc = "A beautiful painting depicting a fair lady sitting beside Him. He weeps. You will see him again."
	icon_state = "weeping"

/obj/structure/unsealed_art/weeping/examine_more(mob/user)
	. = ..()
	. += SPAN_NOTICE("This unsealed art will overwhelm non-heretics with grief for him. They will lose the strength to stand, collapsing to the floor.")

/obj/structure/unsealed_art/weeping/process()
	for(var/mob/living/carbon/human/creature in range(7, loc))
		if(IS_HERETIC(creature))
			continue
		if(HAS_TRAIT(creature, TRAIT_ANTIMAGIC))
			continue
		if(!isInSight(creature, src) || creature.stat == DEAD)
			continue

		creature.SetDizzy(2 MINUTES)
		creature.AdjustConfused(20 SECONDS, 20 SECONDS, 3 MINUTES)
		if(prob(10))
			to_chat(creature, SPAN_NOTICE("You feel an overwhelming crushing grief!"))
			continue
		if(prob(10))
			creature.custom_emote(EMOTE_VISIBLE, "weeps uncontrollably", FALSE)
		if(creature.get_confusion() >= 1 MINUTES && prob(15))
			to_chat(creature, SPAN_DANGER("You are completely overcome with grief!"))
			creature.KnockDown(4 SECONDS)
			continue

GLOBAL_LIST_INIT(blacklisted_vine_turfs, typecacheof(list(
	/turf/simulated/floor/grass/jungle,
	/turf/simulated/floor/lava,
	/turf/simulated/floor/chasm
	)))

// MARK: Vines
/obj/structure/unsealed_art/vines
	name = "\improper Great Chaparral Over Rolling Hills"
	desc = "A painting depicting a massive green thicket, spanning over several hills. This painting is lush with purest life, and seems to strain against its frame."
	icon_state = "vines"
	/// the delay between terf conversions and mob creation
	var/delay = 4 SECONDS
	/// how many creatures do we own
	var/creatures_owned = 0
	/// What kinds of creatures can we spawn?
	var/list/creature_list = list()

	COOLDOWN_DECLARE(time_to_convert)

/obj/structure/unsealed_art/vines/Initialize(mapload)
	. = ..()
	for(var/mob in subtypesof(/mob/living/basic)) // we only want basic mobs to modify their controller
		var/mob/living/basic/basic_mob = mob
		if(initial(basic_mob.gold_core_spawnable) == FRIENDLY_SPAWN)
			creature_list += basic_mob

/obj/structure/unsealed_art/vines/examine_more(mob/user)
	. = ..()
	. += SPAN_NOTICE("This unsealed art will bring forth purest life, converting all around it into lush greenery. All unlightened beware, the creatures birthed forth are hungry.")

/obj/structure/unsealed_art/vines/process()
	if(!COOLDOWN_FINISHED(src, time_to_convert))
		return

	COOLDOWN_START(src, time_to_convert, delay)
	var/list/validturfs = list()
	var/list/vineturfs = list()
	for(var/turf/simulated/floor/T in circleviewturfs(src, 7))
		if(istype(T, /turf/simulated/floor/grass/jungle) && !T.density)
			vineturfs |= T
			continue
		if(is_type_in_typecache(T, GLOB.blacklisted_pylon_turfs))
			continue
		else
			validturfs |= T

	var/turf/T = safepick(validturfs)
	if(isfloorturf(T))
		T.ChangeTurf(/turf/simulated/floor/grass/jungle)

	if(creatures_owned >= 5) // only 5 creatures allowed max
		return
	var/creature_chance = 15 / (creatures_owned + 1)
	if(length(vineturfs) && prob(creature_chance))
		var/turf/V = safepick(vineturfs)
		var/chosen_mob = pick(creature_list)
		var/mob/living/basic/spawned_mob = new chosen_mob(V)
		creatures_owned++
		spawned_mob.visible_message("[spawned_mob] grows out of the grass flooring, knit together from the plant fibers!")
		spawned_mob.faction = list("heretic")
		spawned_mob.maxHealth = 60
		spawned_mob.health = 60
		spawned_mob.melee_damage_lower = 4
		spawned_mob.melee_damage_upper = 8
		spawned_mob.melee_attack_cooldown_min = 1 SECONDS
		spawned_mob.melee_attack_cooldown_max = 1.5 SECONDS
		spawned_mob.environment_smash = ENVIRONMENT_SMASH_STRUCTURES
		spawned_mob.ai_controller = new /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles(spawned_mob)
		spawned_mob.density = TRUE
		RegisterSignal(spawned_mob, COMSIG_MOB_DEATH, PROC_REF(on_mob_death))

/obj/structure/unsealed_art/vines/proc/on_mob_death()
	creatures_owned--
	COOLDOWN_START(src, time_to_convert, 20 SECONDS) // if a mob dies, stop spawning for a bit

// MARK: Desire
/obj/structure/unsealed_art/desire
	name = "\improper The First Desire"
	desc = "A painting of an elaborate feast. Despite being made entirely of rotting meat and decaying organs, the meal somehow looks incredibly appetising."
	icon_state = "desire"
	var/hunger_threshold = NUTRITION_LEVEL_HUNGRY
	var/list/sick_messages = list(
		SPAN_WARNING("Your stomach feels tied up in knots."),
		SPAN_WARNING("You feel sick to your stomach."),
		SPAN_WARNING("You feel incredibly nauseous."),
		SPAN_WARNING("You feel like you could vomit at any moment!"),
		SPAN_WARNING("The food on that painting looks absolutely delicious."),
		SPAN_WARNING("You cant stop looking at how delicious the painting's food it, even though the contents make you feel sick!"),
	)

/obj/structure/unsealed_art/desire/examine_more(mob/user)
	. = ..()
	. += SPAN_NOTICE("This unsealed art fills the unenlightened with the temptation of the first desire. Their hunger will never be sated in its presence, and will reject the gifts of the feast violently.")

/obj/structure/unsealed_art/desire/process()
	for(var/mob/living/carbon/human/creature in range(7, loc))
		if(IS_HERETIC(creature))
			if(creature.nutrition <= hunger_threshold)
				creature.adjust_nutrition(15)
			if(prob(5))
				to_chat(creature, SPAN_NOTICE("Your hunger feels sated."))
			continue
		if(HAS_TRAIT(creature, TRAIT_ANTIMAGIC))
			continue
		if(!isInSight(creature, src) || creature.stat == DEAD)
			continue

		creature.AdjustConfused(5 SECONDS, 10 SECONDS, 1 MINUTES)
		creature.adjust_nutrition(-5)

		if(creature.get_confusion() <= 20 SECONDS)
			return
		if(prob(10))
			to_chat(creature, pick(sick_messages))
		if(prob(5))
			creature.vomit(-10, TRUE, FALSE, 2, FALSE)
			var/turf/T = get_step(creature.loc, creature.dir)
			var/obj/meat = new /obj/item/food/meat(T)
			meat.name = "rotten meat"
			creature.visible_message(SPAN_WARNING("[creature] vomits up rotten meat and decayed organs!"), SPAN_WARNING("You vomit up rotten meat and decayed organs!"))

// MARK: Rust
/obj/structure/unsealed_art/rust
	name = "\improper Master of the Rusted Mountain"
	desc = "A painting of a strange being climbing a rust-coloured mountain. The brushwork is unnatural and unnerving."
	icon_state = "rust"
	var/cooldown_delay = 3 SECONDS
	COOLDOWN_DECLARE(time_to_rust)

/obj/structure/unsealed_art/rust/examine_more(mob/user)
	. = ..()
	. += SPAN_NOTICE("This unsealed art brings reminds the world around it of its fate, bringing all to its final decayed destination.")

/obj/structure/unsealed_art/rust/process()
	if(!COOLDOWN_FINISHED(src, time_to_rust))
		return

	var/list/validturfs = list()
	for(var/turf/simulated/T in circleviewturfs(src, 7))
		validturfs += T

	var/turf/chosen_turf = safepick(validturfs)
	if(chosen_turf)
		if(istype(chosen_turf, /turf/simulated/floor/plating/rust))
			for(var/mob/living/mob in chosen_turf)
				if(IS_HERETIC(mob))
					continue
				mob.do_rust_heretic_act(chosen_turf)
				playsound(chosen_turf, 'sound/items/welder.ogg', 30, TRUE)
		if(!HAS_TRAIT(chosen_turf, TRAIT_RUSTY))
			chosen_turf.rust_heretic_act()
	COOLDOWN_START(src, time_to_rust, cooldown_delay)
