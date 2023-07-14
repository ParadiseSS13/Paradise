/obj/item/stack/tile
	name = "broken tile"
	singular_name = "broken tile"
	desc = "A broken tile. This should not exist."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "tile"
	item_state = "tile"
	w_class = WEIGHT_CLASS_NORMAL
	force = 1
	throwforce = 1
	throw_speed = 5
	throw_range = 20
	max_amount = 60
	flags = CONDUCT
	origin_tech = "materials=1"
	var/turf_type = null
	var/mineralType = null

/obj/item/stack/tile/New(loc, amount)
	..()
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3) //randomize a little

/obj/item/stack/tile/welder_act(mob/user, obj/item/I)
	if(get_amount() < 4)
		to_chat(user, "<span class='warning'>You need at least four tiles to do this!</span>")
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		to_chat(user, "<span class='warning'>You can not reform this!</span>")
		return
	if (mineralType == "metal")
		var/obj/item/stack/sheet/metal/new_item = new(user.loc)
		user.visible_message("[user.name] shaped [src] into metal with the welding tool.", \
					"<span class='notice'>You shaped [src] into metal with the welding tool.</span>", \
					"<span class='italics'>You hear welding.</span>")
		var/obj/item/stack/rods/R = src
		src = null
		var/replace = (user.get_inactive_hand()==R)
		R.use(4)
		if(!R && replace)
			user.put_in_hands(new_item)

//Grass
/obj/item/stack/tile/grass
	name = "grass tiles"
	gender = PLURAL
	singular_name = "grass floor tile"
	desc = "A patch of grass like they often use on golf courses."
	icon_state = "tile_grass"
	origin_tech = "biotech=1"
	turf_type = /turf/simulated/floor/grass
	resistance_flags = FLAMMABLE

//Wood
/obj/item/stack/tile/wood
	name = "wood floor tiles"
	gender = PLURAL
	singular_name = "wood floor tile"
	desc = "An easy to fit wood floor tile."
	icon_state = "tile-wood"
	origin_tech = "biotech=1"
	turf_type = /turf/simulated/floor/wood
	merge_type = /obj/item/stack/tile/wood
	resistance_flags = FLAMMABLE

/obj/item/stack/tile/wood/cyborg
	energy_type = /datum/robot_energy_storage/wood_tile
	is_cyborg = TRUE

//Carpets
/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet"
	desc = "A piece of carpet. It is the same size as a floor tile."
	icon_state = "tile-carpet"
	turf_type = /turf/simulated/floor/carpet
	resistance_flags = FLAMMABLE
	table_type = /obj/structure/table/wood/fancy //Decides what table will be built with what carpet tile

/obj/item/stack/tile/carpet/twenty
	amount = 20

/obj/item/stack/tile/carpet/black
	name = "black carpet"
	icon_state = "tile-carpet-black"
	turf_type = /turf/simulated/floor/carpet/black
	table_type = /obj/structure/table/wood/fancy/black

/obj/item/stack/tile/carpet/black/twenty
	amount = 20

/obj/item/stack/tile/carpet/blue
	name = "blue carpet"
	icon_state = "tile-carpet-blue"
	turf_type = /turf/simulated/floor/carpet/blue
	table_type = /obj/structure/table/wood/fancy/blue

/obj/item/stack/tile/carpet/blue/twenty
	amount = 20

/obj/item/stack/tile/carpet/cyan
	name = "cyan carpet"
	icon_state = "tile-carpet-cyan"
	turf_type = /turf/simulated/floor/carpet/cyan
	table_type = /obj/structure/table/wood/fancy/cyan

/obj/item/stack/tile/carpet/cyan/twenty
	amount = 20

/obj/item/stack/tile/carpet/green
	name = "green carpet"
	icon_state = "tile-carpet-green"
	turf_type = /turf/simulated/floor/carpet/green
	table_type = /obj/structure/table/wood/fancy/green

/obj/item/stack/tile/carpet/green/twenty
	amount = 20

/obj/item/stack/tile/carpet/orange
	name = "orange carpet"
	icon_state = "tile-carpet-orange"
	turf_type = /turf/simulated/floor/carpet/orange
	table_type = /obj/structure/table/wood/fancy/orange

/obj/item/stack/tile/carpet/orange/twenty
	amount = 20

/obj/item/stack/tile/carpet/purple
	name = "purple carpet"
	icon_state = "tile-carpet-purple"
	turf_type = /turf/simulated/floor/carpet/purple
	table_type = /obj/structure/table/wood/fancy/purple

/obj/item/stack/tile/carpet/purple/twenty
	amount = 20

