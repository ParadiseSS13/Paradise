#define GIBBER_ANIMATION_DELAY 16
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

/obj/machinery/gibber/RefreshParts() //If you want to make the machine upgradable, this is where you would change any vars basd on its stock parts.
	return

/obj/machinery/gibber/New()
	..()
	overlays += image('icons/obj/kitchen.dmi', "grjam")

/obj/machinery/gibber/update_icon()
	overlays.Cut()

	if(dirty)
		overlays += image('icons/obj/kitchen.dmi', "grbloody")

	if(stat & (NOPOWER|BROKEN))
		return

	if(!occupant)
		overlays += image('icons/obj/kitchen.dmi', "grjam")

	else if(operating)
		overlays += image('icons/obj/kitchen.dmi', "gruse")

	else
		overlays += image('icons/obj/kitchen.dmi', "gridle")

/obj/machinery/gibber/relaymove(mob/user as mob)
	if(locked)
		return

	go_out()

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return

	if(operating)
		to_chat(user, "<span class='danger'>The gibber is locked and running, wait for it to finish.</span>")
		return

	if(locked)
		to_chat(user, "<span class='warning'>Wait for [occupant.name] to finish being loaded!</span>")
		return

	else
		startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/P as obj, mob/user as mob, params)
	if(istype(P, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = P
		if(G.state < 2)
			to_chat(user, "<span class='danger'>You need a better grip to do that!</span>")
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
	if(user.incapacitated() || !ishuman(user))
		return

	if(!isliving(target))
		return

	var/mob/living/targetl = target

	if(targetl.buckled)
		return

	move_into_gibber(user,target)

/obj/machinery/gibber/proc/move_into_gibber(var/mob/user,var/mob/living/victim)
	if(occupant)
		to_chat(user, "<span class='danger'>The gibber is full, empty it first!</span>")
		return

	if(operating)
		to_chat(user, "<span class='danger'>The gibber is locked and running, wait for it to finish.</span>")
		return

	if(!ishuman(victim) || issmall(victim))
		to_chat(user, "<span class='danger'>This is not suitable for the gibber!</span>")
		return

	if(victim.abiotic(1))
		to_chat(user, "<span class='danger'>Subject may not have abiotic items on.</span>")
		return

	user.visible_message("<span class='danger'>[user] starts to put [victim] into the gibber!</span>")
	src.add_fingerprint(user)
	if(do_after(user, 30, target = victim) && user.Adjacent(src) && victim.Adjacent(user) && !occupant)
		user.visible_message("<span class='danger'>[user] stuffs [victim] into the gibber!</span>")

		victim.forceMove(src)
		occupant = victim

		update_icon()
		feedinTopanim()

/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "Empty Gibber"
	set src in oview(1)

	if(usr.stat != CONSCIOUS)
		return

	go_out()
	add_fingerprint(usr)

/obj/machinery/gibber/proc/go_out()
	if(operating || !occupant) //no going out if operating, just in case they manage to trigger go_out before being dead
		return

	if(locked)
		return

	for(var/obj/O in src)
		O.loc = src.loc

	occupant.forceMove(get_turf(src))
	occupant = null

	update_icon()

	return

/obj/machinery/gibber/proc/feedinTopanim()
	if(!occupant)
		return

	locked = 1 //lock gibber

	var/image/gibberoverlay = new //used to simulate 3D effects
	gibberoverlay.icon = icon
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

	animate(holder, pixel_y = 16, time = GIBBER_ANIMATION_DELAY) //animate going down

	sleep(GIBBER_ANIMATION_DELAY)

	holder.overlays -= feedee //reset static icon
	feedee.icon += icon('icons/obj/kitchen.dmi', "footicon") //this is some byond magic; += to the icon var with a black and white image will mask it
	holder.overlays += feedee
	animate(holder, pixel_y = -3, time = GIBBER_ANIMATION_DELAY) //animate going down further

	sleep(GIBBER_ANIMATION_DELAY) //time everything right, animate doesn't prevent proc from continuing

	qdel(holder) //get rid of holder object
	qdel(holder2) //get rid of holder object
	locked = 0 //unlock

/obj/machinery/gibber/proc/startgibbing(var/mob/user, var/UserOverride=0)
	if(!istype(user) && !UserOverride)
		log_debug("Some shit just went down with the gibber at X[x], Y[y], Z[z] with an invalid user. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")
		return

	if(UserOverride)
		msg_admin_attack("[key_name_admin(occupant)] was gibbed by an autogibber (\the [src]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

	if(operating)
		return

	if(!occupant)
		visible_message("<span class='danger'>You hear a loud metallic grinding sound.</span>")
		return

	use_power(1000)
	visible_message("<span class='danger'>You hear a loud squelchy grinding sound.</span>")

	operating = 1
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


		if(occupant.reagents)
			occupant.reagents.trans_to(new_meat, round(occupant.reagents.total_volume/slab_count,1))

	if(occupant.get_species() == "Human")
		new /obj/item/stack/sheet/animalhide/human(src)
	new /obj/effect/decal/cleanable/blood/gibs(src)

	if(!UserOverride)
		occupant.attack_log += "\[[time_stamp()]\] Was gibbed by [key_name(user)]" //One shall not simply gib a mob unnoticed!
		user.attack_log += "\[[time_stamp()]\] Gibbed [key_name(occupant)]"

		if(occupant.ckey)
			msg_admin_attack("[key_name_admin(user)] gibbed [key_name_admin(occupant)]")

		if(!iscarbon(user))
			occupant.LAssailant = null
		else
			occupant.LAssailant = user

	else //this looks ugly but it's better than a copy-pasted startgibbing proc override
		occupant.attack_log += "\[[time_stamp()]\] Was gibbed by <b>an autogibber (\the [src])</b>"

	occupant.emote("scream")
	playsound(get_turf(src), 'sound/goonstation/effects/gib.ogg', 50, 1)

	victims += "\[[time_stamp()]\] [occupant.name] ([occupant.ckey]) killed by [UserOverride ? "Autogibbing" : "[user] ([user.ckey])"]" //have to do this before ghostizing
	occupant.death(1)
	occupant.ghostize()

	qdel(occupant)

	spawn(gibtime)
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
		operating = 0

		for(var/obj/item/thing in contents) //Meat is spawned inside the gibber and thrown out afterwards.
			thing.loc = get_turf(thing) // Drop it onto the turf for throwing.
			thing.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15) // Being pelted with bits of meat and bone would hurt.
			sleep(1)

		for(var/obj/effect/gibs in contents) //throw out the gibs too
			gibs.loc = get_turf(gibs) //drop onto turf for throwing
			gibs.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15)
			sleep(1)

		pixel_x = initial(pixel_x) //return to it's spot after shaking
		operating = 0
		update_icon()



/* AUTOGIBBER */


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

	victim.forceMove(src)
	occupant = victim

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
