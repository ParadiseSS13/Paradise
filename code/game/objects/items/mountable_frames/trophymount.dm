/obj/item/mounted/frame/trophy_mount
	name = "trophy mount"
	desc = "Used to hang your old hunting trophies. "
	icon = 'icons/obj/objects.dmi'
	icon_state = "wallmount"
	materials = list(MAT_WOOD=1000)
	anchored = 0
	var/initial_name = "wooden wall mount"
	var/initial_desc = "Used to hang your old hunting trophies. "
	var/has_trophy = 0
	var/trophy_id

/obj/item/mounted/frame/trophy_mount/do_build(turf/on_wall, mob/user)
	to_chat(user, "<span class='notice'>You begin attaching the mount to the wall...</span>")
	if(do_after(user, 50, target = src))
		to_chat(user, "<span class='notice'>You attach the mount to the wall.</span>")
		var/obj/item/mounted/frame/trophy_mount/M = new /obj/item/mounted/frame/trophy_mount(get_turf(src), get_dir(on_wall, user), 1)
		M.pixel_y -= (loc.y - on_wall.y) * 32
		M.pixel_x -= (loc.x - on_wall.x) * 32
		M.anchored = 1
		qdel(src)

/obj/item/mounted/frame/trophy_mount/attack_hand(mob/user) //Dumb, I know
	if(anchored)
		return
	else
		..()

/obj/item/mounted/frame/trophy_mount/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/trophy))
		if(anchored)
			var/obj/item/weapon/trophy/T = W //kill me
			if(!has_trophy)
				icon_state = "wallmount_[T.id]"
				name = "[T.id] trophy head"
				desc += "It has a [T.id] trophy head attached to it."
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
			to_chat(user, "<span class='notice'>You begin detaching the mount from the wall...</span>")
			if(do_after(user, 50, target = src))
				src.loc = get_turf(user)
				pixel_y = 0
				pixel_x = 0
				anchored = 0
				to_chat(user, "<span class='notice'>You detach the mount from the wall.</span>")
		else
			to_chat(user, "<span class='alert'>You don't know how you could possibly use this on this mount.</span>")
			return

/obj/item/mounted/frame/trophy_mount/MouseDrop_T(mob/living/simple_animal/S, mob/user as mob)
	if(!istype(S))
		return 0 //not a simple_animal
	if(user.incapacitated())
		return 0 //user shouldn't be doing things
	if(!S.can_trophy)
		return 0 //can't trophy the animal...welp
	if(S.stat != DEAD)
		return 0 //the dang thing ain't even dead yet!
	if(S.trophied)
		return 0 //how do you expect to cut the head off an animal that doesn't have one?!
	if(!anchored)
		to_chat(user, "<span class='notice'>The mount needs to be attached to a wall first.</span>")
		return 0 //the mount isn't even on the wall!
	var/activehand = user.get_active_hand() //so, so shitty
	var/inactivehand = user.get_inactive_hand()
	if(!istype(inactivehand, /obj/item/weapon/kitchen/knife) && !istype(activehand, /obj/item/weapon/kitchen/knife))
		to_chat(user, "<span class='alert'>You need to have a knife in one of your hands to be able to do this!</span>")
		return 0
	if(get_dist(user, src) > 1 || get_dist(user, S) > 1)
		return 0 //doesn't use adjacent() to allow for non-cardinal (fuck my life)
	if(has_trophy)
		to_chat(user, "<span class='notice'>There is already a trophy attached to the mount.</span>")
		return 0

	to_chat(user, "<span class='info'>You begin cutting the trophy head off [S] and attaching it to the mount...</span>")
	if(do_after(user, 80, target = src))
		to_chat(user, "<span class='info'>You cut the trophy head off [S] and attach it to the mount.</span>")
		has_trophy = 1
		trophy_id = S.trophy
		S.trophied = 1
		S.icon_state = S.icon_nohead
		icon_state = "wallmount_[trophy_id]"
		name = "[trophy_id] trophy head"
		desc += "It has a [trophy_id] trophy head attached to it."

/obj/item/mounted/frame/trophy_mount/attack_self(user as mob)
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
