/atom
	layer = 2
	var/level = 2
	var/flags = NONE
	var/flags_2 = NONE
	var/list/fingerprints
	var/list/fingerprintshidden
	var/fingerprintslast = null
	var/list/blood_DNA
	var/blood_color
	var/last_bumped = 0
	var/pass_flags = 0
	var/germ_level = GERM_LEVEL_AMBIENT // The higher the germ level, the more germ on the atom.
	var/simulated = 1 //filter for actions - used by lighting overlays
	var/atom_say_verb = "says"
	var/dont_save = 0 // For atoms that are temporary by necessity - like lighting overlays


	///Chemistry.
	var/container_type = NONE
	var/datum/reagents/reagents = null

	//This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list = list()
	//HUD images that this atom can provide.
	var/list/hud_possible

	///Chemistry.


	//Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	//Detective Work, used for the duplicate data points kept in the scanners
	var/list/original_atom

	//Detective Work, used for allowing a given atom to leave its fibers on stuff. Allowed by default
	var/can_leave_fibers = TRUE

	var/allow_spin = 1 //Set this to 1 for a _target_ that is being thrown at; if an atom has this set to 1 then atoms thrown AT it will not spin; currently used for the singularity. -Fox

	var/admin_spawned = 0	//was this spawned by an admin? used for stat tracking stuff.

	var/initialized = FALSE

	var/list/priority_overlays	//overlays that should remain on top and not normally removed when using cut_overlay functions, like c4.
	var/list/remove_overlays // a very temporary list of overlays to remove
	var/list/add_overlays // a very temporary list of overlays to add

