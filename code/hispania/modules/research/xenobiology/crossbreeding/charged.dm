/*
Charged extracts:
	Have a unique, effect when filled with
	10u plasma and activated in-hand, related to their
	normal extract effect.
*/
/obj/item/slimecross/charged
	name = "charged extract"
	desc = "It sparks with electric power."
	effect = "charged"
	icon_state = "charged"
	container_type = INJECTABLE

/obj/item/slimecross/charged/Initialize()
	. = ..()
	create_reagents(10, INJECTABLE | DRAWABLE)

/obj/item/slimecross/charged/attack_self(mob/user)
	if(!reagents.has_reagent("plasma_dust",  10))
		to_chat(user, "<span class='warning'>This extract needs to be full of plasma to activate!</span>")
		return
	reagents.remove_reagent("plasma_dust",  10)
	to_chat(user, "<span class='notice'>You squeeze the extract, and it absorbs the plasma!</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	do_effect(user)

/obj/item/slimecross/charged/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/charged/grey
	colour = "grey"
	effect_desc = "Produces a slime reviver potion, which revives dead slimes."

/obj/item/slimecross/charged/grey/do_effect(mob/user)
	new /obj/item/slimepotion/slime_reviver(get_turf(user))
	user.visible_message("<span class='notice'>[src] distills into a potion!</span>")
	..()

/obj/item/slimecross/charged/orange
	colour = "orange"
	effect_desc = "Instantly makes a large burst of flame for a moment."

/obj/item/slimecross/charged/orange/do_effect(mob/user)
	for(var/turf/turf in range(5,get_turf(user)))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)
	..()

/obj/item/slimecross/charged/purple
	colour = "purple"
	effect_desc = "Creates a packet of omnizine."

/obj/item/slimecross/charged/purple/do_effect(mob/user)
	new /obj/item/slimecrossbeaker/omnizine(get_turf(user))
	user.visible_message("<span class='notice'>[src] sparks, and floods with a regenerative solution!</span>")
	..()

/obj/item/slimecross/charged/blue
	colour = "blue"
	effect_desc = "Creates a potion that neuters the mutation chance of a slime, which passes on to new generations."

/obj/item/slimecross/charged/blue/do_effect(mob/user)
	new /obj/item/slimepotion/slime/chargedstabilizer(get_turf(user))
	user.visible_message("<span class='notice'>[src] distills into a potion!</span>")
	..()

/obj/item/slimecross/charged/metal
	colour = "metal"
	effect_desc = "Produces a bunch of metal and plasteel."

/obj/item/slimecross/charged/metal/do_effect(mob/user)
	new /obj/item/stack/sheet/metal(get_turf(user), 25)
	new /obj/item/stack/sheet/plasteel(get_turf(user), 10)
	user.visible_message("<span class='notice'>[src] grows into a plethora of metals!</span>")
	..()

/obj/item/slimecross/charged/yellow
	colour = "yellow"
	effect_desc = "Creates a hypercharged slime cell battery, which has high capacity and recharges constantly at a very fast rate."

/obj/item/slimecross/charged/yellow/do_effect(mob/user)
	new /obj/item/stock_parts/cell/high/slime/hypercharged(get_turf(user))
	user.visible_message("<span class='notice'>[src] sparks violently, and swells with electric power!</span>")
	..()

/obj/item/slimecross/charged/darkpurple
	colour = "dark purple"
	effect_desc = "Creates several sheets of plasma."

/obj/item/slimecross/charged/darkpurple/do_effect(mob/user)
	new /obj/item/stack/sheet/mineral/plasma(get_turf(user), 10)
	user.visible_message("<span class='notice'>[src] produces a large amount of plasma!</span>")
	..()

/obj/item/slimecross/charged/silver
	colour = "silver"
	effect_desc = "Creates a slime cake and some drinks."

/obj/item/slimecross/charged/silver/do_effect(mob/user)
	new /obj/item/reagent_containers/food/snacks/sliceable/cake/slimecake(get_turf(user))
	for(var/i in 1 to 5)
		var/drink_type = get_random_drink()
		new drink_type(get_turf(user))
	user.visible_message("<span class='notice'>[src] produces a party's worth of cake and drinks!</span>")
	..()

/obj/item/slimecross/charged/bluespace
	colour = "bluespace"
	effect_desc = "Makes a bluespace polycrystal."

/obj/item/slimecross/charged/bluespace/do_effect(mob/user)
	new /obj/item/stack/sheet/bluespace_crystal(get_turf(user), 10)
	user.visible_message("<span class='notice'>[src] produces several sheets of polycrystal!</span>")
	..()

/obj/item/slimecross/charged/sepia
	colour = "sepia"
	effect_desc = "Creates a camera obscura."

/obj/item/slimecross/charged/sepia/do_effect(mob/user)
	new /obj/item/camera/spooky(get_turf(user))
	user.visible_message("<span class='notice'>[src] flickers in a strange, ethereal manner, and produces a camera!</span>")
	..()

/obj/item/slimecross/charged/cerulean
	colour = "cerulean"
	effect_desc = "Creates an extract enhancer, giving whatever it's used on five more uses."

/obj/item/slimecross/charged/cerulean/do_effect(mob/user)
	new /obj/item/slimepotion/enhancer/max(get_turf(user))
	user.visible_message("<span class='notice'>[src] distills into a potion!</span>")
	..()

/obj/item/slimecross/charged/pyrite
	colour = "pyrite"
	effect_desc = "Creates bananium. Oh no."

/obj/item/slimecross/charged/pyrite/do_effect(mob/user)
	new /obj/item/stack/sheet/mineral/bananium(get_turf(user), 10)
	user.visible_message("<span class='warning'>[src] solidifies with a horrifying banana stench!</span>")
	..()

/obj/item/slimecross/charged/oil
	colour = "oil"
	effect_desc = "Creates an explosion after a few seconds."

/obj/item/slimecross/charged/oil/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] begins to shake with rapidly increasing force!</span>")
	addtimer(CALLBACK(src, .proc/boom), 50)

/obj/item/slimecross/charged/oil/proc/boom()
	explosion(get_turf(src), 2, 3, 4) //Much smaller effect than normal oils, but devastatingly strong where it does hit.
	qdel(src)

/obj/item/slimecross/charged/adamantine
	colour = "adamantine"
	effect_desc = "Creates a completed golem shell."

/obj/item/slimecross/charged/adamantine/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] produces a fully formed golem shell!</span>")
	new /obj/effect/mob_spawn/human/golem/servant(get_turf(src), /datum/species/golem/adamantine, user)
	..()

/obj/item/slimecross/charged/rainbow
	colour = "rainbow"
	effect_desc = "Produces three living slimes of random colors."

/obj/item/slimecross/charged/rainbow/do_effect(mob/user)
	user.visible_message("<span class='warning'>[src] swells and splits into three new slimes!</span>")
	for(var/i in 1 to 3)
		var/mob/living/simple_animal/slime/S = new(get_turf(user))
		S.random_colour()
	..()
