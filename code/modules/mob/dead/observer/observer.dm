#define GHOST_CAN_REENTER 1
#define GHOST_IS_OBSERVER 2

var/list/image/ghost_darkness_images = list() //this is a list of images for things ghosts should still be able to see when they toggle darkness

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = 4
	stat = DEAD
	density = 0
	canmove = 0
	blinded = 0
	anchored = 1	//  don't get pushed around
	invisibility = INVISIBILITY_OBSERVER
	var/can_reenter_corpse
	var/datum/hud/living/carbon/hud = null // hud
	var/bootime = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	universal_speak = 1
	var/atom/movable/following = null
	var/anonsay = 0
	var/image/ghostimage = null //this mobs ghost image, for deleting and stuff
	var/ghostvision = 1 //is the ghost able to see things humans can't?
	var/seedarkness = 1
	var/data_hud_seen = 0 //this should one of the defines in __DEFINES/hud.dm
	var/medhud = 0

/mob/dead/observer/New(var/mob/body=null, var/flags=1)
	sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = SEE_INVISIBLE_OBSERVER_AI_EYE
	see_in_dark = 100
	verbs += /mob/dead/observer/proc/dead_tele

	// Our new boo spell.
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/boo(src))

	can_reenter_corpse = flags & GHOST_CAN_REENTER
	started_as_observer = flags & GHOST_IS_OBSERVER


	stat = DEAD

	ghostimage = image(src.icon,src,src.icon_state)
	ghost_darkness_images |= ghostimage
	updateallghostimages()

	var/turf/T
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?
		attack_log = body.attack_log	//preserve our attack logs by copying them to our ghost

		if (ishuman(body))
			var/mob/living/carbon/human/H = body
			icon = H.stand_icon
			overlays = H.overlays_standing
		else
			icon = body.icon
			icon_state = body.icon_state
			overlays = body.overlays

		alpha = 127
		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				if(gender == MALE)
					name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
				else
					name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.

	if(!T)	T = pick(latejoin)			//Safety in case we cannot find the body's position
	forceMove(T)

	if(!name)							//To prevent nameless ghosts
		name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
	real_name = name
	..()

/mob/dead/observer/Destroy()
	if(ismob(following))
		var/mob/M = following
		M.following_mobs -= src
	following = null
	if (ghostimage)
		ghost_darkness_images -= ghostimage
		qdel(ghostimage)
		ghostimage = null
		updateallghostimages()
	return ..()

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1


/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/
/mob/dead/observer/Life()
	..()
	if(!loc) return
	if(!client) return 0

	//regular_hud_updates()
	//if(client.images.len)
	//	for(var/image/hud in client.images)
	//		if(copytext(hud.icon_state,1,4) == "hud")
	//			client.images.Remove(hud)
	//if(antagHUD)
	//	var/list/target_list = list()
	//	for(var/mob/living/target in oview(src, 14))
	//		if(target.mind && (target.mind.special_role || issilicon(target) || target.mind.nation))
	//			target_list += target
	//	if(target_list.len)
	//		assess_targets(target_list, src)


/mob/dead/proc/assess_targets(list/target_list, mob/dead/observer/U)
	var/client/C = U.client
	for(var/mob/living/carbon/human/target in target_list)
		C.images += target.hud_list[SPECIALROLE_HUD]
		//C.images += target.hud_list[NATIONS_HUD]
	for(var/mob/living/silicon/target in target_list)
		C.images += target.hud_list[SPECIALROLE_HUD]
		//C.images += target.hud_list[NATIONS_HUD]

	return 1

/mob/proc/ghostize(var/flags = GHOST_CAN_REENTER)
	if(key)
		var/mob/dead/observer/ghost = new(src, flags)	//Transfer safety to observer spawning proc.
		ghost.timeofdeath = src.timeofdeath //BS12 EDIT
		respawnable_list -= src
		if(ghost.can_reenter_corpse)
			respawnable_list += ghost
		ghost.key = key
		if(!ghost.client.holder && !config.antag_hud_allowed)    // For new ghosts we remove the verb from even showing up if it's not allowed.
			ghost.verbs -= /mob/dead/observer/verb/toggle_antagHUD  // Poor guys, don't know what they are missing!
		return ghost

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	var/mob/M = src

	if(stat == DEAD)
		ghostize(1)
	else
		var/response = alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to play this round for another 30 minutes! You can't change your mind so choose wisely!)","Are you sure you want to ghost?","Ghost","Stay in body")
		if(response != "Ghost")	return	//didn't want to ghost after-all
		resting = 1
		var/mob/dead/observer/ghost = ghostize(0)            //0 parameter is so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
		ghost.timeofdeath = world.time // Because the living mob won't have a time of death and we want the respawn timer to work properly.

	var/obj/structure/morgue/Morgue = locate() in M.loc
	if(istype(M.loc,/obj/structure/morgue))
		Morgue = M.loc
	if(Morgue)
		Morgue.update()

	return


