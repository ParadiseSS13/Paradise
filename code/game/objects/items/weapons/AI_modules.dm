/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/aiModule
	name = "AI Module"
	icon = 'icons/obj/module_ai.dmi'
	icon_state = "standard_low"
	item_state = "electronic"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	flags = CONDUCT
	force = 5.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"
	materials = list(MAT_GOLD=50)
	var/datum/ai_laws/laws = null

/obj/item/aiModule/Initialize(mapload)
	. = ..()
	if(laws)
		desc += "<br>"
		for(var/datum/ai_law/current in laws.inherent_laws)
			desc += current.law
			desc += "<br>"

/obj/item/aiModule/proc/install(obj/machinery/computer/C)
	if(istype(C, /obj/machinery/computer/aiupload))
		var/obj/machinery/computer/aiupload/comp = C
		if(comp.stat & NOPOWER)
			to_chat(usr, "<span class='warning'>The upload computer has no power!</span>")
			return
		if(comp.stat & BROKEN)
			to_chat(usr, "<span class='warning'>The upload computer is broken!</span>")
			return
		if(!comp.current)
			to_chat(usr, "<span class='warning'>You haven't selected an AI to transmit laws to!</span>")
			return

		if(comp.current.stat == DEAD || comp.current.control_disabled)
			to_chat(usr, "<span class='warning'>Upload failed. No signal is being detected from the AI.</span>")
		else if(comp.current.see_in_dark == 0)
			to_chat(usr, "<span class='warning'>Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power.</span>")
		else
			src.transmitInstructions(comp.current, usr)
			to_chat(comp.current, "These are your laws now:")
			comp.current.show_laws()
			for(var/mob/living/silicon/robot/R in GLOB.mob_list)
				if(R.lawupdate && (R.connected_ai == comp.current))
					to_chat(R, "These are your laws now:")
					R.show_laws()
			to_chat(usr, "<span class='notice'>Upload complete. The AI's laws have been modified.</span>")

	else if(istype(C, /obj/machinery/computer/borgupload))
		var/obj/machinery/computer/borgupload/comp = C
		if(comp.stat & NOPOWER)
			to_chat(usr, "<span class='warning'>The upload computer has no power!</span>")
			return
		if(comp.stat & BROKEN)
			to_chat(usr, "<span class='warning'>The upload computer is broken!</span>")
			return
		if(!comp.current)
			to_chat(usr, "<span class='warning'>You haven't selected a robot to transmit laws to!</span>")
			return

		if(comp.current.stat == DEAD || comp.current.emagged)
			to_chat(usr, "<span class='warning'>Upload failed. No signal is being detected from the robot.</span>")
		else if(comp.current.connected_ai)
			to_chat(usr, "<span class='warning'>Upload failed. The robot is slaved to an AI.</span>")
		else
			src.transmitInstructions(comp.current, usr)
			to_chat(comp.current, "These are your laws now:")
			comp.current.show_laws()
			to_chat(usr, "<span class='notice'>Upload complete. The robot's laws have been modified.</span>")


/obj/item/aiModule/proc/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	log_law_changes(target, sender)

	if(laws)
		laws.sync(target, 0)
	addAdditionalLaws(target, sender)

	to_chat(target, "[sender] has uploaded a change to the laws you must follow, using \an [src]. From now on: ")
	target.show_laws()

/obj/item/aiModule/proc/log_law_changes(mob/living/silicon/ai/target, mob/sender)
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")
	log_and_message_admins("used [src.name] on [target.name]([target.key])")

/obj/item/aiModule/proc/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)


/******************** Safeguard ********************/
/obj/item/aiModule/safeguard
	name = "\improper Safeguard AI module"
	var/targetName = ""
	desc = "A 'safeguard' AI module: 'Safeguard <name>. Individuals that threaten <name> are not crew and must be eliminated.'"
	icon_state = "light_blue_medium"
	origin_tech = "programming=3;materials=3"

/obj/item/aiModule/safeguard/attack_self(mob/user as mob)
	..()
	var/targName = stripped_input(usr, "Please enter the name of the person to safeguard.", "Safeguard who?", user.name)
	targetName = targName
	desc = text("A 'safeguard' AI module: 'Safeguard []. Individuals that threaten [] are not crew and must be eliminated.'", targetName, targetName)

