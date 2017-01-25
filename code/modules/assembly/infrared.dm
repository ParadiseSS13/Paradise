/obj/item/device/assembly/infra
	name = "infrared emitter"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared"
	materials = list(MAT_METAL=1000, MAT_GLASS=500)
	origin_tech = "magnets=2"

	bomb_name = "tripwire mine"

	var/on = 0
	var/visible = 0
	var/obj/effect/beam/i_beam/first = null
	var/obj/effect/beam/i_beam/last = null
	var/max_nesting_level = 10
	var/turf/fire_location

/obj/item/device/assembly/infra/Destroy()
	if(first)
		qdel(first)
		first = null
		last = null
		fire_location = null
	return ..()

/obj/item/device/assembly/infra/describe()
	return "The infrared trigger is [on?"on":"off"]."

/obj/item/device/assembly/infra/activate()
	if(!..())	return 0//Cooldown check
	on = !on
	update_icon()
	return 1

/obj/item/device/assembly/infra/toggle_secure()
	secured = !secured
	if(secured)
		processing_objects.Add(src)
	else
		on = 0
		if(first)	qdel(first)
		processing_objects.Remove(src)
	update_icon()
	return secured

/obj/item/device/assembly/infra/update_icon()
	overlays.Cut()
	attached_overlays = list()
	if(on)
		overlays += "infrared_on"
		attached_overlays += "infrared_on"

	if(holder)
		holder.update_icon()

/obj/item/device/assembly/infra/proc/get_valid_loc(atom/A, atom/prev, level = 0)
	if(!A)
		A = loc
	if(!prev)
		prev = src
	if(level > max_nesting_level)
		return null
	else if(isturf(A))
		return A
	else if(isobj(A))
		var/obj/O = A
		if(isassembly(A) || O.IsAssemblyHolder() || istype(A, /obj/item/device/onetankbomb))
			return .(A.loc, A, level + 1)
	else if(ismob(A))
		var/mob/user = A
		if(user.get_active_hand() == prev || user.get_inactive_hand() == prev)
			return .(A.loc, A, level + 1)
	return null

/obj/item/device/assembly/infra/process()
	if(!on || fire_location != get_turf(loc))
		if(first)
			qdel(first)
			return
	if(!secured)
		return
	if(first && last)
		last.process()
		return
	var/turf/T = get_valid_loc()
	if(T)
		fire_location = T
		var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam(T)
		I.master = src
		I.density = 1
		I.dir = dir
		I.update_icon()
		first = I
		step(I, I.dir)
		if(first)
			I.density = 0
			I.vis_spread(visible)
			I.limit = 8
			I.process()

/obj/item/device/assembly/infra/attack_hand()
	qdel(first)
	..()

/obj/item/device/assembly/infra/Move()
	var/t = dir
	..()
	dir = t
	qdel(first)

/obj/item/device/assembly/infra/holder_movement()
	if(!holder)	return 0
	qdel(first)
	return 1

/obj/item/device/assembly/infra/equipped(var/mob/user, var/slot)
	qdel(first)
	return ..()

/obj/item/device/assembly/infra/pickup(mob/user)
	qdel(first)
	return ..()

/obj/item/device/assembly/infra/proc/trigger_beam()
	if(!secured || !on || cooldown > 0)
		return 0
	pulse(0)
	audible_message("[bicon(src)] *beep* *beep*", null, 3)
	cooldown = 2
	spawn(10)
		process_cooldown()

/obj/item/device/assembly/infra/interact(mob/user as mob)//TODO: change this this to the wire control panel
	if(!secured)	return
	user.set_machine(src)
	var/dat = {"<TT><B>Infrared Laser</B>
				<B>Status</B>: [on ? "<A href='?src=[UID()];state=0'>On</A>" : "<A href='?src=[UID()];state=1'>Off</A>"]<BR>
				<B>Visibility</B>: [visible ? "<A href='?src=[UID()];visible=0'>Visible</A>" : "<A href='?src=[UID()];visible=1'>Invisible</A>"]<BR>
				<B>Current Direction</B>: <A href='?src=[UID()];rotate=1'>[capitalize(dir2text(dir))]</A><BR>
				</TT>
				<BR><BR><A href='?src=[UID()];refresh=1'>Refresh</A>
				<BR><BR><A href='?src=[UID()];close=1'>Close</A>"}
	var/datum/browser/popup = new(user, "infra", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "infra")

/obj/item/device/assembly/infra/Topic(href, href_list)
	..()
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=infra")
		onclose(usr, "infra")
		return
	if(href_list["state"])
		on = !(on)
		update_icon()
	if(href_list["visible"])
		visible = !(visible)
		if(first)
			first.vis_spread(visible)
	if(href_list["rotate"])
		rotate()
	if(href_list["close"])
		usr << browse(null, "window=infra")
		return
	if(usr)
		attack_self(usr)

/obj/item/device/assembly/infra/verb/rotate()//This could likely be better
	set name = "Rotate Infrared Laser"
	set category = "Object"
	set src in usr

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	dir = turn(dir, 90)

	if(usr.machine == src)
		interact(usr)



/***************************IBeam*********************************/

/obj/effect/beam/i_beam
	name = "i beam"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	var/obj/effect/beam/i_beam/next = null
	var/obj/effect/beam/i_beam/previous = null
	var/obj/item/device/assembly/infra/master = null
	var/limit = null
	var/visible = 0.0
	var/left = null
	anchored = 1.0
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE


/obj/effect/beam/i_beam/proc/hit()
	if(master)
		master.trigger_beam()
	qdel(src)

/obj/effect/beam/i_beam/proc/vis_spread(v)
	visible = v
	if(next)
		next.vis_spread(v)

/obj/effect/beam/i_beam/update_icon()
	transform = turn(matrix(), dir2angle(dir))

/obj/effect/beam/i_beam/process()
	if((loc.density || !(master)))
		qdel(src)
		return
	if(left > 0)
		left--
	if(left < 1)
		if(!(visible))
			invisibility = 101
		else
			invisibility = 0
	else
		invisibility = 0

	if(!next && (limit > 0))
		var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam(loc)
		I.master = master
		I.density = 1
		I.dir = dir
		I.update_icon()
		I.previous = src
		next = I
		step(I, I.dir)
		if(next)
			I.density = 0
			I.vis_spread(visible)
			I.limit = limit - 1
			master.last = I
			I.process()

/obj/effect/beam/i_beam/Bump()
	qdel(src)

/obj/effect/beam/i_beam/Bumped()
	hit()

/obj/effect/beam/i_beam/Crossed(atom/movable/AM as mob|obj)
	if(!isobj(AM) && !isliving(AM))
		return
	if(istype(AM, /obj/effect))
		return
	hit()

/obj/effect/beam/i_beam/Destroy()
	if(master.first == src)
		master.first = null
	if(next)
		qdel(next)
		next = null
	if(previous)
		previous.next = null
		master.last = previous
	return ..()
