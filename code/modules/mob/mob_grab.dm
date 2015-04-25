#define UPGRADE_COOLDOWN  40
#define UPGRADE_KILL_TIMER  100

/obj/item/weapon/grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT
	var/obj/screen/grab/hud = null
	var/mob/living/affecting = null
	var/mob/assailant = null
	var/state = GRAB_PASSIVE

	var/allow_upgrade = 1
	var/last_upgrade = 0
	var/last_hit_zone = 0

	layer = 21
	item_state = "nothing"
	w_class = 5.0


/obj/item/weapon/grab/New(mob/user, mob/victim)
	..()
	loc = user
	assailant = user
	affecting = victim

	if(affecting.anchored)
		del(src)
		return

	hud = new /obj/screen/grab(src)
	hud.icon_state = "reinforce"
	icon_state = "grabbed"
	hud.name = "reinforce grab"
	hud.master = src

	last_upgrade = world.time //makes it so you can't insta-agressive-grab.

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/throw()
	if(affecting)
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


/obj/item/weapon/grab/process()
	confirm()

	if(assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		if((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0

		if((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0

		if(state == GRAB_AGGRESSIVE)
			var/h = affecting.hand
			affecting.hand = 0
			affecting.drop_item()
			affecting.hand = 1
			affecting.drop_item()
			affecting.hand = h

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
		var/hit_zone = assailant.zone_sel.selecting
		var/announce = 0
		if(hit_zone != last_hit_zone)
			announce = 1
		last_hit_zone = hit_zone
		switch(hit_zone)
			if("mouth")
				if(announce)
					assailant.visible_message("<span class='warning'>[assailant] covers [affecting]'s mouth!</span>")
				if(affecting.silent < 3)
					affecting.silent = 3
			if("eyes")
				if(announce)
					assailant.visible_message("<span class='warning'>[assailant] covers [affecting]'s eyes!</span>")
				if(affecting.eye_blind < 3)
					affecting.eye_blind = 3

	if(state >= GRAB_NECK)
		affecting.Stun(5)  //It will hamper your voice, being choked and all.
		if(isliving(affecting))
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		affecting.Weaken(5)  //Should keep you down unless you get help.
		affecting.losebreath = min(affecting.losebreath + 2, 3)

/obj/item/weapon/grab/attack_self(mob/user)
	s_click(hud)

//Updating pixelshift, position and direction
//Gets called on process, when the grab gets upgraded or the assailant moves
/obj/item/weapon/grab/proc/adjust_position()
	if(affecting.buckled)
		return
	var/shift = 0
	var/adir = get_dir(assailant, affecting)
	affecting.layer = 4
	switch(state)
		if(GRAB_PASSIVE)
			shift = 6
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
			affecting.set_dir(reverse_dir[assailant.dir])
			affecting.loc = assailant.loc
			affecting.lying = 1

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
		del(src)
		return

	last_upgrade = world.time

	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		assailant.visible_message("<span class='warning'>[assailant] has grabbed [affecting] aggressively (now hands)!</span>")
		state = GRAB_AGGRESSIVE
		icon_state = "grabbed1"
		hud.icon_state = "reinforce1"
	else if(state < GRAB_NECK)
		if(isslime(affecting))
			assailant << "<span class='notice'>You squeeze [affecting], but nothing interesting happens.</span>"
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
	adjust_position()

//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		del(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			del(src)
			return 0
	return 1


/obj/item/weapon/grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(ishuman(M) && assailant.a_intent == "harm" && M == affecting)
		var/mob/living/carbon/human/victim = M
		if(state < GRAB_NECK)
			assailant << "<span class='warning'>You require a better grab to do this.</span>"
			return

		if(victim.grab_joint(assailant))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			return

	if(M == affecting)
		s_click(hud)
		return

	if(M == assailant && state >= GRAB_AGGRESSIVE)
		if( (ishuman(user) && (FAT in user.mutations) && iscarbon(affecting) ) || ( isalien(user) && iscarbon(affecting) ) || ( istype(user,/mob/living/carbon/human/kidan) && istype(affecting,/mob/living/carbon/monkey/diona) ) || ( ishuman(user) && user.get_species() == "Tajaran"  && istype(affecting,/mob/living/simple_animal/mouse) ) )
			var/mob/living/carbon/attacker = user
			user.visible_message("<span class='danger'>[user] is attempting to devour \the [affecting]!</span>")
			if(istype(user, /mob/living/carbon/alien/humanoid/hunter) || istype(affecting, /mob/living/simple_animal/mouse)) //mice are easy to eat
				if(!do_mob(user, affecting)||!do_after(user, 30)) return
			else
				if(!do_mob(user, affecting)||!do_after(user, 100)) return
			user.visible_message("<span class='danger'>[user] devours \the [affecting]!</span>")
			affecting.loc = user
			attacker.stomach_contents.Add(affecting)
			del(src)


/obj/item/weapon/grab/dropped()
	del(src)

/obj/item/weapon/grab/Del()
	//make sure the grabbed_by list doesn't fill up with nulls
	if(affecting) affecting.grabbed_by -= src
	..()

/obj/item/weapon/grab/Destroy()
	affecting.pixel_x = 0
	affecting.pixel_y = 0 //used to be an animate, not quick enough for del'ing
	affecting.layer = initial(affecting.layer)
	if(affecting) affecting.grabbed_by -= src
	del(hud)
	..()
