//Bot Construction

//Cleanbot assembly
/obj/item/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/created_name = "Cleanbot"
	var/robot_arm = /obj/item/robot_parts/l_arm

/obj/item/bucket_sensor/attackby(obj/item/W, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		if(!user.unEquip(W))
			return
		qdel(W)
		var/turf/T = get_turf(loc)
		var/mob/living/simple_animal/bot/cleanbot/A = new /mob/living/simple_animal/bot/cleanbot(T)
		A.name = created_name
		A.robot_arm = W.type
		to_chat(user, "<span class='notice'>You add the robot arm to the bucket and sensor assembly. Beep boop!</span>")
		user.unEquip(src, 1)
		qdel(src)

	else if(is_pen(W))
		var/t = rename_interactive(user, W, prompt = "Enter new robot name")
		if(length(t))
			created_name = t
			log_game("[key_name(user)] has renamed a robot to [t]")
		else
			to_chat(user, "The robot's name must have at least one character.")

//Edbot Assembly

/obj/item/ed209_assembly
	name = "\improper ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	var/build_step = 0
	var/created_name = "\improper ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasercolor = ""
	var/new_name = ""

/obj/item/ed209_assembly/attackby(obj/item/W, mob/user, params)
	..()

	if(is_pen(W))
		var/t = rename_interactive(user, W, prompt = "Enter new robot name")
		if(length(t))
			created_name = t
			log_game("[key_name(user)] has renamed a robot to [t]")
		else
			to_chat(user, "The robot's name must have at least one character.")
		return

	switch(build_step)
		if(0,1)
			if(istype(W, /obj/item/robot_parts/l_leg) || istype(W, /obj/item/robot_parts/r_leg))
				if(!user.unEquip(W))
					return
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the robot leg to [src].</span>")
				update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)

		if(2)
			var/newcolor = ""
			if(istype(W, /obj/item/clothing/suit/redtag))
				newcolor = "r"
			else if(istype(W, /obj/item/clothing/suit/bluetag))
				newcolor = "b"
			if(newcolor || istype(W, /obj/item/clothing/suit/armor/vest))
				if(!user.unEquip(W))
					return
				lasercolor = newcolor
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the armor to [src].</span>")
				update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)

		if(3)
			if(W.tool_behaviour == TOOL_WELDER && W.use_tool(src, user, volume = W.tool_volume))
				build_step++
				update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
				to_chat(user, "<span class='notice'>You weld the vest to [src].</span>")
		if(4)
			switch(lasercolor)
				if("b")
					if(!istype(W, /obj/item/clothing/head/helmet/bluetaghelm))
						return

				if("r")
					if(!istype(W, /obj/item/clothing/head/helmet/redtaghelm))
						return

				if("")
					if(!istype(W, /obj/item/clothing/head/helmet))
						return

			if(!user.unEquip(W))
				return
			qdel(W)
			build_step++
			to_chat(user, "<span class='notice'>You add the helmet to [src].</span>")
			update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)

		if(5)
			if(isprox(W))
				if(!user.unEquip(W))
					return
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the prox sensor to [src].</span>")
				update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)

		if(6)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.get_amount() < 1)
					to_chat(user, "<span class='warning'>You need one length of cable to wire the ED-209!</span>")
					return
				to_chat(user, "<span class='notice'>You start to wire [src]...</span>")
				if(do_after(user, 40 * W.toolspeed, target = src))
					if(coil.get_amount() >= 1 && build_step == 6)
						coil.use(1)
						build_step = 7
						playsound(loc, W.usesound, 50, 1)
						to_chat(user, "<span class='notice'>You wire the ED-209 assembly.</span>")
						update_appearance(UPDATE_NAME)

		if(7)
			new_name = ""
			switch(lasercolor)
				if("b")
					if(!istype(W, /obj/item/gun/energy/laser/tag/blue))
						return
					new_name = "bluetag ED-209 assembly"
				if("r")
					if(!istype(W, /obj/item/gun/energy/laser/tag/red))
						return
					new_name = "redtag ED-209 assembly"
				if("")
					if(!istype(W, /obj/item/gun/energy/disabler))
						return
					new_name = "disabler ED-209 assembly"
				else
					return
			if(!user.unEquip(W))
				return
			build_step++
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
			qdel(W)

		if(8)
			return
			// Handled by screwdriver act, return here to prevent errors being thrown for no switch(build_step) = 8 (might not be needed?)

		if(9)
			if(istype(W, /obj/item/stock_parts/cell))
				if(!user.unEquip(W))
					return
				build_step++
				to_chat(user, "<span class='notice'>You complete the ED-209.</span>")
				var/turf/T = get_turf(src)
				new /mob/living/simple_animal/bot/ed209(T,created_name,lasercolor)
				qdel(W)
				user.unEquip(src, 1)
				qdel(src)

