/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	enable_door_overlay = FALSE
	door_anim_time = 0
	resistance_flags = FLAMMABLE
	max_integrity = 70
	material_drop = /obj/item/stack/sheet/wood
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25

/obj/structure/closet/coffin/sarcophagus
	name = "sarcophagus"
	icon_state = "sarc"
	open_sound = 'sound/effects/stonedoor_openclose.ogg'
	close_sound = 'sound/effects/stonedoor_openclose.ogg'
	material_drop = /obj/item/stack/sheet/mineral/sandstone

/obj/structure/closet/coffin/vampire
	max_integrity = 500
	anchored = TRUE
	armor = list(MELEE = 200, BULLET = 200, LASER = 80, ENERGY = 200, BOMB = 200, RAD = 200, FIRE = 80, ACID = 200)	// just burn it
	custom_fire_overlay = " "	// gets rid of regular SSfires overlay, setting it on fire uses something completely different
	/// Owner of the coffin
	var/mob/vampire
	/// Is the coffin being set on fire?
	var/igniting = FALSE
	/// Last time the vampire was warned of the attack
	COOLDOWN_DECLARE(fire_act_cooldown)

/obj/structure/closet/coffin/vampire/Initialize(mapload, mob/user)
	. = ..()
	name = "\proper the coffin of [user.mind.name]"
	desc += "<br>This coffin's owner may not actually have been dear to anyone, or even departed quite yet.<br>\
		[SPAN_WARNING("It appears impervious to everything but lasers and fire! Especially fire!")]"
	vampire = user

/obj/structure/closet/coffin/vampire/welder_act(mob/user, obj/item/I)
	if(igniting)
		return ITEM_INTERACT_COMPLETE
	if(!I.tool_use_check(user, 30))	// it's a cursed coffin, you will need something better than a maintenance welder to ignite it
		return ITEM_INTERACT_COMPLETE
	igniting = TRUE
	to_chat(user, SPAN_NOTICE("You attempt to set [src] on fire with [I]."))
	to_chat(vampire, SPAN_WARNING("Your lair is being attacked!"))
	if(do_after(user, 15 SECONDS, target = src))
		fire_act()
	igniting = FALSE
	return ITEM_INTERACT_COMPLETE

/obj/structure/closet/coffin/vampire/bullet_act(obj/projectile/P)
	if(!P.immolate)
		return ..()
	fire_act()
	return ..()

/obj/structure/closet/coffin/vampire/fire_act()
	. = ..()
	if(!COOLDOWN_FINISHED(src, fire_act_cooldown))
		return
	to_chat(vampire, SPAN_WARNING("Your lair is being attacked!"))
	switch(rand(1, 4))
		if(1)
			visible_message(SPAN_DANGER("The wood howls as fire bursts out from seemingly nowhere!"))
			playsound(src, "sound/goonstation/voice/howl.ogg", 30)
		if(2 to 3)
			visible_message(SPAN_DANGER("The wood hisses as fire bursts out from seemingly nowhere!"))
			if(prob(50))
				playsound(src, "sound/effects/unathihiss.ogg", 30)
			else
				playsound(src, "sound/effects/tajaranhiss.ogg", 30)
		if(4)
			visible_message(SPAN_DANGER("The wood growls as fire bursts out from seemingly nowhere!"))
			playsound(src, 'sound/goonstation/voice/growl3.ogg', 30)
	var/turf/new_fire = pick(oview(2, src))
	new /obj/effect/fire(get_turf(new_fire), T20C, 30 SECONDS, 1)
	new /obj/effect/fire(loc, T20C, 30 SECONDS, 1)
	COOLDOWN_START(src, fire_act_cooldown, 10 SECONDS)

/obj/structure/closet/coffin/vampire/burn()
	playsound(src, 'sound/hallucinations/wail.ogg', 20, extrarange = SOUND_RANGE_SET(5))
	visible_message(SPAN_DANGER("Fire bursts out from [name] as it falls apart!"))
	for(var/turf/T in range(1, src))
		new /obj/effect/fire(T, T20C, 30 SECONDS, 1)
	..()
