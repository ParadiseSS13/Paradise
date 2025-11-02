/// Component applying shared behaviour by cursed organs granted when sacrificed by a heretic
/// Mostly just does something spooky when it is removed
/datum/element/corrupted_organ

/datum/element/corrupted_organ/Attach(obj/item/organ/target)
	. = ..()
	if(!is_internal_organ(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))

	var/atom/atom_parent = target
	atom_parent.color = COLOR_VOID_PURPLE

	atom_parent.add_filter(name = "ray", priority = 1, params = list(
		type = "rays",
		size = 12,
		color = COLOR_VOID_PURPLE,
		density = 12
	))
	var/ray_filter = atom_parent.get_filter("ray")
	animate(ray_filter, offset = 100, time = 2 MINUTES, loop = -1, flags = ANIMATION_PARALLEL) // Absurdly long animate so nobody notices it hitching when it loops
	animate(offset = 0, time = 2 MINUTES) // I sure hope duration of animate doesnt have any performance effect

/datum/element/corrupted_organ/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_ORGAN_REMOVED))
	return ..()

/// When we're taken out of someone, do something spooky
/datum/element/corrupted_organ/proc/on_removed(obj/item/organ/organ, mob/living/carbon/loser)
	SIGNAL_HANDLER // COMSIG_ORGAN_REMOVED
	if(loser.reagents?.has_reagent("holywater") || loser.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY) || prob(20))
		return
	var/turf/origin_turf = get_turf(loser)
	playsound(loser, 'sound/magic/forcewall.ogg', vol = 100)
	new /obj/effect/temp_visual/curse_blast(origin_turf)
	loser.visible_message("<span class='danger'>[organ] explodes in a burst of dark energy!</span>")
	for(var/mob/living/target in range(1, origin_turf))
		var/armor = target.run_armor_check()
		target.apply_damage(30, damagetype = BURN, blocked = armor, spread_damage = TRUE)
	QDEL_IN(organ, 1 SECONDS)

/obj/effect/temp_visual/curse_blast
	icon = 'icons/effects/64x64.dmi'
	pixel_x = -16
	pixel_y = -16
	icon_state = "curse"
	duration = 0.3 SECONDS

/obj/effect/temp_visual/curse_blast/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix() * 0.2, time = 0, flags = ANIMATION_PARALLEL)
	animate(transform = matrix() * 2, time = duration, easing = EASE_IN)

	animate(src, alpha = 255, time = 0, flags = ANIMATION_PARALLEL)
	animate(alpha = 255, time = 0.2 SECONDS)
	animate(alpha = 0, time = 0.1 SECONDS)
