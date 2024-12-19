//Beam Datum and effect
/datum/beam
	var/atom/origin = null
	var/atom/target = null
	var/list/elements = list()
	var/icon/base_icon = null
	var/icon
	var/icon_state = "" //icon state of the main segments of the beam
	var/max_distance = 0
	var/endtime = 0
	var/sleep_time = 3
	var/finished = FALSE
	var/target_oldloc = null
	var/origin_oldloc = null
	var/static_beam = FALSE
	var/beam_type = /obj/effect/ebeam //must be subtype
	var/beamcolor

/datum/beam/New(beam_origin, beam_target,beam_icon = 'icons/effects/beam.dmi', beam_icon_state = "b_beam", time = 50, maxdistance = 10, btype = /obj/effect/ebeam, beam_sleep_time = 3, beam_color)
	endtime = world.time+time
	origin = beam_origin
	origin_oldloc =	get_turf(origin)
	target = beam_target
	target_oldloc = get_turf(target)
	sleep_time = beam_sleep_time
	if(origin_oldloc == origin && target_oldloc == target)
		static_beam = TRUE
	max_distance = maxdistance
	base_icon = new(beam_icon,beam_icon_state)
	icon = beam_icon
	icon_state = beam_icon_state
	beam_type = btype
	beamcolor = beam_color

/datum/beam/proc/Start()
	Draw()
	while(!finished && origin && target && world.time < endtime && get_dist(origin,target)<max_distance && origin.z == target.z)
		var/origin_turf = get_turf(origin)
		var/target_turf = get_turf(target)
		if(!static_beam && (origin_turf != origin_oldloc || target_turf != target_oldloc))
			origin_oldloc = origin_turf //so we don't keep checking against their initial positions, leading to endless Reset()+Draw() calls
			target_oldloc = target_turf
			Reset()
			Draw()
		sleep(sleep_time)

	qdel(src)

/datum/beam/proc/End()
	finished = TRUE

/datum/beam/proc/Reset()
	QDEL_LIST_CONTENTS(elements)

/datum/beam/Destroy()
	Reset()
	target = null
	origin = null
	return ..()

/datum/beam/proc/Draw()
	var/Angle = round(get_angle(origin, target))

	var/matrix/rot_matrix = matrix()
	rot_matrix.Turn(Angle)

	//Translation vector for origin and target
	var/DX = (32*target.x+target.pixel_x)-(32*origin.x+origin.pixel_x)
	var/DY = (32*target.y+target.pixel_y)-(32*origin.y+origin.pixel_y)
	var/N = 0
	var/length = round(sqrt((DX)**2+(DY)**2)) //hypotenuse of the triangle formed by target and origin's displacement

	for(N in 0 to length-1 step 32)//-1 as we want < not <=, but we want the speed of X in Y to Z and step X
		var/obj/effect/ebeam/X = new beam_type(origin_oldloc)
		X.owner = src
		elements |= X

		//Assign icon, for main segments it's base_icon, for the end, it's icon+icon_state
		//cropped by a transparent box of length-N pixel size
		if(N+32>length)
			var/icon/II = new(icon, icon_state)
			II.DrawBox(null, 1, (length-N), 32, 32)
			X.icon = II
		else
			X.icon = base_icon
		if(beamcolor)
			X.color = beamcolor
		X.transform = rot_matrix

		//Calculate pixel offsets (If necessary)
		var/Pixel_x
		var/Pixel_y
		if(DX == 0)
			Pixel_x = 0
		else
			Pixel_x = round(sin(Angle)+32*sin(Angle)*(N+16)/32)
		if(DY == 0)
			Pixel_y = 0
		else
			Pixel_y = round(cos(Angle)+32*cos(Angle)*(N+16)/32)

		//Position the effect so the beam is one continous line
		var/a
		if(abs(Pixel_x)>32)
			a = Pixel_x > 0 ? round(Pixel_x/32) : CEILING(Pixel_x/32, 1)
			X.x += a
			Pixel_x %= 32
		if(abs(Pixel_y)>32)
			a = Pixel_y > 0 ? round(Pixel_y/32) : CEILING(Pixel_y/32, 1)
			X.y += a
			Pixel_y %= 32

		X.pixel_x = Pixel_x
		X.pixel_y = Pixel_y

/obj/effect/ebeam
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	var/datum/beam/owner

/obj/effect/ebeam/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/ebeam/proc/on_atom_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER // ON_ATOM_ENTERED
	return

/obj/effect/ebeam/ex_act(severity)
	return

/obj/effect/ebeam/Destroy()
	owner = null
	return ..()

/obj/effect/ebeam/singularity_pull()
	return

/obj/effect/ebeam/singularity_act()
	return

/obj/effect/ebeam/deadly/on_atom_entered(datum/source, atom/movable/entered)
	entered.ex_act(EXPLODE_DEVASTATE)

/obj/effect/ebeam/vetus/Destroy()
	for(var/mob/living/M in get_turf(src))
		M.electrocute_act(20, "the giant arc", flags = SHOCK_NOGLOVES) //fuck your gloves.
	return ..()

/obj/effect/ebeam/disintegration_telegraph
	alpha = 100
	layer = ON_EDGED_TURF_LAYER

/obj/effect/ebeam/disintegration
	layer = ON_EDGED_TURF_LAYER

/obj/effect/ebeam/disintegration/on_atom_entered(datum/source, atom/movable/entered)
	if(!isliving(entered))
		return
	var/mob/living/L = entered
	var/damage = 50
	if(L.stat == DEAD)
		visible_message("<span class='danger'>[L] is disintegrated by the beam!</span>")
		L.dust()
	if(isliving(owner.origin))
		var/mob/living/O = owner.origin
		if(faction_check(O.faction, L.faction, FALSE))
			return
		damage = 70 - ((O.health / O.maxHealth) * 20)
	playsound(L,'sound/weapons/sear.ogg', 50, TRUE, -4)
	to_chat(L, "<span class='userdanger'>You're struck by a disintegration laser!</span>")
	var/limb_to_hit = L.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
	var/armor = L.run_armor_check(limb_to_hit, LASER)
	L.apply_damage(damage, BURN, limb_to_hit, armor)

/atom/proc/Beam(atom/BeamTarget, icon_state="b_beam", icon='icons/effects/beam.dmi', time = 5 SECONDS, maxdistance = 10, beam_type = /obj/effect/ebeam, beam_sleep_time = 3, beam_color)
	var/datum/beam/newbeam = new(src, BeamTarget, icon, icon_state, time, maxdistance, beam_type, beam_sleep_time, beam_color)
	INVOKE_ASYNC(newbeam, TYPE_PROC_REF(/datum/beam, Start))
	return newbeam
