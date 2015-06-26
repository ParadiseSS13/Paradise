////////////////////////////////////////////////////////////////////////////////
/// Med Borg Items
////////////////////////////////////////////////////////////////////////////////
//Multiscanner item. Combines the functionality of the Health Analyzer, Antibody Analyzer and Advanced Reagent Scanner
/obj/item/device/med_scanner/robot
	name = "Med Scanner"
	icon_state = "health"
	item_state = "healthanalyzer"
	desc = "An advanced integrated scanning device designed for medical analysis and diagnostics. Can quickly switch between Health, Reagent, Mass Spectrometer and Antibody Analyzer modes. Currently set to Health Analyzer mode."
	var mode = 1
	var scanner_upgrade = 1
	var/list/scanners = list()

	New() //1 = Robotics, 2 = Reagent, 3 = Slime
		scanners += new /obj/item/device/healthanalyzer/advanced(src)
		scanners += new /obj/item/device/reagent_scanner/adv(src)
		scanners += new /obj/item/device/antibody_scanner(src)


	attack_self(mob/user as mob)
		switch(mode) //1 = Robotics, 2 = Reagent, 3 = Slime
			if(3)//Health Analyzer Mode
				name = "Med Scanner (Health Analyzer Mode)"
				icon_state = "health"
				user << "\blue Med Scanner set to Health Analyzer Mode."
				desc = "An advanced integrated scanning device designed for medical use. Can quickly switch between Health, Reagent and Antibody Analyzer modes. Currently set to Health Analyzer mode."
				mode = 1
			if(1)//Reagent Analyzer Mode
				name = "Med Scanner (Reagent Analyzer Mode)"
				icon_state = "adv_spectrometer"
				user << "\blue Med Scanner set to Reagent Analyzer mode."
				desc = "An advanced integrated scanning device designed for medical use. Can quickly switch between Health, Reagent and Antibody Analyzer modes.  Currently set to Reagent Analyzer mode"
				mode = 2
			if(2)//Antibody Analyzer Mode
				name = "Med Scanner (Antibody Analyzer Mode)"
				icon_state = "antibody"
				user << "\blue Med Scanner set to Antibody Analyzer mode."
				desc = "An advanced integrated scanning device designed for medical use. Can quickly switch between Health, Reagent and Antibody Analyzer modes. Currently set to Antibody Analyzer mode."
				mode = 3
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)

	attack(mob/target as mob, mob/user as mob)
		var obj/item/device/S = scanners[mode]
		S.attack(target, user)

	afterattack(mob/target as mob, mob/user as mob)
		var obj/item/device/S = scanners[mode]
		S.afterattack(target, user)


/obj/item/weapon/cyborg/bodybag_containment_unit
	name = "Bodybag Containment Unit"
	desc = "An integrated bodybag containment and deployment unit. Can store up to ten bodybags and cryobags in total."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	var/bags_max = 10
	var/bodybags_stored = 10
	var/cryobags_stored = 0
	var/bags_stored = 10
	var/mode = "bodybag"

/obj/item/weapon/cyborg/bodybag_containment_unit/attack_self(mob/living/user as mob)
	if(!bags_stored)
		playsound(user, 'sound/weapons/emptyclick.ogg', 50, 0)
		user << "<span class='notice'>You have no bags stored.</span>"

	if(mode == "stasis bag")
		if(!cryobags_stored)
			playsound(user, 'sound/weapons/emptyclick.ogg', 50, 0)
			user << "<span class='notice'>You have no [mode]s stored.</span>"
			return
		new /obj/structure/closet/body_bag/cryobag(user.loc)
		cryobags_stored -= 1

	else if(mode == "bodybag")
		if(!bodybags_stored)
			playsound(user, 'sound/weapons/emptyclick.ogg', 50, 0)
			user << "<span class='notice'>You have no [mode]s stored.</span>"
			return
		new /obj/structure/closet/body_bag(user.loc)
		bodybags_stored -= 1

	bags_stored = bodybags_stored + cryobags_stored
	playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
	user << "<span class='notice'>You deploy a [mode]. You currently have [bodybags_stored] bodybag(s) stored and [cryobags_stored] stasisbag(s) stored.</span>"
	return


