/**
 * A click-based spell template which starts charging up once you click the action button/verb. Click again on something to activate the actual spell
 */

/datum/spell/charge_up
	var/start_time = 0
	/// The overlay used to show that you are charging. Create this in the New of the spell
	var/image/charge_up_overlay
	/// How long you can charge for
	var/max_charge_time
	/// The sound charging up your power will make. Be sure to include a channel when creating the sound
	var/sound/charge_sound
	/// The text shown when you start charging
	var/start_charging_text
	/// The text shown when you successfully stop charging
	var/stop_charging_text
	/// The text shown when you are over the charge limit and thus can't stop.
	var/stop_charging_fail_text

/datum/spell/charge_up/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /mob/living
	T.try_auto_target = FALSE
	return T

/datum/spell/charge_up/Click()
	if(cast_check(TRUE, FALSE, usr))
		if(!start_time)
			INVOKE_ASYNC(src, PROC_REF(StartChargeup), usr)
		else
			if(!try_stop_buildup(usr))
				return // Don't remove the click intercept

	return ..()

/datum/spell/charge_up/proc/try_stop_buildup(mob/user)
	var/energy_perc = get_energy_charge() / max_charge_time
	if(energy_perc < 0.5)
		cooldown_handler.start_recharge((1 - energy_perc) * cooldown_handler.recharge_duration) // Shorten the cooldown based on how long it was charged for.
		to_chat(user, "<span class='notice'>[stop_charging_text]</span>")
		Reset(user)
		return TRUE
	else
		to_chat(user, "<span class='danger'>[stop_charging_fail_text]</span>")
		return FALSE

/datum/spell/charge_up/proc/get_energy_charge()
	return min(world.time - start_time, max_charge_time)

/datum/spell/charge_up/proc/StartChargeup(mob/user)
	to_chat(user, "<span class='notice'>[start_charging_text]</span>")
	user.add_overlay(charge_up_overlay)
	playsound(user, charge_sound, 50, FALSE, channel = charge_sound.channel)
	start_time = world.time
	if(do_mob(user, user, max_charge_time, extra_checks = list(CALLBACK(src, PROC_REF(stopped_casting))), only_use_extra_checks = TRUE))
		if(start_time)
			Discharge(user)

/datum/spell/charge_up/proc/stopped_casting()
	return start_time == 0

/datum/spell/charge_up/proc/Reset(mob/user)
	start_time = 0
	user.cut_overlay(charge_up_overlay)
	remove_ranged_ability(user)
	playsound(user, null, 50, FALSE, channel = charge_sound.channel)

/datum/spell/charge_up/revert_cast(mob/user)
	Reset(user)
	..()

/datum/spell/charge_up/proc/Discharge(mob/user)
	to_chat(user, "<span class='danger'>You lose control over the spell!</span>")
	Reset(user)
	spend_spell_cost(user)
	cooldown_handler.start_recharge()

/datum/spell/charge_up/after_cast(list/targets, mob/user)
	..()
	Reset(user)
