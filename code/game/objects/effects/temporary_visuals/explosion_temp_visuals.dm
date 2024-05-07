/obj/effect/temp_visual/explosion
	name = "boom"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	duration = 10 SECONDS
	/// Smoke wave particle holder
	var/obj/effect/abstract/particle_holder/smoke_wave
	/// Explosion smoke particle holder
	var/obj/effect/abstract/particle_holder/explosion_smoke
	/// Sparks particle holder
	var/obj/effect/abstract/particle_holder/sparks
	/// Debris dirt kickup particle holder
	var/obj/effect/abstract/particle_holder/dirt_kickup
	/// Large dirt kickup particle holder
	var/obj/effect/abstract/particle_holder/large_kickup

/obj/effect/temp_visual/explosion/Initialize(mapload, radius, color, small = FALSE, large = FALSE)
	. = ..()
	set_light(radius, radius, LIGHT_COLOR_ORANGE)
	generate_particles(radius, small, large)
	var/image/I = image(icon, src, icon_state, 10, -32, -32)
	var/matrix/rotate = matrix()
	rotate.Turn(rand(0, 359))
	I.transform = rotate
	overlays += I // We use an overlay so the explosion and light source are both in the correct location plus so the particles don't rotate with the explosion
	icon_state = null

/// Generate the particles
/obj/effect/temp_visual/explosion/proc/generate_particles(radius, small = FALSE, large = FALSE)
	if(small)
		smoke_wave = new(src, /particles/smoke_wave/small)
	else
		smoke_wave = new(src, /particles/smoke_wave)

	if(large)
		explosion_smoke = new(src, /particles/explosion_smoke/deva)
	else if(small)
		explosion_smoke = new(src, /particles/explosion_smoke/small)
	else
		explosion_smoke = new(src, /particles/explosion_smoke)

	dirt_kickup = new(src, /particles/dirt_kickup)
	sparks = new(src, /particles/sparks_outwards)

	if(large)
		large_kickup = new(src, /particles/dirt_kickup_large/deva)
	else
		large_kickup = new(src, /particles/dirt_kickup_large)

	if(large)
		smoke_wave.particles.velocity = generator(GEN_CIRCLE, 6 * radius, 6 * radius)
	else if(small)
		smoke_wave.particles.velocity = generator(GEN_CIRCLE, 3 * radius, 3 * radius)
	else
		smoke_wave.particles.velocity = generator(GEN_CIRCLE, 5 * radius, 5 * radius)

	explosion_smoke.layer = layer + 0.1
	sparks.particles.velocity = generator(GEN_CIRCLE, 8 * radius, 8 * radius)
	addtimer(CALLBACK(src, PROC_REF(set_count_short)), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_count_long)), 8 SECONDS)

/obj/effect/temp_visual/explosion/proc/set_count_short()
	explosion_smoke.particles.count = 0
	sparks.particles.count = 0
	large_kickup.particles.count = 0

/obj/effect/temp_visual/explosion/proc/set_count_long()
	dirt_kickup.particles.count = 0
	smoke_wave.particles.count = 0

/obj/effect/temp_visual/explosion/Destroy()
	QDEL_NULL(smoke_wave)
	QDEL_NULL(explosion_smoke)
	QDEL_NULL(sparks)
	QDEL_NULL(large_kickup)
	QDEL_NULL(dirt_kickup)
	return ..()
