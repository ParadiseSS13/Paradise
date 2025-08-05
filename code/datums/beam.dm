/** # Beam Datum and Effect
 * **IF YOU ARE LAZY AND DO NOT WANT TO READ, GO TO THE BOTTOM OF THE FILE AND USE THAT PROC!**
 *
 * This is the beam datum! It's a really neat effect for the game in drawing a line from one atom to another.
 * It has two parts:
 * The datum itself which manages redrawing the beam to constantly keep it pointing from the origin to the target.
 * The effect which is what the beams are made out of. They're placed in a line from the origin to target, rotated towards the target and snipped off at the end.
 * These effects are kept in a list and constantly created and destroyed (hence the proc names draw and reset, reset destroying all effects and draw creating more.)
 *
 * You can add more special effects to the beam itself by changing what the drawn beam effects do. For example you can make a vine that pricks people by making the beam_type
 * include a crossed proc that damages the crosser. Examples in venus_human_trap.dm
*/
/datum/beam
	///where the beam goes from
	var/atom/origin = null
	///where the beam goes to
	var/atom/target = null
	///list of beam objects. These have their visuals set by the visuals var which is created on starting
	var/list/elements = list()
	///icon used by the beam.
	var/icon
	///icon state of the main segments of the beam
	var/icon_state = ""
	///The beam will qdel if it's longer than this many tiles.
	var/max_distance = 0
	///the objects placed in the elements list
	var/beam_type = /obj/effect/ebeam
	///This is used as the visual_contents of beams, so you can apply one effect to this and the whole beam will look like that. never gets deleted on redrawing.
	var/obj/effect/ebeam/visuals
	///The color of the beam we're drawing.
	var/beam_color
	///Should we use a turf for origin/target's x and y values instead
	var/use_get_turf

/datum/beam/New(
	origin,
	target,
	icon = 'icons/effects/beam.dmi',
	icon_state = "b_beam",
	time = INFINITY,
	max_distance = INFINITY,
	beam_type = /obj/effect/ebeam,
	beam_color,
	use_get_turf = FALSE
)
	src.origin = origin
	src.target = target
	src.icon = icon
	src.icon_state = icon_state
	src.max_distance = max_distance
	src.beam_type = beam_type
	src.beam_color = beam_color
	src.use_get_turf = use_get_turf
	if(time < INFINITY)
		QDEL_IN(src, time)

/**
 * Proc called by the atom Beam() proc. Sets up signals, and draws the beam for the first time.
 */
/datum/beam/proc/Start()
	visuals = new beam_type()
	visuals.icon = icon
	visuals.icon_state = icon_state
	visuals.color = beam_color
	visuals.vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_LAYER
	visuals.update_appearance()
	Draw()
	RegisterSignal(origin, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING), PROC_REF(redrawing), TRUE)
	RegisterSignal(target, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING), PROC_REF(redrawing), TRUE)

/**
 * Triggered by signals set up when the beam is set up. If it's still sane to create a beam, it removes the old beam, creates a new one. Otherwise it kills the beam.
 *
 * Arguments:
 * mover: either the origin of the beam or the target of the beam that moved.
 * oldloc: from where mover moved.
 * direction: in what direction mover moved from.
 */
