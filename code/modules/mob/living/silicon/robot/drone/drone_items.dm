//Simple borg hand.
//Limited use.
/obj/item/gripper
	name = "magnetic gripper"
	desc = "A simple grasping tool for synthetic assets."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	//Has a list of items that it can hold.
	var/list/can_hold = list(
		/obj/item/stock_parts/cell,
		/obj/item/firealarm_electronics,
		/obj/item/airalarm_electronics,
		/obj/item/airlock_electronics,
		/obj/item/firelock_electronics,
		/obj/item/intercom_electronics,
		/obj/item/apc_electronics,
		/obj/item/tracker_electronics,
		/obj/item/stock_parts,
		/obj/item/vending_refill,
		/obj/item/mounted/frame/light_fixture,
		/obj/item/mounted/frame/apc_frame,
		/obj/item/mounted/frame/alarm_frame,
		/obj/item/mounted/frame/firealarm,
		/obj/item/mounted/frame/newscaster_frame,
		/obj/item/mounted/frame/intercom,
		/obj/item/rack_parts,
		/obj/item/camera_assembly,
		/obj/item/tank,
		/obj/item/circuitboard,
		/obj/item/stack/tile/light,
		/obj/item/stack/ore/bluespace_crystal
		)

	//Item currently being held.
	var/obj/item/wrapped = null

/obj/item/gripper/paperwork
	name = "paperwork gripper"
	desc = "A simple grasping tool for clerical work."

	can_hold = list(
		/obj/item/clipboard,
		/obj/item/paper,
		/obj/item/card/id
		)

/obj/item/gripper/medical
	name = "medical gripper"
	desc = "A grasping tool used to help patients up once surgery is complete."
	can_hold = list()

/obj/item/gripper/medical/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, proximity, params)
	var/mob/living/carbon/human/H
	if(!wrapped && proximity && target && ishuman(target))
		H = target
		if(H.lying)
			H.AdjustSleeping(-5)
			if(H.sleeping == 0)
				H.StopResting()
			H.AdjustParalysis(-3)
			H.AdjustStunned(-3)
			H.AdjustWeakened(-3)
			playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			user.visible_message( \
				"<span class='notice'>[user] shakes [H] trying to wake [H.p_them()] up!</span>",\
				"<span class='notice'>You shake [H] trying to wake [H.p_them()] up!</span>",\
				)

/obj/item/gripper/New()
	..()
	can_hold = typecacheof(can_hold)

/obj/item/gripper/attack_self(mob/user as mob)
	if(wrapped)
		wrapped.attack_self(user)

/obj/item/gripper/verb/drop_item()

	set name = "Drop Gripped Item"
	set desc = "Release an item from your magnetic gripper."
	set category = "Drone"

	drop_item_p()

// The "p" stands for proc, since I was having annoying weird stuff happening with this in the verb
// when trying to have default values for arguments and stuff
/obj/item/gripper/proc/drop_item_p(var/silent = 0)

	if(!wrapped)
		//There's some weirdness with items being lost inside the arm. Trying to fix all cases. ~Z
		for(var/obj/item/thing in src.contents)
			thing.forceMove(get_turf(src))
		return

	if(wrapped.loc != src)
		wrapped = null
		return

	if(!silent)
		to_chat(src.loc, "<span class='warning'>You drop \the [wrapped].</span>")
	wrapped.forceMove(get_turf(src))
	wrapped = null

/obj/item/gripper/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	return

