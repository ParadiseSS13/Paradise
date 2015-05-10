 #define SAWN_INTACT  0
 #define SAWN_OFF     1
 #define SAWN_SAWING -1

/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	m_amt = 2000
	w_class = 3.0
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = 'sound/weapons/Gunshot.ogg'
	var/obj/item/projectile/in_chamber = null
	var/silenced = 0
	var/ghettomodded = 0
	var/recoil = 0
	var/can_suppress = 0
	var/clumsy_check = 1
	var/sawn_desc = null
	var/sawn_state = SAWN_INTACT
	var/obj/item/ammo_casing/chambered = null // The round (not bullet) that is in the chamber. THIS MISPLACED ITEM BROUGHT TO YOU BY HACKY BUCKSHOT.
	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/lock_time = -100
	var/tmp/mouthshoot = 0 ///To stop people from suiciding twice... >.>
	var/automatic = 0 //Used to determine if you can target multiple people.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate = 1     // 0 for one bullet after tarrget moves and aim is lowered,
						//1 for keep shooting until aim is lowered
	var/fire_delay = 0
	var/last_fired = 0
	var/obj/item/device/flashlight/F = null
	var/can_flashlight = 0
	var/heavy_weapon = 0
	var/randomspread = 0

	proc/ready_to_fire()
		if(world.time >= last_fired + fire_delay)
			last_fired = world.time
			return 1
		else
			return 0

	proc/process_chambered()
		return 0


	proc/special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
		return 1


	proc/shoot_with_empty_chamber(mob/living/user as mob|obj)
		user << "<span class='warning'>*click*</span>"
		playsound(user, 'sound/weapons/emptyclick.ogg', 40, 1)
		return

	emp_act(severity)
		for(var/obj/O in contents)
			O.emp_act(severity)

	proc/prepare_shot(var/obj/item/projectile/proj) //Transfer properties from the gun to the bullet
		proj.shot_from = src
		proj.silenced = silenced
		return

/obj/item/weapon/gun/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	if(flag)    return //we're placing gun on a table or in backpack
	if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))    return//Shouldnt flag take care of this?
	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params) //They're using the new gun system, locate what they're aiming at.
	else
		Fire(A,user,params) //Otherwise, fire normally.

/obj/item/weapon/gun/proc/isHandgun()
	return 1

/obj/item/weapon/gun/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)//TODO: go over this
	//Exclude lasertag guns from the CLUMSY check.
	if(clumsy_check)
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if ((CLUMSY in M.mutations) && prob(50))
				M << "<span class='danger'>[src] blows up in your face.</span>"
				M.take_organ_damage(0,20)
				M.drop_item()
				qdel(src)
				return

	if (!user.IsAdvancedToolUser() || istype(user, /mob/living/carbon/monkey/diona))
		user << "\red You don't have the dexterity to do this!"
		return
	if(istype(user, /mob/living))
		var/mob/living/M = user
		if (HULK in M.mutations)
			M << "\red Your meaty finger is much too large for the trigger guard!"
			return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species.name == "Golem")
			user << "\red Your metal fingers don't fit in the trigger guard!"
			return
		if(user.dna && user.dna.species == "Shadowling")
			user << "<span class='danger'>The muzzle flash would cause damage to your form!</span>"

	add_fingerprint(user)

	if(!special_check(user))
		return

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			user << "<span class='warning'>[src] is not ready to fire again!"
		return

	if(!process_chambered()) //CHECK
		return click_empty(user)

	if(heavy_weapon)
		if(user.get_inactive_hand())
			recoil = 4 //one-handed kick
		else
			recoil = initial(recoil)

	if (istype(in_chamber, /obj/item/projectile/bullet/blank)) // A hacky way of making blank shotgun shells work again. Honk.
		in_chamber.delete()
		in_chamber = null
		return

	user.changeNext_move(CLICK_CD_RANGE)

	var/spread = 0
	var/turf/targloc = get_turf(target)
	if(chambered)
		for (var/i = max(1, chambered.pellets), i > 0, i--) //Previous way of doing it fucked up math for spreading. This way, even the first projectile is part of the spread code.
			if(i != max(1, chambered.pellets)) //Have we fired the initial chambered bullet yet?
				in_chamber = new chambered.projectile_type()
			ready_projectile(target, user)
			prepare_shot(in_chamber)
			if(chambered.deviation)
				if(randomspread) //Random spread
					spread = (rand() - 0.5) * chambered.deviation
				else //Smart spread
					spread = (i / chambered.pellets - 0.5) * chambered.deviation
			if(!process_projectile(targloc, user, params, spread))
				return 0
	else
		ready_projectile(target, user)
		prepare_shot(in_chamber)
		if(!process_projectile(targloc, user, params, spread))
			return 0

	if(recoil)
		spawn()
			shake_camera(user, recoil + 1, recoil)

	if(silenced)
		playsound(user, fire_sound, 10, 1)
	else
		playsound(user, fire_sound, 50, 1)
		user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
		"<span class='warning'>You fire [src][reflex ? "by reflex":""]!</span>", \
		"You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")

	if(heavy_weapon)
		if(user.get_inactive_hand())
			if(prob(15))
				user.visible_message("<span class='danger'>[src] flies out of [user]'s hands!</span>", "<span class='userdanger'>[src] kicks out of your grip!</span>")
				user.drop_item()

	update_icon()
	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()

