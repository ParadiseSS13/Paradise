//Bot Construction
var/robot_arm = /obj/item/robot_parts/l_arm

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

	else if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return
		created_name = t
		log_game("[key_name(user)] has renamed a robot to [t]")

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

/obj/item/ed209_assembly/attackby(obj/item/W, mob/user, params)
	..()

	if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return
		created_name = t
		log_game("[key_name(user)] has renamed a robot to [t]")
		return

	switch(build_step)
		if(0,1)
			if(istype(W, /obj/item/robot_parts/l_leg) || istype(W, /obj/item/robot_parts/r_leg))
				if(!user.unEquip(W))
					return
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the robot leg to [src].</span>")
				name = "legs/frame assembly"
				if(build_step == 1)
					item_state = "ed209_leg"
					icon_state = "ed209_leg"
				else
					item_state = "ed209_legs"
					icon_state = "ed209_legs"

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
				name = "vest/legs/frame assembly"
				item_state = "[lasercolor]ed209_shell"
				icon_state = "[lasercolor]ed209_shell"

		if(3)
			if(istype(W, /obj/item/weldingtool))
				var/obj/item/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					build_step++
					name = "shielded frame assembly"
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
			name = "covered and shielded frame assembly"
			item_state = "[lasercolor]ed209_hat"
			icon_state = "[lasercolor]ed209_hat"

		if(5)
			if(isprox(W))
				if(!user.unEquip(W))
					return
				qdel(W)
				build_step++
				to_chat(user, "<span class='notice'>You add the prox sensor to [src].</span>")
				name = "covered, shielded and sensored frame assembly"
				item_state = "[lasercolor]ed209_prox"
				icon_state = "[lasercolor]ed209_prox"

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
						name = "wired ED-209 assembly"

		if(7)
			var/newname = ""
			switch(lasercolor)
				if("b")
					if(!istype(W, /obj/item/gun/energy/laser/tag/blue))
						return
					newname = "bluetag ED-209 assembly"
				if("r")
					if(!istype(W, /obj/item/gun/energy/laser/tag/red))
						return
					newname = "redtag ED-209 assembly"
				if("")
					if(!istype(W, /obj/item/gun/energy/gun/advtaser))
						return
					newname = "taser ED-209 assembly"
				else
					return
			if(!user.unEquip(W))
				return
			name = newname
			build_step++
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			item_state = "[lasercolor]ed209_taser"
			icon_state = "[lasercolor]ed209_taser"
			qdel(W)

		if(8)
			if(istype(W, /obj/item/screwdriver))
				playsound(loc, W.usesound, 100, 1)
				to_chat(user, "<span class='notice'>You start attaching the gun to the frame...</span>")
				if(do_after(user, 40 * W.toolspeed, target = src))
					build_step++
					name = "armed [name]"
					to_chat(user, "<span class='notice'>Taser gun attached.</span>")

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

/obj/item/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3
	throwforce = 10
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/created_name = "Floorbot"

/obj/item/storage/toolbox/mechanical/attackby(obj/item/stack/tile/plasteel/T, mob/user, params)
	if(!istype(T, /obj/item/stack/tile/plasteel))
		..()
		return
	if(contents.len >= 1)
		to_chat(user, "<span class='warning'>They won't fit in, as there is already stuff inside.</span>")
		return
	if(T.use(10))
		if(user.s_active)
			user.s_active.close(user)
		var/obj/item/toolbox_tiles/B = new /obj/item/toolbox_tiles
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You add the tiles into the empty toolbox. They protrude from the top.</span>")
		user.unEquip(src, 1)
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You need 10 floor tiles to start building a floorbot.</span>")
		return

/obj/item/toolbox_tiles/attackby(obj/item/W, mob/user, params)
	..()
	if(isprox(W))
		qdel(W)
		var/obj/item/toolbox_tiles_sensor/B = new /obj/item/toolbox_tiles_sensor()
		B.created_name = created_name
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You add the sensor to the toolbox and tiles.</span>")
		user.unEquip(src, 1)
		qdel(src)

	else if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return

		created_name = t
		log_game("[key_name(user)] has renamed a robot to [t]")

