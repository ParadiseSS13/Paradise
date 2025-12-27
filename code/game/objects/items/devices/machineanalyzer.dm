/obj/item/robotanalyzer
	name = "machine analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries and the condition of machinery."
	icon = 'icons/obj/device.dmi'
	icon_state = "robotanalyzer"
	inhand_icon_state = "analyzer"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 5
	throw_range = 10
	origin_tech = "magnets=1;biotech=1"

/obj/item/robotanalyzer/proc/handle_clumsy(mob/living/user)
	var/list/msgs = list()
	user.visible_message(SPAN_WARNING("[user] has analyzed the floor's components!"), SPAN_WARNING("You try to analyze the floor's vitals!"))
	msgs += SPAN_NOTICE("Analyzing Results for The floor:\n\t Overall Status: Unknown")
	msgs += SPAN_NOTICE("\t Damage Specifics: <font color='#FFA500'>[0]</font>/<font color='red'>[0]</font>")
	msgs += SPAN_NOTICE("Key: <font color='#FFA500'>Burns</font><font color ='red'>/Brute</font>")
	msgs += SPAN_NOTICE("Chassis Temperature: ???")
	to_chat(user, chat_box_healthscan(msgs.Join("<br>")))

/obj/item/robotanalyzer/attack_obj__legacy__attackchain(obj/machinery/M, mob/living/user) // Scanning a machine object
	if(!ismachinery(M))
		return
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50))
		handle_clumsy(user)
		return
	user.visible_message(SPAN_NOTICE("[user] has analyzed [M]'s components with [src]."), SPAN_NOTICE("You analyze [M]'s components with [src]."))
	machine_scan(user, M)
	add_fingerprint(user)

/obj/item/robotanalyzer/proc/machine_scan(mob/user, obj/machinery/M)
	if(M.obj_integrity == M.max_integrity)
		to_chat(user, SPAN_NOTICE("[M] is at full integrity."))
		return
	to_chat(user, SPAN_NOTICE("Structural damage detected! [M]'s overall estimated integrity is [round((M.obj_integrity / M.max_integrity) * 100)]%."))
	if(M.stat & BROKEN) // Displays alongside above message. Machines with a "broken" state do not become broken at 0% HP - anything that reaches that point is destroyed
		to_chat(user, SPAN_WARNING("Further analysis: Catastrophic component failure detected! [M] requires reconstruction to fully repair."))

/obj/item/robotanalyzer/attack__legacy__attackchain(mob/living/M, mob/living/user) // Scanning borgs, IPCs/augmented crew, and AIs
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50))
		handle_clumsy(user)
		return
	user.visible_message(SPAN_NOTICE("[user] has analyzed [M]'s components with [src]."), SPAN_NOTICE("You analyze [M]'s components with [src]."))
	robot_healthscan(user, M)
	add_fingerprint(user)

