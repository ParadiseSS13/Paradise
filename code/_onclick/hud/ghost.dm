/mob/dead/observer/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/ghost(src)

/obj/screen/ghost
	icon = 'icons/mob/screen_ghost.dmi'

/obj/screen/ghost/MouseEntered()
	flick(icon_state + "_anim", src)

/obj/screen/ghost/jumptomob
	name = "Jump to mob"
	icon_state = "jumptomob"

/obj/screen/ghost/jumptomob/Click()
	var/mob/dead/observer/G = usr
	G.jumptomob()

/obj/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/obj/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()

/obj/screen/ghost/reenter_corpse
	name = "Re-enter corpse"
	icon_state = "reenter_corpse"

/obj/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/obj/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"

/obj/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/obj/screen/ghost/respawn_list
	name = "Ghost spawns"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "template"

/obj/screen/ghost/respawn_list/Initialize(mapload)
	. = ..()
	update_hidden_state()

/obj/screen/ghost/respawn_list/Click()
	var/client/C = hud.mymob.client
	hud.inventory_shown = !hud.inventory_shown
	if(hud.inventory_shown)
		C.screen += hud.toggleable_inventory
	else
		C.screen -= hud.toggleable_inventory
	update_hidden_state()

/obj/screen/ghost/respawn_list/proc/update_hidden_state()
	var/matrix/M = matrix(transform)
	M.Turn(-90)

	overlays.Cut()
	var/image/img = image('icons/mob/actions/actions.dmi', src, (hud && hud.inventory_shown) ? "hide" : "show")
	img.transform = M
	overlays += img

/obj/screen/ghost/respawn_mob
	name = "Mob spawners"
	icon_state = "mob_spawner"

/obj/screen/ghost/respawn_mob/Click()
	var/mob/dead/observer/G = usr
	G.open_spawners_menu()

/obj/screen/ghost/respawn_pai
	name = "Configure pAI"
	icon_state = "pai"

/obj/screen/ghost/respawn_pai/Click()
	var/mob/dead/observer/G = usr
	if(!GLOB.paiController.check_recruit(G))
		to_chat(G, "<span class='warning'>You are not eligible to become a pAI.</span>")
		return
	GLOB.paiController.recruitWindow(G)

/datum/hud/ghost
	inventory_shown = FALSE

/datum/hud/ghost/New(mob/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/ghost/jumptomob()
	using.screen_loc = ui_ghost_jumptomob
	static_inventory += using

	using = new /obj/screen/ghost/orbit()
	using.screen_loc = ui_ghost_orbit
	static_inventory += using

	using = new /obj/screen/ghost/reenter_corpse()
	using.screen_loc = ui_ghost_reenter_corpse
	static_inventory += using

	using = new /obj/screen/ghost/teleport()
	using.screen_loc = ui_ghost_teleport
	static_inventory += using
	static_inventory += using

	using = new /obj/screen/ghost/respawn_list()
	using.screen_loc = ui_ghost_respawn_list
	static_inventory += using

	using = new /obj/screen/ghost/respawn_mob()
	using.screen_loc = ui_ghost_respawn_mob
	toggleable_inventory += using

	using = new /obj/screen/ghost/respawn_pai()
	using.screen_loc = ui_ghost_respawn_pai
	toggleable_inventory += using

	for(var/obj/screen/S in (static_inventory + toggleable_inventory))
		S.hud = src

/datum/hud/ghost/show_hud()
	mymob.client.screen = list()
	mymob.client.screen += static_inventory
	..()
