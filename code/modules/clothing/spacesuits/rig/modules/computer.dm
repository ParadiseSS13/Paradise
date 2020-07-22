/*
 * Contains
 * /obj/item/rig_module/ai_container
 * /obj/item/rig_module/datajack
 * /obj/item/rig_module/power_sink
 * /obj/item/rig_module/electrowarfare_suite
 */

/obj/item/ai_verbs
	name = "AI verb holder"

/obj/item/ai_verbs/verb/hardsuit_interface()
	set category = "Hardsuit"
	set name = "Open Hardsuit Interface"
	set src in usr

	if(!usr.loc || !usr.loc.loc || !istype(usr.loc.loc, /obj/item/rig_module))
		to_chat(usr, "You are not loaded into a hardsuit.")
		return

	var/obj/item/rig_module/module = usr.loc.loc
	if(!module.holder)
		to_chat(usr, "Your module is not installed in a hardsuit.")
		return

	module.holder.ui_interact(usr, nano_state = contained_state)

/obj/item/rig_module/ai_container

	name = "IIS module"
	desc = "An integrated intelligence system module suitable for most hardsuits."
	icon_state = "IIS"
	toggleable = 1
	usable = 1
	disruptive = 0
	activates_on_touch = 1

	engage_string = "Eject AI"
	activate_string = "Enable Dataspike"
	deactivate_string = "Disable Dataspike"

	interface_name = "integrated intelligence system"
	interface_desc = "A socket that supports a range of artificial intelligence systems."

	var/mob/integrated_ai // Direct reference to the actual mob held in the suit.
	var/obj/item/ai_card  // Reference to the MMI, posibrain, intellicard or pAI card previously holding the AI.
	var/obj/item/ai_verbs/verb_holder

/mob
	var/get_rig_stats = 0

/obj/item/rig_module/ai_container/process()
	if(integrated_ai)
		var/obj/item/rig/rig = get_rig()
		if(rig && rig.ai_override_enabled)
			integrated_ai.get_rig_stats = 1
		else
			integrated_ai.get_rig_stats = 0

/obj/item/rig_module/ai_container/proc/update_verb_holder()
	if(!verb_holder)
		verb_holder = new(src)
	if(integrated_ai)
		verb_holder.forceMove(integrated_ai)
	else
		verb_holder.forceMove(src)

/obj/item/rig_module/ai_container/accepts_item(var/obj/item/input_device, var/mob/living/user)

	// Check if there's actually an AI to deal with.
	var/mob/living/silicon/ai/target_ai
	if(istype(input_device, /mob/living/silicon/ai))
		target_ai = input_device
	else
		target_ai = locate(/mob/living/silicon/ai) in input_device.contents

	var/obj/item/aicard/card = ai_card

	// Downloading from/loading to a terminal.
	if(istype(input_device,/obj/machinery/computer/aifixer) || istype(input_device,/mob/living/silicon/ai) || istype(input_device,/obj/structure/AIcore/deactivated))

		// If we're stealing an AI, make sure we have a card for it.
		if(!card)
			card = new /obj/item/aicard(src)

		// Terminal interaction only works with an intellicarded AI.
		if(!istype(card))
			return 0

		// Since we've explicitly checked for three types, this should be safe.
		card.afterattack(input_device, user, 1)

		// If the transfer failed we can delete the card.
		if(locate(/mob/living/silicon/ai) in card)
			ai_card = card
			integrated_ai = locate(/mob/living/silicon/ai) in card
		else
			eject_ai()
		update_verb_holder()
		return 1

	if(istype(input_device,/obj/item/aicard))
		// We are carding the AI in our suit.
		if(integrated_ai)
			var/obj/item/aicard/ext_card = input_device
			ext_card.afterattack(integrated_ai, user, 1)
			// If the transfer was successful, we can clear out our vars.
			if(integrated_ai.loc != src)
				integrated_ai = null
				eject_ai()
		else
			// You're using an empty card on an empty suit, idiot.
			if(!target_ai)
				return 0
			integrate_ai(input_device,user)
		return 1

	// Okay, it wasn't a terminal being touched, check for all the simple insertions.
	if(input_device.type in list(/obj/item/paicard, /obj/item/mmi, /obj/item/mmi/robotic_brain))
		if(integrated_ai)
			integrated_ai.attackby(input_device,user)
			// If the transfer was successful, we can clear out our vars.
			if(integrated_ai.loc != src)
				integrated_ai = null
				eject_ai()
		else
			integrate_ai(input_device,user)
		return 1

	return 0

