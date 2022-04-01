/datum/snake_fashion
	var/name
	var/desc
	var/emote_see
	var/emote_hear
	var/speak
	var/speak_emote

	// This isn't applied to the snake, but stores the icon_state of the
	// sprite that the associated item uses
	var/icon_file
	var/obj_icon_state
	var/icon_state
	var/icon_living
	var/icon_dead
	var/obj_alpha
	var/obj_color

/datum/snake_fashion/New(mob/M)
	name = replacetext(name, "REAL_NAME", M.real_name)
	desc = replacetext(desc, "NAME", name)

/datum/snake_fashion/proc/apply(mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/D)
	if(name)
		D.name = name
	if(desc)
		D.desc = desc
	if(emote_see)
		D.emote_see = emote_see
	if(emote_hear)
		D.emote_hear = emote_hear
	if(speak)
		D.speak = speak
	if(speak_emote)
		D.speak_emote = speak_emote

/datum/snake_fashion/proc/get_overlay()
	if(icon_file && obj_icon_state)
		var/image/snek = image(icon_file, obj_icon_state)
		snek.alpha = obj_alpha
		snek.color = obj_color
		return snek

/datum/snake_fashion/head
	icon_file = 'icons/mob/syndie_snake_hats.dmi'

/datum/snake_fashion/head/beret_hos_black
	name = "Ля Руж"
	desc = "Mon Dieu! C'est un serpent à trois têtes!"
	speak = list("le shhh!")
	emote_see = list("трясётся в наигранном страхе.", "сдаётся.","устраивает тихую битву между своими головами.", "притворяется мёртвой.","ведёт себя так будто перед ней невидимая стенка.")

