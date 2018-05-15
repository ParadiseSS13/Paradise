
/*

Contents:
- The Ninja Space Mask
- Ninja Space Mask speech modification

*/




/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	strip_delay = 120
	burn_state = LAVA_PROOF
	unacidable = TRUE
	species_fit = list("Vox", "Unathi", "Tajaran", "Vulpkanin")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi')
	actions_types = list(/datum/action/item_action/toggle_voice_changer, /datum/action/item_action/change_voice, /datum/action/item_action/toggle_voice_scramble)
	var/scramble_voice = TRUE

/obj/item/clothing/mask/gas/voice/space_ninja/ui_action_click(mob/user, action)
	if(..())
		return FALSE
	if(istype(action, /datum/action/item_action/toggle_voice_scramble))
		toggle_voice_scramble(user)
		return TRUE
	return FALSE

/obj/item/clothing/mask/gas/voice/space_ninja/proc/toggle_voice_scramble(mob/user)
	scramble_voice = !scramble_voice
	to_chat(user, "<span class='notice'>You [scramble_voice ? "enable" : "disable"] the voice scrambling module.</span>")

/obj/item/clothing/mask/gas/voice/space_ninja/speechModification(message)
	if(scramble_voice)
		if(copytext(message, 1, 2) != "*")
			var/list/temp_message = splittext(message, " ")
			var/list/pick_list = list()
			for(var/i = 1, i <= temp_message.len, i++)
				pick_list += i
			for(var/i=1, i <= abs(temp_message.len/3), i++)
				var/H = pick(pick_list)
				if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":"))
					continue
				temp_message[H] = ninjaspeak(temp_message[H])
				pick_list -= H
			message = jointext(temp_message, " ")
			message = replacetext(message, "o", "#")
			message = replacetext(message, "p", "@")
			message = replacetext(message, "l", "|")
			message = replacetext(message, "s", "$")
			message = replacetext(message, "u", "^")
			message = replacetext(message, "b", "#")
	return message

/obj/item/clothing/mask/gas/voice/space_ninja/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == slot_wear_mask)
		for(var/datum/atom_hud/antag/H in huds)
			H.add_hud_to(user)

/obj/item/clothing/mask/gas/voice/space_ninja/dropped(mob/living/carbon/human/user)
	..()
	if(istype(user) && user.wear_mask == src)
		for(var/datum/atom_hud/antag/H in huds)
			H.remove_hud_from(user)

/proc/ninjaspeak(n)
/*
The difference with stutter is that this proc can stutter more than 1 letter
The issue here is that anything that does not have a space is treated as one word (in many instances). For instance, "LOOKING," is a word, including the comma.
It's fairly easy to fix if dealing with single letters but not so much with compounds of letters./N
*/
	var/te = html_decode(n)
	var/t = ""
	n = length(n)
	var/p = 1
	while(p <= n)
		var/n_letter
		var/n_mod = rand(1,4)
		if(p+n_mod>n+1)
			n_letter = copytext(te, p, n+1)
		else
			n_letter = copytext(te, p, p+n_mod)
		if (prob(50))
			if (prob(30))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]")
			else
				n_letter = text("[n_letter]-[n_letter]")
		else
			n_letter = text("[n_letter]")
		t = text("[t][n_letter]")
		p=p+n_mod
	return sanitize(copytext(t, 1, MAX_MESSAGE_LEN))