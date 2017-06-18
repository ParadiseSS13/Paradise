//Sleeper
/obj/item/device/dogborg/sleeper
	name = "Medbelly"
	desc = "Equipment for a medical hound. A mounted sleeper that stabilizes patients and can inject reagents in the borg's reserves."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "sleeper"
	w_class = WEIGHT_CLASS_TINY
	flags = NOBLUDGEON
	discrete = TRUE

	var/mob/living/carbon/patient = null
	var/mob/living/silicon/robot/hound = null
	var/inject_amount = 10
	var/min_health = -100
	var/patient_laststat = null
	var/list/injection_chems = list()
	var/show_patient = TRUE

	var/cleaning = 0
	var/list/items_preserved = list()

/obj/item/device/dogborg/sleeper/handle_internal_lifeform(mob/M, breath_volume)
	if(hound)
		. = hound.handle_internal_lifeform(M, breath_volume)
	else
		. = ..()

/obj/item/device/dogborg/sleeper/afterattack(mob/living/carbon/human/target, mob/living/silicon/user, proximity)
	hound = loc
	if(!proximity)
		return
	if(!istype(target) || !istype(user))
		return
	if(target.buckled)
		to_chat(user, "<span class='warning'>The user is buckled and can not be put into your [name].</span>")
		return
	if(patient)
		to_chat(user, "<span class='warning'>Your [name] is already occupied.</span>")
		return
	hound.visible_message("<span class='warning'>[hound] is loading [target] into their [name].</span>",
	"<span class='notice'>You start loading [target] into your [name]...</span>")
	if(do_after(user, 50, target = target))
		if(!hound.Adjacent(target)) // If they moved away, you can't eat them.
			return

		if(patient) // Someone else got in.
			return

		target.forceMove(src)
		target.reset_perspective(src)
		update_patient()
		processing_objects.Add(src)
		user.visible_message("<span class='warning'>[hound]'s medical pod lights up as [target] slips inside into their [name].</span>",
							"<span class='notice'>Your medical pod lights up as [target] slips into your [name]. Life support functions engaged.</span>")
		message_admins("[key_name_admin(hound)] has put [key_name_admin(patient)] in their dogborg sleeper. [ADMIN_FLW(hound)] [ADMIN_JMP(hound)]")
		playsound(hound, 'sound/effects/dognom.ogg', 100, 1)

/obj/item/device/dogborg/sleeper/container_resist(mob/living/L)
	hound.visible_message("<span class='warning'>[L] starts to climb out of [hound]'s [name].</span>")
	if(do_after_visual(L, (1 MINUTES), target = hound ? hound : get_turf(src)))
		hound.visible_message("<span class='danger'>[L] climbs out of [hound]'s [name].</span>")
		go_out(L)

/obj/item/device/dogborg/sleeper/proc/go_out(target)
	hound = loc
	if(length(contents) > 0)
		if(target)
			hound.visible_message("<span class='warning'>[hound] ejects [target] via their ejection port.</span>",
								"<span class='notice'>You eject [target] via your ejection port.</span>")
			if(ishuman(target))
				var/mob/living/carbon/human/person = target
				person.forceMove(get_turf(src))
				person.reset_perspective(null)
			else
				var/obj/T = target
				T.loc = hound.loc
		else
			hound.visible_message("<span class='warning'>[hound] empties out their contents via their ejection port.</span>",
								"<span class='notice'>You empty your contents via your ejection port.</span>")
			for(var/C in contents)
				if(ishuman(C))
					var/mob/living/carbon/human/person = C
					person.forceMove(get_turf(src))
					person.reset_perspective(null)
				else
					var/obj/T = C
					T.loc = hound.loc
		items_preserved.Cut()
		cleaning = 0
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		update_patient()
	else //You clicked eject with nothing in you, let's just reset stuff to be sure.
		items_preserved.Cut()
		cleaning = 0
		update_patient()

/obj/item/device/dogborg/sleeper/proc/drain(var/amt = 3) //Slightly reduced cost (before, it was always injecting inaprov)
	hound.cell.charge = hound.cell.charge - amt

/obj/item/device/dogborg/sleeper/attack_self(mob/user)
	user.set_machine(src)
	interact(user)

