//copy pasta of the space piano, don't hurt me -Pete

/obj/item/device/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon = 'icons/obj/musician.dmi'
	icon_state = "violin"
	item_state = "violin"
	attack_verb = list("strung", "fiddled", "tuned", "pitched")
	force = 10
	burn_state = FLAMMABLE
	burntime = 20
	hitsound = 'sound/weapons/smash.ogg'
	var/datum/song/handheld/song

/obj/item/device/violin/New()
	song = new("violin", src)
	song.instrumentExt = "ogg"

/obj/item/device/violin/Destroy()
	qdel(song)
	song = null
	return ..()

/obj/item/device/violin/initialize()
	song.tempo = song.sanitize_tempo(song.tempo) // tick_lag isn't set when the map is loaded
	..()

/obj/item/device/violin/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/device/violin/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(!user)
		return

	if(!isliving(user) || user.stat || user.restrained() || user.lying)
		return

	song.ui_interact(user, ui_key, ui, force_open)

/obj/item/device/violin/Topic(href, href_list)
	song.Topic(href, href_list)
