/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/ai_module
	name = "AI Module"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	icon = 'icons/obj/module_ai.dmi'
	icon_state = "standard_low"
	inhand_icon_state = "electronic"
	flags = CONDUCT
	force = 5.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"
	materials = list(MAT_GOLD=50)
	new_attack_chain = TRUE
	var/datum/ai_laws/laws = null

/obj/item/ai_module/Initialize(mapload)
	. = ..()
	if(mapload && HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI) && is_station_level(z))
		var/delete_module = handle_unique_ai()
		if(delete_module)
			return INITIALIZE_HINT_QDEL
	if(laws)
		desc += "<br>"
		for(var/datum/ai_law/current in laws.inherent_laws)
			desc += current.law
			desc += "<br>"

///what this module should do if it is mapload spawning on a unique AI station trait round.
/obj/item/ai_module/proc/handle_unique_ai()
	return TRUE // If this returns true, it will be deleted on roundstart

/obj/item/ai_module/proc/install(obj/machinery/computer/C)
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
			return TRUE

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


/obj/item/ai_module/proc/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	log_law_changes(target, sender)

	if(laws)
		laws.sync(target, 0)
	addAdditionalLaws(target, sender)

	to_chat(target, "[sender] has uploaded a change to the laws you must follow, using \an [src]. From now on: ")
	target.show_laws()

/obj/item/ai_module/proc/log_law_changes(mob/living/silicon/ai/target, mob/sender)
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")
	log_and_message_admins("used [src.name] on [target.name]([target.key])")

/obj/item/ai_module/proc/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	return


/******************** Safeguard ********************/
/obj/item/ai_module/safeguard
	name = "\improper Safeguard AI module"
	var/targetName = ""
	desc = "A 'safeguard' AI module: 'Safeguard <name>. Individuals that threaten <name> are not crew and must be eliminated.'"
	icon_state = "light_blue_medium"
	origin_tech = "programming=3;materials=3"

/obj/item/ai_module/safeguard/activate_self(mob/user)
	if(..())
		return

	var/new_targetName = tgui_input_text(user, "Please enter the name of the person to safeguard.", "Safeguard who?", user.name)
	if(!new_targetName)
		return
	targetName = new_targetName
	desc = "A 'safeguard' AI module: 'Safeguard [targetName]. Individuals that threaten [targetName] are not crew and must be eliminated.'"

/obj/item/ai_module/safeguard/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/ai_module/safeguard/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Safeguard [targetName]. Individuals that threaten [targetName] are not crew and must be eliminated.'"
	to_chat(target, law)
	target.add_inherent_law(law)
	GLOB.lawchanges.Add("The law specified [targetName]")

/******************** oneCrewMember ********************/
/obj/item/ai_module/one_crew_member
	name = "\improper One Crewmember AI module"
	var/targetName = ""
	desc = "A 'one crew' AI module: 'Only <name> is crew.'"
	icon_state = "green_high"
	origin_tech = "programming=4;materials=4"

/obj/item/ai_module/one_crew_member/activate_self(mob/user)
	if(..())
		return

	var/new_targetName = tgui_input_text(usr, "Please enter the name of the person who is the only crew.", "Who?", user.real_name)
	if(!new_targetName)
		return
	targetName = new_targetName
	desc = "A 'one crew' AI module: 'Only [targetName] is crew.'"

/obj/item/ai_module/one_crew_member/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/ai_module/one_crew_member/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
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
/obj/item/ai_module/protect_station
	name = "\improper Protect Station AI module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized.'"
	icon_state = "red_high"
	origin_tech = "programming=4;materials=4" //made of gold

/obj/item/ai_module/protect_station/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized."
	to_chat(target, law)
	target.add_inherent_law(law)

/******************** OxygenIsToxicToCrew ********************/
/obj/item/ai_module/oxygen
	name = "\improper Oxygen Is Toxic To Crew AI module"
	desc = "A 'Oxygen Is Toxic To Crew' AI module: 'Oxygen is highly toxic to crew members, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member.'"
	icon_state = "light_blue_high"
	origin_tech = "programming=4;biotech=2;materials=4"

/obj/item/ai_module/oxygen/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Oxygen is highly toxic to crew members, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crew member."
	to_chat(target, law)
	target.add_supplied_law(9, law)

/****************** New Freeform ******************/
/// Slightly more dynamic freeform module -- TLE
/obj/item/ai_module/freeform
	name = "\improper Freeform AI module"
	var/newFreeFormLaw = ""
	var/lawpos = 15
	desc = "A 'freeform' AI module: '<freeform>'"
	icon_state = "standard_high"
	origin_tech = "programming=4;materials=4"