/obj/item/weapon/cyborg/bodybag_containment_unit/verb/deploy_mode()

	set name = "Set Bodybag Deployment Mode"
	set desc = "Allows you to set the Bodybag Containment Unit to deploy cryobags or bodybags."
	set category = "Robot Commands"

	var modeinput = input("Which type of bag should the BCU deploy?") in list("stasis bag","bodybag")
	if(modeinput)
		mode = modeinput
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
		if(mode == "stasis bag")
			icon_state = "bodybag_store_cryo"
		else if(mode == "bodybag")
			icon_state = "bodybag_closed"
		src.loc << "<span class='notice'>[src] set to [mode] deployment mode.</span>"

/obj/item/weapon/cyborg/bodybag_containment_unit/examine(mob/user as mob)
	if(..(src.loc == user))
		user << "The [src] currently holds [bodybags_stored] bodybags and [cryobags_stored] cryobags. It is currently set to deploy [mode]s."

/obj/item/weapon/reagent_containers/robot/chemvac
	name = "ChemVac"
	desc = "An industrial grade chemical distribution and reallocation device."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "chemvac"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(5,10,20,25,50,100)
	volume = 100
	var/mode = 1 //Initalized to draw reagents
	update_icon()

	attack_self(mob/user as mob)

		switch(mode)
			if(0)//Dispense Reagents
				playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
				user << "\blue Your ChemVac has been set to draw reagents."
				mode = 1
			if(1)//Draw Reagents
				playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
				user << "\blue Your ChemVac has been set to dispense reagents."
				mode = 0
		update_icon()

	afterattack(obj/target, mob/user , flag)
		switch(mode)
			if(0)//Draw Reagents

				if(!target.reagents) return

				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					user << "\red [target] is full."
					return

				if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/clothing/mask/cigarette)) //You can inject humans and food but you cant remove the shit.
					user << "\red You cannot directly fill this object."
					return

				var/trans = 0

				if(ismob(target))
					if(istype(target , /mob/living/carbon/human))
						var/mob/living/carbon/human/victim = target

						var/obj/item/safe_thing = null
						if( victim.wear_mask )
							if ( victim.wear_mask.flags & MASKCOVERSEYES )
								safe_thing = victim.wear_mask
						if( victim.head )
							if ( victim.head.flags & MASKCOVERSEYES )
								safe_thing = victim.head
						if(victim.glasses)
							if ( !safe_thing )
								safe_thing = victim.glasses

						if(safe_thing)
							if(!safe_thing.reagents)
								safe_thing.create_reagents(100)
							trans = src.reagents.trans_to(safe_thing, amount_per_transfer_from_this)

							for(var/mob/O in viewers(world.view, user))
								O.show_message(text("\red <B>[] tries to squirt something into []'s eyes, but fails!</B>", user, target), 1)
							spawn(5)
								src.reagents.reaction(safe_thing, TOUCH)



							user << "\blue You transfer [trans] units of the solution."
							if (src.reagents.total_volume<=0)
								icon_state = "[initial(icon_state)]"
							return


					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red <B>[] squirts something into []'s eyes!</B>", user, target), 1)
					src.reagents.reaction(target, TOUCH)

					var/mob/living/M = target

					var/list/injected = list()
					for(var/datum/reagent/R in src.reagents.reagent_list)
						injected += R.name
					var/contained = english_list(injected)
					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been squirted with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
					user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to squirt [M.name] ([M.key]). Reagents: [contained]</font>")
					if(M.ckey)
						msg_admin_attack("[user.name] ([user.ckey])[isAntag(user) ? "(ANTAG)" : ""] squirted [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
					if(!iscarbon(user))
						M.LAssailant = null
					else
						M.LAssailant = user

				// /vg/: Logging transfers of bad things
				if(isobj(target))
					if(target.reagents_to_log.len)
						var/list/badshit=list()
						for(var/bad_reagent in target.reagents_to_log)
							if(reagents.has_reagent(bad_reagent))
								badshit += reagents_to_log[bad_reagent]
						if(badshit.len)
							var/hl="\red <b>([english_list(badshit)])</b> \black"
							message_admins("[user.name] ([user.ckey]) added [reagents.get_reagent_ids(1)] to \a [target] with [src].[hl] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
							log_game("[user.name] ([user.ckey]) added [reagents.get_reagent_ids(1)] to \a [target] with [src].")

				trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
				user << "\blue You transfer [trans] units of the solution."
				if (src.reagents.total_volume<src.reagents.maximum_volume)
					icon_state = "[initial(icon_state)]"

			else if (1)//Draw Reagents

				if(src.reagents.total_volume >= src.reagents.maximum_volume)
					user << "\red Your ChemVac is full!"
					return
				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
					user << "\red You cannot directly remove reagents from [target]."
					return

				if(!target.reagents.total_volume)
					user << "\red [target] is empty."
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

				user << "\blue You fill the [src] with [trans] units of the solution."

				if(src.reagents.total_volume >= src.reagents.maximum_volume)
					icon_state = "[initial(icon_state)][1]"

			return

	update_icon()
		overlays.Cut()
		if(ismob(loc))
			var/injoverlay
			switch(mode)
				if (0)
					injoverlay = "inject"
				if (1)
					injoverlay = "draw"
			overlays += injoverlay


/obj/item/weapon/robot/medical/nanopastesynth
	name = "Nanopaste Synthesizer"
	desc = "Synthesizes nanites that repair damage to robotic machinery and actuate your autorepair systems. Consumes 100 charge per use."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	var/usecost = 100
	var/cooldown = 0
	var/cooldown_time = 50

/obj/item/weapon/robot/medical/nanopastesynth/attack(mob/living/M as mob, mob/user as mob)
	if (!istype(M) || !istype(user))
		return 0
	if(cooldown && user == M)
		playsound(user, 'sound/machines/buzz-two.ogg', 50, 0)
		user << "<span class='notice'>Your auto-repair system is recharging.</span>"
		return
	var/mob/living/silicon/robot/U = user
	if(U.cell.charge < usecost)
		user << "<span class='notice'>Your energy levels are inadequate to use this module.</span>"
		return
	if (istype(M,/mob/living/silicon/robot))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if (R.getBruteLoss() || R.getFireLoss() )
			R.adjustBruteLoss(-15)
			R.adjustFireLoss(-15)
			R.updatehealth()
			U.cell.use(usecost)//Deducts charge.
			user.visible_message("<span class='notice'>\The [user] applied some [src] at [R]'s damaged areas.</span>",\
				"<span class='notice'>You apply some [src] at [R]'s damaged areas.</span>")
			//Cooldown if using it on yourself.
			if(user == M)
				cooldown = 1
				spawn(cooldown_time)
					user << "<span class='notice'>Your auto-repair system has recharged.</span>"
					cooldown = 0
			return
		else
			user << "<span class='notice'>All [R]'s systems are nominal.</span>"

	if (istype(M,/mob/living/carbon/human))		//Repairing robolimbs
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.get_organ(user.zone_sel.selecting)

		if(can_operate(H))
			if (do_surgery(H,user,src))
				return

		if (S && (S.status & ORGAN_ROBOT))
			if(S.get_damage())
				S.heal_damage(15, 15, robo_repair = 1)
				H.updatehealth()
				U.cell.use(usecost)//Deducts charge.
				user.visible_message("<span class='notice'>\The [user] applies some nanite paste at[user != M ? " \the [M]'s" : " \the"][S.name] with \the [src].</span>",\
				"<span class='notice'>You apply some nanite paste at [user == M ? "your" : "[M]'s"] [S.name].</span>")
				return
			else
				user << "<span class='notice'>Nothing to fix here.</span>"
		else
			user << "<span class='notice'>[src] won't work on that.</span>"

/obj/item/weapon/robot/medical/multisynth
	name = "Med Synthesizer"
	icon = 'icons/obj/items.dmi'
	icon_state = "traumakit"
	desc = "An advanced integrated medical supply synthesis device. Can quickly switch between three different modes, creating biogel for trauma, regenerative membranes for burns, and splints for fractures."
	var mode = 1
	var scanner_upgrade = 1
	var/list/scanners = list()
	var/cost = 100

	New() //1 = Robotics, 2 = Reagent, 3 = Slime
		scanners += new /obj/item/weapon/robot/medical/kits/brutesynth(src)
		scanners += new /obj/item/weapon/robot/medical/kits/burnsynth(src)
		scanners += new /obj/item/weapon/robot/medical/kits/splintsynth(src)

	attack_self(mob/user as mob)
		switch(mode) //1 = Robotics, 2 = Reagent, 3 = Slime
			if(3)//Trauma Treatment Mode
				playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
				name = "Med Synthesizer (Trauma Mode)"
				icon_state = "traumakit"
				user << "\blue Med Synthesizer set to Trauma Treatment mode."
				desc = "An advanced integrated medical supply synthesis device. Can quickly switch between three different modes, sythesizing bioglue for trauma, regenerative membranes for burns, and splints for fractures. It is currently set to Trauma Treatment mode. Costs [cost] charge to use."
				mode = 1
			if(1)//Burn Treatment Mode
				playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
				name = "Med Synthesizer (Burn Mode)"
				icon_state = "burnkit"
				user << "\blue Med Synthesizer set to Burn Treatment mode."
				desc = "An advanced integrated medical supply synthesis device. Can quickly switch between three different modes, sythesizing bioglue for trauma, regenerative membranes for burns, and splints for fractures. It is currently set to Burn Treatment mode. Costs [cost] charge to use."
				mode = 2
			if(2)//Splint Mode
				playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
				name = "Med Synthesizer (Splint Mode)"
				icon_state = "splint"
				user << "\blue Med Synthesizer set to Splint Application mode."
				desc = "An advanced integrated medical supply synthesis device. Can quickly switch between three different modes, sythesizing bioglue for trauma, regenerative membranes for burns, and splints for fractures. It is currently set to Splint Application mode. Costs [cost] charge to use."
				mode = 3

	attack(mob/target as mob, mob/user as mob)
		var obj/item/device/S = scanners[mode]
		S.attack(target, user)

	afterattack(mob/target as mob, mob/user as mob)
		var obj/item/device/S = scanners[mode]
		S.afterattack(target, user)

//Base Item for Medical Cyborg Synthesizer
/obj/item/weapon/robot/medical/kits
	name = "medical pack"
	icon = 'icons/obj/items.dmi'
	var/heal_brute = 0
	var/heal_burn = 0
	var/usecost = 100

/obj/item/weapon/robot/medical/kits/attack(mob/living/carbon/M as mob, mob/user as mob)
	if (!istype(M))
		user << "<span class='danger'>\The [src] cannot be applied to [M]!</span>"
		return 1
	var/mob/living/silicon/robot/U = user
	if(U.cell.charge < usecost) //Check power levels.
		user << "<span class='notice'>Your energy levels are inadequate to use this module.</span>"
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(isliving(M))
			if(!M.can_inject(user, 1))
				return 1

		if(!affecting)
			user << "<span class='danger'>That limb is missing!</span>"
			return 1

		if(affecting.status & ORGAN_ROBOT)
			user << "<span class='danger'>This can't be used on a robotic limb.</span>"
			return 1


		H.UpdateDamageIcon()

	else
		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))
		user.visible_message("<span class='notice'>[M] has been applied with [src] by [user].</span>","<span class='notice'>You apply \the [src] to [M].</span>")
		U.cell.use(usecost)//Deducts charge.

	M.updatehealth()

