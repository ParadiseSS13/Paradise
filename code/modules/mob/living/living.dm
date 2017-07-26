
/mob/living/Destroy()
	if(ranged_ability)
		ranged_ability.remove_ranged_ability(src)
	return ..()

/mob/living/ghostize(can_reenter_corpse = 1)
	var/prev_client = client
	. = ..()
	if(.)
		if(ranged_ability && prev_client)
			ranged_ability.remove_mousepointer(prev_client)

/mob/living/proc/OpenCraftingMenu()
	return

//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A, yes)
	if(..()) //we are thrown onto something
		return
	if(buckled || !yes || now_pushing)
		return
	if(ismob(A))
		if(MobBump(A))
			return
	if(isobj(A))
		if(ObjBump(A))
			return
	if(istype(A, /atom/movable))
		if(PushAM(A))
			return

//Called when we bump into a mob
/mob/living/proc/MobBump(mob/M)
	//Even if we don't push/swap places, we "touched" them, so spread fire
	spreadFire(M)

	if(now_pushing)
		return 1

	//Should stop you pushing a restrained person out of the way
	if(isliving(M))
		var/mob/living/L = M
		if(L.pulledby && L.pulledby != src && L.restrained())
			if(!(world.time % 5))
				to_chat(src, "<span class='warning'>[L] is restrained, you cannot push past.</span>")
			return 1

		if(L.pulling)
			if(ismob(L.pulling))
				var/mob/P = L.pulling
				if(P.restrained())
					if(!(world.time % 5))
						to_chat(src, "<span class='warning'>[L] is restrained, you cannot push past.</span>")
					return 1

	if(moving_diagonally) //no mob swap during diagonal moves.
		return 1

	if(!M.buckled && !M.has_buckled_mobs())
		var/mob_swap
		//the puller can always swap with it's victim if on grab intent
		if(M.pulledby == src && a_intent == INTENT_GRAB)
			mob_swap = 1
		//restrained people act if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
		else if((M.restrained() || M.a_intent == INTENT_HELP) && (restrained() || a_intent == INTENT_HELP))
			mob_swap = 1
		if(mob_swap)
			//switch our position with M
			if(loc && !loc.Adjacent(M.loc))
				return 1
			now_pushing = 1
			var/oldloc = loc
			var/oldMloc = M.loc

			var/M_passmob = (M.pass_flags & PASSMOB) // we give PASSMOB to both mobs to avoid bumping other mobs during swap.
			var/src_passmob = (pass_flags & PASSMOB)
			M.pass_flags |= PASSMOB
			pass_flags |= PASSMOB

			M.Move(oldloc)
			Move(oldMloc)

			if(!src_passmob)
				pass_flags &= ~PASSMOB
			if(!M_passmob)
				M.pass_flags &= ~PASSMOB

			now_pushing = 0
			return 1

	// okay, so we didn't switch. but should we push?
	// not if he's not CANPUSH of course
	if(!(M.status_flags & CANPUSH))
		return 1
	//anti-riot equipment is also anti-push
	if(M.r_hand && (prob(M.r_hand.block_chance * 2)) && !istype(M.r_hand, /obj/item/clothing))
		return 1
	if(M.l_hand && (prob(M.l_hand.block_chance * 2)) && !istype(M.l_hand, /obj/item/clothing))
		return 1

//Called when we bump into an obj
/mob/living/proc/ObjBump(obj/O)
	return