/atom/New(loc, ...)
	if(use_preloader && (src.type == _preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		_preloader.load(src)
	. = ..()
	attempt_init(arglist(args))

// This is distinct from /tg/ because of our space management system
// This is overriden in /atom/movable and the parent isn't called if the SMS wants to deal with it's init
/atom/proc/attempt_init(...)
	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			// we were deleted
			return


//Called after New if the map is being loaded. mapload = TRUE
//Called from base of New if the map is not being loaded. mapload = FALSE
//This base must be called or derivatives must set initialized to TRUE
//must not sleep
//Other parameters are passed from New (excluding loc), this does not happen if mapload is TRUE
//Must return an Initialize hint. Defined in __DEFINES/subsystems.dm

//Note: the following functions don't call the base for optimization and must copypasta:
// /turf/Initialize
// /turf/open/space/Initialize

/atom/proc/Initialize(mapload, ...)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(light_power && light_range)
		update_light()

	if(opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guranteed to be on afterwards anyways.

	if(loc)
		loc.InitializedOn(src) // Used for poolcontroller / pool to improve performance greatly. However it also open up path to other usage of observer pattern on turfs.

	ComponentInitialize()

	return INITIALIZE_HINT_NORMAL


//called if Initialize returns INITIALIZE_HINT_LATELOAD
/atom/proc/LateInitialize()
	return

// Put your AddComponent() calls here
/atom/proc/ComponentInitialize()
	return

/atom/proc/InitializedOn(atom/A) // Proc for when something is initialized on a atom - Optional to call. Useful for observer pattern etc.
	return

/atom/proc/onCentcom()
	var/turf/T = get_turf(src)
	if(!T)
		return 0

	if(!is_admin_level(T.z))//if not, don't bother
		return 0

	//check for centcomm shuttles
	for(var/centcom_shuttle in list("emergency", "pod1", "pod2", "pod3", "pod4", "ferry"))
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(centcom_shuttle)
		if(T in M.areaInstance)
			return 1

	//finally check for centcom itself
	return istype(T.loc,/area/centcom)

/atom/proc/onSyndieBase()
	var/turf/T = get_turf(src)
	if(!T)
		return 0

	if(!is_admin_level(T.z))//if not, don't bother
		return 0

	if(istype(T.loc, /area/shuttle/syndicate_elite) || istype(T.loc, /area/syndicate_mothership))
		return 1

	return 0

/atom/Destroy()
	if(alternate_appearances)
		for(var/aakey in alternate_appearances)
			var/datum/alternate_appearance/AA = alternate_appearances[aakey]
			qdel(AA)
		alternate_appearances = null

	QDEL_NULL(reagents)
	invisibility = 101
	LAZYCLEARLIST(overlays)
	LAZYCLEARLIST(priority_overlays)
	return ..()

//Hook for running code when a dir change occurs
/atom/proc/setDir(newdir)
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir

/atom/proc/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	SEND_SIGNAL(src, COMSIG_ATOM_HULK_ATTACK, user)
	if(does_attack_animation)
		user.changeNext_move(CLICK_CD_MELEE)
		add_attack_logs(user, src, "Punched with hulk powers")
		user.do_attack_animation(src, ATTACK_EFFECT_SMASH)

/atom/proc/CheckParts(list/parts_list)
	for(var/A in parts_list)
		if(istype(A, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(A)
			reagents.conditional_update()
		else if(istype(A, /atom/movable))
			var/atom/movable/M = A
			if(istype(M.loc, /mob/living))
				var/mob/living/L = M.loc
				L.unEquip(M)
			M.forceMove(src)

/atom/proc/assume_air(datum/gas_mixture/giver)
	qdel(giver)
	return null

/atom/proc/remove_air(amount)
	return null

/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/atom/proc/check_eye(user as mob)
	if(istype(user, /mob/living/silicon/ai)) // WHYYYY
		return 1
	return

/atom/proc/on_reagent_change()
	return

/atom/proc/Bumped(AM as mob|obj)
	return

// Convenience procs to see if a container is open for chemistry handling
/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/atom/proc/is_injectable(allowmobs = TRUE)
	return reagents && (container_type & (INJECTABLE | REFILLABLE))

/atom/proc/is_drawable(allowmobs = TRUE)
	return reagents && (container_type & (DRAWABLE | DRAINABLE))

/atom/proc/is_refillable()
	return reagents && (container_type & REFILLABLE)

/atom/proc/is_drainable()
	return reagents && (container_type & DRAINABLE)

/atom/proc/CheckExit()
	return 1

/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/atom/proc/emp_act(var/severity)
	return

/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	. = P.on_hit(src, 0, def_zone)

/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return 1
	else if(src in container)
		return 1
	return

/*
 *	atom/proc/search_contents_for(path,list/filter_path=null)
 * Recursevly searches all atom contens (including contents contents and so on).
 *
 * ARGS: path - search atom contents for atoms of this type
 *	   list/filter_path - if set, contents of atoms not of types in this list are excluded from search.
 *
 * RETURNS: list of found atoms
 */

/atom/proc/search_contents_for(path,list/filter_path=null)
	var/list/found = list()
	for(var/atom/A in src)
		if(istype(A, path))
			found += A
		if(filter_path)
			var/pass = 0
			for(var/type in filter_path)
				pass |= istype(A, type)
			if(!pass)
				continue
		if(A.contents.len)
			found += A.search_contents_for(path,filter_path)
	return found


//All atoms
/atom/proc/examine(mob/user, var/distance = -1, var/infix = "", var/suffix = "")
	//This reformat names to get a/an properly working on item descriptions when they are bloody
	var/f_name = "\a [src][infix]."
	if(src.blood_DNA && !istype(src, /obj/effect/decal))
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		if(blood_color != "#030303")
			f_name += "<span class='danger'>blood-stained</span> [name][infix]!"
		else
			f_name += "oil-stained [name][infix]."

	to_chat(user, "[bicon(src)] That's [f_name] [suffix]")
	if(desc)
		to_chat(user, desc)

	if(reagents)
		if(container_type & TRANSPARENT)
			to_chat(user, "<span class='notice'>It contains:</span>")
			if(reagents.reagent_list.len)
				if(user.can_see_reagents()) //Show each individual reagent
					for(var/I in reagents.reagent_list)
						var/datum/reagent/R = I
						to_chat(user, "<span class='notice'>[R.volume] units of [R.name]</span>")
				else //Otherwise, just show the total volume
					if(reagents && reagents.reagent_list.len)
						to_chat(user, "<span class='notice'>[reagents.total_volume] units of various reagents.</span>")
			else
				to_chat(user, "<span class='notice'>Nothing.</span>	")
		else if(container_type & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				to_chat(user, "<span class='notice'>It has [reagents.total_volume] unit\s left.</span>")
			else
				to_chat(user, "<span class='danger'>It's empty.</span>")

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user)

	return distance == -1 || (get_dist(src, user) <= distance) || isobserver(user) //observers do not have a range limit

/atom/proc/relaymove()
	return

/atom/proc/ex_act()
	return

/atom/proc/blob_act(obj/structure/blob/B)
	SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, B)

/atom/proc/fire_act()
	return

/atom/proc/emag_act()
	return

/atom/proc/rpd_act()
	return

/atom/proc/rpd_blocksusage()
	// Atoms that return TRUE prevent RPDs placing any kind of pipes on their turf.
	return FALSE

/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(density && !has_gravity(AM)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, .proc/hitby_react, AM), 2)

/atom/proc/hitby_react(atom/movable/AM)
	if(AM && isturf(AM.loc))
		step(AM, turn(AM.dir, 180))

/atom/proc/add_hiddenprint(mob/living/M as mob)
	if(isnull(M)) return
	if(isnull(M.key)) return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!istype(H.dna, /datum/dna))
			return 0
		if(H.gloves)
			if(fingerprintslast != H.ckey)
				//Add the list if it does not exist.
				if(!fingerprintshidden)
					fingerprintshidden = list()
				fingerprintshidden += text("\[[time_stamp()]\] (Wearing gloves). Real name: [], Key: []",H.real_name, H.key)
				fingerprintslast = H.ckey
			return 0
		if(!( fingerprints ))
			if(fingerprintslast != H.ckey)
				//Add the list if it does not exist.
				if(!fingerprintshidden)
					fingerprintshidden = list()
				fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []",H.real_name, H.key)
				fingerprintslast = H.ckey
			return 1
	else
		if(fingerprintslast != M.ckey)
			//Add the list if it does not exist.
			if(!fingerprintshidden)
				fingerprintshidden = list()
			fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []",M.real_name, M.key)
			fingerprintslast = M.ckey
	return


//Set ignoregloves to add prints irrespective of the mob having gloves on.
/atom/proc/add_fingerprint(mob/living/M as mob, ignoregloves = 0)
	if(isnull(M)) return
	if(isnull(M.key)) return
	if(ishuman(M))
		//Add the list if it does not exist.
		if(!fingerprintshidden)
			fingerprintshidden = list()

		//Fibers~
		add_fibers(M)

		//He has no prints!
		if(FINGERPRINTS in M.mutations)
			if(fingerprintslast != M.key)
				fingerprintshidden += "(Has no fingerprints) Real name: [M.real_name], Key: [M.key]"
				fingerprintslast = M.key
			return 0		//Now, lets get to the dirty work.
		//First, make sure their DNA makes sense.
		var/mob/living/carbon/human/H = M
		if(!istype(H.dna, /datum/dna) || !H.dna.uni_identity || (length(H.dna.uni_identity) != 32))
			if(!istype(H.dna, /datum/dna))
				H.dna = new /datum/dna(null)
				H.dna.real_name = H.real_name
		H.check_dna()

		//Check if the gloves (if any) hide fingerprints
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.transfer_prints)
				ignoregloves = 1

		//Now, deal with gloves.
		if(!ignoregloves)
			if(H.gloves && H.gloves != src)
				if(fingerprintslast != H.ckey)
					fingerprintshidden += text("\[[]\](Wearing gloves). Real name: [], Key: []",time_stamp(), H.real_name, H.key)
					fingerprintslast = H.ckey
				H.gloves.add_fingerprint(M)
				return 0

		//More adminstuffz
		if(fingerprintslast != H.ckey)
			fingerprintshidden += text("\[[]\]Real name: [], Key: []",time_stamp(), H.real_name, H.key)
			fingerprintslast = H.ckey

		//Make the list if it does not exist.
		if(!fingerprints)
			fingerprints = list()

		//Hash this shit.
		var/full_print = H.get_full_print()

		// Add the fingerprints
		fingerprints[full_print] = full_print

		return 1
	else
		//Smudge up dem prints some
		if(fingerprintslast != M.ckey)
			fingerprintshidden += text("\[[]\]Real name: [], Key: []",time_stamp(), M.real_name, M.key)
			fingerprintslast = M.ckey

	return


/atom/proc/transfer_fingerprints_to(var/atom/A)

	// Make sure everything are lists.
	if(!islist(A.fingerprints))
		A.fingerprints = list()
	if(!islist(A.fingerprintshidden))
		A.fingerprintshidden = list()

	if(!islist(fingerprints))
		fingerprints = list()
	if(!islist(fingerprintshidden))
		fingerprintshidden = list()

	// Transfer
	if(fingerprints)
		A.fingerprints |= fingerprints.Copy()            //detective
	if(fingerprintshidden)
		A.fingerprintshidden |= fingerprintshidden.Copy()    //admin
	A.fingerprintslast = fingerprintslast

var/list/blood_splatter_icons = list()

/atom/proc/blood_splatter_index()
	return "\ref[initial(icon)]-[initial(icon_state)]"

//returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(get_blood_id() != "blood")
		return
	return list("ANIMAL DNA" = "Y-")

/mob/living/carbon/get_blood_dna_list()
	if(get_blood_id() != "blood")
		return
	var/list/blood_dna = list()
	if(dna)
		var/mob/living/carbon/human/H = src
		blood_dna[dna.unique_enzymes] = H.b_type
	else
		blood_dna["UNKNOWN DNA"] = "X*"
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("UNKNOWN DNA" = "X*")

//to add a mob's dna info into an object's blood_DNA list.
/atom/proc/transfer_mob_blood_dna(mob/living/L)
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return 0
	return transfer_blood_dna(new_blood_dna)

/obj/effect/decal/cleanable/blood/splatter/transfer_mob_blood_dna(mob/living/L)
	..(L)
	var/list/b_data = L.get_blood_data(L.get_blood_id())
	if(b_data)
		basecolor = b_data["blood_color"]
	else
		basecolor = "#A10808"
	update_icon()

/obj/effect/decal/cleanable/blood/footprints/transfer_mob_blood_dna(mob/living/L)
	..(L)
	var/list/b_data = L.get_blood_data(L.get_blood_id())
	if(b_data)
		basecolor = b_data["blood_color"]
	else
		basecolor = "#A10808"
	update_icon()

//to add blood dna info to the object's blood_DNA list
/atom/proc/transfer_blood_dna(list/blood_dna)
	if(!blood_DNA)
		blood_DNA = list()
	var/old_length = blood_DNA.len
	blood_DNA |= blood_dna
	if(blood_DNA.len > old_length)
		return 1//some new blood DNA was added


//to add blood from a mob onto something, and transfer their dna info
/atom/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.get_blood_dna_list()
	if(!blood_dna)
		return 0
	var/bloodcolor = "#A10808"
	var/list/b_data = M.get_blood_data(M.get_blood_id())
	if(b_data)
		bloodcolor = b_data["blood_color"]

	return add_blood(blood_dna, bloodcolor)

//to add blood onto something, with blood dna info to include.
/atom/proc/add_blood(list/blood_dna, color)
	return 0

/obj/add_blood(list/blood_dna, color)
	return transfer_blood_dna(blood_dna)

/obj/item/add_blood(list/blood_dna, color)
	var/blood_count = !blood_DNA ? 0 : blood_DNA.len
	if(!..())
		return 0
	if(!blood_count)//apply the blood-splatter overlay if it isn't already in there
		add_blood_overlay(color)
	return 1 //we applied blood to the item

/obj/item/clothing/gloves/add_blood(list/blood_dna, color)
	. = ..()
	transfer_blood = rand(2, 4)

/turf/add_blood(list/blood_dna, color)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src)
	B.transfer_blood_dna(blood_dna) //give blood info to the blood decal.
	B.basecolor = color
	return 1 //we bloodied the floor

