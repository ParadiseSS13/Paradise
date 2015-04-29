mob/living
	var/canEnterVentWith = "/obj/item/weapon/implant=0&/obj/item/clothing/mask/facehugger=0&/obj/item/device/radio/borg=0&/obj/machinery/camera=0"

/mob/living/carbon/Login()
	..()
	update_hud()
	return

/mob/living/carbon/Life()
	..()

	// Increase germ_level regularly
	if(germ_level < GERM_LEVEL_AMBIENT && prob(30))	//if you're just standing there, you shouldn't get more germs beyond an ambient level
		germ_level++

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(src.nutrition && src.stat != 2)
			src.nutrition -= HUNGER_FACTOR/10
			if(src.m_intent == "run")
				src.nutrition -= HUNGER_FACTOR/10
		if((FAT in src.mutations) && src.m_intent == "run" && src.bodytemperature <= 360)
			src.bodytemperature += 2

		// Moving around increases germ_level faster
		if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
			germ_level++

/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("\red You hear something rumbling inside [src]'s stomach..."), 2)
			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/obj/item/organ/external/organ = H.get_organ("chest")
					if (istype(organ))
						if(organ.take_damage(d, 0))
							H.UpdateDamageIcon()
					H.updatehealth()
				else
					src.take_organ_damage(d)
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("\red <B>[user] attacks [src]'s stomach wall with the [I.name]!"), 2)
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(src.getBruteLoss() - 50))
					for(var/atom/movable/A in stomach_contents)
						A.loc = loc
						stomach_contents.Remove(A)
					src.gib()

/mob/living/carbon/gib()
	for(var/mob/M in src)
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		M.loc = src.loc
		for(var/mob/N in viewers(src, null))
			if(N.client)
				N.show_message(text("\red <B>[M] bursts out of [src]!</B>"), 2)
	. = ..()


/mob/living/carbon/attack_hand(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/temp = H.organs_by_name["r_hand"]
		if (H.hand)
			temp = H.organs_by_name["l_hand"]
		if(temp && !temp.is_usable())
			H << "\red You can't use your [temp.name]"
			return
	return


/mob/living/carbon/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/def_zone = null)
	if(status_flags & GODMODE)	//godmode
		return 0
	if(NO_SHOCK in mutations) //shockproof
		return 0
	shock_damage *= siemens_coeff
	if (shock_damage<1)
		return 0

	src.apply_damage(shock_damage, BURN, def_zone, used_weapon="Electrocution")

	if(heart_attack && prob(25))
		heart_attack = 0
	playsound(loc, "sparks", 50, 1, -1)
	if (shock_damage < 10)
		src.visible_message(
			"\red [src] was mildly shocked by the [source].", \
			"\red You feel a mild shock course through your body.", \
			"\red You hear a light zapping." \
		)
	if (shock_damage > 10)
		if (shock_damage < 200)
			src.visible_message(
				"\red [src] was shocked by the [source]!", \
				"\red <B>You feel a powerful shock course through your body!</B>", \
				"\red You hear a heavy electrical crack." \
			)
		jitteriness += 1000 //High numbers for violent convulsions
		do_jitter_animation(jitteriness)
		stuttering += 2
		Stun(2)
		spawn(20)
			jitteriness -= 990 //Still jittery, but vastly less
			Stun(3)
			Weaken(3)
	if (shock_damage > 200)
		src.visible_message(
			"\red [src] was arc flashed by the [source]!", \
			"\red <B>The [source] arc flashes and electrocutes you!</B>", \
			"\red You hear a lightning-like crack!" \
		)
		playsound(loc, "sound/effects/eleczap.ogg", 50, 1, -1)
		explosion(src.loc,-1,0,2,2)
	return shock_damage


/mob/living/carbon/proc/swap_hand()
	var/obj/item/item_in_hand = src.get_active_hand()
	if(item_in_hand) //this segment checks if the item in your hand is twohanded.
		if(istype(item_in_hand,/obj/item/weapon/twohanded))
			if(item_in_hand:wielded == 1)
				usr << "<span class='warning'>Your other hand is too busy holding the [item_in_hand.name]</span>"
				return
	src.hand = !( src.hand )
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.icon_state = "hand_active"
			hud_used.r_hand_hud_object.icon_state = "hand_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_active"
	/*if (!( src.hand ))
		src.hands.dir = NORTH
	else
		src.hands.dir = SOUTH*/
	return

