
/mob/living/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

/mob/living/Stat()
	. = ..()
	if(. && get_rig_stats)
		var/obj/item/weapon/rig/rig = get_rig()
		if(rig)
			SetupStat(rig)

/mob/living/proc/can_track(mob/living/user)
	//basic fast checks go first. When overriding this proc, I recommend calling ..() at the end.
	var/turf/T = get_turf(src)
	if(!T)
		return 0
	if(T.z == ZLEVEL_CENTCOMM) //dont detect mobs on centcomm
		return 0
	if(T.z >= MAX_Z)
		return 0
	if(user != null && src == user)
		return 0
	if(invisibility || alpha == 0)//cloaked
		return 0
	if(digitalcamo)
		return 0

	// Now, are they viewable by a camera? (This is last because it's the most intensive check)
	if(!near_camera(src))
		return 0

	return 1

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(AM.Adjacent(src))
		src.start_pulling(AM)
	return

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(incapacitated())
		return 0
	if(src.status_flags & FAKEDEATH)
		return 0
	if(!..())
		return 0
	visible_message("<b>[src]</b> points to [A]")
	return 1

/mob/living/verb/succumb()
	set hidden = 1
	if (InCritical())
		attack_log += "[src] has ["succumbed to death"] with [round(health, 0.1)] points of health!"
		adjustOxyLoss(health - config.health_threshold_dead)
		updatehealth()
		// super check for weird mobs, including ones that adjust hp
		// we don't want to go overboard and gib them, though
		for(var/i = 1 to 5)
			if(health < config.health_threshold_dead)
				break
			take_overall_damage(max(5, health - config.health_threshold_dead), 0)
			updatehealth()
		to_chat(src, "<span class='notice'>You have given up life and succumbed to death.</span>")

/mob/living/proc/InCritical()
	return (src.health < 0 && src.health > -95.0 && stat == UNCONSCIOUS)

/mob/living/ex_act(severity)
	..()
	flash_eyes()

/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
//		to_chat(world, "DEBUG: burn_skin(), mutations=[mutations]")
		if (RESIST_HEAT in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/obj/item/organ/external/affecting in H.organs)
			if(!affecting)	continue
			if(affecting.take_damage(0, divided_damage+extradam))	//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
				H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		to_chat(world, "[src] ~ [src.bodytemperature] ~ [temperature]")
	return temperature


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn
// I touched them without asking... I'm soooo edgy ~Erro (added nodamage checks)
// no ~Tigerkitty

/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	bruteloss = min(max(bruteloss + amount, 0),(maxHealth*2))

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = min(max(oxyloss + amount, 0),(maxHealth*2))

/mob/living/proc/setOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = min(max(toxloss + amount, 0),(maxHealth*2))

/mob/living/proc/setToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	fireloss = min(max(fireloss + amount, 0),(maxHealth*2))

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = min(max(cloneloss + amount, 0),(maxHealth*2))

/mob/living/proc/setCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = min(max(brainloss + amount, 0),(maxHealth*2))

/mob/living/proc/setBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = amount

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/adjustStaminaLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	staminaloss = min(max(staminaloss + amount, 0),(maxHealth*2))

/mob/living/proc/setStaminaLoss(var/amount)
	if(status_flags & GODMODE)	return 0
	staminaloss = amount

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(var/newMaxHealth)
	maxHealth = newMaxHealth

// ++++ROCKDTBEN++++ MOB PROCS //END


/mob/proc/get_contents()


//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/weapon/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/weapon/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/weapon/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += src.contents
		for(var/obj/item/weapon/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/suit/storage/S in src.contents)//Check for labcoats and jackets
			L += get_contents(S)
		for(var/obj/item/clothing/accessory/storage/S in src.contents)//Check for holsters
			L += get_contents(S)
		for(var/obj/item/weapon/gift/G in src.contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in src.contents) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		for(var/obj/item/weapon/folder/F in src.contents)
			L += F.contents //Folders can't store any storage items.

		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = src.get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/mob/living/proc/can_inject()
	return 1

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter:zone_sel.selecting
	if ((t in list( "eyes", "mouth" )))
		t = "head"
	var/obj/item/organ/external/def_zone = ran_zone(t)
	return def_zone


