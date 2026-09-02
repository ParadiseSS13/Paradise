/obj/item/mmi
	name = "\improper Man-Machine Interface"
	desc = "A compact, highly portable self-contained life support system, capable of housing a single brain and allowing it to seamlessly interface with whatever it is installed into. \
	It can be installed into a cyborg shell, AI core, mech, spiderbot, or an Integrated Robotic Chassis' chest cavity."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	origin_tech = "biotech=2;programming=3;engineering=2"
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	new_attack_chain = TRUE

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.
	var/alien = 0
	var/syndiemmi = FALSE //Whether or not this is a Syndicate MMI
	var/mmi_item_name = "Man-Machine Interface" //Used to name the item when installing a brain
	var/mob/living/brain/brainmob = null//The current occupant.
	var/obj/item/organ/internal/brain/held_brain = null // This is so MMI's aren't brainscrubber 9000's
	var/mob/living/silicon/robot/robot = null//Appears unused.
	var/obj/mecha/mecha = null//This does not appear to be used outside of reference in mecha.dm.
// I'm using this for mechs giving MMIs HUDs now

	var/obj/item/radio/radio = null // For use with the radio MMI upgrade
	var/datum/action/generic/configure_mmi_radio/radio_action = null

	// Used for cases when mmi or one of it's children commits suicide.
	// Needed to fix a rather insane bug when a posibrain/robotic brain commits suicide
	var/dead_icon = "mmi_dead"

	/// Time at which the ghost belonging to the mind in the mmi can be pinged again to be borged
	var/next_possible_ghost_ping
	//Used by syndie MMIs, stores the master's mind UID for later referencing
	var/master_uid = null
	/// Extended description on examine_more
	var/extended_desc = "Development of Man-Machine Interfaces can be dated all the way back to the late 20th century within the Sol system, but the first viable designs didn't emerge until 2408 when Zeng-Hu Pharmaceuticals and Bishop Cybernetics unveiled a co-developed unit and established dominance over the niche market that persists into the present day. \
	The brain is submerged in a preservation fluid rich in mannitol, mitocholide, dissolved oxygen (or functional equivalent in other species) as well as a carefully tuned mixture of nutrients, hormones, peptides, and various other essential substances produced by a specialised chemical synthesiser. \
	A non-invasive neural interface uses a combination of targeted magnetic pulses, micro-electric discharges, and a grid of highly sensitive EMF probes allow a two-way connection between the MMI and the brain. On-board microphones, cameras, and a speaker provide basic sensory input and a method of communication, which can be expanded with an optional radio upgrade. Any further functionality must be provided by whatever the MMI is installed into. \
	Brains housed inside an MMI are effectively biologically immortal, provided the unit remains powered."

/obj/item/mmi/examine_more(mob/user)
	. = ..()
	. += extended_desc