/mob/living/carbon/human/add_blood(list/blood_dna, color)
	if(wear_suit)
		wear_suit.add_blood(blood_dna, color)
		wear_suit.blood_color = color
		update_inv_wear_suit(1)
	else if(w_uniform)
		w_uniform.add_blood(blood_dna, color)
		w_uniform.blood_color = color
		update_inv_w_uniform(1)
	if(head)
		head.add_blood(blood_dna, color)
		head.blood_color = color
		update_inv_head(0,0)
	if(glasses)
		glasses.add_blood(blood_dna, color)
		glasses.blood_color = color
		update_inv_glasses(0)
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood(blood_dna, color)
		G.blood_color = color
		verbs += /mob/living/carbon/human/proc/bloody_doodle
	else
		hand_blood_color = color
		bloody_hands = rand(2, 4)
		transfer_blood_dna(blood_dna)
		verbs += /mob/living/carbon/human/proc/bloody_doodle

	update_inv_gloves(1)	//handles bloody hands overlays and updating
	return 1

/obj/item/proc/add_blood_overlay(color)
	if(initial(icon) && initial(icon_state))
		//try to find a pre-processed blood-splatter. otherwise, make a new one
		var/index = blood_splatter_index()
		var/icon/blood_splatter_icon = blood_splatter_icons[index]
		if(!blood_splatter_icon)
			blood_splatter_icon = icon(initial(icon), initial(icon_state), , 1)		//we only want to apply blood-splatters to the initial icon_state for each object
			blood_splatter_icon.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
			blood_splatter_icon.Blend(icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
			blood_splatter_icon = fcopy_rsc(blood_splatter_icon)
			blood_splatter_icons[index] = blood_splatter_icon

		blood_overlay = image(blood_splatter_icon)
		blood_overlay.color = color
		overlays += blood_overlay

/atom/proc/clean_blood()
	germ_level = 0
	if(islist(blood_DNA))
		blood_DNA = null
		return TRUE

/obj/effect/decal/cleanable/blood/clean_blood()
	return // While this seems nonsensical, clean_blood isn't supposed to be used like this on a blood decal.

/obj/item/clean_blood()
	. = ..()
	if(.)
		if(blood_overlay)
			overlays -= blood_overlay

/obj/item/clothing/gloves/clean_blood()
	. = ..()
	if(.)
		transfer_blood = 0


/obj/item/clothing/shoes/clean_blood()
	..()
	bloody_shoes = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0)
	blood_state = BLOOD_STATE_NOT_BLOODY
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()