/obj/item/ed209_assembly/screwdriver_act(mob/living/user, obj/item/I)
	if(build_step != 8)
		return
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You start attaching the gun to the frame...</span>")
	if(do_after(user, 40 * I.toolspeed, target = src))
		build_step++
		update_appearance(UPDATE_NAME)
		to_chat(user, "<span class='notice'>You attach the gun to the frame.</span>")
	return TRUE

/obj/item/ed209_assembly/update_name()
	. = ..()
	switch(build_step)
		if(1,2)
			name = "legs/frame assembly"
		if(3)
			name = "vest/legs/frame assembly"
		if(4)
			name = "shielded frame assembly"
		if(5)
			name = "covered and shielded frame assembly"
		if(6)
			name = "covered, shielded and sensored frame assembly"
		if(7)
			name = "wired ED-209 assembly"
		if(8)
			name = new_name
		if(9)
			name = "armed [name]"

/obj/item/ed209_assembly/update_icon_state()
	switch(build_step)
		if(1)
			item_state = "ed209_leg"
			icon_state = "ed209_leg"
		if(2)
			item_state = "ed209_legs"
			icon_state = "ed209_legs"
		if(3,4)
			item_state = "[lasercolor]ed209_shell"
			icon_state = "[lasercolor]ed209_shell"
		if(5)
			item_state = "[lasercolor]ed209_hat"
			icon_state = "[lasercolor]ed209_hat"
		if(6,7)
			item_state = "[lasercolor]ed209_prox"
			icon_state = "[lasercolor]ed209_prox"
		if(8,9)
			item_state = "[lasercolor]ed209_taser"
			icon_state = "[lasercolor]ed209_taser"

//Floorbot assemblies
/obj/item/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3
	throwforce = 10
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/created_name = "Floorbot"
	var/toolbox = /obj/item/storage/toolbox/mechanical
	var/toolbox_color = "" //Blank for blue, r for red, y for yellow, etc.

/obj/item/toolbox_tiles/sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon_state = "toolbox_tiles_sensor"

/obj/item/storage/toolbox/attackby(obj/item/stack/tile/plasteel/T, mob/user, params)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		..()
		return
	if(!istype(src, /obj/item/storage/toolbox))
		return
	if(contents.len >= 1)
		to_chat(user, "<span class='warning'>They won't fit in, as there is already stuff inside.</span>")
		return
	if(T.use(10))
		if(user.s_active)
			user.s_active.close(user)
		var/obj/item/toolbox_tiles/B = new /obj/item/toolbox_tiles
		B.toolbox = type
		switch(B.toolbox)
			if(/obj/item/storage/toolbox/mechanical/old)
				B.toolbox_color = "ob"
			if(/obj/item/storage/toolbox/emergency)
				B.toolbox_color = "r"
			if(/obj/item/storage/toolbox/emergency/old)
				B.toolbox_color = "or"
			if(/obj/item/storage/toolbox/electrical)
				B.toolbox_color = "y"
			if(/obj/item/storage/toolbox/artistic)
				B.toolbox_color = "g"
			if(/obj/item/storage/toolbox/syndicate)
				B.toolbox_color = "s"
			if(/obj/item/storage/toolbox/fakesyndi)
				B.toolbox_color = "s"
		B.update_icon(UPDATE_ICON_STATE)
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>")
		user.unEquip(src, 1)
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You need 10 floor tiles to start building a floorbot.</span>")
		return

/obj/item/toolbox_tiles/update_icon_state()
	icon_state = "[toolbox_color]toolbox_tiles"

/obj/item/toolbox_tiles/attackby(obj/item/W, mob/user, params)
	..()
	if(isprox(W))
		qdel(W)
		var/obj/item/toolbox_tiles/sensor/B = new /obj/item/toolbox_tiles/sensor()
		B.created_name = created_name
		B.toolbox_color = src.toolbox_color
		B.update_icon(UPDATE_ICON_STATE)
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You add the sensor to the toolbox and tiles.</span>")
		user.unEquip(src, 1)
		qdel(src)

	else if(is_pen(W))
		var/t = rename_interactive(user, W, prompt = "Enter new robot name")
		if(length(t))
			created_name = t
			log_game("[key_name(user)] has renamed a robot to [t]")
		else
			to_chat(user, "The robot's name must have at least one character.")

