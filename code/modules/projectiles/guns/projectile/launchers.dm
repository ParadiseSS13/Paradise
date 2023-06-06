//KEEP IN MIND: These are different from gun/grenadelauncher. These are designed to shoot premade rocket and grenade projectiles, not flashbangs or chemistry casings etc.
//Put handheld rocket launchers here if someone ever decides to make something so hilarious ~Paprika

/obj/item/gun/projectile/revolver/grenadelauncher//this is only used for underbarrel grenade launchers at the moment, but admins can still spawn it if they feel like being assholes
	desc = "A break-operated grenade launcher."
	name = "grenade launcher"
	icon_state = "dshotgun-sawn"
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/internal/grenadelauncher
	fire_sound = 'sound/weapons/gunshots/1grenlauncher.ogg'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/projectile/revolver/grenadelauncher/attackby(var/obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing))
		chamber_round()

/obj/item/gun/projectile/revolver/grenadelauncher/multi
	desc = "A revolving 6-shot grenade launcher."
	name = "multi grenade launcher"
	icon_state = "bulldog"
	item_state = "bulldog"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi

/obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg
	desc = "A 6-shot grenade launcher."
	icon = 'icons/obj/mecha/mecha_equipment.dmi'
	icon_state = "mecha_grenadelnchr"

/obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg/attack_self()
	return

/obj/item/gun/projectile/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A prototype pistol designed to fire self propelled rockets."
	icon_state = "gyropistol"
	fire_sound = 'sound/effects/explosion1.ogg'
	origin_tech = "combat=5"
	mag_type = /obj/item/ammo_box/magazine/m75
	can_holster = TRUE // Override default automatic setting since it is a handgun sized gun
	burst_size = 1
	fire_delay = 0
	actions_types = list()


/obj/item/gun/projectile/automatic/gyropistol/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/automatic/gyropistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"
	return

/obj/item/gun/projectile/automatic/speargun
	name = "kinetic speargun"
	desc = "A weapon favored by carp hunters. Fires specialized spears using kinetic energy."
	icon_state = "speargun"
	item_state = "speargun"
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "combat=4;engineering=4"
	force = 10
	can_suppress = 0
	mag_type = /obj/item/ammo_box/magazine/internal/speargun
	fire_sound = 'sound/weapons/genhit.ogg'
	burst_size = 1
	fire_delay = 0
	select = 0
	actions_types = list()

/obj/item/gun/projectile/automatic/speargun/update_icon()
	return

/obj/item/gun/projectile/automatic/speargun/attack_self()
	return

/obj/item/gun/projectile/automatic/speargun/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()

/obj/item/gun/projectile/automatic/speargun/attackby(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] spear\s into \the [src].</span>")
		update_icon()
		chamber_round()

/obj/item/gun/projectile/revolver/rocketlauncher //nice revolver you got here
	name = "\improper PML-9"
	desc = "A reusable rocket propelled grenade launcher. The words \"NT this way\" and an arrow have been written near the barrel."
	icon_state = "rocketlauncher"
	item_state = "rocketlauncher"
	mag_type = /obj/item/ammo_box/magazine/internal/rocketlauncher
	fire_sound = 'sound/weapons/gunshots/1launcher.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	can_holster = FALSE
	flags = CONDUCT

/obj/item/gun/projectile/revolver/rocketlauncher/attackby(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You carefully load [A] into \the [src].</span>")
		chamber_round()
		cut_overlays()


/obj/item/gun/projectile/revolver/rocketlauncher/afterattack()
	. = ..()
	magazine.get_round(FALSE) //Hack to clear the mag after it's fired
	chambered = null //weird thing
	update_icon()


/obj/item/gun/projectile/revolver/rocketlauncher/attack_self(mob/living/user)
	var/num_unloaded = 0
	var/obj/item/ammo_casing/CB
	while(get_ammo() > 0)
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(loc)
		user.put_in_hands(CB)
		num_unloaded++
	if(num_unloaded)
		to_chat(user, "<span class = 'notice'>You carefully remove [CB] from \the [src] .</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
	update_icon()
	return

/obj/item/gun/projectile/revolver/rocketlauncher/update_icon()
	cut_overlays()
	if(!chambered)
		add_overlay("[icon_state]_empty")

/obj/item/gun/projectile/revolver/rocketlauncher/suicide_act(mob/user)
	user.visible_message("<span class='warning'>[user] aims [src] at the ground! It looks like [user.p_theyre()] performing a sick rocket jump!<span>")
	if(can_shoot())
		user.notransform = TRUE
		playsound(src, 'sound/weapons/rocketlaunch.ogg', 80, 1, 5)
		animate(user, pixel_z = 300, time = 3 SECONDS, easing = LINEAR_EASING)
		sleep(7 SECONDS)
		animate(user, pixel_z = 0, time = 0.5 SECONDS, easing = LINEAR_EASING)
		sleep(0.5 SECONDS)
		user.notransform = FALSE
		process_fire(user, user, TRUE)
		if(!QDELETED(user)) //if they weren't gibbed by the explosion, take care of them for good.
			user.gib()
		return OBLITERATION
	else
		sleep(0.5 SECONDS)
		shoot_with_empty_chamber(user)
		sleep(2 SECONDS)
		user.visible_message("<span class='warning'>[user] looks about the room realizing [user.p_theyre()] still there. [user.p_they(TRUE)] proceed to shove [src] down their throat and choke [user.p_them()]self with it!<span>")
		sleep(2 SECONDS)
		return OXYLOSS
