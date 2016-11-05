/obj/item/weapon/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=2000)
	w_class = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	origin_tech = "combat=1"
	needs_permit = 1
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = "gunshot"
	var/fire_sound_text = "gunshot" //the fire sound that shows in chat messages: laser blast, gunshot, etc.
	var/suppressed = 0					//whether or not a message is displayed when fired
	var/can_suppress = 0
	var/can_unsuppress = 1
	var/recoil = 0						//boom boom shake the room
	var/clumsy_check = 1
	var/obj/item/ammo_casing/chambered = null
	var/trigger_guard = TRIGGER_GUARD_NORMAL	//trigger guard on the weapon, hulks can't fire them with their big meaty fingers
	var/sawn_desc = null				//description change if weapon is sawn-off
	var/sawn_state = SAWN_INTACT
	var/burst_size = 1					//how large a burst is
	var/fire_delay = 0					//rate of fire for burst firing and semi auto
	var/firing_burst = 0				//Prevent the weapon from firing again while already firing
	var/semicd = 0						//cooldown handler
	var/weapon_weight = WEAPON_LIGHT
	var/list/restricted_species

	var/spread = 0
	var/randomspread = 1

	var/unique_rename = 0 //allows renaming with a pen
	var/unique_reskin = 0 //allows one-time reskinning
	var/current_skin = null //the skin choice if we had a reskin
	var/list/options = list()

	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'

	var/obj/item/device/flashlight/F = null
	var/can_flashlight = 0

	var/list/upgrades = list()

	var/ammo_x_offset = 0 //used for positioning ammo count overlay on sprite
	var/ammo_y_offset = 0
	var/flight_x_offset = 0
	var/flight_y_offset = 0

	//Zooming
	var/zoomable = FALSE //whether the gun generates a Zoom action on creation
	var/zoomed = FALSE //Zoom toggle
	var/zoom_amt = 3 //Distance in TURFs to move the user's screen forward (the "zoom" effect)
	var/datum/action/toggle_scope_zoom/azoom

/obj/item/weapon/gun/New()
	..()
	if(F)
		verbs += /obj/item/weapon/gun/proc/toggle_gunlight
	build_zooming()

/obj/item/weapon/gun/examine(mob/user)
	..()
	if(unique_reskin && !current_skin)
		to_chat(user, "<span class='notice'>Alt-click it to reskin it.</span>")
	if(unique_rename)
		to_chat(user, "<span class='notice'>Use a pen on it to rename it.</span>")

/obj/item/weapon/gun/proc/process_chamber()
	return 0

//check if there's enough ammo/energy/whatever to shoot one time
//i.e if clicking would make it shoot
/obj/item/weapon/gun/proc/can_shoot()
	return 1

/obj/item/weapon/gun/proc/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='danger'>*click*</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)

/obj/item/weapon/gun/proc/shoot_live_shot(mob/living/user as mob|obj, pointblank = 0, mob/pbtarget = null, message = 1)
	if(recoil)
		shake_camera(user, recoil + 1, recoil)

	if(suppressed)
		playsound(user, fire_sound, 10, 1)
	else
		playsound(user, fire_sound, 50, 1)
		if(!message)
			return
		if(pointblank)
			user.visible_message("<span class='danger'>[user] fires [src] point blank at [pbtarget]!</span>", "<span class='danger'>You fire [src] point blank at [pbtarget]!</span>", "<span class='italics'>You hear \a [fire_sound_text]!</span>")
		else
			user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear \a [fire_sound_text]!")

	if(weapon_weight >= WEAPON_MEDIUM)
		if(user.get_inactive_hand())
			if(prob(15))
				if(user.drop_item())
					user.visible_message("<span class='danger'>[src] flies out of [user]'s hands!</span>", "<span class='userdanger'>[src] kicks out of your grip!</span>")

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/afterattack(atom/target, mob/living/user, flag, params)
	if(firing_burst)
		return
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == "harm") //melee attack
			return
		if(target == user && user.zone_selected != "mouth") //so we can't shoot ourselves (unless mouth selected)
			return

	if(istype(user))//Check if the user can use the gun, if the user isn't alive(turrets) assume it can.
		var/mob/living/L = user
		if(!can_trigger_gun(L))
			return

	if(!can_shoot()) //Just because you can pull the trigger doesn't mean it can't shoot.
		shoot_with_empty_chamber(user)
		return

	if(flag)
		if(user.zone_selected == "mouth")
			handle_suicide(user, target, params)
			return


	//Exclude lasertag guns from the CLUMSY check.
	if(clumsy_check)
		if(istype(user))
			if((CLUMSY in user.mutations) && prob(40))
				to_chat(user, "<span class='userdanger'>You shoot yourself in the foot with \the [src]!</span>")
				var/shot_leg = pick("l_foot", "r_foot")
				process_fire(user, user, 0, params, zone_override = shot_leg)
				user.drop_item()
				return

	if(weapon_weight == WEAPON_HEAVY && user.get_inactive_hand())
		to_chat(user, "<span class='userdanger'>You need both hands free to fire \the [src]!</span>")
		return

	process_fire(target,user,1,params)