/mob/living/carbon/proc/activate_hand(var/selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if (src.health >= config.health_threshold_crit)
		if(src == M && istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			src.visible_message( \
				text("\blue [src] examines [].",src.gender==MALE?"himself":"herself"), \
				"\blue You check yourself for injuries." \
				)

			for(var/obj/item/organ/external/org in H.organs)
				var/status = ""
				var/brutedamage = org.brute_dam
				var/burndamage = org.burn_dam
				if(halloss > 0)
					if(prob(30))
						brutedamage += halloss
					if(prob(30))
						burndamage += halloss

				if(brutedamage > 0)
					status = "bruised"
				if(brutedamage > 20)
					status = "bleeding"
				if(brutedamage > 40)
					status = "mangled"
				if(brutedamage > 0 && burndamage > 0)
					status += " and "
				if(burndamage > 40)
					status += "peeling away"

				else if(burndamage > 10)
					status += "blistered"
				else if(burndamage > 0)
					status += "numb"
				if(org.status & ORGAN_DESTROYED)
					status = "MISSING!"
				if(org.status & ORGAN_MUTATED)
					status = "weirdly shapen."
				if(status == "")
					status = "OK"
				src.show_message(text("\t []My [] is [].",status=="OK"?"\blue ":"\red ",org.name,status),1)
			if(staminaloss)
				if(staminaloss > 30)
					src << "<span class='info'>You're completely exhausted.</span>"
				else
					src << "<span class='info'>You feel fatigued.</span>"
			if((SKELETON in H.mutations) && (!H.w_uniform) && (!H.wear_suit))
				H.play_xylophone()
		else
			if(player_logged)
				M.visible_message("<span class='notice'>[M] shakes [src], but they do not respond. Probably suffering from SSD.", \
				"<span class='notice'>You shake [src], but they are unresponsive. Probably suffering from SSD.</span>")
			if(lying) // /vg/: For hugs. This is how update_icon figgers it out, anyway.  - N3X15
				var/t_him = "it"
				if (src.gender == MALE)
					t_him = "him"
				else if (src.gender == FEMALE)
					t_him = "her"
				if (istype(src,/mob/living/carbon/human) && src:w_uniform)
					var/mob/living/carbon/human/H = src
					H.w_uniform.add_fingerprint(M)
				src.sleeping = max(0,src.sleeping-5)
				if(src.sleeping == 0)
					src.resting = 0
				AdjustParalysis(-3)
				AdjustStunned(-3)
				AdjustWeakened(-3)
				playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				M.visible_message( \
					"\blue [M] shakes [src] trying to wake [t_him] up!", \
					"\blue You shake [src] trying to wake [t_him] up!", \
					)
			// BEGIN HUGCODE - N3X
			else
				if (istype(src,/mob/living/carbon/human) && src:w_uniform)
					var/mob/living/carbon/human/H = src
					H.w_uniform.add_fingerprint(M)
				playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				M.visible_message( \
					"\blue [M] gives [src] a [pick("hug","warm embrace")].", \
					"\blue You hug [src].", \
					)


/mob/living/carbon/proc/eyecheck()
	return 0

/mob/living/carbon/proc/tintcheck()
	return 0

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(var/datum/dna/newDNA)
	dna = newDNA

/mob/living/carbon/can_use_vents()
	return

/mob/living/proc/handle_ventcrawl(var/atom/clicked_on) // -- TLE -- Merged by Carn
	diary << "[src] is ventcrawling."
	if(!stat)
		if(!lying)

/*
			if(clicked_on)
				world << "We start with [clicked_on], and [clicked_on.type]"
*/
			var/obj/machinery/atmospherics/unary/vent_found

			if(clicked_on && Adjacent(clicked_on))
				vent_found = clicked_on
				if(!istype(vent_found) || !vent_found.can_crawl_through())
					vent_found = null


			if(!vent_found)
				for(var/obj/machinery/atmospherics/machine in range(1,src))
					if(is_type_in_list(machine, ventcrawl_machinery))
						vent_found = machine

					if(!vent_found.can_crawl_through())
						vent_found = null

					if(vent_found)
						break

			if(vent_found)
				if(vent_found.network && (vent_found.network.normal_members.len || vent_found.network.line_members.len))

					src << "You begin climbing into the ventilation system..."
					if(!do_after(src, 45))
						return

					if(!client)
						return

					if(contents.len && !isrobot(src))
						for(var/obj/item/carried_item in contents)//If the ventcrawler got on objects.
							if(!(isInTypes(carried_item, canEnterVentWith)))
								src << "<SPAN CLASS='warning'>You can't be carrying items or have items equipped when vent crawling!</SPAN>"
								return

					visible_message("<B>[src] scrambles into the ventilation ducts!</B>", "You climb into the ventilation system.")

					loc = vent_found
					add_ventcrawl(vent_found)

				else
					src << "This vent is not connected to anything."

			else
				src << "You must be standing on or beside an air vent to enter it."

		else
			src << "You can't vent crawl while you're stunned!"

	else
		src << "You must be conscious to do this!"
	return

/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/unary/starting_machine)
	for(var/datum/pipeline/pipeline in starting_machine.network.line_members)
		for(var/atom/A in (pipeline.members || pipeline.edges))
			var/image/new_image = image(A, A.loc, dir = A.dir)
			pipes_shown += new_image
			client.images += new_image

/mob/living/proc/remove_ventcrawl()
	for(var/image/current_image in pipes_shown)
		client.images -= current_image

	pipes_shown.len = 0

	if(client)
		client.eye = src

/mob/living/carbon/clean_blood()
	. = ..()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.gloves)
			if(H.gloves.clean_blood())
				H.update_inv_gloves(0,0)
			H.gloves.germ_level = 0
		else
			if(H.bloody_hands)
				H.bloody_hands = 0
				H.update_inv_gloves(0,0)
			H.germ_level = 0
	update_icons()	//apply the now updated overlays to the mob