/mob/living/carbon/human/clean_blood()
	if(gloves)
		if(gloves.clean_blood())
			clean_blood()
			update_inv_gloves()
		gloves.germ_level = 0
	else
		..() // Clear the Blood_DNA list
		if(bloody_hands)
			bloody_hands = 0
			update_inv_gloves()
	update_icons()	//apply the now updated overlays to the mob


/atom/proc/add_vomit_floor(mob/living/carbon/M as mob, var/toxvomit = 0)
	if( istype(src, /turf/simulated) )
		var/obj/effect/decal/cleanable/vomit/this = new /obj/effect/decal/cleanable/vomit(src)

		// Make toxins vomit look different
		if(toxvomit)
			this.icon_state = "vomittox_[pick(1,4)]"


/atom/proc/get_global_map_pos()
	if(!islist(global_map) || isemptylist(global_map)) return
	var/cur_x = null
	var/cur_y = null
	var/list/y_arr = null
	for(cur_x=1,cur_x<=global_map.len,cur_x++)
		y_arr = global_map[cur_x]
		cur_y = y_arr.Find(src.z)
		if(cur_y)
			break
//	to_chat(world, "X = [cur_x]; Y = [cur_y]")
	if(cur_x && cur_y)
		return list("x"=cur_x,"y"=cur_y)
	else
		return 0

