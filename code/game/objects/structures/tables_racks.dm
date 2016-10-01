/* Tables and Racks
 * Contains:
 *		Tables
 *		Wooden tables
 *		Reinforced tables
 *		Racks
 */


/*
 * Tables
 */
/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/smooth_structures/table.dmi'
	icon_state = "table"
	density = 1
	anchored = 1.0
	layer = 2.8
	throwpass = 1	//You can throw objects over this, despite it's density.")
	climbable = 1

	var/parts = /obj/item/weapon/table_parts
	var/flipped = 0
	var/health = 100
	var/busy = 0
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/table, /obj/structure/table/reinforced)

/obj/structure/table/New()
	..()
	for(var/obj/structure/table/T in src.loc)
		if(T != src)
			qdel(T)
	if(flipped)
		update_icon()

/obj/structure/table/proc/destroy()
	new parts(loc)
	density = 0
	qdel(src)

/obj/structure/table/update_icon()
	if(smooth && !flipped)
		icon_state = ""
		smooth_icon(src)
		smooth_icon_neighbors(src)

	if(flipped)
		clear_smooth_overlays()

		var/type = 0
		var/subtype = null
		for(var/direction in list(turn(dir,90), turn(dir,-90)) )
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,direction))
			if(T && T.flipped)
				type++
				if(type == 1)
					subtype = direction == turn(dir,90) ? "-" : "+"
		var/base = "table"
		if(istype(src, /obj/structure/table/woodentable))
			base = "wood"
		if(istype(src, /obj/structure/table/reinforced))
			base = "rtable"

		icon_state = "[base]flip[type][type == 1 ? subtype : ""]"

		return 1


/obj/structure/table/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				destroy()
		else
	return


/obj/structure/table/blob_act()
	if(prob(75))
		destroy()


/obj/structure/table/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	destroy()

/obj/structure/table/mech_melee_attack(obj/mecha/M)
	visible_message("<span class='danger'>[M] smashes [src] apart!</span>")
	destroy()

/obj/structure/table/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		user.do_attack_animation(src)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()



/obj/structure/table/attack_hand(mob/living/user)
	if(HULK in user.mutations)
		user.do_attack_animation(src)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		destroy()
	else
		..()
	if(climber)
		climber.Weaken(2)
		climber.visible_message("<span class='warning'>[climber.name] has been knocked off the table", "You've been knocked off the table", "You see [climber.name] get knocked off the table</span>")

/obj/structure/table/attack_tk() // no telehulk sorry
	return

/obj/structure/table/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if(ismob(mover))
		var/mob/M = mover
		if(M.flying)
			return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	if(flipped)
		if(get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 0

/obj/structure/table/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSTABLE)

//checks if projectile 'P' from turf 'from' can hit whatever is behind the table. Returns 1 if it can, 0 if bullet stops.
/obj/structure/table/proc/check_cover(obj/item/projectile/P, turf/from)
	var/turf/cover = flipped ? get_turf(src) : get_step(loc, get_dir(from, loc))
	if(get_dist(P.starting, loc) <= 1) //Tables won't help you if people are THIS close
		return 1
	if(get_turf(P.original) == cover)
		var/chance = 20
		if(ismob(P.original))
			var/mob/M = P.original
			if(M.lying)
				chance += 20				//Lying down lets you catch less bullets
		if(flipped)
			if(get_dir(loc, from) == dir)	//Flipped tables catch mroe bullets
				chance += 20
			else
				return 1					//But only from one side
		if(prob(chance))
			health -= P.damage/2
			if(health > 0)
				visible_message("<span class='warning'>[P] hits \the [src]!</span>")
				return 0
			else
				visible_message("<span class='warning'>[src] breaks down!</span>")
				destroy()
				return 1
	return 1

