// This is a file with all the power that buff or heal a mindflayer in some way

/obj/effect/proc_holder/spell/flayer/self/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/flayer/self/rejuv
	name = "Rejuvenate"
	desc = "Add me!"
	power_type = FLAYER_INNATE_POWER

/obj/effect/proc_holder/spell/flayer/self/rejuv/cast(list/targets, mob/user)
	to_chat(user, "<span class='notice'>We begin to heal rapidly.</span>")
	var/mob/living/caster = user
	caster.apply_status_effect(STATUS_EFFECT_FLAYER_REJUV)