//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM)
	if(now_pushing)
		return 1
	if(moving_diagonally) // no pushing during diagonal moves
		return 1
	if(!client && (mob_size < MOB_SIZE_SMALL))
		return
	if(!AM.anchored)
		now_pushing = 1
		var/t = get_dir(src, AM)
		if(istype(AM, /obj/structure/window/full))
			for(var/obj/structure/window/win in get_step(AM, t))
				now_pushing = 0
				return
		if(pulling == AM)
			stop_pulling()
		var/current_dir
		if(isliving(AM))
			current_dir = AM.dir
		step(AM, t)
		if(current_dir)
			AM.setDir(current_dir)
		now_pushing = 0


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
	if(!is_level_reachable(T.z))
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
		start_pulling(AM)
	return

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(incapacitated(ignore_lying = TRUE))
		return FALSE
	if(status_flags & FAKEDEATH)
		return FALSE
	if(!..())
		return FALSE
	var/obj/item/hand_item = get_active_hand()
	if(istype(hand_item, /obj/item/weapon/gun) && A != hand_item)
		if(a_intent == INTENT_HELP || !ismob(A))
			visible_message("<b>[src]</b> points to [A] with [hand_item]")
			return TRUE
		A.visible_message("<span class='danger'>[src] points [hand_item] at [A]!</span>",
											"<span class='userdanger'>[src] points [hand_item] at you!</span>")
		A << 'sound/weapons/TargetOn.ogg'
		return TRUE
	visible_message("<b>[src]</b> points to [A]")
	return TRUE

/mob/living/verb/succumb()
	set hidden = 1
	if(InCritical())
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
	return (health < 0 && health > -95.0 && stat == UNCONSCIOUS)

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
//		to_chat(world, "[src] ~ [bodytemperature] ~ [temperature]")
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

		L += contents
		for(var/obj/item/weapon/storage/S in contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/suit/storage/S in contents)//Check for labcoats and jackets
			L += get_contents(S)
		for(var/obj/item/clothing/accessory/storage/S in contents)//Check for holsters
			L += get_contents(S)
		for(var/obj/item/weapon/implant/storage/I in contents) //Check for storage implants.
			L += I.get_contents()
		for(var/obj/item/weapon/gift/G in contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in contents) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		for(var/obj/item/weapon/folder/F in contents)
			L += F.contents //Folders can't store any storage items.

		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/mob/living/proc/can_inject()
	return 1

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter:zone_sel.selecting
	if((t in list( "eyes", "mouth" )))
		t = "head"
	var/obj/item/organ/external/def_zone = ran_zone(t)
	return def_zone

// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	updatehealth()

/mob/living/proc/has_organic_damage()
	return (maxHealth - health)


/mob/living/proc/restore_all_organs()
	return

/mob/living/proc/revive()
	rejuvenate()
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if(C.handcuffed && !initial(C.handcuffed))
			C.unEquip(C.handcuffed)
		C.handcuffed = initial(C.handcuffed)
		C.update_handcuffed()

		if(C.legcuffed && !initial(C.legcuffed))
			C.unEquip(C.legcuffed)
		C.legcuffed = initial(C.legcuffed)
		C.update_inv_legcuffed()

		if(C.reagents)
			for(var/datum/reagent/R in C.reagents.reagent_list)
				C.reagents.clear_reagents()
			C.reagents.addiction_list.Cut()

