/obj/item/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "revolver_bright"
	worn_icon_state = "gun"
	inhand_icon_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags =  CONDUCT
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=2000)
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	origin_tech = "combat=1"
	needs_permit = TRUE
	attack_verb = list("struck", "hit", "bashed")
	/// Sound played when a projectile is fired.
	var/fire_sound = "gunshot"
	/// Sound played when inserting a new magazine.
	var/magin_sound = 'sound/weapons/gun_interactions/smg_magin.ogg'
	/// Sound played when ejecting a magazine.
	var/magout_sound = 'sound/weapons/gun_interactions/smg_magout.ogg'
	/// The fire sound that shows in chat messages: laser blast, gunshot, etc.
	var/fire_sound_text = "gunshot"
	/// Whether or not a message is displayed when fired.
	var/suppressed = FALSE
	/// Whether or not a suppressor can be attached to the gun.
	var/can_suppress = FALSE
	/// Whether or not an attached suppressor can be removed from the gun.
	var/can_unsuppress = TRUE
	/// Screen shake when firing.
	var/recoil = 0
	/// Checks to see if the user has the clumsy trait.
	var/clumsy_check = TRUE
	/// Is there currently a bullet in the chamber?
	var/obj/item/ammo_casing/chambered = null
	/// Trigger guard on the gun, hulks and ash walkers can't fire them with their big meaty fingers.
	var/trigger_guard = TRIGGER_GUARD_NORMAL
	/// Description change if gun is sawn-off.
	var/sawn_desc = null
	/// Whether or not the gun has been sawn-off.
	var/sawn_state = SAWN_INTACT
	/// The number of bullets in a trigger pull.
	var/burst_size = 1
	/// Rate of fire for burst firing and semi auto.
	var/fire_delay = 0
	/// Prevent the gun from firing again while already firing.
	var/firing_burst = 0
	/// Cooldown handler.
	var/semicd = 0
	/// How long it takes to perform an execution with the gun.
	var/execution_speed = 6 SECONDS
	/// When dual wielding, accuracy will decrease based on weapon weight. WEAPON_HEAVY makes a weapon require two hands to fire, unless the user has TRAIT_BADASS.
	var/weapon_weight = WEAPON_LIGHT
	/// Additional spread when dual wielding.
	var/dual_wield_spread = 24
	/// Restrict what species can fire this gun.
	var/list/restricted_species
	/// Bigger values make shots less precise.
	var/spread = 0
	/// If TRUE, allows the gun to be renamed with a pen.
	var/unique_rename = TRUE
	/// Allows one-time reskinning.
	var/unique_reskin = FALSE
	/// The skin choice if we had a reskin.
	var/current_skin = null
	/// List of reskin options.
	var/list/options = list()
	/// Whether or not the gun has a flashlight.
	var/obj/item/flashlight/gun_light = null
	/// Whether or not a flashlight can be attached to the gun.
	var/can_flashlight = FALSE
	/// Whether or not a knife can be attached to the gun.
	var/can_bayonet = FALSE
	var/obj/item/kitchen/knife/bayonet
	var/mutable_appearance/knife_overlay
	var/knife_x_offset = 0
	var/knife_y_offset = 0
	/// Whether or not the gun fits in a shoulder holster.
	var/can_holster = FALSE
	/// Weapon modifications (except bayonets, flashlights, and suppressors - these are tracked seperately).
	var/list/upgrades = list()

	var/ammo_x_offset = 0 // Used for positioning ammo count overlay on sprite.
	var/ammo_y_offset = 0
	var/flight_x_offset = 0
	var/flight_y_offset = 0

/obj/item/gun/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CAN_POINT_WITH, ROUNDSTART_TRAIT)
	appearance_flags |= KEEP_TOGETHER

/obj/item/gun/Destroy()
	QDEL_NULL(bayonet)
	QDEL_NULL(chambered)
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
			. += "<span class='notice'>[bayonet] looks like it can be <b>unscrewed</b> from [src].</span>"
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
				user.visible_message(
					"<span class='danger'>[user] fires [src] point blank at [target]!</span>",
					"<span class='danger'>You fire [src] point blank at [target]!</span>",
					"<span class='danger'>You hear \a [fire_sound_text]!</span>"
				)
			else
				user.visible_message(
					"<span class='danger'>[user] fires [src]!</span>",
					"<span class='danger'>You fire [src]!</span>",
					"<span class='danger'>You hear \a [fire_sound_text]!</span>"
				)
	if(chambered?.muzzle_flash_effect)
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