/obj/item/toolbox_tiles_sensor/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		qdel(W)
		var/turf/T = get_turf(user.loc)
		var/mob/living/simple_animal/bot/floorbot/A = new /mob/living/simple_animal/bot/floorbot(T)
		A.name = created_name
		A.robot_arm = W.type
		to_chat(user, "<span class='notice'>You add the robot arm to the odd looking toolbox assembly. Boop beep!</span>")
		user.unEquip(src, 1)
		qdel(src)
	else if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return

		created_name = t
		log_game("[key_name(user)] has renamed a robot to [t]")

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
	req_one_access = list(access_medical, access_robotics)
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	var/syndicate_aligned = FALSE
	var/treatment_brute = "salglu_solution"
	var/treatment_oxy = "salbutamol"
	var/treatment_fire = "salglu_solution"
	var/treatment_tox = "charcoal"
	var/treatment_virus = "spaceacillin"

/obj/item/firstaid_arm_assembly/New(loc, new_skin)
	..()
	if(new_skin)
		skin = new_skin
	update_icon()

/obj/item/firstaid_arm_assembly/update_icon()
	overlays.Cut()
	if(skin)
		overlays += image('icons/obj/aibots.dmi', "kit_skin_[skin]")
	if(build_step > 0)
		overlays += image('icons/obj/aibots.dmi', "na_scanner")


/obj/item/firstaid_arm_assembly/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name, MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return
		created_name = t
		log_game("[key_name(user)] has renamed a robot to [t]")
	else
		switch(build_step)
			if(0)
				if(istype(I, /obj/item/healthanalyzer))
					if(!user.drop_item())
						return
					qdel(I)
					build_step++
					to_chat(user, "<span class='notice'>You add the health sensor to [src].</span>")
					name = "First aid/robot arm/health analyzer assembly"
					update_icon()

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
						S.bot_core.req_one_access = req_one_access
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

//Secbot Assembly
/obj/item/secbot_assembly
	name = "incomplete securitron assembly"
	desc = "Some sort of bizarre assembly made from a proximity sensor, helmet, and signaler."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess
	var/build_step = 0

/obj/item/clothing/head/helmet/attackby(obj/item/assembly/signaler/S, mob/user, params)
	..()
	if(!issignaler(S))
		..()
		return

	if(!S.secured)
		qdel(S)
		var/obj/item/secbot_assembly/A = new /obj/item/secbot_assembly
		user.put_in_hands(A)
		to_chat(user, "<span class='notice'>You add the signaler to the helmet.</span>")
		user.unEquip(src, 1)
		qdel(src)
	else
		return