/datum/beam/proc/redrawing(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(QDELING(src))
		return
	if(QDELETED(origin) || QDELETED(target) || get_dist(origin,target) > max_distance)
		qdel(src)
		return
	if(origin.z != target.z)
		if(!use_get_turf || !atoms_share_level(get_turf(origin), get_turf(target)))
			qdel(src)
			return
	QDEL_LIST_CONTENTS(elements)
	INVOKE_ASYNC(src, PROC_REF(Draw))

/datum/beam/Destroy()
	QDEL_LIST_CONTENTS(elements)
	QDEL_NULL(visuals)
	UnregisterSignal(origin, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	UnregisterSignal(target, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	origin = null
	target = null
	return ..()

/**
 * Creates the beam effects and places them in a line from the origin to the target. Sets their rotation to make the beams face the target, too.
 */
/datum/beam/proc/Draw()
	var/origin_px = origin.pixel_x + origin.pixel_w
	var/origin_py = origin.pixel_y + origin.pixel_z
	var/target_px = target.pixel_x + target.pixel_w
	var/target_py = target.pixel_y + target.pixel_z

	var/origin_x = origin.x
	var/origin_y = origin.y
	var/target_x = target.x
	var/target_y = target.y
	if(use_get_turf)
		var/turf/T = get_turf(origin)
		origin_x = T.x
		origin_y = T.y
		T = get_turf(target)
		target_x = T.x
		target_y = T.y

	var/Angle = get_angle_raw(origin_x, origin_y, origin_px, origin_py, target_x, target_y, target_px, target_py)
	///var/Angle = round(get_angle(origin,target))
	var/matrix/rot_matrix = matrix()
	var/turf/origin_turf = get_turf(origin)
	rot_matrix.Turn(Angle)

	//Translation vector for origin and target
	var/DX = (32 * target_x + target_px) - (32 * origin_x + origin_px)
	var/DY = (32 * target_y + target_py) - (32 * origin_y + origin_py)
	var/N = 0
	var/length = round(sqrt((DX)**2 + (DY)**2)) // hypotenuse of the triangle formed by target and origin's displacement

	for(N in 0 to length-1 step 32) // -1 as we want < not <=, but we want the speed of X in Y to Z and step X
		if(QDELETED(src))
			break
		var/obj/effect/ebeam/segment = new beam_type(origin_turf, src)
		elements += segment

		//Assign our single visual ebeam to each ebeam's vis_contents
		//ends are cropped by a transparent box icon of length-N pixel size laid over the visuals obj
		if(N + 32 > length) //went past the target, we draw a box of space to cut away from the beam sprite so the icon actually ends at the center of the target sprite
			var/icon/II = new(icon, icon_state)//this means we exclude the overshooting object from the visual contents which does mean those visuals don't show up for the final bit of the beam...
			II.DrawBox(null, 1, (length-N), 32, 32)//in the future if you want to improve this, remove the drawbox and instead use a 513 filter to cut away at the final object's icon
			segment.icon = II
			segment.color = beam_color
		else
			segment.vis_contents += visuals
		segment.transform = rot_matrix

		//Calculate pixel offsets (If necessary)
		var/Pixel_x
		var/Pixel_y
		if(DX == 0)
			Pixel_x = 0
		else
			Pixel_x = round(sin(Angle) + 32 * sin(Angle) * (N + 16) / 32)
		if(DY == 0)
			Pixel_y = 0
		else
			Pixel_y = round(cos(Angle) + 32 * cos(Angle) * (N + 16) / 32)

		//Position the effect so the beam is one continous line
		var/final_x = segment.x
		var/final_y = segment.y
		if(abs(Pixel_x) > 32)
			final_x += Pixel_x > 0 ? round(Pixel_x/32) : CEILING(Pixel_x/32, 1)
			Pixel_x %= 32
		if(abs(Pixel_y) > 32)
			final_y += Pixel_y > 0 ? round(Pixel_y/32) : CEILING(Pixel_y/32, 1)
			Pixel_y %= 32

		segment.forceMove(locate(final_x, final_y, segment.z))
		segment.pixel_x = origin_px + Pixel_x
		segment.pixel_y = origin_py + Pixel_y
		CHECK_TICK

/obj/effect/ebeam
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/datum/beam/owner

/obj/effect/ebeam/Initialize(mapload, beam_owner)
	. = ..()
	owner = beam_owner
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/ebeam/Destroy()
	owner = null
	return ..()

/obj/effect/ebeam/proc/on_atom_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER // ON_ATOM_ENTERED
	return

/obj/effect/ebeam/ex_act(severity)
	return

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

/atom/proc/Beam(atom/BeamTarget,
	icon_state = "b_beam",
	icon = 'icons/effects/beam.dmi',
	time = 5 SECONDS,
	maxdistance = 10,
	beam_type = /obj/effect/ebeam,
	beam_color,
	use_get_turf = FALSE
)
	var/datum/beam/newbeam = new(src, BeamTarget, icon, icon_state, time, maxdistance, beam_type, beam_color, use_get_turf)
	INVOKE_ASYNC(newbeam, TYPE_PROC_REF(/datum/beam, Start))
	return newbeam