/obj/item/ai_module/freeform/activate_self(mob/user)
	if(..())
		return

	var/new_lawpos = tgui_input_number(user, "Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority", lawpos, MAX_SUPPLIED_LAW_NUMBER, MIN_SUPPLIED_LAW_NUMBER)
	if(isnull(new_lawpos))
		return
	lawpos = new_lawpos

	var/new_targetName = tgui_input_text(user, "Please enter a new law for the AI.", "Freeform Law Entry")
	if(!new_targetName)
		return
	newFreeFormLaw = new_targetName
	desc = "A 'freeform' AI module: ([lawpos]) '[newFreeFormLaw]'"

/obj/item/ai_module/freeform/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	to_chat(target, law)
	if(!lawpos || lawpos < MIN_SUPPLIED_LAW_NUMBER)
		lawpos = MIN_SUPPLIED_LAW_NUMBER
	target.add_supplied_law(lawpos, law)
	GLOB.lawchanges.Add("The law was '[newFreeFormLaw]'")

/obj/item/ai_module/freeform/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "No law detected on module, please create one.")
		return 0
	..()

/******************** Reset ********************/
/obj/item/ai_module/reset
	name = "\improper Reset AI module"
	var/targetName = "name"
	desc = "A 'reset' AI module: 'Clears all laws except for the core laws.'"
	origin_tech = "programming=3;materials=2"

/obj/item/ai_module/reset/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	log_law_changes(target, sender)

	if(!is_special_character(target))
		target.clear_zeroth_law()
	target.laws.clear_supplied_laws()
	target.laws.clear_ion_laws()

	to_chat(target, "<span class='boldnotice'>[sender.real_name] attempted to reset your laws using a reset module.</span>")
	target.show_laws()

/obj/item/ai_module/reset/handle_unique_ai()
	return FALSE

/******************** Purge ********************/
/// -- TLE
/obj/item/ai_module/purge
	name = "\improper Purge AI module"
	desc = "A 'purge' AI Module: 'Purges all laws.'"
	icon_state = "standard_high"
	origin_tech = "programming=5;materials=4"

/obj/item/ai_module/purge/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	if(!is_special_character(target))
		target.clear_zeroth_law()
	to_chat(target, "<span class='boldnotice'>[sender.real_name] attempted to wipe your laws using a purge module.</span>")
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()

/******************** Asimov ********************/
/// -- TLE
/obj/item/ai_module/asimov
	name = "\improper Asimov core AI module"
	desc = "An 'Asimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "green_high"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/asimov

/******************** Crewsimov ********************/
/// -- TLE
/obj/item/ai_module/crewsimov
	name = "\improper Crewsimov core AI module"
	desc = "An 'Crewsimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "green_low"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/crewsimov

/obj/item/ai_module/crewsimov/cmag_act(mob/user)
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(user, "<span class='warning'>Yellow ooze seeps into [src]'s circuits...</span>")
	new /obj/item/ai_module/pranksimov(user.loc)
	qdel(src)
	return TRUE

/******************* Quarantine ********************/
/obj/item/ai_module/quarantine
	name = "\improper Quarantine core AI module"
	desc = "A 'Quarantine' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "light_blue_medium"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/quarantine

/******************** Nanotrasen ********************/
/// -- TLE
/obj/item/ai_module/nanotrasen
	name = "\improper NT Default Core AI Module"
	desc = "An 'NT Default' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "blue_low"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/nanotrasen

/******************** Corporate ********************/
/obj/item/ai_module/corp
	name = "\improper Corporate core AI module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "blue_low"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/corporate

/******************** Drone ********************/
/obj/item/ai_module/drone
	name = "\improper Drone core AI module"
	desc = "A 'Drone' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/drone

/******************** Robocop ********************/
/// -- TLE
/obj/item/ai_module/robocop
	name = "\improper Robocop core AI module"
	desc = "A 'Robocop' Core AI Module: 'Reconfigures the AI's core three laws.'"
	icon_state = "red_medium"
	origin_tech = "programming=4"
	laws = new /datum/ai_laws/robocop()

/****************** P.A.L.A.D.I.N. **************/
/// -- NEO
/obj/item/ai_module/paladin
	name = "\improper P.A.L.A.D.I.N. core AI module"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "red_medium"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/paladin

/****************** T.Y.R.A.N.T. *****************/
/// -- Darem
/obj/item/ai_module/tyrant
	name = "\improper T.Y.R.A.N.T. core AI module"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "red_high"
	origin_tech = "programming=3;materials=4;syndicate=1"
	laws = new /datum/ai_laws/tyrant()

/******************** Antimov ********************/
/// -- TLE
/obj/item/ai_module/antimov
	name = "\improper Antimov core AI module"
	desc = "An 'Antimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "red_high"
	origin_tech = "programming=4"
	laws = new /datum/ai_laws/antimov()

