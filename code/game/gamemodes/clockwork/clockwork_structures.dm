/obj/structure/clockwork
	density = 1
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/clockwork.dmi'

/obj/structure/clockwork/beacon
	name = "herald's beacon"
	desc = "An imposing spire formed of brass. It somewhat pulsates."
	icon_state = "beacon"

/obj/structure/clockwork/altar
	name = "credence"
	desc = "A strange brass platform with spinning cogs inside. It demands somethinge in exchange for goods..."
	icon_state = "altar"
	density = 0

/obj/structure/clockwork/functional
	max_integrity = 100
	var/cooldowntime = 0
	var/death_message = "<span class='danger'>The structure falls apart.</span>"
	var/death_sound = 'sound/effects/forge_destroy.ogg'

/obj/structure/clockwork/functional/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(user))
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "":"un"]secure [src] [anchored ? "to":"from"] the floor.</span>")
		if(!anchored)
			icon_state = "[initial(icon_state)]-off"
		else
			icon_state = "[initial(icon_state)]"
		update_icon()
		return TRUE
	return ..()

/obj/structure/clockwork/functional/obj_destruction()
	visible_message(death_message)
	playsound(src, death_sound, 50, TRUE)
	. = ..()

/obj/structure/clockwork/functional/beacon
	name = "herald's beacon"
	desc = "An imposing spire formed of brass. It somewhat pulsates."
	icon_state = "beacon"
	max_integrity = 750 // A very important one
	death_message = "<span class='danger'>The beacon crumbles and falls in parts to the ground relaesing it's power!</span>"
	death_sound = 'sound/effects/creepyshriek.ogg'
	var/heal_delay = 60
	var/last_heal = 0
	var/area/areabeacon
	var/areastring = null
	color = "#FFFFFF"

/obj/structure/clockwork/functional/beacon/Initialize(mapload)
	. = ..()
	areabeacon = get_area(src)
	GLOB.clockwork_beacons += src
	START_PROCESSING(SSobj, src)
	var/area/A = get_area(src)
	//if area isn't specified use current
	if(isarea(A))
		areabeacon = A
	SSticker.mode.clocker_objs.beacon_check()

/obj/structure/clockwork/functional/beacon/process()
	adjust_clockwork_power(CLOCK_POWER_BEACON)

	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(!isclocker(L))
				continue
			if(!(L.health < L.maxHealth))
				continue
			new /obj/effect/temp_visual/heal(get_turf(L), "#960000")

			if(ishuman(L))
				L.heal_overall_damage(2, 2, TRUE, FALSE, TRUE)

			else if(isshade(L) || isconstruct(L))
				var/mob/living/simple_animal/M = L
				if(M.health < M.maxHealth)
					M.adjustHealth(-2)

			if(ishuman(L) && L.blood_volume < BLOOD_VOLUME_NORMAL)
				L.blood_volume += 1

/obj/structure/clockwork/functional/beacon/Destroy()
	GLOB.clockwork_beacons -= src
	for(var/datum/mind/M in SSticker.mode.clockwork_cult)
		to_chat(M.current, "<span class='danger'>You get the feeling that one of the beacons have been destroyed! The source comes from [areabeacon.name]</span>")
	return ..()

/obj/structure/clockwork/functional/beacon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(user))
		to_chat(user, "<span class='danger'>You try to unsecure [src], but it's secures himself back tightly!</span>")
		return TRUE
	return ..()

/obj/structure/clockwork/functional/altar
	name = "credence"
	desc = "A strange brass platform with spinning cogs inside. It demands somethinge in exchange for goods..."
	icon_state = "altar"
	density = 0
	death_message = "<span class='danger'>The alter breaks in pieces as it dusts into nothing!</span>"
	var/time_until_convert = 8 SECONDS
	var/glow_type = /obj/effect/temp_visual/ratvar/altar_convert
	var/summoning = FALSE

/obj/structure/clockwork/functional/altar/Crossed(atom/movable/AM)
	if(!anchored)
		return
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/target = AM
	if(isclocker(target))
		return
	if(summoning)
		if(target.pulledby)
			to_chat(pulledby, "<span class='clockitalic'There is another body on [src]!</span>")
		return
	if(!target.mind)
		if(target.pulledby)
			to_chat(pulledby, "<span class='clockitalic'This body is mindless! It doesn't even worth anything!</span>")
		return
	var/obj/item/rod = target.null_rod_check()
	if(rod)
		target.visible_message("<span class='warning'>[target]'s [rod.name] glows, protecting them from [src]'s effects!</span>", \
		"<span class='userdanger'>Your [rod.name] glows, protecting you!</span>")
		return
	try_convert(target)