/mob/living/proc/rejuvenate()
	var/mob/living/carbon/human/human_mob = null //Get this declared for use later.

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	setStaminaLoss(0)
	SetSleeping(0)
	SetParalysis(0, 1, 1)
	SetStunned(0, 1, 1)
	SetWeakened(0, 1, 1)
	SetSlowed(0)
	SetLoseBreath(0)
	SetDizzy(0)
	SetJitter(0)
	SetConfused(0)
	SetDrowsy(0)
	radiation = 0
	SetDruggy(0)
	SetHallucinate(0)
	blinded = 0
	nutrition = NUTRITION_LEVEL_FED + 50
	bodytemperature = 310
	CureBlind()
	CureNearsighted()
	CureMute()
	CureDeaf()
	CureTourettes()
	CureEpilepsy()
	CureCoughing()
	CureNervous()
	SetEyeBlind(0)
	SetEyeBlurry(0)
	SetEarDamage(0)
	SetEarDeaf(0)
	heal_overall_damage(1000, 1000)
	ExtinguishMob()
	fire_stacks = 0
	on_fire = 0
	suiciding = 0
	if(buckled) //Unbuckle the mob and clear the alerts.
		buckled.buckled_mob = null
		buckled = null
		anchored = initial(anchored)
		update_canmove()
		clear_alert("buckled")
		post_buckle_mob(src)

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.handcuffed = initial(C.handcuffed)

		for(var/thing in C.viruses)
			var/datum/disease/D = thing
			D.cure(0)

		// restore all of the human's blood and reset their shock stage
		if(ishuman(src))
			human_mob = src
			human_mob.set_heartattack(FALSE)
			human_mob.restore_blood()
			human_mob.shock_stage = 0
			human_mob.decaylevel = 0
			human_mob.remove_all_embedded_objects()

	restore_all_organs()
	surgeries.Cut() //End all surgeries.
	if(stat == DEAD)
		dead_mob_list -= src
		living_mob_list += src
		timeofdeath = 0

	stat = CONSCIOUS
	update_fire()
	regenerate_icons()
	restore_blood()
	if(human_mob)
		human_mob.update_eyes()
		human_mob.update_dna()
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
	if(buckled && buckled.loc != newloc) //not updating position
		if(!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	var/atom/movable/pullee = pulling
	if(pullee && get_dist(src, pullee) > 1)
		stop_pulling()
	if(pullee && !isturf(pullee.loc) && pullee.loc != loc)
		log_game("DEBUG: [src]'s pull on [pullee] was broken despite [pullee] being in [pullee.loc]. Pull stopped manually.")
		stop_pulling()
	if(restrained())
		stop_pulling()

	var/turf/T = loc
	. = ..()
	if(.)
		handle_footstep(loc)
		step_count++

		if(pulling && pulling == pullee) // we were pulling a thing and didn't lose it during our move.
			if(pulling.anchored)
				stop_pulling()
				return

			var/pull_dir = get_dir(src, pulling)
			if(get_dist(src, pulling) > 1 || ((pull_dir - 1) & pull_dir)) // puller and pullee more than one tile away or in diagonal position
				if(isliving(pulling))
					var/mob/living/M = pulling
					if(M.lying && !M.buckled && (prob(M.getBruteLoss() * 200 / M.maxHealth)))
						M.makeTrail(T)
				pulling.Move(T, get_dir(pulling, T)) // the pullee tries to reach our previous position
				if(pulling && get_dist(src, pulling) > 1) // the pullee couldn't keep up
					stop_pulling()

	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1) //seperated from our puller and not in the middle of a diagonal move
		pulledby.stop_pulling()

	if(s_active && !(s_active in contents) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents ) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)


/mob/living/proc/handle_footstep(turf/T)
	if(istype(T))
		return 1
	return 0

/mob/living/proc/makeTrail(turf/T)
	if(!has_gravity(src))
		return
	var/blood_exists = 0

	for(var/obj/effect/decal/cleanable/trail_holder/C in loc) //checks for blood splatter already on the floor
		blood_exists = 1
	if(isturf(loc))
		var/trail_type = getTrail()
		if(trail_type)
			var/brute_ratio = round(getBruteLoss()/maxHealth, 0.1)
			if(blood_volume && blood_volume > max(BLOOD_VOLUME_NORMAL*(1 - brute_ratio * 0.25), 0))//don't leave trail if blood volume below a threshold
				blood_volume = max(blood_volume - max(1, brute_ratio * 2), 0) 					//that depends on our brute damage.
				var/newdir = get_dir(T, loc)
				if(newdir != src.dir)
					newdir = newdir | dir
					if(newdir == 3) //N + S
						newdir = NORTH
					else if(newdir == 12) //E + W
						newdir = EAST
				if((newdir in cardinal) && (prob(50)))
					newdir = turn(get_dir(T, loc), 180)
				if(!blood_exists)
					new /obj/effect/decal/cleanable/trail_holder(loc)
				for(var/obj/effect/decal/cleanable/trail_holder/TH in loc)
					if((!(newdir in TH.existing_dirs) || trail_type == "trails_1" || trail_type == "trails_2") && TH.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
						TH.existing_dirs += newdir
						TH.overlays.Add(image('icons/effects/blood.dmi', trail_type, dir = newdir))
						TH.transfer_mob_blood_dna(src)
						if(ishuman(src))
							var/mob/living/carbon/human/H = src
							if(H.species.blood_color)
								TH.color = H.species.blood_color
						else
							TH.color = "#A10808"

/mob/living/carbon/human/makeTrail(turf/T)

	if((NO_BLOOD in species.species_traits) || species.exotic_blood || !bleed_rate || bleedsuppress)
		return
	..()

/mob/living/proc/getTrail()
	if(getBruteLoss() < 300)
		return pick("ltrails_1", "ltrails_2")
	else
		return pick("trails_1", "trails_2")


/*//////////////////////
	START RESIST PROCS
*///////////////////////

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(src) || next_move > world.time || stat || weakened || stunned || paralysis)
		return
	changeNext_move(CLICK_CD_RESIST)

	if(!restrained())
		if(resist_grab())
			return

	//unbuckling yourself
	if(buckled && last_special <= world.time)
		resist_buckle()

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(isobj(loc))
		var/obj/C = loc
		C.container_resist(src)

	else if(canmove)
		if(on_fire)
			resist_fire() //stop, drop, and roll
		else if(last_special <= world.time)
			resist_restraints() //trying to remove cuffs.

