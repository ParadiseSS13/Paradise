/obj/item/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "revolver_bright"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_FLAG_BELT
	materials = list(MAT_METAL=2000)
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	origin_tech = "combat=1"
	needs_permit = TRUE
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = "gunshot"
	var/magin_sound = 'sound/weapons/gun_interactions/smg_magin.ogg'
	var/magout_sound = 'sound/weapons/gun_interactions/smg_magout.ogg'
	var/fire_sound_text = "gunshot" //the fire sound that shows in chat messages: laser blast, gunshot, etc.
	var/suppressed = FALSE					//whether or not a message is displayed when fired
	var/can_suppress = FALSE
	var/can_unsuppress = TRUE
	var/recoil = 0						//boom boom shake the room
	var/clumsy_check = TRUE
	var/obj/item/ammo_casing/chambered = null
	var/trigger_guard = TRIGGER_GUARD_NORMAL	//trigger guard on the weapon, hulks can't fire them with their big meaty fingers
	var/sawn_desc = null				//description change if weapon is sawn-off
	var/sawn_state = SAWN_INTACT
	var/burst_size = 1					//how large a burst is
	var/fire_delay = 0					//rate of fire for burst firing and semi auto
	var/firing_burst = 0				//Prevent the weapon from firing again while already firing
	var/semicd = 0						//cooldown handler
	var/execution_speed = 6 SECONDS
	var/weapon_weight = WEAPON_LIGHT
	var/list/restricted_species

	var/spread = 0

	var/unique_rename = TRUE //allows renaming with a pen
	var/unique_reskin = FALSE //allows one-time reskinning
	var/current_skin = null //the skin choice if we had a reskin
	var/list/options = list()

	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'

	var/obj/item/flashlight/gun_light = null
	var/can_flashlight = FALSE

	var/can_bayonet = FALSE //if a bayonet can be added or removed if it already has one.
	var/obj/item/kitchen/knife/bayonet
	var/mutable_appearance/knife_overlay
	var/knife_x_offset = 0
	var/knife_y_offset = 0

	var/can_holster = FALSE  // Anything that can be holstered should be manually set

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

/obj/item/gun/Initialize(mapload)
	. = ..()
	if(gun_light)
		verbs += /obj/item/gun/proc/toggle_gunlight
	build_zooming()

/obj/item/gun/Destroy()
	QDEL_NULL(bayonet)
	QDEL_NULL(chambered)
	QDEL_NULL(azoom)
	QDEL_NULL(gun_light)
	return ..()

/obj/item/gun/handle_atom_del(atom/A)
	if(A == bayonet)
		clear_bayonet()
	return ..()

/obj/item/gun/examine(mob/user)
	. = ..()
	if(unique_reskin && !current_skin)
		. += "<span class='notice'>Alt-click it to reskin it.</span>"
	if(unique_rename)
		. += "<span class='notice'>Use a pen on it to rename it.</span>"
	if(bayonet)
		. += "It has \a [bayonet] [can_bayonet ? "" : "permanently "]affixed to it."
		if(can_bayonet) //if it has a bayonet and this is false, the bayonet is permanent.
			. += "<span class='info'>[bayonet] looks like it can be <b>unscrewed</b> from [src].</span>"
	else if(can_bayonet)
		. += "It has a <b>bayonet</b> lug on it."


/obj/item/gun/proc/process_chamber()
	return 0

//check if there's enough ammo/energy/whatever to shoot one time
//i.e if clicking would make it shoot
/obj/item/gun/proc/can_shoot()
	return 1

/obj/item/gun/proc/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='danger'>*click*</span>")
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)