// Used to provide overlays when using this atom as a viewing focus
// (cameras, locker tint, etc.)
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

//the sight changes to give to the mob whose perspective is set to that atom (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
/atom/proc/update_remote_sight(mob/living/user)
	return

/atom/proc/checkpass(passflag)
	return pass_flags&passflag

/atom/proc/isinspace()
	if(istype(get_turf(src), /turf/space))
		return 1
	else
		return 0

/atom/proc/handle_fall()
	return

/atom/proc/singularity_act()
	return

/atom/proc/singularity_pull()
	return

/atom/proc/narsie_act()
	return

/atom/proc/ratvar_act()
	return

/atom/proc/handle_ricochet(obj/item/projectile/P)
	return

//This proc is called on the location of an atom when the atom is Destroy()'d
/atom/proc/handle_atom_del(atom/A)
	return

/atom/proc/atom_say(message)
	if(!message)
		return
	audible_message("<span class='game say'><span class='name'>[src]</span> [atom_say_verb], \"[message]\"</span>")

/atom/proc/speech_bubble(var/bubble_state = "",var/bubble_loc = src, var/list/bubble_recipients = list())
	return

/atom/vv_edit_var(var_name, var_value)
	if(!Debug2)
		admin_spawned = TRUE
	. = ..()
	switch(var_name)
		if("light_power", "light_range", "light_color")
			update_light()


/atom/vv_get_dropdown()
	. = ..()
	var/turf/curturf = get_turf(src)
	if(curturf)
		.["Jump to turf"] = "?_src_=holder;adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]"
	.["Add reagent"] = "?_src_=vars;addreagent=[UID()]"
	.["Trigger explosion"] = "?_src_=vars;explode=[UID()]"
	.["Trigger EM pulse"] = "?_src_=vars;emp=[UID()]"

/atom/proc/AllowDrop()
	return FALSE

/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : get_turf(L)

/atom/Entered(atom/movable/AM, atom/oldLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, oldLoc)

/atom/Exit(atom/movable/AM, atom/newLoc)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, AM, newLoc) & COMPONENT_ATOM_BLOCK_EXIT)
		return FALSE

/atom/Exited(atom/movable/AM, atom/newLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, newLoc)
