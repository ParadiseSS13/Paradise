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
	armor = list(MELEE = 200, BULLET = 200, LASER = 150, ENERGY = 200, BOMB = 200, RAD = 200, FIRE = 0, ACID = 200)	// just burn it
	/// Owner of the coffin
	var/mob/vampire
	/// Is the coffin being set on fire?
	var/igniting = FALSE

/obj/structure/closet/coffin/vampire/New(mob/user)
	..()
	name = "\proper the coffin of [user]"
	desc += "<br>Owner of this one may have not actually been dear to anyone or even departed quite yet.<br>\
		<span class='danger'>It appears imprevious to everything but fire!</span>"
	vampire = user

/obj/structure/closet/coffin/vampire/welder_act(mob/user, obj/item/I)
	if(igniting)
		return ITEM_INTERACT_COMPLETE
	if(!I.tool_use_check(user, 30))	// it's a cursed coffin, you will need something better than a maintenance welder to ignite it
		return ITEM_INTERACT_COMPLETE
	igniting = TRUE
	to_chat(user, "<span class='notice'>You attempt to set [src] on fire with [I].</span><br>\
		<span class='danger'>The wood is howling!</span>")
	if(do_after(user, 15 SECONDS, target = src))
		fire_act()
	igniting = FALSE
	return ITEM_INTERACT_COMPLETE

/obj/structure/closet/coffin/vampire/bullet_act(obj/item/projectile/P)
	if(!P.immolate)
		return ..()
	fire_act()