/obj/item/toolbox_tiles/sensor/update_icon_state()
	icon_state = "[toolbox_color]toolbox_tiles_sensor"

/obj/item/toolbox_tiles/sensor/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		qdel(W)
		var/mob/living/simple_animal/bot/floorbot/A = new(get_turf(src), toolbox_color)
		A.name = created_name
		A.robot_arm = W.type
		to_chat(user, "<span class='notice'>You add the robot arm to the odd looking toolbox assembly. Boop beep!</span>")
		user.unEquip(src, 1)
		qdel(src)

//Medbot Assembly
/obj/item/storage/firstaid/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/robot_parts/l_arm) && !istype(I, /obj/item/robot_parts/r_arm))
		return ..()
	else
		robot_arm = I.type

	//Making a medibot!
	if(contents.len)
		to_chat(user, "<span class='warning'>You need to empty [src] out first!</span>")
		return

	var/obj/item/firstaid_arm_assembly/A = new /obj/item/firstaid_arm_assembly(loc, med_bot_skin)

	A.req_one_access = req_one_access
	A.syndicate_aligned = syndicate_aligned
	A.treatment_oxy = treatment_oxy
	A.treatment_brute = treatment_brute
	A.treatment_fire = treatment_fire
	A.treatment_tox = treatment_tox
	A.treatment_virus = treatment_virus

	qdel(I)
	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>You add the robot arm to the first aid kit.</span>")
	user.unEquip(src, 1)
	qdel(src)

/obj/item/firstaid_arm_assembly
	name = "incomplete medibot assembly."
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "firstaid_arm"
	w_class = WEIGHT_CLASS_NORMAL
	req_one_access = list(ACCESS_MEDICAL, ACCESS_ROBOTICS)
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	var/syndicate_aligned = FALSE
	var/treatment_brute = "salglu_solution"
	var/treatment_oxy = "salbutamol"
	var/treatment_fire = "salglu_solution"
	var/treatment_tox = "charcoal"
	var/treatment_virus = "spaceacillin"
	var/robot_arm = /obj/item/robot_parts/l_arm

/obj/item/firstaid_arm_assembly/New(loc, new_skin)
	..()
	if(new_skin)
		skin = new_skin
	update_icon(UPDATE_OVERLAYS)

/obj/item/firstaid_arm_assembly/update_overlays()
	. = ..()
	if(skin)
		. += "kit_skin_[skin]"
	if(build_step > 0)
		. += "na_scanner"

/obj/item/firstaid_arm_assembly/attackby(obj/item/I, mob/user, params)
	..()
	if(is_pen(I))
		var/t = rename_interactive(user, I, prompt = "Enter new robot name")
		if(length(t))
			created_name = t
			log_game("[key_name(user)] has renamed a robot to [t]")
		else
			to_chat(user, "The robot's name must have at least one character.")
	else
		switch(build_step)
			if(0)
				if(istype(I, /obj/item/healthanalyzer))
					if(!user.drop_item())
						return
					qdel(I)
					build_step++
					to_chat(user, "<span class='notice'>You add the health sensor to [src].</span>")
					update_appearance(UPDATE_NAME)

			if(1)
				if(isprox(I))
					if(!user.drop_item())
						return
					qdel(I)
					build_step++
					to_chat(user, "<span class='notice'>You complete the Medibot. Beep boop!</span>")
					var/turf/T = get_turf(src)
					if(!syndicate_aligned)
						var/mob/living/simple_animal/bot/medbot/S = new /mob/living/simple_animal/bot/medbot(T, skin)
						S.name = created_name
						S.req_access = req_one_access
						S.treatment_oxy = treatment_oxy
						S.treatment_brute = treatment_brute
						S.treatment_fire = treatment_fire
						S.treatment_tox = treatment_tox
						S.treatment_virus = treatment_virus
						S.robot_arm = robot_arm
					else
						new /mob/living/simple_animal/bot/medbot/syndicate(T) //Syndicate medibots are a special case that have so many unique vars on them, it's not worth passing them through construction phases
					user.unEquip(src, 1)
					qdel(src)

