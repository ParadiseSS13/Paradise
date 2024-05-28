/datum/map_template/ruin/bridge
	prefix = "_maps/map_files/RandomRuins/LavaRuins/chasm_bridges/"
	ci_exclude = /datum/map_template/ruin/bridge

/datum/map_template/ruin/bridge/horizontal
	ci_exclude = /datum/map_template/ruin/bridge/horizontal

/datum/map_template/ruin/bridge/horizontal/one
	name = "Horizontal Bridge One"
	suffix = "lavaland_bridge_horizontal_1.dmm"

/datum/map_template/ruin/bridge/horizontal/two
	name = "Horizontal Bridge Two"
	suffix = "lavaland_bridge_horizontal_2.dmm"

/datum/map_template/ruin/bridge/horizontal/three
	name = "Horizontal Bridge Three"
	suffix = "lavaland_bridge_horizontal_3.dmm"

/datum/map_template/ruin/bridge/horizontal/four
	name = "Horizontal Bridge Four"
	suffix = "lavaland_bridge_horizontal_4.dmm"

/datum/map_template/ruin/bridge/horizontal/five
	name = "Horizontal Bridge Five"
	suffix = "lavaland_bridge_horizontal_5.dmm"

/datum/map_template/ruin/bridge/horizontal/six
	name = "Horizontal Bridge Six"
	suffix = "lavaland_bridge_horizontal_6.dmm"

/datum/map_template/ruin/bridge/vertical
	ci_exclude = /datum/map_template/ruin/bridge/vertical

/datum/map_template/ruin/bridge/vertical/one
	name = "Vertical Bridge One"
	suffix = "lavaland_bridge_vertical_1.dmm"

/datum/map_template/ruin/bridge/vertical/two
	name = "Vertical Bridge Two"
	suffix = "lavaland_bridge_vertical_2.dmm"

/datum/map_template/ruin/bridge/vertical/three
	name = "Vertical Bridge Three"
	suffix = "lavaland_bridge_vertical_3.dmm"

/datum/map_template/ruin/bridge/vertical/four
	name = "Vertical Bridge Four"
	suffix = "lavaland_bridge_vertical_4.dmm"

/datum/map_template/ruin/bridge/vertical/five
	name = "Vertical Bridge Five"
	suffix = "lavaland_bridge_vertical_5.dmm"

/datum/map_template/ruin/bridge/vertical/six
	name = "Vertical Bridge Six"
	suffix = "lavaland_bridge_vertical_6.dmm"

/obj/effect/spawner/bridge
	name = "Bridge spawner"
	var/datum/map_template/ruin/bridge/template

/obj/effect/spawner/bridge/Initialize(mapload)
	. = ..()
	SSlate_mapping.bridge_spawners += src

/obj/effect/spawner/bridge/Destroy()
	SSlate_mapping.bridge_spawners -= src
	return ..()

/obj/effect/spawner/bridge/proc/generate_bridge()
	var/turf/east = locate(x + 3, y, z)
	var/turf/west = locate(x - 3, y, z)
	var/turf/north = locate(x, y + 3, z)
	var/turf/south = locate(x, y - 3, z)
	var/turf/e1 = locate(x + 1, y, z)
	var/turf/w1 = locate(x - 1, y, z)
	var/turf/n1 = locate(x, y + 1, z)
	var/turf/s1 = locate(x, y - 1, z)


	if((ismineralturf(east) || istype(east, /turf/simulated/floor/plating/asteroid)) && (ismineralturf(west) || istype(west, /turf/simulated/floor/plating/asteroid)) && !(ismineralturf(n1) || istype(n1, /turf/simulated/floor/plating/asteroid)) && !(ismineralturf(s1) || istype(s1, /turf/simulated/floor/plating/asteroid)))
		template = GLOB.bridge_horizontal_templates[pick("lavaland_bridge_horizontal_1.dmm", "lavaland_bridge_horizontal_2.dmm", "lavaland_bridge_horizontal_3.dmm", "lavaland_bridge_horizontal_4.dmm", "lavaland_bridge_horizontal_5.dmm", "lavaland_bridge_horizontal_6.dmm")]
		template.load(loc, centered = TRUE)
	else if((ismineralturf(north) || istype(north, /turf/simulated/floor/plating/asteroid)) && (ismineralturf(south) || istype(south, /turf/simulated/floor/plating/asteroid)) && !(ismineralturf(e1) || istype(e1, /turf/simulated/floor/plating/asteroid)) && !(ismineralturf(w1) || istype(w1, /turf/simulated/floor/plating/asteroid)))
		template = GLOB.bridge_vertical_templates[pick("lavaland_bridge_vertical_1.dmm", "lavaland_bridge_vertical_2.dmm", "lavaland_bridge_vertical_3.dmm", "lavaland_bridge_vertical_4.dmm", "lavaland_bridge_vertical_5.dmm", "lavaland_bridge_vertical_6.dmm")]
		template.load(loc, centered = TRUE)
