/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	anchored = 1

/obj/effect/decal/cleanable/ash/New()
	..()
	reagents.add_reagent("ash", 10)

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "dirt"
	mouse_opacity = 0

/obj/effect/decal/cleanable/dirt/blackpowder
	name = "black powder"
	mouse_opacity = 1
	noscoop = 1

/obj/effect/decal/cleanable/dirt/blackpowder/New()
	..()
	reagents.add_reagent("blackpowder", 40) //size 2 explosion when activated

/obj/effect/decal/cleanable/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"

/obj/effect/decal/cleanable/flour/foam
	name = "Fire fighting foam"
	desc = "It's foam."
	color = "#EBEBEB"

	New()
		..()
		spawn(150)// 15 seconds
			qdel(src)

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	light_range = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

	New()
		..()
		spawn(1200)// 2 minutes
			qdel(src)

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb1"
	burntime = 1

/obj/effect/decal/cleanable/cobweb/fire_act()
	qdel(src)

/obj/effect/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/obj/chemical.dmi'
	icon_state = "molten"

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb2"

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	noclear = 1

/obj/effect/decal/cleanable/vomit/New()
	..()
	reagents.add_reagent("vomit", 5)


/obj/effect/decal/cleanable/vomit/green
	name = "green vomit"
	desc = "It's all gummy. Ew."
	icon_state = "gvomit_1"
	random_icon_states = list("gvomit_1", "gvomit_2", "gvomit_3", "gvomit_4")

/obj/effect/decal/cleanable/vomit/green/New()
	..()
	reagents.remove_reagent("vomit", 5)
	reagents.add_reagent("green_vomit", 5)

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_pie")

/obj/effect/decal/cleanable/fruit_smudge
	name = "smudge"
	desc = "Some kind of fruit smear."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")

/obj/effect/decal/cleanable/fungus
	name = "space fungus"
	desc = "A fungal growth. Looks pretty nasty."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"
	color = "#D5820B"

/obj/effect/decal/cleanable/fungus/New()
	..()
	reagents.add_reagent("fungus", 10)

/obj/effect/decal/cleanable/confetti //PARTY TIME!
	name = "confetti"
	desc = "Party time!"
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "confetti1"
	random_icon_states = list("confetti1", "confetti2", "confetti3")
	anchored = 1


