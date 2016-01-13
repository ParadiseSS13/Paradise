
/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/mob/living/occupant // Mob who has been put inside
	var/locked = 0 //Used to prevent mobs from breaking the feedin anim

	var/gib_throw_dir = WEST // Direction to spit meat and gibs in. Defaults to west.
	var/gibtime = 40 // Time from starting until meat appears

	var/list/victims = list()

	use_power = 1
	idle_power_usage = 2
	active_power_usage = 500

/obj/machinery/gibber/Destroy()
	if(contents.len)
		for(var/atom/movable/A in contents)
			A.loc = get_turf(src)
	if(occupant)	occupant = null
	return ..()

//gibs anything that stands on it's input

/obj/machinery/gibber/autogibber
	var/acceptdir = NORTH
	var/lastacceptdir = NORTH
	var/turf/lturf

/obj/machinery/gibber/autogibber/New()
	..()
	spawn(5)
		var/turf/T = get_step(src, acceptdir)
		if(istype(T))
			lturf = T
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/gibber(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/gibber/RefreshParts() //If you want to make the machine upgradable, this is where you would change any vars basd on its stock parts.
	return

/obj/machinery/gibber/autogibber/process()
	if(!lturf || occupant || locked || dirty || operating)
		return

	if(acceptdir != lastacceptdir)
		lturf = null
		lastacceptdir = acceptdir
		var/turf/T = get_step(src, acceptdir)
		if(istype(T))
			lturf = T

	for(var/mob/living/carbon/human/H in lturf)
		if(istype(H) && H.loc == lturf)
			visible_message({"<span class='danger'>\The [src] states, "Food detected!"</span>"})
			sleep(30)
			if(H.loc == lturf) //still standing there
				if(force_move_into_gibber(H))
					ejectclothes(occupant)
					cleanbay()
					startgibbing(null, 1)
			break

/obj/machinery/gibber/autogibber/proc/force_move_into_gibber(var/mob/living/carbon/human/victim)
	if(!istype(victim))	return 0
	visible_message("<span class='danger'>\The [victim.name] gets sucked into \the [src]!</span>")

	if(victim.client)
		victim.client.perspective = EYE_PERSPECTIVE
		victim.client.eye = src

	victim.loc = src
	src.occupant = victim

	update_icon()
	feedinTopanim()
	return 1

/obj/machinery/gibber/autogibber/proc/ejectclothes(var/mob/living/carbon/human/H)
	if(!istype(H))	return 0
	if(H != occupant)	return 0 //only using H as a shortcut to typecast
	for(var/obj/O in H)
		if(istype(O,/obj/item/clothing)) //clothing gets skipped to avoid cleaning out shit
			continue
		if(istype(O,/obj/item/weapon/implant))
			var/obj/item/weapon/implant/I = O
			if(I.implanted)
				continue
		if(istype(O,/obj/item/organ))
			continue
		if(O.flags & NODROP)
			qdel(O) //they are already dead by now
		H.unEquip(O)
		O.loc = src.loc
		O.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15)
		sleep(1)

	for(var/obj/item/clothing/C in H)
		if(C.flags & NODROP)
			qdel(C)
		H.unEquip(C)
		C.loc = src.loc
		C.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15)
		sleep(1)

	visible_message("<span class='warning'>\The [src] spits out \the [H.name]'s possessions!")

/obj/machinery/gibber/autogibber/proc/cleanbay()
	var/spats = 0 //keeps track of how many items get spit out. Don't show a message if none are found.
	for(var/obj/O in src)
		if(istype(O))
			O.loc = src.loc
			O.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15)
			spats++
			sleep(1)
	if(spats)
		visible_message("<span class='warning'>\The [src] spits out more possessions!</span>")

/*
//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	var/turf/input_plate

/obj/machinery/gibber/autogibber/New()
	..()
	spawn(5)
		for(var/i in cardinal)
			var/obj/machinery/mineral/input/input_obj = locate( /obj/machinery/mineral/input, get_step(src.loc, i) )
			if(input_obj)
				if(isturf(input_obj.loc))
					input_plate = input_obj.loc
					qdel(input_obj)
					break

		if(!input_plate)
			log_misc("a [src] didn't find an input plate.")
			return

/obj/machinery/gibber/autogibber/Bumped(var/atom/A)
	if(!input_plate) return

	if(ismob(A))
		var/mob/M = A

		if(M.loc == input_plate)
			M.loc = src
			M.gib()
*/