/obj/item/weapon/gun/proc/can_trigger_gun(var/mob/living/user)
	if(!user.can_use_guns(src))
		return 0
	if(restricted_species && restricted_species.len && !(user.get_species() in restricted_species))
		to_chat(user, "<span class='danger'>[src] is incompatible with your biology!</span>")
		return 0
	return 1

obj/item/weapon/gun/proc/newshot()
	return

/obj/item/weapon/gun/proc/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	add_fingerprint(user)

	if(semicd)
		return

	if(weapon_weight)
		if(user.get_inactive_hand())
			recoil = 4 //one-handed kick
		else
			recoil = initial(recoil)

	if(burst_size > 1)
		firing_burst = 1
		for(var/i = 1 to burst_size)
			if(!user)
				break
			if(!issilicon(user))
				if( i>1 && !(src in get_both_hands(user))) //for burst firing
					break
			if(chambered)
				var/sprd = 0
				if(randomspread)
					sprd = round((rand() - 0.5) * spread)
				else
					sprd = round((i / burst_size - 0.5) * spread)
				if(!chambered.fire(target, user, params, ,suppressed, zone_override, sprd))
					shoot_with_empty_chamber(user)
					break
				else
					if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
						shoot_live_shot(user, 1, target, message)
					else
						shoot_live_shot(user, 0, target, message)
			else
				shoot_with_empty_chamber(user)
				break
			process_chamber()
			update_icon()
			sleep(fire_delay)
		firing_burst = 0
	else
		if(chambered)
			if(!chambered.fire(target, user, params, , suppressed, zone_override, spread))
				shoot_with_empty_chamber(user)
				return
			else
				if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
					shoot_live_shot(user, 1, target, message)
				else
					shoot_live_shot(user, 0, target, message)
		else
			shoot_with_empty_chamber(user)
			return
		process_chamber()
		update_icon()
		semicd = 1
		spawn(fire_delay)
			semicd = 0

	if(user)
		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()
	feedback_add_details("gun_fired","[type]")

/obj/item/weapon/gun/attack(mob/M as mob, mob/user)
	if(user.a_intent == "harm") //Flogging
		..()
	else
		return

/obj/item/weapon/gun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/flashlight/seclite))
		var/obj/item/device/flashlight/seclite/S = I
		if(can_flashlight)
			if(!F)
				if(!user.unEquip(I))
					return
				to_chat(user, "<span class='notice'>You click [S] into place on [src].</span>")
				if(S.on)
					set_light(0)
				F = S
				I.loc = src
				update_icon()
				update_gunlight(user)
				var/datum/action/A = new /datum/action/item_action/toggle_gunlight(src)
				if(loc == user)
					A.Grant(user)

	if(istype(I, /obj/item/weapon/screwdriver))
		if(F && can_flashlight)
			for(var/obj/item/device/flashlight/seclite/S in src)
				to_chat(user, "<span class='notice'>You unscrew the seclite from [src].</span>")
				F = null
				S.loc = get_turf(user)
				update_gunlight(user)
				S.update_brightness(user)
				update_icon()
				for(var/datum/action/item_action/toggle_gunlight/TGL in actions)
					qdel(TGL)

	if(unique_rename)
		if(istype(I, /obj/item/weapon/pen))
			rename_gun(user)
	..()

/obj/item/weapon/gun/proc/toggle_gunlight()
	set name = "Toggle Gunlight"
	set category = "Object"
	set desc = "Click to toggle your weapon's attached flashlight."

	if(!F)
		return

	var/mob/living/carbon/human/user = usr
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot turn the light on while in this [user.loc]!</span>")
	F.on = !F.on
	to_chat(user, "<span class='notice'>You toggle the gunlight [F.on ? "on":"off"].</span>")

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_gunlight(user)

