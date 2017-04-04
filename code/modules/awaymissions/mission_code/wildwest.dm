/* Code for the Wild West map by Brotemis
 * Contains:
 *		WishMaster 1.0
 *		Meat Grinder
 */

//Wild West Areas

/area/awaymission/wwmines
	name = "Wild West Mines"
	icon_state = "away1"
	luminosity = 1
	requires_power = 0

/area/awaymission/wwgov
	name = "Wild West Mansion"
	icon_state = "away2"
	luminosity = 1
	requires_power = 0

/area/awaymission/wwrefine
	name = "Wild West Refinery"
	icon_state = "away3"
	luminosity = 1
	requires_power = 0

/area/awaymission/wwvault
	name = "Wild West Vault"
	icon_state = "away3"
	luminosity = 0

/area/awaymission/wwvaultdoors
	name = "Wild West Vault Doors"  // this is to keep the vault area being entirely lit because of requires_power
	icon_state = "away2"
	requires_power = 0
	luminosity = 0

/*
 * WishMaster 1.0
 */
/obj/machinery/wish_granter_dark
	name = "WishMaster 1.0"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	anchored = 1
	density = 1
	use_power = 0

	var/chargesa = 1
	var/insistinga = 0

/obj/machinery/wish_granter_dark/attack_hand(var/mob/living/carbon/human/user as mob)
	usr.set_machine(src)

	if(chargesa <= 0)
		to_chat(user, "The WishMaster 1.0 lies silent.")
		return

	else if(!istype(user, /mob/living/carbon/human))
		to_chat(user, "You feel a dark stirring inside of the WishMaster 1.0, something you want nothing of. Your instincts are better than any man's.")
		return

	else if(is_special_character(user))
		to_chat(user, "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away.")

	else if(!insistinga)
		to_chat(user, "Your first touch makes the WishMaster 1.0 stir, listening to you.  Are you really sure you want to do this?")
		insistinga++

	else
		chargesa--
		insistinga = 0
		var/wish = input("You want...","Wish") as null|anything in list("Power","Wealth","Immortality","To Kill","Peace")
		switch(wish)
			if("Power")
				to_chat(user, "<B>Your wish is granted, but at a terrible cost...</B>")
				to_chat(user, "The WishMaster 1.0 punishes you for your selfishness, claiming your soul and warping your body to match the darkness in your heart.")
				user.mutations.Add(LASER)
				user.mutations.Add(RESIST_COLD)
				user.mutations.Add(XRAY)
				if(ishuman(user))
					var/mob/living/carbon/human/human = user
					if(human.species.name != "Shadow")
						to_chat(user, "\red Your flesh rapidly mutates!")
						to_chat(user, "<b>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</b>")
						to_chat(user, "\red Your body reacts violently to light. \green However, it naturally heals in darkness.")
						to_chat(user, "Aside from your new traits, you are mentally unchanged and retain your prior obligations.")
						human.set_species("Shadow")
				user.regenerate_icons()
			if("Wealth")
				to_chat(user, "<B>Your wish is granted, but at a terrible cost...</B>")
				to_chat(user, "The WishMaster 1.0 punishes you for your selfishness, claiming your soul and warping your body to match the darkness in your heart.")
				new /obj/structure/closet/syndicate/resources/everything(loc)
				if(ishuman(user))
					var/mob/living/carbon/human/human = user
					if(human.species.name != "Shadow")
						to_chat(user, "\red Your flesh rapidly mutates!")
						to_chat(user, "<b>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</b>")
						to_chat(user, "\red Your body reacts violently to light. \green However, it naturally heals in darkness.")
						to_chat(user, "Aside from your new traits, you are mentally unchanged and retain your prior obligations.")
						human.set_species("Shadow")
				user.regenerate_icons()
			if("Immortality")
				to_chat(user, "<B>Your wish is granted, but at a terrible cost...</B>")
				to_chat(user, "The WishMaster 1.0 punishes you for your selfishness, claiming your soul and warping your body to match the darkness in your heart.")
				user.verbs += /mob/living/carbon/proc/immortality
				if(ishuman(user))
					var/mob/living/carbon/human/human = user
					if(human.species.name != "Shadow")
						to_chat(user, "\red Your flesh rapidly mutates!")
						to_chat(user, "<b>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</b>")
						to_chat(user, "\red Your body reacts violently to light. \green However, it naturally heals in darkness.")
						to_chat(user, "Aside from your new traits, you are mentally unchanged and retain your prior obligations.")
						human.set_species("Shadow")
				user.regenerate_icons()
			if("To Kill")
				to_chat(user, "<B>Your wish is granted, but at a terrible cost...</B>")
				to_chat(user, "The WishMaster 1.0 punishes you for your wickedness, claiming your soul and warping your body to match the darkness in your heart.")
				ticker.mode.traitors += user.mind
				user.mind.special_role = SPECIAL_ROLE_TRAITOR
				var/datum/objective/hijack/hijack = new
				hijack.owner = user.mind
				user.mind.objectives += hijack
				to_chat(user, "<B>Your inhibitions are swept away, the bonds of loyalty broken, you are free to murder as you please!</B>")
				var/obj_count = 1
				for(var/datum/objective/OBJ in user.mind.objectives)
					to_chat(user, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
					obj_count++
				if(ishuman(user))
					var/mob/living/carbon/human/human = user
					if(human.species.name != "Shadow")
						to_chat(user, "\red Your flesh rapidly mutates!")
						to_chat(user, "<b>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</b>")
						to_chat(user, "\red Your body reacts violently to light. \green However, it naturally heals in darkness.")
						to_chat(user, "Aside from your new traits, you are mentally unchanged and retain your prior obligations.")
						human.set_species("Shadow")
				user.regenerate_icons()
			if("Peace")
				to_chat(user, "<B>Whatever alien sentience that the WishMaster 1.0 possesses is satisfied with your wish. There is a distant wailing as the last of the Faithless begin to die, then silence.</B>")
				to_chat(user, "You feel as if you just narrowly avoided a terrible fate...")
				for(var/mob/living/simple_animal/hostile/faithless/F in world)
					F.health = -10
					F.stat = 2
					F.icon_state = "faithless_dead"


///////////////Meatgrinder//////////////


/obj/effect/meatgrinder
	name = "Meat Grinder"
	desc = "What is that thing?"
	density = 1
	anchored = 1
	layer = 3
	icon = 'icons/mob/blob.dmi'
	icon_state = "blobpod"
	var/triggerproc = "triggerrad1" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/effect/meatgrinder/New()
	icon_state = "blobpod"

/obj/effect/meatgrinder/Crossed(AM as mob|obj)
	Bumped(AM)

/obj/effect/meatgrinder/Bumped(mob/M as mob|obj)

	if(triggered) return

	if(istype(M, /mob/living/carbon/human))
		for(var/mob/O in viewers(world.view, src.loc))
			to_chat(O, "<font color='red'>[M] triggered the [bicon(src)] [src]</font>")
		triggered = 1
		call(src,triggerproc)(M)

/obj/effect/meatgrinder/proc/triggerrad1(mob)
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	for(var/mob/O in viewers(world.view, src.loc))
		s.set_up(3, 1, src)
		s.start()
		explosion(mob, 1, 0, 0, 0)
		qdel(src)


/////For the Wishgranter///////////

/mob/living/carbon/proc/immortality()
	set category = "Immortality"
	set name = "Resurrection"

	var/mob/living/carbon/C = usr
	if(!C.stat)
		to_chat(C, "<span class='notice'>You're not dead yet!</span>")
		return
	to_chat(C, "<span class='notice'>Death is not your end!</span>")

	spawn(rand(800,1200))
		if(C.stat == DEAD)
			dead_mob_list -= C
			living_mob_list += C
		C.stat = CONSCIOUS
		C.timeofdeath = 0
		C.setToxLoss(0)
		C.setOxyLoss(0)
		C.setCloneLoss(0)
		C.SetParalysis(0)
		C.SetStunned(0)
		C.SetWeakened(0)
		C.radiation = 0
		C.heal_overall_damage(C.getBruteLoss(), C.getFireLoss())
		C.reagents.clear_reagents()
		to_chat(C, "<span class='notice'>You have regenerated.</span>")
		C.visible_message("<span class='warning'>[usr] appears to wake from the dead, having healed all wounds.</span>")
		C.update_canmove()
	return 1