/mob/living/simple_animal/bot/griefsky
	name = "\improper General Griefsky"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "griefsky0"
	density = 0
	anchored = 0
	health = 150
	maxHealth = 150
	base_speed = 4 //he's a fast fucker
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB

	radio_channel = "Security" //Security channel
	bot_type = SEC_BOT
	bot_filter = RADIO_SECBOT
	model = "Securitron"
	bot_purpose = "seek out criminals, handcuff them, and report their location to security"
	bot_core_type = /obj/machinery/bot_core/secbot
	window_id = "autosec"
	window_name = "Automatic Security Unit v9.0"
	path_image_color = "#FF0000"
	data_hud_type = DATA_HUD_SECURITY_ADVANCED
	allow_pai = 0

	var/block_chance = 50
	var/spin_icon = "griefsky-c" // griefsky and griefsky junior have dif icons
	var/dmg = 30
	var/spam_flag = FALSE
	var/base_icon = "griefsky"
	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/declare_arrests = 1 //When making an arrest, should it notify everyone on the security channel?
	var/idcheck = 0 //If true, arrest people with no IDs
	var/weaponscheck = 0 //If true, arrest people for weapons if they lack access
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff
	var/harmbaton = 1 //If true, beat instead of stun
	var/flashing_lights = 0 //If true, flash lights
	var/prev_flashing_lights = 0                                       //REMOVE VARS WHEN DONE!!!!!!!!!!!!!PLEASE SACALAS >:/, ya estna en beepsky
	var/onetime = 0

/mob/living/simple_animal/bot/griefsky/proc/spam_flag_false() //used for addtimer to not spam comms
	spam_flag = FALSE

/*/mob/living/simple_animal/bot/griefsky/explode()
	var/turf/Tsec = get_turf(src)
	new /obj/item/melee/energy/sword(Tsec)
	..() */

/mob/living/simple_animal/bot/griefsky/New()
	..()
	icon_state = "[base_icon][on]"
	spawn(3)
		var/datum/job/detective/J = new/datum/job/detective
		access_card.access += J.get_access()
		prev_access = access_card.access

	//SECHUD
	var/datum/atom_hud/secsensor = huds[DATA_HUD_SECURITY_ADVANCED]
	secsensor.add_hud_to(src)
	permanent_huds |= secsensor

/mob/living/simple_animal/bot/griefsky/jgriefsky  // cheaper griefsky less damage
	name = "General griefsky"
	desc = "It's Prison Ofitser! ."
	dmg = 15
	spin_icon = "griefskyj-c"
	
/mob/living/simple_animal/bot/griefsky/turn_on()
	..()
	icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/griefsky/turn_off()
	..()
	icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/griefsky/bot_reset()
	..()
	target = null
	oldtarget_name = null
	anchored = 0
	walk_to(src,0)
	last_found = world.time

/mob/living/simple_animal/bot/griefsky/set_custom_texts()

	text_hack = "You overload [name]'s target identification system."
	text_dehack = "You reboot [name] and restore the target identification."
	text_dehack_fail = "[name] refuses to accept your authority!"

/mob/living/simple_animal/bot/griefsky/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
<TT><B>Securitron v9.0 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"},

"<A href='?src=[UID()];power=1'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user) || user.can_admin_interact())
		dat += text({"<BR>
Arrest Unidentifiable Persons: []<BR>
Arrest for Unauthorized Weapons: []<BR>
Arrest for Warrant: []<BR>
Operating Mode: []<BR>
Report Arrests[]<BR>
Auto Patrol: []"},

"<A href='?src=[UID()];operation=idcheck'>[idcheck ? "Yes" : "No"]</A>",
"<A href='?src=[UID()];operation=weaponscheck'>[weaponscheck ? "Yes" : "No"]</A>",
"<A href='?src=[UID()];operation=ignorerec'>[check_records ? "Yes" : "No"]</A>",
"<A href='?src=[UID()];operation=switchmode'>[arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=[UID()];operation=declarearrests'>[declare_arrests ? "Yes" : "No"]</A>",
"<A href='?src=[UID()];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )

	return	dat

/mob/living/simple_animal/bot/griefsky/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["operation"])
		if("idcheck")
			idcheck = !idcheck
			update_controls()
		if("weaponscheck")
			weaponscheck = !weaponscheck
			update_controls()
		if("ignorerec")
			check_records = !check_records
			update_controls()
		if("switchmode")
			arrest_type = !arrest_type
			update_controls()
		if("declarearrests")
			declare_arrests = !declare_arrests
			update_controls()

/mob/living/simple_animal/bot/griefsky/proc/retaliate(mob/living/carbon/human/H)
	threatlevel = H.assess_threat(src)
	threatlevel += 6
	if(threatlevel >= 4)
		target = H
		mode = BOT_HUNT

/mob/living/simple_animal/bot/griefsky/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_HARM || H.a_intent == INTENT_DISARM)
		retaliate(H)
	return ..()