/obj/item/mmi/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/organ/internal/brain) && !brainmob) // Time to stick a brain in it --NEO
		if(istype(used, /obj/item/organ/internal/brain/golem))
			to_chat(user, SPAN_WARNING("You can't find a way to plug [used] into [src]."))
			return ITEM_INTERACT_COMPLETE
		var/obj/item/organ/internal/brain/B = used
		if(!B.brainmob)
			to_chat(user, SPAN_WARNING("You aren't sure where this brain came from, but you're pretty sure it's a useless brain."))
			return ITEM_INTERACT_COMPLETE
		if(held_brain)
			to_chat(user, SPAN_USERDANGER("Somehow, this MMI still has a brain in it. Report this to the bug tracker."))
			CRASH("[user] tried to stick a [used] into [src] in [get_area(src)], but the held brain variable wasn't cleared")
		if(user.drop_item())
			B.forceMove(src)
			if(!syndiemmi)
				visible_message(SPAN_NOTICE("[user] sticks \a [used] into \the [src]."))
			brainmob = B.brainmob
			B.brainmob = null
			brainmob.container = src
			brainmob.forceMove(src)
			REMOVE_TRAIT(brainmob, TRAIT_RESPAWNABLE, GHOSTED)
			brainmob.set_stat(CONSCIOUS)
			// If they suicided as an MMI, re-inserting them should
			// restore their ability to suicide.
			brainmob.suiciding = FALSE
			brainmob.see_invisible = initial(brainmob.see_invisible)
			GLOB.dead_mob_list -= brainmob//Update dem lists
			GLOB.alive_mob_list += brainmob

			held_brain = B
			if(istype(used, /obj/item/organ/internal/brain/xeno)) // kept the type check, as it still does other weird stuff
				name = "\improper [mmi_item_name]: Alien - [brainmob.real_name]"
				icon = 'icons/mob/alien.dmi'
				become_occupied("AlienMMI")
				alien = TRUE
			else
				name = "\improper [mmi_item_name]: [brainmob.real_name]"
				icon = B.mmi_icon
				become_occupied("[B.mmi_icon_state]")
				alien = FALSE

			if(radio_action)
				radio_action.build_all_button_icons()
			SSblackbox.record_feedback("amount", "mmis_filled", 1)
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, SPAN_WARNING("You can't drop [B]!"))
	if(istype(used, /obj/item/mmi_radio_upgrade))
		if(radio)
			to_chat(user, SPAN_WARNING("[src] already has a radio installed."))
			return ITEM_INTERACT_COMPLETE
		user.visible_message(SPAN_NOTICE("[user] begins to install [used] into [src]..."), \
			SPAN_NOTICE("You start to install [used] into [src]..."))
		if(do_after(user, 2 SECONDS, target=src))
			if(user.drop_item())
				user.visible_message(SPAN_NOTICE("[user] installs [used] in [src]."), \
					SPAN_NOTICE("You install [used] in [src]."))
				if(brainmob)
					to_chat(brainmob, SPAN_NOTICE("MMI radio capability installed."))
					install_radio()
					qdel(used)
					return ITEM_INTERACT_COMPLETE
			else
				to_chat(user, SPAN_WARNING("You can't drop [used]!"))
	if(istype(used, /obj/item/stack/nanopaste)) // MMIs can get EMP damaged too so this isn't just for robobrains
		if(!brainmob)
			return ITEM_INTERACT_COMPLETE
		var/obj/item/stack/nanopaste/nano = used
		if(nano.use(1))
			brainmob.rejuvenate()
			to_chat(user, SPAN_NOTICE("You repair the damage on [src]."))
			return ITEM_INTERACT_COMPLETE

/obj/item/mmi/screwdriver_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0))
		return
	if(!radio)
		to_chat(user, SPAN_WARNING("There is no radio in [src]!"))
		return
	user.visible_message(SPAN_WARNING("[user] begins to uninstall the radio from [src]..."), \
							SPAN_NOTICE("You start to uninstall the radio from [src]..."))
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || !radio)
		return
	uninstall_radio()
	new /obj/item/mmi_radio_upgrade(get_turf(src))
	user.visible_message(SPAN_WARNING("[user] uninstalls the radio from [src]."), \
						SPAN_NOTICE("You uninstall the radio from [src]."))
	return TRUE


/obj/item/mmi/activate_self(mob/user)
	if(..() || !brainmob || !held_brain)
		return
	to_chat(user, SPAN_NOTICE("You unlock and upend the MMI, spilling the brain onto the floor."))
	dropbrain(get_turf(user))
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	name = initial(name)

