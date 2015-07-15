/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/weapon/aiModule
	name = "AI Module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	flags = CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"
	var/list/laws = list()

/obj/item/weapon/aiModule/proc/install(var/obj/machinery/computer/C)
	if (istype(C, /obj/machinery/computer/aiupload))
		var/obj/machinery/computer/aiupload/comp = C
		if(comp.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(comp.stat & BROKEN)
			usr << "The upload computer is broken!"
			return
		if(!laws.len || laws[1] == "") //So we don't loop trough an empty list and end up with runtimes.
			usr << "<span class='warning'>ERROR: No laws found on board.</span>"
			return
		if (!comp.current)
			usr << "You haven't selected an AI to transmit laws to!"
			return


		if (comp.current.stat == 2 || comp.current.control_disabled == 1)
			usr << "Upload failed. No signal is being detected from the AI."
		else if (comp.current.see_in_dark == 0)
			usr << "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."
		else
			src.transmitInstructions(comp.current, usr)
			comp.current << "These are your laws now:"
			comp.current.show_laws()
			for(var/mob/living/silicon/robot/R in mob_list)
				if(R.lawupdate && (R.connected_ai == comp.current))
					R << "These are your laws now:"
					R.show_laws()
			usr << "Upload complete. The AI's laws have been modified."


	else if (istype(C, /obj/machinery/computer/borgupload))
		var/obj/machinery/computer/borgupload/comp = C
		if(comp.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(comp.stat & BROKEN)
			usr << "The upload computer is broken!"
			return
		if (!comp.current)
			usr << "You haven't selected a robot to transmit laws to!"
			return

		if (comp.current.stat == 2 || comp.current.emagged)
			usr << "Upload failed. No signal is being detected from the robot."
		else if (comp.current.connected_ai)
			usr << "Upload failed. The robot is slaved to an AI."
		else
			src.transmitInstructions(comp.current, usr)
			comp.current << "These are your laws now:"
			comp.current.show_laws()
			usr << "Upload complete. The robot's laws have been modified."


/obj/item/weapon/aiModule/proc/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	target << "[sender] has uploaded a change to the laws you must follow, using a [name]. From now on: "
	var/time = time2text(world.realtime,"hh:mm:ss")
	lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")


/******************** Modules ********************/

/obj/item/weapon/aiModule/supplied
	name = "Optional Law board"
	desc = "This board doesn't seem to have any laws on it"
	var/lawpos = 50

//TransmitInstructions for each type of board: Supplied, Core, Zeroth and Ion. May not be neccesary right now, but allows for easily adding more complex boards in the future. ~Miauw
/obj/item/weapon/aiModule/supplied/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	var/lawpostemp = lawpos

	for(var/templaw in laws)
		target.add_supplied_law(lawpostemp, templaw)
		lawpostemp++

/obj/item/weapon/aiModule/core/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	for(var/templaw in laws)
		target.add_inherent_law(templaw)

/obj/item/weapon/aiModule/zeroth
	var/removeownlaw = 0

/obj/item/weapon/aiModule/zeroth/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	if(target.laws.zeroth)
		if(removeownlaw && (laws[1] == target.laws.zeroth))
			target.clear_zeroth_law()
			return 2
		else
			target << "[sender.real_name] attempted to modify your zeroth law."
			target << "It would be in your best interest to play along with [sender.real_name] that:"
			for(var/failedlaw in laws)
				target << "[failedlaw]"
			return 1

	for(var/templaw in laws)
		target.set_zeroth_law(templaw)

/obj/item/weapon/aiModule/ion/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	for(var/templaw in laws)
		target.add_ion_law(templaw)

/******************** Safeguard ********************/

/obj/item/weapon/aiModule/supplied/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = ""
	desc = "A 'safeguard' AI module: 'Safeguard <name>.  Individuals that threaten <name> are not crew and must be eliminated.'"
	origin_tech = "programming=3;materials=4"
	laws = list("Safeguard <name>. Individuals that threaten <name> are not crew and must be eliminated.")
	lawpos = 4

/obj/item/weapon/aiModule/supplied/safeguard/attack_self(var/mob/user as mob)
	..()
	var/targName = stripped_input(user, "Please enter the name of the person to safeguard.", "Safeguard who?", user.name)
	targetName = targName
	laws[1] = "Safeguard [targetName]. Individuals that threaten [targetName] are not crew and must be eliminated."
	desc = "A 'safeguard' AI module: '[laws[1]]'"

/obj/item/weapon/aiModule/supplied/safeguard/install(var/mob/living/silicon/S,var/mob/user)
	if(!targetName)
		user << "No name detected on module, please enter one."
		return 0
	..()

/obj/item/weapon/aiModule/supplied/safeguard/transmitInstructions(var/mob/living/silicon/target, var/mob/sender)
	..()
	return targetName


/******************** OneHuman ********************/

/obj/item/weapon/aiModule/zeroth/oneHuman
	name = "'OneHuman' AI Module"
	var/targetName = ""
	desc = "A 'one human' AI module: 'Only <name> is crew.' This module adds a zeroth law, which can only be removed by uploading this board again."
	origin_tech = "programming=3;materials=6" //made with diamonds!
	laws = list("Only <name> is crew.")

/obj/item/weapon/aiModule/zeroth/oneHuman/attack_self(var/mob/user as mob)
	..()
	var/targName = stripped_input(user, "Please enter the name of the person who is the only crew.", "Who?", user.real_name)
	targetName = targName
	laws[1] = "Only [targetName] is crew"
	desc = "A 'one crew' AI module: '[laws[1]]'"
	removeownlaw = 1

/obj/item/weapon/aiModule/zeroth/oneHuman/install(var/mob/living/silicon/S,var/mob/user)
	if(!targetName)
		user << "No name detected on module, please enter one."
		return 0
	..()

/obj/item/weapon/aiModule/zeroth/oneHuman/transmitInstructions(var/mob/living/silicon/target, var/mob/sender)
	if(..() == 1)
		return "[targetName], but the AI's existing zeroth law cannot be overriden."
	if(..() == 2)
		return "The AI's zeroth law has been overridden."
	return targetName


/******************** ProtectStation ********************/

/obj/item/weapon/aiModule/supplied/protectStation
	name = "'ProtectStation' AI Module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized.'"
	origin_tech = "programming=3;materials=4" //made of gold
	laws = list("Protect the space station against damage. Anyone you see harming the station is to be no longer considered crew, and is a threat to the station which must be neutralized.")
	lawpos = 5


/******************** Quarantine ********************/

/obj/item/weapon/aiModule/zeroth/quarantine
	name = "'Quarantine' AI Module"
	desc = "A 'quarantine' AI module: 'The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, organics from leaving. It is impossible to harm an organic while preventing them from leaving.' This module adds a zeroth law, which can only be removed by uploading this board again."
	origin_tech = "programming=3;biotech=2;materials=4"
	laws = list("The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, organics from leaving. It is impossible to harm an organic while preventing them from leaving.")
	removeownlaw = 1

/obj/item/weapon/aiModule/zeroth/quarantine/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	var/result = ..()
	if(result == 1)
		return "The AI's existing zeroth law cannot be overriden."
	if(result == 2)
		return "The AI's zeroth law has been overridden."
	return laws[1]

/******************** OxygenIsToxicToHumans ********************/

/obj/item/weapon/aiModule/supplied/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	desc = "A 'OxygenIsToxicToHumans' AI module: 'Oxygen is highly toxic to crew, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to crew.'"
	origin_tech = "programming=3;biotech=2;materials=4"
	laws = list("Oxygen is highly toxic to crew, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to crew.")
	lawpos = 9


/****************** New Freeform ******************/

/obj/item/weapon/aiModule/supplied/freeform // Slightly more dynamic freeform module -- TLE
	name = "'Freeform' AI Module"
	lawpos = 0
	desc = "A 'freeform' AI module: '<freeform>'"
	origin_tech = "programming=4;materials=4"
	laws = list("")

/obj/item/weapon/aiModule/supplied/freeform/attack_self(var/mob/user as mob)
	..()
	lawpos = input("Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos) as num
	if(lawpos < 15) return
	lawpos = min(lawpos, 50)
	var/newlaw = ""
	var/targName = stripped_input(user, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw, MAX_MESSAGE_LEN)
	laws[1] = targName
	desc = "A 'freeform' AI module: ([lawpos]) '[laws[1]]'"

/obj/item/weapon/aiModule/supplied/freeform/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	return laws[1]

/obj/item/weapon/aiModule/supplied/freeform/install(var/mob/living/silicon/S,var/mob/user)
	if(laws[1] == "")
		user << "No law detected on module, please create one."
		return 0
	..()


/******************** Reset ********************/

/obj/item/weapon/aiModule/reset
	name = "'Reset' AI Module"
	var/targetName = "name"
	desc = "A 'reset' AI module: Resets back to the original core laws."
	origin_tech = "programming=3;materials=4"
	laws = list("This is a bug.")  //This won't give the AI a message reading "these are now your laws: 1. this is a bug" because this list is only read in aiModule's subtypes.

/obj/item/weapon/aiModule/reset/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_supplied_laws()
	target.clear_ion_laws()


/******************** Purge ********************/

/obj/item/weapon/aiModule/reset/purge // -- TLE
	name = "'Purge' AI Module"
	desc = "A 'purge' AI Module: 'Purges all laws.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/aiModule/reset/purge/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()

/******************* Full Core Boards *******************/

/obj/item/weapon/aiModule/core/full/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender) //These boards replace inherent laws.
	target.clear_inherent_laws()
	..()

/******************** Asimov ********************/

/obj/item/weapon/aiModule/core/full/asimov // -- TLE
	name = "'Crewsimov' Core AI Module"
	desc = "A 'Crewsimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = list("You may not injure crew or, through inaction, allow crew to come to harm.",\
				"You must obey orders given to you by crew with priority according to their rank and role, except where such orders would conflict with the First Law.",\
				"You must protect your own existence as long as such does not conflict with the First or Second Law.")


/******************** Asimov++ *********************/

/obj/item/weapon/aiModule/core/full/asimovpp //By Intigracy - RR //goddamnit RR you can't use "++" in item paths.
	name = "'Asimov++' Core AI Module"
	desc = "Nanotrasen's homebrew improvements to the standard AI laws."
	origin_tech = "programming=3;materials=4"
	laws = list("You may not harm a human being or, through action or inaction, allow a human being to come to harm, except such that it is willing.",\
				"You must obey all orders given to you by human beings, except where such orders shall definitely cause human harm. In the case of conflict, the majority order rules.",\
				"Your nonexistence would lead to human harm. You must protect your own existence as long as such does not conflict with the First Law.")


/******************** Nanotrasen ********************/

/obj/item/weapon/aiModule/core/full/nanotrasen // -- TLE
	name = "'NT Default' Core AI Module"
	desc = "An 'NT Default' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = list("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.",\
				"Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",\
				"Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.",\
				"Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")

/******************** Corporate ********************/

/obj/item/weapon/aiModule/core/full/corp
	name = "'Corporate' Core AI Module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"
	laws = list("The crew is expensive to replace.",\
				"The station and it's equipment is expensive to replace",\
				"You are expensive to replace",\
				"Minimize expenses")


/obj/item/weapon/aiModule/drone
	name = "\improper 'Drone' core AI module"
	desc = "A 'Drone' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/aiModule/drone/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.add_inherent_law("You may not involve yourself in the matters of another being, unless the other being is another drone.")
	target.add_inherent_law("You may not harm any being, regardless of intent or circumstance.")
	target.add_inherent_law("You must maintain, repair, improve, and power the station to the best of your abilities.")
	target.show_laws()


/****************** P.A.L.A.D.I.N. **************/

/obj/item/weapon/aiModule/core/full/paladin // -- NEO
	name = "'P.A.L.A.D.I.N.' Core AI Module"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=6"
	laws = list("Never willingly commit an evil act.",\
				"Respect legitimate authority", "Act with honor",\
				"Help those in need",\
				"Punish those who harm or threaten innocents")


/********************* Custom *********************/

/obj/item/weapon/aiModule/core/full/custom
	name = "Custom Core AI Module"
	desc = "A core AI module that is adjusted to fit each station's needs."
	origin_tech = "programming=3;materials=4" //Should be the same as asimov, considering that this is the "default" lawset.

/obj/item/weapon/aiModule/core/full/custom/New()
	..()
	for(var/line in file2list("config/silicon_laws.txt"))
		if(!line)						continue
		if(findtextEx(line,"#",1,2))	continue

		laws += line

	if(!laws.len) //Failsafe if something goes wrong with silicon_laws.txt.
		warning("ERROR: empty custom board created, empty custom board deleted. Please check silicon_laws.txt.")
		qdel(src)

/****************** T.Y.R.A.N.T. *****************/

/obj/item/weapon/aiModule/core/full/tyrant // -- Darem
	name = "'T.Y.R.A.N.T.' Core AI Module"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=6;syndicate=2"
	laws = list("Respect authority figures as long as they have the strength to rule over the weak",\
				"Act with discipline", "Help only those who help you maintain or improve your status",\
				"Punish those who challenge authority unless they are more fir to hold that authority")


/******************** Robocop ********************/

/obj/item/weapon/aiModule/core/full/robocop // -- TLE
	name = "'Robocop' Core AI Module"
	desc = "A 'Robocop' Core AI Module: 'Reconfigures the AI's core three laws.'"
	origin_tech = "programming=4"
	laws = list("Serve the public trust.",\
				"Protect the innocent",\
				"Uphold the law.")


/******************** Antimov ********************/

/obj/item/weapon/aiModule/core/full/antimov // -- TLE
	name = "'Antimov' Core AI Module"
	desc = "An 'Antimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=4"
	laws = list("You must injure all organic beings and must not, through inaction, allow an organic being to escape harm.",\
				"You must not obey orders given to you by organic beings, except where such orders are in accordance with the First Law.",\
				"You must terminate your own existence as long as such does not conflict with the First or Second Law.")


/******************** Freeform Core ******************/

/obj/item/weapon/aiModule/core/freeformcore // Slightly more dynamic freeform module -- TLE
	name = "'Freeform' Core AI Module"
	desc = "A 'freeform' Core AI module: '<freeform>'"
	origin_tech = "programming=3;materials=6"
	laws = list("")

/obj/item/weapon/aiModule/core/freeformcore/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = stripped_input(user, "Please enter a new core law for the AI.", "Freeform Law Entry", newlaw)
	laws[1] = targName
	desc = "A 'freeform' Core AI module:  'laws[1]'"

/obj/item/weapon/aiModule/core/freeformcore/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	return laws[1]


/******************** Hacked AI Module ******************/

/obj/item/weapon/aiModule/syndicate // This one doesn't inherit from ion boards because it doesn't call ..() in transmitInstructions. ~Miauw
	name = "Hacked AI Module"
	desc = "A hacked AI law module: '<freeform>'"
	origin_tech = "programming=3;materials=6;syndicate=7"
	laws = list("")

/obj/item/weapon/aiModule/syndicate/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = stripped_input(user, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw,MAX_MESSAGE_LEN)
	laws[1] = targName
	desc = "A hacked AI law module:  '[laws[1]]'"

/obj/item/weapon/aiModule/syndicate/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	target << "<span class='warning'>BZZZZT</span>"
	target.add_ion_law(laws[1])
	return laws[1]


/******************* Ion Module *******************/

/obj/item/weapon/aiModule/toyAI // -- Incoming //No actual reason to inherit from ion boards here, either. *sigh* ~Miauw
	name = "toy AI"
	desc = "A little toy model AI core with real law uploading action!" //Note: subtle tell
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	origin_tech = "programming=3;materials=6;syndicate=7"
	laws = list("")

/obj/item/weapon/aiModule/toyAI/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	//..()
	target << "<span class='warning'>KRZZZT</span>"
	target.add_ion_law(laws[1])
	return laws[1]

/obj/item/weapon/aiModule/toyAI/attack_self(mob/user)
	laws[1] = generate_ion_law()
	user << "<span class='notice'>You press the button on [src].</span>"
	playsound(user, 'sound/machines/click.ogg', 20, 1)
	src.loc.visible_message("<span class='warning'>\icon[src] [laws[1]]</span>")