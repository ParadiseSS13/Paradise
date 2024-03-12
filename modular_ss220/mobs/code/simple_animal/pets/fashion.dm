/obj/item
	var/datum/muhtar_fashion/muhtar_fashion = null
	var/datum/snake_fashion/snake_fashion = null

/// Muhtar fashion
/datum/muhtar_fashion
	var/name
	var/desc
	var/emote_see
	var/emote_hear
	var/speak
	var/speak_emote

	// This isn't applied to the dog, but stores the icon_state of the
	// sprite that the associated item uses
	var/icon_file
	var/obj_icon_state
	var/obj_alpha
	var/obj_color

/datum/muhtar_fashion/New(mob/M)
	name = replacetext(name, "REAL_NAME", M.real_name)
	desc = replacetext(desc, "NAME", name)

/datum/muhtar_fashion/proc/apply(mob/living/simple_animal/pet/dog/D)
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

/datum/muhtar_fashion/proc/get_overlay(dir)
	if(icon_file && obj_icon_state)
		var/image/muhtar = image(icon_file, obj_icon_state, dir = dir)
		muhtar.alpha = obj_alpha
		muhtar.color = obj_color
		return muhtar

// Item datums
/datum/muhtar_fashion/head
	icon_file = 'modular_ss220/mobs/icons/muhtar_accessories.dmi'

/datum/muhtar_fashion/mask
	icon_file = 'modular_ss220/mobs/icons/muhtar_accessories.dmi'

/datum/muhtar_fashion/head/detective
	name = "Детектив REAL_NAME"
	desc = "NAME sees through your lies..."
	emote_see = list("investigates the area.","sniffs around for clues.","searches for scooby snacks.","takes a candycorn from the hat.")

/datum/muhtar_fashion/mask/cigar
	obj_icon_state = "cigar"

/datum/muhtar_fashion/head/beret
	name = "Лейтенант REAL_NAME"
	obj_icon_state = "beret"

// Muhtar items
/obj/item/clothing/mask/cigarette/cigar
	muhtar_fashion = /datum/muhtar_fashion/mask/cigar

/obj/item/clothing/head/det_hat
	muhtar_fashion = /datum/muhtar_fashion/head/detective

/obj/item/clothing/head/beret/sec
	muhtar_fashion = /datum/muhtar_fashion/head/beret

/// Snake fashion
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

// Item datums
/datum/snake_fashion/head
	icon_file = 'modular_ss220/mobs/icons/rouge_accessories.dmi'

/datum/snake_fashion/head/beret_hos_black
	name = "Ля Руж"
	desc = "Mon Dieu! C'est un serpent à trois têtes!"
	speak = list("le shhh!")
	emote_see = list("трясётся в наигранном страхе.", "сдаётся.","устраивает тихую битву между своими головами.", "притворяется мёртвой.","ведёт себя так будто перед ней невидимая стенка.")

// Rouge items
/obj/item/clothing/head/HoS/beret
	snake_fashion = /datum/snake_fashion/head/beret_hos_black