/obj/item/gun/proc/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	if(recoil)
		shake_camera(user, recoil + 1, recoil)

	var/muzzle_range = chambered?.muzzle_flash_range
	var/muzzle_strength = chambered?.muzzle_flash_strength
	var/muzzle_flash_time = 0.2 SECONDS

	if(suppressed)
		playsound(user, fire_sound, 10, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
		muzzle_range *= 0.5
		muzzle_strength *= 0.2
		muzzle_flash_time *= 0.5
	else
		playsound(user, fire_sound, 50, 1)
		if(message)
			if(pointblank)
				user.visible_message("<span class='danger'>[user] fires [src] point blank at [target]!</span>", "<span class='danger'>You fire [src] point blank at [target]!</span>", "<span class='italics'>You hear \a [fire_sound_text]!</span>")
			else
				user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear \a [fire_sound_text]!")
	if(chambered.muzzle_flash_effect)
		var/obj/effect/temp_visual/target_angled/muzzle_flash/effect = new chambered.muzzle_flash_effect(get_turf(src), target, muzzle_flash_time)
		effect.alpha = min(255, muzzle_strength * 255)
		if(chambered.muzzle_flash_color)
			effect.color = chambered.muzzle_flash_color
			effect.set_light(muzzle_range, muzzle_strength, chambered.muzzle_flash_color)
		else
			effect.color = LIGHT_COLOR_TUNGSTEN

/obj/item/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/gun/afterattack(atom/target, mob/living/user, flag, params)
	if(firing_burst)
		return
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == INTENT_HARM) //melee attack
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
			if(HAS_TRAIT(user, TRAIT_BADASS))
				user.visible_message("<span class='danger'>[user] blows smoke off of [src]'s barrel. What a badass.</span>")
			else
				handle_suicide(user, target, params)
			return


	//Exclude lasertag guns from the CLUMSY check.
	if(clumsy_check)
		if(istype(user))
			if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(40))
				to_chat(user, "<span class='userdanger'>You shoot yourself in the foot with \the [src]!</span>")
				var/shot_leg = pick("l_foot", "r_foot")
				process_fire(user, user, 0, params, zone_override = shot_leg)
				user.drop_item()
				return

	if(!HAS_TRAIT(user, TRAIT_BADASS) && weapon_weight == WEAPON_HEAVY && user.get_inactive_hand())
		to_chat(user, "<span class='userdanger'>You need both hands free to fire \the [src]!</span>")
		return

	//DUAL WIELDING
	var/bonus_spread = 0
	var/loop_counter = 0
	if(ishuman(user) && user.a_intent == INTENT_HARM)
		var/mob/living/carbon/human/H = user
		for(var/obj/item/gun/G in get_both_hands(H))
			if(G == src || G.weapon_weight >= WEAPON_MEDIUM)
				continue
			else if(G.can_trigger_gun(user))
				if(!HAS_TRAIT(user, TRAIT_BADASS))
					bonus_spread += 24 * G.weapon_weight
				loop_counter++
				addtimer(CALLBACK(G, PROC_REF(process_fire), target, user, 1, params, null, bonus_spread), loop_counter)

	process_fire(target,user,1,params, null, bonus_spread)

/obj/item/gun/proc/can_trigger_gun(mob/living/user)
	if(!user.can_use_guns(src))
		return 0
	if(restricted_species && restricted_species.len && !is_type_in_list(user.dna.species, restricted_species))
		to_chat(user, "<span class='danger'>[src] is incompatible with your biology!</span>")
		return 0
	return 1

/obj/item/gun/proc/newshot()
	return

/obj/item/gun/proc/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override, bonus_spread = 0)
	add_fingerprint(user)

	if(semicd)
		return

	var/sprd = 0
	var/randomized_gun_spread = 0
	if(spread)
		randomized_gun_spread =	rand(0,spread)
	var/randomized_bonus_spread = rand(0, bonus_spread)

	if(burst_size > 1)
		if(chambered && chambered.harmful)
			if(HAS_TRAIT(user, TRAIT_PACIFISM)) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
				to_chat(user, "<span class='warning'>[src] is lethally chambered! You don't want to risk harming anyone...</span>")
				return
		firing_burst = 1
		for(var/i = 1 to burst_size)
			if(!user)
				break
			if(!issilicon(user))
				if(i>1 && !(src in get_both_hands(user))) //for burst firing
					break
			if(chambered)
				sprd = round((pick(0.5, -0.5)) * (randomized_gun_spread + randomized_bonus_spread))
				if(!chambered.fire(target = target, user = user, params = params, distro = null, quiet = suppressed, zone_override = zone_override, spread = sprd, firer_source_atom = src))
					shoot_with_empty_chamber(user)
					break
				else
					if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
						shoot_live_shot(user, target, TRUE, message)
					else
						shoot_live_shot(user, target, FALSE, message)
			else
				shoot_with_empty_chamber(user)
				break
			process_chamber()
			update_icon()
			sleep(fire_delay)
		firing_burst = 0
	else
		if(chambered)
			if(HAS_TRAIT(user, TRAIT_PACIFISM)) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
				if(chambered.harmful) // Is the bullet chambered harmful?
					to_chat(user, "<span class='warning'>[src] is lethally chambered! You don't want to risk harming anyone...</span>")
					return
			sprd = round((pick(1,-1)) * (randomized_gun_spread + randomized_bonus_spread))
			if(!chambered.fire(target = target, user = user, params = params, distro = null, quiet = suppressed, zone_override = zone_override, spread = sprd, firer_source_atom = src))
				shoot_with_empty_chamber(user)
				return
			else
				if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
					shoot_live_shot(user, target, TRUE, message)
				else
					shoot_live_shot(user, target, FALSE, message)
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
	SSblackbox.record_feedback("tally", "gun_fired", 1, type)