/obj/item/secbot_assembly/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/weldingtool))
		if(!build_step)
			var/obj/item/weldingtool/WT = I
			if(WT.remove_fuel(0, user))
				build_step++
				overlays += "hs_hole"
				to_chat(user, "<span class='notice'>You weld a hole in [src]!</span>")
		else if(build_step == 1)
			var/obj/item/weldingtool/WT = I
			if(WT.remove_fuel(0, user))
				build_step--
				overlays -= "hs_hole"
				to_chat(user, "<span class='notice'>You weld the hole in [src] shut!</span>")

	else if(isprox(I) && (build_step == 1))
		if(!user.unEquip(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You add the prox sensor to [src]!</span>")
		overlays += "hs_eye"
		name = "helmet/signaler/prox sensor assembly"
		qdel(I)

	else if(((istype(I, /obj/item/robot_parts/l_arm)) || (istype(I, /obj/item/robot_parts/r_arm))) && (build_step == 2))
		if(!user.unEquip(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You add the robot arm to [src]!</span>")
		name = "helmet/signaler/prox sensor/robot arm assembly"
		overlays += "hs_arm"
		robot_arm = I.type
		qdel(I)

	else if((istype(I, /obj/item/melee/baton)) && (build_step >= 3))
		if(!user.unEquip(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You complete the Securitron! Beep boop.</span>")
		var/mob/living/simple_animal/bot/secbot/S = new /mob/living/simple_animal/bot/secbot
		S.forceMove(get_turf(src))
		S.name = created_name
		S.robot_arm = robot_arm
		qdel(I)
		qdel(src)

	else if(istype(I, /obj/item/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return
		created_name = t
		log_game("[key_name(user)] has renamed a robot to [t]")

	else if(istype(I, /obj/item/screwdriver))
		if(!build_step)
			new /obj/item/assembly/signaler(get_turf(src))
			new /obj/item/clothing/head/helmet(get_turf(src))
			to_chat(user, "<span class='notice'>You disconnect the signaler from the helmet.</span>")
			qdel(src)

		else if(build_step == 2)
			overlays -= "hs_eye"
			new /obj/item/assembly/prox_sensor(get_turf(src))
			to_chat(user, "<span class='notice'>You detach the proximity sensor from [src].</span>")
			build_step--

		else if(build_step == 3)
			overlays -= "hs_arm"
			new /obj/item/robot_parts/l_arm(get_turf(src))
			to_chat(user, "<span class='notice'>You remove the robot arm from [src].</span>")
			build_step--

//General Griefsky

	else if((istype(I, /obj/item/wrench)) && (build_step == 3))		
		var/obj/item/griefsky_assembly/A = new /obj/item/griefsky_assembly
		user.put_in_hands(A)
		to_chat(user, "<span class='notice'>You adjust the arm slots for extra weapons!.</span>")
		user.unEquip(src, 1)
		qdel(src)

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
	if((istype(I, /obj/item/melee/energy/sword)) && (build_step < 3 ))
		if(!user.unEquip(I))
			return
		build_step++
		to_chat(user, "<span class='notice'>You add an energy sword to [src]!.</span>")
		qdel(I)
		
	else if((istype(I, /obj/item/melee/energy/sword)) && (build_step == 3))
		if(!user.unEquip(I))
			return
		to_chat(user, "<span class='notice'>You complete General Griefsky!.</span>")
		var/mob/living/simple_animal/bot/secbot/griefsky/S = new /mob/living/simple_animal/bot/secbot/griefsky 
		S.forceMove(get_turf(src))
		qdel(I)
		qdel(src)

	else if((istype(I, /obj/item/toy/sword)) && (toy_step < 3 ))
		if(!user.unEquip(I))
			return
		toy_step++
		to_chat(user, "<span class='notice'>You add a toy sword to [src]!.</span>")
		qdel(I)

	else if((istype(I, /obj/item/toy/sword)) && (toy_step == 3))
		if(!user.unEquip(I))
			return
		to_chat(user, "<span class='notice'>You complete Genewul Giftskee!.</span>")
		var/mob/living/simple_animal/bot/secbot/griefsky/toy/S = new /mob/living/simple_animal/bot/secbot/griefsky/toy 
		S.forceMove(get_turf(src))
		qdel(I)
		qdel(src)

	else if(istype(I, /obj/item/screwdriver))
		if((build_step == 1) || (build_step == 2) || (build_step == 3) || (build_step == 4))
			new /obj/item/melee/energy/sword(get_turf(src))
			to_chat(user, "<span class='notice'>You detach the energy sword from [src].</span>")
			build_step--
		else if((toy_step == 1) || (toy_step == 2) || (toy_step == 3) || (toy_step == 4))
			new /obj/item/toy/sword(get_turf(src))
			to_chat(user, "<span class='notice'>You detach the toy sword from [src].</span>")
			toy_step--

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
	name = "incomplete honkbot assembly."
	desc = "A clown box with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "honkbot_arm"
	w_class = WEIGHT_CLASS_NORMAL
	req_one_access = list(access_clown, access_robotics, access_mime)
	var/build_step = 0
	var/created_name = "Honkbot" //To preserve the name if it's a unique medbot I guess

/obj/item/honkbot_arm_assembly/attackby(obj/item/W, mob/user, params)
	..()
	if(build_step == 0)
		if(istype(W, /obj/item/assembly/prox_sensor))
			if(!user.unEquip(W))
				return
			build_step++
			to_chat(user, "<span class='notice'>You add the proximity sensor to [src].</span>")
			icon_state = "honkbot_proxy"
			qdel(W)
	else if(build_step == 1)
		if(istype(W, /obj/item/bikehorn))
			if(!user.unEquip(W))
				return
			build_step++
			to_chat(user, "<span class='notice'>You add the bikehorn to [src]! Honk!</span>")
			desc = "A clown box with a robot arm and a bikehorn permanently grafted to it. It needs a trombone to be finished"
			qdel(W)
	else if(build_step == 2)
		if(istype(W, /obj/item/instrument/trombone))
			if(!user.unEquip(W))
				return
			to_chat(user, "<span class='notice'>You add the trombone to [src]! Heeeenk! </span>")
			qdel(W)
			var/mob/living/simple_animal/bot/honkbot/A = new /mob/living/simple_animal/bot/honkbot(T)
			A.robot_arm = robot_arm
			qdel(src)