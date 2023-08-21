/datum/antagonist/mindflayer
	name = "Mind Flayer"
//	antag_hud_type = ANTAG_HUD_MIND_FLAYER
	antag_hud_name = "hudflayer"
	special_role = SPECIAL_ROLE_MIND_FLAYER
	wiki_page_name = "Mind Flayer"
	///The current amount of swarms the mind flayer has access to purchase with
	var/usable_swarms = 0
	///The total points of brain damage the flayer has harvested, only used for logging purposes.
	var/total_swarms_gathered = 0
	///The current person being drained
	var/mob/living/carbon/human/harvesting
	///The list of all purchased powers
	var/list/powers = list()
	/// The list of all innate powers
	var/list/innate_powers = list(/obj/effect/proc_holder/spell/flayer/weapon/swarmprod, /datum/mindflayer_passive/new_crit, /obj/effect/proc_holder/spell/flayer/self/rejuv) // They won't get newcrit for being a mindflayer, I just like having it during testing
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

/datum/antagonist/mindflayer/proc/set_swarms(amount, update_total = FALSE) //If you adminbus someone's swarms it won't add or remove to the total
	var/old_swarm_amount = usable_swarms
	usable_swarms = amount
	if(update_total)
		var/difference = usable_swarms - old_swarm_amount
		total_swarms_gathered += difference

/datum/antagonist/mindflayer/proc/adjust_swarms(amount, bound_lower = 0, bound_upper = INFINITY)
	set_swarms(directional_bounded_sum(usable_swarms, amount, bound_lower, bound_upper), TRUE)

//This is mostly for flavor, for framing messages as coming from the swarm itself.
/datum/antagonist/mindflayer/proc/send_swarm_message(message)
	to_chat(owner.current, "<span class='boldnotice'>Your parasites whisper to you...</span>")
	to_chat(owner.current, "<span class='sinister'>\"" + message + "\"</span>")

/**
	Checks for any reason that you should not be able to drain someone for.
	Returns either true or false, if the harvest will work or not.
*/
/datum/antagonist/mindflayer/proc/check_valid_harvest(mob/living/carbon/human/H)
	var/obj/item/organ/internal/brain/brain = H.get_int_organ(/obj/item/organ/internal/brain)
	if(!brain)
		send_swarm_message("This entity has no brain to harvest from.")
		return FALSE
/** Uncomment this when it won't make testing horrible
	if(!H.ckey || !H.player_ghosted)
		send_swarm_message("This brain does not contain the spark that feeds us. Find more suitable prey.")
**/
	if(brain.damage >= 120)
		send_swarm_message("We detect no neural activity to harvest from this brain.")
		return FALSE
	var/unique_drain_id = H.UID()
	if(!(drained_humans[unique_drain_id]))
		drained_humans[unique_drain_id] = 0
	else
		return drained_humans[unique_drain_id] <= BRAIN_DRAIN_LIMIT //TODO better feedback on trying to drain past the limit
	return TRUE

/**
	Begins draining the brain of H, gains swarms equal to the amount of brain damage dealt per tick. Upgrades can increase the amount of damage per tick.
**/
/datum/antagonist/mindflayer/proc/handle_harvest(mob/living/carbon/human/H)
	harvesting = H
	var/drain_total_damage = 0
	var/obj/item/organ/internal/brain/drained_brain = H.get_int_organ(/obj/item/organ/internal/brain)
	var/unique_drain_id = H.UID()
	owner.current.visible_message("<span class='danger'>[owner.current] puts [owner.current.p_their()] fingers on [H]'s [drained_brain.parent_organ] and begins harvesting their brain!</span>", "<span class='sinister'>We begin our harvest on [H]</span>", "<span class='notice'>You hear the hum of electricity.</span>")
	while(do_mob(owner.current, H, time = DRAIN_TIME, progress = FALSE) && check_valid_harvest(H))
		H.Beam(owner.current, icon_state = "drain_life", icon ='icons/effects/effects.dmi', time = DRAIN_TIME)
		var/damage_to_deal = (1/2 * drain_multiplier * H.dna.species.brain_mod) // Change that first fraction for adjusting the balance of how much damage it deals
		H.adjustBrainLoss(damage_to_deal, use_brain_mod = FALSE)
		adjust_swarms(damage_to_deal)
		drained_humans[unique_drain_id] += damage_to_deal
		drain_total_damage += damage_to_deal //TODO, give some sort of effect/max HP loss based on how high this ends up
	send_swarm_message("We have stopped receiving energy from [H].")
	harvesting = null

/**
 * Gives the mind_flayer the passed in `power`. Subtracts the cost of the power from our swarms.
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

// This proc adds extra things that the mindflayer should get upon becoming a mindflayer
/datum/antagonist/mindflayer/on_gain()
	. = ..()
	for(var/path in innate_powers)
		powers += path
		add_ability(path)


/datum/antagonist/mindflayer/greet()
	var/dat
	SEND_SOUND(owner.current, sound('sound/ambience/antag/vampalert.ogg'))
	dat = "<span class='danger'>You are a mindflayer!</span><br>" // TODO: Add actual description
	dat += {"To harvest someone, target where the brain of your victim is and use harm intent with an empty hand. Drain intelligence to increase your swarm.
		You are weak to holy things, starlight and fire. Don't go into space and avoid the Chaplain, the chapel and especially Holy Water."}
	to_chat(owner.current, dat)

/datum/antagonist/mindflayer/proc/add_ability(path)
//	if(!get_ability(path)) TODO: make a working check for if the mindflayer already has the spell you're trying to add
	force_add_ability(path)

/datum/antagonist/mindflayer/proc/force_add_ability(path)
	var/spell = new path(owner)
	if(istype(spell, /obj/effect/proc_holder/spell))
		owner.AddSpell(spell)
	if(istype(spell, /datum/mindflayer_passive))
		var/datum/mindflayer_passive/passive = spell
		passive.owner = owner.current
		passive.on_apply(src)
	powers += spell

/datum/antagonist/mindflayer/proc/remove_ability(path)
	if(get_ability(path))
		force_remove_ability(path)

/datum/antagonist/mindflayer/proc/force_remove_ability(path)
	var/spell = new path(owner)
	if(istype(spell, /obj/effect/proc_holder/spell))
		owner.RemoveSpell(spell)
	if(istype(spell, (/datum/mindflayer_passive)))
		var/datum/mindflayer_passive/passive = spell
		passive.on_remove(src)
	powers -= spell

/datum/antagonist/mindflayer/proc/get_ability(path)
	for(var/datum/power as anything in powers)
		if(power == path)
			return power
	return null

/*
/datum/hud/proc/remove_mindflayer_hud() TODO: make this remove the mindflayer hud
	static_inventory -= vampire_blood_display
	QDEL_NULL(vampire_blood_display)
*/
// This is the proc that gets called every tick of life(), use this for updating something that should update every few seconds
/datum/antagonist/mindflayer/proc/handle_mindflayer()
	if(owner.current.hud_used)
		var/datum/hud/hud = owner.current.hud_used
		if(!hud.vampire_blood_display)
			hud.vampire_blood_display = new /obj/screen()
			hud.vampire_blood_display.name = "Usable Swarms"
			hud.vampire_blood_display.icon_state = "blood_display"
			hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
			hud.static_inventory += hud.vampire_blood_display
			hud.show_hud(hud.hud_version)
		hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#ce0202'>[usable_swarms]</font></div>"


#undef BRAIN_DRAIN_LIMIT
#undef DRAIN_TIME
