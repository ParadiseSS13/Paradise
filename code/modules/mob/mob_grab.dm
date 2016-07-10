#define UPGRADE_COOLDOWN  40
#define UPGRADE_KILL_TIMER  100

//times it takes for a mob to eat
#define EAT_TIME_XENO 30
#define EAT_TIME_FAT 100

//time it takes for a mob to be eaten (in deciseconds) (overrides mob eat time)
#define EAT_TIME_ANIMAL 30

/obj/item/weapon/grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT
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
	w_class = 5


/obj/item/weapon/grab/New(var/mob/user, var/mob/victim)
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
	if(assailant.grabbed_by)
		for(var/obj/item/weapon/grab/G in assailant.grabbed_by)
			if(G.assailant == affecting && G.affecting == assailant)
				G.dancing = 1
				G.adjust_position()
				dancing = 1

	clean_grabbed_by(assailant, affecting)
	adjust_position()

/obj/item/weapon/grab/proc/clean_grabbed_by(var/mob/user, var/mob/victim) //Cleans up any nulls in the grabbed_by list.
	if(istype(user))

		for(var/entry in user.grabbed_by)
			if(isnull(entry) || !istype(entry, /obj/item/weapon/grab)) //the isnull() here is probably redundant- but it might outperform istype, who knows. Better safe than sorry.
				user.grabbed_by -= entry

	if(istype(victim))

		for(var/entry in victim.grabbed_by)
			if(isnull(entry) || !istype(entry, /obj/item/weapon/grab))
				victim.grabbed_by -= entry

	return 1

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/get_mob_if_throwable()
	if(affecting && assailant.Adjacent(affecting))
		if(affecting.buckled)
			return null
		if(state >= GRAB_AGGRESSIVE)
			return affecting
	return null

//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand
		else
			hud.screen_loc = ui_lhand
		assailant.client.screen += hud

