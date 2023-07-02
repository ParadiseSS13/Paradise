//Small sprites
/datum/action/innate/small_sprite_dragon
	name = "Toggle Giant Sprite"
	desc = "Остальные продолжат видеть вас огромным."
	button_icon_state = "carp"
	background_icon_state = "bg_alien"
	var/small = FALSE
	var/small_icon = 'icons/mob/carp.dmi'
	var/small_icon_state = "carp"

/datum/action/innate/small_sprite_dragon/Trigger()
	..()
	if(!small)
		var/image/I = image(icon = small_icon, icon_state = small_icon_state, loc = owner)
		I.override = TRUE
		I.pixel_x -= owner.pixel_x
		I.pixel_y -= owner.pixel_y
		owner.add_alt_appearance("smallsprite", I, list(owner))
		small = TRUE
	else
		owner.remove_alt_appearance("smallsprite")
		small = FALSE

/datum/action/innate/space_dragon_gust
	name = "Gust"
	desc = "Эта способность отталкивает всех, кто находится рядом с вами."
	button_icon_state = "repulse"
	background_icon_state = "bg_alien"
	var/mob/living/simple_animal/hostile/space_dragon/space_dragon

/datum/action/innate/space_dragon_gust/Grant(mob/M)
	. = ..()
	if(!M)
		return
	if(istype(owner, /mob/living/simple_animal/hostile/space_dragon))
		space_dragon = owner

/datum/action/innate/space_dragon_gust/Remove(mob/M)
	. = ..()
	if(!M)
		return
	space_dragon = null

/datum/action/innate/space_dragon_gust/Trigger()
	. = ..()
	space_dragon?.try_gust()