//Brute Synthesizer for Medical Cyborg
/obj/item/weapon/robot/medical/kits/brutesynth
	name = "Trauma Treatment Synthesizer"
	desc = "Synthesizes bioglue for utilization in burn treatment. Consumes 100 charge per use."
	icon_state = "traumakit"
	heal_brute = 12
	usecost = 100

/obj/item/weapon/robot/medical/kits/brutesynth/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1
	var/mob/living/silicon/robot/U = user
	if(U.cell.charge < usecost) //Check power levels.
		user << "<span class='notice'>Your energy levels are inadequate to use this module.</span>"
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			var/bandaged = affecting.bandage()
			var/disinfected = affecting.disinfect()
			if(!(bandaged || disinfected))
				user << "\red The wounds on [M]'s [affecting.name] have already been treated."
				return 1
			else
				for (var/datum/wound/W in affecting.wounds)
					if (W.internal)
						continue
					if (W.current_stage <= W.max_bleeding_stage)
						user.visible_message( 	"\blue [user] cleans \the [W.desc] on [M]'s [affecting.name] and seals the edges with bioglue.", \
										"\blue You clean and seal \the [W.desc] on [M]'s [affecting.name]." )
						//H.add_side_effect("Itch")
					else if (istype(W,/datum/wound/bruise))
						user.visible_message( 	"\blue [user] places a medicine patch over \the [W.desc] on [M]'s [affecting.name].", \
										"\blue You place a medicine patch over \the [W.desc] on [M]'s [affecting.name]." )
					else
						user.visible_message( 	"\blue [user] smears some bioglue over [W.desc] on [M]'s [affecting.name].", \
										"\blue You smear some bioglue over [W.desc] on [M]'s [affecting.name]." )
				if (bandaged)
					affecting.heal_damage(heal_brute,0)
				U.cell.use(usecost)//Deducts charge.
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>"

