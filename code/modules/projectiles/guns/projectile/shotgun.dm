/obj/item/gun/projectile/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	worn_icon_state = null
	inhand_icon_state = null
	lefthand_file = 'icons/mob/inhands/64x64_guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_guns_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	weapon_weight = WEAPON_HEAVY
	var/pump_time = 1 SECONDS // To prevent spammage
	COOLDOWN_DECLARE(pump_cooldown)

/obj/item/gun/projectile/shotgun/examine(mob/user)
	. = ..()
	if(chambered)
		. += "A [chambered.BB ? "live" : "spent"] one is in the chamber."
	. += get_shotgun_info()

/obj/item/gun/projectile/shotgun/proc/get_shotgun_info()
	return "<span class='notice'>After firing a shot, use this item in hand to remove the spent shell.</span>"

/obj/item/gun/projectile/shotgun/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	var/num_loaded = magazine.attackby__legacy__attackchain(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		A.update_icon()
		update_icon()

/obj/item/gun/projectile/shotgun/process_chamber()
	return ..(FALSE, FALSE)

/obj/item/gun/projectile/shotgun/chamber_round()
	return

/obj/item/gun/projectile/shotgun/can_shoot()
	if(!chambered)
		return FALSE
	return chambered.BB

/obj/item/gun/projectile/shotgun/attack_self__legacy__attackchain(mob/living/user)
	if(!COOLDOWN_FINISHED(src, pump_cooldown))
		return
	pump(user)
	COOLDOWN_START(src, pump_cooldown, pump_time)

/obj/item/gun/projectile/shotgun/proc/pump(mob/M)
	if(QDELETED(M))
		return
	playsound(M, 'sound/weapons/gun_interactions/shotgunpump.ogg', 60, TRUE)
	pump_unload()
	pump_reload()

/obj/item/gun/projectile/shotgun/proc/pump_unload()
	if(chambered)//We have a shell in the chamber
		chambered.forceMove(get_turf(src))
		chambered.SpinAnimation(5, 1)
		playsound(src, chambered.casing_drop_sound, 60, TRUE)
		chambered = null

/obj/item/gun/projectile/shotgun/proc/pump_reload()
	if(!magazine.ammo_count())
		return FALSE
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC

/obj/item/gun/projectile/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// RIOT SHOTGUN //

/// for spawn in the armory
/obj/item/gun/projectile/shotgun/riot
	name = "\improper M500 riot shotgun"
	desc = "A sturdy shotgun by Starstrike Arms, featuring a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot
	sawn_desc = "Come with me if you want to live."

/obj/item/gun/projectile/shotgun/riot/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)
	if(istype(A, /obj/item/melee/energy))
		var/obj/item/melee/energy/W = A
		if(HAS_TRAIT(W, TRAIT_ITEM_ACTIVE))
			sawoff(user)
	if(istype(A, /obj/item/pipe))
		unsaw(A, user)
	else
		return ..()

