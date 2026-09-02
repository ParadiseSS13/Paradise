/datum/action/innate/web_giant_spider
	name = "Lay Web"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "stickyweb1"

/datum/action/innate/web_giant_spider/Activate()
	var/mob/living/basic/giant_spider/user = owner
	user.create_web()

/datum/action/innate/wrap_giant_spider
	name = "Wrap"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "cocoon_large1"

/datum/action/innate/wrap_giant_spider/Activate()
	var/mob/living/basic/giant_spider/nurse/user = owner
	user.wrap_target()

/datum/action/innate/lay_eggs_giant_spider
	name = "Lay Eggs"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "eggs"

/datum/action/innate/lay_eggs_giant_spider/Activate()
	var/mob/living/basic/giant_spider/nurse/user = owner
	user.lay_spider_eggs()
