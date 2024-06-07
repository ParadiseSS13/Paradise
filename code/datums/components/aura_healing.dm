#define HEAL_EFFECT_COOLDOWN (1 SECONDS)

/// Applies healing to those in the area.
/// Will provide them with an alert while they're in range, as well as
/// give them a healing particle.
/// Can be applied to those only with a trait conditionally.
/atom/movable/screen/alert/aura_healing
	name = "Aura Healing"
	icon_state = "template"

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
	var/list/organ_healing = null

	/// Shows that aura heals fractures
	var/heal_fractures = FALSE

	/// Shows that aura heals internal bleedings
	var/heal_internal_bleedings = FALSE

	/// Showa that aura heals critical burns

	var/heal_critical_burns = FALSE

	/// Amount of damage to heal on simple mobs over a second
	var/simple_heal = 0

	/// Trait to limit healing to, if set
	var/limit_to_trait = null

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
	heal_fractures = FALSE,
	heal_internal_bleedings = FALSE,
	simple_heal = 0,
	limit_to_trait = null,
	healing_color = COLOR_GREEN,
)
	if(!isatom(parent))
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
	src.heal_fractures = heal_fractures
	src.heal_internal_bleedings = heal_internal_bleedings
	src.simple_heal = simple_heal
	src.limit_to_trait = limit_to_trait
	src.healing_color = healing_color

/datum/component/aura_healing/Destroy(force, silent)
	STOP_PROCESSING(SSaura_healing, src)
	var/alert_category = "aura_healing_[\ref(src)]"

	for(var/mob/living/alert_holder in current_alerts)
		alert_holder.clear_alert(alert_category)
	current_alerts.Cut()

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
			var/atom/movable/screen/alert/aura_healing/alert = candidate.throw_alert(alert_category, /atom/movable/screen/alert/aura_healing, new_master = parent)
			alert.desc = "You are being healed by [parent]."
			current_alerts += candidate

		if(should_show_effect && candidate.health < candidate.maxHealth)
			new /obj/effect/temp_visual/heal(get_turf(candidate), healing_color)

		if(iscarbon(candidate) || issilicon(candidate) || isanimal(candidate))
			candidate.adjustBruteLoss(-brute_heal * seconds_per_tick, updating_health = FALSE)
			candidate.adjustFireLoss(-burn_heal * seconds_per_tick, updating_health = FALSE)

		if(iscarbon(candidate))
			candidate.adjustToxLoss(-toxin_heal * seconds_per_tick, updating_health = FALSE)
			candidate.adjustOxyLoss(-suffocation_heal * seconds_per_tick, updating_health = FALSE)
			candidate.adjustStaminaLoss(-stamina_heal * seconds_per_tick, updating_health = FALSE)
			candidate.adjustCloneLoss(-clone_heal * seconds_per_tick, updating_health = FALSE)

			for(var/obj/item/organ/organ in organ_healing)
				organ.heal_internal_damage(organ_healing[organ] * seconds_per_tick)
		else if(isanimal(candidate))
			var/mob/living/simple_animal/animal_candidate = candidate
			animal_candidate.adjustHealth(-simple_heal * seconds_per_tick, updating_health = FALSE)
		if(ishuman(candidate) && (heal_fractures || heal_internal_bleedings || heal_critical_burns))
			var/mob/living/carbon/human/H = candidate
			for(var/obj/item/organ/external/E in H.bodyparts)
				if(E.status & (ORGAN_INT_BLEEDING | ORGAN_BROKEN | ORGAN_SPLINTED | ORGAN_BURNT))
					if(prob(5))
						E.rejuvenate() //Repair it completely. But not often.

		if(candidate.blood_volume < BLOOD_VOLUME_NORMAL)
			candidate.blood_volume += blood_heal * seconds_per_tick

		candidate.updatehealth()

	for(var/mob/remove_alert_from as anything in remove_alerts_from)
		remove_alert_from.clear_alert(alert_category)
		current_alerts -= remove_alert_from

#undef HEAL_EFFECT_COOLDOWN
