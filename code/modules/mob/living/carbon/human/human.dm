#define STRIP_DELAY      40  //time taken (in deciseconds) to strip somebody
/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"
	var/list/hud_list[10]
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/embedded_flag	  //To check if we've need to roll for damage on movement while an item is imbedded in us.

/mob/living/carbon/human/New(var/new_loc, var/new_species = null, var/delay_ready_dna=0)
	if(!species)
		if(new_species)
			set_species(new_species,1)
		else
			set_species()

	if(species)
		name = species.get_random_name(gender)

	var/datum/reagents/R = new/datum/reagents(330)
	reagents = R
	R.my_atom = src

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudunknown")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD_OOC]  = image('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[NATIONS_HUD]	  = image('icons/mob/hud.dmi', src, "hudblank")

	..()

	if(dna)
		dna.real_name = real_name

	prev_gender = gender // Debug for plural genders
	make_blood()

	var/mob/M = src
	faction |= "\ref[M]"

	// Set up DNA.
	if(!delay_ready_dna)
		dna.ready_dna(src)
	UpdateAppearance()

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/skrell/New(var/new_loc)
	h_style = "Skrell Male Tentacles"
	..(new_loc, "Skrell")

/mob/living/carbon/human/tajaran/New(var/new_loc)
	h_style = "Tajaran Ears"
	..(new_loc, "Tajaran")

/mob/living/carbon/human/unathi/New(var/new_loc)
	h_style = "Unathi Horns"
	..(new_loc, "Unathi")

/mob/living/carbon/human/vox/New(var/new_loc)
	h_style = "Short Vox Quills"
	..(new_loc, "Vox")

/mob/living/carbon/human/voxarmalis/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Vox Armalis")

/mob/living/carbon/human/skellington/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Skellington")

/mob/living/carbon/human/kidan/New(var/new_loc)
	..(new_loc, "Kidan")

/mob/living/carbon/human/plasma/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Plasmaman")

/mob/living/carbon/human/slime/New(var/new_loc)
	..(new_loc, "Slime People")

/mob/living/carbon/human/grey/New(var/new_loc)
	..(new_loc, "Grey")

/mob/living/carbon/human/human/New(var/new_loc)
	..(new_loc, "Human")

/mob/living/carbon/human/diona/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Diona")

/mob/living/carbon/human/machine/New(var/new_loc)
	h_style = "blue IPC screen"
	..(new_loc, "Machine")

/mob/living/carbon/human/shadow/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Shadow")

/mob/living/carbon/human/golem/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Golem")

/mob/living/carbon/human/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if (ismob(AM))
		var/mob/tmob = AM

		if( istype(tmob, /mob/living/carbon) && prob(10) )
			src.spread_disease_to(AM, "Contact")
//BubbleWrap - Should stop you pushing a restrained person out of the way

		if(istype(tmob, /mob/living/carbon/human))

			for(var/mob/M in range(tmob, 1))
				if(tmob.pinned.len ||  ((M.pulling == tmob && ( tmob.restrained() && !( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, tmob.grabbed_by.len)) )
					if ( !(world.time % 5) )
						src << "\red [tmob] is restrained, you cannot push past"
					now_pushing = 0
					return
				if( tmob.pulling == M && ( M.restrained() && !( tmob.restrained() ) && tmob.stat == 0) )
					if ( !(world.time % 5) )
						src << "\red [tmob] is restraining [M], you cannot push past"
					now_pushing = 0
					return

		//Leaping mobs just land on the tile, no pushing, no anything.
		if(status_flags & LEAPING)
			loc = tmob.loc
			status_flags &= ~LEAPING
			now_pushing = 0
			return

		if(istype(tmob,/mob/living/silicon/robot/drone)) //I have no idea why the hell this isn't already happening. How do mice do it?
			loc = tmob.loc
			now_pushing = 0
			return

		//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
		if((tmob.a_intent == "help" || tmob.restrained()) && (a_intent == "help" || src.restrained()) && tmob.canmove && !tmob.buckled && canmove) // mutual brohugs all around!
			var/turf/oldloc = loc
			loc = tmob.loc
			tmob.loc = oldloc
			now_pushing = 0
			for(var/mob/living/carbon/slime/slime in view(1,tmob))
				if(slime.Victim == tmob)
					slime.UpdateFeed()
			return

		if(istype(tmob, /mob/living/carbon/human) && (FAT in tmob.mutations))
			if(prob(40) && !(FAT in src.mutations))
				src << "\red <B>You fail to push [tmob]'s fat ass out of the way.</B>"
				now_pushing = 0
				return
		if(tmob.r_hand && istype(tmob.r_hand, /obj/item/weapon/shield/riot))
			if(prob(99))
				now_pushing = 0
				return
		if(tmob.l_hand && istype(tmob.l_hand, /obj/item/weapon/shield/riot))
			if(prob(99))
				now_pushing = 0
				return
		if(!(tmob.status_flags & CANPUSH))
			now_pushing = 0
			return

		tmob.LAssailant = src

	now_pushing = 0
	spawn(0)
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!now_pushing)
			now_pushing = 1

			if (!AM.anchored)
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window/full))
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
				step(AM, t)
			now_pushing = 0
		return
	return