/*////////////////////
	RESIST SUBPROCS
*/////////////////////
/mob/living/proc/resist_grab()
	var/resisting = 0
	for(var/obj/O in requests)
		qdel(O)
		resisting++
	for(var/X in grabbed_by)
		var/obj/item/weapon/grab/G = X
		resisting++
		switch(G.state)
			if(GRAB_PASSIVE)
				qdel(G)

			if(GRAB_AGGRESSIVE)
				if(prob(60))
					visible_message("<span class='danger'>[src] has broken free of [G.assailant]'s grip!</span>")
					qdel(G)

			if(GRAB_NECK)
				if(prob(5))
					visible_message("<span class='danger'>[src] has broken free of [G.assailant]'s headlock!</span>")
					qdel(G)

	if(resisting)
		visible_message("<span class='danger'>[src] resists!</span>")
		return 1

/mob/living/proc/resist_buckle()
	spawn(0)
		resist_muzzle()
	buckled.user_unbuckle_mob(src,src)

/mob/living/proc/resist_muzzle()
	return

/mob/living/proc/resist_fire()
	return

/mob/living/proc/resist_restraints()
	spawn(0)
		resist_muzzle()
	return

/*//////////////////////
	END RESIST PROCS
*///////////////////////

/mob/living/proc/Exhaust()
	to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
	Weaken(5)

/mob/living/proc/get_visible_name()
	return name

/mob/living/update_gravity(has_gravity)
	if(!ticker)
		return
	if(has_gravity)
		clear_alert("weightless")
	else
		throw_alert("weightless", /obj/screen/alert/weightless)
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
	if(check_eye_prot() < intensity && (override_blindness_check || !(disabilities & BLIND)))
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
			add_logs(src, who, "stripped", addition="of [what]", print_attack_log = isLivingSSD(who))

// The src mob is trying to place an item on someone
// Override if a certain mob should be behave differently when placing items (can't, for example)
/mob/living/stripPanelEquip(obj/item/what, mob/who, where, var/silent = 0)
	what = get_active_hand()
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
				add_logs(src, who, "equipped", what, print_attack_log = isLivingSSD(who))


/mob/living/singularity_act()
	var/gain = 20
	investigate_log("([key_name(src)]) has been consumed by the singularity.","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/singularity_pull(S)
	step_towards(src,S)

/mob/living/narsie_act()
	if(client)
		makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, src, null, 1)
	spawn_dust()
	gib()
	return

/atom/movable/proc/do_attack_animation(atom/A, end_pixel_y)
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/final_pixel_y = initial(pixel_y)
	if(end_pixel_y)
		final_pixel_y = end_pixel_y

	var/direction = get_dir(src, A)
	if(direction & NORTH)
		pixel_y_diff = 8
	else if(direction & SOUTH)
		pixel_y_diff = -8

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = final_pixel_y, time = 2)


