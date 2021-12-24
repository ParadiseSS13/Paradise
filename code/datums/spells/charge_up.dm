/**
 * A click-based spell template which starts charging up once you click the action button/verb. Click again on something to activate the actual spell
 */

/obj/effect/proc_holder/spell/charge_up
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

/obj/effect/proc_holder/spell/charge_up/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /mob/living
	T.try_auto_target = FALSE
	return T

/obj/effect/proc_holder/spell/charge_up/Click()
	if(cast_check(TRUE, FALSE, usr))
		if(!start_time)
			INVOKE_ASYNC(src, .proc/StartChargeup, usr)
		else
			if(!try_stop_buildup(usr))
				return // Don't remove the click intercept

	return ..()

/obj/effect/proc_holder/spell/charge_up/proc/try_stop_buildup(mob/user)
	var/energy_perc = get_energy_charge() / max_charge_time
	if(energy_perc < 0.5)
		charge_counter = (1 - energy_perc) * charge_max // Give them some charge back
		to_chat(user, "<span class='notice'>[stop_charging_text]</span>")
		Reset(user)
		start_recharge()
		return TRUE
	else
		to_chat(user, "<span class='danger'>[stop_charging_fail_text]</span>")
		return FALSE

/obj/effect/proc_holder/spell/charge_up/proc/get_energy_charge()
	return min(world.time - start_time, max_charge_time)

/obj/effect/proc_holder/spell/charge_up/proc/StartChargeup(mob/user)
	to_chat(user, "<span class='notice'>[start_charging_text]</span>")
	user.add_overlay(charge_up_overlay)
	playsound(user, charge_sound, 50, FALSE, channel = charge_sound.channel)
	start_time = world.time
	if(do_mob(user, user, max_charge_time, extra_checks = list(CALLBACK(src, .proc/stopped_casting)), only_use_extra_checks = TRUE))
		if(start_time)
			Discharge(user)

/obj/effect/proc_holder/spell/charge_up/proc/stopped_casting()
	return start_time == 0

/obj/effect/proc_holder/spell/charge_up/proc/Reset(mob/user)
	start_time = 0
	user.cut_overlay(charge_up_overlay)
	remove_ranged_ability(user)
	playsound(user, null, 50, FALSE, channel = charge_sound.channel)

/obj/effect/proc_holder/spell/charge_up/revert_cast(mob/user)
	Reset(user)
	..()

/obj/effect/proc_holder/spell/charge_up/proc/Discharge(mob/user)
	to_chat(user, "<span class='danger'>You lose control over the spell!</span>")
	Reset(user)
	spend_spell_cost(user)
	start_recharge()

/obj/effect/proc_holder/spell/charge_up/after_cast(list/targets, mob/user)
	..()
	Reset(user)
