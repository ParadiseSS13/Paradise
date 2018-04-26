/*
 * Contains
 * /obj/item/rig_module/stealth_field
 * /obj/item/rig_module/teleporter
 * /obj/item/rig_module/fabricator/energy_net
 * /obj/item/rig_module/self_destruct
 */

/obj/item/rig_module/stealth_field

	name = "active camouflage module"
	desc = "A robust hardsuit-integrated stealth module."
	icon_state = "cloak"

	toggleable = 1
	disruptable = 1
	disruptive = 0

	use_power_cost = 50
	active_power_cost = 10
	passive_power_cost = 0
	module_cooldown = 30

	activate_string = "Enable Cloak"
	deactivate_string = "Disable Cloak"

	interface_name = "integrated stealth system"
	interface_desc = "An integrated active camouflage system."

	suit_overlay_active =   "stealth_active"
	suit_overlay_inactive = "stealth_inactive"

/obj/item/rig_module/stealth_field/activate()

	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	to_chat(H, "<font color='blue'><b>You are now invisible to normal detection.</b></font>")
	H.invisibility = INVISIBILITY_LEVEL_TWO

	H.visible_message("[H.name] vanishes into thin air!",1)

/obj/item/rig_module/stealth_field/deactivate()

	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	to_chat(H, "<span class='danger'>You are now visible.</span>")
	H.invisibility = 0

	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(H), H.dir)

	for(var/mob/O in oviewers(H))
		O.show_message("[H.name] appears from thin air!",1)
	playsound(get_turf(H), 'sound/effects/stealthoff.ogg', 75, 1)


/obj/item/rig_module/teleporter

	name = "teleportation module"
	desc = "A complex, sleek-looking, hardsuit-integrated teleportation module."
	icon_state = "teleporter"
	use_power_cost = 40
	redundant = 1
	usable = 1
	selectable = 1

	engage_string = "Emergency Leap"

	interface_name = "VOID-shift phase projector"
	interface_desc = "An advanced teleportation system. It is capable of pinpoint precision or random leaps forward."

/obj/item/rig_module/teleporter/proc/phase_in(var/mob/M,var/turf/T)

	if(!M || !T)
		return

	holder.spark_system.start()
	playsound(T, 'sound/effects/phasein.ogg', 25, 1)
	playsound(T, 'sound/effects/sparks2.ogg', 50, 1)
	new /obj/effect/temp_visual/dir_setting/ninja/phase(T, M.dir)

/obj/item/rig_module/teleporter/proc/phase_out(var/mob/M,var/turf/T)

	if(!M || !T)
		return

	playsound(T, "sparks", 50, 1)
	new /obj/effect/temp_visual/dir_setting/ninja/phase/out(T, M.dir)

/obj/item/rig_module/teleporter/engage(var/atom/target, var/notify_ai)

	if(!..()) return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!istype(H.loc, /turf))
		to_chat(H, "<span class='warning'>You cannot teleport out of your current location.</span>")
		return 0

	var/turf/T
	if(target)
		T = get_turf(target)
	else
		T = get_teleport_loc(get_turf(H), H, rand(5, 9))

	/*if(!T || T.density)
		to_chat(H, "<span class='warning'>You cannot teleport into solid walls.</span>")
		return 0*///Who the fuck cares? Ninjas in walls are cool.

	if(!is_teleport_allowed(T.z))
		to_chat(H, "<span class='warning'>You cannot use your teleporter on this Z-level.</span>")
		return 0

	phase_out(H,get_turf(H))
	H.forceMove(T)
	phase_in(H,get_turf(H))

	for(var/obj/item/grab/G in H.contents)
		if(G.affecting)
			phase_out(G.affecting,get_turf(G.affecting))
			G.affecting.forceMove(locate(T.x+rand(-1,1),T.y+rand(-1,1),T.z))
			phase_in(G.affecting,get_turf(G.affecting))

	return 1

/*
/obj/item/rig_module/fabricator/energy_net

	name = "net projector"
	desc = "Some kind of complex energy projector with a hardsuit mount."
	icon_state = "enet"

	interface_name = "energy net launcher"
	interface_desc = "An advanced energy-patterning projector used to capture targets."

	engage_string = "Fabricate Net"

	fabrication_type = /obj/item/energy_net
	use_power_cost = 70

/obj/item/rig_module/fabricator/energy_net/engage(atom/target)

	if(holder && holder.wearer)
		if(..(target) && target)
			holder.wearer.Beam(target,"n_beam",,10)
		return 1
	return 0*/

/obj/item/rig_module/self_destruct

	name = "self-destruct module"
	desc = "Oh my God, Captain. A bomb."
	icon_state = "deadman"
	usable = 1
	active = 1
	permanent = 1

	engage_string = "Detonate"

	interface_name = "dead man's switch"
	interface_desc = "An integrated self-destruct module. When the wearer dies, so does the surrounding area. Do not press this button."

/obj/item/rig_module/self_destruct/activate()
	return

/obj/item/rig_module/self_destruct/deactivate()
	return

/obj/item/rig_module/self_destruct/process()

	// Not being worn, leave it alone.
	if(!holder || !holder.wearer || !holder.wearer.wear_suit == holder)
		return 0

	//OH SHIT.
	if(holder.wearer.stat == 2)
		engage()

/obj/item/rig_module/self_destruct/engage()
	explosion(get_turf(src), 1, 2, 4, 5)
	if(holder && holder.wearer)
		holder.wearer.unEquip(src)
		qdel(holder)
	qdel(src)

/obj/item/rig_module/self_destruct/small/engage()
	explosion(get_turf(src), 0, 0, 3, 4)
	if(holder && holder.wearer)
		holder.wearer.unEquip(src)
		qdel(holder)
	qdel(src)
