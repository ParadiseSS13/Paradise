/mob/living/simple_animal/bot/griefsky //This bot is powerful. If you managed to get 4 eswords somehow, you deserve this horror.
	name = "\improper General Griefsky"
	desc = "Is that a secbot with four eswords in its arms...?"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "griefsky0"
	density = 0
	anchored = 0
	health = 150
	maxHealth = 150
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB
	radio_channel = "Security" //Security channel
	bot_type = SEC_BOT
	bot_filter = RADIO_SECBOT
	model = "Securitron"
	bot_purpose = "seek out criminals, end their miserable lifes"
	bot_core_type = /obj/machinery/bot_core/secbot
	window_id = "autosec"
	window_name = "Automatic Security Unit v9.0"
	path_image_color = "#FF0000"
	data_hud_type = DATA_HUD_SECURITY_ADVANCED
	allow_pai = 0
	var/weapon //edagger or esword 
	weapon = /obj/item/melee/energy/sword
	
	var/spin_icon = "griefsky-c" // griefsky and griefsky junior have dif icons
	var/dmg = 30 //esword dmg
	var/block_chance_melee = 50
	var/block_chance_ranged = 90
	var/spam_flag = 0
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

	
/mob/living/simple_animal/bot/griefsky/proc/spam_flag_false() //used for addtimer to not spam comms
	spam_flag = 0

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
	name = "Griefsky apprentice"
	desc = "Is that a secbot with four energy daggers in its arms...?"
	dmg = 18 // e dagger
	block_chance_melee = 30
	block_chance_ranged = 50
	spin_icon = "griefskyj-c"
	window_name = "Automatic Security Unit v7.0"
	health = 100
	maxHealth = 100
	weapon = /obj/item/pen/edagger

/mob/living/simple_animal/bot/griefsky/griefsky/toy  //A toy version of general griefsky!
	name = "Genewul Bweepskee"
	desc = "An adorable looking secbot with four toy swords taped to its arms"
	spin_icon = "griefskyj-c"
	health = 50
	maxHealth = 50
	dmg = 0
	block_chance_melee = 0
	block_chance_ranged = 0
	bot_core_type = /obj/machinery/bot_core/toy

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
		light_color = LIGHT_COLOR_PURE_RED //if you see a red one. RUN!!

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
			speak("Back away! i will deal with this level [threat] swine <b>[C]</b> in [location] myself!.", radio_channel)
			spam_flag = 1
			addtimer(CALLBACK(src, .proc/spam_flag_false), 100) //to avoid spamming comms of sec for each hit
			visible_message("[src] flails his swords and cuts [C]!")

/mob/living/simple_animal/bot/griefsky/handle_automated_action()
	if(!..())
		return

	switch(mode)
		if(BOT_IDLE)		// idle
			icon_state = "griefsky1"
			walk_to(src,0)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_HUNT)		// hunting for perp
			// if can't reach perp for long enough, go idle
			icon_state = spin_icon
			playsound(loc,'sound/effects/spinsabre.ogg',100,1,-1)
			if(frustration >= 20) // general griefsky doesn't give up so easily, jedi scum
				walk_to(src,0)
				back_to_idle()
				return

			if(target)		// make sure target exists
				if(target.stat == !DEAD)
					if(Adjacent(target) && isturf(target.loc))	// if right next to perp
						sword_attack(target)
						anchored = 1
						target_lastloc = target.loc
						return
					else								// not next to perp
						var/turf/olddist = get_dist(src, target)
						walk_to(src, target,1,3) //he's a fast fucker
						if((get_dist(src, target)) >= (olddist))
							frustration++
						else
							frustration = 0
				else 
					back_to_idle()
					speak("You fool")
			else
				back_to_idle()

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			icon_state = "griefsky1"
			look_for_perp()
			bot_patrol()
	return

/mob/living/simple_animal/bot/griefsky/proc/back_to_idle()
	playsound(loc, 'sound/weapons/saberoff.ogg', 50, 1, -1)
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
			speak("You are a bold one")
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
	var/turf/Tsec = get_turf(src)
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		new /obj/item/robot_parts/r_arm(Tsec)
	if(prob(50)) //most of the time weapon will be destroyed
		new weapon(Tsec)
	if(prob(25))
		new weapon(Tsec)
	if(prob(10))
		new weapon(Tsec)
	if(prob(5))
		new weapon(Tsec)
	do_sparks(3, 1, src)
	new /obj/effect/decal/cleanable/blood/oil(loc)
	..()

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

/mob/living/simple_animal/bot/griefsky/bullet_act(obj/item/projectile/P) //so uncivilized
	retaliate(P.firer)
	if((icon_state == spin_icon) && (prob(block_chance_ranged))) //only when the eswords are on
		visible_message("[src] deflects [P] with its energy swords!")
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1, 0)
	else
		..()
	
/mob/living/simple_animal/bot/griefsky/proc/special_retaliate_after_attack(mob/user) //allows special actions to take place after being attacked.
	return

/mob/living/simple_animal/bot/griefsky/special_retaliate_after_attack(mob/user)
	if(icon_state != spin_icon)
		return
	if(prob(block_chance_melee))
		visible_message("[src] deflects [user]'s attack with his energy swords!")
		playsound(loc, 'sound/weapons/blade1.ogg', 50, TRUE, -1)	
		return TRUE

/mob/living/simple_animal/bot/griefsky/attack_hand(mob/living/carbon/human/H)
	if((H.a_intent == INTENT_HARM) || (H.a_intent == INTENT_DISARM))
		retaliate(H)
		if(special_retaliate_after_attack(H))
			return
	return ..()

/mob/living/simple_animal/bot/griefsky/attackby(obj/item/W, mob/user, params) //cant touch or attack him while spinning
	if(src.icon_state == spin_icon)
		if(prob(block_chance_melee))
			user.changeNext_move(CLICK_CD_MELEE)
			user.do_attack_animation(src)
			visible_message("[src] deflects [user]'s move with his energy swords!")
			playsound(loc, 'sound/weapons/blade1.ogg', 50, TRUE, -1)
		else
			..()
	else
		..()

/obj/machinery/bot_core/secbot
	req_access = list(access_security)

/obj/machinery/bot_core/toy
	req_access = list(access_maint_tunnels, access_theatre, access_robotics)