/mob/living/simple_animal/bot/griefsky/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weldingtool) && user.a_intent != INTENT_HARM) // Any intent but harm will heal, so we shouldn't get angry.
		return
	if(!istype(W, /obj/item/screwdriver) && (W.force) && (!target) && (W.damtype != STAMINA) ) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
		retaliate(user)

/mob/living/simple_animal/bot/griefsky/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, "<span class='danger'>You short out [src]'s target assessment circuits.</span>")
			oldtarget_name = user.name
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
		declare_arrests = 0
		icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/griefsky/bullet_act(obj/item/projectile/Proj)            //if you fire him it will increase your threat level
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < src.health)
				retaliate(Proj.firer)
	..()

/mob/living/simple_animal/bot/griefsky/UnarmedAttack(atom/A)        //when controlled by a player
	if(!on)
		return
	if(iscarbon(A))
		sword_attack(A)
	else
		..()

/mob/living/simple_animal/bot/griefsky/hitby(atom/movable/AM, skipcatch = 0, hitpush = 1, blocked = 0) //if you throw him something
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		if(I.throwforce < src.health && I.thrownby && ishuman(I.thrownby))
			var/mob/living/carbon/human/H = I.thrownby
			retaliate(H)
	..()


/*/mob/living/simple_animal/bot/griefsky/proc/cuff(mob/living/carbon/C)
	mode = BOT_ARREST
	playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
	C.visible_message("<span class='danger'>[src] is trying to put zipties on [C]!</span>",\
						"<span class='userdanger'>[src] is trying to put zipties on you!</span>")
	spawn(60)
		if( !Adjacent(C) || !isturf(C.loc) ) //if he's in a closet or not adjacent, we cancel cuffing.
			return
		if(!C.handcuffed)
			C.handcuffed = new /obj/item/restraints/handcuffs/cable/zipties/used(C)
			C.update_handcuffed()
			playsound(loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
			back_to_idle() */

/mob/living/simple_animal/bot/griefsky/proc/sword_attack(mob/living/carbon/C)     // esword attack
	src.do_attack_animation(C)
	playsound(loc, 'sound/weapons/blade1.ogg', 50, 1, -1)
	spawn(2)
	icon_state = spin_icon
	var/threat = C.assess_threat(src)
	if(ishuman(C))
		C.apply_damage(dmg, BRUTE)
		if(prob(50)) 
			C.Weaken(5)
	add_attack_logs(src, C, "sliced")
	if(declare_arrests)
		var/area/location = get_area(src)
		if(!spam_flag)
			speak("[arrest_type ? "Detaining" : "Arresting"] level [threat] scumbag <b>[C]</b> in [location].", radio_channel)
			spam_flag = TRUE
			addtimer(CALLBACK(src, .proc/spam_flag_false), 100) //to avoid spamming comms of sec for each hit
			visible_message("[src] flails his swords and cuts [C]!")

/mob/living/simple_animal/bot/griefsky/Life(seconds, times_fired)
	. = ..()
	if(flashing_lights)
		switch(light_color)
			if(LIGHT_COLOR_PURE_RED)
				light_color = LIGHT_COLOR_PURE_BLUE
			if(LIGHT_COLOR_PURE_BLUE)
				light_color = LIGHT_COLOR_PURE_RED
		update_light()
	else if(prev_flashing_lights)
		light_color = LIGHT_COLOR_PURE_RED
		update_light()

	prev_flashing_lights = flashing_lights

/mob/living/simple_animal/bot/griefsky/verb/toggle_flashing_lights()
	set name = "Toggle Flashing Lights"
	set category = "Object"
	set src = usr

	flashing_lights = !flashing_lights

