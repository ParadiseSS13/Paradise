/obj/effect/decal/remains
	gender = PLURAL

/obj/effect/decal/remains/human
	name = "remains"
	desc = "They look like human remains. They have a strange aura about them."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	anchored = 1

/obj/effect/decal/remains/xeno
	name = "remains"
	desc = "They look like the remains of something... alien. They have a strange aura about them."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remainsxeno"
	anchored = 1

/obj/effect/decal/remains/robot
	name = "remains"
	desc = "They look like the remains of something mechanical. They have a strange aura about them."
	icon = 'icons/mob/robots.dmi'
	icon_state = "remainsrobot"
	anchored = 1

/obj/effect/decal/remains/robot/New()
	..()
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

/obj/effect/decal/remains/slime
	name = "You shouldn't see this"
	desc = "Noooooooooooooooooooooo"
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	anchored = 1

/obj/effect/decal/remains/slime/New()
	..()
	var/datum/reagents/R = new/datum/reagents(5)
	var/obj/effect/effect/water/W = new(get_turf(src))
	W.reagents = R
	R.my_atom = W
	R.add_reagent("water", 5)
	R.reaction(get_turf(src))
	qdel(src)
