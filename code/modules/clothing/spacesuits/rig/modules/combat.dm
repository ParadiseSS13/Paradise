/*
 * Contains
 * /obj/item/rig_module/grenade_launcher
 * /obj/item/rig_module/mounted
 * /obj/item/rig_module/mounted/taser
 * /obj/item/rig_module/shield
 * /obj/item/rig_module/fabricator
 * /obj/item/rig_module/device/flash
 */

/obj/item/rig_module/device/flash
	name = "mounted flash"
	desc = "You are the law."
	icon_state = "flash"
	interface_name = "mounted flash"
	interface_desc = "Stuns your target by blinding them with a bright light."
	device_type = /obj/item/flash

/obj/item/rig_module/grenade_launcher

	name = "mounted grenade launcher"
	desc = "A shoulder-mounted micro-explosive dispenser."
	selectable = 1
	icon_state = "grenade"

	interface_name = "integrated grenade launcher"
	interface_desc = "Discharges loaded grenades against the wearer's location."

	var/fire_force = 30
	var/fire_distance = 10

	charges = list(
		list("flashbang",   "flashbang",   /obj/item/grenade/flashbang,  3),
		list("smoke bomb",  "smoke bomb",  /obj/item/grenade/smokebomb,  3),
		list("EMP grenade", "EMP grenade", /obj/item/grenade/empgrenade, 3),
		)

/obj/item/rig_module/grenade_launcher/accepts_item(var/obj/item/input_device, var/mob/living/user)

	if(!istype(input_device) || !istype(user))
		return 0

	var/datum/rig_charge/accepted_item
	for(var/charge in charges)
		var/datum/rig_charge/charge_datum = charges[charge]
		if(input_device.type == charge_datum.product_type)
			accepted_item = charge_datum
			break

	if(!accepted_item)
		return 0

	if(accepted_item.charges >= 5)
		to_chat(user, "<span class='danger'>Another grenade of that type will not fit into the module.</span>")
		return 0

	to_chat(user, "<font color='blue'><b>You slot \the [input_device] into the suit module.</b></font>")
	user.unEquip(input_device)
	qdel(input_device)
	accepted_item.charges++
	return 1

/obj/item/rig_module/grenade_launcher/engage(atom/target)

	if(!..())
		return 0

	if(!target)
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!charge_selected)
		to_chat(H, "<span class='danger'>You have not selected a grenade type.</span>")
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return 0

	if(charge.charges <= 0)
		to_chat(H, "<span class='danger'>Insufficient grenades!</span>")
		return 0

	charge.charges--
	var/obj/item/grenade/new_grenade = new charge.product_type(get_turf(H))
	H.visible_message("<span class='danger'>[H] launches \a [new_grenade]!</span>")
	new_grenade.throw_at(target,fire_force,fire_distance)
	new_grenade.prime()

/obj/item/rig_module/mounted

	name = "mounted laser cannon"
	desc = "A shoulder-mounted battery-powered laser cannon mount."
	selectable = 1
	usable = 1
	module_cooldown = 0
	icon_state = "lcannon"

	engage_string = "Configure"

	interface_name = "mounted laser cannon"
	interface_desc = "A shoulder-mounted cell-powered laser cannon."

	var/gun_type = /obj/item/gun/energy/lasercannon/mounted
	var/obj/item/gun/gun

/obj/item/rig_module/mounted/New()
	..()
	gun = new gun_type(src)

/obj/item/rig_module/mounted/engage(atom/target)

	if(!..())
		return 0

	if(!target)
		gun.attack_self(holder.wearer)
		return 1

	gun.afterattack(target,holder.wearer)
	return 1

/obj/item/rig_module/mounted/egun

	name = "mounted energy gun"
	desc = "A forearm-mounted energy projector."
	icon_state = "egun"

	interface_name = "mounted energy gun"
	interface_desc = "A forearm-mounted suit-powered energy gun."

	gun_type = /obj/item/gun/energy/gun/mounted

/obj/item/rig_module/mounted/taser

	name = "mounted taser"
	desc = "A palm-mounted nonlethal energy projector."
	icon_state = "taser"

	usable = 0

	suit_overlay_active = "mounted-taser"
	suit_overlay_inactive = "mounted-taser"

	interface_name = "mounted energy gun"
	interface_desc = "A shoulder-mounted cell-powered energy gun."

	gun_type = /obj/item/gun/energy/taser/mounted

/obj/item/rig_module/mounted/energy_blade

	name = "energy blade projector"
	desc = "A powerful cutting beam projector."
	icon_state = "eblade"

	activate_string = "Project Blade"
	deactivate_string = "Cancel Blade"

	interface_name = "spider fang blade"
	interface_desc = "A lethal energy projector that can shape a blade projected from the hand of the wearer or launch radioactive darts."

	usable = 0
	selectable = 1
	toggleable = 1
	use_power_cost = 50
	active_power_cost = 10
	passive_power_cost = 0

	gun_type = /obj/item/gun/energy/kinetic_accelerator/crossbow/ninja

/obj/item/rig_module/mounted/energy_blade/process()

	if(holder && holder.wearer)
		if(!(locate(/obj/item/melee/energy/blade) in holder.wearer))
			deactivate()
			return 0

	return ..()

/obj/item/rig_module/mounted/energy_blade/activate()

	..()

	var/mob/living/M = holder.wearer

	if(M.l_hand && M.r_hand)
		to_chat(M, "<span class='danger'>Your hands are full.</span>")
		deactivate()
		return

	var/obj/item/melee/energy/blade/blade = new(M)
	M.put_in_hands(blade)

/obj/item/rig_module/mounted/energy_blade/deactivate()

	..()

	var/mob/living/M = holder.wearer

	if(!M)
		return

	for(var/obj/item/melee/energy/blade/blade in M.contents)
		M.unEquip(blade)
		qdel(blade)

/obj/item/rig_module/fabricator

	name = "matter fabricator"
	desc = "A self-contained microfactory system for hardsuit integration."
	selectable = 1
	usable = 1
	use_power_cost = 15
	icon_state = "enet"

	engage_string = "Fabricate Tile"

	interface_name = "death blossom launcher"
	interface_desc = "An integrated microfactory that produces floor tiles from thin air and electricity."

	var/fabrication_type = /obj/item/stack/tile/plasteel
	var/fire_force = 30
	var/fire_distance = 10

/obj/item/rig_module/fabricator/engage(atom/target)

	if(!..())
		return 0

	var/mob/living/H = holder.wearer

	if(target)
		var/obj/item/firing = new fabrication_type()
		firing.forceMove(get_turf(src))
		H.visible_message("<span class='danger'>[H] launches \a [firing]!</span>")
		firing.throw_at(target,fire_force,fire_distance)
	else
		if(H.l_hand && H.r_hand)
			to_chat(H, "<span class='danger'>Your hands are full.</span>")
		else
			var/obj/item/new_weapon = new fabrication_type()
			new_weapon.forceMove(H)
			to_chat(H, "<font color='blue'><b>You quickly fabricate \a [new_weapon].</b></font>")
			H.put_in_hands(new_weapon)

	return 1