/obj/item/rig_module/ai_container/engage(atom/target)

	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!target)
		if(ai_card)
			if(istype(ai_card,/obj/item/aicard))
				ai_card.ui_interact(H, state = deep_inventory_state)
			else
				eject_ai(H)
		update_verb_holder()
		return 1

	if(accepts_item(target,H))
		return 1

	return 0

/obj/item/rig_module/ai_container/removed()
	eject_ai()
	..()

/obj/item/rig_module/ai_container/proc/eject_ai(var/mob/user)

	if(ai_card)
		if(istype(ai_card, /obj/item/aicard))
			if(integrated_ai && !integrated_ai.stat)
				if(user)
					to_chat(user, "<span class='danger'>You cannot eject your currently stored AI. Purge it manually.</span>")
				return 0
			to_chat(user, "<span class='danger'>You purge the remaining scraps of data from your previous AI, freeing it for use.</span>")
			QDEL_NULL(integrated_ai)
			QDEL_NULL(ai_card)
		else if(user)
			user.put_in_hands(ai_card)
		else
			ai_card.forceMove(get_turf(src))
	ai_card = null
	integrated_ai = null
	update_verb_holder()



/obj/item/rig_module/ai_container/proc/integrate_ai(var/obj/item/ai,var/mob/user)
	if(!ai) return

	// The ONLY THING all the different AI systems have in common is that they all store the mob inside an item.
	var/mob/living/ai_mob = locate(/mob/living) in ai.contents
	if(ai_mob)
		if(ai_mob.key && ai_mob.client)
			if(istype(ai, /obj/item/aicard))
				var/mob/living/silicon/ai/ROBUTT = ai_mob
				if(istype(ROBUTT))
					if(!ai_card)
						ai_card = new /obj/item/aicard(src)

					var/obj/item/aicard/source_card = ai
					var/obj/item/aicard/target_card = ai_card
					if(istype(source_card) && istype(target_card))
						ROBUTT.forceMove(target_card)
						ROBUTT.aiRestorePowerRoutine = 0//So the AI initially has power.
						ROBUTT.control_disabled = 1//Can't control things remotely if you're stuck in a card!
						ROBUTT.aiRadio.disabledAi = 1 	//No talking on the built-in radio for you either!
						source_card.update_state()
						target_card.update_state()
					else
						return 0

			else
				user.unEquip(ai)
				ai.forceMove(src)
				ai_card = ai
				to_chat(ai_mob, "<font color='blue'>You have been transferred to \the [holder]'s [src].</font>")
				to_chat(user, "<font color='blue'>You load [ai_mob] into \the [holder]'s [src].</font>")

			integrated_ai = ai_mob

			if(!(locate(integrated_ai) in ai_card))
				integrated_ai = null
				eject_ai()
		else
			to_chat(user, "<span class='warning'>There is no active AI within \the [ai].</span>")
	else
		to_chat(user, "<span class='warning'>There is no active AI within \the [ai].</span>")
	update_verb_holder()

/obj/item/rig_module/datajack

	name = "datajack module"
	desc = "A simple induction datalink module."
	icon_state = "datajack"
	toggleable = 1
	activates_on_touch = 1
	usable = 0

	activate_string = "Enable Datajack"
	deactivate_string = "Disable Datajack"

	interface_name = "contact datajack"
	interface_desc = "An induction-powered high-throughput datalink suitable for hacking encrypted networks."
	var/list/stored_research

/obj/item/rig_module/datajack/New()
	..()
	stored_research = list()

/obj/item/rig_module/datajack/engage(atom/target)

	if(!..())
		return 0

	if(target)
		var/mob/living/carbon/human/H = holder.wearer
		if(!accepts_item(target,H))
			return 0
	return 1