//damage/heal the mob ears and adjust the deaf amount
/mob/living/adjustEarDamage(damage, deaf)
	ear_damage = max(0, ear_damage + damage)
	ear_deaf = max(0, ear_deaf + deaf)

//pass a negative argument to skip one of the variable
/mob/living/setEarDamage(damage, deaf)
	if(damage >= 0)
		ear_damage = damage
	if(deaf >= 0)
		ear_deaf = deaf

// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/restore_all_organs()
	return

/mob/living/proc/revive()
	rejuvenate()
	buckled = initial(src.buckled)
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if (C.handcuffed && !initial(C.handcuffed))
			C.unEquip(C.handcuffed)
		C.handcuffed = initial(C.handcuffed)

		if (C.legcuffed && !initial(C.legcuffed))
			C.unEquip(C.legcuffed)
		C.legcuffed = initial(C.legcuffed)
		if(C.reagents)
			for(var/datum/reagent/R in C.reagents.reagent_list)
				C.reagents.clear_reagents()
			C.reagents.addiction_list.Cut()

/mob/living/proc/update_revive() // handles revival through other means than cloning or adminbus (defib, IPC repair)
	stat = CONSCIOUS
	dead_mob_list -= src
	living_mob_list |= src
	mob_list |= src
	ear_deaf = 0
	timeofdeath = 0

