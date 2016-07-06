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
		/obj/structure/toilet,
		/obj/item/weapon/storage,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/machinery/dna_scannernew,
		/obj/item/weapon/grenade/chem_grenade,
		/mob/living/simple_animal/bot/medbot,
		/obj/item/weapon/storage/secure/safe,
		/obj/machinery/iv_drip,
		/obj/machinery/computer/pandemic,
		/obj/machinery/disposal,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/obj/machinery/sleeper,
		/obj/machinery/smartfridge/,
		/obj/machinery/biogenerator,
		/obj/machinery/portable_atmospherics/hydroponics,
		/obj/machinery/constructable_frame)

/obj/item/weapon/reagent_containers/glass/New()
	..()
	base_name = name

/obj/item/weapon/reagent_containers/glass/examine(mob/user)
	if(!..(user, 2))
		return
	if (!is_open_container())
		to_chat(user, "<span class='notice'>Airtight lid seals it completely.</span>")

/obj/item/weapon/reagent_containers/glass/attack_self()
	..()
	if (is_open_container())
		to_chat(usr, "<span class='notice'>You put the lid on \the [src].</span>")
		flags ^= OPENCONTAINER
	else
		to_chat(usr, "<span class='notice'>You take the lid off \the [src].</span>")
		flags |= OPENCONTAINER
	update_icon()

/obj/item/weapon/reagent_containers/glass/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return
	if (!is_open_container())
		return

	for(var/type in can_be_placed_into)
		if(istype(target, type))
			return

	if(ismob(target) && target.reagents && reagents.total_volume)
		to_chat(user, "<span class='notice'>You splash the solution onto [target].</span>")

		var/mob/living/M = target
		var/list/injected = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			injected += R.name
		var/contained = english_list(injected)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been splashed with [name] by [key_name(user)]. Reagents: [contained]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to splash [key_name(M)]. Reagents: [contained]</font>")
		if(M.ckey)
			msg_admin_attack("[key_name_admin(user)] splashed [key_name_admin(M)] with [name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)])")
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

		for(var/mob/O in viewers(world.view, user))
			O.show_message(text("<span class='warning'>[] has been splashed with something by []!</span>", target, user), 1)
		reagents.reaction(target, TOUCH)
		spawn(5) reagents.clear_reagents()
		return
	else if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume && target.reagents)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		// /vg/: Logging transfers of bad things
		if(target.reagents_to_log.len)
			var/list/badshit=list()
			for(var/bad_reagent in target.reagents_to_log)
				if(reagents.has_reagent(bad_reagent))
					badshit += reagents_to_log[bad_reagent]
			if(badshit.len)
				var/hl = "<span class='danger'>([english_list(badshit)])</span>"
				message_admins("[key_name_admin(user)] added [reagents.get_reagent_ids(1)] to \a [target] with [src].[hl]")
				log_game("[key_name(user)] added [reagents.get_reagent_ids(1)] to \a [target] with [src].")

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

	else if(istype(target, /obj/item/weapon/reagent_containers/glass) && !target.is_open_container())
		to_chat(user, "<span class='warning'>You cannot fill [target] while it is sealed.</span>")
		return

	/*else if(istype(target, /obj/machinery/bunsen_burner))
		return

	else if(istype(target, /obj/machinery/radiocarbon_spectrometer))
		return*/

	else if(istype(target, /obj/effect/decal/cleanable)) //stops splashing while scooping up fluids
		return

	else if(reagents.total_volume)
		to_chat(user, "<span class='notice'>You splash the solution onto [target].</span>")
		reagents.reaction(target, TOUCH)
		spawn(5) reagents.clear_reagents()
		return


/obj/item/weapon/reagent_containers/glass/attackby(var/obj/item/I, mob/user as mob, params)
	if(istype(I, /obj/item/clothing/mask/cigarette)) //ciggies are weird
		return
	if(is_hot(I))
		if(reagents)
			reagents.chem_temp += 15
			to_chat(user, "<span class='notice'>You heat [src] with [I].</span>")
			reagents.handle_reactions()
	if(istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/device/flashlight/pen))
		var/tmp_label = sanitize(input(user, "Enter a label for [name]","Label",label_text))
		if(length(tmp_label) > MAX_NAME_LEN)
			to_chat(user, "<span class='warning'>The label can be at most [MAX_NAME_LEN] characters long.</span>")
		else
			to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
			label_text = tmp_label
			update_name_label()
	if(istype(I,/obj/item/weapon/storage/bag))
		..()

/obj/item/weapon/reagent_containers/glass/proc/update_name_label()
	if(label_text == "")
		name = base_name
	else
		name = "[base_name] ([label_text])"

/obj/item/weapon/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	materials = list(MAT_GLASS=500)
	var/obj/item/device/assembly_holder/assembly = null

/obj/item/weapon/reagent_containers/glass/beaker/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/update_icon()
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
		to_chat(usr, "<span class='notice'>You detach [assembly] from \the [src]</span>")
		usr.put_in_hands(assembly)
		assembly = null
		update_icon()
	else
		to_chat(usr, "<span class='notice'>There is no assembly to remove.</span>")

/obj/item/weapon/reagent_containers/glass/beaker/proc/heat_beaker()
	if(reagents)
		reagents.chem_temp += 30
		reagents.handle_reactions()

/obj/item/weapon/reagent_containers/glass/beaker/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W,/obj/item/device/assembly_holder))
		if (assembly)
			to_chat(usr, "<span class='warning'>The [src] already has an assembly.</span>")
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

/obj/item/weapon/reagent_containers/glass/beaker/hear_message(mob/living/M, msg)
	if(assembly)
		assembly.hear_message(M, msg)

/obj/item/weapon/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	materials = list(MAT_GLASS=2500)
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial. Can hold up to 25 units."
	icon_state = "vial"
	materials = list(MAT_GLASS=250)
	volume = 25
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	icon_state = "beakernoreact"
	materials = list(MAT_GLASS=500)
	volume = 50
	amount_per_transfer_from_this = 10
	flags = OPENCONTAINER | NOREACT

/obj/item/weapon/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	icon_state = "beakerbluespace"
	materials = list(MAT_GLASS=5000)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100,300)
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/beaker/cryoxadone/New()
	..()
	reagents.add_reagent("cryoxadone", 30)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/sulphuric/New()
	..()
	reagents.add_reagent("sacid", 50)
	update_icon()

/obj/item/weapon/reagent_containers/glass/beaker/slime/New()
	..()
	reagents.add_reagent("slimejelly", 50)
	update_icon()

/obj/item/weapon/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	materials = list(MAT_METAL=200)
	w_class = 3.0
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(5,10,15,20,25,30,50,80,100,120)
	volume = 120
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/bucket/attackby(var/obj/D, mob/user as mob, params)
	if(isprox(D))
		to_chat(user, "You add [D] to [src].")
		qdel(D)
		user.put_in_hands(new /obj/item/weapon/bucket_sensor)
		user.unEquip(src)
		qdel(src)
	else
		..()

/obj/item/weapon/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "Small glass vial. Looks fragile."
	icon_state = "vial"
	materials = list(MAT_GLASS=500)
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
	materials = list(MAT_METAL=300)
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
