
/mob/living/Life()
	..()
	if (monkeyizing)	return
	if(!loc)			return	// Fixing a null error that occurs when the mob isn't found in the world -- TLE
	if(mind)
		if(mind in ticker.mode.implanted)
			if(implanting) return
			//world << "[src.name]"
			var/datum/mind/head = ticker.mode.implanted[mind]
			//var/list/removal
			if(!(locate(/obj/item/weapon/implant/traitor) in src.contents))
				//world << "doesn't have an implant"
				ticker.mode.remove_traitor_mind(mind, head)
				/*
				if((head in ticker.mode.implanters))
					ticker.mode.implanter[head] -= src.mind
				ticker.mode.implanted -= src.mind
				if(src.mind in ticker.mode.traitors)
					ticker.mode.traitors -= src.mind
					special_role = null
					current << "\red <FONT size = 3><B>The fog clouding your mind clears. You remember nothing from the moment you were implanted until now..(You don't remember who enslaved you)</B></FONT>"
				*/
/mob/living/verb/succumb()
	set hidden = 1
	if (InCritical())
		src.attack_log += "[src] has ["succumbed to death"] with [round(health, 0.1)] points of health!"
		src.adjustOxyLoss(src.health - config.health_threshold_dead)
		updatehealth()
		src << "<span class='notice'>You have given up life and succumbed to death.</span>"
		death()

/mob/living/proc/InCritical()
	return (src.health < 0 && src.health > -95.0 && stat == UNCONSCIOUS)

/mob/living/ex_act(severity)
	..()
	if(client && !eye_blind)
		flick("flash", src.flash)

/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
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
	else if(istype(src, /mob/living/carbon/monkey))
		if (RESIST_HEAT in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
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
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn
// I touched them without asking... I'm soooo edgy ~Erro (added nodamage checks)

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

/mob/living/proc/getHalLoss()
	return halloss

/mob/living/proc/adjustHalLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = min(max(halloss + amount, 0),(maxHealth*2))

/mob/living/proc/setHalLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = amount

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
	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD

/mob/living/proc/rejuvenate()

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	setStaminaLoss(0)
	setHalLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
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
	fire_stacks = 0
	on_fire = 0
	suiciding = 0
	buckled = initial(src.buckled)

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.handcuffed = initial(C.handcuffed)
		C.heart_attack = 0

		// restore all of the human's blood and reset their shock stage
		if(ishuman(src))
			var/mob/living/carbon/human/human_mob = src
			human_mob.restore_blood()
			human_mob.shock_stage = 0

	restore_all_organs()
	if(stat == 2)
		dead_mob_list -= src
		living_mob_list += src
		tod = null
		timeofdeath = 0

	stat = CONSCIOUS
	update_fire()
	regenerate_icons()
	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD
	return

/mob/living/proc/UpdateDamageIcon()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			usr << "[src]'s Metainfo:<br>[client.prefs.metadata]"
		else
			usr << "[src] does not have any stored infomation!"
	else
		usr << "OOC Metadata is not supported by this server!"

	return

/mob/living/Move(a, b, flag)
	if (buckled)
		return

	if (restrained())
		stop_pulling()


	var/t7 = 1
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
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
								del(G)
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


						step(pulling, get_dir(pulling.loc, T))
						M.start_pulling(t)
				else
					if (pulling)
						if (istype(pulling, /obj/structure/window/full))
							for(var/obj/structure/window/win in get_step(pulling,get_dir(pulling.loc, T)))
								stop_pulling()
					if (pulling)
						step(pulling, get_dir(pulling.loc, T))
	else
		stop_pulling()
		. = ..()

	if (s_active && !( s_active in contents ) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents ) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)


