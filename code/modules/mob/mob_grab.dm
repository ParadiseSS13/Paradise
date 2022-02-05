#define UPGRADE_COOLDOWN  44
#define UPGRADE_KILL_TIMER  100

//times it takes for a mob to eat
#define EAT_TIME_XENO 30
#define EAT_TIME_FAT 100

//time it takes for a mob to be eaten (in deciseconds) (overrides mob eat time)
#define EAT_TIME_ANIMAL 30

/obj/item/grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT | DROPDEL
	var/obj/screen/grab/hud = null
	var/mob/living/affecting = null
	var/mob/living/assailant = null
	var/state = GRAB_PASSIVE

	var/allow_upgrade = 1
	var/last_upgrade = 0
	var/last_hit_zone = 0
//	var/force_down //determines if the affecting mob will be pinned to the ground //disabled due to balance, kept for an example for any new things.
	var/dancing //determines if assailant and affecting keep looking at each other. Basically a wrestling position

	layer = 21
	plane = HUD_PLANE
	item_state = "nothing"
	icon = 'icons/mob/screen_gen.dmi'
	w_class = WEIGHT_CLASS_BULKY


/obj/item/grab/New(var/mob/user, var/mob/victim)
	..()

	//Okay, first off, some fucking sanity checking. No user, or no victim, or they are not mobs, no grab.
	if(!istype(user) || !istype(victim))
		return

	loc = user
	assailant = user
	affecting = victim

	if(affecting.anchored)
		qdel(src)
		return

	affecting.grabbed_by += src

	hud = new /obj/screen/grab(src)
	hud.icon_state = "reinforce"
	icon_state = "grabbed"
	hud.name = "reinforce grab"
	hud.master = src

	//check if assailant is grabbed by victim as well
	for(var/obj/item/grab/G in assailant.grabbed_by)
		if(G.assailant == affecting && G.affecting == assailant)
			G.dancing = 1
			G.adjust_position()
			dancing = 1

	clean_grabbed_by(assailant, affecting)
	adjust_position()

/obj/item/grab/proc/clean_grabbed_by(var/mob/user, var/mob/victim) //Cleans up any nulls in the grabbed_by list.
	if(istype(user))

		for(var/entry in user.grabbed_by)
			if(isnull(entry) || !istype(entry, /obj/item/grab)) //the isnull() here is probably redundant- but it might outperform istype, who knows. Better safe than sorry.
				user.grabbed_by -= entry

	if(istype(victim))

		for(var/entry in victim.grabbed_by)
			if(isnull(entry) || !istype(entry, /obj/item/grab))
				victim.grabbed_by -= entry

	return 1

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/grab/proc/get_mob_if_throwable()
	if(affecting && assailant.Adjacent(affecting))
		if(affecting.buckled)
			return null
		if(state >= GRAB_AGGRESSIVE)
			return affecting
	return null

//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/grab/proc/synch()
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand
		else
			hud.screen_loc = ui_lhand
		assailant.client.screen += hud

/obj/item/grab/process()
	if(!confirm())
		return //If the confirm fails, the grab is about to be deleted. That means it shouldn't continue processing.

	if(assailant.client)
		if(!hud)
			return //this somehow can runtime under the right circumstances
		assailant.client.screen -= hud
		assailant.client.screen += hud

	var/hit_zone = assailant.zone_selected
	last_hit_zone = hit_zone

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		//disallow upgrading if we're grabbing more than one person
		if((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/grab)))
			var/obj/item/grab/G = assailant.l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/grab)))
			var/obj/item/grab/G = assailant.r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0

		//disallow upgrading past aggressive if we're being grabbed aggressively
		for(var/obj/item/grab/G in affecting.grabbed_by)
			if(G == src) continue
			if(G.state >= GRAB_AGGRESSIVE)
				allow_upgrade = 0

		if(allow_upgrade)
			if(state < GRAB_AGGRESSIVE)
				hud.icon_state = "reinforce"
			else
				hud.icon_state = "reinforce1"
		else
			hud.icon_state = "!reinforce"

	if(state >= GRAB_AGGRESSIVE)
		if(!HAS_TRAIT(assailant, TRAIT_PACIFISM))
			affecting.drop_r_hand()
			affecting.drop_l_hand()


		//var/announce = 0
		//(hit_zone != last_hit_zone)
			//announce = 1
	/*	if(ishuman(affecting))
			switch(hit_zone)
				/*if("mouth")
					if(announce)
						assailant.visible_message("<span class='warning'>[assailant] covers [affecting]'s mouth!</span>")
					if(affecting.silent < 3)
						affecting.silent = 3
				if("eyes")
					if(announce)
						assailant.visible_message("<span class='warning'>[assailant] covers [affecting]'s eyes!</span>")
					if(affecting.eye_blind < 3)
						affecting.eye_blind = 3*///These are being left in the code as an example for adding new hit-zone based things.

		if(force_down)
			if(affecting.loc != assailant.loc)
				force_down = 0
			else
				affecting.Weaken(3) //This is being left in the code as an example of adding a new variable to do something in grab code.