/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")

	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")
	if(ticker && ticker.mode && ticker.mode.name == "AI malfunction")
		if(ticker.mode:malf_mode_declared)
			stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
	if(emergency_shuttle)
		var/eta_status = emergency_shuttle.get_status_panel_eta()
		if(eta_status)
			stat(null, eta_status)

	if (client.statpanel == "Status")
		if (internal)
			if (!internal.air_contents)
				del(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)
		if(mind)
			if(mind.changeling)
				stat("Chemical Storage", "[mind.changeling.chem_charges]/[mind.changeling.chem_storage]")
				stat("Absorbed DNA", mind.changeling.absorbedcount)

	if(istype(loc, /obj/spacepod)) // Spacdpods!
		var/obj/spacepod/S = loc
		stat("Spacepod Charge", "[istype(S.battery) ? "[(S.battery.charge / S.battery.maxcharge) * 100]" : "No cell detected"]")
		stat("Spacepod Integrity", "[!S.health ? "0" : "[(S.health / initial(S.health)) * 100]"]%")

/mob/living/carbon/human/ex_act(severity)
	var/shielded = 0
	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			if (!prob(getarmor(null, "bomb")))
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)

				var/limbs_affected = pick(2,3,4)
				var/obj/item/organ/external/processing_dismember

				while(limbs_affected != 0)
					processing_dismember = pick(organs)
					if(processing_dismember.limb_name != "chest" && processing_dismember.limb_name != "head" && processing_dismember.limb_name != "groin")
						processing_dismember.droplimb(1,pick(0,1,2),0,1)
						limbs_affected -= 1


			//return