/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.changeNext_move(CLICK_CD_RESIST)

	var/mob/living/L = usr

	//Getting out of someone's inventory.
	if(istype(src.loc,/obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.loc //Get our item holder.
		var/mob/M = H.loc                      //Get our mob holder (if any).

		if(istype(M))
			M.unEquip(H)
			M << "[H] wriggles out of your grip!"
			src << "You wriggle out of [M]'s grip!"
		else if(istype(H.loc,/obj/item))
			src << "You struggle free of [H.loc]."
			H.loc = get_turf(H)

		if(istype(M))
			for(var/atom/A in M.contents)
				if(istype(A,/mob/living/simple_animal/borer) || istype(A,/obj/item/weapon/holder))
					return

		M.status_flags &= ~PASSEMOTES
		return

	//Resisting control by an alien mind.
	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		var/mob/living/captive_brain/H = src

		H << "\red <B>You begin doggedly resisting the parasite's control (this will take approximately sixty seconds).</B>"
		B.host << "\red <B>You feel the captive mind of [src] begin to resist your control.</B>"

		spawn(rand(350,450)+B.host.brainloss)

			if(!B || !B.controlling)
				return

			B.host.adjustBrainLoss(rand(5,10))
			H << "\red <B>With an immense exertion of will, you regain control of your body!</B>"
			B.host << "\red <B>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</b>"

			B.detatch()

			verbs -= /mob/living/carbon/proc/release_control
			verbs -= /mob/living/carbon/proc/punish_host
			verbs -= /mob/living/carbon/proc/spawn_larvae

			return

	//resisting grabs (as if it helps anyone...)
	if ((!( L.stat ) && !( L.restrained() )))
		var/resisting = 0
		for(var/obj/O in L.requests)
			L.requests.Remove(O)
			del(O)
			resisting++
		for(var/obj/item/weapon/grab/G in usr.grabbed_by)
			resisting++
			if (G.state == 1)
				del(G)
			else
				if (G.state == 2)
					if (prob(25))
						for(var/mob/O in viewers(L, null))
							O.show_message(text("\red [] has broken free of []'s grip!", L, G.assailant), 1)
						del(G)
				else
					if (G.state == 3)
						if (prob(5))
							for(var/mob/O in viewers(usr, null))
								O.show_message(text("\red [] has broken free of []'s headlock!", L, G.assailant), 1)
							del(G)
		if(resisting)
			for(var/mob/O in viewers(usr, null))
				O.show_message(text("\red <B>[] resists!</B>", L), 1)

	//unbuckling yourself
	if(L.buckled && (L.last_special <= world.time) )
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if( C.handcuffed )
				C.changeNext_move(CLICK_CD_BREAKOUT)
				C.last_special = world.time + CLICK_CD_BREAKOUT
				C << "\red You attempt to unbuckle yourself. (This will take around 2 minutes and you need to stand still)"
				for(var/mob/O in viewers(L))
					O.show_message("\red <B>[usr] attempts to unbuckle themself!</B>", 1)
				spawn(0)
					if(do_after(usr, 1200))
						if(!C.buckled)
							return
						for(var/mob/O in viewers(C))
							O.show_message("\red <B>[usr] manages to unbuckle themself!</B>", 1)
						C << "\blue You successfully unbuckle yourself."
						C.buckled.manual_unbuckle(C)
		else
			L.buckled.manual_unbuckle(L)

	//Breaking out of a locker?
	else if( src.loc && (istype(src.loc, /obj/structure/closet)) )
		var/breakout_time = 2 //2 minutes by default

		var/obj/structure/closet/C = L.loc
		if(C.opened)
			return //Door's open... wait, why are you in it's contents then?
		if(istype(L.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/SC = L.loc
			if(!SC.locked && !SC.welded)
				return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'
		else
			if(!C.welded)
				return //closed but not welded...
		//	else Meh, lets just keep it at 2 minutes for now
		//		breakout_time++ //Harder to get out of welded lockers than locked lockers

		//okay, so the closet is either welded or locked... resist!!!
		L.changeNext_move(CLICK_CD_BREAKOUT)
		L.last_special = world.time + CLICK_CD_BREAKOUT
		L << "\red You lean on the back of \the [C] and start pushing the door open. (this will take about [breakout_time] minutes)"
		for(var/mob/O in viewers(usr.loc))
			O.show_message("\red <B>The [L.loc] begins to shake violently!</B>", 1)


		spawn(0)
			if(do_after(usr,(breakout_time*60*10))) //minutes * 60seconds * 10deciseconds
				if(!C || !L || L.stat != CONSCIOUS || L.loc != C || C.opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
					return

				//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
				if(istype(L.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					if(!SC.locked && !SC.welded)
						return
				else
					if(!C.welded)
						return

				//Well then break it!
				if(istype(usr.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					SC.desc = "It appears to be broken."
					SC.icon_state = SC.icon_off
					flick(SC.icon_broken, SC)
					sleep(10)
					flick(SC.icon_broken, SC)
					sleep(10)
					SC.broken = 1
					SC.locked = 0
					SC.update_icon()
					usr << "\red You successfully break out!"
					for(var/mob/O in viewers(L.loc))
						O.show_message("\red <B>\the [usr] successfully broke out of \the [SC]!</B>", 1)
					if(istype(SC.loc, /obj/structure/bigDelivery)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
						var/obj/structure/bigDelivery/BD = SC.loc
						BD.attack_hand(usr)
					SC.open()
				else
					C.welded = 0
					C.update_icon()
					usr << "\red You successfully break out!"
					for(var/mob/O in viewers(L.loc))
						O.show_message("\red <B>\the [usr] successfully broke out of \the [C]!</B>", 1)
					if(istype(C.loc, /obj/structure/bigDelivery)) //nullspace ect.. read the comment above
						var/obj/structure/bigDelivery/BD = C.loc
						BD.attack_hand(usr)
					C.open()

	//breaking out of handcuffs
	else if(iscarbon(L))
		var/mob/living/carbon/CM = L

		if(CM.on_fire && CM.canmove)
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

		if(CM.handcuffed && CM.canmove && (CM.last_special <= world.time))
			CM.changeNext_move(CLICK_CD_BREAKOUT)
			CM.last_special = world.time + CLICK_CD_BREAKOUT
			if(isalienadult(CM) || (HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				usr << "\red You attempt to break your handcuffs. (This will take around 5 seconds and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message(text("\red <B>[] is trying to break the handcuffs!</B>", CM), 1)
				spawn(0)
					if(do_after(CM, 50))
						if(!CM.handcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("\red <B>[] manages to break the handcuffs!</B>", CM), 1)
						CM << "\red You successfully break your handcuffs."
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						del(CM.handcuffed)
						CM.handcuffed = null
						CM.update_inv_handcuffed()
			else
				var/obj/item/weapon/restraints/handcuffs/HC = CM.handcuffed
				var/breakouttime = 1200 //A default in case you are somehow handcuffed with something that isn't an obj/item/weapon/restraints/handcuffs type
				var/displaytime = 2 //Minutes to display in the "this will take X minutes."
				if(istype(HC)) //If you are handcuffed with actual handcuffs... Well what do I know, maybe someone will want to handcuff you with toilet paper in the future...
					breakouttime = HC.breakouttime
					displaytime = breakouttime / 600 //Minutes
				CM << "\red You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message( "\red <B>[usr] attempts to remove \the [HC]!</B>", 1)
				spawn(0)
					if(do_after(CM, breakouttime))
						if(!CM.handcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server
						for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
							O.show_message("\red <B>[CM] manages to remove the handcuffs!</B>", 1)
						CM << "\blue You successfully remove \the [CM.handcuffed]."
						CM.unEquip(CM.handcuffed)

		else if(CM.legcuffed && CM.canmove && (CM.last_special <= world.time))
			CM.changeNext_move(CLICK_CD_BREAKOUT)
			CM.last_special = world.time + CLICK_CD_BREAKOUT
			if(isalienadult(CM) || (HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				usr << "\red You attempt to break your legcuffs. (This will take around 5 seconds and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message(text("\red <B>[] is trying to break the legcuffs!</B>", CM), 1)
				spawn(0)
					if(do_after(CM, 50))
						if(!CM.legcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("\red <B>[] manages to break the legcuffs!</B>", CM), 1)
						CM << "\red You successfully break your legcuffs."
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						del(CM.legcuffed)
						CM.legcuffed = null
						CM.update_inv_legcuffed()
			else
				var/obj/item/weapon/restraints/legcuffs/HC = CM.legcuffed
				var/breakouttime = 1200 //A default in case you are somehow legcuffed with something that isn't an obj/item/weapon/legcuffs type
				var/displaytime = 2 //Minutes to display in the "this will take X minutes."
				if(istype(HC)) //If you are legcuffed with actual legcuffs... Well what do I know, maybe someone will want to legcuff you with toilet paper in the future...
					breakouttime = HC.breakouttime
					displaytime = breakouttime / 600 //Minutes
				CM << "\red You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message( "\red <B>[usr] attempts to remove \the [HC]!</B>", 1)
				spawn(0)
					if(do_after(CM, breakouttime))
						if(!CM.legcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server
						for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
							O.show_message("\red <B>[CM] manages to remove the legcuffs!</B>", 1)
						CM << "\blue You successfully remove \the [CM.legcuffed]."
						CM.unEquip(CM.legcuffed)
						CM.legcuffed = null
						CM.update_inv_legcuffed()

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

/mob/living/proc/CheckStamina()
	if(staminaloss)
		var/total_health = (health - staminaloss)
		if(total_health <= config.health_threshold_softcrit && !stat)
			Exhaust()
			setStaminaLoss(health - 2)
			return
		setStaminaLoss(max((staminaloss - 2), 0))

/mob/living/proc/Exhaust()
	src << "<span class='notice'>You're too exhausted to keep going...</span>"
	Weaken(5)

/mob/living/update_gravity(has_gravity)
	if(!ticker)
		return
	float(!has_gravity)

/mob/living/proc/float(on)
	if(on && !floating)
		animate(src, pixel_y = 2, time = 10, loop = -1)
		floating = 1
	else if(!on && floating)
		animate(src, pixel_y = initial(pixel_y), time = 10)
		floating = 0

/mob/living/proc/can_use_vents()
	return "You can't fit into that vent."



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