//Throwing stuff

/mob/living/carbon/proc/toggle_throw_mode()
	if (in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/carbon/proc/throw_mode_off()
	src.in_throw_mode = 0
	if(src.throw_icon) //in case we don't have the HUD and we use the hotkey
		src.throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/proc/throw_mode_on()
	src.in_throw_mode = 1
	if(src.throw_icon)
		src.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	throw_mode_off()
	if(usr.stat || !target)
		return
	if(target.type == /obj/screen)
		return

	var/atom/movable/item = src.get_active_hand()

	if(!item || (item.flags & NODROP))
		return

	if (istype(item, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = item
		item = G.throw() //throw the person instead of the grab
		if(ismob(item))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				var/mob/M = item
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been thrown by [usr.name] ([usr.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				msg_admin_attack("[usr.name] ([usr.ckey])[isAntag(usr) ? "(ANTAG)" : ""] has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>)")

				if(!iscarbon(usr))
					M.LAssailant = null
				else
					M.LAssailant = usr

	if(!item)
		return //Grab processing has a chance of returning null
	if(!ismob(item)) //Honk mobs don't have a dropped() proc honk
		unEquip(item)
	update_icons()

	if (istype(usr, /mob/living/carbon)) //Check if a carbon mob is throwing. Modify/remove this line as required.
		item.loc = usr.loc
		if(src.client)
			src.client.screen -= item
		if(istype(item, /obj/item))
			item:dropped(src) // let it know it's been dropped

	//actually throw it!
	if (item)
		item.layer = initial(item.layer)
		src.visible_message("\red [src] has thrown [item].")

		if(!src.lastarea)
			src.lastarea = get_area(src.loc)
		if((istype(src.loc, /turf/space)) || (src.lastarea.has_gravity == 0))
			src.inertia_dir = get_dir(target, src)
			step(src, inertia_dir)


/*
		if(istype(src.loc, /turf/space) || (src.flags & NOGRAV)) //they're in space, move em one space in the opposite direction
			src.inertia_dir = get_dir(target, src)
			step(src, inertia_dir)
*/


		item.throw_at(target, item.throw_range, item.throw_speed, src)
/*
/mob/living/carbon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	src.IgniteMob()
	bodytemperature = max(bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT+10)
*/
/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && ! istype(buckled, /obj/structure/stool/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if (handcuffed)
		return 1
	return

/mob/living/carbon/unEquip(obj/item/I) //THIS PROC DID NOT CALL ..()
	. = ..() //Sets the default return value to what the parent returns.
	if(!. || !I) //We don't want to set anything to null if the parent returned 0.
		return

	if(I == back)
		back = null
		update_inv_back(0)
	else if(I == wear_mask)
		if(istype(src, /mob/living/carbon/human)) //If we don't do this hair won't be properly rebuilt.
			return
		wear_mask = null
		update_inv_wear_mask(0)
	else if(I == handcuffed)
		handcuffed = null
		update_inv_handcuffed(1)
	else if(I == legcuffed)
		legcuffed = null
		update_inv_legcuffed(1)

/mob/living/carbon/proc/get_temperature(var/datum/gas_mixture/environment)
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

/mob/living/carbon/show_inv(mob/living/carbon/user as mob)
	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask && !(wear_mask.flags & ABSTRACT)) ? wear_mask : "Nothing"]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand && !(l_hand.flags & ABSTRACT)) ? l_hand  : "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand && !(r_hand.flags & ABSTRACT)) ? r_hand : "Nothing"]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR>[(handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob\ref[src];size=325x500"))
	onclose(user, "mob\ref[src]")
	return

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(var/method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^


//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

	set category = "Alien"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(B && B.host_brain)
		src << "\red <B>You withdraw your probosci, releasing control of [B.host_brain]</B>"

		B.detatch()

		verbs -= /mob/living/carbon/proc/release_control
		verbs -= /mob/living/carbon/proc/punish_host
		verbs -= /mob/living/carbon/proc/spawn_larvae

	else
		src << "\red <B>ERROR NO BORER OR BRAINMOB DETECTED IN THIS MOB, THIS IS A BUG !</B>"

//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
	set category = "Alien"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain.ckey)
		src << "\red <B>You send a punishing spike of psychic agony lancing into your host's brain.</B>"
		B.host_brain << "\red <B><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></B>"

//Check for brain worms in head.
/mob/proc/has_brain_worms()

	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			return I

	return 0

/mob/living/carbon/proc/spawn_larvae()
	set category = "Alien"
	set name = "Reproduce (100)"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.chemicals >= 100)
		src << "\red <B>Your host twitches and quivers as you rapdly excrete several larvae from your sluglike body.</B>"
		visible_message("\red <B>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</B>")
		B.chemicals -= 100

		new /obj/effect/decal/cleanable/vomit(get_turf(src))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		new /mob/living/simple_animal/borer(get_turf(src))

	else
		src << "You do not have enough chemicals stored to reproduce."
		return

/mob/living/carbon/proc/canBeHandcuffed()
	return 0

/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))