/obj/structure/table/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSTABLE))
		return 1
	if(flipped)
		if(get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 1

/obj/structure/table/MouseDrop_T(obj/O as obj, mob/user as mob)
	..()
	if((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
		return
	if(isrobot(user))
		return
	if(!user.drop_item())
		return
	if(O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/structure/table/proc/tablepush(obj/item/I, mob/user)
	if(get_dist(src, user) < 2)
		var/obj/item/weapon/grab/G = I
		if(G.affecting.buckled)
			to_chat(user, "<span class='warning'>[G.affecting] is buckled to [G.affecting.buckled]!</span>")
			return 0
		if(G.state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return 0
		if(!G.confirm())
			return 0
		G.affecting.forceMove(get_turf(src))
		G.affecting.Weaken(2)
		G.affecting.visible_message("<span class='danger'>[G.assailant] pushes [G.affecting] onto [src].</span>", \
									"<span class='userdanger'>[G.assailant] pushes [G.affecting] onto [src].</span>")
		add_logs(G.assailant, G.affecting, "pushed onto a table")
		qdel(I)
		return 1
	qdel(I)

/obj/structure/table/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/grab))
		tablepush(W, user)
		return

	if(istype(W, /obj/item/weapon/wrench))
		user.visible_message("<span class='notice'>[user] is disassembling \a [src].</span>", "<span class='notice'>You start disassembling \the [src].</span>")
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 50, target = src))
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
			destroy()
		return

	if(isrobot(user))
		return

	if(istype(W, /obj/item/weapon/melee/energy/blade))
		var/datum/effect/system/spark_spread/spark_system = new /datum/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src.loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(src.loc, "sparks", 50, 1)
		for(var/mob/O in viewers(user, 4))
			O.show_message("\blue The [src] was sliced apart by [user]!", 1, "\red You hear [src] coming apart.", 2)
		destroy()
		return

	if(!(W.flags & ABSTRACT))
		if(user.drop_item())
			W.Move(loc)
			var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
			if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			W.pixel_x = Clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
			W.pixel_y = Clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)

	return

/obj/structure/table/proc/straight_table_check(var/direction)
	var/obj/structure/table/T
	for(var/angle in list(-90,90))
		T = locate() in get_step(src.loc,turn(direction,angle))
		if(T && !T.flipped)
			return 0
	T = locate() in get_step(src.loc,direction)
	if(!T || T.flipped)
		return 1
	if(istype(T,/obj/structure/table/reinforced/))
		var/obj/structure/table/reinforced/R = T
		if(R.status == 2)
			return 0
	return T.straight_table_check(direction)

/obj/structure/table/verb/do_flip()
	set name = "Flip table"
	set desc = "Flips a non-reinforced table"
	set category = null
	set src in oview(1)

	if(!can_touch(usr) || ismouse(usr))
		return

	if(!flip(get_cardinal_dir(usr,src)))
		to_chat(usr, "<span class='notice'>It won't budge.</span>")
		return

	usr.visible_message("<span class='warning'>[usr] flips \the [src]!</span>")

	if(climbable)
		structure_shaken()

	return

/obj/structure/table/proc/do_put()
	set name = "Put table back"
	set desc = "Puts flipped table back"
	set category = "Object"
	set src in oview(1)

	if(!unflip())
		to_chat(usr, "<span class='notice'>It won't budge.</span>")
		return


/obj/structure/table/proc/flip(var/direction)
	if(flipped)
		return 0

	if( !straight_table_check(turn(direction,90)) || !straight_table_check(turn(direction,-90)) )
		return 0

	verbs -=/obj/structure/table/verb/do_flip
	verbs +=/obj/structure/table/proc/do_put

	var/list/targets = list(get_step(src,dir),get_step(src,turn(dir, 45)),get_step(src,turn(dir, -45)))
	for(var/atom/movable/A in get_turf(src))
		if(!A.anchored)
			spawn(0)
				A.throw_at(pick(targets),1,1)

	dir = direction
	if(dir != NORTH)
		layer = 5
	flipped = 1
	smooth = SMOOTH_FALSE
	flags |= ON_BORDER
	for(var/D in list(turn(direction, 90), turn(direction, -90)))
		if(locate(/obj/structure/table,get_step(src,D)))
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,D))
			T.flip(direction)
	update_icon()

	return 1

