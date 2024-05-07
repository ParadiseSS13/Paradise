/*
	MARK: Impact debris + smoke
*/

/particles/debris
	icon = 'icons/effects/particles/generic_particles.dmi'
	width = 500
	height = 500
	count = 10
	spawning = 10
	lifespan = 0.5 SECONDS
	fade = 0.3 SECONDS
	drift = generator(GEN_CIRCLE, 0, 7)
	scale = 0.3
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.1, 0.15)
	spin = generator(GEN_NUM, -20, 20)

/particles/impact_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 20
	spawning = 20
	lifespan = 0.8 SECONDS
	fade = 10 SECONDS
	grow = 0.1
	scale = 0.2
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.1, 0.5)

/*
	MARK: Explosion smoke
*/

/particles/explosion_smoke
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke3"
	width = 1000
	height = 1000
	count = 75
	spawning = 75
	gradient = list("#FA9632", "#C3630C", "#333333", "#808080", "#FFFFFF")
	lifespan = 3 SECONDS
	fade = 6 SECONDS
	color = generator(GEN_NUM, 0, 0.25)
	color_change = generator(GEN_NUM, 0.04, 0.05)
	velocity = generator(GEN_CIRCLE, 15, 15)
	drift = generator(GEN_CIRCLE, 0, 1, NORMAL_RAND)
	spin = generator(GEN_NUM, -20, 20)
	friction = generator(GEN_NUM, 0.1, 0.5)
	gravity = list(1, 2)
	scale = 0.25
	grow = 0.05

/particles/explosion_smoke/deva
	scale = 0.5
	velocity = generator(GEN_CIRCLE, 23, 23)

/particles/explosion_smoke/small
	count = 25
	spawning = 25
	scale = 0.25
	velocity = generator(GEN_CIRCLE, 10, 10)

/particles/smoke_wave
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke3"
	width = 750
	height = 750
	count = 75
	spawning = 75
	lifespan = 8 SECONDS
	fade = 6 SECONDS
	gradient = list("#BA9F6D", "#808080", "#FFFFFF")
	color = generator(GEN_NUM, 0, 0.25)
	color_change = generator(GEN_NUM, 0.08, 0.07)
	velocity = generator(GEN_CIRCLE, 25, 25)
	rotation = generator(GEN_NUM, -45, 45)
	scale = 0.25
	grow = 0.05
	friction = 0.05

/particles/smoke_wave/small
	count = 45
	spawning = 45
	scale = 0.1

/particles/sparks_outwards
	icon = 'icons/effects/64x64.dmi'
	icon_state = "flare"
	width = 750
	height = 750
	count = 40
	spawning = 20
	lifespan = 2 SECONDS
	fade = 2 SECONDS
	position = generator(GEN_SPHERE, 8, 8)
	velocity = generator(GEN_CIRCLE, 30, 30)
	scale = 0.1
	friction = 0.1

/particles/dirt_kickup
	icon = 'icons/effects/96x157.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 80
	spawning = 10
	lifespan = 5 SECONDS
	fade = 2 SECONDS
	fadein = 3
	scale = generator(GEN_NUM, 0.18, 0.15)
	position = generator(GEN_SPHERE, 150, 150)
	color = COLOR_BROWN
	velocity = list(0, 12)
	grow = list(0, 0.01)
	gravity = list(0, -1.25)

/particles/dirt_kickup_large
	icon = 'icons/effects/96x157.dmi'
	icon_state = "smoke"
	width = 750
	height = 750
	gradient = list("#FA9632", "#C3630C", "#333333", "#808080", "#FFFFFF")
	count = 3
	spawning = 3
	lifespan = 8 SECONDS
	fade = 3 SECONDS
	fadein = 3
	scale = generator(GEN_NUM, 0.5, 1)
	position = generator(GEN_BOX, list(-12, 32), list(12, 48), NORMAL_RAND)
	color = generator(GEN_NUM, 0, 0.25)
	color_change = generator(GEN_NUM, 0.04, 0.05)
	velocity = list(0, 12)
	grow = list(0, 0.025)
	gravity = list(0, -1)

/particles/dirt_kickup_large/deva
	velocity = list(0, 25)
	scale = generator(GEN_NUM, 1, 1.25)
	grow = list(0, 0.03)
	gravity = list(0, -2)
	fade = 1 SECONDS
