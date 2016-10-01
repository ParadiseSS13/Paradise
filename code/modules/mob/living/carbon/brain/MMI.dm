//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = 3
	origin_tech = "biotech=3"

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.
	var/alien = 0
	var/syndiemmi = 0 //Whether or not this is a Syndicate MMI
	var/mob/living/carbon/brain/brainmob = null//The current occupant.
	var/obj/item/organ/internal/brain/held_brain = null // This is so MMI's aren't brainscrubber 9000's
	var/mob/living/silicon/robot/robot = null//Appears unused.
	var/obj/mecha/mecha = null//This does not appear to be used outside of reference in mecha.dm.
// I'm using this for mechs giving MMIs HUDs now

/obj/item/device/mmi/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/organ/internal/brain/crystal ))
		to_chat(user, "<span class='warning'> This brain is too malformed to be able to use with the [src].</span>")
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
		for(var/mob/V in viewers(src, null))
			V.show_message("<span class='notice'>[user] sticks \a [O] into \the [src].</span>")
		brainmob = B.brainmob
		B.brainmob = null
		brainmob.loc = src
		brainmob.container = src
		brainmob.stat = CONSCIOUS
		respawnable_list -= brainmob
		dead_mob_list -= brainmob//Update dem lists
		living_mob_list += brainmob

		user.drop_item()
		B.forceMove(src)
		held_brain = B
		if(istype(O,/obj/item/organ/internal/brain/xeno)) // kept the type check, as it still does other weird stuff
			name = "Man-Machine Interface: Alien - [brainmob.real_name]"
			icon = 'icons/mob/alien.dmi'
			icon_state = "AlienMMI"
			alien = 1
		else
			name = "Man-Machine Interface: [brainmob.real_name]"
			icon = B.mmi_icon
			icon_state = "[B.mmi_icon_state]"
			alien = 0
		feedback_inc("cyborg_mmis_filled",1)

		return

	if(brainmob)
		O.attack(brainmob, user)//Oh noooeeeee
		// Brainmobs can take damage, but they can't actually die. Maybe should fix.
		return
	..()



/obj/item/device/mmi/attack_self(mob/user as mob)
	if(!brainmob)
		to_chat(user, "<span class='warning'>You upend the MMI, but there's nothing in it.</span>")
	else
		to_chat(user, "<span class='notice'>You unlock and upend the MMI, spilling the brain onto the floor.</span>")
		dropbrain(get_turf(user))
		icon = 'icons/obj/assemblies.dmi'
		icon_state = "mmi_empty"
		name = "Man-Machine Interface"

/obj/item/device/mmi/proc/transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->robot people.
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	brainmob.container = src

	if(!istype(H.species) || isnull(H.species.return_organ("brain"))) // Diona/buggy people
		held_brain = new(src)
	else // We have a species, and it has a brain
		var/brain_path = H.species.return_organ("brain")
		if(!ispath(brain_path, /obj/item/organ/internal/brain))
			brain_path = /obj/item/organ/internal/brain
		held_brain = new brain_path(src) // Slime people will keep their slimy brains this way
	held_brain.dna = brainmob.dna.Clone()
	held_brain.name = "\the [brainmob.name]'s [initial(held_brain.name)]"

	name = "Man-Machine Interface: [brainmob.real_name]"
	icon_state = "mmi_full"
	return

//I made this proc as a way to have a brainmob be transferred to any created brain, and to solve the
//problem i was having with alien/nonalien brain drops.
/obj/item/device/mmi/proc/dropbrain(var/turf/dropspot)
	if(isnull(held_brain))
		log_runtime(EXCEPTION("[src] at [loc] attempted to drop brain without a contained brain in [get_area(src)]."), src)
		to_chat(brainmob, "<span class='userdanger'>Your MMI did not contain a brain! We'll make a new one for you, but you'd best report this to the bugtracker!</span>")
		held_brain = new(dropspot) // Let's not ruin someone's round because of something dumb -- Crazylemon
		held_brain.dna = brainmob.dna.Clone()
		held_brain.name = "\the [brainmob.name]'s [initial(held_brain.name)]"

	brainmob.container = null//Reset brainmob mmi var.
	brainmob.loc = held_brain//Throw mob into brain.
	respawnable_list += brainmob
	living_mob_list -= brainmob//Get outta here
	held_brain.brainmob = brainmob//Set the brain to use the brainmob
	held_brain.brainmob.cancel_camera()
	brainmob = null//Set mmi brainmob var to null
	held_brain.forceMove(dropspot)
	held_brain = null


/obj/item/device/mmi/radio_enabled
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	origin_tech = "biotech=4"

	var/obj/item/device/radio/radio = null//Let's give it a radio.

/obj/item/device/mmi/radio_enabled/New()
	..()
	radio = new(src)//Spawns a radio inside the MMI.
	radio.broadcasting = 1//So it's broadcasting from the start.

/obj/item/device/mmi/radio_enabled/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = 0

	if(brainmob.stat)
		to_chat(brainmob, "Can't do that while incapacitated or dead.")

	radio.listening = radio.listening==1 ? 0 : 1
	to_chat(brainmob, "<span class='notice'>Radio is [radio.listening==1 ? "now" : "no longer"] receiving broadcast.</span>")

/obj/item/device/mmi/emp_act(severity)
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

/obj/item/device/mmi/relaymove(var/mob/user, var/direction)
	if(user.stat || user.stunned)
		return
	var/obj/item/weapon/rig/rig = src.get_rig()
	if(rig)
		rig.forced_move(direction, user)

/obj/item/device/mmi/Destroy()
	if(isrobot(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	if(held_brain)
		qdel(held_brain)
		held_brain = null
	return ..()

/obj/item/device/mmi/syndie
	name = "Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs created with it, but doesn't fit in Nanotrasen AI cores."
	syndiemmi = 1

/obj/item/device/mmi/attempt_become_organ(obj/item/organ/external/parent,mob/living/carbon/human/H)
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
	if(istype(src, /obj/item/device/mmi/posibrain))
		holder.robotize()
	if(brainmob && brainmob.mind)
		brainmob.mind.transfer_to(H)
	holder.insert(H)

	return 1
