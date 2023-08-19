#define HEAL_EFFECT_COOLDOWN (1 SECONDS)

/// Applies healing to those in the area.
/// Will provide them with an alert while they're in range, as well as
/// give them a healing particle.
/// Can be applied to those only with a trait conditionally.
/datum/component/aura_healing
	/// The range of which to heal
	var/range

	/// Whether or not you must be a visible object of the parent
	var/requires_visibility = TRUE

	/// Brute damage to heal over a second
	var/brute_heal = 0

	/// Burn damage to heal over a second
	var/burn_heal = 0

	/// Toxin damage to heal over a second
	var/toxin_heal = 0

	/// Suffocation damage to heal over a second
	var/suffocation_heal = 0

	/// Stamina damage to heal over a second
	var/stamina_heal = 0

	/// Amount of cloning damage to heal over a second
	var/clone_heal = 0

	/// Amount of blood to heal over a second
	var/blood_heal = 0

	/// Map of organ (such as ORGAN_SLOT_BRAIN) to damage heal over a second
	var/list/organ_healing

	/// Amount of damage to heal on simple mobs over a second
	var/simple_heal = 0

	/// Map of external organs (such as "head", "l_leg", "groin" etc.). Will mend fractures only on these organs if specified.
	var/list/external_organ_fracture_healing

	/// Chance to mend fractures
	var/mend_fractures_chance = 0

	/// Its healing robots parts as well?
	var/robot_heal = FALSE

	/// Map of external organs (such as "tail", "wing", "r_foot" etc.). Will stop internal bleedings only on these organs if specified.
	var/list/external_organ_bleeding_healing

	/// Chance to stop internal bleedings
	var/stop_internal_bleeding_chance = 0

	/// Trait to limit healing to, if set
	var/limit_to_trait

	/// The color to give the healing visual
	var/healing_color = COLOR_GREEN

	/// A list of being healed to active alerts
	var/list/current_alerts = list()

	COOLDOWN_DECLARE(last_heal_effect_time)


/datum/component/aura_healing/Initialize(
	range,
	requires_visibility = TRUE,
	brute_heal = 0,
	burn_heal = 0,
	toxin_heal = 0,
	suffocation_heal = 0,
	stamina_heal = 0,
	clone_heal = 0,
	blood_heal = 0,
	organ_healing = null,
	simple_heal = 0,
	external_organ_fracture_healing = null,
	mend_fractures_chance = 0,
	external_organ_bleeding_healing = null,
	stop_internal_bleeding_chance = 0,
	limit_to_trait = null,
	healing_color = COLOR_GREEN,
	robot_heal = FALSE
)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSaura_healing, src)

	src.range = range
	src.requires_visibility = requires_visibility
	src.brute_heal = brute_heal
	src.burn_heal = burn_heal
	src.toxin_heal = toxin_heal
	src.suffocation_heal = suffocation_heal
	src.stamina_heal = stamina_heal
	src.clone_heal = clone_heal
	src.blood_heal = blood_heal
	src.organ_healing = organ_healing
	src.simple_heal = simple_heal
	src.external_organ_fracture_healing = external_organ_fracture_healing
	src.mend_fractures_chance = mend_fractures_chance
	src.external_organ_bleeding_healing = external_organ_bleeding_healing
	src.stop_internal_bleeding_chance = stop_internal_bleeding_chance
	src.limit_to_trait = limit_to_trait
	src.healing_color = healing_color
	src.robot_heal = robot_heal


/datum/component/aura_healing/Destroy(force, silent)
	STOP_PROCESSING(SSaura_healing, src)
	var/alert_category = "aura_healing_[\ref(src)]"

	for(var/mob/living/alert_holder in current_alerts)
		alert_holder.clear_alert(alert_category)
	current_alerts.Cut()
	organ_healing = null
	external_organ_fracture_healing = null
	external_organ_bleeding_healing = null

	return ..()