*/

	var/breathing_tube = affecting.get_organ_slot("breathing_tube")

	if(state >= GRAB_NECK)
		affecting.Stun(2)  //It will hamper your voice, being choked and all.
		if(isliving(affecting) && !breathing_tube)
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		//affecting.apply_effect(STUTTER, 5) //would do this, but affecting isn't declared as mob/living for some stupid reason.
		affecting.Stuttering(5) //It will hamper your voice, being choked and all.
		affecting.Weaken(5)	//Should keep you down unless you get help.
		if(!breathing_tube)
			affecting.AdjustLoseBreath(2, bound_lower = 0, bound_upper = 3)

	adjust_position()


/obj/item/grab/attack_self(mob/user)
	s_click(hud)

//Updating pixelshift, position and direction
//Gets called on process, when the grab gets upgraded or the assailant moves
/obj/item/grab/proc/adjust_position()
	if(!affecting || affecting.buckled)
		return
	if(affecting.lying && state != GRAB_KILL)
		animate(affecting, pixel_x = 0, pixel_y = 0, 5, 1, LINEAR_EASING)
		return //KJK
	/*	if(force_down) //THIS GOES ABOVE THE RETURN LABELED KJK
			affecting.setDir(SOUTH)*///This shows how you can apply special directions based on a variable. //face up

	var/shift = 0
	var/adir = get_dir(assailant, affecting)
	affecting.layer = 4
	switch(state)
		if(GRAB_PASSIVE)
			shift = 8
			if(dancing) //look at partner
				shift = 10
				assailant.setDir(get_dir(assailant, affecting))
		if(GRAB_AGGRESSIVE)
			shift = 12
		if(GRAB_NECK, GRAB_UPGRADING)
			shift = -10
			adir = assailant.dir
			affecting.setDir(assailant.dir)
			affecting.forceMove(assailant.loc)
		if(GRAB_KILL)
			shift = 0
			adir = 1
			affecting.setDir(SOUTH)//face up
			affecting.forceMove(assailant.loc)

	switch(adir)
		if(NORTH)
			animate(affecting, pixel_x = 0, pixel_y =-shift, 5, 1, LINEAR_EASING)
			affecting.layer = 3.9
		if(SOUTH)
			animate(affecting, pixel_x = 0, pixel_y = shift, 5, 1, LINEAR_EASING)
		if(WEST)
			animate(affecting, pixel_x = shift, pixel_y = 0, 5, 1, LINEAR_EASING)
		if(EAST)
			animate(affecting, pixel_x =-shift, pixel_y = 0, 5, 1, LINEAR_EASING)