/obj/structure/clockwork/functional/altar/proc/try_convert(mob/living/carbon/human/target)
	var/has_clocker = null
	for(var/mob/living/M in range(1, src))
		if(isclocker(M) && !M.stat)
			has_clocker = M
			break
	if(!has_clocker)
		visible_message("<span class='warning'>[src] strains into a gentle yellow color, but quietly fades...</span>")
		return
	target.visible_message("<span class='warning'>[src] begins to glow a piercing amber!</span>", "<span class='clock'>You feel something start to invade your mind...</span>")
	var/obj/effect/temp_visual/ratvar/altar_convert/glow = new glow_type(get_turf(src))
	animate(glow, alpha = 255, time = time_until_convert)
	icon_state = "[initial(icon_state)]-fast"
	var/timer = 0
	// We doing some converting here
	while(timer < time_until_convert)
		if(get_turf(target) != get_turf(src))
			break
		if(!anchored)
			break
		if(!in_range(src, has_clocker))
			for(var/mob/living/M in range(1, src))
				if(!isclocker(M))
					continue
				if(M.stat)
					has_clocker = M
					break
			has_clocker = null
			break
		timer++
		sleep(1)
	if(get_turf(target) != get_turf(src) || !anchored || !has_clocker)
		QDEL_NULL(glow)
		if(anchored)
			icon_state = "[initial(icon_state)]"
		else
			icon_state = "[initial(icon_state)]-off"
		visible_message("<span class='warning'>[src] slowly stops glowing!</span>")
		return
	if(target.stat != DEAD && is_convertable_to_clocker(target.mind))
		to_chat(target, "<span class='clocklarge'><b>\"You belong to me now.\"</b></span>")
		// Brass golem now and the master Ratvar. One way only: Serve or die perma.
		if(isgolem(target))
			target.mind.wipe_memory()
			target.set_species(/datum/species/golem/clockwork)
		if(SSticker.mode.add_clocker(target.mind))
			target.create_log(CONVERSION_LOG, "[target] been converted into clockwork cult by altar.")
		target.Weaken(5) //Accept new power... and new information
		target.EyeBlind(5)
	else // Start tearing him apart until GIB
		timer = 0
		target.visible_message("<span class='warning'>[src] in glowing manner starts rupturing [target]!</span>", \
		"<span class='danger'>[src] underneath you starts to tear you to pieces!</span>")
		while(timer < time_until_convert)
			if(get_turf(target) != get_turf(src))
				break
			if(!anchored)
				break
			if(!in_range(src, has_clocker))
				for(var/mob/living/M in range(1, src))
					if(!isclocker(M))
						continue
					if(M.stat)
						has_clocker = M
						break
				has_clocker = null
				break
			timer++
			sleep(1)
			if(timer > time_until_convert*0.8)
				target.adjustBruteLoss(30)
			else
				target.adjustBruteLoss(5)
		if(get_turf(target) == get_turf(src) && src.anchored && has_clocker)
			target.gib()
			var/obj/item/mmi/robotic_brain/clockwork/cube = new (get_turf(src))
			cube.try_to_transfer(target)
			adjust_clockwork_power(CLOCK_POWER_SACRIFICE)

		if(src.anchored)
			icon_state = "[initial(icon_state)]"
		else
			icon_state = "[initial(icon_state)]-off"
	QDEL_NULL(glow)
	visible_message("<span class='warning'>[src] slowly stops glowing!</span>")

/obj/structure/clockwork/functional/altar/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/clockwork/shard))
		var/area/A = get_area(src)
		if(!anchored)
			to_chat(user, "<span class='warning'>It has to be anchored before you can start!</span>")
		if(!double_check(user, A))
			return
		GLOB.command_announcement.Announce("A high anomalous power has been detected in [A.map_name], the origin of the power indicates an attempt to summon eldtrich god named Ratvar. Disrupt the ritual at all costs, before the station is destroyed! Space law and SOP are suspended. The entire crew must kill cultists on sight.", "Central Command Higher Dimensional Affairs", 'sound/AI/spanomalies.ogg')
		visible_message("<span class='biggerdanger'>[user] ominously presses [I] into [src] as the mechanism inside starts to shine!</span>")
		user.unEquip(I)
		qdel(I)
		begin_the_ritual()

/obj/structure/clockwork/functional/altar/proc/double_check(mob/living/user, area/A)
	var/datum/game_mode/gamemode = SSticker.mode

	if(gamemode.clocker_objs.clock_status < RATVAR_NEEDS_SUMMONING)
		to_chat(user, "<span class='clockitalic'><b>Ratvar</b> is not ready to be summoned yet!</span>")
		return FALSE
	if(gamemode.clocker_objs.clock_status == RATVAR_HAS_RISEN)
		to_chat(user, "<span class='clocklarge'>\"My fellow. There is no need for it anymore.\"</span>")
		return FALSE

	var/list/summon_areas = gamemode.clocker_objs.obj_summon.ritual_spots
	if(!(A in summon_areas))
		to_chat(user, "<span class='cultlarge'>Ratvar can only be summoned where the veil is weak - in [english_list(summon_areas)]!</span>")
		return FALSE
	var/confirm_final = alert(user, "This is the FINAL step to summon, the crew will be alerted to your presence AND your location!",
	"The power comes...", "Let Ratvar shine ones more!", "No")
	if(user)
		if(confirm_final == "No" || confirm_final == null)
			to_chat(user, "<span class='clockitalic'><b>You decide to prepare further before pincing the shard.</b></span>")
			return FALSE
		return TRUE

/obj/structure/clockwork/functional/altar/proc/begin_the_ritual()
	summoning = TRUE
	visible_message("<span class='danger'>The [src] expands itself revealing into the great Ark!</span>")
	new /obj/structure/clockwork/functional/celestial_gateway(get_turf(src))
	qdel(src)
	return

/// for area.get_beacon() returns BEACON if it exists
/area/proc/get_beacon()
	for(var/thing in GLOB.clockwork_beacons)
		var/obj/structure/clockwork/functional/beacon/BEACON = thing
		if(BEACON.areabeacon == get_area(src))
			return BEACON

