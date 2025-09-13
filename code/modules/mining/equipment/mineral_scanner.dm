/**********************Mining Scanner**********************/
/obj/item/mining_scanner
	name = "manual mining scanner"
	desc = "A scanner that checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results."
	icon = 'icons/obj/device.dmi'
	icon_state = "mining1"
	inhand_icon_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	var/cooldown = 35
	var/current_cooldown = 0

	origin_tech = "engineering=1;magnets=1"

/obj/item/mining_scanner/attack_self__legacy__attackchain(mob/user)
	if(!user.client)
		return
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		mineral_scan_pulse(get_turf(user))

//Debug item to identify all ore spread quickly
/obj/item/mining_scanner/admin

/obj/item/mining_scanner/admin/attack_self__legacy__attackchain(mob/user)
	for(var/turf/simulated/mineral/M in world)
		if(M.ore?.scan_icon_state)
			M.icon_state = M.ore.scan_icon_state
	qdel(src)

/obj/item/t_scanner/adv_mining_scanner
	name = "advanced automatic mining scanner"
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results. This one has an extended range."
	icon_state = "mining0"
	inhand_icon_state = "analyzer"
	flags = CONDUCT
	var/cooldown = 35
	var/current_cooldown = 0
	var/range = 7
	origin_tech = "engineering=3;magnets=3"

/obj/item/t_scanner/adv_mining_scanner/cyborg
	flags = CONDUCT | NODROP

/obj/item/t_scanner/adv_mining_scanner/lesser
	name = "automatic mining scanner"
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results."
	range = 4
	cooldown = 50

/obj/item/t_scanner/adv_mining_scanner/scan()
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		var/turf/t = get_turf(src)
		mineral_scan_pulse(t, range)

/proc/mineral_scan_pulse(turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/simulated/mineral/M in range(range, T))
		if(M.ore?.scan_icon_state)
			minerals += M
	if(LAZYLEN(minerals))
		for(var/turf/simulated/mineral/M in minerals)
			var/obj/effect/temp_visual/mining_overlay/oldC = locate(/obj/effect/temp_visual/mining_overlay) in M
			if(oldC)
				qdel(oldC)
			var/obj/effect/temp_visual/mining_overlay/C = new /obj/effect/temp_visual/mining_overlay(M)
			C.icon_state = M.ore.scan_icon_state
			M.vis_contents += C

/obj/effect/temp_visual/mining_overlay
	plane = FULLSCREEN_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/ore_visuals.dmi'
	icon_state = null
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	duration = 35
	pixel_x = -224
	pixel_y = -224

/obj/effect/temp_visual/mining_overlay/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = EASE_IN)