/mob/dead/observer/Move(NewLoc, direct)
	following = null
	dir = direct
	if(NewLoc)
		forceMove(NewLoc)
		return
	forceMove(get_turf(src)) //Get out of closets and such as a ghost
	if((direct & NORTH) && y < world.maxy)
		y++
	else if((direct & SOUTH) && y > 1)
		y--
	if((direct & EAST) && x < world.maxx)
		x++
	else if((direct & WEST) && x > 1)
		x--

	for(var/obj/effect/step_trigger/S in locate(x, y, z))	//<-- this is dumb
		S.Crossed(src)

	var/area/A = get_area_master(src)
	if(A)
		A.Entered(src)

	..()

/mob/dead/observer/experience_pressure_difference()
	return 0

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/Stat()
	..()
	statpanel("Status")
	if (client.statpanel == "Status")
		stat(null, "Station Time: [worldtime2text()]")
		if(ticker)
			if(ticker.mode)
				//world << "DEBUG: ticker not null"
				if(ticker.mode.name == "AI malfunction")
					//world << "DEBUG: malf mode ticker test"
					if(ticker.mode:malf_mode_declared)
						stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
		if(shuttle_master.emergency.mode >= SHUTTLE_RECALL)
			var/timeleft = shuttle_master.emergency.timeLeft()
			if(timeleft > 0)
				stat(null, "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]")

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!client)	return
	if(!can_reenter_corpse)
		src << "<span class='warning'>You've given up your right to respawn!</span>"
		return
	if(!(mind && mind.current && can_reenter_corpse))
		src << "<span class='warning'>You have no body.</span>"
		return
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		usr << "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>"
		return
	if(mind.current.ajourn && mind.current.stat != DEAD) 	//check if the corpse is astral-journeying (it's client ghosted using a cultist rune).
		var/obj/effect/rune/R = locate() in mind.current.loc	//whilst corpse is alive, we can only reenter the body if it's on the rune
		if(!(R && R.word1 == cultwords["hell"] && R.word2 == cultwords["travel"] && R.word3 == cultwords["self"]))	//astral journeying rune
			usr << "<span class='warning'>The astral cord that ties your body and your spirit has been severed. You are likely to wander the realm beyond until your body is finally dead and thus reunited with you.</span>"
			return
	mind.current.ajourn=0
	mind.current.key = key

	var/obj/structure/morgue/Morgue = locate() in mind.current.loc
	if(istype(mind.current.loc,/obj/structure/morgue))
		Morgue = mind.current.loc
	if(Morgue)
		Morgue.update()

	return 1


/mob/dead/observer/verb/toggle_medHUD()
	set category = "Ghost"
	set name = "Toggle MedicHUD"
	set desc = "Toggles the medical HUD."
	if(!client)
		return
	var/datum/atom_hud/H = huds[DATA_HUD_MEDICAL_BASIC]
	H.remove_hud_from(src)//out with the old..
	if(medhud==0)//TOGGLE!
		medhud = 1
		H.add_hud_to(src)
	else
		medhud = 0


/mob/dead/observer/verb/toggle_antagHUD()
	set category = "Ghost"
	set name = "Toggle AntagHUD"
	set desc = "Toggles AntagHUD allowing you to see who is the antagonist"
	if(!config.antag_hud_allowed && !client.holder)
		src << "\red Admins have disabled this for this round."
		return
	if(!client)
		return
	var/mob/dead/observer/M = src
	if(jobban_isbanned(M, "AntagHUD"))
		src << "\red <B>You have been banned from using this feature</B>"
		return
	if(config.antag_hud_restricted && !M.has_enabled_antagHUD && !check_rights(R_ADMIN|R_MOD,0))
		var/response = alert(src, "If you turn this on, you will not be able to take any part in the round.","Are you sure you want to turn this feature on?","Yes","No")
		if(response == "No") return
		M.can_reenter_corpse = 0
		if(M in respawnable_list)
			respawnable_list -= M
	if(!M.has_enabled_antagHUD && !check_rights(R_ADMIN|R_MOD,0))
		M.has_enabled_antagHUD = 1

	var/datum/atom_hud/A = huds[DATA_HUD_SECURITY_ADVANCED]
	var/adding_hud = (usr in A.hudusers) ? 0 : 1
	for(var/datum/atom_hud/H in huds)
		if(istype(H, /datum/atom_hud/antag) || istype(H, /datum/atom_hud/data/human/security/advanced))
			(adding_hud) ? H.add_hud_to(usr) : H.remove_hud_from(usr)
	usr << "AntagHud Toggled [adding_hud ? "ON" : "OFF"]"