//Burn Synthesizer for Medical Cyborg
/obj/item/weapon/robot/medical/kits/burnsynth
	name = "Burn Treatment Synthesizer"
	desc = "Synthesizes regenerative membranes for utilization in burn treatment. Consumes 100 charge per use."
	icon_state = "burnkit"
	heal_burn = 12
	usecost = 100

/obj/item/weapon/robot/medical/kits/burnsynth/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1
	var/mob/living/silicon/robot/U = user
	if(U.cell.charge < usecost) //Check power levels.
		user << "<span class='notice'>Your energy levels are inadequate to use this module.</span>"
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
		if(affecting.open == 0)
			if(!affecting.salve())
				user << "\red The wounds on [M]'s [affecting.name] have already been salved."
				return 1
			else
				user.visible_message( 	"\blue [user] covers the wounds on [M]'s [affecting.name] with regenerative membrane.", \
										"\blue You cover the wounds on [M]'s [affecting.name] with regenerative membrane." )
				affecting.heal_damage(0,heal_burn)
				U.cell.use(usecost)//Deducts charge.
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>"

//Splint Synthesizer for Medical Cyborg
/obj/item/weapon/robot/medical/kits/splintsynth
	name = "Medical Splint Synthesizer"
	desc = "Synthesizes splint casts for utilization in stabilizing fractures. Consumes 100 charge per use."
	icon_state = "splint"
	usecost = 100