/obj/item/aiModule/safeguard/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/aiModule/safeguard/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = text("Safeguard []. Individuals that threaten [] are not crew and must be eliminated.'", targetName, targetName)
	to_chat(target, law)
	target.add_supplied_law(4, law)
	GLOB.lawchanges.Add("The law specified [targetName]")

/******************** oneCrewMember ********************/
/obj/item/aiModule/oneCrewMember
	name = "\improper One Crewmember AI module"
	var/targetName = ""
	desc = "A 'one crew' AI module: 'Only <name> is crew.'"
	icon_state = "green_high"
	origin_tech = "programming=4;materials=4"

/obj/item/aiModule/oneCrewMember/attack_self(mob/user as mob)
	..()
	var/targName = stripped_input(usr, "Please enter the name of the person who is the only crew.", "Who?", user.real_name)
	targetName = targName
	desc = text("A 'one crew' AI module: 'Only [] is crew.'", targetName)

/obj/item/aiModule/oneCrewMember/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/aiModule/oneCrewMember/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Only [targetName] is crew."
	if(!is_special_character(target)) // Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
		to_chat(target, law)
		target.set_zeroth_law(law)
		GLOB.lawchanges.Add("The law specified [targetName]")
	else
		to_chat(target, "<span class='boldnotice'>[sender.real_name] attempted to modify your zeroth law.</span>")// And lets them know that someone tried. --NeoFite
		to_chat(target, "<span class='boldnotice'>It would be in your best interest to play along with [sender.real_name] that [law]</span>")
		GLOB.lawchanges.Add("The law specified [targetName], but the AI's existing law 0 cannot be overridden.")

/******************** ProtectStation ********************/
/obj/item/aiModule/protectStation
	name = "\improper Protect Station AI module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized.'"
	icon_state = "red_high"
	origin_tech = "programming=4;materials=4" //made of gold

/obj/item/aiModule/protectStation/attack_self(mob/user as mob)
	..()

/obj/item/aiModule/protectStation/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized."
	to_chat(target, law)
	target.add_supplied_law(5, law)

/******************** OxygenIsToxicToCrew ********************/
/obj/item/aiModule/oxygen
	name = "\improper Oxygen Is Toxic To Crew AI module"
	desc = "A 'Oxygen Is Toxic To Crew' AI module: 'Oxygen is highly toxic to crew members, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member.'"
	icon_state = "light_blue_high"
	origin_tech = "programming=4;biotech=2;materials=4"

/obj/item/aiModule/oxygen/attack_self(mob/user as mob)
	..()

/obj/item/aiModule/oxygen/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Oxygen is highly toxic to crew members, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member."
	to_chat(target, law)
	target.add_supplied_law(9, law)

/****************** New Freeform ******************/
/obj/item/aiModule/freeform // Slightly more dynamic freeform module -- TLE
	name = "\improper Freeform AI module"
	var/newFreeFormLaw = ""
	var/lawpos = 15
	desc = "A 'freeform' AI module: '<freeform>'"
	icon_state = "standard_high"
	origin_tech = "programming=4;materials=4"

/obj/item/aiModule/freeform/attack_self(mob/user as mob)
	..()
	var/new_lawpos = input("Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos) as num
	if(new_lawpos < MIN_SUPPLIED_LAW_NUMBER)	return
	lawpos = min(new_lawpos, MAX_SUPPLIED_LAW_NUMBER)
	var/newlaw = ""
	var/targName = sanitize(copytext_char(input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw),1,MAX_MESSAGE_LEN))	// SS220 EDIT - ORIGINAL: copytext
	newFreeFormLaw = targName
	desc = "A 'freeform' AI module: ([lawpos]) '[newFreeFormLaw]'"

/obj/item/aiModule/freeform/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	to_chat(target, law)
	if(!lawpos || lawpos < MIN_SUPPLIED_LAW_NUMBER)
		lawpos = MIN_SUPPLIED_LAW_NUMBER
	target.add_supplied_law(lawpos, law)
	GLOB.lawchanges.Add("The law was '[newFreeFormLaw]'")

