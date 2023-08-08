/datum/antagonist/mindflayer
	name = "Mind Flayer"
//	antag_hud_type = ANTAG_HUD_MIND_FLAYER
	antag_hud_name = "hudflayer"
//	special_role = SPECIAL_ROLE_MIND_FLAYER
	wiki_page_name = "Mind Flayer"
	///The current amount of swarms the mind flayer has access to purchase with
	var/usable_swarms = 0
	///The total points of brain damage the flayer has harvested, only used for logging purposes.
	var/total_swarms_gathered = 0
	///The current person being drained
	var/mob/living/carbon/human/harvesting
	///The list of all purchased powers
	var/list/powers = list()
	///List for keeping track of who has already been drained
	var/list/drained_humans = list()
	///How fast the flayer's touch drains
	var/drain_multiplier = 1

#define BRAIN_DRAIN_LIMIT 120
#define DRAIN_TIME 1/4 SECONDS

/proc/ismindflayer(mob/M)
	return M.mind?.has_antag_datum(/datum/antagonist/mindflayer)

/datum/antagonist/mindflayer/proc/get_swarms()
	return usable_swarms

/datum/antagonist/mindflayer/proc/set_swarms(amount, update_total = FALSE)
	var/old_swarm_amount = usable_swarms
	usable_swarms = amount
	if(update_total)
		var/difference = usable_swarms - old_swarm_amount
		total_swarms_gathered += difference

/datum/antagonist/mindflayer/proc/adjust_swarms(amount, bound_lower = 0, bound_upper = INFINITY)
	set_swarms(directional_bounded_sum(usable_swarms, amount, bound_lower, bound_upper), TRUE)

/**
	Checks for any reason that you should not be able to drain someone for.
	Returns either true or false, if the harvest will work or not.
*/
/datum/antagonist/mindflayer/proc/check_valid_harvest(mob/living/carbon/human/H)
	var/obj/item/organ/internal/brain/brain = H.get_int_organ(/obj/item/organ/internal/brain)
	if(!brain)
		to_chat(owner.current, "<span class='warning'>This entity has no brain!")
		return FALSE
	var/unique_drain_id = H.UID()
	if(!(drained_humans[unique_drain_id]))
		drained_humans[unique_drain_id] = 0
	else
		return drained_humans[unique_drain_id] <= BRAIN_DRAIN_LIMIT //TODO better feedback on trying to drain past the limit
	return TRUE

/datum/antagonist/mindflayer/proc/handle_harvest(mob/living/carbon/human/H)
	harvesting = H
	var/unique_drain_id = H.UID()
	while(do_mob(owner.current, H, DRAIN_TIME, FALSE) && check_valid_harvest(H))// Gotta fix this magic number later
		H.Beam(owner.current, icon_state = "drain_life", icon ='icons/effects/effects.dmi', time = DRAIN_TIME)
		var/damage_to_deal = (1/4 * drain_multiplier * H.dna.species.brain_mod)
		H.adjustBrainLoss(damage_to_deal, use_brain_mod = FALSE)
		adjust_swarms(damage_to_deal)
		drained_humans[unique_drain_id] += damage_to_deal
	harvesting = null

/**
 * Gives the mind_flayer the passed in `power`. Subtracts the cost of the power from our genetic points.
 *
 * Arugments:
 * * datum/action/mindflayer/power - the power to give to the mindflayer.
 * * mob/living/mindflayer - the mindflayer who owns this datum. Optional argument.
 * * take_cost - if we should spend genetic points when giving the power
 */
/* TODO: fix this proc so it works with mindflayers
/datum/antagonist/mindflayer/proc/give_power(datum/action/mindflayer/power, mob/living/mindflayer, take_cost = TRUE)
	if(take_cost)
		genetic_points -= power.dna_cost
	acquired_powers += power
	on_purchase(mindflayer || owner.current, src, power)
*/
/datum/antagonist/mindflayer/greet()
	var/dat
	SEND_SOUND(owner.current, sound('sound/ambience/antag/vampalert.ogg'))
	dat = "<span class='danger'>You are a mindflayer!</span><br>" // TODO: Add actual description
	dat += {"To bite someone, target the head and use harm intent with an empty hand. Drink blood to gain new powers.
		You are weak to holy things, starlight and fire. Don't go into space and avoid the Chaplain, the chapel and especially Holy Water."}
	to_chat(owner.current, dat)

/datum/antagonist/mindflayer/apply_innate_effects(mob/living/mob_override)
	mob_override = ..()

	mob_override.dna.species.hunger_type = "vampire"
	mob_override.dna.species.hunger_icon = 'icons/mob/screen_hunger_vampire.dmi'
//	check_mindflayer_upgrade(FALSE) TODO: add this proc
/*
/datum/hud/proc/remove_vampire_hud()
	static_inventory -= vampire_blood_display
	QDEL_NULL(vampire_blood_display)
*/
// This is the proc that gets called every tick of life(), use this for updating something that should update every few seconds
/datum/antagonist/mindflayer/proc/handle_mindflayer()
	if(owner.current.hud_used)
		var/datum/hud/hud = owner.current.hud_used
		if(!hud.vampire_blood_display)
			hud.vampire_blood_display = new /obj/screen()
			hud.vampire_blood_display.name = "Usable Blood"
			hud.vampire_blood_display.icon_state = "blood_display"
			hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
			hud.static_inventory += hud.vampire_blood_display
			hud.show_hud(hud.hud_version)
//		hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#ce0202'>[bloodusable]</font></div>"


#undef BRAIN_DRAIN_LIMIT
#undef DRAIN_TIME