/obj/item/weapon/gun/proc/ready_projectile(atom/target as mob|obj|turf, mob/living/user)
	in_chamber.firer = user
	in_chamber.def_zone = user.zone_sel.selecting
	in_chamber.original = target
	return

/obj/item/weapon/gun/proc/process_projectile(var/turf/targloc, mob/living/user as mob|obj, params, spread)
	var/turf/curloc = user.loc
	if (!istype(targloc) || !istype(curloc) || !in_chamber)
		return 0
	if(targloc == curloc)			//Fire the projectile
		user.bullet_act(in_chamber)
		qdel(in_chamber)
		update_icon()
		return 1

	in_chamber.loc = get_turf(user)
	in_chamber.starting = get_turf(user)
	in_chamber.current = curloc
	in_chamber.yo = targloc.y - curloc.y
	in_chamber.xo = targloc.x - curloc.x
	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			in_chamber.p_x = text2num(mouse_control["icon-x"])
		if(mouse_control["icon-y"])
			in_chamber.p_y = text2num(mouse_control["icon-y"])
		if(mouse_control["screen-loc"])
			//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
			var/list/screen_loc_params = text2list(mouse_control["screen-loc"], ",")

			//Split X+Pixel_X up into list(X, Pixel_X)
			var/list/screen_loc_X = text2list(screen_loc_params[1],":")

			//Split Y+Pixel_Y up into list(Y, Pixel_Y)
			var/list/screen_loc_Y = text2list(screen_loc_params[2],":")

			var/x = text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32
			var/y = text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32
			var/ox = round(544/2) //"origin" x - Basically center of the screen. This is a bad way of doing it because if you are able to view MORE than 17 tiles at a time your aim will get fucked.
			var/oy = round(544/2) //"origin" y - Basically center of the screen.

			var/angle = Atan2(y - oy, x - ox)

			in_chamber.Angle = angle

	if(istype(user, /mob/living/carbon)) //Increase spread based on shock
		var/mob/living/carbon/mob = user
		if(mob.shock_stage > 120)
			spread += rand(-5,5)
		else if(mob.shock_stage > 70)
			spread += rand(-2,2)

	if(spread)
		in_chamber.Angle += spread
	if(in_chamber)
		in_chamber.process()
	in_chamber = null
	return 1

/obj/item/weapon/gun/proc/can_fire()
	return process_chambered()

/obj/item/weapon/gun/proc/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	return in_chamber.check_fire(target,user)