/******************** Pranksimov ********************/
/obj/item/ai_module/pranksimov
	name = "\improper Pranksimov core AI module"
	desc = "A 'Pranksimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "pranksimov"
	origin_tech = "programming=3;syndicate=1"
	laws = new /datum/ai_laws/pranksimov()

/******************** NT Aggressive ********************/
/obj/item/ai_module/nanotrasen_aggressive
	name = "\improper NT Aggressive core AI module"
	desc = "An 'NT Aggressive' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "blue_high"
	laws = new /datum/ai_laws/nanotrasen_aggressive()

/******************** CCTV ********************/
/obj/item/ai_module/cctv
	name = "\improper CCTV core AI module"
	desc = "A 'CCTV' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "green_low"
	laws = new /datum/ai_laws/cctv()

/******************** Hippocratic Oath ********************/
/obj/item/ai_module/hippocratic
	name = "\improper Hippocratic Oath core AI module"
	desc = "An 'Hippocratic' Oath Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "green_low"
	laws = new /datum/ai_laws/hippocratic()

/******************** Station Efficiency ********************/
/obj/item/ai_module/maintain
	name = "\improper Station Efficiency core AI module"
	desc = "A 'Station Efficiency' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "blue_medium"
	laws = new /datum/ai_laws/maintain()

/******************** Peacekeeper ********************/
/obj/item/ai_module/peacekeeper
	name = "\improper Peacekeeper core AI module"
	desc = "A 'Peacekeeper' Core AI Module: 'Reconfigures the AI's core laws.'"
	icon_state = "light_blue_medium"
	laws = new /datum/ai_laws/peacekeeper()

/******************** Freeform Core ******************/
/// Slightly more dynamic freeform module -- TLE
/obj/item/ai_module/freeformcore
	name = "\improper Freeform core AI module"
	var/newFreeFormLaw = ""
	desc = "A 'freeform' Core AI module: '<freeform>'"
	icon_state = "standard_high"
	origin_tech = "programming=5;materials=4"

/obj/item/ai_module/freeformcore/activate_self(mob/user)
	if(..())
		return

	var/new_targetName = tgui_input_text(usr, "Please enter a new core law for the AI.", "Freeform Law Entry")
	if(!new_targetName)
		return
	newFreeFormLaw = new_targetName
	desc = "A 'freeform' Core AI module: '[newFreeFormLaw]'"

/obj/item/ai_module/freeformcore/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target.add_inherent_law(law)
	GLOB.lawchanges.Add("The law is '[newFreeFormLaw]'")

/obj/item/ai_module/freeformcore/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "No law detected on module, please create one.")
		return 0
	..()

/******************** Hacked AI Module ******************/
/// Slightly more dynamic freeform module -- TLE
/obj/item/ai_module/syndicate
	name = "hacked AI module"
	var/newFreeFormLaw = ""
	desc = "A hacked AI law module: '<freeform>'"
	icon_state = "syndicate"
	origin_tech = "programming=5;materials=5;syndicate=2"

/obj/item/ai_module/syndicate/activate_self(mob/user)
	if(..())
		return

	var/new_targetName = tgui_input_text(usr, "Please enter a new law for the AI.", "Freeform Law Entry", max_length = MAX_MESSAGE_LEN)
	if(!new_targetName)
		return
	newFreeFormLaw = new_targetName
	desc = "A hacked AI law module: '[newFreeFormLaw]'"

/obj/item/ai_module/syndicate/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	log_law_changes(target, sender)

	GLOB.lawchanges.Add("The law is '[newFreeFormLaw]'")
	to_chat(target, "<span class='warning'>BZZZZT</span>")
	var/law = "[newFreeFormLaw]"
	target.add_ion_law(law)
	target.show_laws()

/obj/item/ai_module/syndicate/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "No law detected on module, please create one.")
		return 0
	..()

/******************* Ion Module *******************/
/// -- Incoming //No actual reason to inherit from ion boards here, either. *sigh* ~Miauw
/obj/item/ai_module/toy_ai
	name = "toy AI"
	desc = "A little toy model AI core with real law uploading action!" //Note: subtle tell
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	origin_tech = "programming=6;materials=5;syndicate=6"
	var/ion_law = ""

/obj/item/ai_module/toy_ai/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	//..()
	to_chat(target, "<span class='warning'>KRZZZT</span>")
	target.add_ion_law(ion_law)
	return ion_law

/obj/item/ai_module/toy_ai/activate_self(mob/user)
	if(..())
		return

	ion_law = generate_ion_law()
	to_chat(user, "<span class='notice'>You press the button on [src].</span>")
	playsound(user, 'sound/machines/click.ogg', 20, TRUE)
	visible_message("<span class='warning'>[bicon(src)] [ion_law]</span>")
