/datum/species/machine
	speciesbox = /obj/item/storage/box/survival_ipc

// Survival box for IPC
/obj/item/storage/box/survival_ipc
	icon = 'modular_ss220/aesthetics/boxes/icons/boxes.dmi'
	icon_state = "machine_box"

/obj/item/storage/box/survival_ipc/populate_contents()
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil/five(src)
	new /obj/item/flashlight/flare/glowstick/emergency(src)

/obj/machinery/recharger/attackby(obj/item/G, mob/user, params)
	if(istype(G, /obj/item/melee/baton/electrostaff))
		to_chat(user, span_notice("[G] не имеет внешних разъемов для подзарядки."))
		return
	. = ..()
