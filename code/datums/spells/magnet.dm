/datum/spell/charge_up/bounce/magnet
	name = "Magnetic Pull"
	desc = "Pulls metallic objects from enemies hands with the power of MAGNETS."
	action_icon_state = "magnet"
	base_cooldown	= 30 SECONDS
	clothes_req = FALSE
	invocation = "UN'LTD P'WAH!"
	cooldown_min = 3 SECONDS
	charge_sound = new /sound('sound/magic/lightning_chargeup.ogg', channel = 7)
	max_charge_time = 10 SECONDS
	stop_charging_text = "You stop charging the magnetism around you."
	stop_charging_fail_text = "The magnetism around you is too strong to stop now!"
	start_charging_text = "You start gathering magnetism around you."
	bounce_hit_sound = 'sound/machines/defib_zap.ogg'

/datum/spell/charge_up/bounce/magnet/New()
	..()
	charge_up_overlay = image(icon = 'icons/effects/effects.dmi', icon_state = "electricity", layer = EFFECTS_LAYER)

/datum/spell/charge_up/bounce/magnet/get_bounce_energy()
	return get_energy_charge()

/datum/spell/charge_up/bounce/magnet/get_bounce_amount()
	if(get_energy_charge() >= 75)
		return 5
	return 0

/datum/spell/charge_up/bounce/magnet/create_beam(mob/origin, mob/target)
	origin.Beam(target, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5)

/datum/spell/charge_up/bounce/magnet/apply_bounce_effect(mob/origin, mob/target, energy, mob/user)
	var/list/items_to_throw = list()
	switch(energy)
		if(0 to 25)
			if(prob(50))
				if(target.l_hand)
					items_to_throw += target.l_hand
			else
				if(target.r_hand)
					items_to_throw += target.r_hand
		if(25 to INFINITY)
			if(target.r_hand)
				items_to_throw += target.r_hand
			if(target.l_hand)
				items_to_throw += target.l_hand
	for(var/I in items_to_throw)
		try_throw_object(user, target, I)

/datum/spell/charge_up/bounce/magnet/proc/try_throw_object(mob/user, mob/thrower, obj/item/to_throw)
	if(!(to_throw.flags & CONDUCT) || !thrower.drop_item_to_ground(to_throw, silent = TRUE))
		return FALSE
	thrower.visible_message("<span class='warning'>[to_throw] gets thrown out of [thrower] [thrower.p_their()] hands!</span>",
		"<span class='danger'>[to_throw] suddenly gets thrown out of your hands!</span>")
	to_throw.throw_at(user, to_throw.throw_range, 4)
	return TRUE