/obj/item/grab/proc/s_click(obj/screen/S)
	if(!affecting)
		return
	if(state >= GRAB_AGGRESSIVE && HAS_TRAIT(assailant, TRAIT_PACIFISM))
		to_chat(assailant, "<span class='warning'>You don't want to risk hurting [affecting]!</span>")
		return
	if(state == GRAB_UPGRADING)
		return
	if(assailant.next_move > world.time)
		return
	if(world.time < (last_upgrade + UPGRADE_COOLDOWN))
		return
	if(!assailant.canmove || assailant.lying)
		qdel(src)
		return

	last_upgrade = world.time

	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		//if(!affecting.lying)
		assailant.visible_message("<span class='warning'>[assailant] has grabbed [affecting] aggressively (now hands)!</span>")
		/* else
			assailant.visible_message("<span class='warning'>[assailant] pins [affecting] down to the ground (now hands)!</span>")
			force_down = 1
			affecting.Weaken(3)
			step_to(assailant, affecting)
			assailant.setDir(EAST) //face the victim
			affecting.setDir(SOUTH) //face up  //This is an example of a new feature based on the context of the location of the victim.
			*/									//It means that upgrading while someone is lying on the ground would cause you to go into pin mode.
		state = GRAB_AGGRESSIVE
		icon_state = "grabbed1"
		hud.icon_state = "reinforce1"
		add_attack_logs(assailant, affecting, "Aggressively grabbed", ATKLOG_ALL)
	else if(state < GRAB_NECK)
		if(isslime(affecting))
			to_chat(assailant, "<span class='notice'>You squeeze [affecting], but nothing interesting happens.</span>")
			return

		assailant.visible_message("<span class='warning'>[assailant] has reinforced [assailant.p_their()] grip on [affecting] (now neck)!</span>")
		state = GRAB_NECK
		icon_state = "grabbed+1"

		add_attack_logs(assailant, affecting, "Neck grabbed", ATKLOG_ALL)
		if(!iscarbon(assailant))
			affecting.LAssailant = null
		else
			affecting.LAssailant = assailant
		hud.icon_state = "kill"
		hud.name = "kill"
		affecting.Stun(10) //10 ticks of ensured grab
	else if(state < GRAB_UPGRADING)
		assailant.visible_message("<span class='danger'>[assailant] starts to tighten [assailant.p_their()] grip on [affecting]'s neck!</span>")
		hud.icon_state = "kill1"

		state = GRAB_KILL
		assailant.visible_message("<span class='danger'>[assailant] has tightened [assailant.p_their()] grip on [affecting]'s neck!</span>")
		add_attack_logs(assailant, affecting, "Strangled")

		assailant.next_move = world.time + 10
		if(!affecting.get_organ_slot("breathing_tube"))
			affecting.AdjustLoseBreath(1)

	adjust_position()

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 0
	return 1


