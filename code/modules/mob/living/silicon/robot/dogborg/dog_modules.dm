/obj/item/weapon/dogborg/jaws/big
	name = "combat jaws"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "jaws"
	desc = "The jaws of the law."
	flags = CONDUCT
	force = 10
	throwforce = 0
	hitsound = 'sound/weapons/bite.ogg'
	attack_verb = list("chomped", "bit", "ripped", "mauled", "enforced")
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/dogborg/jaws/sec
	name = "vice jaws"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "jaws"
	desc = "The jaws of the law."
	flags = CONDUCT
	force = 10
	damtype = STAMINA
	throwforce = 0
	hitsound = 'sound/weapons/bite.ogg'
	attack_verb = list("chomped", "bit", "ripped", "mauled", "enforced")
	w_class = WEIGHT_CLASS_NORMAL


/obj/item/weapon/dogborg/jaws/sec/afterattack(mob/living/carbon/human/target, mob/living/silicon/user, proximity)

	if(..() || !ishuman(target))//if it gets caught or the target can't be cuffed,
		return//abort
	var/mob/living/carbon/human/C = target
	if(!C.legcuffed)
		user.changeNext_move(CLICK_CD_MELEE)
		visible_message("<span class='danger'>[src] latches onto [C] ankles dispensing an energy bola!</span>")
		C.legcuffed = new /obj/item/weapon/restraints/legcuffs/bola/energy(C)
		C.update_inv_legcuffed()
		feedback_add_details("ankle bit","B")
		to_chat(C, "<span class='userdanger'>[src] bites your ankles dispensing an energy bola!</span>")
		C.Weaken(1)

/obj/item/weapon/dogborg/jaws/small
	name = "puppy jaws"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "smalljaws"
	desc = "The jaws of a small dog."
	flags = CONDUCT
	force = 5
	throwforce = 0
	hitsound = 'sound/weapons/bite.ogg'
	attack_verb = list("nibbled", "bit", "gnawed", "chomped", "nommed")
	w_class = WEIGHT_CLASS_NORMAL

	var/emagged = 0

/obj/item/weapon/dogborg/jaws/small/attack_self(mob/living/silicon/robot/R)
	if(!istype(R) || !R.emagged)
		return

	emagged = !emagged
	if(emagged)
		name = "combat jaws"
		icon_state = "jaws"
		desc = "The jaws of the law."
		flags = CONDUCT
		force = 10
		attack_verb = list("chomped", "bit", "ripped", "mauled", "enforced")
	else
		name = "puppy jaws"
		icon_state = "smalljaws"
		desc = "The jaws of a small dog."
		flags = CONDUCT
		force = 5
		attack_verb = list("nibbled", "bit", "gnawed", "chomped", "nommed")
	update_icon()

//Boop
/obj/item/device/dogborg/boop_module
	name = "scent module"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "nose"
	desc = "The SCENT module, a simple reagent and atmosphere sniffer."
	flags = CONDUCT | NOBLUDGEON
	force = 0
	throwforce = 0
	attack_verb = list("nosed", "booped")
	w_class = WEIGHT_CLASS_TINY