/obj/item/gripper/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, proximity, params)

	if(!target || !proximity) //Target is invalid or we are not adjacent.
		return

	//There's some weirdness with items being lost inside the arm. Trying to fix all cases. ~Z
	if(!wrapped)
		for(var/obj/item/thing in src.contents)
			wrapped = thing
			break

	if(wrapped) //Already have an item.

		//Temporary put wrapped into user so target's attackby() checks pass.
		wrapped.forceMove(user)

		//Pass the attack on to the target. This might delete/relocate wrapped.
		if(!target.attackby(wrapped, user, params) && target && wrapped)
			// If the attackby didn't resolve or delete the target or wrapped, afterattack
			// (Certain things, such as mountable frames, rely on afterattack)
			wrapped.afterattack(target, user, 1, params)

		//If wrapped did neither get deleted nor put into target, put it back into the gripper.
		if(wrapped && user && (wrapped.loc == user))
			wrapped.forceMove(src)
		else
			wrapped = null
			return

	else if(istype(target,/obj/item)) //Check that we're not pocketing a mob.

		//...and that the item is not in a container.
		if(!isturf(target.loc))
			return

		var/obj/item/I = target

		//Check if the item is blacklisted.
		var/grab = 0
		if(can_hold.len)
			if(is_type_in_typecache(I, can_hold))
				grab = 1

		//We can grab the item, finally.
		if(grab)
			to_chat(user, "You collect \the [I].")
			I.forceMove(src)
			wrapped = I
			return
		else
			to_chat(user, "<span class='warning'>Your gripper cannot hold \the [target].</span>")

	else if(istype(target,/obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(A.opened)
			if(A.cell)

				wrapped = A.cell

				A.cell.add_fingerprint(user)
				A.cell.update_icon()
				A.cell.forceMove(src)
				A.cell = null

				A.charging = 0
				A.update_icon()

				user.visible_message("<span class='warning'>[user] removes the power cell from [A]!</span>", "You remove the power cell.")

//TODO: Matter decompiler.
/obj/item/matter_decompiler

	name = "matter decompiler"
	desc = "Eating trash, bits of glass, or other debris will replenish your stores."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minigibber"

	//Metal, glass, wood, plastic.
	var/list/stored_comms = list(
		"metal" = 0,
		"glass" = 0,
		"wood" = 0,
		"plastic" = 0
		)

/obj/item/matter_decompiler/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	return

/obj/item/matter_decompiler/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, proximity, params)

	if(!proximity) return //Not adjacent.

	//We only want to deal with using this on turfs. Specific items aren't important.
	var/turf/T = get_turf(target)
	if(!istype(T))
		return

	//Used to give the right message.
	var/grabbed_something = 0

	for(var/mob/M in T)
		if(istype(M,/mob/living/simple_animal/lizard) || istype(M,/mob/living/simple_animal/mouse))
			src.loc.visible_message("<span class='notice'>[src.loc] sucks [M] into its decompiler. There's a horrible crunching noise.</span>","<span class='warning'>It's a bit of a struggle, but you manage to suck [M] into your decompiler. It makes a series of visceral crunching noises.</span>")
			new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
			qdel(M)
			stored_comms["wood"]++
			stored_comms["wood"]++
			stored_comms["plastic"]++
			stored_comms["plastic"]++
			return

		else if(istype(M,/mob/living/silicon/robot/drone) && !M.client)

			var/mob/living/silicon/robot/drone/D = src.loc

			if(!istype(D))
				return

			to_chat(D, "<span class='warning'>You begin decompiling the other drone.</span>")

			if(!do_after(D, 50, target = target))
				to_chat(D, "<span class='warning'>You need to remain still while decompiling such a large object.</span>")
				return

			if(!M || !D) return

			to_chat(D, "<span class='warning'>You carefully and thoroughly decompile your downed fellow, storing as much of its resources as you can within yourself.</span>")

			qdel(M)
			new/obj/effect/decal/cleanable/blood/oil(get_turf(src))

			stored_comms["metal"] += 15
			stored_comms["glass"] += 15
			stored_comms["wood"] += 5
			stored_comms["plastic"] += 5

			return
		else
			continue

	for(var/obj/W in T)
		//Different classes of items give different commodities.
		if(istype(W,/obj/item/cigbutt))
			stored_comms["plastic"]++
		else if(istype(W,/obj/structure/spider/spiderling))
			stored_comms["wood"]++
			stored_comms["wood"]++
			stored_comms["plastic"]++
			stored_comms["plastic"]++
		else if(istype(W,/obj/item/light))
			var/obj/item/light/L = W
			if(L.status >= 2) //In before someone changes the inexplicably local defines. ~ Z
				stored_comms["metal"]++
				stored_comms["glass"]++
			else
				continue
		else if(istype(W,/obj/effect/decal/remains/robot))
			stored_comms["metal"]++
			stored_comms["metal"]++
			stored_comms["plastic"]++
			stored_comms["plastic"]++
			stored_comms["glass"]++
		else if(istype(W,/obj/item/trash))
			stored_comms["metal"]++
			stored_comms["plastic"]++
			stored_comms["plastic"]++
		else if(istype(W,/obj/effect/decal/cleanable/blood/gibs/robot))
			stored_comms["metal"]++
			stored_comms["metal"]++
			stored_comms["glass"]++
			stored_comms["glass"]++
		else if(istype(W,/obj/item/ammo_casing))
			stored_comms["metal"]++
		else if(istype(W,/obj/item/shard))
			stored_comms["glass"]++
			stored_comms["glass"]++
			stored_comms["glass"]++
		else if(istype(W,/obj/item/reagent_containers/food/snacks/grown))
			stored_comms["wood"]++
			stored_comms["wood"]++
			stored_comms["wood"]++
			stored_comms["wood"]++
		else if(istype(W,/obj/item/broken_bottle))
			stored_comms["glass"]++
			stored_comms["glass"]++
			stored_comms["glass"]++
		else if(istype(W,/obj/item/light/tube) || istype(W,/obj/item/light/bulb))
			stored_comms["glass"]++
		else
			continue

		qdel(W)
		grabbed_something = 1

	if(grabbed_something)
		to_chat(user, "<span class='notice'>You deploy your decompiler and clear out the contents of \the [T].</span>")
	else
		to_chat(user, "<span class='warning'>Nothing on \the [T] is useful to you.</span>")
	return

//PRETTIER TOOL LIST.
/mob/living/silicon/robot/drone/installed_modules()

	if(weapon_lock)
		to_chat(src, "<span class='warning'>Weapon lock active, unable to use modules! Count:[weaponlock_time]</span>")
		return

	if(!module)
		module = new /obj/item/robot_module/drone(src)

	var/dat = "<HEAD><TITLE>Drone modules</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += {"<A HREF='?src=[UID()];mach_close=robotmod'>Close</A>
	<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=[UID()];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=[UID()];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=[UID()];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	var/tools = "<B>Tools and devices</B><BR>"
	var/resources = "<BR><B>Resources</B><BR>"

	for(var/O in module.modules)

		var/module_string = ""

		if(!O)
			module_string += text("<B>Resource depleted</B><BR>")
		else if(activated(O))
			module_string += text("[O]: <B>Activated</B><BR>")
		else
			module_string += text("[O]: <A HREF=?src=[UID()];act=\ref[O]>Activate</A><BR>")

		if((istype(O,/obj/item) || istype(O,/obj/item)) && !(istype(O,/obj/item/stack/cable_coil)))
			tools += module_string
		else
			resources += module_string

	dat += tools

	if(emagged)
		if(!module.emag)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=[UID()];act=\ref[module.emag]>Activate</A><BR>")

	dat += resources

	src << browse(dat, "window=robotmod&can_close=0")

//Putting the decompiler here to avoid doing list checks every tick.
/mob/living/silicon/robot/drone/use_power()

	..()
	if(low_power_mode || !decompiler)
		return

	//The decompiler replenishes drone stores from hoovered-up junk each tick.
	for(var/type in decompiler.stored_comms)
		if(decompiler.stored_comms[type] > 0)
			var/obj/item/stack/sheet/stack
			switch(type)
				if("metal")
					if(!stack_metal)
						stack_metal = new /obj/item/stack/sheet/metal/cyborg(src.module)
						stack_metal.amount = 1
					stack = stack_metal
				if("glass")
					if(!stack_glass)
						stack_glass = new /obj/item/stack/sheet/glass/cyborg(src.module)
						stack_glass.amount = 1
					stack = stack_glass
				if("wood")
					if(!stack_wood)
						stack_wood = new /obj/item/stack/sheet/wood(src.module)
						stack_wood.amount = 1
					stack = stack_wood
				if("plastic")
					if(!stack_plastic)
						stack_plastic = new /obj/item/stack/sheet/plastic(src.module)
						stack_plastic.amount = 1
					stack = stack_plastic

			stack.amount++
			decompiler.stored_comms[type]--