/obj/item/gun/projectile/shotgun/riot/sawoff(mob/user)
	if(sawn_state == SAWN_OFF)
		to_chat(user, "<span class='warning'>[src] has already been shortened!</span>")
		return
	if(isstorage(loc))	//To prevent inventory exploits
		to_chat(user, "<span class='notice'>How do you plan to modify [src] while it's in a bag.</span>")
		return
	if(chambered)	//if the gun is chambering live ammo, shoot self, if chambering empty ammo, 'click'
		if(chambered.BB)
			process_fire(user, user)
			user.visible_message("<span class='danger'>\The [src] goes off!</span>", "<span class='danger'>\The [src] goes off in your face!</span>")
			return
		else
			afterattack__legacy__attackchain(user, user)
			user.visible_message("[src] goes click!", "<span class='notice'>[src] you are holding goes click.</span>")
	if(magazine.ammo_count())	//Spill the mag onto the floor
		user.visible_message("<span class='danger'>[user.name] opens [src] up and the shells go goes flying around!</span>", "<span class='userdanger'>You open [src] up and the shells go goes flying everywhere!!</span>")
		while(get_ammo(0) > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			if(CB)
				CB.loc = get_turf(loc)
				CB.update_icon()

	if(do_after(user, 30, target = src))
		user.visible_message("[user] shortens \the [src]!", "<span class='notice'>You shorten \the [src].</span>")
		post_sawoff()
		return 1

/obj/item/gun/projectile/shotgun/riot/proc/post_sawoff()
	w_class = WEIGHT_CLASS_NORMAL
	current_skin = "riotshotgun_sawn"
	slot_flags &= ~ITEM_SLOT_BACK    //you can't sling it on your back
	slot_flags |= ITEM_SLOT_BELT     //but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
	sawn_state = SAWN_OFF
	magazine.max_ammo = 3
	update_appearance()

/obj/item/gun/projectile/shotgun/riot/proc/unsaw(obj/item/A, mob/user)
	if(sawn_state == SAWN_INTACT)
		to_chat(user, "<span class='warning'>[src] has not been shortened!</span>")
		return
	if(isstorage(loc))	//To prevent inventory exploits
		to_chat(user, "<span class='notice'>How do you plan to modify [src] while it's in a bag.</span>")
		return
	if(chambered)	//if the gun is chambering live ammo, shoot self, if chambering empty ammo, 'click'
		if(chambered.BB)
			afterattack__legacy__attackchain(user, user)
			user.visible_message("<span class='danger'>\The [src] goes off!</span>", "<span class='danger'>\The [src] goes off in your face!</span>")
			return
		else
			afterattack__legacy__attackchain(user, user)
			user.visible_message("[src] goes click!", "<span class='notice'>[src] you are holding goes click.</span>")
	if(magazine.ammo_count())	//Spill the mag onto the floor
		user.visible_message("<span class='danger'>[user.name] opens [src] up and the shells go goes flying around!</span>", "<span class='userdanger'>You open [src] up and the shells go goes flying everywhere!!</span>")
		while(get_ammo() > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			if(CB)
				CB.loc = get_turf(loc)
				CB.update_icon()

	if(do_after(user, 30, target = src))
		qdel(A)
		user.visible_message("<span class='notice'>[user] lengthens [src]!</span>", "<span class='notice'>You lengthen [src].</span>")
		post_unsaw(user)
		return 1

/obj/item/gun/projectile/shotgun/riot/proc/post_unsaw()
	w_class = initial(w_class)
	current_skin = "riotshotgun"
	slot_flags &= ~ITEM_SLOT_BELT
	slot_flags |= ITEM_SLOT_BACK
	sawn_state = SAWN_INTACT
	magazine.max_ammo = 6
	update_appearance()

/obj/item/gun/projectile/shotgun/riot/update_icon_state() //Can't use the old proc as it makes it go to riotshotgun-short_sawn
	if(current_skin)
		icon_state = "[current_skin]"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun/projectile/shotgun/riot/short
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot/short

/obj/item/gun/projectile/shotgun/riot/short/Initialize(mapload)
	. = ..()
	post_sawoff()

///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/gun/projectile/shotgun/boltaction
	name = "\improper Mosin Nagant"
	desc = "An ancient design commonly used by the conscript forces of the USSP. Chambered in 7.62mm. Has a bayonet lug for attaching a knife."
	icon_state = "moistnugget"
	worn_icon_state = "moistnugget"
	inhand_icon_state = "moistnugget"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	fire_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 13
	execution_speed = 7 SECONDS
	var/bolt_open = FALSE

/obj/item/gun/projectile/shotgun/boltaction/pump(mob/M)
	playsound(M, 'sound/weapons/gun_interactions/rifle_load.ogg', 60, 1)
	if(bolt_open)
		pump_reload(M)
	else
		pump_unload(M)
	bolt_open = !bolt_open
	update_icon(UPDATE_ICON_STATE)
	return 1

/obj/item/gun/projectile/shotgun/boltaction/update_icon_state()
	icon_state = "[initial(icon_state)][bolt_open ? "-open" : ""]"

/obj/item/gun/projectile/shotgun/blow_up(mob/user)
	. = 0
	if(chambered && chambered.BB)
		process_fire(user, user,0)
		. = 1

/obj/item/gun/projectile/shotgun/boltaction/attackby__legacy__attackchain(obj/item/A, mob/user, params)
	if(!bolt_open)
		to_chat(user, "<span class='notice'>The bolt is closed!</span>")
		return
	. = ..()

/obj/item/gun/projectile/shotgun/boltaction/examine(mob/user)
	. = ..()
	. += "The bolt is [bolt_open ? "open" : "closed"]."

/obj/item/gun/projectile/shotgun/boltaction/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	var/guns_left = 30
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted
	can_bayonet = FALSE

/obj/item/gun/projectile/shotgun/boltaction/enchanted/Initialize(mapload)
	. = ..()
	bolt_open = 1
	pump()

/obj/item/gun/projectile/shotgun/boltaction/enchanted/dropped()
	..()
	guns_left = 0

/obj/item/gun/projectile/shotgun/boltaction/enchanted/attack_self__legacy__attackchain()
	return

/obj/item/gun/projectile/shotgun/boltaction/enchanted/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	..()
	if(guns_left)
		var/obj/item/gun/projectile/shotgun/boltaction/enchanted/GUN = new type
		GUN.guns_left = guns_left - 1
		discard_gun(user)
		user.swap_hand()
		user.drop_item()
		user.put_in_hands(GUN)
	else
		discard_gun(user)

/obj/item/gun/projectile/shotgun/boltaction/enchanted/proc/discard_gun(mob/living/user)
	user.visible_message("<span class='warning'>[user] tosses aside the spent rifle!</span>")
	user.throw_item(pick(oview(7, get_turf(user))))

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage
	name = "arcane barrage"
	desc = "Pew Pew Pew."
	icon_state = "arcane_barrage"
	inhand_icon_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	fire_sound = 'sound/weapons/emitter.ogg'
	slot_flags = null
	flags = NOBLUDGEON | DROPDEL | ABSTRACT
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/examine(mob/user)
	return build_base_description() // Override since magical hand lasers don't have chambers or bolts

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/discard_gun(mob/living/user)
	qdel(src)

// Automatic Shotguns//

/obj/item/gun/projectile/shotgun/automatic

/obj/item/gun/projectile/shotgun/automatic/get_shotgun_info()
	return "<span class='notice'>Automatically releases spent shotgun shells.</span>"

/obj/item/gun/projectile/shotgun/automatic/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	..()
	pump(user)

/obj/item/gun/projectile/shotgun/automatic/combat
	name = "\improper M600 combat shotgun"
	desc = "A semi automatic shotgun by Starstrike Arms, with tactical furniture and a six-shell magazine capacity."
	icon_state = "shotgun_combat"
	origin_tech = "combat=6"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	execution_speed = 5 SECONDS

/// Service Malfunction Borg Combat Shotgun Variant
/obj/item/gun/projectile/shotgun/automatic/combat/cyborg
	name = "cyborg shotgun"
	desc = "Get those organics off your station. Holds eight shots. Can only reload in a recharge station."
	mag_type = /obj/item/ammo_box/magazine/internal/shot/malf

/obj/item/gun/projectile/shotgun/automatic/combat/cyborg/cyborg_recharge(coeff, emagged)
	if(magazine.ammo_count() < magazine.max_ammo)
		magazine.stored_ammo.Add(new /obj/item/ammo_casing/shotgun/lasershot)

//Dual Feed Shotgun

/obj/item/gun/projectile/shotgun/automatic/dual_tube
	name = "\improper XM800 cycler shotgun"
	desc = "A prototype shotgun by Starstrike Arms with two separate magazine tubes, allowing you to quickly toggle between ammo types."
	icon_state = "cycler"
	worn_icon_state = "shotgun_combat"
	inhand_icon_state = "bulldog"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	w_class = WEIGHT_CLASS_HUGE
	var/toggled = 0
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine

/obj/item/gun/projectile/shotgun/automatic/dual_tube/Initialize(mapload)
	. = ..()
	if(!alternate_magazine)
		alternate_magazine = new mag_type(src)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/Destroy()
	QDEL_NULL(alternate_magazine)
	return ..()

/obj/item/gun/projectile/shotgun/automatic/dual_tube/attack_self__legacy__attackchain(mob/living/user)
	if(!chambered && length(magazine.contents))
		pump(user)
	else
		toggle_tube(user)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	if(toggled)
		to_chat(user, "You switch to tube B.")
	else
		to_chat(user, "You switch to tube A.")
	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/AltClick(mob/living/user)
	if(user.incapacitated() || !Adjacent(user) || !istype(user))
		return
	pump(user)

// DOUBLE BARRELED SHOTGUN, IMPROVISED SHOTGUN, and CANE SHOTGUN are in revolver.dm
