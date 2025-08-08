/obj/item/storm_staff
	name = "staff of storms"
	desc = "An ancient staff retrieved from the remains of Legion. The wind stirs as you move it."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "staffofstorms"
	lefthand_file = 'icons/mob/inhands/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/staves_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	damtype = BURN
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	needs_permit = TRUE
	var/max_thunder_charges = 3
	var/thunder_charges = 3
	var/thunder_charge_time = 15 SECONDS
	var/static/list/excluded_areas = list(/area/space)
	///This is a list of turfs currently being targeted.
	var/list/targeted_turfs = list()

/obj/item/storm_staff/Destroy()
	targeted_turfs = null
	return ..()

/obj/item/storm_staff/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It has [thunder_charges] charges remaining.</span>"
	. += "<span class='notice'>Use it in hand to dispel storms.</span>"
	. += "<span class='notice'>Use it on targets to summon thunderbolts from the sky.</span>"
	. += "<span class='notice'>The thunderbolts are boosted if in an area with weather effects.</span>"

/obj/item/storm_staff/attack__legacy__attackchain(mob/living/target, mob/living/user)
	if(cigarette_lighter_act(user, target))
		return TRUE

	return ..()

/obj/item/storm_staff/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!thunder_charges)
		to_chat(user, "<span class='warning'>[src] needs to recharge!</span>")
		return TRUE

	if(target == user)
		user.visible_message(
			"<span class='warning'>[user] holds [src] up to [user.p_their()] [cig.name] and shoots a tiny bolt of lightning that sets it alight!</span>",
			"<span class='warning'>You hold [src] up to [cig] and shoot a tiny bolt of lightning that sets it alight!</span>",
			"<span class='danger'>A thundercrack fills the air!</span>"
		)
	else
		user.visible_message(
			"<span class='warning'>[user] points [src] at [target] and shoots a tiny bolt of lightning that sets [target.p_their()] [cig.name] alight!</span>",
			"<span class='warning'>You point [src] at [target] and shoot a tiny bolt of lightning that sets [target.p_their()] [cig.name] alight!</span>",
			"<span class='danger'>A thundercrack fills the air!</span>"
		)
	cig.light(user, target)
	playsound(target, 'sound/magic/lightningbolt.ogg', 50, TRUE)
	thunder_charges--
	return TRUE

