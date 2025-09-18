/obj/item/melee/classic_baton/telescopic/contractor
	name = "contractor baton"
	desc = "A compact, specialised baton issued to Syndicate contractors. Applies light electrical shocks to targets."
	icon_state = "contractor_baton_0" // For telling what it is when mapping
	// Overrides
	affect_silicon = TRUE
	knockdown_duration = 4 SECONDS
	cooldown = 2.5 SECONDS
	stamina_damage = 70
	stamina_armor_pen = 100
	force_off = 5
	force_on = 15
	worn_icon_state_on = "contractor_baton"
	inhand_icon_state_on = "contractor_baton"
	icon_state_off = "contractor_baton_0"
	icon_state_on = "contractor_baton_1"
	stun_sound = 'sound/weapons/contractorbatonhit.ogg'
	extend_sound = 'sound/weapons/contractorbatonextend.ogg'
	// Settings
	/// Jitter to deal on stun.
	var/jitter_amount = 5 SECONDS
	/// Stutter to deal on stun.
	var/stutter_amount = 10 SECONDS

/obj/item/melee/classic_baton/telescopic/contractor/baton_knockdown(mob/living/target, mob/living/user)
	. = ..()
	target.Jitter(jitter_amount)
	target.AdjustStuttering(stutter_amount)