/obj/item/gun/attack(mob/M, mob/user)
	if(user.a_intent == INTENT_HARM) //Flogging
		if(bayonet)
			M.attackby(bayonet, user)
		else
			return ..()

/obj/item/gun/attack_obj(obj/O, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		if(bayonet)
			O.attackby(bayonet, user)
			return
	return ..()

/obj/item/gun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/flashlight/seclite))
		var/obj/item/flashlight/seclite/S = I
		if(can_flashlight)
			if(!gun_light)
				if(!user.unEquip(I))
					return
				to_chat(user, "<span class='notice'>You click [S] into place on [src].</span>")
				if(S.on)
					set_light(0)
				gun_light = S
				I.loc = src
				update_icon()
				update_gun_light(user)
				var/datum/action/A = new /datum/action/item_action/toggle_gunlight(src)
				if(loc == user)
					A.Grant(user)

	if(unique_rename)
		if(is_pen(I))
			var/t = rename_interactive(user, I, use_prefix = FALSE)
			if(!isnull(t))
				to_chat(user, "<span class='notice'>You name the gun [name]. Say hello to your new friend.</span>")
	if(istype(I, /obj/item/kitchen/knife))
		var/obj/item/kitchen/knife/K = I
		if(!can_bayonet || !K.bayonet || bayonet) //ensure the gun has an attachment point available, and that the knife is compatible with it.
			return ..()
		if(!user.drop_item())
			return
		K.forceMove(src)
		to_chat(user, "<span class='notice'>You attach [K] to [src]'s bayonet lug.</span>")
		bayonet = K
		var/state = "bayonet"							//Generic state.
		if(bayonet.icon_state in icon_states('icons/obj/guns/bayonets.dmi'))		//Snowflake state?
			state = bayonet.icon_state
		var/icon/bayonet_icons = 'icons/obj/guns/bayonets.dmi'
		knife_overlay = mutable_appearance(bayonet_icons, state)
		knife_overlay.pixel_x = knife_x_offset
		knife_overlay.pixel_y = knife_y_offset
		overlays += knife_overlay
	else
		return ..()

/obj/item/gun/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(gun_light && can_flashlight)
		for(var/obj/item/flashlight/seclite/S in src)
			to_chat(user, "<span class='notice'>You unscrew the seclite from [src].</span>")
			gun_light = null
			S.loc = get_turf(user)
			update_gun_light(user)
			S.update_brightness(user)
			update_icon()
			for(var/datum/action/item_action/toggle_gunlight/TGL in actions)
				qdel(TGL)
	else if(bayonet && can_bayonet) //if it has a bayonet, and the bayonet can be removed
		bayonet.forceMove(get_turf(user))
		clear_bayonet()

/obj/item/gun/proc/toggle_gunlight()
	if(!gun_light)
		return
	gun_light.on = !gun_light.on
	var/mob/living/carbon/human/user = usr
	if(user)
		to_chat(user, "<span class='notice'>You toggle the gun light [gun_light.on ? "on":"off"].</span>")
	playsound(src, 'sound/weapons/empty.ogg', 100, 1)
	update_gun_light(user)