/obj/structure/table/proc/unflip()
	if(!flipped)
		return 0

	var/can_flip = 1
	for(var/mob/A in oview(src,0))//src.loc)
		if(istype(A))
			can_flip = 0
	if(!can_flip)
		return 0

	verbs -=/obj/structure/table/proc/do_put
	verbs +=/obj/structure/table/verb/do_flip

	layer = initial(layer)
	flipped = 0
	smooth = initial(smooth)
	flags &= ~ON_BORDER
	for(var/D in list(turn(dir, 90), turn(dir, -90)))
		if(locate(/obj/structure/table,get_step(src,D)))
			var/obj/structure/table/T = locate(/obj/structure/table,get_step(src,D))
			T.unflip()
	update_icon()

	return 1

/*
 * Wooden tables
 */
/obj/structure/table/woodentable
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'icons/obj/smooth_structures/wood_table.dmi'
	icon_state = "wood_table"
	parts = /obj/item/weapon/table_parts/wood
	health = 50
	canSmoothWith = list(/obj/structure/table/woodentable, /obj/structure/table/woodentable/poker)
	burn_state = FLAMMABLE
	burntime = 20
	var/canPokerize = 1

/obj/structure/table/woodentable/attackby(obj/item/I as obj, mob/user as mob, params)
	if(canPokerize && istype(I, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/gr = I
		gr.use(1)
		new /obj/structure/table/woodentable/poker( src.loc )
		qdel(src)
		visible_message("<span class='notice'>[user] adds the grass to the wooden table</span>")
		return 1
	else
		return ..()

	return 1

/obj/structure/table/woodentable/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'icons/obj/smooth_structures/poker_table.dmi'
	icon_state = "pokertable"
	canSmoothWith = list(/obj/structure/table/woodentable/poker, /obj/structure/table/woodentable)
	canPokerize = 0

/obj/structure/table/woodentable/poker/destroy()
	new /obj/item/stack/tile/grass(loc)
	..()

/obj/structure/glasstable_frame
	name = "glass table frame"
	desc = "A metal frame for a glass table."
	icon = 'icons/obj/structures.dmi'
	icon_state = "glass_table_frame"
	density = 1

/obj/structure/glasstable_frame/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.amount >= 2)
			to_chat(user, "<span class='notice'>You start to add the glass to \the [src].</span>")
			if(do_after(user, 10, target = src))
				G.use(2)
				to_chat(user, "<span class='notice'>You add the glass to \the [src].</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				new /obj/structure/table/glass(loc)
				qdel(src)
		else
			to_chat(user, "<span class='notice'>You don't have enough glass! You need at least 2 sheets.</span>")
			return

	if(iswrench(I))
		to_chat(user, "<span class='notice'>You start to deconstruct \the [src].</span>")
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		if(do_after(user, 10, target = src))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 75, 1)
			to_chat(user, "<span class='notice'>You dismantle \the [src].</span>")
			new /obj/item/stack/sheet/metal(loc)
			new /obj/item/stack/sheet/metal(loc)
			qdel(src)

/obj/structure/table/glass
	name = "glass table"
	desc = "Looks fragile. You should totally flip it. It is begging for it."
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	icon_state = "glass_table"
	parts = /obj/item/weapon/table_parts/glass
	health = 10
	canSmoothWith = null

/obj/structure/table/glass/flip(var/direction)
	collapse()

/obj/structure/table/glass/proc/collapse() //glass table collapse is called twice in this code, more efficent to just have a proc
	src.visible_message("<span class='warning'>\The [src] shatters, and the frame collapses!</span>", "<span class='warning'>You hear metal collapsing and glass shattering.</span>")
	playsound(src.loc, "shatter", 50, 1)
	destroy(1)

/obj/structure/table/glass/destroy(dirty)
	if(dirty)
		new /obj/item/weapon/shard(loc)
		new /obj/item/weapon/shard(loc)
	else
		new /obj/item/stack/sheet/glass(loc, 2)
	..()

/obj/structure/table/glass/tablepush(obj/item/I, mob/user)
	if(..())
		collapse()

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A version of the four legged table. It is stronger."
	icon = 'icons/obj/smooth_structures/reinforced_table.dmi'
	icon_state = "r_table"
	health = 200
	var/status = 2
	parts = /obj/item/weapon/table_parts/reinforced
	canSmoothWith = list(/obj/structure/table/reinforced, /obj/structure/table)

/obj/structure/table/reinforced/flip(var/direction)
	if(status == 2)
		return 0
	else
		return ..()

/obj/structure/table/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			if(src.status == 2)
				to_chat(user, "\blue Now weakening the reinforced table")
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, 50, target = src))
					if(!src || !WT.isOn()) return
					to_chat(user, "\blue Table weakened")
					src.status = 1
			else
				to_chat(user, "\blue Now strengthening the reinforced table")
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, 50, target = src))
					if(!src || !WT.isOn()) return
					to_chat(user, "\blue Table strengthened")
					src.status = 2
			return
		return

	if(istype(W, /obj/item/weapon/wrench))
		if(src.status == 2)
			return

	..()