/obj/item/gun/afterattack__legacy__attackchain(atom/target, mob/living/user, flag, params)
	if(firing_burst)
		return
	if(SEND_SIGNAL(src, COMSIG_GUN_TRY_FIRE, user, target, flag, params) & COMPONENT_CANCEL_GUN_FIRE)
		return
	if(SEND_SIGNAL(src, COMSIG_MOB_TRY_FIRE, user, target, flag, params) & COMPONENT_CANCEL_GUN_FIRE)
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
			if(target == user && HAS_TRAIT(user, TRAIT_BADASS)) // Check if we are blowing smoke off of our own gun, otherwise we are trying to execute someone
				user.visible_message(
					"<span class='danger'>[user] blows smoke off of [src]'s barrel. What a badass.</span>",
					"<span class='danger'>You blow smoke off of [src]'s barrel.</span>",
					"<span class='danger'>You hear someone blowing over a hollow tube.</span>"
				)
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
	if(!(ishuman(user) && user.a_intent == INTENT_HARM))
		process_fire(target, user, TRUE, params, null, bonus_spread)
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/gun/GUN_1 = H.get_active_hand()
	if(istype(H.get_inactive_hand(), /obj/item/gun)) //We do not need to check gun one, as it is controlled by the afterattack
		var/obj/item/gun/GUN_2 = H.get_inactive_hand()

		if(GUN_2.weapon_weight >= WEAPON_MEDIUM)
			process_fire(target, user, TRUE, params, null, bonus_spread)
			return
		if(GUN_2.can_trigger_gun(user))
			if(!HAS_TRAIT(user, TRAIT_BADASS))
				var/temporary_weapon_weight = GUN_2.weapon_weight
				if(GUN_1.type != GUN_2.type)
					temporary_weapon_weight = max(temporary_weapon_weight, WEAPON_LIGHT) //Can't hold the sparker in the off hand to make both guns perfectly accurate, must be 2 sparkers
				bonus_spread += dual_wield_spread * temporary_weapon_weight
			addtimer(CALLBACK(GUN_2, PROC_REF(process_fire), target, user, TRUE, params, null, bonus_spread), 1)

	process_fire(target, user, TRUE, params, null, bonus_spread)

/obj/item/gun/proc/can_trigger_gun(mob/living/user)
	if(!user.can_use_guns(src))
		return 0
	if(restricted_species && length(restricted_species) && !is_type_in_list(user.dna.species, restricted_species))
		to_chat(user, "<span class='danger'>[src] is incompatible with your biology!</span>")
		return 0
	return 1

/obj/item/gun/proc/newshot()
	return

/obj/item/gun/proc/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override, bonus_spread = 0)
	add_fingerprint(user)

	if(semicd)
		return
	SEND_SIGNAL(src, COMSIG_GUN_FIRED, user, target)
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
				chambered.leave_residue(user)

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

/obj/item/gun/attack__legacy__attackchain(mob/M, mob/user)
	if(user.a_intent == INTENT_HARM) //Flogging
		if(bayonet)
			M.attack_by(bayonet, user)
		else
			return ..()

/obj/item/gun/attack_obj__legacy__attackchain(obj/O, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		if(bayonet)
			O.attackby__legacy__attackchain(bayonet, user)
			return
	return ..()

/obj/item/gun/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/flashlight/seclite))
		var/obj/item/flashlight/seclite/S = I
		if(can_flashlight)
			if(!gun_light)
				if(!user.transfer_item_to(I, src))
					return
				to_chat(user, "<span class='notice'>You click [S] into place on [src].</span>")
				playsound(src, 'sound/machines/click.ogg', 50, TRUE)
				if(S.on)
					set_light(0)
				gun_light = S
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
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
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
	if(gun_light || bayonet)
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
		else if(bayonet && can_bayonet) // if it has a bayonet, and the bayonet can be removed
			bayonet.forceMove(get_turf(user))
			to_chat(user, "<span class='notice'>You remove [bayonet] from [src].</span>")
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

	update_action_buttons()

/obj/item/gun/proc/clear_bayonet()
	if(!bayonet)
		return
	bayonet = null
	if(knife_overlay)
		overlays -= knife_overlay
		knife_overlay = null
		update_icon()
	return TRUE

/obj/item/gun/extinguish_light(force = FALSE)
	if(gun_light?.on)
		toggle_gunlight()
		visible_message("<span class='danger'>[src]'s light fades and turns off.</span>")



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

/obj/item/gun/proc/handle_suicide(mob/user, mob/living/carbon/human/target, params)
	if(!ishuman(target)) // So only human-type mobs can be executed.
		return

	if(semicd)
		return

	if(user == target)
		if(!ishuman(user))	// Borg suicide needs a refactor for this to work.
			return
		target.visible_message(
			"<span class='warning'>[user] sticks [src] in [user.p_their()] mouth, ready to pull the trigger...</span>",
			"<span class='userdanger'>You stick [src] in your mouth, ready to pull the trigger...</span>"
		)
	else
		target.visible_message(
			"<span class='warning'>[user] points [src] at [target]'s head, ready to pull the trigger...</span>",
			"<span class='userdanger'>[user] points [src] at your head, ready to pull the trigger...</span>"
		)

	semicd = 1

	if(!do_mob(user, target, execution_speed) || user.zone_selected != "mouth")
		if(user)
			if(user == target)
				user.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
			else if(target && target.Adjacent(user))
				target.visible_message(
					"<span class='notice'>[user] has decided to spare [target]'s life.</span>",
					"<span class='userdanger'>[user] has decided to spare your life!</span>"
				)
		semicd = 0
		return

	semicd = 0

	target.visible_message(
		"<span class='warning'>[user] pulls the trigger!</span>",
		"<span class='userdanger'>[user] pulls the trigger!</span>"
	)

	if(chambered && chambered.BB)
		chambered.BB.damage *= 5

	process_fire(target, user, 1, params)

/obj/item/gun/proc/on_scope_success()
	return

/obj/item/gun/proc/on_scope_end()
	return