/mob/living/proc/rejuvenate()
	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	setStaminaLoss(0)
	SetSleeping(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
	losebreath = 0
	dizziness = 0
	jitteriness = 0
	confused = 0
	drowsyness = 0
	radiation = 0
	nutrition = 400
	bodytemperature = 310
	sdisabilities = 0
	disabilities = 0
	blinded = 0
	eye_blind = 0
	eye_blurry = 0
	ear_deaf = 0
	ear_damage = 0
	heal_overall_damage(1000, 1000)
	ExtinguishMob()
	fire_stacks = 0
	on_fire = 0
	suiciding = 0
	buckled = initial(src.buckled)

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.handcuffed = initial(C.handcuffed)
		C.heart_attack = 0

		for(var/datum/disease/D in C.viruses)
			D.cure(0)

		// restore all of the human's blood and reset their shock stage
		if(ishuman(src))
			var/mob/living/carbon/human/human_mob = src
			human_mob.restore_blood()
			human_mob.shock_stage = 0
			human_mob.decaylevel = 0

	restore_all_organs()
	if(stat == DEAD)
		dead_mob_list -= src
		living_mob_list += src
		timeofdeath = 0

	stat = CONSCIOUS
	update_fire()
	regenerate_icons()
	return

/mob/living/proc/UpdateDamageIcon()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(usr, "[src] does not have any stored infomation!")
	else
		to_chat(usr, "OOC Metadata is not supported by this server!")

	return

/mob/living/Move(atom/newloc, direct)
	if (buckled && buckled.loc != newloc) //not updating position
		if (!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	if (restrained())
		stop_pulling()


	var/t7 = 1
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if(t7 && pulling && (get_dist(src, pulling) <= 1 || pulling.loc == loc))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				stop_pulling()
				return
			else
				if(Debug)
					diary <<"pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			stop_pulling()
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (isliving(pulling))
					var/mob/living/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								qdel(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/atom/movable/t = M.pulling
						M.stop_pulling()

						//this is the gay blood on floor shit -- Added back -- Skie
						if (M.lying && (prob(M.getBruteLoss() / 6)))
							var/turf/location = M.loc
							if (istype(location, /turf/simulated))
								location.add_blood()
						pulling.Move(T, get_dir(pulling, T))
						if(M)
							M.start_pulling(t)
				else
					if (pulling)
						pulling.Move(T, get_dir(pulling, T))
	else
		stop_pulling()
		. = ..()

	if (s_active && !( s_active in contents ) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents ) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

	if(.) // did we actually move?
		handle_footstep(loc)
		step_count++

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)

/mob/living/proc/handle_footstep(turf/T)
	if(istype(T))
		return 1
	return 0

/*//////////////////////
	START RESIST PROCS
*///////////////////////

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.changeNext_move(CLICK_CD_RESIST)

	var/mob/living/L = usr

	//Resisting control by an alien mind.
	if(istype(src.loc,/mob/living/simple_animal/borer))
		resist_borer()

	//resisting grabs (as if it helps anyone...)
	if ((!(L.stat) && !(L.restrained())))
		resist_grab(L) //this passes L because the proc requires a typecasted mob/living instead of just 'src'

	//unbuckling yourself
	if(L.buckled && (L.last_special <= world.time) )
		resist_buckle(L) //this passes L because the proc requires a typecasted mob/living instead of just 'src'

	//Breaking out of an object?
	else if(src.loc && istype(src.loc, /obj) && (!isturf(src.loc)))
		if(stat == CONSCIOUS && !stunned && !weakened && !paralysis)
			var/obj/C = loc
			C.container_resist(L)

	//breaking out of handcuffs
	else if(iscarbon(L))
		var/mob/living/carbon/CM = L

		if(CM.on_fire && CM.canmove)
			resist_stop_drop_roll(CM) //this passes CM because the proc requires a typecasted mob/living/carbon instead of just 'src'

		if(CM.handcuffed && CM.canmove && (CM.last_special <= world.time))//this passes CM because the proc requires a typecasted mob/living/carbon instead of just 'src'
			resist_handcuffs(CM)

		else if(CM.legcuffed && CM.canmove && (CM.last_special <= world.time)) //this passes CM because the proc requires a typecasted mob/living/carbon instead of just 'src'
			resist_legcuffs(CM)

/*////////////////////
	RESIST SUBPROCS
*/////////////////////

/* resist_borer allows a mob to regain control of their body after a borer has assumed control.
*/////
/mob/living/proc/resist_borer()
	var/mob/living/simple_animal/borer/B = src.loc
	var/mob/living/captive_brain/H = src

	to_chat(H, "\red <B>You begin doggedly resisting the parasite's control (this will take approximately sixty seconds).</B>")
	to_chat(B.host, "\red <B>You feel the captive mind of [src] begin to resist your control.</B>")

	spawn(rand(350,450)+B.host.brainloss)

		if(!B || !B.controlling)
			return

		B.host.adjustBrainLoss(rand(5,10))
		to_chat(H, "\red <B>With an immense exertion of will, you regain control of your body!</B>")
		to_chat(B.host, "\red <B>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</b>")

		B.detatch()

		verbs -= /mob/living/carbon/proc/release_control
		verbs -= /mob/living/carbon/proc/punish_host
		verbs -= /mob/living/carbon/proc/spawn_larvae

		return

/* resist_grab allows a mob to resist a grab from another mob when disarming is not an option/neckgrabbed.
*/////
/mob/living/proc/resist_grab(var/mob/living/L)
	var/resisting = 0

	for(var/obj/O in L.requests)
		L.requests.Remove(O)
		qdel(O)
		resisting++

	for(var/obj/item/weapon/grab/G in usr.grabbed_by)
		resisting++
		if (G.state == 1)
			qdel(G)

		else
			if(G.state == 2)
				if(prob(60))
					for(var/mob/O in viewers(L, null))
						O.show_message(text("\red [] has broken free of []'s grip!", L, G.assailant), 1)
					qdel(G)

			else
				if(G.state == 3)
					if(prob(5))
						for(var/mob/O in viewers(usr, null))
							O.show_message(text("\red [] has broken free of []'s headlock!", L, G.assailant), 1)
						qdel(G)

	if(resisting)
		for(var/mob/O in viewers(usr, null))
			O.show_message(text("\red <B>[] resists!</B>", L), 1)

/* resist_buckle allows a mob that is bucklecuffed to break free of the chair/bed/whatever
*/////
/mob/living/proc/resist_buckle(var/mob/living/L)
	if(iscarbon(L))
		var/mob/living/carbon/C = L

		if(C.handcuffed)
			C.changeNext_move(CLICK_CD_BREAKOUT)
			C.last_special = world.time + CLICK_CD_BREAKOUT

			to_chat(C, "\red You attempt to unbuckle yourself. (This will take around 2 minutes and you need to stay still)</span>")
			for(var/mob/O in viewers(L))
				O.show_message("\red <B>[usr] attempts to unbuckle themself!</B>", 1)

			spawn(0)
				if(do_after(usr, 1200, target = C))
					if(!C.buckled)
						return
					for(var/mob/O in viewers(C))
						O.show_message("\red <B>[usr] manages to unbuckle themself!</B>", 1)
					to_chat(C, "\blue You successfully unbuckle yourself.")
					C.buckled.user_unbuckle_mob(C,C)

	else
		L.buckled.user_unbuckle_mob(L,L)

/* resist_stop_drop_roll allows a mob to stop, drop, and roll in order to put out a fire burning on them.
*/////
/mob/living/proc/resist_stop_drop_roll(var/mob/living/carbon/CM)
	CM.fire_stacks -= 5
	CM.weakened = max(CM.weakened, 3)//We dont check for CANWEAKEN, I don't care how immune to weakening you are, if you're rolling on the ground, you're busy.
	CM.update_canmove()
	CM.spin(32,2)
	CM.visible_message("<span class='danger'>[CM] rolls on the floor, trying to put themselves out!</span>", \
		"<span class='notice'>You stop, drop, and roll!</span>")
	sleep(30)
	if(fire_stacks <= 0)
		CM.visible_message("<span class='danger'>[CM] has successfully extinguished themselves!</span>", \
			"<span class='notice'>You extinguish yourself.</span>")
		ExtinguishMob()
	return

/* resist_handcuffs allows a mob to break/remove their handcuffs after a delay
*/////
/mob/living/proc/resist_handcuffs(var/mob/living/carbon/CM)
	CM.changeNext_move(CLICK_CD_BREAKOUT)
	CM.last_special = world.time + CLICK_CD_BREAKOUT
	var/obj/item/weapon/restraints/handcuffs/HC = CM.handcuffed

	var/breakouttime = 1200 //A default in case you are somehow handcuffed with something that isn't an obj/item/weapon/restraints/handcuffs type
	var/displaytime = 2 //Minutes to display in the "this will take X minutes."

	var/hulklien = 0 //variable used to define if someone is a hulk or alien

	if(istype(HC)) //If you are handcuffed with actual handcuffs... Well what do I know, maybe someone will want to handcuff you with toilet paper in the future...
		breakouttime = HC.breakouttime
		displaytime = breakouttime / 600 //Minutes

	if(isalienadult(CM) || (HULK in usr.mutations))
		hulklien = 1
		breakouttime = 50
		displaytime = 5

	to_chat(CM, "\red You attempt to remove \the [HC]. (This will take around [displaytime] [hulklien ? "seconds" : "minute[displaytime==1 ? "" : "s"]"] and you need to stand still)")
	for(var/mob/O in viewers(CM))
		O.show_message( "\red <B>[usr] attempts to [hulklien ? "break" : "remove"] \the [HC]!</B>", 1)
	spawn(0)
		if(do_after(CM, breakouttime, target = src))
			if(!CM.handcuffed || CM.buckled)
				return // time leniency for lag which also might make this whole thing pointless but the server

			for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
				O.show_message("\red <B>[CM] manages to [hulklien ? "break" : "remove"] the handcuffs!</B>", 1)

			to_chat(CM, "\blue You successfully [hulklien ? "break" : "remove"] \the [CM.handcuffed].")

			if(hulklien)
				CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
				qdel(CM.handcuffed)
				CM.handcuffed = null
				if(CM.buckled && CM.buckled.buckle_requires_restraints)
					CM.buckled.unbuckle_mob()
				CM.update_inv_handcuffed()
				return

			CM.unEquip(CM.handcuffed)

/* resist_legcuffs allows a mob to break/remove their legcuffs after a delay
*/////
/mob/living/proc/resist_legcuffs(var/mob/living/carbon/CM)
	var/obj/item/weapon/restraints/legcuffs/HC = CM.legcuffed

	var/breakouttime = 1200 //A default in case you are somehow legcuffed with something that isn't an obj/item/weapon/legcuffs type
	var/displaytime = 2 //Minutes to display in the "this will take X minutes."

	var/hulklien = 0 //variable used to define if someone is a hulk or alien

	if(istype(HC)) //If you are legcuffed with actual legcuffs... Well what do I know, maybe someone will want to legcuff you with toilet paper in the future...
		breakouttime = HC.breakouttime
		displaytime = breakouttime / 600 //Minutes

	if(isalienadult(CM) || (HULK in usr.mutations))
		hulklien = 1
		breakouttime = 50
		displaytime = 5

	to_chat(CM, "\red You attempt to remove \the [HC]. (This will take around [displaytime] [hulklien ? "seconds" : "minute[displaytime==1 ? "" : "s"]"] and you need to stand still)")

	for(var/mob/O in viewers(CM))
		O.show_message( "\red <B>[usr] attempts to [hulklien ? "break" : "remove"] \the [HC]!</B>", 1)

	spawn(0)
		if(do_after(CM, breakouttime, target = src))
			if(!CM.legcuffed || CM.buckled)
				return // time leniency for lag which also might make this whole thing pointless but the server
			for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
				O.show_message("\red <B>[CM] manages to [hulklien ? "break" : "remove"] the legcuffs!</B>", 1)

			to_chat(CM, "\blue You successfully [hulklien ? "break" : "remove"] \the [CM.legcuffed].")

			if(!hulklien)
				CM.unEquip(CM.legcuffed)

			if(hulklien)
				CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
				qdel(CM.legcuffed)

			CM.legcuffed = null
			CM.update_inv_legcuffed()

/*//////////////////////
	END RESIST PROCS
*///////////////////////





/mob/living/carbon/proc/spin(spintime, speed)
	spawn()
		var/D = dir
		while(spintime >= speed)
			sleep(speed)
			switch(D)
				if(NORTH)
					D = EAST
				if(SOUTH)
					D = WEST
				if(EAST)
					D = SOUTH
				if(WEST)
					D = NORTH
			dir = D
			spintime -= speed
	return

/mob/living/proc/Exhaust()
	to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
	Weaken(5)

/mob/living/proc/get_visible_name()
	return name

/mob/living/update_gravity(has_gravity)
	if(!ticker)
		return
	float(!has_gravity)

/mob/living/proc/float(on)
	if(throwing)
		return
	var/fixed = 0
	if(anchored || (buckled && buckled.anchored))
		fixed = 1
	if(on && !floating && !fixed)
		animate(src, pixel_y = pixel_y + 2, time = 10, loop = -1)
		floating = 1
	else if(((!on || fixed) && floating))
		var/final_pixel_y = get_standard_pixel_y_offset(lying)
		animate(src, pixel_y = final_pixel_y, time = 10)
		floating = 0

/mob/living/proc/can_use_vents()
	return "You can't fit into that vent."

//called when the mob receives a bright flash
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash)
	if(check_eye_prot() < intensity && (override_blindness_check || !(sdisabilities & BLIND)))
		overlay_fullscreen("flash", type)
		addtimer(src, "clear_fullscreen", 25, FALSE, "flash", 25)
		return 1

/mob/living/proc/check_eye_prot()
	return 0

/mob/living/proc/check_ear_prot()

// The src mob is trying to strip an item from someone
// Override if a certain type of mob should be behave differently when stripping items (can't, for example)
/mob/living/stripPanelUnequip(obj/item/what, mob/who, where, var/silent = 0)
	if(what.flags & NODROP)
		to_chat(src, "<span class='warning'>You can't remove \the [what.name], it appears to be stuck!</span>")
		return
	if(!silent)
		who.visible_message("<span class='danger'>[src] tries to remove [who]'s [what.name].</span>", \
						"<span class='userdanger'>[src] tries to remove [who]'s [what.name].</span>")
	what.add_fingerprint(src)
	if(do_mob(src, who, what.strip_delay))
		if(what && what == who.get_item_by_slot(where) && Adjacent(who))
			who.unEquip(what)
			if(silent)
				put_in_hands(what)
			add_logs(who, src, "stripped", addition="of [what]")

// The src mob is trying to place an item on someone
// Override if a certain mob should be behave differently when placing items (can't, for example)
/mob/living/stripPanelEquip(obj/item/what, mob/who, where, var/silent = 0)
	what = src.get_active_hand()
	if(what && (what.flags & NODROP))
		to_chat(src, "<span class='warning'>You can't put \the [what.name] on [who], it's stuck to your hand!</span>")
		return
	if(what)
		if(!what.mob_can_equip(who, where, 1))
			to_chat(src, "<span class='warning'>\The [what.name] doesn't fit in that place!</span>")
			return
		if(!silent)
			visible_message("<span class='notice'>[src] tries to put [what] on [who].</span>")
		if(do_mob(src, who, what.put_on_delay))
			if(what && Adjacent(who))
				unEquip(what)
				who.equip_to_slot_if_possible(what, where, 0, 1)
				add_logs(who, src, "equipped", what)


/mob/living/singularity_act()
	var/gain = 20
	investigate_log("([key_name(src)]) has been consumed by the singularity.","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/singularity_pull(S)
	step_towards(src,S)

/mob/living/narsie_act()
	if(client)
		makeNewConstruct(/mob/living/simple_animal/construct/harvester, src, null, 1)
	spawn_dust()
	gib()
	return

/atom/movable/proc/do_attack_animation(atom/A)
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/direction = get_dir(src, A)
	switch(direction)
		if(NORTH)
			pixel_y_diff = 8
		if(SOUTH)
			pixel_y_diff = -8
		if(EAST)
			pixel_x_diff = 8
		if(WEST)
			pixel_x_diff = -8
		if(NORTHEAST)
			pixel_x_diff = 8
			pixel_y_diff = 8
		if(NORTHWEST)
			pixel_x_diff = -8
			pixel_y_diff = 8
		if(SOUTHEAST)
			pixel_x_diff = 8
			pixel_y_diff = -8
		if(SOUTHWEST)
			pixel_x_diff = -8
			pixel_y_diff = -8
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 2)

/mob/living/do_attack_animation(atom/A)
	..()
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.


/atom/movable/proc/receive_damage(atom/A)
	var/pixel_x_diff = rand(-3,3)
	var/pixel_y_diff = rand(-3,3)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 2)