/obj/item/weapon/robot/medical/kits/splintsynth/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1
	var/mob/living/silicon/robot/U = user
	if(U.cell.charge < usecost) //Check power levels.
		user << "<span class='notice'>Your energy levels are inadequate to use this module.</span>"
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
		var/limb = affecting.name
		if(!(affecting.limb_name in list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")))
			user << "\red You can't apply a splint there!"
			return
		if(affecting.status & ORGAN_SPLINTED)
			user << "\red [M]'s [limb] is already splinted!"
			return
		if (M != user)
			user.visible_message("\red [user] starts to apply \the [src] to [M]'s [limb].", "\red You start to apply \the [src] to [M]'s [limb].", "\red You hear something being wrapped.")
		else
			if((!user.hand && affecting.limb_name in list("r_arm", "r_hand")) || (user.hand && affecting.limb_name in list("l_arm", "l_hand")))
				user << "\red You can't apply a splint to the arm you're using!"
				return
			user.visible_message("\red [user] starts to apply \the [src] to their [limb].", "\red You start to apply \the [src] to your [limb].", "\red You hear something being wrapped.")
		if(do_after(user, 50))
			if (M != user)
				user.visible_message("\red [user] finishes applying \the [src] to [M]'s [limb].", "\red You finish applying \the [src] to [M]'s [limb].", "\red You hear something being wrapped.")
			else
				if(prob(25))
					user.visible_message("\red [user] successfully applies \the [src] to their [limb].", "\red You successfully apply \the [src] to your [limb].", "\red You hear something being wrapped.")
				else
					user.visible_message("\red [user] fumbles \the [src].", "\red You fumble \the [src].", "\red You hear something being wrapped.")
					return
			affecting.status |= ORGAN_SPLINTED
			U.cell.use(usecost)//Deducts charge.
		return




// A special pen for service droids. Can be toggled to switch between normal writing mode, and paper rename mode
// Allows service droids to rename paper items.

/obj/item/weapon/pen/robopen
	desc = "A black ink printing attachment with a paper naming mode."
	name = "Printing Pen"
	var/mode = 1

/obj/item/weapon/pen/robopen/attack_self(mob/user as mob)

	var/choice = input("Would you like to change colour or mode?") as null|anything in list("Colour","Mode")
	if(!choice) return

	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)

	switch(choice)

		if("Colour")
			var/newcolour = input("Which colour would you like to use?") as null|anything in list("black","blue","red","green","yellow")
			if(newcolour) colour = newcolour

		if("Mode")
			if (mode == 1)
				mode = 2
			else
				mode = 1
			user << "Changed printing mode to '[mode == 2 ? "Rename Paper" : "Write Paper"]'"

	return

// Copied over from paper's rename verb
// see code\modules\paperwork\paper.dm line 62


/obj/item/weapon/pen/robopen/proc/RenamePaper(mob/user as mob,obj/paper as obj)
	if ( !user || !paper )
		return
	var/n_name = input(user, "What would you like to label the paper?", "Paper Labelling", null)  as text
	if ( !user || !paper )
		return

	n_name = copytext(n_name, 1, 32)
	if(( get_dist(user,paper) <= 1  && user.stat == 0))
		paper.name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(user)
	return

//TODO: Add prewritten forms to dispense when you work out a good way to store the strings.
/obj/item/weapon/form_printer
	//name = "paperwork printer"
	name = "paper dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"

/obj/item/weapon/form_printer/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	return

/obj/item/weapon/form_printer/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)

	if(!target || !flag)
		return

	if(istype(target,/obj/structure/table))
		deploy_paper(get_turf(target))

/obj/item/weapon/form_printer/attack_self(mob/user as mob)
	deploy_paper(get_turf(src))

/obj/item/weapon/form_printer/proc/deploy_paper(var/turf/T)
	T.visible_message("\blue \The [src.loc] dispenses a sheet of crisp white paper.")
	new /obj/item/weapon/paper(T)


//Personal shielding for the combat module.
/obj/item/borg/combat/shield
	name = "personal shielding"
	desc = "A powerful experimental module that turns aside or absorbs incoming attacks at the cost of charge."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
	var/shield_level = 0.5 //Percentage of damage absorbed by the shield.

/obj/item/borg/combat/shield/verb/set_shield_level()
	set name = "Set shield level"
	set category = "Object"
	set src in range(0)

	var/N = input("How much damage should the shield absorb?") in list("5","10","25","50","75","100")
	if (N)
		shield_level = text2num(N)/100

/obj/item/borg/combat/mobility
	name = "mobility module"
	desc = "By retracting limbs and tucking in its head, a combat android can roll at high speeds."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"