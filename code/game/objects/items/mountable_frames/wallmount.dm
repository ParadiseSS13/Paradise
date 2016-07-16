/obj/item/mounted/frame/wall_mount
	name = "wooden wall mount"
	desc = "Used to hang your old hunting trophies. "
	icon = 'icons/obj/objects.dmi'
	icon_state = "wallmount"
	item_state = "wallmount"
	anchored = 0
	var/initial_name = "wooden wall mount"
	var/initial_desc = "Used to hang your old hunting trophies. "
	var/has_trophy = 0
	var/trophy_id
	var/descammend

/obj/item/mounted/frame/wall_mount/do_build(turf/on_wall, mob/user)
	to_chat(user, "<span class='notice'>You begin attaching the mount to the wall...</span>")
	if(do_after(user, 50, target = src))
		to_chat(user, "<span class='notice'>You attach the mount to the wall.</span>")
		var/obj/item/mounted/frame/wall_mount/M = new /obj/item/mounted/frame/wall_mount(get_turf(src), get_dir(on_wall, user), 1)
		M.pixel_y -= (loc.y - on_wall.y) * 32
		M.pixel_x -= (loc.x - on_wall.x) * 32
		M.anchored = 1
		qdel(src)

/obj/item/mounted/frame/wall_mount/attack_hand(mob/user) //Dumb, I know
	if(anchored)
		return
	else
		..()

/obj/item/mounted/frame/wall_mount/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/trophy))
		if(anchored)
			var/obj/item/weapon/trophy/T = W
			if(!has_trophy)
				icon_state = "wallmount_[T.id]"
				name = "[T.id] trophy head"
				descammend = "There is a [T.id] trophy head on this one."
				desc += descammend
				has_trophy = 1
				trophy_id = T.id
				qdel(T)
				to_chat(user, "<span class='notice'>You attach the [T.id] trophy head to the mount.</span>")
			else
				to_chat(user, "<span class='warning'>There is already a trophy on this mount!</span>")
				return
		else
			to_chat(user, "<span class='warning'>The mount isn't attached to a wall!</span>")
			return
	else if(istype(W, /obj/item/weapon/wrench))
		if(anchored)
			to_chat(user, "<span class='notice'>You begin to detach the mount from the wall...</span>")
			if(do_after(user, 50, target = src))
				src.loc = get_turf(user)
				pixel_y = 0
				pixel_x = 0
				anchored = 0
				to_chat(user, "<span class='notice'>You detach the mount from the wall.</span>")
		else
			to_chat(user, "<span class='alert'>You don't know how you could possibly use this on this mount.</span>")
			return

/obj/item/mounted/frame/wall_mount/attack_self(user as mob)
	if(has_trophy)
		icon_state = "wallmount"
		name = initial_name
		desc = initial_desc
		has_trophy = 0
		var/obj/O = text2path("/obj/item/weapon/trophy/[trophy_id]")
		new O(get_turf(user))
		trophy_id = null //sanity
		to_chat(user, "<span class='notice'>You remove the trophy from the mount.</span>")
	else
		to_chat(user, "<span class='warning'>There isn't anything attached to the mount!</span>")
		return
