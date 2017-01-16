/atom
	layer = 2
	var/level = 2
	var/flags = 0
	var/list/fingerprints
	var/list/fingerprintshidden
	var/fingerprintslast = null
	var/list/blood_DNA
	var/blood_color
	var/last_bumped = 0
	var/pass_flags = 0
	var/throwpass = 0
	var/germ_level = GERM_LEVEL_AMBIENT // The higher the germ level, the more germ on the atom.
	var/simulated = 1 //filter for actions - used by lighting overlays
	var/atom_say_verb = "says"
	var/dont_save = 0 // For atoms that are temporary by necessity - like lighting overlays

	///Chemistry.
	var/datum/reagents/reagents = null

	//This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list = list()
	//HUD images that this atom can provide.
	var/list/hud_possible


	//var/chem_is_open_container = 0
	// replaced by OPENCONTAINER flags and atom/proc/is_open_container()
	///Chemistry.


	//Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	//Detective Work, used for the duplicate data points kept in the scanners
	var/list/original_atom

	var/allow_spin = 1 //Set this to 1 for a _target_ that is being thrown at; if an atom has this set to 1 then atoms thrown AT it will not spin; currently used for the singularity. -Fox

/atom/proc/onCentcom()
	var/turf/T = get_turf(src)
	if(!T)
		return 0

	if(!is_admin_level(T.z))//if not, don't bother
		return 0

	//check for centcomm shuttles
	for(var/centcom_shuttle in list("emergency", "pod1", "pod2", "pod3", "pod4", "ferry"))
		var/obj/docking_port/mobile/M = shuttle_master.getShuttle(centcom_shuttle)
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

	if(reagents)
		qdel(reagents)
		reagents = null
	invisibility = 101
	return ..()

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

// Convenience proc to see if a container is open for chemistry handling
// returns true if open
// false if closed
/atom/proc/is_open_container()
	return flags & OPENCONTAINER

/*//Convenience proc to see whether a container can be accessed in a certain way.

	proc/can_subract_container()
		return flags & EXTRACT_CONTAINER

	proc/can_add_container()
		return flags & INSERT_CONTAINER
*/



/atom/proc/allow_drop()
	return 1

/atom/proc/CheckExit()
	return 1

/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/atom/proc/emp_act(var/severity)
	return

/atom/proc/bullet_act(var/obj/item/projectile/Proj, def_zone)
	Proj.on_hit(src, 0, def_zone)
	return 0

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

	if(reagents && is_open_container()) //is_open_container() isn't really the right proc for this, but w/e
		to_chat(user, "It contains:")
		if(reagents.reagent_list.len)
			if(user.can_see_reagents()) //Show each individual reagent
				for(var/datum/reagent/R in reagents.reagent_list)
					to_chat(user, "[R.volume] units of [R.name]")
			else //Otherwise, just show the total volume
				if(reagents && reagents.reagent_list.len)
					to_chat(user, "[reagents.total_volume] units of various reagents.")
		else
			to_chat(user, "Nothing.")

	return distance == -1 || (get_dist(src, user) <= distance) || isobserver(user) //observers do not have a range limit

/atom/proc/relaymove()
	return

//called to set the atom's dir and used to add behaviour to dir-changes - Not fully used (yet)
/atom/proc/set_dir(new_dir)
	. = new_dir != dir
	dir = new_dir

/atom/proc/ex_act()
	return

/atom/proc/blob_act()
	return

/atom/proc/fire_act()
	return

/atom/proc/emag_act()
	return

/atom/proc/hitby(atom/movable/AM as mob|obj)
	if(density)
		AM.throwing = 0
	return

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
	// Returns 0 if we have that blood already
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return 0
	if(!blood_DNA)	//if our list of DNA doesn't exist yet, initialise it.
		blood_DNA = list()
	var/old_length = blood_DNA.len
	blood_DNA |= new_blood_dna
	if(blood_DNA.len == old_length)
		return 0
	return 1

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
	return add_blood(blood_dna)

//to add blood onto something, with blood dna info to include.
/atom/proc/add_blood(list/blood_dna)
	return 0

/obj/add_blood(list/blood_dna)
	return transfer_blood_dna(blood_dna)

/obj/item/add_blood(list/blood_dna)
	var/blood_count = !blood_DNA ? 0 : blood_DNA.len
	if(!..())
		return 0
	if(!blood_count)//apply the blood-splatter overlay if it isn't already in there
		add_blood_overlay(blood_DNA[blood_color])
	return 1 //we applied blood to the item

/obj/item/proc/add_blood_overlay(var/bloodcolor)
	if(initial(icon) && initial(icon_state))
		//try to find a pre-processed blood-splatter. otherwise, make a new one
		var/index = blood_splatter_index()
		var/icon/blood_splatter_icon = blood_splatter_icons[index]
		if(!blood_splatter_icon)
			blood_splatter_icon = icon(initial(icon), initial(icon_state), , 1)		//we only want to apply blood-splatters to the initial icon_state for each object
			blood_splatter_icon.Blend(bloodcolor, ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
			blood_splatter_icon.Blend(icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
			blood_splatter_icon = fcopy_rsc(blood_splatter_icon)
			blood_splatter_icons[index] = blood_splatter_icon
		overlays += blood_splatter_icon

/obj/item/clothing/gloves/add_blood(list/blood_dna)
	. = ..()
	transfer_blood = rand(2, 4)

/turf/add_blood(list/blood_dna)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src)
	B.transfer_blood_dna(blood_dna) //give blood info to the blood decal.
	return 1 //we bloodied the floor

/mob/living/carbon/human/add_blood(list/blood_dna)
	if(wear_suit)
		wear_suit.add_blood(blood_dna)
		update_inv_wear_suit()
	else if(w_uniform)
		w_uniform.add_blood(blood_dna)
		update_inv_w_uniform()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood(blood_dna)
	else
		transfer_blood_dna(blood_dna)
	bloody_hands = rand(2, 4)
	update_inv_gloves()	//handles bloody hands overlays and updating
	return 1

/atom/proc/clean_blood()
	src.germ_level = 0
	if(istype(blood_DNA, /list))
		qdel(blood_DNA)
		return 1

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

/atom/proc/atom_say(message)
	if(!message)
		return
	audible_message("<span class='game say'><span class='name'>[src]</span> [atom_say_verb], \"[message]\"</span>")

/atom/proc/speech_bubble(var/bubble_state = "",var/bubble_loc = src, var/list/bubble_recipients = list())
	return
