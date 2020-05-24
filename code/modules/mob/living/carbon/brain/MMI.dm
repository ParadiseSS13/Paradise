/obj/item/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "biotech=3"
	origin_tech = "biotech=2;programming=3;engineering=2"

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.
	var/alien = 0
	var/syndiemmi = 0 //Whether or not this is a Syndicate MMI
	var/mob/living/carbon/brain/brainmob = null//The current occupant.
	var/obj/item/organ/internal/brain/held_brain = null // This is so MMI's aren't brainscrubber 9000's
	var/mob/living/silicon/robot/robot = null//Appears unused.
	var/obj/mecha/mecha = null//This does not appear to be used outside of reference in mecha.dm.
// I'm using this for mechs giving MMIs HUDs now

	var/obj/item/radio/radio = null // For use with the radio MMI upgrade
	var/datum/action/generic/configure_mmi_radio/radio_action = null

	// Used for cases when mmi or one of it's children commits suicide.
	// Needed to fix a rather insane bug when a posibrain/robotic brain commits suicide
	var/dead_icon = "mmi_dead"

/obj/item/mmi/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/organ/internal/brain/crystal))
		to_chat(user, "<span class='warning'> This brain is too malformed to be able to use with the [src].</span>")
		return
	if(istype(O, /obj/item/organ/internal/brain/golem))
		to_chat(user, "<span class='warning'>You can't find a way to plug [O] into [src].</span>")
		return
	if(istype(O,/obj/item/organ/internal/brain) && !brainmob) //Time to stick a brain in it --NEO
		var/obj/item/organ/internal/brain/B = O
		if(!B.brainmob)
			to_chat(user, "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain.</span>")
			return
		if(held_brain)
			to_chat(user, "<span class='userdanger'>Somehow, this MMI still has a brain in it. Report this to the bug tracker.</span>")
			log_runtime(EXCEPTION("[user] tried to stick a [O] into [src] in [get_area(src)], but the held brain variable wasn't cleared"), src)
			return
		if(user.drop_item())
			B.forceMove(src)
			visible_message("<span class='notice'>[user] sticks \a [O] into \the [src].</span>")
			brainmob = B.brainmob
			B.brainmob = null
			brainmob.forceMove(src)
			brainmob.container = src
			brainmob.stat = CONSCIOUS
			GLOB.respawnable_list -= brainmob
			GLOB.dead_mob_list -= brainmob//Update dem lists
			GLOB.living_mob_list += brainmob

			held_brain = B
			if(istype(O,/obj/item/organ/internal/brain/xeno)) // kept the type check, as it still does other weird stuff
				name = "Man-Machine Interface: Alien - [brainmob.real_name]"
				icon = 'icons/mob/alien.dmi'
				become_occupied("AlienMMI")
				alien = 1
			else
				name = "Man-Machine Interface: [brainmob.real_name]"
				icon = B.mmi_icon
				become_occupied("[B.mmi_icon_state]")
				alien = 0

			if(radio_action)
				radio_action.UpdateButtonIcon()
			feedback_inc("cyborg_mmis_filled",1)
		else
			to_chat(user, "<span class='warning'>You can't drop [B]!</span>")

		return

	if(istype(O, /obj/item/mmi_radio_upgrade))
		if(radio)
			to_chat(user, "<span class='warning'>[src] already has a radio installed.</span>")
		else
			user.visible_message("<span class='notice'>[user] begins to install the [O] into [src]...</span>", \
				"<span class='notice'>You start to install the [O] into [src]...</span>")
			if(do_after(user, 20, target=src))
				if(user.drop_item())
					user.visible_message("<span class='notice'>[user] installs [O] in [src].</span>", \
						"<span class='notice'>You install [O] in [src].</span>")
					if(brainmob)
						to_chat(brainmob, "<span class='notice'>MMI radio capability installed.</span>")
					install_radio()
					qdel(O)
				else
					to_chat(user, "<span class='warning'>You can't drop [O]!</span>")
		return

	// Maybe later add encryption key support, but that's a pain in the neck atm

	if(brainmob)
		O.attack(brainmob, user)//Oh noooeeeee
		// Brainmobs can take damage, but they can't actually die. Maybe should fix.
		return
	return ..()