/mob/living/do_attack_animation(atom/A)
	var/final_pixel_y = get_standard_pixel_y_offset(lying)
	..(A, final_pixel_y)
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.

	// What icon do we use for the attack?
	var/image/I
	if(hand && l_hand) // Attacked with item in left hand.
		I = image(l_hand.icon, A, l_hand.icon_state, A.layer + 1)
	else if(!hand && r_hand) // Attacked with item in right hand.
		I = image(r_hand.icon, A, r_hand.icon_state, A.layer + 1)
	else // Attacked with a fist?
		return

	// Who can see the attack?
	var/list/viewing = list()
	for(var/mob/M in viewers(A))
		if(M.client && M.client.prefs.show_ghostitem_attack)
			viewing |= M.client
	flick_overlay(I, viewing, 5) // 5 ticks/half a second

	// Scale the icon.
	I.transform *= 0.75
	// The icon should not rotate.
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	// Set the direction of the icon animation.
	var/direction = get_dir(src, A)
	if(direction & NORTH)
		I.pixel_y = -16
	else if(direction & SOUTH)
		I.pixel_y = 16

	if(direction & EAST)
		I.pixel_x = -16
	else if(direction & WEST)
		I.pixel_x = 16

	if(!direction) // Attacked self?!
		I.pixel_z = 16

	// And animate the attack!
	animate(I, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)

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

/mob/living/proc/attempt_harvest(obj/item/I, mob/user)
	if(stat == DEAD && !isnull(butcher_results)) //can we butcher it?
		if(istype(I, /obj/item/weapon/kitchen/knife))
			to_chat(user, "<span class='notice'>You begin to butcher [src]...</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
			if(do_mob(user, src, 80))
				harvest(user)
			return 1

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

/mob/living/movement_delay(ignorewalk = 0)
	. = ..()
	if(isturf(loc))
		var/turf/T = loc
		. += T.slowdown
	if(slowed)
		. += 10
	if(ignorewalk)
		. += config.run_speed
	else
		switch(m_intent)
			if(MOVE_INTENT_RUN)
				if(drowsyness > 0)
					. += 6
				. += config.run_speed
			if(MOVE_INTENT_WALK)
				. += config.walk_speed


/mob/living/proc/can_use_guns(var/obj/item/weapon/gun/G)
	if(G.trigger_guard != TRIGGER_GUARD_ALLOW_ALL && !IsAdvancedToolUser() && !issmall(src))
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0
	return 1

/mob/living/proc/get_taste_sensitivity()
	return 1

/mob/living/proc/taste_reagents(datum/reagents/tastes)
	if(!get_taste_sensitivity())//this also works for IPCs and stuff that returns 0 here
		return

	var/do_not_taste_at_all = 1//so we don't spam with recent tastes

	var/taste_sum = 0
	var/list/taste_list = list()//associative list so we can stack stuff that tastes the same
	var/list/final_taste_list = list()//final list of taste strings

	for(var/datum/reagent/R in tastes.reagent_list)
		taste_sum += R.volume * R.taste_strength
		if(!R.taste_message)//set to null; no taste, like water
			continue
		taste_list[R.taste_message] += R.volume * R.taste_strength

	for(var/R in taste_list)
		if(recent_tastes[R] && (world.time - recent_tastes[R] < 12 SECONDS))
			continue

		do_not_taste_at_all = 0//something was fresh enough to taste; could still be bland enough to be unrecognizable

		if(taste_list[R] / taste_sum >= 0.15 / get_taste_sensitivity())//we return earlier if the proc returns a 0; won't break the universe
			final_taste_list += R
			recent_tastes[R] = world.time

	if(do_not_taste_at_all)
		return //no message spam

	if(final_taste_list.len == 0)//too many reagents - none meet their thresholds
		to_chat(src, "<span class='notice'>You you can't really make out what you're tasting...</span>")
		return

	to_chat(src, "<span class='notice'>You can taste [english_list(final_taste_list)].</span>")