//				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				//user.throw_at(target, 200, 4)

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

				var/limbs_affected = pick(1, 1, 2)
				var/obj/item/organ/external/processing_dismember

				while(limbs_affected != 0)
					processing_dismember = pick(organs)
					if(processing_dismember.limb_name != "chest" && processing_dismember.limb_name != "head" && processing_dismember.limb_name != "groin")
						processing_dismember.droplimb(1,pick(0,2),0,1)
						limbs_affected -= 1

			else
				var/limbs_affected = pick(1, 2, 3)
				var/obj/item/organ/external/processing_dismember

				while(limbs_affected != 0)
					processing_dismember = pick(organs)
					if(processing_dismember.limb_name != "chest" && processing_dismember.limb_name != "head" && processing_dismember.limb_name != "groin")
						processing_dismember.droplimb(1,pick(0,2),0,1)
						limbs_affected -= 1

			if (!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 30
				ear_deaf += 120
			if (prob(70) && !shielded)
				Paralyse(10)

		if(3.0)
			b_loss += 30
			if (prob(getarmor(null, "bomb")))
				b_loss = b_loss/2

			else

				var/limbs_affected = pick(0, 1)
				var/obj/item/organ/external/processing_dismember

				while(limbs_affected != 0)
					processing_dismember = pick(organs)
					if(processing_dismember.limb_name != "chest" && processing_dismember.limb_name != "head" && processing_dismember.limb_name != "groin")
						processing_dismember.droplimb(1,1,0,1)
						limbs_affected -= 1

			if (!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 15
				ear_deaf += 60
			if (prob(50) && !shielded)
				Paralyse(10)

	var/update = 0
	var/weapon_message = "Explosive Blast"
	for(var/obj/item/organ/external/temp in organs)
		switch(temp.limb_name)
			if("head")
				update |= temp.take_damage(b_loss * 0.2, f_loss * 0.2, used_weapon = weapon_message)
			if("chest")
				update |= temp.take_damage(b_loss * 0.4, f_loss * 0.4, used_weapon = weapon_message)
			if("groin")
				update |= temp.take_damage(b_loss * 0.1, f_loss * 0.1, used_weapon = weapon_message)
			if("l_arm")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("r_arm")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("l_leg")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("r_leg")
				update |= temp.take_damage(b_loss * 0.05, f_loss * 0.05, used_weapon = weapon_message)
			if("r_foot")
				update |= temp.take_damage(b_loss * 0.025, f_loss * 0.025, used_weapon = weapon_message)
			if("l_foot")
				update |= temp.take_damage(b_loss * 0.025, f_loss * 0.025, used_weapon = weapon_message)
			if("r_hand")
				update |= temp.take_damage(b_loss * 0.025, f_loss * 0.025, used_weapon = weapon_message)
			if("l_hand")
				update |= temp.take_damage(b_loss * 0.025, f_loss * 0.025, used_weapon = weapon_message)
	if(update)	UpdateDamageIcon()

	..()

/mob/living/carbon/human/blob_act()
	if(stat == 2)	return
	show_message("\red The blob attacks you!")
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
	apply_damage(rand(20,30), BRUTE, affecting, run_armor_check(affecting, "melee"))
	return

/mob/living/carbon/human/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message("\red [src] has been hit by [O]", 1)
	if (health > 0)
		var/obj/item/organ/external/affecting = get_organ(pick("chest", "chest", "chest", "head"))
		if(!affecting)	return
		if (istype(O, /obj/effect/immovablerod))
			if(affecting.take_damage(101, 0))
				UpdateDamageIcon()
		else
			if(affecting.take_damage((istype(O, /obj/effect/meteor/small) ? 10 : 25), 30))
				UpdateDamageIcon()
		updatehealth()
	return

/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		M.do_attack_animation(src)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		var/armor = run_armor_check(affecting, "melee")

		var/obj/item/organ/external/affected = src.get_organ(dam_zone)
		affected.add_autopsy_data(M.name, damage) // Add the mob's name to the autopsy data
		apply_damage(damage, BRUTE, affecting, armor, M.name)
		if(armor >= 2)	return

/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L as mob)

	switch(L.a_intent)
		if("help")
			visible_message("<span class='notice'>[L] rubs its head against [src].</span>")


		else
			L.do_attack_animation(src)
			var/damage = rand(1, 3)
			visible_message("<span class='danger'>[L] bites [src]!</span>", \
					"<span class='userdanger'>[L] bites [src]!</span>")
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)

			if(stat != DEAD)
				L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/organ/external/affecting = get_organ(ran_zone(L.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")
			apply_damage(damage, BRUTE, affecting, armor_block)

/mob/living/carbon/human/proc/is_loyalty_implanted(mob/living/carbon/human/M)
	for(var/L in M.contents)
		if(istype(L, /obj/item/weapon/implant/loyalty))
			for(var/obj/item/organ/external/O in M.organs)
				if(L in O.implants)
					return 1
	return 0

/mob/living/carbon/human/attack_slime(mob/living/carbon/slime/M as mob)
	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		M.do_attack_animation(src)
		visible_message("<span class='danger'>The [M.name] glomps [src]!</span>", \
				"<span class='userdanger'>The [M.name] glomps [src]!</span>")

		var/damage = rand(1, 3)

		if(M.is_adult)
			damage = rand(10, 35)
		else
			damage = rand(5, 25)


		var/dam_zone = pick("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg", "groin")

		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		var/armor_block = run_armor_check(affecting, "melee")
		apply_damage(damage, BRUTE, affecting, armor_block)


		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>The [M.name] has shocked []!</B>", src), 1)

				Weaken(power)
				if (stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))


		updatehealth()

	return


/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0



/mob/living/carbon/human/var/co2overloadtime = null
/mob/living/carbon/human/var/temperature_resistance = T0C+75


/mob/living/carbon/human/show_inv(mob/user as mob)
	var/obj/item/clothing/under/suit = null
	if (istype(w_uniform, /obj/item/clothing/under))
		suit = w_uniform

	var/obj/item/clothing/gloves/G
	var/pickpocket = 0
	if(ishuman(user))
		if(user:gloves)
			G = user:gloves
			pickpocket = G.pickpocket
	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask && !(wear_mask.flags & ABSTRACT)) ? wear_mask : "Nothing"]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand && !(l_hand.flags & ABSTRACT)) ? l_hand  : "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? r_hand : "Nothing"]</A>
	<BR><B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>[(gloves && !(gloves.flags & ABSTRACT)) ? gloves : "Nothing"]</A>
	<BR><B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>[(glasses && !(glasses.flags & ABSTRACT)) ? glasses : "Nothing"]</A>
	<BR><B>Left Ear:</B> <A href='?src=\ref[src];item=l_ear'>[(l_ear && !(l_ear.flags & ABSTRACT)) ? l_ear : "Nothing"]</A>
	<BR><B>Right Ear:</B> <A href='?src=\ref[src];item=r_ear'>[(r_ear && !(r_ear.flags & ABSTRACT)) ? r_ear : "Nothing"]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(head && !(head.flags & ABSTRACT)) ? head : "Nothing"]</A>
	<BR><B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>[(shoes && !(shoes.flags & ABSTRACT)) ? shoes : "Nothing"]</A>
	<BR><B>Belt:</B> <A href='?src=\ref[src];item=belt'>[(belt && !(belt.flags & ABSTRACT)) ? belt : "Nothing"]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(belt, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR><B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>[(w_uniform && !(w_uniform.flags & ABSTRACT)) ? w_uniform : "Nothing"]</A> [(suit) ? ((suit.has_sensor == 1) ? text(" <A href='?src=\ref[];item=sensor'>Sensors</A>", src) : "") :]
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(wear_suit && !(wear_suit.flags & ABSTRACT)) ? wear_suit : "Nothing"]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back && !(back.flags & ABSTRACT)) ? back : "Nothing"]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR><B>ID:</B> <A href='?src=\ref[src];item=id'>[(wear_id && !(wear_id.flags & ABSTRACT)) ? wear_id : "Nothing"]</A>
	<BR><B>PDA:</B> <A href='?src=\ref[src];item=pda'>[(wear_pda && !(wear_pda.flags & ABSTRACT)) ? wear_pda : "Nothing"]</A>
	<BR><B>Suit Storage:</B> <A href='?src=\ref[src];item=s_store'>[(s_store && !(s_store.flags & ABSTRACT)) ? s_store : "Nothing"]</A>
	<BR><BR><A href='?src=\ref[src];pockets=left'>Left Pocket ([(l_store && !(l_store.flags & ABSTRACT)) ? (pickpocket ? l_store.name : "Full") : "Empty"])</A>
	<BR><A href='?src=\ref[src];pockets=right'>Right Pocket ([(r_store && !(r_store.flags & ABSTRACT)) ? (pickpocket ? r_store.name : "Full") : "Empty"])</A>
	<BR><A href='?src=\ref[src];item=pockets'>Empty Both Pockets</A>
	<BR><BR>[(handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(legcuffed ? text("<A href='?src=\ref[src];item=legcuff'>Legcuffed</A>") : text(""))]
	[(suit) ? ((suit.accessories.len) ? text("<BR><A href='?src=\ref[];item=tie'>Remove Accessory</A>", src) : "") :]
	[(internal ? text("<BR><A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=splints'>Remove Splints</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob\ref[src];size=340x480"))
	onclose(user, "mob\ref[src]")
	return

// called when something steps onto a human
// this handles mulebots and vehicles
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	if(istype(AM, /obj/machinery/bot/mulebot))
		var/obj/machinery/bot/mulebot/MB = AM
		MB.RunOver(src)

	if(istype(AM, /obj/vehicle))
		var/obj/vehicle/V = AM
		V.RunOver(src)

// Get rank from ID, ID inside PDA, PDA, ID in wallet, etc.
/mob/living/carbon/human/proc/get_authentification_rank(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	if (istype(pda))
		if (pda.id)
			return pda.id.rank
		else
			return pda.ownrank
	else
		var/obj/item/weapon/card/id/id = get_idcard()
		if(id)
			return id.rank ? id.rank : if_no_job
		else
			return if_no_id

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id && istype(pda.id, /obj/item/weapon/card/id))
			. = pda.id.assignment
		else
			. = pda.ownjob
	else if (istype(id))
		. = id.assignment
	else
		return if_no_id
	if (!.)
		. = if_no_job
	return

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id)
			. = pda.id.registered_name
		else
			. = pda.owner
	else if (istype(id))
		. = id.registered_name
	else
		return if_no_id
	return

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/proc/get_visible_name()
	if( wear_mask && (wear_mask.flags_inv&HIDEFACE) )	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if( head && (head.flags_inv&HIDEFACE) )
		return get_id_name("Unknown")		//Likewise for hats
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/obj/item/organ/external/head = get_organ("head")
	if( !head || head.disfigured || (head.status & ORGAN_DESTROYED) || !real_name || (HUSK in mutations) )	//disfigured. use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if(istype(pda))		. = pda.owner
	else if(istype(id))	. = id.registered_name
	if(!.) 				. = if_no_id	//to prevent null-names making the mob unclickable
	return

//gets ID card object from special clothes slot or null.
/mob/living/carbon/human/proc/get_idcard()
	var/obj/item/weapon/card/id/id = wear_id
	var/obj/item/device/pda/pda = wear_id
	if (istype(pda) && pda.id)
		id = pda.id
	if (istype(id))
		return id

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/base_siemens_coeff = 1.0, var/def_zone = null)
	if(status_flags & GODMODE)	//godmode
		return 0
	if(NO_SHOCK in mutations) //shockproof
		return 0

	if (!def_zone)
		def_zone = pick("l_hand", "r_hand")

	var/obj/item/organ/external/affected_organ = get_organ(check_zone(def_zone))
	var/siemens_coeff = base_siemens_coeff * get_siemens_coefficient_organ(affected_organ)

	return ..(shock_damage, source, siemens_coeff, def_zone)