/obj/item/device/dogborg/sleeper/interact(mob/user)
	if(!user)
		return 0

	. = ""

	if(length(injection_chems))
		. += "<h3>Injector</h3>"

		if(patient && patient.health > min_health)
			for(var/re in injection_chems)
				var/datum/reagent/C = chemical_reagents_list[re]
				if(C)
					. += "<br><a href='?src=[UID()];inject=[C.id]'>Inject [C]</a>"
		else
			for(var/re in injection_chems)
				var/datum/reagent/C = chemical_reagents_list[re]
				if(C)
					. += "<BR><span class='linkOff'>Inject [C]</span>"

	. += "<h3>[name] Status</h3>"
	. += "<a id='refbutton' href='?src=[UID()];refresh=1'>Refresh</a>"
	. += "<a href='?src=[UID()];eject=1'>Eject All</a>"
	if(!cleaning)
		. += "<a href='?src=[UID()];clean=1'>Self-Clean</A>"
	else
		. += "<span class='linkOff'>Self-Clean</span>"

	. += "<div class='statusDisplay'>"

	//Cleaning and there are still un-preserved items
	if(cleaning && length(contents - items_preserved))
		. += "<span class='bad'><b>Self-cleaning mode.</b> [length(contents - items_preserved)] object(s) remaining.</span><br>"

	//There are no items to be processed other than un-preserved items
	else if(cleaning && length(items_preserved))
		. += "<span class='bad'><b>Self-cleaning done. Eject remaining objects now.</b></span><br>"

	//Preserved items count when the list is populated
	if(length(items_preserved))
		. += "<span class='bad'>[length(items_preserved)] uncleanable object(s).</span><br>"

	if(show_patient)
		. += get_patient_data()
	else
		. += "Items: [length(contents)]"

	. += "</div>"

	var/datum/browser/popup = new(user, "sleeper", "Sleeper Console", 520, 540)	//Set up the popup browser window
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.set_content(.)
	popup.open()

/obj/item/device/dogborg/sleeper/proc/get_patient_data()
	if(!patient)
		return "[src] Unoccupied"

	. += "[patient] => "

	switch(patient.stat)
		if(0)
			. += "<span class='good'>Conscious</span>"
		if(1)
			. += "<span class='average'>Unconscious</span>"
		else
			. += "<span class='bad'>DEAD</span>"

	var/pulsecolor = (patient.pulse == PULSE_NONE || patient.pulse == PULSE_THREADY ? "color:red;" : "color:white;")
	var/healthcolor = (patient.health > 0 ? "color:white;" : "color:red;")
	var/brutecolor = (patient.getBruteLoss() < 60 ? "color:gray;" : "color:red;")
	var/o2color = (patient.getOxyLoss() < 60 ? "color:gray;" : "color:red;")
	var/toxcolor = (patient.getToxLoss() < 60 ? "color:gray;" : "color:red;")
	var/burncolor = (patient.getFireLoss() < 60 ? "color:gray;" : "color:red;")

	. += "<span style='[pulsecolor]'>\t-Pulse, bpm: [patient.get_pulse(GETPULSE_TOOL)]</span><BR>"
	. += "<span style='[healthcolor]'>\t-Overall Health %: [round(patient.health)]</span><BR>"
	. += "<span style='[brutecolor]'>\t-Brute Damage %: [patient.getBruteLoss()]</span><BR>"
	. += "<span style='[o2color]'>\t-Respiratory Damage %: [patient.getOxyLoss()]</span><BR>"
	. += "<span style='[toxcolor]'>\t-Toxin Content %: [patient.getToxLoss()]</span><BR>"
	. += "<span style='[burncolor]'>\t-Burn Severity %: [patient.getFireLoss()]</span><BR>"

	if(round(patient.paralysis / 4) >= 1)
		. += text("<hr>Patient paralyzed for: []<br>", round(patient.paralysis / 4) >= 1 ? "[round(patient.paralysis / 4)] seconds" : "None")
	if(patient.getBrainLoss())
		. += "<div class='line'><span class='average'>Significant brain damage detected.</span></div><br>"
	if(patient.getCloneLoss())
		. += "<div class='line'><span class='average'>Patient may be improperly cloned.</span></div><br>"
	if(patient.reagents.reagent_list.len)
		for(var/datum/reagent/R in patient.reagents.reagent_list)
			. += "<div class='line'><div style='width: 170px;' class='statusLabel'>[R.name]:</div><div class='statusValue'>[round(R.volume, 0.1)] units</div></div><br>"