/obj/item/rig_module/datajack/accepts_item(var/obj/item/input_device, var/mob/living/user)

	if(istype(input_device,/obj/item/disk/tech_disk))
		to_chat(user, "You slot the disk into [src].")
		var/obj/item/disk/tech_disk/disk = input_device
		if(disk.stored)
			if(load_data(disk.stored))
				to_chat(user, "<font color='blue'>Download successful; disk erased.</font>")
				disk.stored = null
			else
				to_chat(user, "<span class='warning'>The disk is corrupt. It is useless to you.</span>")
		else
			to_chat(user, "<span class='warning'>The disk is blank. It is useless to you.</span>")
		return 1

	// I fucking hate R&D code. This typecheck spam would be totally unnecessary in a sane setup.
	else if(istype(input_device,/obj/machinery))
		var/datum/research/incoming_files
		if(istype(input_device,/obj/machinery/computer/rdconsole))
			var/obj/machinery/computer/rdconsole/input_machine = input_device
			incoming_files = input_machine.files
		else if(istype(input_device,/obj/machinery/r_n_d/server))
			var/obj/machinery/r_n_d/server/input_machine = input_device
			incoming_files = input_machine.files
		else if(istype(input_device,/obj/machinery/mecha_part_fabricator))
			var/obj/machinery/mecha_part_fabricator/input_machine = input_device
			incoming_files = input_machine.files

		if(!incoming_files || !incoming_files.known_tech || !incoming_files.known_tech.len)
			to_chat(user, "<span class='warning'>Memory failure. There is nothing accessible stored on this terminal.</span>")
		else
			// Maybe consider a way to drop all your data into a target repo in the future.
			if(load_data(incoming_files.known_tech))
				to_chat(user, "<font color='blue'>Download successful; local and remote repositories synchronized.</font>")
			else
				to_chat(user, "<span class='warning'>Scan complete. There is nothing useful stored on this terminal.</span>")
		return 1
	return 0

/obj/item/rig_module/datajack/proc/load_data(var/incoming_data)

	if(islist(incoming_data))
		for(var/entry in incoming_data)
			load_data(entry)
		return 1

	if(istype(incoming_data, /datum/tech))
		var/data_found
		var/datum/tech/new_data = incoming_data
		for(var/datum/tech/current_data in stored_research)
			if(current_data.id == new_data.id)
				data_found = 1
				if(current_data.level < new_data.level)
					current_data.level = new_data.level
				break
		if(!data_found)
			stored_research += incoming_data
		return 1
	return 0

/obj/item/rig_module/electrowarfare_suite

	name = "electrowarfare module"
	desc = "A bewilderingly complex bundle of fiber optics and chips."
	icon_state = "ewar"
	toggleable = 1
	usable = 0

	activate_string = "Enable Countermeasures"
	deactivate_string = "Disable Countermeasures"

	interface_name = "electrowarfare system"
	interface_desc = "An active counter-electronic warfare suite that disrupts AI tracking."

/obj/item/rig_module/electrowarfare_suite/activate()

	if(!..())
		return

	// This is not the best way to handle this, but I don't want it to mess with ling camo
	var/mob/living/M = holder.wearer
	M.digitalcamo++

/obj/item/rig_module/electrowarfare_suite/deactivate()

	if(!..())
		return

	var/mob/living/M = holder.wearer
	M.digitalcamo = max(0,(M.digitalcamo-1))

