/obj/mecha/working/hoverpod
	name = "hover pod"
	icon_state = "engineering_pod"
	desc = "Stubby and round, it has a human sized access hatch on the top."
	wreckage = /obj/effect/decal/mecha_wreckage/hoverpod
	stepsound = 'sound/machines/hiss.ogg'

/obj/mecha/working/hoverpod/Process_Spacemove(var/movement_dir = 0)
	return 1 // puts the hover in hoverpod

/obj/effect/decal/mecha_wreckage/hoverpod
	name = "Hover pod wreckage"
	icon_state = "engineering_pod-broken"