/obj/item/weapon/gun/proc/update_gunlight(mob/user = null)
	if(F)
		if(F.on)
			set_light(F.brightness_on)
		else
			set_light(0)
		update_icon()
	else
		set_light(0)

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/weapon/gun/pickup(mob/user)
	..()
	if(azoom)
		azoom.Grant(user)

/obj/item/weapon/gun/dropped(mob/user)
	..()
	zoom(user,FALSE)
	if(azoom)
		azoom.Remove(user)

/obj/item/weapon/gun/AltClick(mob/user)
	..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(unique_reskin && !current_skin && loc == user)
		reskin_gun(user)

/obj/item/weapon/gun/proc/reskin_gun(mob/M)
	var/choice = input(M,"Warning, you can only reskin your weapon once!","Reskin Gun") in options

	if(src && choice && !current_skin && !M.incapacitated() && in_range(M,src))
		if(options[choice] == null)
			return
		current_skin = options[choice]
		to_chat(M, "Your gun is now skinned as [choice]. Say hello to your new friend.")
		update_icon()

/obj/item/weapon/gun/proc/rename_gun(mob/M)
	var/input = stripped_input(M,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

	if(src && input && !M.stat && in_range(M,src) && !M.restrained() && M.canmove)
		name = input
		to_chat(M, "You name the gun [input]. Say hello to your new friend.")
		return

/obj/item/weapon/gun/proc/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params)
	if(!ishuman(user) || !ishuman(target))
		return

	if(semicd)
		return

	if(user == target)
		target.visible_message("<span class='warning'>[user] sticks [src] in their mouth, ready to pull the trigger...</span>", \
			"<span class='userdanger'>You stick [src] in your mouth, ready to pull the trigger...</span>")
	else
		target.visible_message("<span class='warning'>[user] points [src] at [target]'s head, ready to pull the trigger...</span>", \
			"<span class='userdanger'>[user] points [src] at your head, ready to pull the trigger...</span>")

	semicd = 1

	if(!do_mob(user, target, 120) || user.zone_selected != "mouth")
		if(user)
			if(user == target)
				user.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
			else if(target && target.Adjacent(user))
				target.visible_message("<span class='notice'>[user] has decided to spare [target]'s life.</span>", "<span class='notice'>[user] has decided to spare your life!</span>")
		semicd = 0
		return

	semicd = 0

	target.visible_message("<span class='warning'>[user] pulls the trigger!</span>", "<span class='userdanger'>[user] pulls the trigger!</span>")

	if(chambered && chambered.BB)
		chambered.BB.damage *= 5

	process_fire(target, user, 1, params)

/obj/item/weapon/gun/proc/isHandgun()
	return 1

/////////////
// ZOOMING //
/////////////

/datum/action/toggle_scope_zoom
	name = "Toggle Scope"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING
	button_icon_state = "sniper_zoom"
	var/obj/item/weapon/gun/gun = null

/datum/action/toggle_scope_zoom/Trigger()
	gun.zoom(owner)

/datum/action/toggle_scope_zoom/IsAvailable()
	. = ..()
	if(!. && gun)
		gun.zoom(owner, FALSE)

/datum/action/toggle_scope_zoom/Remove(mob/living/L)
	gun.zoom(L, FALSE)
	..()

/obj/item/weapon/gun/proc/zoom(mob/living/user, forced_zoom)
	if(!user || !user.client)
		return

	switch(forced_zoom)
		if(FALSE)
			zoomed = FALSE
		if(TRUE)
			zoomed = TRUE
		else
			zoomed = !zoomed

	if(zoomed)
		var/_x = 0
		var/_y = 0
		switch(user.dir)
			if(NORTH)
				_y = zoom_amt
			if(EAST)
				_x = zoom_amt
			if(SOUTH)
				_y = -zoom_amt
			if(WEST)
				_x = -zoom_amt

		user.client.pixel_x = world.icon_size*_x
		user.client.pixel_y = world.icon_size*_y
	else
		user.client.pixel_x = 0
		user.client.pixel_y = 0


//Proc, so that gun accessories/scopes/etc. can easily add zooming.
/obj/item/weapon/gun/proc/build_zooming()
	if(azoom)
		return

	if(zoomable)
		azoom = new()
		azoom.gun = src
