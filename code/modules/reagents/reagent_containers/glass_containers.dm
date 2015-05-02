 ////////////////////////////////////////////////////////////////////////////////
/// (Mixing)Glass.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/glass
	name = " "
	var/base_name = " "
	desc = " "
	icon = 'icons/obj/chemical.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50)
	volume = 50
	flags = OPENCONTAINER

	var/label_text = ""
	// the fucking asshole who designed this can go die in a fire - Iamgoofball
	var/list/can_be_placed_into = list(
		/obj/machinery/chem_master/,
		/obj/machinery/chem_heater/,
		/obj/machinery/chem_dispenser/,
		/obj/machinery/reagentgrinder,
		/obj/structure/table,
		/obj/structure/closet,
		/obj/structure/sink,
		/obj/item/weapon/storage,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/machinery/dna_scannernew,
		/obj/item/weapon/grenade/chem_grenade,
		/obj/machinery/bot/medbot,
		/obj/item/weapon/storage/secure/safe,
		/obj/machinery/iv_drip,
		/obj/machinery/disease2/incubator,
		/obj/machinery/disposal,
		/obj/machinery/apiary,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/obj/machinery/computer/centrifuge,
		/obj/machinery/sleeper,
		/obj/machinery/smartfridge/,
//		/obj/machinery/biogenerator,
		/obj/machinery/portable_atmospherics/hydroponics,
		/obj/machinery/constructable_frame)

	New()
		..()
		base_name = name

	examine()
		set src in view()
		..()
		if (!(usr in view(2)) && usr!=src.loc) return
		usr << "\blue It contains:"
		if(reagents && reagents.reagent_list.len)
			usr << "\blue [src.reagents.total_volume] units of liquid."
		else
			usr << "\blue Nothing."
		if (!is_open_container())
			usr << "\blue Airtight lid seals it completely."

	attack_self()
		..()
		if (is_open_container())
			usr << "<span class = 'notice'>You put the lid on \the [src]."
			flags ^= OPENCONTAINER
		else
			usr << "<span class = 'notice'>You take the lid off \the [src]."
			flags |= OPENCONTAINER
		update_icon()

	afterattack(obj/target, mob/user, proximity)
		if(!proximity) return
		if (!is_open_container())
			return

		for(var/type in src.can_be_placed_into)
			if(istype(target, type))
				return

		if(ismob(target) && target.reagents && reagents.total_volume)
			user << "\blue You splash the solution onto [target]."

			var/mob/living/M = target
			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been splashed with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to splash [M.name] ([M.key]). Reagents: [contained]</font>")
			if(M.ckey)
				msg_admin_attack("[user.name] ([user.ckey])[isAntag(user) ? "(ANTAG)" : ""] splashed [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user

			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red [] has been splashed with something by []!", target, user), 1)
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return
		else if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume && target.reagents)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			if(istype(target, /obj/item/weapon/reagent_containers))
				var/obj/item/weapon/reagent_containers/RC = target
				for(var/bad_reg in RC.banned_reagents)
					if(reagents.has_reagent(bad_reg, 1)) //Message is a bit "Game-y" but I can't think up a better one.
						user << "<span class='warning'>A chemical in [src] is far too dangerous to transfer to [RC]!</span>"
						return

			// /vg/: Logging transfers of bad things
			if(target.reagents_to_log.len)
				var/list/badshit=list()
				for(var/bad_reagent in target.reagents_to_log)
					if(reagents.has_reagent(bad_reagent))
						badshit += reagents_to_log[bad_reagent]
				if(badshit.len)
					var/hl="\red <b>([english_list(badshit)])</b> \black"
					message_admins("[user.name] ([user.ckey]) added [reagents.get_reagent_ids(1)] to \a [target] with [src].[hl] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
					log_game("[user.name] ([user.ckey]) added [reagents.get_reagent_ids(1)] to \a [target] with [src].")

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "\blue You transfer [trans] units of the solution to [target]."

		else if(istype(target, /obj/machinery/bunsen_burner))
			return

		else if(istype(target, /obj/machinery/radiocarbon_spectrometer))
			return

		else if(istype(target, /obj/effect/decal/cleanable)) //stops splashing while scooping up fluids
			return

		else if(reagents.total_volume)
			user << "\blue You splash the solution onto [target]."
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return


	attackby(var/obj/item/I, mob/user as mob, params)
		if(istype(I, /obj/item/clothing/mask/cigarette)) //ciggies are weird
			return
		if(is_hot(I))
			if(src.reagents)
				src.reagents.chem_temp += 15
				user << "<span class='notice'>You heat [src] with [I].</span>"
				src.reagents.handle_reactions()
		if(istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/device/flashlight/pen))
			var/tmp_label = sanitize(input(user, "Enter a label for [src.name]","Label",src.label_text))
			if(length(tmp_label) > 10)
				user << "\red The label can be at most 10 characters long."
			else
				user << "\blue You set the label to \"[tmp_label]\"."
				src.label_text = tmp_label
				src.update_name_label()


	proc/update_name_label()
		if(src.label_text == "")
			src.name = src.base_name
		else
			src.name = "[src.base_name] ([src.label_text])"

