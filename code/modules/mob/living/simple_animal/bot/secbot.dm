/mob/living/simple_animal/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot0"
	density = 0
	anchored = 0
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB

	radio_channel = "Security" //Security channel
	bot_type = SEC_BOT
	bot_filter = RADIO_SECBOT
	model = "Securitron"
	bot_purpose = "seek out criminals, handcuff them, and report their location to security"
	bot_core_type = /obj/machinery/bot_core/secbot
	window_id = "autosec"
	window_name = "Automatic Security Unit v1.6"
	path_image_color = "#FF0000"
	data_hud_type = DATA_HUD_SECURITY_ADVANCED

	var/base_icon = "secbot"
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
	var/harmbaton = 0 //If true, beat instead of stun
	var/flashing_lights = 0 //If true, flash lights
	var/prev_flashing_lights = 0
	allow_pai = 0

/mob/living/simple_animal/bot/secbot/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! Powered by a potato and a shot of whiskey."
	idcheck = 0
	weaponscheck = 0
	auto_patrol = 1

/mob/living/simple_animal/bot/secbot/beepsky/explode()
	var/turf/Tsec = get_turf(src)
	new /obj/item/stock_parts/cell/potato(Tsec)
	var/obj/item/reagent_containers/food/drinks/drinkingglass/S = new(Tsec)
	S.reagents.add_reagent("whiskey", 15)
	S.on_reagent_change()
	..()

/mob/living/simple_animal/bot/secbot/pingsky
	name = "Officer Pingsky"
	desc = "It's Officer Pingsky! Delegated to satellite guard duty for harbouring anti-human sentiment."
	radio_channel = "AI Private"

/mob/living/simple_animal/bot/secbot/ofitser
	name = "Prison Ofitser"
	desc = "It's Prison Ofitser! Powered by the tears and sweat of prisoners."
	idcheck = 0
	weaponscheck = 1
	auto_patrol = 1

/mob/living/simple_animal/bot/secbot/buzzsky
	name = "Officer Buzzsky"
	desc = "It's Officer Buzzsky! Rusted and falling apart, he seems less than thrilled with the crew for leaving him in his current state."
	base_icon = "rustbot"
	icon_state = "rustbot0"
	declare_arrests = 0
	arrest_type = 1
	harmbaton = 1
	emagged = 2

/mob/living/simple_animal/bot/secbot/armsky
	name = "Sergeant-at-Armsky"
	health = 45
	idcheck = 1
	arrest_type = 1
	weaponscheck = 1

/mob/living/simple_animal/bot/secbot/New()
	..()
	icon_state = "[base_icon][on]"
	spawn(3)
		var/datum/job/detective/J = new/datum/job/detective
		access_card.access += J.get_access()
		prev_access = access_card.access

	//SECHUD
	var/datum/atom_hud/secsensor = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	secsensor.add_hud_to(src)
	permanent_huds |= secsensor

/mob/living/simple_animal/bot/secbot/turn_on()
	..()
	icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/secbot/turn_off()
	..()
	icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/secbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	anchored = 0
	walk_to(src,0)
	last_found = world.time

/mob/living/simple_animal/bot/secbot/set_custom_texts()

	text_hack = "You overload [name]'s target identification system."
	text_dehack = "You reboot [name] and restore the target identification."
	text_dehack_fail = "[name] refuses to accept your authority!"

/mob/living/simple_animal/bot/secbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
<TT><B>[window_name]</B></TT><BR><BR>
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

/mob/living/simple_animal/bot/secbot/Topic(href, href_list)
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

/mob/living/simple_animal/bot/secbot/proc/retaliate(mob/living/carbon/human/H)
	threatlevel = H.assess_threat(src)
	threatlevel += 6
	if(threatlevel >= 4)
		target = H
		mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_HARM || H.a_intent == INTENT_DISARM)
		retaliate(H)
	return ..()

/mob/living/simple_animal/bot/secbot/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weldingtool) && user.a_intent != INTENT_HARM) // Any intent but harm will heal, so we shouldn't get angry.
		return
	if(!istype(W, /obj/item/screwdriver) && (W.force) && (!target) && (W.damtype != STAMINA) ) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
		retaliate(user)

/mob/living/simple_animal/bot/secbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, "<span class='danger'>You short out [src]'s target assessment circuits.</span>")
			oldtarget_name = user.name
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
		declare_arrests = 0
		icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/secbot/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < src.health)
				retaliate(Proj.firer)
	..()