/obj/item/mmi/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!radio)
		to_chat(user, "<span class='warning'>There is no radio in [src]!</span>")
		return
	user.visible_message("<span class='warning'>[user] begins to uninstall the radio from [src]...</span>", \
							 "<span class='notice'>You start to uninstall the radio from [src]...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || !radio)
		return
	uninstall_radio()
	new /obj/item/mmi_radio_upgrade(get_turf(src))
	user.visible_message("<span class='warning'>[user] uninstalls the radio from [src].</span>", \
						 "<span class='notice'>You uninstall the radio from [src].</span>")


/obj/item/mmi/attack_self(mob/user as mob)
	if(!brainmob)
		to_chat(user, "<span class='warning'>You upend the MMI, but there's nothing in it.</span>")
	else
		to_chat(user, "<span class='notice'>You unlock and upend the MMI, spilling the brain onto the floor.</span>")
		dropbrain(get_turf(user))
		icon = 'icons/obj/assemblies.dmi'
		icon_state = "mmi_empty"
		name = "Man-Machine Interface"

/obj/item/mmi/proc/transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->robot people.
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

	name = "Man-Machine Interface: [brainmob.real_name]"
	become_occupied("mmi_full")

//I made this proc as a way to have a brainmob be transferred to any created brain, and to solve the
//problem i was having with alien/nonalien brain drops.
/obj/item/mmi/proc/dropbrain(var/turf/dropspot)
	if(isnull(held_brain))
		log_runtime(EXCEPTION("[src] at [loc] attempted to drop brain without a contained brain in [get_area(src)]."), src)
		to_chat(brainmob, "<span class='userdanger'>Your MMI did not contain a brain! We'll make a new one for you, but you'd best report this to the bugtracker!</span>")
		held_brain = new(dropspot) // Let's not ruin someone's round because of something dumb -- Crazylemon
		held_brain.dna = brainmob.dna.Clone()
		held_brain.name = "\the [brainmob.name]'s [initial(held_brain.name)]"

	brainmob.container = null//Reset brainmob mmi var.
	brainmob.forceMove(held_brain) //Throw mob into brain.
	GLOB.respawnable_list += brainmob
	GLOB.living_mob_list -= brainmob//Get outta here
	held_brain.brainmob = brainmob//Set the brain to use the brainmob
	held_brain.brainmob.cancel_camera()
	brainmob = null//Set mmi brainmob var to null
	held_brain.forceMove(dropspot)
	held_brain = null

/obj/item/mmi/proc/become_occupied(var/new_icon)
	icon_state = new_icon
	if(radio)
		radio_action.ApplyIcon()

/obj/item/mmi/examine(mob/user)
	. = ..()
	if(radio)
		. += "<span class='notice'>A radio is installed on [src].</span>"

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

/datum/action/generic/configure_mmi_radio/New(var/Target, var/obj/item/mmi/M)
	. = ..()
	mmi = M

/datum/action/generic/configure_mmi_radio/Destroy()
	mmi = null
	return ..()

/datum/action/generic/configure_mmi_radio/ApplyIcon(obj/screen/movable/action_button/current_button)
	// A copy/paste of the item action icon code
	current_button.overlays.Cut()
	if(target)
		var/obj/item/I = mmi
		var/old_layer = I.layer
		var/old_plane = I.plane
		I.layer = 21
		I.plane = HUD_PLANE
		current_button.overlays += I
		I.layer = old_layer
		I.plane = old_plane

/obj/item/mmi/emp_act(severity)
	if(!brainmob)
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage += rand(20,30)
			if(2)
				brainmob.emp_damage += rand(10,20)
			if(3)
				brainmob.emp_damage += rand(0,10)
	..()

/obj/item/mmi/relaymove(var/mob/user, var/direction)
	if(user.stat || user.stunned)
		return
	var/obj/item/rig/rig = src.get_rig()
	if(rig)
		rig.forced_move(direction, user)

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
	if(radio && istype(A, /mob/living/carbon/brain))
		radio_action.Grant(A)

/obj/item/mmi/Exited(atom/movable/A)
	if(radio && istype(A, /mob/living/carbon/brain))
		radio_action.Remove(A)

/obj/item/mmi/syndie
	name = "Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs created with it, but doesn't fit in Nanotrasen AI cores."
	origin_tech = "biotech=4;programming=4;syndicate=2"
	syndiemmi = 1

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
/obj/item/mmi/contents_nano_distance(var/src_object, var/mob/living/user)
	if((src_object in view(src)) && get_dist(src_object, src) <= user.client.view)
		return STATUS_INTERACTIVE	// interactive (green visibility)
	return user.shared_living_nano_distance(src_object)

// For now the only thing that is helped by this is radio access
// Later a more intricate system for MMI UI interaction can be established
/obj/item/mmi/contents_nano_interact(var/src_object, var/mob/living/user)
	if(!istype(user, /mob/living/carbon/brain))
		log_runtime(EXCEPTION("Somehow a non-brain mob is inside an MMI!"), user)
		return ..()
	var/mob/living/carbon/brain/BM = user
	if(BM.container == src && src_object == radio)
		return STATUS_INTERACTIVE
	return ..()
