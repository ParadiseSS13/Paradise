/obj/item/gun/energy/laser
	name = "laser gun"
	desc = "A WT-650 'Sentinel' laser carbine manufactured by Warp-Tac Inc. The golden shield of Nanotrasen Security is visible."
	icon_state = "laser"
	item_state = "laser"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=4;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)
	ammo_x_offset = 1
	shaded_charge = TRUE

/obj/item/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	origin_tech = "combat=2;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = FALSE
	needs_permit = FALSE

/obj/item/gun/energy/laser/retro
	name ="retro laser gun"
	icon_state = "retro"
	item_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's private security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	ammo_x_offset = 3

/obj/item/gun/energy/laser/captain
	name = "antique laser gun"
	icon_state = "caplaser"
	item_state = null
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	force = 10
	origin_tech = null
	ammo_x_offset = 3
	selfcharge = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/gun/energy/laser/captain/Initialize(mapload, ...)
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(alert_admins_on_destroy))

/obj/item/gun/energy/laser/captain/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The power cell of this item slowly recharges on it's own. This caused the station pictured to explode. Cannot be recharged in a recharger.</span>"

/obj/item/gun/energy/laser/captain/scattershot
	name = "scatter shot laser rifle"
	icon_state = "lasercannon"
	item_state = "laser"
	desc = "An industrial-grade heavy-duty laser rifle with a modified laser lense to scatter its shot into multiple smaller lasers. The inner-core can self-charge for theorically infinite use."
	origin_tech = "combat=5;materials=4;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)
	shaded_charge = FALSE

/obj/item/gun/energy/laser/cyborg
	can_charge = FALSE
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/cyborg)
	origin_tech = null

/obj/item/gun/energy/laser/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/laser/cyborg/emp_act()
	return

/obj/item/gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)

///Laser Cannon

/obj/item/gun/energy/lasercannon
	name = "accelerator laser cannon"
	desc = "An advanced laser cannon that does more damage the farther away the target is."
	icon_state = "lasercannon"
	item_state = null
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	can_holster = FALSE
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/accelerator)
	ammo_x_offset = 3

/obj/item/ammo_casing/energy/laser/accelerator
	projectile_type = /obj/item/projectile/beam/laser/accelerator
	select_name = "accelerator"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/projectile/beam/laser/accelerator
	name = "accelerator laser"
	icon_state = "heavylaser"
	range = 255
	damage = 6

/obj/item/projectile/beam/laser/accelerator/Range()
	..()
	damage = min(damage+7, 100)

/obj/item/gun/energy/lasercannon/cyborg

/obj/item/gun/energy/lasercannon/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/lasercannon/cyborg/emp_act()
	return

#define PROCESS_TIME_PLUS_DECISECOND 2.1 SECONDS //This ensures that you cant move and scope the lwap.

/obj/item/gun/energy/lwap
	name = "LWAP laser sniper"
	desc = "A highly advanced laser sniper that does more damage the farther away the target is, but fires slowly. Comes with a super advanced scope, which can highlight threats through walls, and pierce one object, after being deployed for a while."
	icon_state = "esniper"
	item_state = null
	w_class = WEIGHT_CLASS_BULKY
	force = 12
	flags = CONDUCT
	slot_flags = SLOT_BACK
	can_holster = FALSE
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=6;magnets=6;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/sniper, /obj/item/ammo_casing/energy/laser/sniper/pierce)
	zoomable = TRUE
	zoom_amt = 7
	shaded_charge = TRUE
	/// Is the scope fully online or not?
	var/scope_active = FALSE
	var/stored_dir

/obj/item/gun/energy/lwap/Initialize(mapload, ...)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/gun/energy/lwap/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/gun/energy/lwap/zoom(mob/living/user, forced_zoom)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	stored_dir = H.dir
	if(scope_active && !zoomed)
		select_fire(H)
		H.remove_status_effect(STATUS_EFFECT_LWAPSCOPE)
		scope_active = FALSE
		return
	if(zoomed && do_after(user, 3 SECONDS, target = src))
		if(zoomed && !scope_active) //We check after to be sure.
			scope_active = TRUE
			to_chat(user, "<b><span class='robot'>SCOPE_CREEPER_[rand(1, 9999)] Online.</span></b>")
			select_fire(H)
			H.apply_status_effect(STATUS_EFFECT_LWAPSCOPE, stored_dir)
		return
	if(zoomed)
		zoom(user, FALSE) //Moved while scope was booting, so we unzoom

