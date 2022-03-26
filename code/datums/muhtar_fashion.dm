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

/datum/muhtar_fashion/proc/get_overlay(var/dir)
	if(icon_file && obj_icon_state)
		var/image/muhtar = image(icon_file, obj_icon_state, dir = dir)
		muhtar.alpha = obj_alpha
		muhtar.color = obj_color
		return muhtar


/datum/muhtar_fashion/head
	icon_file = 'icons/mob/muhtar_accessories.dmi'

/datum/muhtar_fashion/mask
	icon_file = 'icons/mob/muhtar_accessories.dmi'

/datum/muhtar_fashion/head/detective
	name = "Детектив REAL_NAME"
	desc = "NAME sees through your lies..."
	emote_see = list("investigates the area.","sniffs around for clues.","searches for scooby snacks.","takes a candycorn from the hat.")

/datum/muhtar_fashion/mask/cigar
	obj_icon_state = "cigar"


/datum/muhtar_fashion/head/beret
	name = "Лейтенант REAL_NAME"
	obj_icon_state = "beret"
