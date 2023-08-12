
/particles/electrical_sparks
    width = 500
    height = 500
    count = 2500
    spawning = 15
    bound1 = list(-1000, -48, -1000)
    gravity = list(-1,-10)
    friction = 0.3
    color = COLOR_YELLOW
    gradient = list(COLOR_YELLOW, COLOR_ORANGE)
    color_change = 0.005
    lifespan = 1.5 SECONDS
    drift = 5 // generator("box", list(-32, 32), list(0, 96))
    velocity = list(10, 25)

/obj/particle_emitter
	appearance_flags = PIXEL_SCALE
	plane = -1

//generator
/// "square", 15, 0 - good spark effect

//velocity
/// y should always be 5-10
/// x should be +/- 3-8

//friction
/// .1 WiLD spread
/// .2 crazy spread
/// .3 normal spread
/// .4 light spread
/obj/particle_emitter/electrical_sparks
	icon = null
	particles = new /particles/electrical_sparks

/proc/electricity_sparks(atom/src_atom, test1, gradient, duration, count)
	return
	/*var/obj/particle_emitter/electrical_sparks/sparks_emitter = new /obj/particle_emitter/electrical_sparks(get_turf(src_atom))
	sparks_emitter.particles.count = count
	sparks_emitter.particles.gradient = gradient
	sleep(duration)
	var/wait_time = sparks_emitter.particles.lifespan
	sparks_emitter.particles.lifespan = 0
	sleep(wait_time)
	QDEL_NULL(sparks_emitter.particles)
	qdel(sparks_emitter)*/


