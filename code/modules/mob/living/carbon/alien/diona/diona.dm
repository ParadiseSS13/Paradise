/mob/living/carbon/alien/diona
	name = "diona nymph"
	voice_name = "diona nymph"
	adult_form = /mob/living/carbon/human
	speak_emote = list("chirrups")
	icon_state = "nymph"
	language = "Rootspeak"

	universal_understand = 1
	universal_speak = 0      // Dionaea do not need to speak to people other than other dionaea.
	holder_type = /obj/item/weapon/holder/diona

/mob/living/carbon/alien/diona/New()

	..()
	species = all_species["Diona"]
	verbs += /mob/living/carbon/alien/diona/proc/merge

/mob/living/carbon/alien/diona/start_pulling(var/atom/movable/AM)
	//TODO: Collapse these checks into one proc (see pai and drone)
	if(istype(AM,/obj/item))
		var/obj/item/O = AM
		if(O.w_class > 2)
			src << "<span class='warning'>You are too small to pull that.</span>"
			return
		else
			..()
	else
		src << "<span class='warning'>You are too small to pull that.</span>"
		return

/mob/living/carbon/alien/diona/put_in_hands(var/obj/item/W) // No hands.
	W.loc = get_turf(src)
	return 1