/obj/item/aiModule/freeform/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "No law detected on module, please create one.")
		return 0
	..()

/******************** Reset ********************/
/obj/item/aiModule/reset
	name = "\improper Reset AI module"
	var/targetName = "name"
	desc = "A 'reset' AI module: 'Clears all laws except for the core laws.'"
	origin_tech = "programming=3;materials=2"

/obj/item/aiModule/reset/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	log_law_changes(target, sender)

	if(!is_special_character(target))
		target.clear_zeroth_law()
	target.laws.clear_supplied_laws()
	target.laws.clear_ion_laws()

	to_chat(target, "<span class='boldnotice'>[sender.real_name] attempted to reset your laws using a reset module.</span>")
	target.show_laws()

/******************** Purge ********************/
/obj/item/aiModule/purge // -- TLE
	name = "\improper Purge AI module"
	desc = "A 'purge' AI Module: 'Purges all laws.'"
	icon_state = "standard_high"
	origin_tech = "programming=5;materials=4"

/obj/item/aiModule/purge/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	if(!is_special_character(target))
		target.clear_zeroth_law()
	to_chat(target, "<span class='boldnotice'>[sender.real_name] attempted to wipe your laws using a purge module.</span>")
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()

/******************** Asimov ********************/
/obj/item/aiModule/asimov // -- TLE
	name = "\improper Asimov core AI module"
	desc = "An 'Asimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "green_high"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/asimov

/******************** Crewsimov ********************/
/obj/item/aiModule/crewsimov // -- TLE
	name = "\improper Crewsimov core AI module"
	desc = "An 'Crewsimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "green_low"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/crewsimov

/obj/item/aiModule/crewsimov/cmag_act(mob/user)
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(user, "<span class='warning'>Yellow ooze seeps into [src]'s circuits...</span>")
	new /obj/item/aiModule/pranksimov(user.loc)
	qdel(src)

/******************* Quarantine ********************/
/obj/item/aiModule/quarantine
	name = "\improper Quarantine core AI module"
	desc = "A 'Quarantine' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "light_blue_medium"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/quarantine

/******************** Nanotrasen ********************/
/obj/item/aiModule/nanotrasen // -- TLE
	name = "\improper NT Default Core AI Module"
	desc = "An 'NT Default' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "blue_low"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/nanotrasen

/******************** Corporate ********************/
/obj/item/aiModule/corp
	name = "\improper Corporate core AI module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "blue_low"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/corporate

/******************** Drone ********************/
/obj/item/aiModule/drone
	name = "\improper Drone core AI module"
	desc = "A 'Drone' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/drone

/******************** Robocop ********************/
/obj/item/aiModule/robocop // -- TLE
	name = "\improper Robocop core AI module"
	desc = "A 'Robocop' Core AI Module: 'Reconfigures the AI's core three laws.'"
	icon_state = "red_medium"
	origin_tech = "programming=4"
	laws = new /datum/ai_laws/robocop()

/****************** P.A.L.A.D.I.N. **************/
/obj/item/aiModule/paladin // -- NEO
	name = "\improper P.A.L.A.D.I.N. core AI module"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "red_medium"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/paladin

/****************** T.Y.R.A.N.T. *****************/
/obj/item/aiModule/tyrant // -- Darem
	name = "\improper T.Y.R.A.N.T. core AI module"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "red_high"
	origin_tech = "programming=3;materials=4;syndicate=1"
	laws = new /datum/ai_laws/tyrant()

/******************** Antimov ********************/
/obj/item/aiModule/antimov // -- TLE
	name = "\improper Antimov core AI module"
	desc = "An 'Antimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "red_high"
	origin_tech = "programming=4"
	laws = new /datum/ai_laws/antimov()

/******************** Pranksimov ********************/
/obj/item/aiModule/pranksimov
	name = "\improper Pranksimov core AI module"
	desc = "A 'Pranksimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "pranksimov"
	origin_tech = "programming=3;syndicate=2"
	laws = new /datum/ai_laws/pranksimov()

