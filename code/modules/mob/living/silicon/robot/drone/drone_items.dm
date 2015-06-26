//Simple borg hand.
//Limited use.
/obj/item/weapon/gripper
	name = "magnetic gripper"
	desc = "A simple grasping tool for synthetic assets."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	//Has a list of items that it can hold.
	var/list/can_hold = list(
		/obj/item/weapon/stock_parts/cell,
		/obj/item/weapon/firealarm_electronics,
		/obj/item/weapon/airalarm_electronics,
		/obj/item/weapon/airlock_electronics,
		/obj/item/weapon/module/power_control,
		/obj/item/weapon/stock_parts,
		/obj/item/mounted/frame/light_fixture,
		/obj/item/mounted/frame/apc_frame,
		/obj/item/mounted/frame/alarm_frame,
		/obj/item/mounted/frame/firealarm,
		/obj/item/mounted/frame/newscaster_frame,
		/obj/item/mounted/frame/intercom,
		/obj/item/weapon/table_parts,
		/obj/item/weapon/rack_parts,
		/obj/item/weapon/camera_assembly,
		/obj/item/weapon/tank,
		/obj/item/weapon/circuitboard
		)

	//Item currently being held.
	var/obj/item/wrapped = null

/obj/item/weapon/gripper/paperwork
	name = "paperwork gripper"
	desc = "A simple grasping tool for clerical work."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	can_hold = list(
		/obj/item/weapon/clipboard,
		/obj/item/weapon/paper,
//		/obj/item/weapon/paper_bundle,
		/obj/item/weapon/card/id
		)

//Med Borg Medical Gripper
/obj/item/weapon/gripper/medical
	name = "Medical Gripper"
	desc = "A specialized manipulator for organs, iv-bags, pills, patches, viral samples, vials, and other medical assets."
	icon = 'icons/obj/device.dmi'
	icon_state = "medgripper"

	//Has a list of items that it can hold.
	can_hold = list(
		/obj/item/organ, //surgery
		/obj/item/weapon/reagent_containers/blood, //i-v bags for surgery
		/obj/item/weapon/reagent_containers/pill, //pills & patches for treatment
		/obj/item/weapon/reagent_containers/food, //treatment & monkey cubes
		/obj/item/weapon/reagent_containers/glass/beaker/vial, //virology
		/obj/item/weapon/dnainjector, //genetics; for applying clean injectors
		/obj/item/clothing/mask/breath, //breath masks for anesthetic
		/obj/item/weapon/tank, //tanks handling to apply oxygen and anesthetic to patients
		/obj/item/weapon/disk, //virology & genetics
		/obj/item/weapon/implant, //surgery
		/obj/item/weapon/virusdish, //virology
		/obj/item/weapon/storage/box,//Medical supply retrieval; pills, bodybags, monkey cubes for genetics/virology.
		/obj/item/weapon/storage/firstaid, //Medical supply retrieval.
		/obj/item/stack/sheet/biomass, //biomass; mainly for supplying the cloner
		/obj/item/bodybag //morgue
		)

/obj/item/weapon/gripper/attack_self(mob/user as mob)
	if(istype(wrapped,/obj/item/weapon/storage))//Allow grippers that can carry containers to empty them
		var/obj/item/weapon/storage/W = wrapped
		if(W.contents.len >= 1)
			var/response = sd_Alert(user,"Empty this container?","Empty Container?",list("Yes","No"))
			if(response == "Yes")
				var/turf/T = get_turf(user)
				for(var/obj/item/I in wrapped)
					W.remove_from_storage(I, T)
					user << "\red You empty the [wrapped]."
			if(response == "No")
				return

		else
			user << "\red The [wrapped] is empty."
	else if (wrapped)
		wrapped.attack_self(user)
	else
		return


/obj/item/weapon/gripper/verb/drop_item()

	set name = "Drop Item"
	set desc = "Release an item from your magnetic gripper."
	set category = "Robot Commands"

	if(!wrapped)
		//There's some weirdness with items being lost inside the arm. Trying to fix all cases. ~Z
		for(var/obj/item/thing in src.contents)
			thing.loc = get_turf(src)
		return

	if(wrapped.loc != src)
		wrapped = null
		return

	src.loc << "\red You drop \the [wrapped]."
	wrapped.loc = get_turf(src)
	wrapped = null
	//update_icon()