/mob/living/carbon/human/Topic(href, href_list)
	var/pickpocket = 0

	if(!usr.stat && usr.canmove && !usr.restrained() && in_range(src, usr))

		// if looting pockets with gloves, do it quietly
		if(href_list["pockets"])
			if(usr:gloves)
				var/obj/item/clothing/gloves/G = usr:gloves
				pickpocket = G.pickpocket
			var/pocket_side = href_list["pockets"]
			var/pocket_id = (pocket_side == "right" ? slot_r_store : slot_l_store)
			var/obj/item/pocket_item = (pocket_id == slot_r_store ? src.r_store : src.l_store)
			var/obj/item/place_item = usr.get_active_hand() // Item to place in the pocket, if it's empty

			if(pocket_item && !(pocket_item.flags & ABSTRACT))
				if(pocket_item.flags & NODROP)
					usr << "<span class='notice'>You try to empty [src]'s [pocket_side] pocket, it seems to be stuck!</span>"
				usr << "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>"
			else if(place_item && place_item.mob_can_equip(src, pocket_id, 1) && !(place_item.flags & ABSTRACT))
				usr << "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>"
			else
				return

			if(do_mob(usr, src, STRIP_DELAY))
				if(pocket_item)
					unEquip(pocket_item)
					usr.put_in_hands(pocket_item)
				else
					if(place_item)
						usr.unEquip(place_item)
					equip_to_slot_if_possible(place_item, pocket_id, 0, 1)

				// Update strip window
				if(usr.machine == src && in_range(src, usr))
					show_inv(usr)



			else if(!pickpocket)
				// Display a warning if the user mocks up
				src << "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>"


		// if looting id with gloves, do it quietly - this allows pickpocket gloves to take/place id stealthily - Bone White
		if(href_list["item"])
			var/itemTarget = href_list["item"]
			if(itemTarget == "id")
				if(usr:gloves)
					var/obj/item/clothing/gloves/G = usr:gloves
					pickpocket = G.pickpocket
				if(pickpocket)
					var/obj/item/worn_id = src.wear_id
					var/obj/item/place_item = usr.get_active_hand() // Item to place in the pocket, if it's empty

					if(worn_id)
						usr << "<span class='notice'>You try to remove [src]'s ID.</span>"
					else if(place_item && place_item.mob_can_equip(src, slot_wear_id, 1))
						usr << "<span class='notice'>You try to place [place_item] onto [src].</span>"
					else
						return

					if(do_mob(usr, src, STRIP_DELAY))
						if(worn_id)
							unEquip(worn_id)
							usr.put_in_hands(worn_id)
						else
							if(place_item)
								usr.unEquip(place_item)
							equip_to_slot_if_possible(place_item, slot_wear_id, 0, 1)

						// Update strip window
						if(usr.machine == src && in_range(src, usr))
							show_inv(usr)



					else if(!pickpocket)
						// Display a warning if the user mocks up
						src << "<span class='warning'>You feel your ID slot being fumbled with!</span>"




	if (href_list["refresh"])
		if((machine)&&(in_range(src, usr)))
			show_inv(machine)

	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)

	if ((href_list["item"] && !( usr.stat ) && usr.canmove && !( usr.restrained() ) && in_range(src, usr) && ticker)) //if game hasn't started, can't make an equip_e
		var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human(  )
		if(ishuman(usr) && usr:gloves)
			var/obj/item/clothing/gloves/G = usr:gloves
			pickpocket = G.pickpocket
		if(!pickpocket || href_list["item"] != "id")  // Stop the non-stealthy verbose strip if pickpocketing id.
			O.source = usr
			O.target = src
			O.item = usr.get_active_hand()
			O.s_loc = usr.loc
			O.t_loc = loc
			O.place = href_list["item"]
			O.pickpocket = pickpocket //Stealthy
			requests += O
			spawn( 0 )
				O.process()
				return

	if (href_list["criminal"])
		if(hasHUD(usr,"security"))

			var/modified = 0
			var/perpname = "wot"
			if(wear_id)
				var/obj/item/weapon/card/id/I = wear_id.GetID()
				if(I)
					perpname = I.registered_name
				else
					perpname = name
			else
				perpname = name

			if(perpname)
				for (var/datum/data/record/E in data_core.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in data_core.security)
							if (R.fields["id"] == E.fields["id"])

								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Released", "Cancel")

								if(hasHUD(usr, "security"))
									if(setcriminal != "Cancel")
										R.fields["criminal"] = setcriminal
										modified = 1

										spawn()
											hud_updateflag |= 1 << WANTED_HUD
											if(istype(usr,/mob/living/carbon/human))
												var/mob/living/carbon/human/U = usr
												U.handle_regular_hud_updates()
											if(istype(usr,/mob/living/silicon/robot))
												var/mob/living/silicon/robot/U = usr
												U.handle_regular_hud_updates()

			if(!modified)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["secrecord"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								usr << "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]"
								usr << "<b>Minor Crimes:</b> [R.fields["mi_crim"]]"
								usr << "<b>Details:</b> [R.fields["mi_crim_d"]]"
								usr << "<b>Major Crimes:</b> [R.fields["ma_crim"]]"
								usr << "<b>Details:</b> [R.fields["ma_crim_d"]]"
								usr << "<b>Notes:</b> [R.fields["notes"]]"
								usr << "<a href='?src=\ref[src];secrecordComment=`'>\[View Comment Log\]</a>"
								read = 1

			if(!read)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["secrecordComment"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									usr << text("[]", R.fields[text("com_[]", counter)])
									counter++
								if (counter == 1)
									usr << "No comment found"
								usr << "<a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>"

			if(!read)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["secrecordadd"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								var/t1 = sanitize(copytext(input("Add Comment:", "Sec. records", null, null)  as message,1,MAX_MESSAGE_LEN))
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"security")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/ai))
									var/mob/living/silicon/ai/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] (artificial intelligence) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")

	if (href_list["medical"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/modified = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name

			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.general)
						if (R.fields["id"] == E.fields["id"])

							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")

							if(hasHUD(usr,"medical"))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1
									if(PDA_Manifest.len)
										PDA_Manifest.Cut()

									spawn()
										if(istype(usr,/mob/living/carbon/human))
											var/mob/living/carbon/human/U = usr
											U.handle_regular_hud_updates()
										if(istype(usr,/mob/living/silicon/robot))
											var/mob/living/silicon/robot/U = usr
											U.handle_regular_hud_updates()

			if(!modified)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["medrecord"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								usr << "<b>Name:</b> [R.fields["name"]]	<b>Blood Type:</b> [R.fields["b_type"]]"
								usr << "<b>DNA:</b> [R.fields["b_dna"]]"
								usr << "<b>Minor Disabilities:</b> [R.fields["mi_dis"]]"
								usr << "<b>Details:</b> [R.fields["mi_dis_d"]]"
								usr << "<b>Major Disabilities:</b> [R.fields["ma_dis"]]"
								usr << "<b>Details:</b> [R.fields["ma_dis_d"]]"
								usr << "<b>Notes:</b> [R.fields["notes"]]"
								usr << "<a href='?src=\ref[src];medrecordComment=`'>\[View Comment Log\]</a>"
								read = 1

			if(!read)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["medrecordComment"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									usr << text("[]", R.fields[text("com_[]", counter)])
									counter++
								if (counter == 1)
									usr << "No comment found"
								usr << "<a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>"

			if(!read)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["medrecordadd"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								var/t1 = sanitize(copytext(input("Add Comment:", "Med. records", null, null)  as message,1,MAX_MESSAGE_LEN))
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"medical")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")

	if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		I.examine()

	if (href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		M.examine()
	..()
	return


///eyecheck()
///Returns a number between -1 to 2
/mob/living/carbon/human/eyecheck()
	var/number = 0
	if(istype(src.head, /obj/item/clothing/head))			//are they wearing something on their head
		var/obj/item/clothing/head/HFP = src.head			//if yes gets the flash protection value from that item
		number += HFP.flash_protect
	if(istype(src.glasses, /obj/item/clothing/glasses))		//glasses
		var/obj/item/clothing/glasses/GFP = src.glasses
		number += GFP.flash_protect
	if(istype(src.wear_mask, /obj/item/clothing/mask))		//mask
		var/obj/item/clothing/mask/MFP = src.wear_mask
		number += MFP.flash_protect
	return number

///tintcheck()
///Checks eye covering items for visually impairing tinting, such as welding masks
///Checked in life.dm. 0 & 1 = no impairment, 2 = welding mask overlay, 3 = You can see jack, but you can't see shit.
/mob/living/carbon/human/tintcheck()
	var/tinted = 0
	if(istype(src.head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = src.head
		tinted += HT.tint
	if(istype(src.glasses, /obj/item/clothing/glasses))
		var/obj/item/clothing/glasses/GT = src.glasses
		tinted += GT.tint
	if(istype(src.wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/MT = src.wear_mask
		tinted += MT.tint
	return tinted

/mob/living/carbon/human/IsAdvancedToolUser()
	return 1//Humans can use guns and such


/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !(src.l_hand.flags & ABSTRACT)) || (src.r_hand && !(src.r_hand.flags & ABSTRACT)) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves)))
		return 1

	if((src.l_hand && !(src.l_hand.flags & ABSTRACT)) || (src.r_hand && !(src.r_hand.flags & ABSTRACT)))
		return 1

	return 0


/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)
	return

/mob/living/carbon/human/get_species()

	if(!species)
		set_species()

	return species.name

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("\red [src] begins playing his ribcage like a xylophone. It's quite spooky.","\blue You begin to play a spooky refrain on your ribcage.","\red You hear a spooky xylophone melody.")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/can_inject(var/mob/user, var/error_msg, var/target_zone)
	. = 1 // Default to returning true.
	if(user && !target_zone)
		target_zone = user.zone_sel.selecting
	// If targeting the head, see if the head item is thin enough.
	// If targeting anything else, see if the wear suit is thin enough.
	if(above_neck(target_zone))
		if(head && head.flags & THICKMATERIAL)
			. = 0
	else
		if(wear_suit && wear_suit.flags & THICKMATERIAL)
			. = 0
	if(!. && error_msg && user)
		// Might need re-wording.
		user << "<span class='alert'>There is no exposed flesh or thin material [target_zone == "head" ? "on their head" : "on their body"].</span>"

/mob/living/carbon/human/proc/vomit(hairball=0)
	if(stat==2)return

	if(species.flags & IS_SYNTHETIC)
		return //Machines don't throw up.

	if(!lastpuke)
		lastpuke = 1
		src << "<spawn class='warning'>You feel nauseous..."
		spawn(150)	//15 seconds until second warning
			src << "<spawn class='warning'>You feel like you are about to throw up!"
			spawn(100)	//and you have 10 more for mad dash to the bucket
				Stun(5)

				if(hairball)
					src.visible_message("<span class='warning'>[src] hacks up a hairball!</span>","<span class='warning'>You hack up a hairball!</span>")
				else
					src.visible_message("<span class='warning'>[src] throws up!</span>","<span class='warning'>You throw up!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

				var/turf/location = loc
				if (istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1)

				var/stomach_len = src.stomach_contents.len
				if (stomach_len)
					var/content = src.stomach_contents[stomach_len]
					if (istype(content, /atom/movable))
						var/atom/movable/AM = content
						src.stomach_contents.Remove(AM)
						AM.loc = location

				if(!hairball)
					nutrition -= 40
					adjustToxLoss(-3)
				spawn(350)	//wait 35 seconds before next volley
					lastpuke = 0


/mob/living/carbon/human/proc/get_visible_gender()
	if(wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT && ((head && head.flags_inv & HIDEMASK) || wear_mask))
		return NEUTER
	return gender

/mob/living/carbon/human/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n

/mob/living/carbon/human/revive()

	if(species && !(species.flags & NO_BLOOD))
		vessel.add_reagent("blood",560-vessel.total_volume)
		fixblood()

	// Fix up all organs.
	// This will ignore any prosthetics in the prefs currently.
	species.create_organs(src)

	if(!client || !key) //Don't boot out anyone already in the mob.
		for (var/obj/item/organ/brain/H in world)
			if(H.brainmob)
				if(H.brainmob.real_name == src.real_name)
					if(H.brainmob.mind)
						H.brainmob.mind.transfer_to(src)
						del(H)



	for (var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		V.cure(src)

	..()

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/obj/item/organ/lungs/L = internal_organs_by_name["lungs"]
	if(!L)
		return 0

	return L.is_bruised()

/mob/living/carbon/human/proc/rupture_lung()
	var/obj/item/organ/lungs/L = internal_organs_by_name["lungs"]
	if(!L)
		return 0

	if(!L.is_bruised())
		src.custom_pain("You feel a stabbing pain in your chest!", 1)
		L.damage = L.min_bruised_damage

/*
/mob/living/carbon/human/verb/simulate()
	set name = "sim"
	//set background = 1

	var/damage = input("Wound damage","Wound damage") as num

	var/germs = 0
	var/tdamage = 0
	var/ticks = 0
	while (germs < 2501 && ticks < 100000 && round(damage/10)*20)
		diary << "VIRUS TESTING: [ticks] : germs [germs] tdamage [tdamage] prob [round(damage/10)*20]"
		ticks++
		if (prob(round(damage/10)*20))
			germs++
		if (germs == 100)
			world << "Reached stage 1 in [ticks] ticks"
		if (germs > 100)
			if (prob(10))
				damage++
				germs++
		if (germs == 1000)
			world << "Reached stage 2 in [ticks] ticks"
		if (germs > 1000)
			damage++
			germs++
		if (germs == 2500)
			world << "Reached stage 3 in [ticks] ticks"
	world << "Mob took [tdamage] tox damage"
*/
//returns 1 if made bloody, returns 0 otherwise

/mob/living/carbon/human/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0
	//if this blood isn't already in the list, add it
	if(blood_DNA[M.dna.unique_enzymes])
		return 0 //already bloodied with this blood. Cannot add more.
	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	hand_blood_color = blood_color
	src.update_inv_gloves()
	verbs += /mob/living/carbon/human/proc/bloody_doodle
	return 1 //we applied blood to the item

/mob/living/carbon/human/clean_blood(var/clean_feet)
	.=..()
	if(clean_feet && !shoes && istype(feet_blood_DNA, /list) && feet_blood_DNA.len)
		feet_blood_color = null
		del(feet_blood_DNA)
		update_inv_shoes(1)
		return 1

/mob/living/carbon/human/get_visible_implants(var/class = 0)

	var/list/visible_implants = list()
	for(var/obj/item/organ/external/organ in src.organs)
		for(var/obj/item/weapon/O in organ.implants)
			if(!istype(O,/obj/item/weapon/implant) && (O.w_class > class) && !istype(O,/obj/item/weapon/shard/shrapnel))
				visible_implants += O

	return(visible_implants)

/mob/living/carbon/human/generate_name()
	name = species.makeName(gender,src)
	real_name = name
	return name

/mob/living/carbon/human/proc/handle_embedded_objects()

	for(var/obj/item/organ/external/organ in src.organs)
		if(organ.status & ORGAN_SPLINTED) //Splints prevent movement.
			continue
		for(var/obj/item/weapon/O in organ.implants)
			if(!istype(O,/obj/item/weapon/implant) && prob(5)) //Moving with things stuck in you could be bad.
				// All kinds of embedded objects cause bleeding.
				var/msg = null
				switch(rand(1,3))
					if(1)
						msg ="<span class='warning'>A spike of pain jolts your [organ.name] as you bump [O] inside.</span>"
					if(2)
						msg ="<span class='warning'>Your movement jostles [O] in your [organ.name] painfully.</span>"
					if(3)
						msg ="<span class='warning'>[O] in your [organ.name] twists painfully as you move.</span>"
				src << msg

				organ.take_damage(rand(1,3), 0, 0)
				if(!(organ.status & ORGAN_ROBOT)) //There is no blood in protheses.
					organ.status |= ORGAN_BLEEDING
					src.adjustToxLoss(rand(1,3))

/mob/living/carbon/human/verb/check_pulse()
	set category = null
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.stat == 1 || usr.restrained() || !isliving(usr)) return

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message("\blue [usr] kneels down, puts \his hand on [src]'s wrist and begins counting their pulse.",\
		"You begin counting [src]'s pulse")
	else
		usr.visible_message("\blue [usr] begins counting their pulse.",\
		"You begin counting your pulse.")

	if(src.pulse)
		usr << "\blue [self ? "You have a" : "[src] has a"] pulse! Counting..."
	else
		usr << "\red [src] has no pulse!"	//it is REALLY UNLIKELY that a dead person would check his own pulse
		return

	usr << "Don't move until counting is finished."
	var/time = world.time
	sleep(60)
	if(usr.l_move_time >= time)	//checks if our mob has moved during the sleep()
		usr << "You moved while counting. Try again."
	else
		usr << "\blue [self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)]."

/mob/living/carbon/human/proc/set_species(var/new_species, var/default_colour)

	var/datum/species/oldspecies = species
	if(!dna)
		if(!new_species)
			new_species = "Human"
	else
		if(!new_species)
			new_species = dna.species
		else
			dna.species = new_species

	if(species)
		if(species.name && species.name == new_species)
			return

		if(species.language)
			remove_language(species.language)

		if(species.default_language)
			remove_language(species.default_language)

	species = all_species[new_species]

	if(oldspecies)
		if(oldspecies.default_genes.len)
			oldspecies.handle_dna(src,1) // Remove any genes that belong to the old species

	if(vessel)
		vessel = null
	make_blood()

	if(species.language)
		add_language(species.language)

	if(species.default_language)
		add_language(species.default_language)

	see_in_dark = species.darksight
	if(see_in_dark > 2)
		see_invisible = SEE_INVISIBLE_LEVEL_ONE
	else
		see_invisible = SEE_INVISIBLE_LIVING

	if(species.base_color && default_colour)
		//Apply colour.
		r_skin = hex2num(copytext(species.base_color,2,4))
		g_skin = hex2num(copytext(species.base_color,4,6))
		b_skin = hex2num(copytext(species.base_color,6,8))
	else
		r_skin = 0
		g_skin = 0
		b_skin = 0

	species.create_organs(src)

	if(!dna)
		dna = new /datum/dna(null)
		dna.species = species.name
		dna.real_name = real_name

	species.handle_post_spawn(src)

	spawn(0)
		overlays.Cut()
		update_mutantrace(1)
		regenerate_icons()
		fixblood()

	if(species)
		return 1
	else
		return 0

/mob/living/carbon/human/get_default_language()
	if(default_language)
		return default_language

	if(!species)
		return null
	return species.default_language ? all_languages[species.default_language] : null


/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if (usr != src)
		return 0 //something is terribly wrong

	if (!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if (src.gloves)
		src << "<span class='warning'>Your [src.gloves] are getting in the way.</span>"
		return

	var/turf/simulated/T = src.loc
	if (!istype(T)) //to prevent doodling out of mechs and lockers
		src << "<span class='warning'>You cannot reach the floor.</span>"
		return

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	if (direction != "Here")
		T = get_step(T,text2dir(direction))
	if (!istype(T))
		src << "<span class='warning'>You cannot doodle there.</span>"
		return

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		src << "<span class='warning'>There is no space to write on!</span>"
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"
			src << "<span class='warning'>You ran out of blood to write with!</span>"

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)

		W.add_fingerprint(src)



/mob/living/carbon/human/canSingulothPull(var/obj/machinery/singularity/singulo)
	if(!..())
		return 0

	if(istype(shoes,/obj/item/clothing/shoes/magboots))
		var/obj/item/clothing/shoes/magboots/M = shoes
		if(M.magpulse)
			return 0
	return 1


//Putting a couple of procs here that I don't know where else to dump.
//Mostly going to be used for Vox and Vox Armalis, but other human mobs might like them (for adminbuse).

/mob/living/carbon/human/proc/leap()
	set category = "Abilities"
	set name = "Leap"
	set desc = "Leap at a target and grab them aggressively."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You cannot leap in your current state."
		return

	var/list/choices = list()
	for(var/mob/living/M in view(6,src))
		if(!istype(M,/mob/living/silicon))
			choices += M
	choices -= src

	var/mob/living/T = input(src,"Who do you wish to leap at?") as null|anything in choices

	if(!T || !src || src.stat) return

	if(get_dist(get_turf(T), get_turf(src)) > 6) return

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You cannot leap in your current state."
		return

	last_special = world.time + 75
	status_flags |= LEAPING

	src.visible_message("<span class='warning'><b>\The [src]</b> leaps at [T]!</span>")
	src.throw_at(get_step(get_turf(T),get_turf(src)), 5, 1, src)
	playsound(src.loc, 'sound/voice/shriek1.ogg', 50, 1)

	sleep(5)

	if(status_flags & LEAPING) status_flags &= ~LEAPING

	if(!src.Adjacent(T))
		src << "\red You miss!"
		return

	T.Weaken(5)

	//Only official raider vox get the grab and no self-prone."
	if(src.mind && src.mind.special_role != "Vox Raider")
		src.Weaken(5)
		return

	var/use_hand = "left"
	if(l_hand)
		if(r_hand)
			src << "\red You need to have one hand free to grab someone."
			return
		else
			use_hand = "right"

	src.visible_message("<span class='warning'><b>\The [src]</b> seizes [T] aggressively!</span>")

	var/obj/item/weapon/grab/G = new(src,T)
	if(use_hand == "left")
		l_hand = G
	else
		r_hand = G

	G.state = GRAB_AGGRESSIVE
	G.icon_state = "grabbed1"
	G.synch()

/mob/living/carbon/human/proc/gut()
	set category = "Abilities"
	set name = "Gut"
	set desc = "While grabbing someone aggressively, rip their guts out or tear them apart."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying)
		src << "\red You cannot do that in your current state."
		return

	var/obj/item/weapon/grab/G = locate() in src
	if(!G || !istype(G))
		src << "\red You are not grabbing anyone."
		return

	if(G.state < GRAB_AGGRESSIVE)
		src << "\red You must have an aggressive grab to gut your prey!"
		return

	last_special = world.time + 50

	visible_message("<span class='warning'><b>\The [src]</b> rips viciously at \the [G.affecting]'s body with its claws!</span>")

	if(istype(G.affecting,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = G.affecting
		H.apply_damage(50,BRUTE)
		if(H.stat == 2)
			H.gib()
	else
		var/mob/living/M = G.affecting
		if(!istype(M)) return //wut
		M.apply_damage(50,BRUTE)
		if(M.stat == 2)
			M.gib()

/mob/living/carbon/human/assess_threat(var/obj/machinery/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if((istype(r_hand,/obj/item/weapon/gun/energy/laser/redtag)) || (istype(l_hand,/obj/item/weapon/gun/energy/laser/redtag)))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 2

		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if((istype(r_hand,/obj/item/weapon/gun/energy/laser/bluetag)) || (istype(l_hand,/obj/item/weapon/gun/energy/laser/bluetag)))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 2

		return threatcount

	//Check for ID
	var/obj/item/weapon/card/id/idcard = get_idcard()
	if(judgebot.idcheck && !idcard)
		threatcount += 4

	//Check for weapons
	if(judgebot.weaponscheck)
		if(!idcard || !(access_weapons in idcard.access))
			if(judgebot.check_for_weapons(l_hand))
				threatcount += 4
			if(judgebot.check_for_weapons(r_hand))
				threatcount += 4
			if(judgebot.check_for_weapons(belt))
				threatcount += 2

	//Check for arrest warrant
	if(judgebot.check_records)
		var/perpname = get_face_name(get_id_name())
		var/datum/data/record/R = find_record("name", perpname, data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if("*Arrest*")
					threatcount += 5
				if("Incarcerated")
					threatcount += 2
				if("Parolled")
					threatcount += 2

	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/rig/wizard))
		threatcount += 2


	//Loyalty implants imply trustworthyness
	if(isloyal(src))
		threatcount -= 1

	//Agent cards lower threatlevel.
	if(istype(idcard, /obj/item/weapon/card/id/syndicate))
		threatcount -= 5

	return threatcount

/mob/living/carbon/human/canBeHandcuffed()
	return 1

/mob/living/carbon/human/InCritical()
	return (health <= config.health_threshold_crit && stat == UNCONSCIOUS)