/obj/item/gun/energy/lwap/process()
	. = ..()
	if(!isliving(loc))
		return
	var/mob/living/M = loc
	if(world.time - M.last_movement <= PROCESS_TIME_PLUS_DECISECOND && scope_active) //If they have moved in the last process cycle.
		to_chat(M, "<span class='warning'>[src]'s scope is overloaded by movement and shuts down!</span>")
		zoom(M, FALSE)

/obj/item/gun/energy/lwap/attack_self()
	return //no manual ammo changing.

#undef PROCESS_TIME_PLUS_DECISECOND
/obj/item/ammo_casing/energy/laser/sniper
	projectile_type = /obj/item/projectile/beam/laser/sniper
	muzzle_flash_color = LIGHT_COLOR_PINK
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	select_name = null
	fire_sound = 'sound/weapons/marauder.ogg'
	delay = 5 SECONDS

/obj/item/ammo_casing/energy/laser/sniper/pierce
	projectile_type = /obj/item/projectile/beam/laser/sniper/pierce

/obj/item/projectile/beam/laser/sniper
	name = "sniper laser"
	icon_state = "sniperlaser"
	range = 255
	damage = 10
	speed = 0.75
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	forced_accuracy = TRUE
	var/can_knockdown = TRUE

/obj/item/projectile/beam/laser/sniper/Range()
	..()
	damage = min(damage + 5, 100)

/obj/item/projectile/beam/laser/sniper/on_hit(atom/target, blocked = 0, hit_zone)
	..()
	var/mob/living/carbon/human/H = target
	if(istype(H) && damage >= 40 && can_knockdown)
		H.KnockDown(2 SECONDS * (damage / 10))
	can_knockdown = FALSE //Projectiles that pierce can not knockdown, no wall knockdowns.

/obj/item/projectile/beam/laser/sniper/pierce
	forcedodge = 1 // Can pierce one mob.
	speed = 0.5

/obj/item/gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts. These blasts will penetrate solid objects, but will decrease in power the longer they have to travel."
	icon_state = "xray"
	item_state = null
	shaded_charge = TRUE
	origin_tech = "combat=6;materials=4;magnets=4;syndicate=1"
	ammo_type = list(/obj/item/ammo_casing/energy/xray)

/obj/item/gun/energy/immolator
	name = "immolator laser gun"
	desc = "A modified laser gun, shooting highly concetrated beams with higher intensity that ignites the target, for the cost of draining more power per shot"
	icon_state = "immolator"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/immolator)
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	shaded_charge = TRUE

/obj/item/gun/energy/immolator/multi
	name = "multi lens immolator cannon"
	desc = "A large laser cannon, similar to the Immolator Laser, with toggleable firemodes. It is frequently used by military-like forces through Nanotrasen."
	icon_state = "multilensimmolator"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/immolator/strong, /obj/item/ammo_casing/energy/immolator/scatter)
	origin_tech = "combat=5;magnets=5;powerstorage=4"

/obj/item/gun/energy/immolator/multi/update_overlays()
	. = ..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/append = shot.select_name
	. += image(icon = icon, icon_state = "multilensimmolator-[append]")

/obj/item/gun/energy/immolator/multi/cyborg
	name = "cyborg immolator cannon"
	ammo_type = list(/obj/item/ammo_casing/energy/immolator/scatter/cyborg, /obj/item/ammo_casing/energy/immolator/strong/cyborg) // scatter is default, because it is more useful

/obj/item/gun/energy/emitter
	name = "mobile emitter"
	desc = "An emitter removed from its base, and attached to a laser cannon frame."
	icon_state = "emittercannon"
	item_state = "laser"
	w_class = WEIGHT_CLASS_BULKY
	shaded_charge = TRUE
	can_holster = FALSE
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/emitter)
	ammo_x_offset = 3

/obj/item/gun/energy/emitter/cyborg
	name = "mounted emitter"
	desc = "An emitter built into to your cyborg frame, draining charge from your cell."
	ammo_type = list(/obj/item/ammo_casing/energy/emitter/cyborg)

/obj/item/gun/energy/emitter/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/emitter/cyborg/emp_act()
	return

////////Laser Tag////////////////////

/obj/item/gun/energy/laser/tag
	name = "laser tag gun"
	desc = "Standard issue weapon of the Imperial Guard"
	origin_tech = "combat=2;magnets=2"
	clumsy_check = FALSE
	needs_permit = FALSE
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/tag/blue
	icon_state = "bluetag"
	item_state = "bluetag"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)

/obj/item/gun/energy/laser/tag/red
	icon_state = "redtag"
	item_state = "redtag"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