/obj/item/storm_staff/attack_self__legacy__attackchain(mob/user)
	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)
	if(!user_area || !user_turf)
		to_chat(user, "<span class='warning'>Something is preventing you from using the staff here.</span>")
		return
	var/datum/weather/A
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if((user_turf.z in W.impacted_z_levels) && is_type_in_list(user_area, W.area_types))
			A = W
			break

	if(A)
		if(A.stage != WEATHER_END_STAGE)
			if(A.stage == WEATHER_WIND_DOWN_STAGE)
				to_chat(user, "<span class='warning'>The storm is already ending! It would be a waste to use the staff now.</span>")
				return
			user.visible_message(
				"<span class='warning'>[user] holds [src] skywards as an orange beam travels into the sky!</span>",
				"<span class='notice'>You hold [src] skyward, dispelling the storm!</span>"
			)
			playsound(user, 'sound/magic/staff_change.ogg', 200, FALSE)
			A.wind_down()
			var/old_color = user.color
			user.color = list(340/255, 240/255, 0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
			var/old_transform = user.transform
			user.transform *= 1.2
			animate(user, color = old_color, transform = old_transform, time = 1 SECONDS)

/obj/item/storm_staff/afterattack__legacy__attackchain(atom/target, mob/user, proximity_flag, click_parameters)
	// This early return stops the staff from shooting lightning at someone when being used as a lighter.
	if(iscarbon(target))
		var/mob/living/carbon/cig_haver = target
		var/mask_item = cig_haver.get_item_by_slot(ITEM_SLOT_MASK)
		if(istype(mask_item, /obj/item/clothing/mask/cigarette) && user.zone_selected == "mouth" && user.a_intent == INTENT_HELP)
			return

	. = ..()
	if(!thunder_charges)
		to_chat(user, "<span class='warning'>The staff needs to recharge.</span>")
		return
	var/turf/target_turf = get_turf(target)
	var/area/target_area = get_area(target)
	var/area/user_area = get_area(user)
	if(!target_turf || !target_area || (is_type_in_list(target_area, excluded_areas)) || !user_area || (is_type_in_list(user_area, excluded_areas)))
		to_chat(user, "<span class='warning'>The staff will not work here.</span>")
		return
	if(target_turf in targeted_turfs)
		to_chat(user, "<span class='warning'>That SPOT is already being shocked!</span>")
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to hurt anyone!</span>")
		return
	var/power_boosted = FALSE
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if((target_turf.z in W.impacted_z_levels) && is_type_in_list(target_area, W.area_types))
			power_boosted = TRUE
			break
	playsound(src, 'sound/magic/lightningshock.ogg', 10, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	targeted_turfs += target_turf
	to_chat(user, "<span class='warning'>You aim at [target_turf]!</span>")
	new /obj/effect/temp_visual/thunderbolt_targeting(target_turf)
	addtimer(CALLBACK(src, PROC_REF(throw_thunderbolt), target_turf, power_boosted, user), 1.5 SECONDS)
	thunder_charges--
	addtimer(CALLBACK(src, PROC_REF(recharge)), thunder_charge_time)

/obj/item/storm_staff/proc/recharge(mob/user)
	thunder_charges = min(thunder_charges + 1, max_thunder_charges)
	playsound(src, 'sound/magic/charge.ogg', 10, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)

/obj/item/storm_staff/proc/throw_thunderbolt(turf/target, boosted, mob/caster)
	targeted_turfs -= target
	new /obj/effect/temp_visual/thunderbolt(target)
	var/list/affected_turfs = list(target)
	if(boosted)
		for(var/direction in GLOB.alldirs)
			var/turf_to_add = get_step(target, direction)
			if(!turf_to_add)
				continue
			affected_turfs += turf_to_add
	for(var/turf/T as anything in affected_turfs)
		new /obj/effect/temp_visual/electricity(T)
		for(var/mob/living/hit_mob in T)
			to_chat(hit_mob, "<span class='userdanger'>You've been struck by lightning!</span>")
			hit_mob.electrocute_act(15 * (isanimal(hit_mob) ? 3 : 1) * (T == target ? 2 : 1) * (boosted ? 2 : 1), src, flags = SHOCK_TESLA|SHOCK_NOSTUN)
			if(ishostile(hit_mob))
				var/mob/living/simple_animal/hostile/H = hit_mob //mobs find and damage you...
				if(H.stat == CONSCIOUS && !H.target && H.AIStatus != AI_OFF && !H.client)
					if(!QDELETED(caster))
						if(get_dist(H, caster) <= H.aggro_vision_range)
							H.FindTarget(list(caster), 1)
						else
							H.Goto(get_turf(caster), H.move_to_delay, 3)

		for(var/obj/hit_thing in T)
			hit_thing.take_damage(20, BURN, ENERGY, FALSE)
	playsound(target, 'sound/magic/lightningbolt.ogg', 100, TRUE)
	target.visible_message(
		"<span class='danger'>A thunderbolt strikes [target]!</span>",
		"<span class='danger'>A thundercrack fills the air!</span>"
	)
	explosion(target, -1, -1, light_impact_range = (boosted ? 1 : 0), flame_range = (boosted ? 2 : 1), silent = TRUE, cause = name)


/obj/effect/temp_visual/thunderbolt_targeting
	icon_state = "target_circle"
	layer = BELOW_MOB_LAYER
	light_range = 1
	duration = 2 SECONDS

/obj/effect/temp_visual/thunderbolt
	icon_state = "thunderbolt"
	icon = 'icons/effects/32x96.dmi'
	duration = 0.6 SECONDS

/obj/effect/temp_visual/electricity
	icon_state = "electricity3"
	duration = 0.5 SECONDS