/obj/machinery/gibber/New()
	..()
	src.overlays += image('icons/obj/kitchen.dmi', "grjam")

/obj/machinery/gibber/update_icon()
	overlays.Cut()

	if (dirty)
		src.overlays += image('icons/obj/kitchen.dmi', "grbloody")

	if(stat & (NOPOWER|BROKEN))
		return

	if (!occupant)
		src.overlays += image('icons/obj/kitchen.dmi', "grjam")

	else if (operating)
		src.overlays += image('icons/obj/kitchen.dmi', "gruse")

	else
		src.overlays += image('icons/obj/kitchen.dmi', "gridle")

/obj/machinery/gibber/relaymove(mob/user as mob)
	if(locked)
		return

	src.go_out()

	return

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return

	if(operating)
		user << "<span class='danger'>The gibber is locked and running, wait for it to finish.</span>"
		return

	if(locked)
		user << "<span class='warning'>Wait for [occupant.name] to finish being loaded!</span>"
		return

	else
		src.startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/P as obj, mob/user as mob, params)
	if(istype(P, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = P
		if(G.state < 2)
			user << "<span class='danger'>You need a better grip to do that!</span>"
			return
		move_into_gibber(user,G.affecting)
		qdel(G)
		return

	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", P))
		return

	if(exchange_parts(user, P))
		return

	if(default_unfasten_wrench(user, P))
		return

	default_deconstruction_crowbar(P)

/obj/machinery/gibber/MouseDrop_T(mob/target, mob/user)
	if(usr.stat || (!ishuman(user)) || user.restrained() || user.weakened || user.stunned || user.paralysis || user.resting)
		return

	if(!istype(target,/mob/living))
		return

	var/mob/living/targetl = target

	if(targetl.buckled)
		return

	move_into_gibber(user,target)

/obj/machinery/gibber/proc/move_into_gibber(var/mob/user,var/mob/living/victim)
	if(src.occupant)
		user << "<span class='danger'>The gibber is full, empty it first!</span>"
		return

	if(operating)
		user << "<span class='danger'>The gibber is locked and running, wait for it to finish.</span>"
		return

	if(!(istype(victim, /mob/living/carbon/human)))
		user << "<span class='danger'>This is not suitable for the gibber!</span>"
		return

	if(victim.abiotic(1))
		user << "<span class='danger'>Subject may not have abiotic items on.</span>"
		return

	user.visible_message("<span class='danger'>[user] starts to put [victim] into the gibber!</span>")
	src.add_fingerprint(user)
	if(do_after(user, 30, target = victim) && user.Adjacent(src) && victim.Adjacent(user) && !occupant)

		user.visible_message("<span class='danger'>[user] stuffs [victim] into the gibber!</span>")

		if(victim.client)
			victim.client.perspective = EYE_PERSPECTIVE
			victim.client.eye = src

		victim.loc = src
		src.occupant = victim

		update_icon()
		feedinTopanim()

/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "Empty Gibber"
	set src in oview(1)

	if (usr.stat != 0)
		return

	src.go_out()
	add_fingerprint(usr)

	return

/obj/machinery/gibber/proc/go_out()
	if (operating || !src.occupant) //no going out if operating, just in case they manage to trigger go_out before being dead
		return

	if (locked)
		return

	for(var/obj/O in src)
		O.loc = src.loc

	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE

	src.occupant.loc = src.loc
	src.occupant = null

	update_icon()

	return

/obj/machinery/gibber/proc/feedinTopanim()
	if(!occupant)	return

	var/arbitrary_delay = 16 //arbitrary delay for animating going down
	locked = 1 //lock gibber

	var/image/gibberoverlay = new //used to simulate 3D effects
	gibberoverlay.icon = src.icon
	gibberoverlay.icon_state = "grinderoverlay"
	gibberoverlay.overlays += image('icons/obj/kitchen.dmi', "gridle")

	var/image/feedee = new
	occupant.dir = 2
	feedee.icon = getFlatIcon(occupant, 2) //makes the image a copy of the occupant

	var/atom/movable/holder = new //holder for occupant image
	holder.name = null //make unclickable
	holder.overlays += feedee //add occupant to holder overlays
	holder.pixel_y = 25 //above the gibber
	holder.pixel_x = 2
	holder.loc = get_turf(src)
	holder.layer = MOB_LAYER //simulate mob-like layering
	holder.anchored = 1

	var/atom/movable/holder2 = new //holder for gibber overlay, used to simulate 3D effect
	holder2.name = null
	holder2.overlays += gibberoverlay
	holder2.loc = get_turf(src)
	holder2.layer = MOB_LAYER + 0.1 //3D, it's above the mob, rest of the gibber is behind
	holder2.anchored = 1

	animate(holder, pixel_y = 16, time = arbitrary_delay) //animate going down

	sleep(arbitrary_delay)

	holder.overlays -= feedee //reset static icon
	feedee.icon += icon('icons/obj/kitchen.dmi', "footicon") //this is some byond magic; += to the icon var with a black and white image will mask it
	holder.overlays += feedee
	animate(holder, pixel_y = -3, time = arbitrary_delay) //animate going down further

	sleep(arbitrary_delay) //time everything right, animate doesn't prevent proc from continuing

	qdel(holder) //get rid of holder object
	qdel(holder2) //get rid of holder object
	locked = 0 //unlock

/obj/machinery/gibber/proc/startgibbing(var/mob/user, var/UserOverride=0)
	if(!istype(user) && !UserOverride)
		log_debug("Some shit just went down with the gibber at X[x], Y[y], Z[z] with an invalid user. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")
		return

	if(UserOverride)
		msg_admin_attack("[key_name_admin(occupant)] was gibbed by an autogibber (\the [src]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

	if(src.operating)
		return

	if(!src.occupant)
		visible_message("<span class='danger'>You hear a loud metallic grinding sound.</span>")
		return

	use_power(1000)
	visible_message("<span class='danger'>You hear a loud squelchy grinding sound.</span>")

	src.operating = 1
	update_icon()
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking

	var/slab_name = occupant.name
	var/slab_count = 3
	var/slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human //gibber can only gib humans on paracode, no need to check meat type
	var/slab_nutrition = src.occupant.nutrition / 15

	slab_nutrition /= slab_count

	for(var/i=1 to slab_count)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/new_meat = new slab_type(src)
		new_meat.name = "[slab_name] [new_meat.name]"
		new_meat.reagents.add_reagent("nutriment",slab_nutrition)

		if(src.occupant.reagents)
			src.occupant.reagents.trans_to(new_meat, round(occupant.reagents.total_volume/slab_count,1))

	new /obj/effect/decal/cleanable/blood/gibs(src)

	if(!UserOverride)
		src.occupant.attack_log += "\[[time_stamp()]\] Was gibbed by [key_name(user)]" //One shall not simply gib a mob unnoticed!
		user.attack_log += "\[[time_stamp()]\] Gibbed [key_name(occupant)]"

		if(src.occupant.ckey)
			msg_admin_attack("[key_name_admin(user)] gibbed [key_name_admin(occupant)]")

		if(!iscarbon(user))
			src.occupant.LAssailant = null
		else
			src.occupant.LAssailant = user

	if(UserOverride) //this looks ugly but it's better than a copy-pasted startgibbing proc override
		occupant.attack_log += "\[[time_stamp()]\] Was gibbed by <b>an autogibber (\the [src])</b>"

	src.occupant.emote("scream")
	playsound(src.loc, 'sound/effects/gib.ogg', 50, 1)

	victims += "\[[time_stamp()]\] [occupant.name] ([occupant.ckey]) killed by [UserOverride ? "Autogibbing" : "[user] ([user.ckey])"]" //have to do this before ghostizing
	src.occupant.death(1)
	src.occupant.ghostize()

	qdel(src.occupant)

	spawn(src.gibtime)

		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
		operating = 0

		for (var/obj/item/thing in contents) //Meat is spawned inside the gibber and thrown out afterwards.
			thing.loc = get_turf(thing) // Drop it onto the turf for throwing.
			thing.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15) // Being pelted with bits of meat and bone would hurt.
			sleep(1)

		for (var/obj/effect/gibs in contents) //throw out the gibs too
			gibs.loc = get_turf(gibs) //drop onto turf for throwing
			gibs.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15)
			sleep(1)

		pixel_x = initial(pixel_x) //return to it's spot after shaking
		src.operating = 0
		update_icon()