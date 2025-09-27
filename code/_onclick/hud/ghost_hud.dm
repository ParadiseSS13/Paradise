/atom/movable/screen/ghost
	icon = 'icons/mob/screen_ghost.dmi'

/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/atom/movable/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()

/atom/movable/screen/ghost/reenter_corpse
	name = "Re-enter corpse"
	icon_state = "reenter_corpse"

/atom/movable/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/ghost/reenter_corpse/MouseEntered()
	. = ..()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/respawn_char
	name = "Respawn as new character"
	icon_state = "respawn"

/atom/movable/screen/ghost/respawn_char/Click()
	var/mob/dead/observer/G = usr
	G.respawn_character()

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"

/atom/movable/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/atom/movable/screen/ghost/respawn_list
	name = "Ghost spawns"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "template"

/atom/movable/screen/ghost/respawn_list/Initialize(mapload)
	. = ..()
	update_hidden_state()

/atom/movable/screen/ghost/respawn_list/Click()
	var/client/C = hud.mymob.client
	hud.inventory_shown = !hud.inventory_shown
	if(hud.inventory_shown)
		C.screen += hud.toggleable_inventory
	else
		C.screen -= hud.toggleable_inventory
	update_hidden_state()

/atom/movable/screen/ghost/respawn_list/proc/update_hidden_state()
	var/matrix/M = matrix(transform)
	M.Turn(-90)

	overlays.Cut()
	var/image/img = image('icons/mob/actions/actions.dmi', src, (hud && hud.inventory_shown) ? "hide" : "show")
	img.transform = M
	overlays += img

/atom/movable/screen/ghost/respawn_mob
	name = "Mob spawners"
	icon_state = "mob_spawner"

/atom/movable/screen/ghost/respawn_mob/Click()
	var/mob/dead/observer/G = usr
	G.open_spawners_menu()

/atom/movable/screen/ghost/respawn_pai
	name = "Configure pAI"
	icon_state = "pai"

/atom/movable/screen/ghost/respawn_pai/Click()
	var/mob/dead/observer/G = usr
	if(!GLOB.paiController.check_recruit(G))
		to_chat(G, "<span class='warning'>You are not eligible to become a pAI.</span>")
		return
	GLOB.paiController.recruitWindow(G)

/datum/hud/ghost
	inventory_shown = FALSE

/datum/hud/ghost/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/ghost/respawn_char()
	using.screen_loc = UI_GHOST_RESPAWN_CHAR
	static_inventory += using

	using = new /atom/movable/screen/ghost/orbit()
	using.screen_loc = UI_GHOST_ORBIT
	static_inventory += using

	using = new /atom/movable/screen/ghost/reenter_corpse()
	using.screen_loc = UI_GHOST_REENTER_CORPSE
	static_inventory += using

	using = new /atom/movable/screen/ghost/teleport()
	using.screen_loc = UI_GHOST_TELEPORT
	static_inventory += using
	static_inventory += using

	using = new /atom/movable/screen/ghost/respawn_list()
	using.screen_loc = UI_GHOST_RESPAWN_LIST
	static_inventory += using

	using = new /atom/movable/screen/ghost/respawn_mob()
	using.screen_loc = UI_GHOST_RESPAWN_MOB
	toggleable_inventory += using

	using = new /atom/movable/screen/ghost/respawn_pai()
	using.screen_loc = UI_GHOST_RESPAWN_PAI
	toggleable_inventory += using

	for(var/atom/movable/screen/S in (static_inventory + toggleable_inventory))
		S.hud = src

/datum/hud/ghost/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if(istype(O) && O.mob_observed)
		plane_masters_update()
		return FALSE

	return ..()

// We should only see observed mob alerts.
/datum/hud/ghost/reorganize_alerts(mob/viewmob)
	var/mob/dead/observer/O = mymob
	if(istype(O) && O.mob_observed)
		return
	return ..()

