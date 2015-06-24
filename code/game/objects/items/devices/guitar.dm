//copy pasta of the space piano, don't hurt me -Pete

/obj/item/device/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon = 'icons/obj/musician.dmi'
	icon_state = "guitar"
	item_state = "guitar"
	icon_override = 'icons/mob/in-hand/tools.dmi'
	force = 10
	var/datum/song/handheld/song
	hitsound = 'sound/effects/guitarsmash.ogg'

/obj/item/device/guitar/New()
	song = new("guitar", src)
	song.instrumentExt = "ogg"

/obj/item/device/guitar/Destroy()
	del(song)
	song = null
	..()

/obj/item/device/guitar/attack_self(mob/user as mob)
	interact(user)

/obj/item/device/guitar/interact(mob/user as mob)
	if(!user)
		return

	if(!isliving(user) || user.stat || user.restrained() || user.lying)
		return

	user.set_machine(src)
	song.interact(user)

/datum/table_recipe/guitar
	name = "Guitar"
	result = /obj/item/device/guitar
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(/obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters)
	time = 80