/obj/item/stack/tile/carpet/red
	name = "red carpet"
	icon_state = "tile-carpet-red"
	turf_type = /turf/simulated/floor/carpet/red
	table_type = /obj/structure/table/wood/fancy/red

/obj/item/stack/tile/carpet/red/twenty
	amount = 20

/obj/item/stack/tile/carpet/royalblack
	name = "royal black carpet"
	icon_state = "tile-carpet-royalblack"
	turf_type = /turf/simulated/floor/carpet/royalblack
	table_type = /obj/structure/table/wood/fancy/royalblack

/obj/item/stack/tile/carpet/royalblack/ten
	amount = 10
/obj/item/stack/tile/carpet/royalblack/twenty
	amount = 20

/obj/item/stack/tile/carpet/royalblue
	name = "royal blue carpet"
	icon_state = "tile-carpet-royalblue"
	turf_type = /turf/simulated/floor/carpet/royalblue
	table_type = /obj/structure/table/wood/fancy/royalblue

/obj/item/stack/tile/carpet/royalblue/ten
	amount = 10

/obj/item/stack/tile/carpet/royalblue/twenty
	amount = 20

//Plasteel
/obj/item/stack/tile/plasteel
	name = "floor tiles"
	gender = PLURAL
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon."
	icon_state = "tile"
	force = 6
	materials = list(MAT_METAL=500)
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	turf_type = /turf/simulated/floor/plasteel
	mineralType = "metal"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF

/obj/item/stack/tile/plasteel/cyborg
	energy_type = /datum/robot_energy_storage/metal_tile
	is_cyborg = TRUE

//Light
/obj/item/stack/tile/light
	name = "light tiles"
	gender = PLURAL
	singular_name = "light floor tile"
	desc = "A floor tile made of glass, with an integrated light. Use a multitool on it to change its color."
	icon_state = "tile_white"
	force = 3
	throwforce = 5
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	turf_type = /turf/simulated/floor/light

//Fakespace
/obj/item/stack/tile/fakespace
	name = "astral carpet"
	singular_name = "astral carpet"
	desc = "A piece of carpet with a convincing star pattern."
	icon_state = "tile_space"
	turf_type = /turf/simulated/floor/fakespace
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fakespace

/obj/item/stack/tile/fakespace/loaded
	amount = 30

//High-traction
/obj/item/stack/tile/noslip
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip"
	turf_type = /turf/simulated/floor/noslip
	origin_tech = "materials=3"
	merge_type = /obj/item/stack/tile/noslip

/obj/item/stack/tile/noslip/loaded
	amount = 20

//Pod floor
/obj/item/stack/tile/pod
	name = "pod floor tile"
	singular_name = "pod floor tile"
	desc = "A grooved floor tile."
	icon_state = "tile_pod"
	turf_type = /turf/simulated/floor/pod

/obj/item/stack/tile/pod/light
	name = "light pod floor tile"
	singular_name = "light pod floor tile"
	desc = "A lightly colored grooved floor tile."
	icon_state = "tile_podlight"
	turf_type = /turf/simulated/floor/pod

/obj/item/stack/tile/pod/dark
	name = "dark pod floor tile"
	singular_name = "dark pod floor tile"
	desc = "A darkly colored grooved floor tile."
	icon_state = "tile_poddark"
	turf_type = /turf/simulated/floor/pod/dark

/obj/item/stack/tile/arcade_carpet
	name = "arcade carpet"
	singular_name = "arcade carpet"
	desc= "A piece of carpet with a retro spaceship pattern."
	icon_state = "tile_space"
	turf_type = /turf/simulated/floor/carpet/arcade
	merge_type = /obj/item/stack/tile/arcade_carpet
	resistance_flags = FLAMMABLE

/obj/item/stack/tile/arcade_carpet/loaded
	amount = 20

/obj/item/stack/tile/disco_light
	name = "disco light tiles"
	singular_name = "disco light tile"
	desc = "A sheet of disco light tile."
	icon_state = "tile_disco"
	turf_type = /turf/simulated/floor/light/disco
	merge_type = /obj/item/stack/tile/disco_light

/obj/item/stack/tile/disco_light/thirty
	amount = 30

/obj/item/stack/tile/catwalk
	name = "catwalk tiles"
	gender = PLURAL
	singular_name = "catwalk tile"
	desc = "A catwalk tile. Not rated for space usage."
	icon_state = "tile_catwalk"
	force = 6
	materials = list(MAT_METAL=500)
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	turf_type = /turf/simulated/floor/catwalk
	mineralType = "metal"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
