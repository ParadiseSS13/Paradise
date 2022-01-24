/obj/effect/proc_holder/spell/charge_up/bounce/lightning
	name = "Lightning Bolt"
	desc = "Throws a lightning bolt at your enemies. Classic. When clicked will start to charge in power. Then click on a mob to send the bolt before it overloads with power."
	charge_type = "recharge"
	charge_max	= 30 SECONDS
	clothes_req = TRUE
	invocation = "UN'LTD P'WAH!"
	invocation_type = "shout"
	cooldown_min = 3 SECONDS
	action_icon_state = "lightning"
	charge_sound = new /sound('sound/magic/lightning_chargeup.ogg', channel = 7)
	max_charge_time = 10 SECONDS
	stop_charging_text = "You stop charging the lightning around you."
	stop_charging_fail_text = "The lightning around you is too strong to stop now!"
	start_charging_text = "You start gathering lightning around you."
	bounce_hit_sound = 'sound/magic/lightningshock.ogg'
	var/damaging = TRUE

/obj/effect/proc_holder/spell/charge_up/bounce/lightning/New()
	..()
	charge_up_overlay = image(icon = 'icons/effects/effects.dmi', icon_state = "electricity", layer = EFFECTS_LAYER)

/obj/effect/proc_holder/spell/charge_up/bounce/lightning/lightnian
	clothes_req = FALSE
	invocation_type = "none"
	damaging = FALSE

/obj/effect/proc_holder/spell/charge_up/bounce/lightning/get_bounce_energy()
	if(damaging)
		return max(15, get_energy_charge() / 2)
	return 0

/obj/effect/proc_holder/spell/charge_up/bounce/lightning/get_bounce_amount()
	if(damaging)
		return 5
	return round(get_energy_charge() / 20)

/obj/effect/proc_holder/spell/charge_up/bounce/lightning/create_beam(mob/origin, mob/target)
	origin.Beam(target, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5)

/obj/effect/proc_holder/spell/charge_up/bounce/lightning/apply_bounce_effect(mob/origin, mob/living/target, energy, mob/user)
	if(damaging)
		target.electrocute_act(energy, "Lightning Bolt", flags = SHOCK_NOGLOVES)
	else
		target.AdjustJitter(1000) //High numbers for violent convulsions
		target.do_jitter_animation(target.jitteriness)
		target.AdjustStuttering(2)
		target.Slowed(3)
		addtimer(CALLBACK(target, /mob/.proc/AdjustJitter, -1000, 10), 2 SECONDS) //Still jittery, but vastly less
