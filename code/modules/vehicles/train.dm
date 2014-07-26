/obj/vehicle/train
	name = "train"
	dir = 4

	move_delay = 1

	health = 100
	maxhealth = 100
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5

	var/passenger_allowed = 1

	var/active_engines = 0
	var/train_length = 0

	var/obj/vehicle/train/lead
	var/obj/vehicle/train/tow


//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/train/initialize()
	for(var/obj/vehicle/train/T in orange(1, src))
		latch(T)

/obj/vehicle/train/Move()
	var/old_loc = get_turf(src)
	if(..())
		if(tow)
			tow.Move(old_loc)
		return 1
	else
		return 0

/obj/vehicle/train/Bump(atom/Obstacle)
	if(!istype(Obstacle, /atom/movable))
		return
	var/atom/movable/A = Obstacle

	if(!A.anchored)
		var/turf/T = get_step(A, dir)
		if(isturf(T))
			A.Move(T)	//bump things away when hit

	if(emagged)
		if(istype(A, /mob/living))
			var/mob/living/M = A
			visible_message("\red [src] knocks over [M]!")
			M.apply_effects(5, 5)							//knock people down if you hit them
			M.apply_damages(5 * train_length / move_delay)	// and do damage according to how fast the train is going and how heavy it is
			if(istype(load, /mob/living/carbon/human))
				var/mob/living/D = load
				D << "\red You hit [M]!"
				msg_admin_attack("[D.name] ([D.ckey]) hit [M.name] ([M.ckey]) with [src]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")



//-------------------------------------------
// Interaction procs
//-------------------------------------------
/obj/vehicle/train/relaymove(mob/user, direction)
	var/turf/T = get_step_to(src, get_step(src, direction))
	if(!T)
		user << "You can't find a clear area to step onto."
		return 0

	if(user != load)
		if(user in src)		//for handling players stuck in src - this shouldn't happen - but just in case it does
			user.loc = T
			contents -= user
			return 1
		return 0

	unload(user, direction)

	user << "\blue You climb down from [src]."

	return 1

/obj/vehicle/train/MouseDrop_T(var/atom/movable/C, mob/user as mob)
	if(user.buckled || user.stat || user.restrained() || !Adjacent(user) || !user.Adjacent(C) || !istype(C))
		return
	if(istype(C,/obj/vehicle/train))
		latch(C, user)
	else
		if(!load(C))
			user << "\red You were unable to load [C] on [src]."

/obj/vehicle/train/attack_hand(mob/user as mob)
	if(user.stat || user.restrained() || !Adjacent(user))
		return 0

	if(user != load && (user in src))
		user.loc = loc			//for handling players stuck in src
		contents -= user
	else if(load)
		unload(user)			//unload if loaded
	else if(!load && !user.buckled)
		load(user)				//else try climbing on board
	else
		return 0

/obj/vehicle/train/verb/unlatch_v()
	set name = "Unlatch"
	set desc = "Unhitches this train from the one in front of it."
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(!usr.canmove || usr.stat || usr.restrained() || !Adjacent(usr))
		return

	unattach(usr)


//-------------------------------------------
// Latching/unlatching procs
//-------------------------------------------

//attempts to attach src as a follower of the train T
/obj/vehicle/train/proc/attach_to(obj/vehicle/train/T, mob/user)
	if (get_dist(src, T) > 1)
		user << "\red [src] is too far away from [T] to hitch them together."
		return

	if (lead)
		user << "\red [src] is already hitched to something."
		return

	if (T.tow)
		user << "\red [T] is already towing something."
		return
	//latch with src as the follower
	lead = T
	T.tow = src
	dir = lead.dir

	if(user)
		user << "\blue You hitch [src] to [T]."

	update_stats()


//detaches the train from whatever is towing it
/obj/vehicle/train/proc/unattach(mob/user)
	if (!lead)
		user << "\red [src] is not hitched to anything."
		return

	lead.tow = null
	lead.update_stats()

	lead = null

	update_stats()

/obj/vehicle/train/proc/latch(obj/vehicle/train/T, mob/user)
	if(!istype(T) || !Adjacent(T))
		return 0

	var/T_dir = get_dir(src, T)	//figure out where T is wrt src

	if(dir == T_dir) 	//if car is ahead
		src.attach_to(T, user)
	else if(reverse_direction(dir) == T_dir)	//else if car is behind
		T.attach_to(src, user)

//returns 1 if this is the lead car of the train
/obj/vehicle/train/proc/is_train_head()
	if (lead)
		return 0
	return 1

//-------------------------------------------------------
// Stat update procs
//
// Used for updating the stats for how long the train is.
// These are useful for calculating speed based on the
// size of the train, to limit super long trains.
//-------------------------------------------------------
/obj/vehicle/train/update_stats()
	if(tow)
		return tow.update_stats()	//take us to the very end
	else
		update_train_stats()		//we're at the end

/obj/vehicle/train/proc/update_train_stats()
	if(powered && on)
		active_engines = 1	//increment active engine count if this is a running engine
	else
		active_engines = 0

	train_length = 1

	if(istype(tow))
		active_engines += tow.active_engines
		train_length += tow.train_length

	//update the next section of train ahead of us
	if(istype(lead))
		lead.update_train_stats()