/mob/living/receive_damage(atom/A)
	..()
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.

/mob/living/proc/do_jitter_animation(jitteriness)
	var/amplitude = min(4, (jitteriness/100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude/3, amplitude/3)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 2, loop = 6)
	animate(pixel_x = initial(pixel_x) , pixel_y = initial(pixel_y) , time = 2)
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.


/mob/living/proc/get_temperature(datum/gas_mixture/environment)
	var/loc_temp = T0C
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		loc_temp =  M.return_temperature()

	else if(istype(loc, /obj/spacepod))
		var/obj/spacepod/S = loc
		loc_temp = S.return_temperature()

	else if(istype(loc, /obj/structure/transit_tube_pod))
		loc_temp = environment.temperature

	else if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.temperature

	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/C = loc

		if(C.air_contents.total_moles() < 10)
			loc_temp = environment.temperature
		else
			loc_temp = C.air_contents.temperature

	else
		loc_temp = environment.temperature

	return loc_temp

/mob/living/proc/get_standard_pixel_x_offset(lying = 0)
	return initial(pixel_x)

/mob/living/proc/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)

/mob/living/proc/spawn_dust()
	new /obj/effect/decal/cleanable/ash(loc)

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return 0

/mob/living/proc/harvest(mob/living/user)
	if(qdeleted(src))
		return
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1, i <= butcher_results[path], i++)
				new path(loc)
			butcher_results.Remove(path) //In case you want to have things like simple_animals drop their butcher results on gib, so it won't double up below.
		visible_message("<span class='notice'>[user] butchers [src].</span>")
		gib()
