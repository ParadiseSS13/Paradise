/mob/camera/blob/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/blob_overmind(src)

/obj/screen/blob
	icon = 'icons/mob/blob.dmi'

/obj/screen/blob/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc, theme = "blob")

/obj/screen/blob/MouseExited()
	closeToolTip(usr)

/obj/screen/blob/BlobHelp
	icon_state = "ui_help"
	name = "Ayuda blob"
	desc = "Ayuda para jugar blob!"

/obj/screen/blob/BlobHelp/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/obj/screen/blob/JumpToNode
	icon_state = "ui_tonode"
	name = "Saltar al nodo"
	desc = "Mueve tu camara al nodo seleccionado."

/obj/screen/blob/JumpToNode/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/obj/screen/blob/JumpToCore
	icon_state = "ui_tocore"
	name = "Saltar al nucleo"
	desc = "Mueve tu camara hacia el nucleo."

/obj/screen/blob/JumpToCore/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		name = initial(name)
		desc = initial(desc)
	..()

/obj/screen/blob/JumpToCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.transport_core()

/obj/screen/blob/Blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Producir un Blobbernaut (60)"
	desc = "Produce un fuerte e inteligente blobbernaut de una fabrica blob por 60 recursos.<br>La fabrica de blob sera destruida en el proceso."

/obj/screen/blob/Blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/obj/screen/blob/StorageBlob
	icon_state = "ui_storage"
	name = "Producir un almacen de blob (40)"
	desc = "Produce un almacen de blob por 40 resources.<br>Los almacenes de blob incrementaran tu maximo de blob en 50."

/obj/screen/blob/StorageBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_storage()

/obj/screen/blob/ResourceBlob
	icon_state = "ui_resource"
	name = "Producir una fabrica de blob (40)"
	desc = "Produce una fabrica de blob por 40 recursos.<br>Las fabricas produciran recursos cada 4 segundos."

/obj/screen/blob/ResourceBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_resource()

/obj/screen/blob/NodeBlob
	icon_state = "ui_node"
	name = "Producir un nodo de blob (60)"
	desc = "Produce un nodo de blob por 60 recursos.<br>Los nodos de blob se expandiran y activaran almacenes y fabricas de blob."

/obj/screen/blob/NodeBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_node()

/obj/screen/blob/FactoryBlob
	icon_state = "ui_factory"
	name = "Produce Factory Blob (60)"
	desc = "Produces a factory blob for 60 resources.<br>Factory blobs will produce spores every few seconds."

/obj/screen/blob/FactoryBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_factory()

/obj/screen/blob/ReadaptChemical
	icon_state = "ui_chemswap"
	name = "Readaptar quimico (50)"
	desc = "Cambia tu quimico de manera aleatoria por 50 recursos."

/obj/screen/blob/ReadaptChemical/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		name = initial(name)
		desc = initial(desc)
	..()

/obj/screen/blob/ReadaptChemical/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.chemical_reroll()

/obj/screen/blob/RelocateCore
	icon_state = "ui_swap"
	name = "Reubicar nucleo (80)"
	desc = "Intercambia tu nodo y tu nucleo por 80 recursos."

/obj/screen/blob/RelocateCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()

/obj/screen/blob/Split
	icon_state = "ui_split"
	name = "Dividir consciencia (100)"
	desc = "Crea otra mente de blob en un nodo. Un solo uso.<br>Offspring are unable to use this ability."

/obj/screen/blob/Split/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.split_consciousness()

/datum/hud/blob_overmind/New(mob/user)
	..()
	var/obj/screen/using

	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "poder blob"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blobpwrdisplay.layer = ABOVE_HUD_LAYER
	blobpwrdisplay.plane = ABOVE_HUD_PLANE
	static_inventory += blobpwrdisplay

	blobhealthdisplay = new /obj/screen()
	blobhealthdisplay.name = "salud blob"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = ui_internal
	static_inventory += blobhealthdisplay

	using = new /obj/screen/blob/BlobHelp()
	using.screen_loc = "WEST:6,NORTH:-3"
	static_inventory += using

	using = new /obj/screen/blob/JumpToNode()
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/blob/JumpToCore()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/Blobbernaut()
	using.screen_loc = ui_id
	static_inventory += using

	using = new /obj/screen/blob/StorageBlob()
	using.screen_loc = ui_belt
	static_inventory += using

	using = new /obj/screen/blob/ResourceBlob()
	using.screen_loc = ui_back
	static_inventory += using

	using = new /obj/screen/blob/NodeBlob()
	using.screen_loc = using.screen_loc = ui_rhand
	static_inventory += using

	using = new /obj/screen/blob/FactoryBlob()
	using.screen_loc = using.screen_loc = ui_lhand
	static_inventory += using

	using = new /obj/screen/blob/ReadaptChemical()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /obj/screen/blob/RelocateCore()
	using.screen_loc = ui_storage2
	static_inventory += using

	using = new /obj/screen/blob/Split()
	using.screen_loc = ui_acti
	static_inventory += using