/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	m_amt = 0
	g_amt = 500
	var/obj/item/device/assembly_holder/assembly = null

	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_hand()
		..()
		update_icon()

	update_icon()
		overlays.Cut()

		if(reagents.total_volume)
			var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

			var/percent = round((reagents.total_volume / volume) * 100)
			switch(percent)
				if(0 to 9)		filling.icon_state = "[icon_state]-10"
				if(10 to 24) 	filling.icon_state = "[icon_state]10"
				if(25 to 49)	filling.icon_state = "[icon_state]25"
				if(50 to 74)	filling.icon_state = "[icon_state]50"
				if(75 to 79)	filling.icon_state = "[icon_state]75"
				if(80 to 90)	filling.icon_state = "[icon_state]80"
				if(91 to INFINITY)	filling.icon_state = "[icon_state]100"

			filling.icon += mix_color_from_reagents(reagents.reagent_list)
			overlays += filling

		if (!is_open_container())
			var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
			overlays += lid
		if(assembly)
			overlays += "assembly"

/obj/item/weapon/reagent_containers/glass/beaker/verb/remove_assembly()
	set name = "Remove Assembly"
	set category = "Object"
	set src in usr
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if (assembly)
		usr << "<span class='notice'>You detach [assembly] from \the [src]</span>"
		usr.put_in_hands(assembly)
		assembly = null
		update_icon()
	else
		usr << "<span class='notice'>There is no assembly to remove.</span>"

/obj/item/weapon/reagent_containers/glass/beaker/proc/heat_beaker()
	if(reagents)
		reagents.chem_temp += 30
		reagents.handle_reactions()

/obj/item/weapon/reagent_containers/glass/beaker/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W,/obj/item/device/assembly_holder))
		if (assembly)
			usr << "<span class='warning'>The [src] already has an assembly.</span>"
			return ..()
		assembly = W
		user.drop_item()
		W.loc = src
		overlays += "assembly"
	else
		..()

/obj/item/weapon/reagent_containers/glass/beaker/HasProximity(atom/movable/AM)
	if(assembly)
		assembly.HasProximity(AM)

/obj/item/weapon/reagent_containers/glass/beaker/Crossed(atom/movable/AM)
	if(assembly)
		assembly.Crossed(AM)

/obj/item/weapon/reagent_containers/glass/beaker/on_found(mob/finder as mob) //for mousetraps
	if(assembly)
		assembly.on_found(finder)

/obj/item/weapon/reagent_containers/glass/beaker/hear_talk(mob/living/M, msg)
	if(assembly)
		assembly.hear_talk(M, msg)

/obj/item/weapon/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	g_amt = 2500
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial. Can hold up to 25 units."
	icon_state = "vial"
	g_amt = 250
	volume = 25
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	icon_state = "beakernoreact"
	g_amt = 500
	volume = 50
	amount_per_transfer_from_this = 10
	flags = OPENCONTAINER | NOREACT

/obj/item/weapon/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	icon_state = "beakerbluespace"
	g_amt = 5000
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100,300)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone
	New()
		..()
		reagents.add_reagent("cryoxadone", 30)
		update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/sulphuric
	New()
		..()
		reagents.add_reagent("sacid", 50)
		update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/slime
	New()
		..()
		reagents.add_reagent("slimejelly", 50)
		update_icon()

/obj/item/weapon/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	m_amt = 200
	g_amt = 0
	w_class = 3.0
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(5,10,15,25,30,50,80,100,120)
	volume = 120
	flags = OPENCONTAINER

	attackby(var/obj/D, mob/user as mob, params)
		if(isprox(D))
			user << "You add [D] to [src]."
			del(D)
			user.put_in_hands(new /obj/item/weapon/bucket_sensor)
			user.unEquip(src)
			qdel(src)
		else
			..()

/obj/item/weapon/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "Small glass vial. Looks fragile."
	icon_state = "vial"
	g_amt = 500
	volume = 15
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,5,15)
	flags = OPENCONTAINER

/*
/obj/item/weapon/reagent_containers/glass/blender_jug
	name = "Blender Jug"
	desc = "A blender jug, part of a blender."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "blender_jug_e"
	volume = 100

	on_reagent_change()
		switch(src.reagents.total_volume)
			if(0)
				icon_state = "blender_jug_e"
			if(1 to 75)
				icon_state = "blender_jug_h"
			if(76 to 100)
				icon_state = "blender_jug_f"

/obj/item/weapon/reagent_containers/glass/canister		//not used apparantly
	desc = "It's a canister. Mainly used for transporting fuel."
	name = "canister"
	icon = 'icons/obj/tank.dmi'
	icon_state = "canister"
	item_state = "canister"
	m_amt = 300
	g_amt = 0
	w_class = 4.0

	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,60)
	volume = 120

/obj/item/weapon/reagent_containers/glass/dispenser
	name = "reagent glass"
	desc = "A reagent glass."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker0"
	amount_per_transfer_from_this = 10
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/dispenser/surfactant
	name = "reagent glass (surfactant)"
	icon_state = "liquid"

	New()
		..()
		reagents.add_reagent("fluorosurfactant", 20)

*/
