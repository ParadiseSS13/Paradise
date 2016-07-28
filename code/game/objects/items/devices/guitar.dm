//copy pasta of the space piano, don't hurt me -Pete

/obj/item/device/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon = 'icons/obj/musician.dmi'
	icon_state = "guitar"
	item_state = "guitar"
	force = 10
	var/datum/song/handheld/song
	hitsound = 'sound/effects/guitarsmash.ogg'

/obj/item/device/guitar/New()
	song = new("guitar", src)
	song.instrumentExt = "ogg"

/obj/item/device/guitar/Destroy()
	qdel(song)
	song = null
	return ..()

/obj/item/device/guitar/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/device/guitar/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(!user)
		return

	if(!isliving(user) || user.stat || user.restrained() || user.lying)
		return

	song.ui_interact(user, ui_key, ui, force_open)

/obj/item/device/guitar/Topic(href, href_list)
	song.Topic(href, href_list)

/datum/crafting_recipe/guitar
	name = "Guitar"
	result = /obj/item/device/guitar
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(/obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters)
	time = 80