/obj/item/melee/classic_baton/telescopic/contractor
	name = "contractor baton"
	desc = "A compact, specialised baton issued to Syndicate contractors. Applies light electrical shocks to targets."
	// Overrides
	affect_silicon = TRUE
	stun_time = 1
	cooldown = 2.5 SECONDS
	force_off = 5
	force_on = 15
	item_state_on = "contractor_baton"
	icon_state_off = "contractor_baton_0"
	icon_state_on = "contractor_baton_1"
	stun_sound = 'sound/weapons/contractorbatonhit.ogg'
	extend_sound = 'sound/weapons/contractorbatonextend.ogg'
	// Settings
	/// Stamina damage to deal on stun.
	var/stamina_damage = 70
	/// Jitter to deal on stun.
	var/jitter_amount = 5 SECONDS_TO_JITTER
	/// Stutter to deal on stun.
	var/stutter_amount = 10 SECONDS_TO_LIFE_CYCLES

/obj/item/melee/classic_baton/telescopic/contractor/stun(mob/living/target, mob/living/user)
	. = ..()
	target.adjustStaminaLoss(stamina_damage)
	target.Jitter(jitter_amount)
	target.AdjustStuttering(stutter_amount)