/mob/dead/observer/proc/dead_tele(A in ghostteleportlocs)
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"

	if(!isobserver(usr))
		usr << "Not when you're not dead!"
		return

	usr.verbs -= /mob/dead/observer/proc/dead_tele
	spawn(30)
		usr.verbs += /mob/dead/observer/proc/dead_tele

	var/area/thearea = ghostteleportlocs[A]
	if(!thearea)	return

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L += T

	if(!L || !L.len)
		usr << "<span class='warning'>No area available.</span>"

	usr.forceMove(pick(L))
	following = null

/mob/dead/observer/verb/follow(input in getmobs())
	set category = "Ghost"
	set name = "Follow" // "Haunt"
	set desc = "Follow and haunt a mob."

	var/target = getmobs()[input]
	if(!target) return
	ManualFollow(target)

// This is the ghost's follow verb with an argument
/mob/dead/observer/proc/ManualFollow(var/atom/movable/target)
	if(!target)
		return

	if(target != src)
		if(following && following == target)
			return
		following = target
		src << "<span class='notice'>Now following [target]</span>"
		if(ismob(target))
			forceMove(get_turf(target))
			var/mob/M = target
			M.following_mobs += src
		else
			spawn(0)
				while(target && following == target && client)
					var/turf/T = get_turf(target)
					if(!T)
						break
					// To stop the ghost flickering.
					if(loc != T)
						forceMove(T)
					sleep(15)

/mob/proc/update_following()
	. = get_turf(src)
	for(var/mob/dead/observer/M in following_mobs)
		if(M.following != src)
			following_mobs -= M
		else
			if(M.loc != .)
				M.forceMove(.)

/mob
	var/list/following_mobs = list()

/mob/Move()
	. = ..()
	if(.)
		update_following()

/mob/Life()
	// to catch teleports etc which directly set loc
	update_following()
	return ..()

/mob/dead/observer/verb/jumptomob(target in getmobs()) //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob"

	if(istype(usr, /mob/dead/observer)) //Make sure they're an observer!

		if (!target)//Make sure we actually have a target
			return
		else
			var/mob/M = getmobs()[target] //Destination mob
			var/turf/T = get_turf(M) //Turf of the destination mob

			if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
				forceMove(T)
				following = null
			else
				src << "This mob is not located in the game world."


/* Now a spell.  See spells.dm
/mob/dead/observer/verb/boo()
	set category = "Ghost"
	set name = "Boo!"
	set desc= "Scare your crew members because of boredom!"

	if(bootime > world.time) return
	bootime = world.time + 600
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L)
		L.flicker()
	//Maybe in the future we can add more <i>spooky</i> code here!
	return
*/

/mob/dead/observer/memory()
	set hidden = 1
	src << "\red You are dead! You have no mind to store memory!"

/mob/dead/observer/add_memory()
	set hidden = 1
	src << "\red You are dead! You have no mind to store memory!"

/mob/dead/observer/verb/analyze_air()
	set name = "Analyze Air"
	set category = "Ghost"

	if(!istype(usr, /mob/dead/observer)) return

	// Shamelessly copied from the Gas Analyzers
	if (!( istype(usr.loc, /turf) ))
		return

	var/datum/gas_mixture/environment = usr.loc.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	src << "\blue <B>Results:</B>"
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		src << "\blue Pressure: [round(pressure,0.1)] kPa"
	else
		src << "\red Pressure: [round(pressure,0.1)] kPa"
	if(total_moles)
		var/o2_concentration = environment.oxygen/total_moles
		var/n2_concentration = environment.nitrogen/total_moles
		var/co2_concentration = environment.carbon_dioxide/total_moles
		var/plasma_concentration = environment.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		if(abs(n2_concentration - N2STANDARD) < 20)
			src << "\blue Nitrogen: [round(n2_concentration*100)]% ([round(environment.nitrogen,0.01)] moles)"
		else
			src << "\red Nitrogen: [round(n2_concentration*100)]% ([round(environment.nitrogen,0.01)] moles)"

		if(abs(o2_concentration - O2STANDARD) < 2)
			src << "\blue Oxygen: [round(o2_concentration*100)]% ([round(environment.oxygen,0.01)] moles)"
		else
			src << "\red Oxygen: [round(o2_concentration*100)]% ([round(environment.oxygen,0.01)] moles)"

		if(co2_concentration > 0.01)
			src << "\red CO2: [round(co2_concentration*100)]% ([round(environment.carbon_dioxide,0.01)] moles)"
		else
			src << "\blue CO2: [round(co2_concentration*100)]% ([round(environment.carbon_dioxide,0.01)] moles)"

		if(plasma_concentration > 0.01)
			src << "\red Plasma: [round(plasma_concentration*100)]% ([round(environment.toxins,0.01)] moles)"

		if(unknown_concentration > 0.01)
			src << "\red Unknown: [round(unknown_concentration*100)]% ([round(unknown_concentration*total_moles,0.01)] moles)"

		src << "\blue Temperature: [round(environment.temperature-T0C,0.1)]&deg;C"
		src << "\blue Heat Capacity: [round(environment.heat_capacity(),0.1)]"

