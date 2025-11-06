// Telegun for Tator RDs

/obj/item/gun/energy/telegun
	name = "teleporter gun"
	desc = "An extremely high-tech energy gun that utilizes jury-rigged bluespace technology to teleport away living targets."
	icon_state = "telegun"
	inhand_icon_state = "telegun"
	origin_tech = "combat=6;materials=7;powerstorage=5;bluespace=5;syndicate=4"
	ammo_type = list(/obj/item/ammo_casing/energy/teleport)
	shaded_charge = TRUE
	var/teleport_target = null

/obj/item/gun/energy/telegun/Destroy()
	teleport_target = null
	return ..()

/obj/item/gun/energy/telegun/attack_self__legacy__attackchain(mob/living/user)
	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/beacon/R in GLOB.beacons)
		var/turf/T = get_turf(R)
		var/turf/M = get_turf(user)
		if(!T)
			continue
		if(!is_teleport_allowed(T.z))
			continue
		if(T.z != M.z && !R.emagged)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	var/desc = tgui_input_list(user, "Please select a location to lock in.", "Telegun Target Selection", L)
	if(!desc)
		return
	teleport_target = L[desc]
	to_chat(user, "<span class='notice'>The [src] is now set to [desc].</span>")
	//Process the shot without draining the cell
	if(chambered)
		if(chambered.BB)
			qdel(chambered.BB)
			chambered.BB = null
		chambered = null
	newshot()

/obj/item/gun/energy/telegun/newshot()
	var/obj/item/ammo_casing/energy/teleport/T = ammo_type[select]
	T.teleport_target = teleport_target
	..()
