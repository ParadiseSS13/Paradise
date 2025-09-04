/atom/movable/screen/blob
	icon = 'icons/mob/blob.dmi'

/atom/movable/screen/blob/MouseEntered(location, control, params)
	. = ..()
	openToolTip(usr,src,params,title = name,content = desc, theme = "blob")

/atom/movable/screen/blob/MouseExited()
	closeToolTip(usr)
	return ..()

/atom/movable/screen/blob/blob_help
	icon_state = "ui_help"
	name = "Blob Help"
	desc = "Help on playing blob!"

/atom/movable/screen/blob/blob_help/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/atom/movable/screen/blob/jump_to_node
	icon_state = "ui_tonode"
	name = "Jump to Node"
	desc = "Moves your camera to a selected blob node."

/atom/movable/screen/blob/jump_to_node/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/atom/movable/screen/blob/jump_to_core
	icon_state = "ui_tocore"
	name = "Jump to Core"
	desc = "Moves your camera to your blob core."

/atom/movable/screen/blob/jump_to_core/MouseEntered(location, control, params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		name = initial(name)
		desc = initial(desc)
	return ..()

/atom/movable/screen/blob/jump_to_core/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.transport_core()

/atom/movable/screen/blob/blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Produce Blobbernaut (60)"
	desc = "Produces a strong, intelligent blobbernaut from a factory blob for 60 resources.<br>The factory blob will be destroyed in the process."

/atom/movable/screen/blob/blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/atom/movable/screen/blob/storage_blob
	icon_state = "ui_storage"
	name = "Produce Storage Blob (40)"
	desc = "Produces a storage blob for 40 resources.<br>Storage blobs will raise your max resource cap by 50."

/atom/movable/screen/blob/storage_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_storage()

/atom/movable/screen/blob/resource_blob
	icon_state = "ui_resource"
	name = "Produce Resource Blob (40)"
	desc = "Produces a resource blob for 40 resources.<br>Resource blobs will give you resources every few seconds."

/atom/movable/screen/blob/resource_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_resource()

/atom/movable/screen/blob/node_blob
	icon_state = "ui_node"
	name = "Produce Node Blob (60)"
	desc = "Produces a node blob for 60 resources.<br>Node blobs will expand and activate nearby resource and factory blobs."

/atom/movable/screen/blob/node_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_node()

/atom/movable/screen/blob/factory_blob
	icon_state = "ui_factory"
	name = "Produce Factory Blob (60)"
	desc = "Produces a factory blob for 60 resources.<br>Factory blobs will produce spores every few seconds."

/atom/movable/screen/blob/factory_blob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_factory()

/atom/movable/screen/blob/readapt_chemical
	icon_state = "ui_chemswap"
	name = "Readapt Chemical (50)"
	desc = "Randomly rerolls your chemical for 50 resources."

/atom/movable/screen/blob/readapt_chemical/MouseEntered(location, control, params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		name = initial(name)
		desc = initial(desc)
	return ..()

/atom/movable/screen/blob/readapt_chemical/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.chemical_reroll()

/atom/movable/screen/blob/relocate_core
	icon_state = "ui_swap"
	name = "Relocate Core (80)"
	desc = "Swaps a node and your core for 80 resources."

/atom/movable/screen/blob/relocate_core/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()

/atom/movable/screen/blob/split
	icon_state = "ui_split"
	name = "Split consciousness (100)"
	desc = "Creates another Blob Overmind at the targeted node. One use only.<br>Offspring are unable to use this ability."

/atom/movable/screen/blob/split/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.split_consciousness()
		if(B.split_used) // Destroys split proc if the split is succesfully used
			qdel(src)

/datum/hud/blob_overmind/New(mob/user)
	..()
	var/atom/movable/screen/using

	blobpwrdisplay = new /atom/movable/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = UI_HEALTH
	blobpwrdisplay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blobpwrdisplay.layer = ABOVE_HUD_LAYER
	blobpwrdisplay.plane = ABOVE_HUD_PLANE
	static_inventory += blobpwrdisplay

	blobhealthdisplay = new /atom/movable/screen()
	blobhealthdisplay.name = "blob health"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = UI_INTERNAL
	static_inventory += blobhealthdisplay

	using = new /atom/movable/screen/blob/blob_help()
	using.screen_loc = "WEST:6,NORTH:-3"
	static_inventory += using

	using = new /atom/movable/screen/blob/jump_to_node()
	using.screen_loc = UI_INVENTORY
	static_inventory += using

	using = new /atom/movable/screen/blob/jump_to_core()
	using.screen_loc = UI_ZONESEL
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/blobbernaut()
	using.screen_loc = UI_ID
	static_inventory += using

	using = new /atom/movable/screen/blob/storage_blob()
	using.screen_loc = UI_BELT
	static_inventory += using

	using = new /atom/movable/screen/blob/resource_blob()
	using.screen_loc = UI_BACK
	static_inventory += using

	using = new /atom/movable/screen/blob/node_blob()
	using.screen_loc = using.screen_loc = UI_RHAND
	static_inventory += using

	using = new /atom/movable/screen/blob/factory_blob()
	using.screen_loc = using.screen_loc = UI_LHAND
	static_inventory += using

	using = new /atom/movable/screen/blob/readapt_chemical()
	using.screen_loc = UI_STORAGE1
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/relocate_core()
	using.screen_loc = UI_STORAGE2
	static_inventory += using

	var/mob/camera/blob/B = user
	if(!B.is_offspring && (length(GLOB.clients) >= GLOB.configuration.event.blob_highpop_trigger)) // Checks if the blob is an offspring or below a population value, to not create split button if it is
		using = new /atom/movable/screen/blob/split()
		using.screen_loc = UI_ACTI
		static_inventory += using
