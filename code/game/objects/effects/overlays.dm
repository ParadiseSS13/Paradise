
/obj/effect/overlay
	name = "overlay"
	unacidable = 1
	var/i_attached//Added for possible image attachments to objects. For hallucinations and the like.

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull()
	return

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	var/tmp/atom/BeamSource
	New()
		..()
		spawn(10) qdel(src)


/obj/effect/overlay/temp
	anchored = 1
	layer = 4.1
	mouse_opacity = 0
	var/duration = 10
	var/randomdir = 1

/obj/effect/overlay/temp/New()
	if(randomdir)
		dir = pick(cardinal)
	spawn(duration)
		qdel(src)

/obj/effect/overlay/temp/revenant
	name = "spooky lights"
	icon = 'icons/effects/effects.dmi'
	icon_state = "purplesparkles"

/obj/effect/overlay/temp/revenant/cracks
	name = "glowing cracks"
	icon_state = "purplecrack"
	duration = 6

/obj/effect/overlay/temp/guardian
	randomdir = 0

/obj/effect/overlay/temp/guardian/phase
	duration = 5
	icon_state = "phasein"

/obj/effect/overlay/temp/guardian/phase/out
	icon_state = "phaseout"

/obj/effect/overlay/temp/emp
	name = "emp sparks"
	icon = 'icons/effects/effects.dmi'
	icon_state = "empdisable"

/obj/effect/overlay/temp/emp/pulse
	name = "emp pulse"
	icon_state = "emp pulse"
	duration = 8
	randomdir = 0

/obj/effect/overlay/temp/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = 4.1
	duration = 4

/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"

/obj/effect/overlay/adminoverlay
	name = "adminoverlay"
	icon = 'icons/effects/effects.dmi'
	icon_state = "admin"
	layer = 4.1
