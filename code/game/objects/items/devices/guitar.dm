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