/mob/dead/observer/verb/view_manifest()
	set name = "View Crew Manifest"
	set category = "Ghost"

	var/dat
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest()

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

//this is called when a ghost is drag clicked to something.
/mob/dead/observer/MouseDrop(atom/over)
	if(!usr || !over) return
	if (isobserver(usr) && usr.client && usr.client.holder && isliving(over))
		if (usr.client.holder.cmd_ghost_drag(src,over))
			return

	return ..()

/proc/ghost_follow_link(var/atom/target, var/atom/ghost)
	if((!target) || (!ghost)) return
	if(isAI(target)) // AI core/eye follow links
		var/mob/living/silicon/ai/A = target
		. = "<a href='byond://?src=\ref[ghost];follow=\ref[A]'>core</a>"
		if(A.client && A.eyeobj) // No point following clientless AI eyes
			. += "|<a href='byond://?src=\ref[ghost];follow=\ref[A.eyeobj]'>eye</a>"
		return
	else if(istype(target, /mob/dead/observer))
		var/mob/dead/observer/O = target
		. = "<a href='byond://?src=\ref[ghost];follow=\ref[target]'>follow</a>"
		if(O.mind && O.mind.current)
			. += "|<a href='byond://?src=\ref[ghost];follow=\ref[O.mind.current]'>body</a>"
		return
	else
		return "<a href='byond://?src=\ref[ghost];follow=\ref[target]'>follow</a>"

//BEGIN TELEPORT HREF CODE
/mob/dead/observer/Topic(href, href_list)
	if(usr != src)
		return
		..()

	if (href_list["track"])
		var/atom/target = locate(href_list["track"])
		if(target)
			ManualFollow(target)

	if (href_list["follow"])
		var/atom/target = locate(href_list["follow"])
		if(target)
			ManualFollow(target)

	if (href_list["jump"])
		var/mob/target = locate(href_list["jump"])
		var/mob/A = usr;
		A << "Teleporting to [target]..."
		//var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(target && target != usr)
			spawn(0)
				var/turf/pos = get_turf(A)
				var/turf/T=get_turf(target)
				if(T != pos)
					if(!T)
						return
					if(!client)
						return
					forceMove(T)
				following = null
	..()
//END TELEPORT HREF CODE

/mob/dead/observer/verb/toggle_anonsay()
	set category = "Ghost"
	set name = "Toggle Anonymous Chat"
	set desc = "Toggles showing your key in dead chat."

	src.anonsay = !src.anonsay
	if(anonsay)
		src << "<span class='info'>Your key won't be shown when you speak in dead chat.</span>"
	else
		src << "<span class='info'>Your key will be publicly visible again.</span>"

/mob/dead/observer/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"
	set category = "Ghost"
	ghostvision = !(ghostvision)
	updateghostsight()
	usr << "You [(ghostvision?"now":"no longer")] have ghost vision."

/mob/dead/observer/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"
	seedarkness = !(seedarkness)
	updateghostsight()

/mob/dead/observer/proc/updateghostsight()
	if (!seedarkness)
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
	else
		see_invisible = SEE_INVISIBLE_OBSERVER
		if (!ghostvision)
			see_invisible = SEE_INVISIBLE_LIVING;
	updateghostimages()

/proc/updateallghostimages()
	for (var/mob/dead/observer/O in player_list)
		O.updateghostimages()

/mob/dead/observer/proc/updateghostimages()
	if (!client)
		return
	if (seedarkness || !ghostvision)
		client.images -= ghost_darkness_images
	else
		//add images for the 60inv things ghosts can normally see when darkness is enabled so they can see them now
		client.images |= ghost_darkness_images
		if (ghostimage)
			client.images -= ghostimage //remove ourself

/mob/proc/can_admin_interact()
	return 0

/mob/dead/observer/can_admin_interact()
	return check_rights(R_ADMIN, 0, src)

//this is a mob verb instead of atom for performance reasons
//see /mob/verb/examinate() in mob.dm for more info
//overriden here and in /mob/living for different point span classes and sanity checks
/mob/dead/observer/pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return 0
	usr.visible_message("<span class='deadsay'><b>[src]</b> points to [A].</span>")
	return 1