/obj/item/mmi/proc/transfer_identity(mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->robot people.
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	brainmob.container = src

	if(!istype(H.dna.species) || isnull(H.dna.species.return_organ("brain"))) // Diona/buggy people
		held_brain = new(src)
	else // We have a species, and it has a brain
		var/brain_path = H.dna.species.return_organ("brain")
		if(!ispath(brain_path, /obj/item/organ/internal/brain))
			brain_path = /obj/item/organ/internal/brain
		held_brain = new brain_path(src) // Slime people will keep their slimy brains this way
	held_brain.dna = brainmob.dna.Clone()
	held_brain.name = "\the [brainmob.name]'s [initial(held_brain.name)]"

	name = "\improper [mmi_item_name]: [brainmob.real_name]"
	become_occupied("mmi_full")

//I made this proc as a way to have a brainmob be transferred to any created brain, and to solve the
//problem i was having with alien/nonalien brain drops.
/obj/item/mmi/proc/dropbrain(turf/dropspot)
	if(isnull(held_brain))
		stack_trace("[src] at [loc] attempted to drop brain without a contained brain in [get_area(src)].")
		to_chat(brainmob, SPAN_USERDANGER("Your MMI did not contain a brain! We'll make a new one for you, but you'd best report this to the bugtracker!"))
		held_brain = new(dropspot) // Let's not ruin someone's round because of something dumb -- Crazylemon
		held_brain.dna = brainmob.dna.Clone()
		held_brain.name = "\the [brainmob.name]'s [initial(held_brain.name)]"

	brainmob.container = null//Reset brainmob mmi var.
	brainmob.forceMove(held_brain) //Throw mob into brain.
	ADD_TRAIT(brainmob, TRAIT_RESPAWNABLE, GHOSTED)
	GLOB.alive_mob_list -= brainmob//Get outta here
	held_brain.brainmob = brainmob//Set the brain to use the brainmob
	held_brain.brainmob.cancel_camera()
	brainmob = null//Set mmi brainmob var to null
	held_brain.forceMove(dropspot)
	held_brain = null

/obj/item/mmi/proc/become_occupied(new_icon)
	icon_state = new_icon
	if(radio)
		radio_action.build_all_button_icons()

/obj/item/mmi/examine(mob/user)
	. = ..()
	if(radio)
		. += SPAN_NOTICE("A radio is installed on [src].")

/obj/item/mmi/proc/install_radio()
	radio = new(src)
	radio.broadcasting = TRUE
	radio_action = new(radio, src)
	if(brainmob && brainmob.loc == src)
		radio_action.Grant(brainmob)

/obj/item/mmi/proc/uninstall_radio()
	QDEL_NULL(radio)
	QDEL_NULL(radio_action)

/datum/action/generic/configure_mmi_radio
	name = "Configure MMI Radio"
	desc = "Configure the radio installed in your MMI."
	check_flags = AB_CHECK_CONSCIOUS
	procname = "ui_interact"
	var/obj/item/mmi = null

/datum/action/generic/configure_mmi_radio/New(Target, obj/item/mmi/M)
	. = ..()
	mmi = M

/datum/action/generic/configure_mmi_radio/Destroy()
	mmi = null
	return ..()

/datum/action/generic/configure_mmi_radio/apply_button_overlay(atom/movable/screen/movable/action_button/current_button)
	button_icon = mmi.icon
	button_icon_state = mmi.icon_state
	..()

/obj/item/mmi/emp_act(severity)
	if(!brainmob)
		return

	if(issilicon(loc)) // Silicons aren't affected by brain damage and there is no way to fix silicon brain damage either.
		return

	switch(severity)
		if(1)
			brainmob.emp_damage += rand(20, 30)
		if(2)
			brainmob.emp_damage += rand(10, 20)
		if(3)
			brainmob.emp_damage += rand(0, 10)
	..()

/obj/item/mmi/Destroy()
	if(isrobot(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	QDEL_NULL(brainmob)
	QDEL_NULL(held_brain)
	QDEL_NULL(radio)
	QDEL_NULL(radio_action)
	return ..()

// These two procs are important for when an MMI pilots a mech
// (Brainmob "enters/leaves" the MMI when piloting)
// Also neatly handles basically every case where a brain
// is inserted or removed from an MMI
/obj/item/mmi/Entered(atom/movable/A)
	if(radio && isbrain(A))
		radio_action.Grant(A)

/obj/item/mmi/Exited(atom/movable/A)
	if(radio && isbrain(A))
		radio_action.Remove(A)


/obj/item/mmi/attempt_become_organ(obj/item/organ/external/parent,mob/living/carbon/human/H)
	if(!brainmob)
		return 0
	if(!parent)
		log_debug("Attempting to insert into a null parent!")
		return 0
	if(H.get_int_organ(/obj/item/organ/internal/brain))
		// one brain at a time
		return 0
	var/obj/item/organ/internal/brain/mmi_holder/holder = new()
	holder.parent_organ = parent.limb_name
	forceMove(holder)
	holder.stored_mmi = src
	holder.update_from_mmi()
	if(brainmob && brainmob.mind)
		brainmob.mind.transfer_to(H)
	holder.insert(H)

	return 1

// As a synthetic, the only limit on visibility is view range
/obj/item/mmi/contents_ui_distance(src_object, mob/living/user)
	. = ..()
	if((src_object in view(src)) && get_dist(src_object, src) <= user.client.maxview())
		return UI_INTERACTIVE	// interactive (green visibility)
	return user.shared_living_ui_distance()

/obj/item/mmi/forceMove(atom/destination)
	if(!brainmob)
		return ..()

	var/atom/old_loc = loc
	if(issilicon(old_loc) && !issilicon(destination))
		var/mob/living/silicon/S = old_loc
		brainmob.weather_immunities -= S.weather_immunities
	else if(issilicon(destination))
		var/mob/living/silicon/S = destination
		brainmob.weather_immunities |= S.weather_immunities

	. = ..()
	brainmob.update_runechat_msg_location()


/obj/item/mmi/syndie
	name = "\improper Syndicate Man-Machine Interface"
	desc = "The Syndicate's own brand of MMI. Mindslaves any brain inserted into it for as long as it's inside. Cyborgs, mechs, spiderbots, or IRCs made with this MMI will be slaved to the owner. Does not fit into NT AI cores. \
	Cyborgs will appear to be linked to an AI (if present). If someone attempts to detonate the cyborg, it will automatically block the attempt and then disconnect from the AI. No emagged equipment is provided."
	origin_tech = "biotech=4;programming=4;syndicate=2"
	syndiemmi = TRUE
	mmi_item_name = "Syndicate Man-Machine Interface"
	extended_desc = "Before the development of the mindslave implant, the mind-controlling technology was first prototyped using existing MMI systems. The unfettered access given to the user's brain made the task of delivering the memetic payloads trivial, allowing for brainwashing techniques to be perfected before moving on to a miniaturised implant. \
		Whilst these specialty MMIs are rarely used owing to the far greater applicability and convenience of the mindslave implant, they do see occasional employment by undercover agents that wish to stealthily convert the AI-slaved cyborgs of Nanotrasen. \
		Just like the mindslave implant, these are extremely illegal in most regions of space. Simple possession (to say nothing of actual use) generally warrants a very long prison sentence. \
		The manufacturer of these devices remains unknown, though independent observers have noted similarities in the design to contemporary Cybersun electronics. The company, naturally, denies all such associations."

/obj/item/mmi/syndie/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!master_uid && ishuman(user) && user.mind && istype(used, /obj/item/organ/internal/brain))
		to_chat(user, SPAN_NOTICE("You press your thumb on [src] and imprint your user information."))
		master_uid = user.mind.UID()
		if(!user.mind.has_antag_datum(/datum/antagonist/traitor))
			message_admins("[user] has mindslaved [used] using a Syndicate MMI, but they are not a traitor!")
	return ..()

/obj/item/mmi/syndie/become_occupied(new_icon)
	..()
	brainmob.mind.remove_antag_datum(/datum/antagonist/mindslave) //Overrides any previous mindslaving

	if(master_uid)
		var/datum/mind/master = locateUID(master_uid)

		if(master)
			to_chat(brainmob, SPAN_USERDANGER("You feel the MMI overriding your free will!"))
			brainmob.mind.add_antag_datum(new /datum/antagonist/mindslave(master))
			return

	//Edgecase handling, shouldn't get here
	to_chat(brainmob, SPAN_USERDANGER("You feel the MMI overriding your free will. You are now loyal to the Syndicate! Assist Syndicate Agents to the best of your abilities."))
	message_admins("[src] received a brain but has no master. A generic syndicate zeroth law will be installed instead of a full mindslaving.")

/obj/item/mmi/syndie/dropbrain(turf/dropspot)
	brainmob.mind.remove_antag_datum(/datum/antagonist/mindslave)
	master_uid = null
	to_chat(brainmob, SPAN_USERDANGER("You are no longer a mindslave: You have complete and free control of your own faculties once more!"))
	..()