/* //Not easily compatible with our current powernet, and is
/obj/item/rig_module/power_sink // quite stupid anyways, iyam

	name = "hardsuit power sink"
	desc = "An heavy-duty power sink."
	icon_state = "powersink"
	toggleable = 1
	activates_on_touch = 1
	disruptive = 0

	activate_string = "Enable Power Sink"
	deactivate_string = "Disable Power Sink"

	interface_name = "niling d-sink"
	interface_desc = "Colloquially known as a power siphon, this module drains power through the suit hands into the suit battery."

	var/atom/interfaced_with // Currently draining power from this device.
	var/total_power_drained = 0
	var/drain_loc

/obj/item/rig_module/power_sink/deactivate()

	if(interfaced_with)
		if(holder && holder.wearer)
			to_chat(holder.wearer, "<span class = 'warning'>Your power sink retracts as the module deactivates.</span>")
		drain_complete()
	interfaced_with = null
	total_power_drained = 0
	return ..()

/obj/item/rig_module/power_sink/activate()
	interfaced_with = null
	total_power_drained = 0
	return ..()

/obj/item/rig_module/power_sink/engage(atom/target)

	if(!..())
		return 0

	//Target wasn't supplied or we're already draining.
	if(interfaced_with)
		return 0

	if(!target)
		return 1

	// Are we close enough?
	var/mob/living/carbon/human/H = holder.wearer
	if(!target.Adjacent(H))
		return 0

	// Is it a valid power source?
	if(target.drain_power(1) <= 0)
		return 0

	to_chat(H, "<span class = 'danger'>You begin draining power from [target]!</span>")
	interfaced_with = target
	drain_loc = interfaced_with.loc

	holder.spark_system.start()
	playsound(H.loc, 'sound/effects/sparks2.ogg', 50, 1)

	return 1

/obj/item/rig_module/power_sink/accepts_item(var/obj/item/input_device, var/mob/living/user)
	var/can_drain = input_device.drain_power(1)
	if(can_drain > 0)
		engage(input_device)
		return 1
	return 0

/obj/item/rig_module/power_sink/process()

	if(!interfaced_with)
		return ..()

	var/mob/living/carbon/human/H
	if(holder && holder.wearer)
		H = holder.wearer

	if(!H || !istype(H))
		return 0

	holder.spark_system.start()
	playsound(H.loc, 'sound/effects/sparks2.ogg', 50, 1)

	if(!holder.cell)
		to_chat(H, "<span class = 'danger'>Your power sink flashes an error; there is no cell in your rig.</span>")
		drain_complete(H)
		return

	if(!interfaced_with || !interfaced_with.Adjacent(H) || !(interfaced_with.loc == drain_loc))
		to_chat(H, "<span class = 'warning'>Your power sink retracts into its casing.</span>")
		drain_complete(H)
		return

	if(holder.cell.fully_charged())
		to_chat(H, "<span class = 'warning'>Your power sink flashes an amber light; your rig cell is full.</span>")
		drain_complete(H)
		return

	// Attempts to drain up to 40kW, determines this value from remaining cell capacity to ensure we don't drain too much..
	var/to_drain = min(40000, ((holder.cell.maxcharge - holder.cell.charge) / CELLRATE))
	var/target_drained = interfaced_with.drain_power(0,0,to_drain)
	if(target_drained <= 0)
		to_chat(H, "<span class = 'danger'>Your power sink flashes a red light; there is no power left in [interfaced_with].</span>")
		drain_complete(H)
		return

	holder.cell.give(target_drained * CELLRATE)
	total_power_drained += target_drained

	return 1

/obj/item/rig_module/power_sink/proc/drain_complete(var/mob/living/M)

	if(!interfaced_with)
		to_chat(if(M) M, "<font color='blue'><b>Total power drained:</b> [round(total_power_drained/1000)]kJ.</font>")
	else
		to_chat(if(M) M, "<font color='blue'><b>Total power drained from [interfaced_with]:</b> [round(total_power_drained/1000)]kJ.</font>")
		interfaced_with.drain_power(0,1,0) // Damage the victim.

	drain_loc = null
	interfaced_with = null
	total_power_drained = 0*/

/*
//Maybe make this use power when active or something
/obj/item/rig_module/emp_shielding
	name = "\improper EMP dissipation module"
	desc = "A bewilderingly complex bundle of fiber optics and chips."
	toggleable = 1
	usable = 0

	activate_string = "Enable active EMP shielding"
	deactivate_string = "Disable active EMP shielding"

	interface_name = "active EMP shielding system"
	interface_desc = "A highly experimental system that augments the hardsuit's existing EM shielding."
	var/protection_amount = 20

/obj/item/rig_module/emp_shielding/activate()
	if(!..())
		return

	holder.emp_protection += protection_amount

/obj/item/rig_module/emp_shielding/deactivate()
	if(!..())
		return

	holder.emp_protection = max(0,(holder.emp_protection - protection_amount))
*/