/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = 1
	anchored = 1.0
	throwpass = 1	//You can throw objects over this, despite it's density.
	var/parts = /obj/item/weapon/rack_parts
	var/health = 5

/obj/structure/rack/proc/destroy()
	new parts(loc)
	density = 0
	qdel(src)

/obj/structure/rack/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			qdel(src)
			if(prob(50))
				new /obj/item/weapon/rack_parts(src.loc)
		if(3.0)
			if(prob(25))
				qdel(src)
				new /obj/item/weapon/rack_parts(src.loc)

/obj/structure/rack/blob_act()
	if(prob(75))
		qdel(src)
		return
	else if(prob(50))
		new /obj/item/weapon/rack_parts(src.loc)
		qdel(src)
		return

/obj/structure/rack/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(src.density == 0) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/structure/rack/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSTABLE)

/obj/structure/rack/MouseDrop_T(obj/O as obj, mob/user as mob)
	if((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
		return
	if(isrobot(user))
		return
	if(!user.drop_item())
		return
	if(O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/structure/rack/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/rack_parts( src.loc )
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		qdel(src)
		return
	if(isrobot(user))
		return
	if(!(W.flags & ABSTRACT))
		if(user.drop_item())
			W.Move(loc)
	return

/obj/structure/rack/attack_hand(mob/user)
	if(HULK in user.mutations)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		destroy()
	else
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		playsound(loc, 'sound/items/dodgeball.ogg', 80, 1)
		user.visible_message("<span class='warning'>[user] kicks [src].</span>", \
							 "<span class='danger'>You kick [src].</span>")
		health -= rand(1,2)
		healthcheck()

/obj/structure/rack/mech_melee_attack(obj/mecha/M)
	visible_message("<span class='danger'>[M] smashes [src] apart!</span>")
	destroy()

/obj/structure/rack/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	destroy()


/obj/structure/rack/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		user.do_attack_animation(src)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()

/obj/structure/rack/attack_tk() // no telehulk sorry
	return

/obj/structure/rack/proc/healthcheck()
	if(health <= 0)
		destroy()

/obj/structure/rack/skeletal_bar
	name = "skeletal minibar"
	desc = "Made with the skulls of the fallen."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "minibar"

/obj/structure/rack/skeletal_bar/left
	icon_state = "minibar_left"

/obj/structure/rack/skeletal_bar/right
	icon_state = "minibar_right"
