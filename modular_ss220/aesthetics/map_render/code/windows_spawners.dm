/**
 * В этом файле, спавнерам окон добавляется переменная со списком предметов,
 * которые она должна спавнить как на ТГ. Но, этот список не будет делать ничего.
 *
 * Зачем же он тогда? Для красивого рендера карт, не больше не меньше.
 * Текущие паровские спавнеры окон, несовместимы с теми которые обрабатывает SDMM.
 * Так же тут добавлены рамки к окнам как отдельный объект, дабы окна выглядели нормально при рендере.
 *
 * ВАЖНО! Если оффы сделают рефактор спавнеров окон как на ТГ, список придётся модифицировать,
 * под использоватье дефайна CBT с ТГ, которого тут тоже нет.
 */
/obj/structure/window/full/frame
	name = "DO NOT USE THIS!!!"
	icon = 'modular_ss220/aesthetics/map_render/icons/window_edges.dmi'
	icon_state = "edge-0"
	base_icon_state = "edge"

/obj/structure/window/full/frame/reinforced
	icon = 'modular_ss220/aesthetics/map_render/icons/reinforced_window_edges.dmi'

// ----- //
/obj/effect/spawner/window
	var/spawn_list = list(/obj/structure/window/full/basic, /obj/structure/window/full/frame)

/obj/effect/spawner/window/grilled
	spawn_list = list(/obj/structure/window/full/basic, /obj/structure/window/full/frame, /obj/structure/grille)

/obj/effect/spawner/window/reinforced
	icon = 'modular_ss220/aesthetics/windows/icons/spawners.dmi'
	spawn_list = list(/obj/structure/window/full/reinforced, /obj/structure/window/full/frame/reinforced)

/obj/effect/spawner/window/reinforced/grilled
	spawn_list = list(/obj/structure/window/full/reinforced, /obj/structure/window/full/frame/reinforced, /obj/structure/grille)

/obj/effect/spawner/window/plasma
	spawn_list = list(/obj/structure/window/full/plasmabasic, /obj/structure/window/full/frame)

/obj/effect/spawner/window/plasma/grilled
	spawn_list = list(/obj/structure/window/full/plasmabasic, /obj/structure/window/full/frame, /obj/structure/grille)

/obj/effect/spawner/window/reinforced/plasma
	spawn_list = list(/obj/structure/window/full/plasmareinforced, /obj/structure/window/full/frame/reinforced)

/obj/effect/spawner/window/reinforced/plasma/grilled
	spawn_list = list(/obj/structure/window/full/plasmareinforced, /obj/structure/window/full/frame/reinforced, /obj/structure/grille)

/obj/effect/spawner/window/reinforced/tinted
	spawn_list = list(/obj/structure/window/full/reinforced/tinted, /obj/structure/window/full/frame/reinforced)

/obj/effect/spawner/window/reinforced/tinted/grilled
	spawn_list = list(/obj/structure/window/full/reinforced/tinted, /obj/structure/window/full/frame/reinforced, /obj/structure/grille)

/obj/effect/spawner/window/reinforced/polarized
	spawn_list = list(/obj/structure/window/full/reinforced, /obj/structure/window/full/frame/reinforced)

/obj/effect/spawner/window/reinforced/polarized/grilled
	spawn_list = list(/obj/structure/window/full/reinforced, /obj/structure/window/full/frame/reinforced, /obj/structure/grille)

/obj/effect/spawner/window/shuttle
	spawn_list = list(/obj/structure/window/full/shuttle, /obj/structure/grille)

/obj/effect/spawner/window/plastitanium
	spawn_list = list(/obj/structure/window/full/plastitanium, /obj/structure/grille)

/obj/effect/spawner/window/shuttle/survival_pod
	spawn_list = list(/obj/structure/window/full/shuttle/survival_pod, /obj/structure/grille)

/obj/effect/spawner/window/shuttle/survival_pod/tinted
	spawn_list = list(/obj/structure/window/full/shuttle/survival_pod/tinted, /obj/structure/grille)