/obj/item/gun/proc/update_gun_light(mob/user = null)
	if(gun_light)
		if(gun_light.on)
			set_light(gun_light.brightness_on)
		else
			set_light(0)
		update_icon()
	else
		set_light(0)

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/gun/proc/clear_bayonet()
	if(!bayonet)
		return
	bayonet = null
	if(knife_overlay)
		overlays -= knife_overlay
		knife_overlay = null
	return TRUE

/obj/item/gun/extinguish_light(force = FALSE)
	if(gun_light?.on)
		toggle_gunlight()
		visible_message("<span class='danger'>[src]'s light fades and turns off.</span>")


/obj/item/gun/dropped(mob/user)
	..()
	zoom(user,FALSE)
	if(azoom)
		azoom.Remove(user)

/obj/item/gun/AltClick(mob/user)
	..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(unique_reskin && !current_skin && loc == user)
		reskin_gun(user)

/obj/item/gun/proc/reskin_gun(mob/M)
	var/list/skins = list()
	for(var/I in options)
		skins[I] = image(icon, icon_state = options[I])
	var/choice = show_radial_menu(M, src, skins, radius = 40, custom_check = CALLBACK(src, PROC_REF(reskin_radial_check), M), require_near = TRUE)

	if(choice && reskin_radial_check(M) && !current_skin)
		current_skin = options[choice]
		to_chat(M, "Your gun is now skinned as [choice]. Say hello to your new friend.")
		update_icon()
		M.update_inv_r_hand()
		M.update_inv_l_hand()

/obj/item/gun/proc/reskin_radial_check(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!src || !H.is_in_hands(src) || HAS_TRAIT(H, TRAIT_HANDS_BLOCKED))
		return FALSE
	return TRUE

/obj/item/gun/proc/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params)
	if(!ishuman(user) || !ishuman(target))
		return

	if(semicd)
		return

	if(user == target)
		target.visible_message("<span class='warning'>[user] sticks [src] in [user.p_their()] mouth, ready to pull the trigger...</span>", \
			"<span class='userdanger'>You stick [src] in your mouth, ready to pull the trigger...</span>")
	else
		target.visible_message("<span class='warning'>[user] points [src] at [target]'s head, ready to pull the trigger...</span>", \
			"<span class='userdanger'>[user] points [src] at your head, ready to pull the trigger...</span>")

	semicd = 1

	if(!do_mob(user, target, execution_speed) || user.zone_selected != "mouth")
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

/////////////
// ZOOMING //
/////////////

/datum/action/toggle_scope_zoom
	name = "Toggle Scope"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING
	button_icon_state = "sniper_zoom"
	var/obj/item/gun/gun = null

/datum/action/toggle_scope_zoom/Destroy()
	gun = null
	return ..()

/datum/action/toggle_scope_zoom/Trigger(left_click)
	gun.zoom(owner)

/datum/action/toggle_scope_zoom/IsAvailable()
	. = ..()
	if(!. && gun)
		gun.zoom(owner, FALSE)

/datum/action/toggle_scope_zoom/Remove(mob/living/L)
	gun.zoom(L, FALSE)
	..()

/obj/item/gun/proc/zoom(mob/living/user, forced_zoom)
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
/obj/item/gun/proc/build_zooming()
	if(azoom)
		return

	if(zoomable)
		azoom = new()
		azoom.gun = src
		RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(ZoomGrantCheck))

/**
 * Proc which will be called when the gun receives the `COMSIG_ITEM_EQUIPPED` signal.
 *
 * This happens if the mob picks up the gun, or equips it to any of their slots.
 * If the slot is anything other than either of their hands (such as the back slot), un-zoom them, and `Remove` the zoom action button from the mob.
 * Otherwise, `Grant` the mob the zoom action button.
 *
 * Arguments:
 * * source - the gun that got equipped, which is `src`.
 * * user - the mob equipping the gun.
 * * slot - the slot the gun is getting equipped to.
 */
/obj/item/gun/proc/ZoomGrantCheck(datum/source, mob/user, slot)
	// Checks if the gun got equipped into either of the user's hands.
	if(slot != SLOT_HUD_RIGHT_HAND && slot != SLOT_HUD_LEFT_HAND)
		// If its not in their hands, un-zoom, and remove the zoom action button.
		zoom(user, FALSE)
		azoom.Remove(user)
		return FALSE

	// The gun is equipped in their hands, give them the zoom ability.
	azoom.Grant(user)