/obj/item/weapon/gun/proc/click_empty(mob/user = null)
	if (user)
		user.visible_message("*click click*", "\red <b>*click*</b>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	else
		src.visible_message("*click click*")
		playsound(src.loc, 'sound/weapons/empty.ogg', 100, 1)

/obj/item/weapon/gun/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	//Suicide handling.
	if (M == user && user.zone_sel.selecting == "mouth" && !mouthshoot)
		mouthshoot = 1
		M.visible_message("\red [user] sticks their gun in their mouth, ready to pull the trigger...")
		if(!do_after(user, 40))
			M.visible_message("\blue [user] decided life was worth living")
			mouthshoot = 0
			return
		if (process_chambered())
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			if(silenced)
				playsound(user, fire_sound, 10, 1)
			else
				playsound(user, fire_sound, 50, 1)
			if(istype(in_chamber, /obj/item/projectile/lasertag))
				user.show_message("<span class = 'warning'>You feel rather silly, trying to commit suicide with a toy.</span>")
				mouthshoot = 0
				return
			in_chamber.on_hit(M)
			if (in_chamber.damage_type != STAMINA)
				user.apply_damage(in_chamber.damage*2.5, in_chamber.damage_type, "head", used_weapon = "Point blank shot in the mouth with \a [in_chamber]", sharp=1)
				user.death()
			else
				user << "<span class = 'notice'>Ow...</span>"
				user.apply_effect(110,AGONY,0)
			del(in_chamber)
			mouthshoot = 0
			return
		else
			click_empty(user)
			mouthshoot = 0
			return

	if (src.process_chambered())
		//Point blank shooting if on harm intent or target we were targeting.
		if(user.a_intent == "harm")
			user.visible_message("\red <b> \The [user] fires \the [src] point blank at [M]!</b>")
			if(istype(in_chamber)) in_chamber.damage *= 1.3
			Fire(M,user,0,0,1)
			return
		else if(target && M in target)
			Fire(M,user,0,0,1) ///Otherwise, shoot!
			return
	else
		return ..() //Pistolwhippin'


/obj/item/weapon/gun/attackby(var/obj/item/A as obj, mob/user as mob, params)
	if(istype(A, /obj/item/device/flashlight/seclite))
		var/obj/item/device/flashlight/seclite/S = A
		if(can_flashlight)
			if(!F)
				if(user.l_hand != src && user.r_hand != src)
					user << "<span class='notice'>You'll need [src] in your hands to do that.</span>"
					return
				user.drop_item()
				user << "<span class='notice'>You click [S] into place on [src].</span>"
				if(S.on)
					set_light(0)
				F = S
				A.loc = src
				update_icon()
				update_gunlight(user)
				verbs += /obj/item/weapon/gun/proc/toggle_gunlight
	if(istype(A, /obj/item/weapon/screwdriver))
		if(F)
			if(user.l_hand != src && user.r_hand != src)
				user << "<span class='notice'>You'll need [src] in your hands to do that.</span>"
				return
			for(var/obj/item/device/flashlight/seclite/S in src)
				user << "<span class='notice'>You unscrew the seclite from [src].</span>"
				F = null
				S.loc = get_turf(user)
				update_gunlight(user)
				S.update_brightness(user)
				update_icon()
				verbs -= /obj/item/weapon/gun/proc/toggle_gunlight
	..()
	return

/obj/item/weapon/gun/proc/toggle_gunlight()
	set name = "Toggle Gunlight"
	set category = "Object"
	set desc = "Click to toggle your weapon's attached flashlight."

	if(!F)
		return

	var/mob/living/carbon/human/user = usr
	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]."
	F.on = !F.on
	user << "<span class='notice'>You toggle the gunlight [F.on ? "on":"off"].</span>"

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_gunlight(user)
	return

/obj/item/weapon/gun/proc/update_gunlight(var/mob/user = null)
	if(F)
		if(F.on)
			set_light(F.brightness_on)
		else
			set_light(0)
		update_icon()
	else
		set_light(0)
		return