/mob/living/simple_animal/bot/secbot/UnarmedAttack(atom/A)
	if(!on)
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(!C.stunned || arrest_type)
			stun_attack(A)
		else if(C.canBeHandcuffed() && !C.handcuffed)
			cuff(A)
	else
		..()


/mob/living/simple_animal/bot/secbot/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		if(I.throwforce < src.health && I.thrownby && ishuman(I.thrownby))
			var/mob/living/carbon/human/H = I.thrownby
			retaliate(H)
	..()


/mob/living/simple_animal/bot/secbot/proc/cuff(mob/living/carbon/C)
	mode = BOT_ARREST
	playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
	C.visible_message("<span class='danger'>[src] is trying to put zipties on [C]!</span>",\
						"<span class='userdanger'>[src] is trying to put zipties on you!</span>")
	INVOKE_ASYNC(src, .proc/cuff_callback, C)

/mob/living/simple_animal/bot/secbot/proc/cuff_callback(mob/living/carbon/C)
	if(do_after(src, 60, target = C))
		if(!C.handcuffed)
			C.handcuffed = new /obj/item/restraints/handcuffs/cable/zipties/used(C)
			C.update_handcuffed()
			playsound(loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
			back_to_idle()

/mob/living/simple_animal/bot/secbot/proc/stun_attack(mob/living/carbon/C)
	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
	if(harmbaton)
		playsound(loc, 'sound/weapons/genhit1.ogg', 50, 1, -1)
	icon_state = "[base_icon]-c"
	spawn(2)
		icon_state = "[base_icon][on]"
	var/threat = C.assess_threat(src)
	if(ishuman(C) && harmbaton) // Bots with harmbaton enabled become shitcurity. - Dave
		C.apply_damage(10, BRUTE)
	C.SetStuttering(5)
	C.Stun(5)
	C.Weaken(5)
	add_attack_logs(src, C, "stunned")
	if(declare_arrests)
		var/area/location = get_area(src)
		speak("[arrest_type ? "Detaining" : "Arresting"] level [threat] scumbag <b>[C]</b> in [location].", radio_channel)
	C.visible_message("<span class='danger'>[src] has [harmbaton ? "beaten" : "stunned"] [C]!</span>",\
							"<span class='userdanger'>[src] has [harmbaton ? "beaten" : "stunned"] you!</span>")

/mob/living/simple_animal/bot/secbot/Life(seconds, times_fired)
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

/mob/living/simple_animal/bot/secbot/verb/toggle_flashing_lights()
	set name = "Toggle Flashing Lights"
	set category = "Object"
	set src = usr

	flashing_lights = !flashing_lights

/mob/living/simple_animal/bot/secbot/handle_automated_action()
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
			if(frustration >= 8)
				walk_to(src,0)
				back_to_idle()
				return

			if(target)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc))	// if right next to perp
					stun_attack(target)

					mode = BOT_PREP_ARREST
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
						cuff(target)
					else
						back_to_idle()
						return
			else
				back_to_idle()
				return

		if(BOT_ARREST)
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
				anchored = 0

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()


	return

/mob/living/simple_animal/bot/secbot/proc/back_to_idle()
	anchored = 0
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	spawn(0)
		handle_automated_action() //ensure bot quickly responds

/mob/living/simple_animal/bot/secbot/proc/back_to_hunt()
	anchored = 0
	frustration = 0
	mode = BOT_HUNT
	spawn(0)
		handle_automated_action() //ensure bot quickly responds
// look for a criminal in view of the bot

/mob/living/simple_animal/bot/secbot/proc/look_for_perp()
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
			mode = BOT_HUNT
			spawn(0)
				handle_automated_action()	// ensure bot quickly responds to a perp
			break
		else
			continue
/mob/living/simple_animal/bot/secbot/proc/check_for_weapons(var/obj/item/slot_item)
	if(slot_item && slot_item.needs_permit)
		return 1
	return 0

/mob/living/simple_animal/bot/secbot/explode()
	walk_to(src,0)
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)
	var/obj/item/secbot_assembly/Sa = new /obj/item/secbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += "hs_hole"
	Sa.created_name = name
	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/melee/baton(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)
	do_sparks(3, 1, src)
	new /obj/effect/decal/cleanable/blood/oil(loc)
	..()

/mob/living/simple_animal/bot/secbot/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/Crossed(atom/movable/AM, oldloc)
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

/obj/machinery/bot_core/secbot
	req_access = list(ACCESS_SECURITY)