/obj/item/device/dogborg/sleeper/Topic(href, href_list)
	if(..())
		return

	var/mob/user = usr
	if(user == patient)
		return

	user.set_machine(src)
	if(href_list["refresh"])
		update_patient()
		updateUsrDialog()
		interact(user)
		return

	if(href_list["eject"])
		go_out()
		interact(user)
		return

	if(href_list["clean"])
		if(!cleaning)
			var/confirm = alert(user, "You are about to engage self-cleaning mode. \
			This will fill your [src] with caustic enzymes to remove any objects or biomatter, and convert them into energy. \
			Are you sure?", "Confirmation", "Self-Clean", "Cancel")
			if(confirm == "Self-Clean")
				// no violently disintegrating patients unless you're rouge
				if(patient && (hound && !hound.emagged))
					to_chat(user, "<span class='danger'>Saftey protocols dictate that you eject any patients before engaging self-cleaning.</span>")
					return
				if(cleaning)
					to_chat(user, "<span class='warning'>Your [name] is already in self cleaning mode.</span>")
					return
				cleaning = TRUE
				drain(500)
				processing_objects.Add(src)
				interact(user)
				if(patient)
					to_chat(patient, "<span class='danger'>[hound]'s [name] fills with caustic enzymes around you!</span>")
				return
		else
			to_chat(user, "<span class='warning'>Your [name] is already in self cleaning mode.</span>")
			return

	if(href_list["inject"])
		if(patient && !(patient.stat & DEAD))
			if(patient.health > min_health)
				inject_chem(user, href_list["inject"])
			else
				to_chat(user, "<span class='notice'>ERROR: Subject is not in stable condition for injections.</span>")
		else
			to_chat(user, "<span class='notice'>ERROR: Subject cannot metabolise chemicals.</span>")

	updateUsrDialog()
	interact(user)

/obj/item/device/dogborg/sleeper/proc/inject_chem(mob/user, chem)
	if(patient && patient.reagents)
		if(chem in injection_chems)
			if(hound.cell.charge < 800) //This is so borgs don't kill themselves with it.
				to_chat(hound, "<span class='notice'>You don't have enough power to synthesize fluids.</span>")
				return
			else if(patient.reagents.get_reagent_amount(chem) + 10 >= 20) //Preventing people from accidentally killing themselves by trying to inject too many chemicals!
				to_chat(hound, "<span class='notice'>Your stomach is currently too full of fluids to secrete more fluids of this kind.</span>")
			else if(patient.reagents.get_reagent_amount(chem) + 10 <= 20) //No overdoses for you
				patient.reagents.add_reagent(chem, inject_amount)
				drain(750) //-750 charge per injection
			var/units = round(patient.reagents.get_reagent_amount(chem))
			to_chat(hound, "<span class='notice'>Injecting [units] unit\s of [chemical_reagents_list[chem]] into occupant.</span>")  //If they were immersed, the reagents wouldn't leave with them.


//For if the dogborg's existing patient uh, doesn't make it.
/obj/item/device/dogborg/sleeper/proc/update_patient()
	//Well, we HAD one, what happened to them?
	if(patient in contents)
		if(patient_laststat != patient.stat)
			if(patient.stat & DEAD)
				hound.sleeper_r = 1
				hound.sleeper_g = 0
				patient_laststat = patient.stat
			else
				hound.sleeper_r = 0
				hound.sleeper_g = 1
				patient_laststat = patient.stat
			//Update icon
			hound.update_icons()
		if(cleaning && (!hound.sleeper_r || hound.sleeper_g))
			hound.sleeper_r = 1
			hound.sleeper_g = 0
			hound.update_icons()
		//Return original patient
		return patient

	//Check for a new patient
	for(var/mob/living/carbon/human/C in contents)
		patient = C
		if(patient.stat & DEAD)
			hound.sleeper_r = 1
			hound.sleeper_g = 0
			patient_laststat = patient.stat
		else
			hound.sleeper_r = 0
			hound.sleeper_g = 1
			patient_laststat = patient.stat
		//Update icon and return new patient
		hound.update_icons()
		return C

	//Cleaning looks better with red on, even with nobody in it
	if(cleaning && !patient)
		hound.sleeper_r = 1
		hound.sleeper_g = 0

	//Couldn't find anyone, and not cleaning
	else if(!cleaning && !patient)
		hound.sleeper_r = 0
		hound.sleeper_g = 0

	patient_laststat = null
	patient = null
	hound.update_icons()

//CLEANSE
/obj/item/device/dogborg/sleeper/proc/clean_cycle()
	//Sanity? Maybe not required.
	for(var/I in items_preserved)
		if(!(I in contents))
			items_preserved -= I

	var/list/touchable_items = contents - items_preserved

	//Sleeper is entirely empty
	if(!length(contents))
		to_chat(hound, "<span class='notice'>Your [name] is now clean. Ending self-cleaning cycle.</span>")
		cleaning = 0
		update_patient()
		return

	//If the timing is right, and there are items to be touched
	if(mob_master.current_cycle % 3 == 1 && length(touchable_items))
		//Burn all the mobs or add them to the exclusion list
		for(var/mob/living/carbon/human/T in (touchable_items))
			if(T.status_flags & GODMODE)
				items_preserved += T
			else
				T.adjustBruteLoss(2)
				T.adjustFireLoss(3)
				update_patient()

		//Pick a random item to deal with (if there are any)
		var/atom/target = pick(touchable_items)

		//Handle the target being a mob
		if(ishuman(target))
			var/mob/living/carbon/human/T = target

			//Mob is now dead
			if(T.stat & DEAD)
				message_admins("[key_name_admin(hound)] CLEANSED [key_name_admin(T)] from this realm with their [name]. [ADMIN_FLW(hound)] [ADMIN_JMP(hound)]")
				to_chat(hound, "<span class='notice'>[T] has expired to [src]'s cleaning cycle, and has been converted to fuel for your power cell.</span>")
				to_chat(T, "<span class='userdanger'>[src]'s caustic enzymes have disintegrated you!</span>")
				drain(-30000) //Fueeeeellll
				qdel(T)
				update_patient()

		//Handle the target being anything but a /mob/living/carbon/human
		else
			qdel(target)
			update_patient()
			hound.cell.charge += 120 //10 charge? that was such a practically nonexistent number it hardly gave any purpose for this bit :v *cranks up*

