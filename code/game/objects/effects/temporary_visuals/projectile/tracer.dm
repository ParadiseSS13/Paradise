//These are the visual tracers, the beams you see with hitscan effects. This is the proc that generates said tracer

/proc/generate_tracer_between_points(datum/position/starting, datum/position/ending, beam_type, color, qdel_in = 5, light_range = 2, light_color_override, light_intensity = 1, instance_key) //Do not pass z-crossing points as that will not be properly (and likely will never be properly until it's absolutely needed) supported!
	if(isnull(starting))
		return
	if(isnull(ending))
		return
	if(isnull(beam_type))
		return
	var/datum/position/midpoint = point_midpoint_points(starting, ending)
	var/performance_counter
	for(var/obj/effect/projectile/tracer/counter in midpoint.return_turf())
		performance_counter++
	if(performance_counter >= 3)
		return //Damage still happens, this should stop engineers with looping emitters doing shenanigins that makes the server cry

	var/obj/effect/projectile/tracer/PB = new beam_type
	if(isnull(light_color_override))
		light_color_override = color
	PB.apply_vars(angle_between_points(starting, ending), midpoint.return_px(), midpoint.return_py(), color, pixel_length_between_points(starting, ending) / world.icon_size, midpoint.return_turf(), 0)
	. = PB
	if(light_range > 0 && light_intensity > 0)
		var/list/turf/line = get_line(starting.return_turf(), ending.return_turf())
		tracing_line:
			for(var/i in line)
				var/turf/T = i
				for(var/obj/effect/projectile_lighting/PL in T)
					if(PL.owner == locateUID(instance_key))
						continue tracing_line
				QDEL_IN(new /obj/effect/projectile_lighting(T, light_color_override, light_range, light_intensity, instance_key), qdel_in > 0? qdel_in : 5)
		line = null
	if(qdel_in)
		QDEL_IN(PB, qdel_in)

/obj/effect/projectile/tracer
	name = "beam"
	icon = 'icons/obj/projectiles_tracer.dmi'

/obj/effect/projectile/tracer/laser
	name = "laser"
	icon_state = "beam"

/obj/effect/projectile/tracer/laser/blue
	icon_state = "beam_blue"

/obj/effect/projectile/tracer/disabler
	name = "disabler"
	icon_state = "beam_omni"

/obj/effect/projectile/tracer/xray
	name = "\improper X-ray laser"
	icon_state = "xray"

/obj/effect/projectile/tracer/pulse
	name = "pulse laser"
	icon_state = "u_laser"

/obj/effect/projectile/tracer/plasma_cutter
	name = "plasma blast"
	icon_state = "plasmacutter"

/obj/effect/projectile/tracer/stun
	name = "stun beam"
	icon_state = "stun"

/obj/effect/projectile/tracer/heavy_laser
	name = "heavy laser"
	icon_state = "beam_heavy"

/obj/effect/projectile/tracer/solar
	name = "solar beam"
	icon_state = "solar"

/obj/effect/projectile/tracer/solar/thin
	icon_state = "solar_thin"

/obj/effect/projectile/tracer/solar/thinnest
	icon_state = "solar_thinnest"

//BEAM RIFLE
/obj/effect/projectile/tracer/tracer/beam_rifle
	icon_state = "tracer_beam"

/obj/effect/projectile/tracer/tracer/aiming
	icon_state = "pixelbeam_greyscale"
	plane = ABOVE_LIGHTING_PLANE

/obj/effect/projectile/tracer/wormhole
	icon_state = "wormhole_g"

/obj/effect/projectile/tracer/laser/emitter
	name = "emitter beam"
	icon_state = "emitter"

/obj/effect/projectile/tracer/sniper
	icon_state = "sniper"

/obj/effect/projectile/tracer/death
	icon_state = "hcult"