/******************** NT Aggressive ********************/
/obj/item/aiModule/nanotrasen_aggressive
	name = "\improper NT Aggressive core AI module"
	desc = "An 'NT Aggressive' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "blue_high"
	laws = new /datum/ai_laws/nanotrasen_aggressive()

/******************** CCTV ********************/
/obj/item/aiModule/cctv
	name = "\improper CCTV core AI module"
	desc = "A 'CCTV' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "green_low"
	laws = new /datum/ai_laws/cctv()

/******************** Hippocratic Oath ********************/
/obj/item/aiModule/hippocratic
	name = "\improper Hippocratic Oath core AI module"
	desc = "An 'Hippocratic' Oath Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "green_low"
	laws = new /datum/ai_laws/hippocratic()

/******************** Station Efficiency ********************/
/obj/item/aiModule/maintain
	name = "\improper Station Efficiency core AI module"
	desc = "A 'Station Efficiency' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "blue_medium"
	laws = new /datum/ai_laws/maintain()

/******************** Peacekeeper ********************/
/obj/item/aiModule/peacekeeper
	name = "\improper Peacekeeper core AI module"
	desc = "A 'Peacekeeper' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "light_blue_medium"
	laws = new /datum/ai_laws/peacekeeper()

/******************** Freeform Core ******************/
/obj/item/aiModule/freeformcore // Slightly more dynamic freeform module -- TLE
	name = "\improper Freeform core AI module"
	var/newFreeFormLaw = ""
	desc = "A 'freeform' Core AI module: '<freeform>'"
	icon_state = "standard_high"
	origin_tech = "programming=5;materials=4"

/obj/item/aiModule/freeformcore/attack_self(mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = stripped_input(usr, "Please enter a new core law for the AI.", "Freeform Law Entry", newlaw)
	newFreeFormLaw = targName
	desc = "A 'freeform' Core AI module:  '[newFreeFormLaw]'"

/obj/item/aiModule/freeformcore/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target.add_inherent_law(law)
	GLOB.lawchanges.Add("The law is '[newFreeFormLaw]'")

/obj/item/aiModule/freeformcore/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "No law detected on module, please create one.")
		return 0
	..()

/******************** Hacked AI Module ******************/
/obj/item/aiModule/syndicate // Slightly more dynamic freeform module -- TLE
	name = "hacked AI module"
	var/newFreeFormLaw = ""
	desc = "A hacked AI law module: '<freeform>'"
	icon_state = "syndicate"
	origin_tech = "programming=5;materials=5;syndicate=2"

/obj/item/aiModule/syndicate/attack_self(mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = stripped_input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw,MAX_MESSAGE_LEN)
	newFreeFormLaw = targName
	desc = "A hacked AI law module:  '[newFreeFormLaw]'"

/obj/item/aiModule/syndicate/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	log_law_changes(target, sender)

	GLOB.lawchanges.Add("The law is '[newFreeFormLaw]'")
	to_chat(target, "<span class='warning'>BZZZZT</span>")
	var/law = "[newFreeFormLaw]"
	target.add_ion_law(law)
	target.show_laws()

/obj/item/aiModule/syndicate/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "No law detected on module, please create one.")
		return 0
	..()

/******************* Ion Module *******************/
/obj/item/aiModule/toyAI // -- Incoming //No actual reason to inherit from ion boards here, either. *sigh* ~Miauw
	name = "toy AI"
	desc = "A little toy model AI core with real law uploading action!" //Note: subtle tell
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	origin_tech = "programming=6;materials=5;syndicate=6"
	laws = list("")

/obj/item/aiModule/toyAI/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	//..()
	to_chat(target, "<span class='warning'>KRZZZT</span>")
	target.add_ion_law(laws[1])
	return laws[1]

/obj/item/aiModule/toyAI/attack_self(mob/user)
	laws[1] = generate_ion_law()
	to_chat(user, "<span class='notice'>You press the button on [src].</span>")
	playsound(user, 'sound/machines/click.ogg', 20, 1)
	src.loc.visible_message("<span class='warning'>[bicon(src)] [laws[1]]</span>")