/obj/item/device/dogborg/boop_module/attack_self(mob/user)
	if(!isturf(user.loc))
		return

	var/datum/gas_mixture/environment = user.loc.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='notice'>[user] sniffs the air.</span>", "<span class='notice'>You sniff the air...</span>")

	to_chat(user, "<span class='notice'><B>Smells like:</B></span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(user, "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>")
	else
		to_chat(user, "<span class='warning'>Pressure: [round(pressure,0.1)] kPa</span>")

	if(total_moles)
		var/o2_concentration = environment.oxygen/total_moles
		var/n2_concentration = environment.nitrogen/total_moles
		var/co2_concentration = environment.carbon_dioxide/total_moles
		var/plasma_concentration = environment.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		if(abs(n2_concentration - N2STANDARD) < 20)
			to_chat(src, "<span class='notice'>Nitrogen: [round(n2_concentration*100)]% ([round(environment.nitrogen,0.01)] moles)</span>")
		else
			to_chat(src, "<span class='warning'>Nitrogen: [round(n2_concentration*100)]% ([round(environment.nitrogen,0.01)] moles)</span>")

		if(abs(o2_concentration - O2STANDARD) < 2)
			to_chat(src, "<span class='notice'>Oxygen: [round(o2_concentration*100)]% ([round(environment.oxygen,0.01)] moles)</span>")
		else
			to_chat(src, "<span class='warning'>Oxygen: [round(o2_concentration*100)]% ([round(environment.oxygen,0.01)] moles)</span>")

		if(co2_concentration > 0.01)
			to_chat(src, "<span class='warning'>CO2: [round(co2_concentration*100)]% ([round(environment.carbon_dioxide,0.01)] moles)</span>")
		else
			to_chat(src, "<span class='notice'>CO2: [round(co2_concentration*100)]% ([round(environment.carbon_dioxide,0.01)] moles)</span>")

		if(plasma_concentration > 0.01)
			to_chat(src, "<span class='warning'>Plasma: [round(plasma_concentration*100)]% ([round(environment.toxins,0.01)] moles)</span>")

		if(unknown_concentration > 0.01)
			to_chat(src, "<span class='warning'>Unknown: [round(unknown_concentration*100)]% ([round(unknown_concentration*total_moles,0.01)] moles)</span>")

		to_chat(src, "<span class='notice'>Temperature: [round(environment.temperature-T0C,0.1)]&deg;C</span>")
		to_chat(src, "<span class='notice'>Heat Capacity: [round(environment.heat_capacity(),0.1)]</span>")

/obj/item/device/dogborg/boop_module/afterattack(obj/O, mob/user, proximity)
	if(!istype(O) || !proximity)
		return
	if(user.incapacitated())
		return

	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='notice'>[user] sniffs at [O].</span>", "<span class='notice'>You sniff [O]...</span>")

	if(!isnull(O.reagents))
		var/dat = ""
		if(O.reagents.reagent_list.len > 0)
			for(var/datum/reagent/R in O.reagents.reagent_list)
				dat += "\n \t <span class='notice'>[R]</span>"

		if(dat)
			to_chat(user, "<span class='notice'>Your BOOP module indicates: [dat]</span>")
		else
			to_chat(user, "<span class='notice'>No active chemical agents smelled in [O].</span>")
	else
		to_chat(user, "<span class='notice'>No significant chemical agents smelled in [O].</span>")

/obj/item/device/dogborg/boop_module/sec //no report printing for this..just relay results.
	name = "forensic module"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "nose"
	desc = "The forensic module, a basic forensic module."
	flags = CONDUCT | NOBLUDGEON
	force = 0
	throwforce = 0
	attack_verb = list("nosed", "booped")
	w_class = WEIGHT_CLASS_TINY
	var/scanning = 0

/obj/item/device/dogborg/boop_module/sec/afterattack(obj/O, mob/user, proximity)
	scan(O, user)

/obj/item/device/dogborg/boop_module/sec/proc/scan(var/atom/A, var/mob/user)

	if(!scanning)
		// Can remotely scan objects and mobs.
		if(!in_range(A, user) && !(A in view(world.view, user)))
			return
		if(loc != user)
			return

		scanning = 1

		user.changeNext_move(CLICK_CD_MELEE)
		user.visible_message("<span class='notice'>[user] sniffs at [A].</span>", "<span class='notice'>You sniff [A]...</span>")


		// GATHER INFORMATION

		//Make our lists
		var/list/fingerprints = list()
		var/list/blood = list()
		var/list/fibers = list()
		var/list/reagents = list()

		var/target_name = A.name

		// Start gathering

		if(A.blood_DNA && A.blood_DNA.len)
			blood = A.blood_DNA.Copy()

		if(A.suit_fibers && A.suit_fibers.len)
			fibers = A.suit_fibers.Copy()

		if(ishuman(A))

			var/mob/living/carbon/human/H = A
			if(istype(H.dna, /datum/dna) && !H.gloves)
				fingerprints += md5(H.dna.uni_identity)

		else if(!ismob(A))

			if(A.fingerprints && A.fingerprints.len)
				fingerprints = A.fingerprints.Copy()

			// Only get reagents from non-mobs.
			if(A.reagents && A.reagents.reagent_list.len)

				for(var/datum/reagent/R in A.reagents.reagent_list)
					reagents[R.name] = R.volume

					// Get blood data from the blood reagent.
					if(istype(R, /datum/reagent/blood))

						if(R.data["blood_DNA"] && R.data["blood_type"])
							var/blood_DNA = R.data["blood_DNA"]
							var/blood_type = R.data["blood_type"]
							blood[blood_DNA] = blood_type

		// We gathered everything. Create a fork and slowly display the results to the holder of the scanner.

		spawn(0)

			var/found_something = 0

			// Fingerprints
			if(fingerprints && fingerprints.len)
				sleep(30)
				to_chat(user, "<span class='info'><B>Prints:</B></span>")
				for(var/finger in fingerprints)
					to_chat(user, "[finger]")
				found_something = 1

			// Blood
			if(blood && blood.len)
				sleep(30)
				to_chat(user, "<span class='info'><B>Blood:</B></span>")
				found_something = 1
				for(var/B in blood)
					to_chat(user, "Type: <font color='red'>[blood[B]]</font> DNA: <font color='red'>[B]</font>")

			//Fibers
			if(fibers && fibers.len)
				sleep(30)
				to_chat(user, "<span class='info'><B>Fibers:</B></span>")
				for(var/fiber in fibers)
					to_chat(user, "[fiber]")
				found_something = 1

			//Reagents
			if(reagents && reagents.len)
				sleep(30)
				to_chat(user, "<span class='info'><B>Reagents:</B></span>")
				for(var/R in reagents)
					to_chat(user, "Reagent: <font color='red'>[R]</font> Volume: <font color='red'>[reagents[R]]</font>")
				found_something = 1

			// Get a new user
			var/mob/holder = null
			if(ismob(src.loc))
				holder = src.loc

			if(!found_something)
				if(holder)
					to_chat(holder, "<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on \the [target_name]!</span>")
			else
				if(holder)
					to_chat(holder, "<span class='notice'>You finish scanning \the [target_name].</span>")

			scanning = 0
			return

//Tongue stuff
/obj/item/device/dogborg/tongue
	name = "synthetic tongue"
	desc = "Useful for cleaning mess off the floor before affectionally licking the crew members in the face with much static and metal."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "synthtongue"
	hitsound = 'sound/effects/attackblob.ogg'
	flags = NOBLUDGEON
	discrete = TRUE
	var/emagged = 0

/obj/item/device/dogborg/tongue/attack_self(var/mob/living/silicon/robot/R)
	if(!istype(R))
		return

	if(R.emagged)
		emagged = !emagged
		if(emagged)
			name = "hacked tongue of doom"
			desc = "Your tongue has been upgraded successfully. Congratulations."
			icon_state = "syndietongue"
		else
			name = "synthetic tongue"
			desc = "Useful for cleaning mess off the floor before affectionally licking the crew members in the face face with much static and metal"
			icon_state = "synthtongue"
		update_icon()

/obj/item/device/dogborg/tongue/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	user.changeNext_move(CLICK_CD_MELEE)
	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='warning'>You need to take [target] off before cleaning it!</span>")

	else if(istype(target,/obj/effect/decal/cleanable))
		user.visible_message("[user] begins to lick off [target].", "<span class='notice'>You begin to lick off [target]...</span>")
		if(do_after(user, 50, target = target))
			to_chat(user, "<span class='notice'>You finish licking off [target].</span>")
			qdel(target)
			var/mob/living/silicon/robot/R = user
			R.cell.charge = R.cell.charge + 50

	else if(istype(target,/obj/item))
		if(istype(target,/obj/item/trash))
			user.visible_message("[user] nibbles away at [target].", "<span class='notice'>You begin to nibble away at [target]...</span>")
			if(do_after(user, 50, target = get_turf(target)))
				user.visible_message("[user] finishes eating [target].", "<span class='notice'>You finish eating [target].</span>")
				to_chat(user, "<span class='notice'>You finish off [target].</span>")
				qdel(target)
				var/mob/living/silicon/robot/R = user
				R.cell.charge = R.cell.charge + 250
			return

		if(istype(target, /obj/item/weapon/stock_parts/cell))
			user.visible_message("[user] begins cramming [target] down its throat.", "<span class='notice'>You begin cramming [target] down your throat...</span>")
			if(do_after(user, 50, target = get_turf(target)))
				user.visible_message("[user] finishes gulping down [target].", "<span class='notice'>You finish swallowing [target].</span>")
				to_chat(user, "<span class='notice'>You finish off [target], and gain some charge!</span>")
				var/mob/living/silicon/robot/R = user
				var/obj/item/weapon/stock_parts/cell/C = target
				R.cell.charge = R.cell.charge + (C.maxcharge / 3)
				qdel(target)
			return

		user.visible_message("[user] begins to lick [target] clean...", "<span class='notice'>You begin to lick [target] clean...</span>")
		if(do_after(user, 50, target = get_turf(target)))
			to_chat(user, "<span class='notice'>You clean [target].</span>")
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			target.clean_blood()

	else if(ishuman(target))
		if(emagged)
			var/mob/living/silicon/robot/R = user
			var/mob/living/L = target
			if(R.cell.charge <= 666)
				return
			L.Stun(4) // normal stunbaton is force 7 gimme a break good sir!
			L.Weaken(4)
			L.apply_effect(STUTTER, 4)
			L.visible_message("<span class='danger'>[user] has shocked [L] with its tongue!</span>", \
								"<span class='userdanger'>[user] has shocked you with its tongue! You can feel the betrayal.</span>")
			playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			R.cell.charge = R.cell.charge - 666
		else
			user.visible_message("<span class='notice'>\the [user] affectionally licks all over [target]'s face!</span>", "<span class='notice'>You affectionally lick all over [target]'s face!</span>")
			playsound(loc, 'sound/effects/attackblob.ogg', 50, 1)
			return

	else
		user.visible_message("[user] begins to lick [target] clean...", "<span class='notice'>You begin to lick [target] clean...</span>")
		if(do_after(user, 50, target = get_turf(target)))
			to_chat(user, "<span class='notice'>You clean [target].</span>")
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			target.clean_blood()

/obj/item/weapon/dogborg/swordtail
	name = "sword tail"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "swordtail"
	desc = "A glowing pink dagger normally attached to the end of a cyborg's tail. It appears to be extremely sharp."
	flags = CONDUCT
	force = 20 //Takes 5 hits to 100-0
	sharp = 1
	edge = 1
	throwforce = 0 //This shouldn't be thrown in the first place.
	hitsound = 'sound/weapons/blade1.ogg'
	attack_verb = list("slashed", "stabbed", "jabbed", "mauled", "sliced")
	w_class = WEIGHT_CLASS_NORMAL