/obj/item/grab/attack(mob/living/M, mob/living/carbon/user)
	if(!affecting)
		return

	if(M == affecting)
		if(ishuman(M) && ishuman(assailant))
			var/mob/living/carbon/human/affected = affecting
			var/mob/living/carbon/human/attacker = assailant
			switch(assailant.a_intent)
				if(INTENT_HELP)
					/*if(force_down)
						to_chat(assailant, "<span class='warning'>You no longer pin [affecting] to the ground.</span>")
						force_down = 0
						return*///This is a very basic demonstration of a new feature based on attacking someone with the grab, based on intent.
								//This specific example would allow you to stop pinning people to the floor without moving away from them.
					return

				if(INTENT_GRAB)
					return

				if(INTENT_HARM) //This checks that the user is on harm intent.
					if(last_hit_zone == "head") //This checks the hitzone the user has selected. In this specific case, they have the head selected.
						if(affecting.lying)
							return
						assailant.visible_message("<span class='danger'>[assailant] thrusts [assailant.p_their()] head into [affecting]'s skull!</span>") //A visible message for what is going on.
						var/damage = 5
						var/obj/item/clothing/hat = attacker.head
						if(istype(hat))
							damage += hat.force * 3
						affecting.apply_damage(damage*rand(90, 110)/100, BRUTE, "head", affected.run_armor_check(affecting, "melee"))
						playsound(assailant.loc, "swing_hit", 25, 1, -1)
						add_attack_logs(assailant, affecting, "Headbutted")
						return

					/*if(last_hit_zone == "eyes")
						if(state < GRAB_NECK)
							to_chat(assailant, "<span class='warning'>You require a better grab to do this.</span>")
							return
						if((affected.head && affected.head.flags_cover & HEADCOVERSEYES) || \
							(affected.wear_mask && affected.wear_mask.flags_cover & MASKCOVERSEYES) || \
							(affected.glasses && affected.glasses.flags_cover & GLASSESCOVERSEYES))
							to_chat(assailant, "<span class='danger'>You're going to need to remove the eye covering first.</span>")
							return
						if(!affected.internal_bodyparts_by_name["eyes"])
							to_chat(assailant, "<span class='danger'>You cannot locate any eyes on [affecting]!</span>")
							return
						assailant.visible_message("<span class='danger'>[assailant] presses [assailant.p_their()] fingers into [affecting]'s eyes!</span>")
						to_chat(affecting, "<span class='danger'>You feel immense pain as digits are being pressed into your eyes!</span>")
						add_attack_logs(assailant, affecting, "Eye-fucked with their fingers")
						var/obj/item/organ/internal/eyes/eyes = affected.get_int_organ(/obj/item/organ/internal/eyes)
						eyes.damage += rand(3,4)
						if(eyes.damage >= eyes.min_broken_damage)
							if(M.stat != 2)
								to_chat(M, "<span class='warning'>You go blind!</span>")*///This is a demonstration of adding a new damaging type based on intent as well as hitzone.

															//This specific example would allow you to squish people's eyes with a GRAB_NECK.

				if(INTENT_DISARM) //This checks that the user is on disarm intent.
				/*	if(state < GRAB_AGGRESSIVE)
						to_chat(assailant, "<span class='warning'>You require a better grab to do this.</span>")
						return
					if(!force_down)
						assailant.visible_message("<span class='danger'>[user] is forcing [affecting] to the ground!</span>")
						force_down = 1
						affecting.Weaken(3)
						affecting.lying = 1
						step_to(assailant, affecting)
						assailant.setDir(EAST) //face the victim
						affecting.setDir(SOUTH) //face up
						return
					else
						to_chat(assailant, "<span class='warning'>You are already pinning [affecting] to the ground.</span>")
						return*///This is an example of something being done with an agressive grab + disarm intent.
					return


	if(M == assailant && state >= GRAB_AGGRESSIVE) //no eatin unless you have an agressive grab
		if(checkvalid(user, affecting)) //wut
			var/mob/living/carbon/attacker = user

			if(affecting.buckled)
				to_chat(user, "<span class='warning'>[affecting] is buckled!</span>")
				return

			user.visible_message("<span class='danger'>[user] is attempting to devour \the [affecting]!</span>")

			if(!do_after(user, checktime(user, affecting), target = affecting)) return

			if(affecting.buckled)
				to_chat(user, "<span class='warning'>[affecting] is buckled!</span>")
				return

			user.visible_message("<span class='danger'>[user] devours \the [affecting]!</span>")
			if(affecting.mind)
				add_attack_logs(attacker, affecting, "Devoured")

			affecting.forceMove(user)
			LAZYADD(attacker.stomach_contents, affecting)
			qdel(src)

/obj/item/grab/proc/checkvalid(var/mob/attacker, var/mob/prey) //does all the checking for the attack proc to see if a mob can eat another with the grab
	if(isalien(attacker) && iscarbon(prey)) //Xenomorphs eating carbon mobs
		return 1

	var/mob/living/carbon/human/H = attacker
	if(ishuman(H) && is_type_in_list(prey,  H.dna.species.allowed_consumed_mobs)) //species eating of other mobs
		return 1

	return 0

/obj/item/grab/proc/checktime(var/mob/attacker, var/mob/prey) //Returns the time the attacker has to wait before they eat the prey
	if(isalien(attacker))
		return EAT_TIME_XENO //xenos get a speed boost

	if(istype(prey,/mob/living/simple_animal)) //simple animals get eaten at xeno-eating-speed regardless
		return EAT_TIME_ANIMAL

	return EAT_TIME_FAT //if it doesn't fit into the above, it's probably a fat guy, take EAT_TIME_FAT to do it

/obj/item/grab/Destroy()
	if(affecting)
		if(!affecting.buckled)
			affecting.pixel_x = 0
			affecting.pixel_y = 0 //used to be an animate, not quick enough for qdel'ing
			affecting.layer = initial(affecting.layer)
		affecting.grabbed_by -= src
		affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	QDEL_NULL(hud)
	return ..()


#undef EAT_TIME_XENO
#undef EAT_TIME_FAT

#undef EAT_TIME_ANIMAL