/obj/item/device/dogborg/sleeper/process()
	if(cleaning) //We're cleaning, return early after calling this as we don't care about the patient.
		clean_cycle()
		return

	if(patient)	//We're caring for the patient. Medical emergency! Or endo scene.
		update_patient()
		if(patient.health < 0)
			patient.adjustOxyLoss(-1) //Heal some oxygen damage if they're in critical condition
			patient.updatehealth()
		patient.AdjustStunned(-4)
		patient.AdjustWeakened(-4)
		drain()
		// if((patient.reagents.get_reagent_amount("inaprovaline") < 5) && (patient.health < patient.maxHealth)) //Stop pumping full HP people full of drugs. Don't heal people you're digesting, meanie.
		// 	patient.reagents.add_reagent("inaprovaline", 5)
		return

	if(!patient && !cleaning) //We think we're done working.
		if(!update_patient()) //One last try to find someone
			processing_objects.Remove(src)
			return

/mob/living/silicon/robot
	var/sleeper_g
	var/sleeper_r

/obj/item/device/dogborg/sleeper/K9 //The K9 portabrig
	name = "Portabrig"
	desc = "Equipment for a K9 unit. A mounted portable-brig that holds criminals."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "sleeperb"
	inject_amount = 10
	min_health = -100
	injection_chems = null //So they don't have all the same chems as the medihound!

/obj/item/device/dogborg/sleeper/compactor //Janihound processor
	name = "garbage processor"
	desc = "A mounted garbage compactor unit with fuel processor."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "compactor"
	inject_amount = 10
	min_health = -100
	injection_chems = null //So they don't have all the same chems as the medihound!
	show_patient = FALSE
	var/max_item_count = 32

/obj/item/device/dogborg/sleeper/compactor/afterattack(atom/movable/target, mob/living/silicon/user, proximity)//GARBO NOMS
	hound = loc

	if(!istype(target) || target.anchored)
		return
	if(!proximity)
		return
	if(length(contents) > (max_item_count - 1))
		to_chat(user, "<span class='warning'>Your [name] is full. Eject or process contents to continue.</span>")
		return

	if(istype(target, /obj/item))
		var/obj/item/I = target
		if(I.w_class > WEIGHT_CLASS_BULKY)
			to_chat(user, "<span class='warning'>[target] is too large to fit into your [name].</span>")
			return
		user.visible_message("<span class='warning'>[hound] is loading [target] into their [name].</span>", "<span class='notice'>You start loading [target] into your [name]...</span>")
		if(do_after(user, 30, target = target) && length(contents) < max_item_count)
			target.forceMove(src)
			user.visible_message("<span class='warning'>[hound]'s garbage processor groans lightly as [target] slips inside.</span>", "<span class='notice'>Your garbage compactor groans lightly as [target] slips inside.</span>")
			playsound(hound, 'sound/effects/dognom.ogg', 50, 1)
			if(length(contents) > 11) //grow that tum after a certain junk amount
				hound.sleeper_r = 1
				hound.update_icons()

	else if(ishuman(target))
		var/mob/living/carbon/human/trashman = target
		if(patient)
			to_chat(user, "<span class='warning'>Your [name] is already occupied.</span>")
			return
		if(trashman.buckled)
			to_chat(user, "<span class='warning'>[trashman] is buckled and can not be put into your [name].</span>")
			return
		user.visible_message("<span class='warning'>[hound.name] is loading [trashman] into their [name].</span>", "<span class='notice'>You start loading [trashman] into your [name]...</span>")
		if(do_after(user, 30, target = trashman) && !patient && !trashman.buckled && length(contents) < max_item_count)
			trashman.forceMove(src)
			trashman.reset_perspective(src)
			update_patient()
			processing_objects.Add(src)
			user.visible_message("<span class='warning'>[hound]'s [name] groans lightly as [trashman] slips inside.</span>", "<span class='notice'>Your garbage compactor groans lightly as [trashman] slips inside.</span>")
			playsound(hound, 'sound/effects/dognom.ogg', 80, 1)