/proc/robot_healthscan(mob/user, mob/living/M)
	var/scan_type
	var/list/msgs = list()
	if(isrobot(M))
		scan_type = "robot"
	else if(ishuman(M))
		scan_type = "prosthetics"
	else if(is_ai(M))
		scan_type = "ai"
	else
		to_chat(user, SPAN_WARNING("You can't analyze non-robotic things!"))
		return

	switch(scan_type)
		if("robot")
			var/burn = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
			var/brute = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
			msgs += SPAN_NOTICE("Analyzing Results for [M]:\n\t Overall Status: [M.stat == DEAD ? "fully disabled" : "[M.health]% functional"]")
			msgs += "\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>"
			msgs += "\t Damage Specifics: <font color='#FFA500'>[burn]</font> - <font color='red'>[brute]</font>"
			if(M.timeofdeath && M.stat == DEAD)
				msgs += SPAN_NOTICE("Time of disable: [station_time_timestamp("hh:mm:ss", M.timeofdeath)]")
			var/mob/living/silicon/robot/H = M
			var/list/damaged = H.get_damaged_components(TRUE, TRUE, TRUE) // Get all except the missing ones
			var/list/missing = H.get_missing_components()
			msgs += SPAN_NOTICE("Localized Damage:")
			if(!LAZYLEN(damaged) && !LAZYLEN(missing))
				msgs += SPAN_NOTICE("\t Components are OK.")
			else
				if(LAZYLEN(damaged))
					for(var/datum/robot_component/org in damaged)
						msgs += text("<span class='notice'>\t []: [][] - [] - [] - []</span>",	\
						capitalize(org.name),					\
						(org.is_destroyed())	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
						(org.electronics_damage > 0)	?	"<font color='#FFA500'>[org.electronics_damage]</font>"	:0,	\
						(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
						(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
						(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>")
				if(LAZYLEN(missing))
					for(var/datum/robot_component/org in missing)
						msgs += SPAN_WARNING("\t [capitalize(org.name)]: MISSING")

			if(H.emagged && prob(5))
				msgs += SPAN_WARNING("\t ERROR: INTERNAL SYSTEMS COMPROMISED")

		if("prosthetics")
			var/mob/living/carbon/human/H = M
			var/is_ipc = ismachineperson(H)
			msgs += "<span class='notice'>Analyzing Results for [M]: [is_ipc ? "\n\t Overall Status: [H.stat == DEAD ? "fully disabled" : "[H.health]% functional"]</span><hr>" : "<hr>"]" //for the record im sorry
			msgs += "\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>"
			msgs += SPAN_NOTICE("External prosthetics:")
			var/organ_found
			if(LAZYLEN(H.internal_organs))
				for(var/obj/item/organ/external/E in H.bodyparts)
					if(!E.is_robotic() || (is_ipc && (E.get_damage() == 0))) //Non-IPCs have their cybernetics show up in the scan, even if undamaged
						continue
					organ_found = TRUE
					msgs += "[E.name]: <font color='red'>[E.brute_dam]</font> <font color='#FFA500'>[E.burn_dam]</font>"
			if(!organ_found)
				msgs += SPAN_WARNING("No prosthetics located.")
			msgs += "<hr>"
			msgs += SPAN_NOTICE("Internal prosthetics:")
			organ_found = null
			if(LAZYLEN(H.internal_organs))
				for(var/obj/item/organ/internal/O in H.internal_organs)
					if(!O.is_robotic() || istype(O, /obj/item/organ/internal/cyberimp) || O.stealth_level > 1)
						continue
					organ_found = TRUE
					msgs += "[capitalize(O.name)]: <font color='red'>[O.status & ORGAN_DEAD ? "CRITICAL FAILURE" : O.damage]</font>"
			if(!organ_found)
				msgs += SPAN_WARNING("No prosthetics located.")
			msgs += "<hr>"
			msgs += SPAN_NOTICE("Cybernetic implants:")
			organ_found = null
			if(LAZYLEN(H.internal_organs))
				for(var/obj/item/organ/internal/cyberimp/I in H.internal_organs)
					if(I.stealth_level > 1)
						continue
					organ_found = TRUE
					msgs += "[capitalize(I.name)]: <font color='red'>[(I.crit_fail || I.status & ORGAN_DEAD) ? "CRITICAL FAILURE" : I.damage]</font>"
			if(!organ_found)
				msgs += SPAN_WARNING("No implants located.")
			msgs += "<hr>"
			if(is_ipc)
				msgs.Add(get_chemscan_results(user, H))
			msgs += SPAN_NOTICE("Subject temperature: [round(H.bodytemperature-T0C, 0.01)]&deg;C ([round(H.bodytemperature*1.8-459.67, 0.01)]&deg;F)")
		if("ai")
			var/mob/living/silicon/ai/A = M
			var/burn = A.getFireLoss() > 50 	? 	"<b>[A.getFireLoss()]</b>" 		: A.getFireLoss()
			var/brute = A.getBruteLoss() > 50 	? 	"<b>[A.getBruteLoss()]</b>" 	: A.getBruteLoss()
			msgs += SPAN_NOTICE("Analyzing Results for [M]:\n\t Overall Status: [A.stat == DEAD ? "fully disabled" : "[A.health]% functional"]")
			msgs += "\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>"
			msgs += "\t Damage Specifics: <font color='#FFA500'>[burn]</font> - <font color='red'>[brute]</font>"

	to_chat(user, chat_box_healthscan(msgs.Join("<br>")))
