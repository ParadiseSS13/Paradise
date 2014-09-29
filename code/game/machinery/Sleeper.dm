/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/sleeper/connected = null
	anchored = 1 //About time someone fixed this.
	density = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"

	l_color = "#7BF9FF"
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			SetLuminosity(2)
		else
			SetLuminosity(0)

/obj/machinery/sleep_console/process()
	if(stat & (NOPOWER|BROKEN))
		return
	src.updateUsrDialog()
	return

/obj/machinery/sleep_console/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/sleep_console/New()
	..()
	spawn( 5 )
		if(orient == "RIGHT")
			icon_state = "sleeperconsole-r"
			src.connected = locate(/obj/machinery/sleeper, get_step(src, EAST))
		else
			src.connected = locate(/obj/machinery/sleeper, get_step(src, WEST))

		return
	return

/obj/machinery/sleep_console/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/sleep_console/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/sleep_console/attack_hand(mob/user as mob)
	if(..())
		return
	if (src.connected)
		var/mob/living/occupant = src.connected.occupant
		var/dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
		if (occupant)
			var/t1
			switch(occupant.stat)
				if(0)
					t1 = "Conscious"
				if(1)
					t1 = "<font color='blue'>Unconscious</font>"
				if(2)
					t1 = "<font color='red'>*dead*</font>"
				else
			dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
			if(iscarbon(occupant))
				var/mob/living/carbon/C = occupant
				dat += text("[]\t-Pulse, bpm: []</FONT><BR>", (C.pulse == PULSE_NONE || C.pulse == PULSE_THREADY ? "<font color='red'>" : "<font color='blue'>"), C.get_pulse(GETPULSE_TOOL))
			dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
			dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
			dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
			dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())
			dat += text("<HR>Paralysis Summary %: [] ([] seconds left!)<BR>", occupant.paralysis, round(occupant.paralysis / 4))
			if(occupant.reagents)
				for(var/chemical in connected.available_chemicals)
					dat += "[connected.available_chemicals[chemical]]: [occupant.reagents.get_reagent_amount(chemical)] units<br>"
			dat += "<A href='?src=\ref[src];refresh=1'>Refresh Meter Readings</A><BR>"
			if(src.connected.beaker)
				dat += "<HR><A href='?src=\ref[src];removebeaker=1'>Remove Beaker</A><BR>"
				if(src.connected.filtering)
					dat += "<A href='?src=\ref[src];togglefilter=1'>Stop Dialysis</A><BR>"
					dat += text("Output Beaker has [] units of free space remaining<BR><HR>", src.connected.beaker.reagents.maximum_volume - src.connected.beaker.reagents.total_volume)
				else
					dat += "<HR><A href='?src=\ref[src];togglefilter=1'>Start Dialysis</A><BR>"
					dat += text("Output Beaker has [] units of free space remaining<BR><HR>", src.connected.beaker.reagents.maximum_volume - src.connected.beaker.reagents.total_volume)
			else
				dat += "<HR>No Dialysis Output Beaker is present.<BR><HR>"
			for(var/chemical in connected.available_chemicals)
				dat += "Inject [connected.available_chemicals[chemical]]: "
				for(var/amount in connected.amounts)
					dat += "<a href ='?src=\ref[src];chemical=[chemical];amount=[amount]'>[amount] units</a><br> "
			dat += "<HR><A href='?src=\ref[src];ejectify=1'>Eject Patient</A>"
		else
			dat += "The sleeper is empty."
		dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)
		user << browse(dat, "window=sleeper;size=400x500")
		onclose(user, "sleeper")
	return

/obj/machinery/sleep_console/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.set_machine(src)
		if (href_list["chemical"])
			if (src.connected)
				if (src.connected.occupant)
					if (src.connected.occupant.stat == DEAD)
						usr << "\red \b This person has no life for to preserve anymore. Take them to a department capable of reanimating them."
					else if(src.connected.occupant.health > 0 || href_list["chemical"] == "inaprovaline")
						src.connected.inject_chemical(usr,href_list["chemical"],text2num(href_list["amount"]))
					else
						usr << "\red \b This person is not in good enough condition for sleepers to be effective! Use another means of treatment, such as cryogenics!"
					src.updateUsrDialog()
		if (href_list["refresh"])
			src.updateUsrDialog()
		if (href_list["removebeaker"])
			src.connected.remove_beaker()
			src.updateUsrDialog()
		if (href_list["togglefilter"])
			src.connected.toggle_filter()
			src.updateUsrDialog()
		if (href_list["ejectify"])
			src.connected.eject()
			src.updateUsrDialog()
		src.add_fingerprint(usr)
	return


/obj/machinery/sleep_console/power_change()
	return
	// no change - sleeper works without power (you just can't inject more)







