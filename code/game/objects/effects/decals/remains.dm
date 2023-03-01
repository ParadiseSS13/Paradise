/obj/effect/decal/remains
	gender = PLURAL

/obj/effect/decal/remains/acid_act()
	visible_message("<span class='warning'>[src] dissolve[gender==PLURAL?"":"s"] into a puddle of sizzling goop!</span>")
	playsound(src, 'sound/items/welder.ogg', 150, TRUE)
	new /obj/effect/decal/cleanable/greenglow(drop_location())
	qdel(src)

/obj/effect/decal/remains/human
	name = "remains"
	desc = "They look like human remains. They have a strange aura about them."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	anchored = TRUE

/obj/effect/decal/remains/xeno
	name = "remains"
	desc = "They look like the remains of something... alien. They have a strange aura about them."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remainsxeno"
	anchored = TRUE

/obj/effect/decal/remains/robot
	name = "remains"
	desc = "They look like the remains of something mechanical. They have a strange aura about them."
	icon = 'icons/effects/robot.dmi'
	icon_state = "remainsrobot"
	anchored = TRUE

/obj/effect/decal/remains/robot/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["glass"] += 2
	C.stored_comms["metal"] += 3
	qdel(src)
	return TRUE

/obj/effect/decal/remains/slime
	name = "You shouldn't see this"
	desc = "Noooooooooooooooooooooo"
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	anchored = TRUE

/obj/effect/decal/remains/slime/New()
	..()
	var/datum/reagents/R = new/datum/reagents(5)
	var/obj/effect/particle_effect/water/W = new(get_turf(src))
	W.reagents = R
	R.my_atom = W
	R.add_reagent("water", 5)
	R.reaction(get_turf(src))
	qdel(src)

/obj/effect/decal/remains/mouse
	name = "remains"
	desc = "Некогда бывшая мышь. Её останки. Больше не будет пищать..."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_skeleton"
	anchored = FALSE
	move_resist = MOVE_FORCE_EXTREMELY_WEAK

/obj/effect/decal/remains/mouse/water_act(volume, temperature, source, method)
	. = ..()
