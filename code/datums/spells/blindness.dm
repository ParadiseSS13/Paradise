/datum/spell/aoe/blindness
	name = "Blindness"
	desc = "Your prey will be momentarily blind for you to advance on them."

	message = SPAN_NOTICE("You glare your eyes.")
	base_cooldown = 600
	clothes_req = FALSE
	aoe_range = 10

/datum/spell/aoe/blindness/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()
	targeting.range = aoe_range
	targeting.allowed_type = /mob/living
	return targeting

/datum/spell/aoe/blindness/cast(list/targets, mob/user = usr)
	for(var/mob/living/L in targets)
		if(istype(L, /mob/living/basic/hostile/statue))
			continue
		L.EyeBlind(8 SECONDS)
