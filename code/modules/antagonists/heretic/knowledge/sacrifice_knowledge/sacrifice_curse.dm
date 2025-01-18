/// A curse given to people to disencourage them from retaliating against someone who sacrificed them
/datum/status_effect/heretic_curse
	id = "heretic_curse"
	alert_type = null
	status_type = STATUS_EFFECT_MULTIPLE // In case several different people sacrifice you, unlucky
	/// Who cursed us?
	var/mob/living/the_curser
	/// Don't experience bad things too often
	COOLDOWN_DECLARE(consequence_cooldown)

/datum/status_effect/heretic_curse/on_creation(mob/living/new_owner, mob/living/the_curser)
	src.the_curser = the_curser
	return ..()

/datum/status_effect/heretic_curse/Destroy()
	the_curser = null
	return ..()

/datum/status_effect/heretic_curse/on_apply()
	if(isnull(the_curser) || !iscarbon(owner))
		return FALSE
	message_admins(" QWERTODO: MAKE THIS CURSE DO SOMETHING THIS IS TOO MANY SIGNALS")

