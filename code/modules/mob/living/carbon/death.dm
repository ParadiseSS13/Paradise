/**
* _DAMAGE = any rvalue, _PART = lvalue (DO NOT CALCULATE DYNAMICALLY), _RES = any lvalue
* this macro tries to apply DAMAGE damage to the PART internal organ and
* then subtracts RES by the damage actually taken
*/
#define APPLY_DAMAGE(_DAMAGE, _PART, _RES)\
	if (_PART){\
		var/can_be_absorbed = (_PART:max_damage - _PART:damage);\
		var/damage_to_be_applied = min(can_be_absorbed, _DAMAGE);\
		_PART:receive_damage(damage_to_be_applied);\
		_PART:add_autopsy_data("Toxin Residue", damage_to_be_applied);\
		_RES -= damage_to_be_applied;\
	}\

/**
* This function applies damage to internal organs in case the mob died having toxin damage
* This feature increases amount of effort it takes to revive a victim of poisoning
*/
/mob/living/carbon/proc/process_toxin_damage_on_death(mob/living/carbon/target)
	if (!target)
		return

	var/internal_damage = target.getToxLoss()*TOXIN_TO_INTERNAL_DAMAGE_MULTIPLIER // getting toxin damage, converting into internal organ damage
	if (internal_damage < 10) // don't wanna be bothering with random 1-2 toxin dmg
		return

	// first the liver takes the hit
	APPLY_DAMAGE(internal_damage, target.get_int_organ(/obj/item/organ/internal/liver),internal_damage)
	// now we either took all damage and wanna quit, or need another organ to be damaged. It's gonna be heart+1
	if (internal_damage <= 0)
		return
	// heart takes at least 50% of the damage that is left after liver failure (unless it dies earlier)
	APPLY_DAMAGE(internal_damage/2, target.get_int_organ(/obj/item/organ/internal/heart),internal_damage)
	// now the rest of the damage is going to be distributed among other organs
	var/list/to_be_picked_from = target.internal_organs.Copy()
	if (to_be_picked_from)
		var/excessive_cycle_counter = 0
		var/excessive_cycle_limiter = 200
		while (internal_damage > 0 && length(to_be_picked_from) > 0 && excessive_cycle_counter < excessive_cycle_limiter)
			var/obj/item/organ/internal/organ_picked = pick(to_be_picked_from)
			APPLY_DAMAGE(min(rand(5,19), internal_damage), organ_picked, internal_damage)
			if (organ_picked?.damage >= organ_picked?.max_damage) // you can't check if the organ is dead because of immortality of the brain
				to_be_picked_from.Remove(organ_picked)
			excessive_cycle_counter++

#undef APPLY_DAMAGE

/mob/living/carbon/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	if(reagents)
		reagents.death_metabolize(src)

	process_toxin_damage_on_death(src) // applies TOXIN_TO_INTERNAL_DAMAGE_MULTIPLIER times toxin damage to internal organs

	for(var/obj/item/organ/internal/I in internal_organs)
		I.on_owner_death()
