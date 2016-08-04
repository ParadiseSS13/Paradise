//Define all tape types in policetape.dm
/obj/item/taperoll
	name = "tape roll"
	icon = 'icons/policetape.dmi'
	icon_state = "rollstart"
	w_class = 1
	var/turf/start
	var/turf/end
	var/tape_type = /obj/item/tape
	var/icon_base

var/list/image/hazard_overlays
var/list/tape_roll_applications = list()

/obj/item/tape
	name = "tape"
	icon = 'icons/policetape.dmi'
	anchored = 1
	density = 1
	var/icon_base

/obj/item/tape/New()
	..()
	if(!hazard_overlays)
		hazard_overlays = list()
		hazard_overlays["[NORTH]"]	= new/image('icons/effects/warning_stripes.dmi', icon_state = "N")
		hazard_overlays["[EAST]"]	= new/image('icons/effects/warning_stripes.dmi', icon_state = "E")
		hazard_overlays["[SOUTH]"]	= new/image('icons/effects/warning_stripes.dmi', icon_state = "S")
		hazard_overlays["[WEST]"]	= new/image('icons/effects/warning_stripes.dmi', icon_state = "W")

/obj/item/taperoll/New() //just using tape is not enough to guarantee the overlays are genned
	..()
	if(!hazard_overlays)
		hazard_overlays = list()
		hazard_overlays["[NORTH]"]	= new/image('icons/effects/warning_stripes.dmi', icon_state = "N")
		hazard_overlays["[EAST]"]	= new/image('icons/effects/warning_stripes.dmi', icon_state = "E")
		hazard_overlays["[SOUTH]"]	= new/image('icons/effects/warning_stripes.dmi', icon_state = "S")
		hazard_overlays["[WEST]"]	= new/image('icons/effects/warning_stripes.dmi', icon_state = "W")

/obj/item/taperoll/police
	name = "police tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon_state = "police_start"
	tape_type = /obj/item/tape/police
	icon_base = "police"

/obj/item/tape/police
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	req_one_access = list(access_security,access_forensics_lockers)
	icon_base = "police"

/obj/item/taperoll/engineering
	name = "engineering tape"
	desc = "A roll of engineering tape used to block off working areas from the public."
	icon_state = "engineering_start"
	tape_type = /obj/item/tape/engineering
	icon_base = "engineering"

/obj/item/tape/engineering
	name = "engineering tape"
	desc = "A length of engineering tape. Better not cross it."
	req_one_access = list(access_engine,access_atmospherics)
	icon_base = "engineering"

/obj/item/taperoll/attack_self(mob/user as mob)
	if(icon_state == "[icon_base]_start")
		start = get_turf(src)
		to_chat(usr, "\blue You place the first end of the [src].")
		icon_state = "[icon_base]_stop"
	else
		icon_state = "[icon_base]_start"
		end = get_turf(src)
		if(start.y != end.y && start.x != end.x || start.z != end.z)
			to_chat(usr, "\blue [src] can only be laid horizontally or vertically.")
			return

		var/turf/cur = start
		var/dir
		if(start.x == end.x)
			var/d = end.y-start.y
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x,end.y+d,end.z))
			dir = "v"
		else
			var/d = end.x-start.x
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x+d,end.y,end.z))
			dir = "h"

		var/can_place = 1
		while(cur!=end && can_place)
			if(cur.density == 1)
				can_place = 0
			else if(istype(cur, /turf/space))
				can_place = 0
			else
				for(var/obj/O in cur)
					if(!istype(O, /obj/item/tape) && O.density)
						can_place = 0
						break
			cur = get_step_towards(cur,end)
		if(!can_place)
			to_chat(usr, "\blue You can't run \the [src] through that!")
			return

		cur = start
		var/tapetest = 0
		while(cur!=end)
			for(var/obj/item/tape/Ptest in cur)
				if(Ptest.icon_state == "[Ptest.icon_base]_[dir]")
					tapetest = 1
			if(tapetest != 1)
				var/obj/item/tape/P = new tape_type(cur)
				P.icon_state = "[P.icon_base]_[dir]"
			cur = get_step_towards(cur,end)
	//is_blocked_turf(var/turf/T)
			to_chat(usr, "\blue You finish placing the [src].")//Git Test


/obj/item/taperoll/afterattack(var/atom/A, mob/user as mob, proximity)
	if(!proximity)
		return

	if(istype(A, /obj/machinery/door/airlock))
		var/turf/T = get_turf(A)
		var/obj/item/tape/P = new tape_type(T.x,T.y,T.z)
		P.loc = locate(T.x,T.y,T.z)
		P.icon_state = "[src.icon_base]_door"
		P.layer = 3.2
		to_chat(user, "\blue You finish placing the [src].")

	if(istype(A, /turf/simulated/floor) ||istype(A, /turf/unsimulated/floor))
		var/turf/F = A
		var/direction = user.loc == F ? user.dir : turn(user.dir, 180)
		var/icon/hazard_overlay = hazard_overlays["[direction]"]
		if(tape_roll_applications[F] == null)
			tape_roll_applications[F] = 0

		if(tape_roll_applications[F] & direction) // hazard_overlay in F.overlays wouldn't work.
			user.visible_message("[user] uses the adhesive of \the [src] to remove area markings from \the [F].", "You use the adhesive of \the [src] to remove area markings from \the [F].")
			F.overlays -= hazard_overlay
			tape_roll_applications[F] &= ~direction
		else
			user.visible_message("[user] applied \the [src] on \the [F] to create area markings.", "You apply \the [src] on \the [F] to create area markings.")
			F.overlays |= hazard_overlay
			tape_roll_applications[F] |= direction
		return

/obj/item/tape/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!density) return 1
	if(air_group || (height==0)) return 1

	if((mover.pass_flags & PASSTABLE || istype(mover, /obj/effect/meteor) || mover.throwing == 1) )
		return 1
	else if(ismob(mover) && allowed(mover))
		return 1
	else
		return 0

/obj/item/tape/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	breaktape(W, user)

/obj/item/tape/attack_hand(mob/user as mob)
	if(user.a_intent == I_HELP && src.allowed(user))
		user.visible_message("<span class=notice>[user] lifts [src], allowing passage.</span>", "<span class=notice>You lift [src], allowing passage.</span>")
		src.density = 0
		spawn(200)
			src.density = 1
	else
		breaktape(/obj/item/weapon/soap, user)//cant be null, and can't be sharp.

/obj/item/tape/attack_alien(mob/user as mob)
	breaktape(/obj/item/weapon/wirecutters,user)

/obj/item/tape/proc/breaktape(obj/item/weapon/W as obj, mob/user as mob)
	if(user.a_intent == I_HELP && ((!can_puncture(W) && src.allowed(user))))
		to_chat(user, "You can't break the [src] with that!")
		return
	user.visible_message("<span class=warning>[user] breaks the [src]!</span>", "<span class=warning>You break the [src]!</span>")

	var/dir[2]
	var/icon_dir = src.icon_state
	if(icon_dir == "[src.icon_base]_h")
		dir[1] = EAST
		dir[2] = WEST
	if(icon_dir == "[src.icon_base]_v")
		dir[1] = NORTH
		dir[2] = SOUTH

	for(var/i=1;i<3;i++)
		var/N = 0
		var/turf/cur = get_step(src,dir[i])
		while(N != 1)
			N = 1
			for(var/obj/item/tape/P in cur)
				if(P.icon_state == icon_dir)
					N = 0
					qdel(P)
			cur = get_step(cur,dir[i])

	qdel(src)
	return