/mob/living/simple_animal/bot/griefsky/handle_automated_action()
	if(!..())
		return

	flashing_lights = mode == BOT_HUNT

	switch(mode)
		if(BOT_IDLE)		// idle
			walk_to(src,0)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_HUNT)		// hunting for perp
			// if can't reach perp for long enough, go idle
			icon_state = spin_icon
			playsound(src,'sound/effects/spinsabre.ogg',100,TRUE,-1)
			if(frustration >= 8)
				walk_to(src,0)
				back_to_idle()
				return

			if(target)		// make sure target exists
				if(target.stat == !DEAD)	
					if(Adjacent(target) && isturf(target.loc))	// if right next to perp
						sword_attack(target)

				//	mode = BOT_PREP_ARREST
						anchored = 1
						target_lastloc = target.loc
						return

					else								// not next to perp
						var/turf/olddist = get_dist(src, target)
						walk_to(src, target,1,4)
						if((get_dist(src, target)) >= (olddist))
							frustration++
						else
							frustration = 0
				else
					back_to_idle()

		if(BOT_PREP_ARREST)		// preparing to arrest target

			// see if he got away. If he's no no longer adjacent or inside a closet or about to get up, we hunt again.
			if( !Adjacent(target) || !isturf(target.loc) ||  target.weakened < 2 )
				back_to_hunt()
				return

			if(iscarbon(target) && target.canBeHandcuffed())
				if(!arrest_type)
					if(!target.handcuffed)  //he's not cuffed? Try to cuff him!
						//cuff(target)
					else
						back_to_idle()
						return
			else
				back_to_idle()
				return

	/*	if(BOT_ARREST)
			if(!target)
				anchored = 0
				mode = BOT_IDLE
				last_found = world.time
				frustration = 0
				return

			if(target.handcuffed) //no target or target cuffed? back to idle.
				back_to_idle()
				return

			if(!Adjacent(target) || !isturf(target.loc) || (target.loc != target_lastloc && target.weakened < 2)) //if he's changed loc and about to get up or not adjacent or got into a closet, we prep arrest again.
				back_to_hunt()
				return
			else //Try arresting again if the target escapes.
				mode = BOT_PREP_ARREST
				anchored = 0 */

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			icon_state = "griefsky1"
			look_for_perp()
			bot_patrol()
	return

/mob/living/simple_animal/bot/griefsky/proc/back_to_idle()
	anchored = 0
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	spawn(0)
		handle_automated_action() //ensure bot quickly responds

/mob/living/simple_animal/bot/griefsky/proc/back_to_hunt()
	anchored = 0
	frustration = 0
	mode = BOT_HUNT
	spawn(0)
		handle_automated_action() //ensure bot quickly responds
// look for a criminal in view of the bot

/mob/living/simple_animal/bot/griefsky/proc/look_for_perp()
	anchored = 0
	for(var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = C.assess_threat(src)

		if(!threatlevel)
			continue

		else if(threatlevel >= 4)
			target = C
			oldtarget_name = C.name
			speak("Level [threatlevel] infraction alert!")
			playsound(loc, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, 0)
			visible_message("<b>[src]</b> points at [C.name]!")
			playsound(loc, 'sound/weapons/saberon.ogg', 50, 1, -1)
			mode = BOT_HUNT
			spawn(0)
				handle_automated_action()	// ensure bot quickly responds to a perp
			break
		else
			continue
/mob/living/simple_animal/bot/griefsky/proc/check_for_weapons(var/obj/item/slot_item)
	if(slot_item && slot_item.needs_permit)
		return 1
	return 0

/mob/living/simple_animal/bot/griefsky/explode()
	walk_to(src,0)
	visible_message("<span class='boldannounce'>[src] lets out a huge cough as it blows apart!</span>")
	var/atom/Tsec = drop_location()
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		new /obj/item/robot_parts/r_arm(Tsec)
	if(prob(75))
		new /obj/item/melee/energy/sword(Tsec)
	do_sparks(3, TRUE, src)
	new /obj/effect/decal/cleanable/blood/oil(loc)

/mob/living/simple_animal/bot/griefsky/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT

/mob/living/simple_animal/bot/griefsky/Crossed(atom/movable/AM)
	if(ismob(AM) && target)
		var/mob/living/carbon/C = AM
		if(!istype(C) || !C || in_range(src, target))
			return
		C.visible_message("<span class='warning'>[pick( \
						  "[C] dives out of [src]'s way!", \
						  "[C] stumbles over [src]!", \
						  "[C] jumps out of [src]'s path!", \
						  "[C] trips over [src] and falls!", \
						  "[C] topples over [src]!", \
						  "[C] leaps out of [src]'s way!")]</span>")
		C.Weaken(2)
		return
	..() 

/mob/living/simple_animal/bot/griefsky/bullet_act(obj/item/projectile/P)
	visible_message("[src] deflects [P] with its energy swords!")
	playsound(loc, 'sound/weapons/blade1.ogg', 50, 1, FALSE)
	retaliate(P.firer)
	return FALSE

/obj/machinery/bot_core/secbot
	req_access = list(access_security)