/obj/item/firstaid_arm_assembly/update_name()
	. = ..()
	if(build_step == 1)
		name = "First aid/robot arm/health analyzer assembly"

//Secbot Assembly
/obj/item/secbot_assembly
	name = "incomplete securitron assembly"
	desc = "Some sort of bizarre assembly made from a proximity sensor, helmet, and signaler."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess
	var/build_step = 0
	var/robot_arm = /obj/item/robot_parts/l_arm

/obj/item/clothing/head/helmet/attackby(obj/item/assembly/signaler/S, mob/user, params)
	..()
	if(!issignaler(S))
		..()
		return

	if(S.secured)
		to_chat(user, "<span class='notice'>[S] is secured.</span>")
		return
	qdel(S)
	var/obj/item/secbot_assembly/A = new /obj/item/secbot_assembly
	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>You add the signaler to the helmet.</span>")
	user.unEquip(src, 1)
	qdel(src)


/obj/item/secbot_assembly/attackby(obj/item/I, mob/user, params)
	..()
	if(I.tool_behaviour == TOOL_WELDER && I.use_tool(src, user, volume = I.tool_volume))
		if(!build_step)
			build_step++
			to_chat(user, "<span class='notice'>You weld a hole in [src]!</span>")
		else if(build_step == 1)
			build_step--
			to_chat(user, "<span class='notice'>You weld the hole in [src] shut!</span>")

	else if(isprox(I) && (build_step == 1))
		if(!user.unEquip(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You add the prox sensor to [src]!</span>")
		qdel(I)

	else if(((istype(I, /obj/item/robot_parts/l_arm)) || (istype(I, /obj/item/robot_parts/r_arm))) && (build_step == 2))
		if(!user.unEquip(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You add the robot arm to [src]!</span>")
		robot_arm = I.type
		qdel(I)

	else if((istype(I, /obj/item/melee/baton)) && (build_step >= 3))
		if(!user.unEquip(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You complete the Securitron! Beep boop.</span>")
		var/mob/living/simple_animal/bot/secbot/S = new /mob/living/simple_animal/bot/secbot(get_turf(src))
		S.name = created_name
		S.robot_arm = robot_arm
		qdel(I)
		qdel(src)

	else if(is_pen(I))
		var/t = rename_interactive(user, I, prompt = "Enter new robot name")
		if(length(t))
			created_name = t
			log_game("[key_name(user)] has renamed a robot to [t]")
		else
			to_chat(user, "The robot's name must have at least one character.")

//General Griefsky

	else if(istype(I, /obj/item/wrench) && build_step == 3)
		var/obj/item/griefsky_assembly/A = new /obj/item/griefsky_assembly(get_turf(src))
		user.put_in_hands(A)
		to_chat(user, "<span class='notice'>You adjust the arm slots for extra weapons!</span>")
		user.unEquip(src, 1)
		qdel(src)

	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)

/obj/item/secbot_assembly/screwdriver_act(mob/living/user, obj/item/I)
	if(build_step != 0 && build_step != 2 && build_step != 3)
		return

	switch(build_step)
		if(0)
			new /obj/item/assembly/signaler(get_turf(src))
			new /obj/item/clothing/head/helmet(get_turf(src))
			to_chat(user, "<span class='notice'>You disconnect the signaler from the helmet.</span>")
			qdel(src)
		if(2)
			new /obj/item/assembly/prox_sensor(get_turf(src))
			to_chat(user, "<span class='notice'>You detach the proximity sensor from [src].</span>")
			build_step--
		if(3)
			new /obj/item/robot_parts/l_arm(get_turf(src))
			to_chat(user, "<span class='notice'>You remove the robot arm from [src].</span>")
			build_step--

	I.play_tool_sound(src)
	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)
	return TRUE

/obj/item/secbot_assembly/update_name()
	. = ..()
	switch(build_step)
		if(2)
			name = "helmet/signaler/prox sensor assembly"
		if(3)
			name = "helmet/signaler/prox sensor/robot arm assembly"

/obj/item/secbot_assembly/update_overlays()
	. = ..()
	switch(build_step)
		if(1)
			. += "hs_hole"
		if(2)
			. += "hs_eye"
		if(3)
			. += "hs_arm"

/obj/item/griefsky_assembly
	name = "\improper Griefsky assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "griefsky_assembly"
	item_state = "griefsky_assembly"
	var/build_step = 0
	var/toy_step = 0

/obj/item/griefsky_assembly/attackby(obj/item/I, mob/user, params)
	..()
	if((istype(I, /obj/item/melee/energy/sword)) && (build_step < 3))
		if(!user.unEquip(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You add an energy sword to [src]!.</span>")
		qdel(I)

	else if((istype(I, /obj/item/melee/energy/sword)) && (build_step == 3))
		if(!user.unEquip(I))
			return
		to_chat(user, "<span class='notice'>You complete General Griefsky!.</span>")
		new /mob/living/simple_animal/bot/secbot/griefsky(get_turf(src))
		qdel(I)
		qdel(src)

	else if((istype(I, /obj/item/toy/sword)) && (toy_step < 3))
		if(!user.unEquip(I))
			return
		toy_step++
		to_chat(user, "<span class='notice'>You add a toy sword to [src]!.</span>")
		qdel(I)

	else if((istype(I, /obj/item/toy/sword)) && (toy_step == 3))
		if(!user.unEquip(I))
			return
		to_chat(user, "<span class='notice'>You complete Genewul Giftskee!.</span>")
		new /mob/living/simple_animal/bot/secbot/griefsky/toy(get_turf(src))
		qdel(I)
		qdel(src)

/obj/item/griefsky_assembly/screwdriver_act(mob/living/user, obj/item/I)
	if(!build_step && !toy_step)
		return

	if(build_step)
		new /obj/item/melee/energy/sword(get_turf(src))
		to_chat(user, "<span class='notice'>You detach the energy sword from [src].</span>")
		build_step--
	else if(toy_step)
		new /obj/item/toy/sword(get_turf(src))
		to_chat(user, "<span class='notice'>You detach the toy sword from [src].</span>")
		toy_step--
	I.play_tool_sound(src)
	return TRUE

//Honkbot Assembly
/obj/item/storage/box/clown/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/robot_parts/l_arm) && !istype(W, /obj/item/robot_parts/r_arm))
		return ..()
	else
		robot_arm = W.type

	if(contents.len)
		to_chat(user, "<span class='warning'>You need to empty [src] out first!</span>")
		return

	var/obj/item/honkbot_arm_assembly/A = new /obj/item/honkbot_arm_assembly
	qdel(W)
	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>You add the robot arm to the honkbot.</span>")
	user.unEquip(src, 1)
	qdel(src)

/obj/item/honkbot_arm_assembly
	name = "incomplete honkbot assembly"
	desc = "A clown box with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "honkbot_arm"
	w_class = WEIGHT_CLASS_NORMAL
	req_one_access = list(ACCESS_CLOWN, ACCESS_ROBOTICS, ACCESS_MIME)
	var/build_step = 0
	var/created_name = "Honkbot" //To preserve the name if it's a unique medbot I guess
	var/robot_arm = /obj/item/robot_parts/l_arm

/obj/item/honkbot_arm_assembly/attackby(obj/item/W, mob/user, params)
	..()
	if(build_step == 0)
		if(istype(W, /obj/item/assembly/prox_sensor))
			if(!user.unEquip(W))
				return
			build_step++
			to_chat(user, "<span class='notice'>You add the proximity sensor to [src].</span>")
			qdel(W)
	else if(build_step == 1)
		if(istype(W, /obj/item/bikehorn))
			if(!user.unEquip(W))
				return
			build_step++
			to_chat(user, "<span class='notice'>You add the bikehorn to [src]! Honk!</span>")
			qdel(W)
	else if(build_step == 2)
		if(istype(W, /obj/item/instrument/trombone))
			if(!user.unEquip(W))
				return
			to_chat(user, "<span class='notice'>You add the trombone to [src]! Heeeenk!</span>")
			qdel(W)
			var/mob/living/simple_animal/bot/honkbot/A = new /mob/living/simple_animal/bot/honkbot(get_turf(src))
			A.robot_arm = robot_arm
			qdel(src)
	update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)

/obj/item/honkbot_arm_assembly/update_icon_state()
	if(build_step == 1)
		icon_state = "honkbot_proxy"

/obj/item/honkbot_arm_assembly/update_desc()
	. = ..()
	if(build_step == 2)
		desc = "A clown box with a robot arm and a bikehorn permanently grafted to it. It needs a trombone to be finished"