/obj/item/weapon/gripper/attack(mob/living/carbon/C as mob)
	//Medical Grippers can shape people awake
	if(istype(src,/obj/item/weapon/gripper/medical))
		//Med Gripper must be empty
		if(!wrapped)
			switch(C.a_intent)
				if ("help")
					var/mob/living/silicon/R = src.loc
					//R << "DEBUG: /obj/item/weapon/gripper/attack | Gripper: [src] | Target: [C] | User: [R]" //Debug
					R.help_shake_act(C, R)
	return

/obj/item/weapon/gripper/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, proximity, params)

	if(!target || !proximity) //Target is invalid or we are not adjacent.
		return

	//There's some weirdness with items being lost inside the arm. Trying to fix all cases. ~Z
	if(!wrapped)
		for(var/obj/item/thing in src.contents)
			wrapped = thing
			break

	if(wrapped) //Already have an item.

		//Temporary put wrapped into user so target's attackby() checks pass.
		wrapped.loc = user

		//Pass the attack on to the target. This might delete/relocate wrapped.
		if(!target.attackby(wrapped, user, params) && target && wrapped)
			// If the attackby didn't resolve or delete the target or wrapped, afterattack
			// (Certain things, such as mountable frames, rely on afterattack)
			wrapped.afterattack(target, user, 1, params)

		//If wrapped did neither get deleted nor put into target, put it back into the gripper.
		if(wrapped && user && (wrapped.loc == user))
			wrapped.loc = src
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
		for(var/typepath in can_hold)
			if(istype(I,typepath))
				grab = 1
				break

		//We can grab the item, finally.
		if(grab)
			user << "You collect \the [I]."
			I.loc = src
			wrapped = I
			return
		else
			user << "\red Your gripper cannot hold \the [target]."

	else if(istype(target,/obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(A.opened)
			if(A.cell)

				wrapped = A.cell

				A.cell.add_fingerprint(user)
				A.cell.updateicon()
				A.cell.loc = src
				A.cell = null

				A.charging = 0
				A.update_icon()

				user.visible_message("\red [user] removes the power cell from [A]!", "You remove the power cell.")


//NEW MATTER DECOMPILER
/obj/item/weapon/matter_decompiler

	name = "matter decompiler"
	desc = "Eating trash, bits of glass, or other debris will replenish your stores."
	icon = 'icons/obj/device.dmi'
	icon_state = "decompiler"
	//Temporary storage to assess amount gained per use
	var/list/store_buffer = list(
		"metal" = 0,
		"glass" = 0,
		"wood" = 0,
		"plastic" = 0,
		"plasteel" = 0,
		"biomass" = 0
		)
	//Metal, glass, wood, plastic, plasteel, biomass
	var/list/stored_comms = list(
		"metal" = 0,
		"glass" = 0,
		"wood" = 0,
		"plastic" = 0,
		"plasteel" = 0,
		"biomass" = 0
		)

/obj/item/weapon/matter_decompiler/verb/check_salvage()

	set name = "Check Salvage Levels"
	set desc = "Review levels of stored salvage."
	set category = "Robot Commands"
	var/S = null
	var/amount = null

	for(S in src.stored_comms)
		amount = src.stored_comms[S]
		src.loc << "\blue The decompiler has [amount] units of [S] stored."


/obj/item/weapon/matter_decompiler/verb/recompile_matter()

	set name = "Recompile Matter"
	set desc = "Recompiles stored matter into sheets."
	set category = "Robot Commands"
	var/stored = null
	var/stackamount = null

	var res_type = input("Select a resource to be recompiled:", "Robot", null, null) in src.stored_comms
	if(res_type)
		stored = src.stored_comms[res_type]
		stackamount = round(input("You currently have adequate resources to produce [stored] sheets. How many sheets of [res_type] do you want to produce?") as num)
	if(stackamount <= 0 || stored <= 0)
		return
	if(stackamount > stored) //If the stated amount is greater than biomass actually in the stack
		stackamount = round(stored)

	//Determine material
	var/material
	switch(res_type)
		if("metal")
			material = /obj/item/stack/sheet/metal
			recompile_stacks(stackamount, material, stored, 50, res_type)
		if("glass")
			material = /obj/item/stack/sheet/glass
			recompile_stacks(stackamount, material, stored, 50, res_type)
		if("plastic")
			material = /obj/item/stack/sheet/mineral/plastic
			recompile_stacks(stackamount, material, stored, 50, res_type)
		if("wood")
			material = /obj/item/stack/sheet/wood
			recompile_stacks(stackamount, material, stored, 50, res_type)
		if("plasteel")
			material = /obj/item/stack/sheet/plasteel
			recompile_stacks(stackamount, material, stored, 50, res_type)
		if("biomass")
			material = /obj/item/stack/sheet/biomass
			recompile_stacks(stackamount, material, stored, 300, res_type)


/obj/item/weapon/matter_decompiler/proc/recompile_stacks(var/stackamount, var/obj/item/stack/sheet/material, var/stored, var/stack_max, var/res_type)
	src.loc.visible_message("\red [src.loc] recompiles [stackamount] sheets of [res_type]","\blue You recompile [stackamount] sheets of [res_type]",)
	while(stackamount > 0)
		var/obj/item/stack/S = PoolOrNew(material,get_turf(src))
		S.amount = min(stack_max,stackamount)
		stored -= min(stack_max,stackamount)
		stackamount -= min(stack_max,stackamount)

	playsound(src.loc, 'sound/weapons/wave.ogg', 50, 1)
	src.stored_comms[res_type] = stored
	src.loc << "\blue You have [src.stored_comms[res_type]] units of [res_type] remaining."


/obj/item/weapon/matter_decompiler/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	return

/obj/item/weapon/matter_decompiler/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, proximity, params)

	if(!proximity) return //Not adjacent.

	//We only want to deal with using this on turfs. Specific items aren't important.
	var/turf/T = get_turf(target)
	if(!istype(T))
		return

	//Used to give the right message.
	var/grabbed_something = 0

	for(var/mob/M in T)
		if(istype(M,/mob/living/simple_animal/lizard) || istype(M,/mob/living/simple_animal/mouse))

			src.loc.visible_message("\red [src.loc] begins to process the creature with its decompiler...","\red You begin to process the creature with your decompiler...")

			if(!do_after(user,10))
				user << "\red You need to remain still while decompiling such a large object."
				return

			src.loc.visible_message("\red [src.loc] sucks [M] into its decompiler. There's a horrible crunching and squelching noise.","\red It's a bit of a struggle, but you manage to suck [M] into your decompiler. It makes a series of visceral crunching and squelching noises.")
			playsound(src.loc, 'sound/effects/gib.ogg', 30, 1, -2)
			del(M)
			new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
			store_buffer["biomass"] += 25
			grabbed_something = 1
			continue

		else if(istype(M,/mob/living/carbon) && M.stat == DEAD)

			src.loc.visible_message("\red [src.loc] begins to process the corpse with its decompiler...","\red You begin to process the corpse with your decompiler...")

			if(!do_after(user,50))
				user << "\red You need to remain still while decompiling such a large object."
				return

			if(!M) return
			playsound(src.loc, 'sound/effects/gib.ogg', 30, 1, -2)
			src.loc.visible_message("\red [src.loc] sucks [M] into its decompiler. There's a horrible crunching and squelching noise.","\red It's a bit of a struggle, but you manage to suck [M] into your decompiler. It makes a series of visceral crunching and squelching noises.")
			del(M)
			new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
			store_buffer["biomass"] += 150
			grabbed_something = 1
			continue

		else if(istype(M,/mob/living/silicon/robot/drone) && !M.client)

			var/mob/living/silicon/robot/drone/D = src.loc

			if(!istype(D))
				return

			D << "\red You begin decompiling the [M]."

			if(!do_after(D,50))
				D << "\red You need to remain still while decompiling such a large object."
				return

			if(!M || !D) return

			D << "\red You carefully and thoroughly decompile your downed fellow, storing as much of its resources as you can within yourself."

			del(M)
			new/obj/effect/decal/cleanable/blood/oil(get_turf(src))

			store_buffer["metal"] += 15
			store_buffer["glass"] += 15
			store_buffer["plastic"] += 15
			grabbed_something = 1
			continue

		else
			continue



	for(var/obj/W in T)
		//Different classes of items give different commodities.
		if (istype(W,/obj/item/organ))
			playsound(src.loc, 'sound/effects/gib.ogg', 30, 1, -2)
			src.loc.visible_message("\red [src.loc] sucks [W] into its decompiler. There's a horrible squelching noise.","\red You suck [W] into your decompiler. It makes a series of visceral crunching noises.")
			store_buffer["biomass"] += 25
		else if (istype(W,/obj/item/weapon/cigbutt))
			store_buffer["plastic"] += 1
			store_buffer["biomass"] += 1
		else if (istype(W,/obj/effect/spider/spiderling))
			store_buffer["biomass"] += 10
		else if (istype(W,/obj/item/weapon/light))
			var/obj/item/weapon/light/L = W
			if(L.status >= 2) //In before someone changes the inexplicably local defines. ~ Z
				store_buffer["metal"] += 5
				store_buffer["glass"] += 5
			else
				continue
		else if(istype(W,/obj/effect/decal/remains/robot))
			store_buffer["metal"] += 5
			store_buffer["plastic"] += 5
			store_buffer["glass"] += 5
		else if (istype(W,/obj/item/trash))
			store_buffer["metal"] += 1
			store_buffer["plastic"] += 1
		else if (istype(W,/obj/effect/decal/cleanable/blood/gibs/robot))
			store_buffer["metal"] += 2
			store_buffer["glass"] += 2
		else if (istype(W,/obj/item/ammo_casing))
			store_buffer["metal"] += 1
		else if (istype(W,/obj/item/weapon/shard/shrapnel))
			store_buffer["metal"] += 5
		else if (istype(W,/obj/item/weapon/shard))
			store_buffer["glass"] += 1
		else if (istype(W,/obj/item/weapon/reagent_containers/food/snacks/grown))
			store_buffer["biomass"] += 5
		else if (istype(W,/obj/item/weapon/broken_bottle))
			store_buffer["glass"] += 5
		else if (istype(W,/obj/item/weapon/light/tube) || istype(W,/obj/item/weapon/light/bulb))
			store_buffer["glass"]++
		else if (istype(W,/obj/effect/decal/cleanable) || istype(W,/obj/effect/decal/remains))
			store_buffer["biomass"] += 1
		else if(istype(W,/obj/item/pipe))//something that can actually clear pipes!
			store_buffer["metal"] += 1
		else
			continue

		del(W)
		grabbed_something = 1

	if(grabbed_something)
		playsound(src.loc, 'sound/weapons/wave.ogg', 50, 1)
		src.loc.visible_message("\red [src.loc] cleans out the contents of the [T] with its decompiler","\blue You clean out the contents of the [T] with your decompiler")
		for(var/type in store_buffer)
			if(store_buffer[type] > 0)
				stored_comms[type] += store_buffer[type]
				src.loc << "\blue You decompile the waste into [store_buffer[type]] units of [type]. Your decompiler now holds [stored_comms[type]] units of [type]."
				store_buffer[type] = 0
	else
		user << "\red Nothing on \the [T] is useful to you."
	return


//PRETTIER TOOL LIST.
/mob/living/silicon/robot/drone/installed_modules()

	if(weapon_lock)
		src << "\red Weapon lock active, unable to use modules! Count:[weaponlock_time]"
		return

	if(!module)
		module = new /obj/item/weapon/robot_module/drone(src)

	var/dat = "<HEAD><TITLE>Drone modules</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += {"<A HREF='?src=\ref[src];mach_close=robotmod'>Close</A>
	<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	var/tools = "<B>Tools and devices</B><BR>"
	var/resources = "<BR><B>Resources</B><BR>"

	for (var/O in module.modules)

		var/module_string = ""

		if (!O)
			module_string += text("<B>Resource depleted</B><BR>")
		else if(activated(O))
			module_string += text("[O]: <B>Activated</B><BR>")
		else
			module_string += text("[O]: <A HREF=?src=\ref[src];act=\ref[O]>Activate</A><BR>")

		if((istype(O,/obj/item/weapon) || istype(O,/obj/item/device)) && !(istype(O,/obj/item/stack/cable_coil)))
			tools += module_string
		else
			resources += module_string

	dat += tools

	if (emagged)
		if (!module.emag)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=\ref[src];act=\ref[module.emag]>Activate</A><BR>")

	dat += resources

	src << browse(dat, "window=robotmod&can_close=0")

//Putting the decompiler here to avoid doing list checks every tick.
/mob/living/silicon/robot/drone/use_power()

	..()
	if(!src.has_power || !decompiler)
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
						stack_wood = new /obj/item/stack/sheet/wood/cyborg(src.module)
						stack_wood.amount = 1
					stack = stack_wood
				if("plastic")
					if(!stack_plastic)
						stack_plastic = new /obj/item/stack/sheet/mineral/plastic/cyborg(src.module)
						stack_plastic.amount = 1
					stack = stack_plastic

			stack.amount++
			decompiler.stored_comms[type]--;