/datum/component/aura_healing/process(seconds_per_tick)
	var/should_show_effect = COOLDOWN_FINISHED(src, last_heal_effect_time)
	if(should_show_effect)
		COOLDOWN_START(src, last_heal_effect_time, HEAL_EFFECT_COOLDOWN)

	var/list/remove_alerts_from = current_alerts.Copy()

	var/alert_category = "aura_healing_[\ref(src)]"

	for(var/mob/living/candidate in (requires_visibility ? view(range, parent) : range(range, parent)))
		if(!isnull(limit_to_trait) && !HAS_TRAIT(candidate, limit_to_trait))
			continue

		remove_alerts_from -= candidate

		if(!(candidate in current_alerts))
			var/obj/screen/alert/aura_healing/alert = candidate.throw_alert(alert_category, /obj/screen/alert/aura_healing, new_master = parent)
			alert.desc = "You are being healed by [parent]."
			current_alerts += candidate

		var/old_health = candidate.health

		if(issilicon(candidate) || isanimal(candidate))
			candidate.adjustBruteLoss(-brute_heal * seconds_per_tick, updating_health = FALSE)
			candidate.adjustFireLoss(-burn_heal * seconds_per_tick, updating_health = FALSE)

		if(iscarbon(candidate)) //another if, because porotic parts
			if(ishuman(candidate)) //humans, tajarans...
				var/mob/living/carbon/human/healing = candidate
				healing.adjustBruteLoss(-brute_heal * seconds_per_tick, updating_health = FALSE, robotic = robot_heal)
				healing.adjustFireLoss(-burn_heal * seconds_per_tick, updating_health = FALSE, robotic = robot_heal)
			else
				candidate.adjustBruteLoss(-brute_heal * seconds_per_tick, updating_health = FALSE) //aliens, brains...
				candidate.adjustFireLoss(-burn_heal * seconds_per_tick, updating_health = FALSE)

		if(iscarbon(candidate))
			// Toxin healing is forced for slime people
			candidate.adjustToxLoss(-toxin_heal * seconds_per_tick, updating_health = FALSE)

			candidate.adjustOxyLoss(-suffocation_heal * seconds_per_tick, updating_health = FALSE)
			candidate.adjustStaminaLoss(-stamina_heal * seconds_per_tick, updating_health = FALSE)
			candidate.adjustCloneLoss(-clone_heal * seconds_per_tick, updating_health = FALSE)

			for(var/obj/item/organ/organ in organ_healing)
				organ.heal_internal_damage(organ_healing[organ] * seconds_per_tick)

		else if(isanimal(candidate))
			var/mob/living/simple_animal/animal_candidate = candidate
			animal_candidate.adjustHealth(-simple_heal * seconds_per_tick, updating_health = FALSE)

		if(candidate.blood_volume < BLOOD_VOLUME_NORMAL)
			candidate.blood_volume += blood_heal * seconds_per_tick

		var/external_organ_heal_done = FALSE
		if(ishuman(candidate))
			var/mob/living/carbon/human/human = candidate

			if(mend_fractures_chance)
				if(length(external_organ_fracture_healing))
					var/obj/item/organ/external/body_part

					for(var/index in external_organ_fracture_healing)
						body_part = human.bodyparts_by_name[index]
						if(QDELETED(body_part) || !(body_part.status & ORGAN_BROKEN) || (body_part.is_robotic() && !robot_heal))
							continue

						if(prob(mend_fractures_chance))
							external_organ_heal_done = TRUE
							body_part.mend_fracture()
							break

				else
					for(var/obj/item/organ/external/body_part in human.bodyparts)
						if(QDELETED(body_part) || !(body_part.status & ORGAN_BROKEN) || (body_part.is_robotic() && !robot_heal))
							continue

						if(prob(mend_fractures_chance))
							external_organ_heal_done = TRUE
							body_part.mend_fracture()
							break

			if(stop_internal_bleeding_chance)
				if(length(external_organ_bleeding_healing))
					var/obj/item/organ/external/body_part

					for(var/index in external_organ_bleeding_healing)
						body_part = human.bodyparts_by_name[index]
						if(QDELETED(body_part) || !body_part.internal_bleeding)
							continue

						if(prob(stop_internal_bleeding_chance))
							external_organ_heal_done = TRUE
							body_part.internal_bleeding = FALSE
							break

				else
					for(var/obj/item/organ/external/body_part in human.bodyparts)
						if(QDELETED(body_part) || !body_part.internal_bleeding)
							continue

						if(prob(stop_internal_bleeding_chance))
							external_organ_heal_done = TRUE
							body_part.internal_bleeding = FALSE
							break

		if(should_show_effect && (external_organ_heal_done || old_health < candidate.maxHealth))
			new /obj/effect/temp_visual/heal(get_turf(candidate), healing_color)

		candidate.updatehealth()

	for(var/mob/remove_alert_from as anything in remove_alerts_from)
		remove_alert_from.clear_alert(alert_category)
		current_alerts -= remove_alert_from


/obj/screen/alert/aura_healing
	name = "Aura Healing"
	icon_state = "template"

#undef HEAL_EFFECT_COOLDOWN