/obj/item/weapon/grab/process()
	if(!confirm())
		return //If the confirm fails, the grab is about to be deleted. That means it shouldn't continue processing.

	if(assailant.client)
		if(!hud)
			return //this somehow can runtime under the right circumstances
		assailant.client.screen -= hud
		assailant.client.screen += hud

	var/hit_zone = assailant.zone_sel.selecting
	last_hit_zone = hit_zone

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		//disallow upgrading if we're grabbing more than one person
		if((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0

		//disallow upgrading past aggressive if we're being grabbed aggressively
		for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
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

	if(state >= GRAB_NECK)
		affecting.Stun(5)  //It will hamper your voice, being choked and all.
		if(isliving(affecting))
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		//affecting.apply_effect(STUTTER, 5) //would do this, but affecting isn't declared as mob/living for some stupid reason.
		affecting.stuttering = max(affecting.stuttering, 5) //It will hamper your voice, being choked and all.
		affecting.Weaken(5)	//Should keep you down unless you get help.
		affecting.losebreath = max(affecting.losebreath + 2, 3)

	adjust_position()


/obj/item/weapon/grab/attack_self(mob/user)
	s_click(hud)

//Updating pixelshift, position and direction
//Gets called on process, when the grab gets upgraded or the assailant moves
/obj/item/weapon/grab/proc/adjust_position()
	if(affecting.buckled)
		return
	if(affecting.lying && state != GRAB_KILL)
		animate(affecting, pixel_x = 0, pixel_y = 0, 5, 1, LINEAR_EASING)
		return //KJK
	/*	if(force_down) //THIS GOES ABOVE THE RETURN LABELED KJK
			affecting.set_dir(SOUTH)*///This shows how you can apply special directions based on a variable. //face up

	var/shift = 0
	var/adir = get_dir(assailant, affecting)
	affecting.layer = 4
	switch(state)
		if(GRAB_PASSIVE)
			shift = 8
			if(dancing) //look at partner
				shift = 10
				assailant.set_dir(get_dir(assailant, affecting))
		if(GRAB_AGGRESSIVE)
			shift = 12
		if(GRAB_NECK, GRAB_UPGRADING)
			shift = -10
			adir = assailant.dir
			affecting.set_dir(assailant.dir)
			affecting.loc = assailant.loc
		if(GRAB_KILL)
			shift = 0
			adir = 1
			affecting.set_dir(SOUTH)//face up
			affecting.loc = assailant.loc

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

/obj/item/weapon/grab/proc/s_click(obj/screen/S)
	if(!affecting)
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
			assailant.set_dir(EAST) //face the victim
			affecting.set_dir(SOUTH) //face up  //This is an example of a new feature based on the context of the location of the victim.
			*/									//It means that upgrading while someone is lying on the ground would cause you to go into pin mode.
		state = GRAB_AGGRESSIVE
		icon_state = "grabbed1"
		hud.icon_state = "reinforce1"
	else if(state < GRAB_NECK)
		if(isslime(affecting))
			to_chat(assailant, "<span class='notice'>You squeeze [affecting], but nothing interesting happens.</span>")
			return

		assailant.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] (now neck)!</span>")
		state = GRAB_NECK
		icon_state = "grabbed+1"
		assailant.set_dir(get_dir(assailant, affecting))
		affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their neck grabbed by [assailant.name] ([assailant.ckey])</font>"
		assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Grabbed the neck of [affecting.name] ([affecting.ckey])</font>"
		log_attack("<font color='red'>[assailant.name] ([assailant.ckey]) grabbed the neck of [affecting.name] ([affecting.ckey])</font>")
		if(!iscarbon(assailant))
			affecting.LAssailant = null
		else
			affecting.LAssailant = assailant
		hud.icon_state = "kill"
		hud.name = "kill"
		affecting.Stun(10) //10 ticks of ensured grab
	else if(state < GRAB_UPGRADING)
		assailant.visible_message("<span class='danger'>[assailant] starts to tighten \his grip on [affecting]'s neck!</span>")
		hud.icon_state = "kill1"

		state = GRAB_KILL
		assailant.visible_message("<span class='danger'>[assailant] has tightened \his grip on [affecting]'s neck!</span>")
		affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been strangled (kill intent) by [assailant.name] ([assailant.ckey])</font>"
		assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>"
		msg_admin_attack("[key_name(assailant)] strangled (kill intent) [key_name(affecting)]")

		assailant.next_move = world.time + 10
		affecting.losebreath += 1
		affecting.set_dir(WEST)
	adjust_position()

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 0
	return 1


/obj/item/weapon/grab/attack(mob/living/M, mob/living/carbon/user)
	if(!affecting)
		return

	if(M == affecting)
		if(ishuman(M) && ishuman(assailant))
			var/mob/living/carbon/human/affected = affecting
			var/mob/living/carbon/human/attacker = assailant
			switch(assailant.a_intent)
				if(I_HELP)
					/*if(force_down)
						to_chat(assailant, "<span class='warning'>You no longer pin [affecting] to the ground.</span>")
						force_down = 0
						return*///This is a very basic demonstration of a new feature based on attacking someone with the grab, based on intent.
								//This specific example would allow you to stop pinning people to the floor without moving away from them.
					return

				if(I_GRAB)
					return

				if(I_HARM) //This checks that the user is on harm intent.
					if(last_hit_zone == "head") //This checks the hitzone the user has selected. In this specific case, they have the head selected.
						if(affecting.lying)
							return
						assailant.visible_message("<span class='danger'>[assailant] thrusts \his head into [affecting]'s skull!</span>") //A visible message for what is going on.
						var/damage = 5
						var/obj/item/clothing/hat = attacker.head
						if(istype(hat))
							damage += hat.force * 3
						affecting.apply_damage(damage*rand(90, 110)/100, BRUTE, "head", affected.run_armor_check(affecting, "melee"))
						playsound(assailant.loc, "swing_hit", 25, 1, -1)
						assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Headbutted [affecting.name] ([affecting.ckey])</font>")
						affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Headbutted by [assailant.name] ([assailant.ckey])</font>")
						msg_admin_attack("[key_name(assailant)] has headbutted [key_name(affecting)]")
						return

					/*if(last_hit_zone == "eyes")
						if(state < GRAB_NECK)
							to_chat(assailant, "<span class='warning'>You require a better grab to do this.</span>")
							return
						if((affected.head && affected.head.flags & HEADCOVERSEYES) || \
							(affected.wear_mask && affected.wear_mask.flags & MASKCOVERSEYES) || \
							(affected.glasses && affected.glasses.flags & GLASSESCOVERSEYES))
							to_chat(assailant, "<span class='danger'>You're going to need to remove the eye covering first.</span>")
							return
						if(!affected.internal_organs_by_name["eyes"])
							to_chat(assailant, "<span class='danger'>You cannot locate any eyes on [affecting]!</span>")
							return
						assailant.visible_message("<span class='danger'>[assailant] presses \his fingers into [affecting]'s eyes!</span>")
						to_chat(affecting, "<span class='danger'>You feel immense pain as digits are being pressed into your eyes!</span>")
						assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Pressed fingers into the eyes of [affecting.name] ([affecting.ckey])</font>")
						affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had fingers pressed into their eyes by [assailant.name] ([assailant.ckey])</font>")
						msg_admin_attack("[key_name(assailant)] has pressed his fingers into [key_name(affecting)]'s eyes.")
						var/obj/item/organ/internal/eyes/eyes = affected.get_int_organ(/obj/item/organ/internal/eyes)
						eyes.damage += rand(3,4)
						if(eyes.damage >= eyes.min_broken_damage)
							if(M.stat != 2)
								to_chat(M, "\red You go blind!")*///This is a demonstration of adding a new damaging type based on intent as well as hitzone.

															//This specific example would allow you to squish people's eyes with a GRAB_NECK.

				if(I_DISARM) //This checks that the user is on disarm intent.
				/*	if(state < GRAB_AGGRESSIVE)
						to_chat(assailant, "<span class='warning'>You require a better grab to do this.</span>")
						return
					if(!force_down)
						assailant.visible_message("<span class='danger'>[user] is forcing [affecting] to the ground!</span>")
						force_down = 1
						affecting.Weaken(3)
						affecting.lying = 1
						step_to(assailant, affecting)
						assailant.set_dir(EAST) //face the victim
						affecting.set_dir(SOUTH) //face up
						return
					else
						to_chat(assailant, "<span class='warning'>You are already pinning [affecting] to the ground.</span>")
						return*///This is an example of something being done with an agressive grab + disarm intent.
					return


	if(M == assailant && state >= GRAB_AGGRESSIVE) //no eatin unless you have an agressive grab
		if(checkvalid(user, affecting)) //wut
			var/mob/living/carbon/attacker = user
			user.visible_message("<span class='danger'>[user] is attempting to devour \the [affecting]!</span>")

			if(!do_after(user, checktime(user, affecting), target = affecting)) return

			user.visible_message("<span class='danger'>[user] devours \the [affecting]!</span>")
			if(affecting.mind)
				affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been devoured by [attacker.name] ([attacker.ckey])</font>"
				attacker.attack_log += "\[[time_stamp()]\] <font color='red'>Devoured [affecting.name] ([affecting.ckey])</font>"
				msg_admin_attack("[key_name(attacker)] devoured [key_name(affecting)]")

			affecting.loc = user
			attacker.stomach_contents.Add(affecting)
			qdel(src)

/obj/item/weapon/grab/proc/checkvalid(var/mob/attacker, var/mob/prey) //does all the checking for the attack proc to see if a mob can eat another with the grab
	if(ishuman(attacker) && (/datum/dna/gene/basic/grant_spell/mattereater in attacker.active_genes)) // MATTER EATER CARES NOT OF YOUR FORM
		return 1

	if(ishuman(attacker) && (FAT in attacker.mutations) && iscarbon(prey) && !isalien(prey)) //Fat people eating carbon mobs but not xenos
		return 1

	if(isalien(attacker) && iscarbon(prey)) //Xenomorphs eating carbon mobs
		return 1

	var/mob/living/carbon/human/H = attacker
	if(ishuman(H) && is_type_in_list(prey,  H.species.allowed_consumed_mobs)) //species eating of other mobs
		return 1

	return 0

/obj/item/weapon/grab/proc/checktime(var/mob/attacker, var/mob/prey) //Returns the time the attacker has to wait before they eat the prey
	if(isalien(attacker))
		return EAT_TIME_XENO //xenos get a speed boost

	if(istype(prey,/mob/living/simple_animal)) //simple animals get eaten at xeno-eating-speed regardless
		return EAT_TIME_ANIMAL

	return EAT_TIME_FAT //if it doesn't fit into the above, it's probably a fat guy, take EAT_TIME_FAT to do it

/obj/item/weapon/grab/dropped()
	qdel(src)


/obj/item/weapon/grab/Destroy()
	if(affecting)
		affecting.pixel_x = 0
		affecting.pixel_y = 0 //used to be an animate, not quick enough for del'ing
		affecting.layer = initial(affecting.layer)
		affecting.grabbed_by -= src
		affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	qdel(hud)
	hud = null
	return ..()


#undef EAT_TIME_XENO
#undef EAT_TIME_FAT

#undef EAT_TIME_ANIMAL