/////////////////////////////////////////
// THE SLEEPER ITSELF
/////////////////////////////////////////

/obj/machinery/sleeper
	name = "Sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/living/carbon/human/occupant = null
	var/available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "paracetamol" = "Paracetamol", "anti_toxin" = "Dylovene", "dexalin" = "Dexalin")
	var/amounts = list(5, 10)
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/filtering = 0

	New()
		..()
		beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large()
		spawn( 5 )
			if(orient == "RIGHT")
				icon_state = "sleeper_0-r"
			return
		return

	process()
		if(filtering > 0)
			if(beaker)
				if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
					src.occupant.vessel.trans_to(beaker, 1)
					for(var/datum/reagent/x in src.occupant.reagents.reagent_list)
//            world << "FILTERING CHEMS"
						src.occupant.reagents.trans_to(beaker, 3)
						src.occupant.vessel.trans_to(beaker, 1)
		src.updateDialog()
		return


	blob_act()
		if(prob(75))
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				A.blob_act()
			del(src)
		return


	attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)
		if(istype(G, /obj/item/weapon/reagent_containers/glass))
			if(!beaker)
				beaker = G
				user.drop_item()
				G.loc = src
				user.visible_message("[user] adds \a [G] to \the [src]!", "You add \a [G] to \the [src]!")
				src.updateUsrDialog()
				return
			else
				user << "\red The sleeper has a beaker already."
				return

		else if(istype(G, /obj/item/weapon/grab))
			if(!ismob(G:affecting))
				return
			if(src.occupant)
				user << "\blue <B>The sleeper is already occupied!</B>"
				return
			for(var/mob/living/carbon/slime/M in range(1,G:affecting))
				if(M.Victim == G:affecting)
					usr << "[G:affecting.name] will not fit into the sleeper because they have a slime latched onto their head."
					return

			visible_message("[user] starts putting [G:affecting:name] into the sleeper.", 3)

			if(do_after(user, 20))
				if(src.occupant)
					user << "\blue <B>The sleeper is already occupied!</B>"
					return
				if(!G || !G:affecting) return
				var/mob/M = G:affecting
				if(M.client)
					M.client.perspective = EYE_PERSPECTIVE
					M.client.eye = src
				M.loc = src
				src.occupant = M
				src.icon_state = "sleeper_1"
				if(orient == "RIGHT")
					icon_state = "sleeper_1-r"

				M << "\blue <b>You feel cool air surround you. You go numb as your senses turn inward.</b>"

				src.add_fingerprint(user)
				del(G)
			return
		return


	ex_act(severity)
		if(filtering)
			toggle_filter()
		switch(severity)
			if(1.0)
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
			if(2.0)
				if(prob(50))
					for(var/atom/movable/A as mob|obj in src)
						A.loc = src.loc
						ex_act(severity)
					qdel(src)
					return
			if(3.0)
				if(prob(25))
					for(var/atom/movable/A as mob|obj in src)
						A.loc = src.loc
						ex_act(severity)
					qdel(src)
					return
		return
	emp_act(severity)
		if(filtering)
			toggle_filter()
		if(stat & (BROKEN|NOPOWER))
			..(severity)
			return
		if(occupant)
			go_out()
		..(severity)

	alter_health(mob/living/M as mob)
		if (M.health > 0)
			if (M.getOxyLoss() >= 10)
				var/amount = max(0.15, 1)
				M.adjustOxyLoss(-amount)
			else
				M.adjustOxyLoss(-12)
			M.updatehealth()
		M.AdjustParalysis(-4)
		M.AdjustWeakened(-4)
		M.AdjustStunned(-4)
		M.Paralyse(1)
		M.Weaken(1)
		M.Stun(1)
		if (M:reagents.get_reagent_amount("inaprovaline") < 5)
			M:reagents.add_reagent("inaprovaline", 5)
		return

	proc/toggle_filter()
		if(filtering)
			filtering = 0
		else
			filtering = 1

	proc/go_out()
		if(filtering)
			toggle_filter()
		if(!src.occupant)
			return
		if(src.occupant.client)
			src.occupant.client.eye = src.occupant.client.mob
			src.occupant.client.perspective = MOB_PERSPECTIVE
		src.occupant.loc = src.loc
		src.occupant = null
		if(orient == "RIGHT")
			icon_state = "sleeper_0-r"
		return


	proc/inject_chemical(mob/living/user as mob, chemical, amount)
		if(src.occupant && src.occupant.reagents)
			if(src.occupant.reagents.get_reagent_amount(chemical) + amount <= 40)
				src.occupant.reagents.add_reagent(chemical, amount)
				user << "Occupant now has [src.occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in his/her bloodstream."
				return
		user << "There's no occupant in the sleeper or the subject rejects the chemicals!"
		return


	proc/check(mob/living/user as mob)
		if(src.occupant)
			user << text("\blue <B>Occupant ([]) Statistics:</B>", src.occupant)
			var/t1
			switch(src.occupant.stat)
				if(0.0)
					t1 = "Conscious"
				if(1.0)
					t1 = "Unconscious"
				if(2.0)
					t1 = "*dead*"
				else
			user << text("[]\t Health %: [] ([])", (src.occupant.health > 50 ? "\blue " : "\red "), src.occupant.health, t1)
			user << text("[]\t -Core Temperature: []&deg;C ([]&deg;F)</FONT><BR>", (src.occupant.bodytemperature > 50 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.bodytemperature-T0C, src.occupant.bodytemperature*1.8-459.67)
			user << text("[]\t -Brute Damage %: []", (src.occupant.getBruteLoss() < 60 ? "\blue " : "\red "), src.occupant.getBruteLoss())
			user << text("[]\t -Respiratory Damage %: []", (src.occupant.getOxyLoss() < 60 ? "\blue " : "\red "), src.occupant.getOxyLoss())
			user << text("[]\t -Toxin Content %: []", (src.occupant.getToxLoss() < 60 ? "\blue " : "\red "), src.occupant.getToxLoss())
			user << text("[]\t -Burn Severity %: []", (src.occupant.getFireLoss() < 60 ? "\blue " : "\red "), src.occupant.getFireLoss())
			user << "\blue Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)"
			user << text("\blue \t [] second\s (if around 1 or 2 the sleeper is keeping them asleep.)", src.occupant.paralysis / 5)
			if(src.beaker)
				user << text("\blue \t Dialysis Output Beaker has [] of free space remaining.", src.beaker.reagents.maximum_volume - src.beaker.reagents.total_volume)
			else
				user << "\blue No Dialysis Output Beaker loaded."
		else
			user << "\blue There is no one inside!"
		return


	verb/eject()
		set name = "Eject Sleeper"
		set category = null
		set src in oview(1)
		if(usr.stat != 0)
			return
		if(orient == "RIGHT")
			icon_state = "sleeper_0-r"
		src.icon_state = "sleeper_0"
		src.go_out()
		add_fingerprint(usr)
		return

	verb/remove_beaker()
		set name = "Remove Beaker"
		set category = null
		set src in oview(1)
		if(usr.stat != 0)
			return
		if(beaker)
			filtering = 0
			beaker.loc = usr.loc
			beaker = null
		add_fingerprint(usr)
		return

/obj/machinery/sleeper/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(occupant)
		user << "\blue <B>The sleeper is already occupied!</B>"
		return
/*	if(isrobot(user))
		if(!istype(user:module, /obj/item/weapon/robot_module/medical))
			user << "<span class='warning'>You do not have the means to do this!</span>"
			return*/
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic())
		user << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			usr << "[L.name] will not fit into the sleeper because they have a slime latched onto their head."
			return
	if(L == user)
		visible_message("[user] starts climbing into the sleeper.", 3)
	else
		visible_message("[user] starts putting [L.name] into the sleeper.", 3)

	if(do_after(user, 20))
		if(src.occupant)
			user << "\blue <B>The sleeper is already occupied!</B>"
			return
		if(!L) return

		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
		L.loc = src
		src.occupant = L
		src.icon_state = "sleeper_1"
		if(orient == "RIGHT")
			icon_state = "sleeper_1-r"
		L << "\blue <b>You feel cool air surround you. You go numb as your senses turn inward.</b>"
		for(var/obj/OO in src)
			OO.loc = src.loc
		src.add_fingerprint(user)
		if(user.pulling == L)
			user.pulling = null
		return
	return

/obj/machinery/sleeper/allow_drop()
	return 0

/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = null
	set src in oview(1)
	if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr)))
		return

	if(src.occupant)
		usr << "\blue <B>The sleeper is already occupied!</B>"
		return
	if(usr.restrained() || usr.stat || usr.weakened || usr.stunned || usr.paralysis || usr.resting) //are you cuffed, dying, lying, stunned or other
		return
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "You're too busy getting your life sucked out of you."
			return
	visible_message("[usr] starts climbing into the sleeper.", 3)
	if(do_after(usr, 20))
		if(src.occupant)
			usr << "\blue <B>The sleeper is already occupied!</B>"
			return
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		src.occupant = usr
		src.icon_state = "sleeper_1"
		if(orient == "RIGHT")
			icon_state = "sleeper_1-r"

		for(var/obj/O in src)
			del(O)
		src.add_fingerprint(usr)
		return
	return