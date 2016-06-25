/obj/item/weapon/reagent_containers/drugs
	name = " "
	var/base_name = " "
	desc = " "
	icon = 'icons/obj/chemical.dmi'
	icon_state = "baggie"
	item_state = "beaker"
	amount_per_transfer_from_this = 2
	possible_transfer_amounts = 2
	volume = 10
	flags = OPENCONTAINER

	var/label_text = ""

	New()
		..()
		src.pixel_x = rand(-10.0, 10) //Randomizes postion
		src.pixel_y = rand(-10.0, 10)
		base_name = name

	afterattack(obj/target, mob/user, proximity)
		if(!proximity) return

		if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume && target.reagents)
				to_chat(user, "\red [target] is empty.")
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "\red [src] is full.")
				return

			for(var/datum/reagent/A in target.reagents.reagent_list)
				if(A.reagent_state != 1)
					to_chat(user, "\red You can only put powders in [src].")
					return

			var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
			to_chat(user, "\blue You fill [src] with [trans] units of the contents of [target].")

		else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				to_chat(user, "\red [src] is empty.")
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "\red [target] is full.")
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

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, "\blue You transfer [trans] units of the solution to [target].")

		//Safety for dumping stuff into a ninja suit. It handles everything through attackby() and this is unnecessary.

		/*else if(istype(target, /obj/machinery/bunsen_burner))
			return

		else if(istype(target, /obj/machinery/radiocarbon_spectrometer))
			return*/


	attackby(obj/item/weapon/W as obj, mob/user as mob, params)
		if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/device/flashlight/pen))
			var/tmp_label = sanitize(input(user, "Enter a label for [src.name]","Label",src.label_text))
			if(length(tmp_label) > 10)
				to_chat(user, "\red The label can be at most 10 characters long.")
			else
				to_chat(user, "\blue You set the label to \"[tmp_label]\".")
				src.label_text = tmp_label
				src.update_name_label()

	proc/update_name_label()
		if(src.label_text == "")
			src.name = src.base_name
		else
			src.name = "[src.base_name] ([src.label_text])"

/obj/item/weapon/reagent_containers/drugs/baggie
	name = "baggie"
	desc = "A baggie. Can hold up to 10 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "baggie"
	item_state = "beaker"

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
			var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]2")

			switch(reagents.total_volume)
				if(0 to 2)	filling.icon_state = "[icon_state]2"
				if(3 to 4) 	filling.icon_state = "[icon_state]4"
				if(5 to 6)	filling.icon_state = "[icon_state]6"
				if(7 to 8)	filling.icon_state = "[icon_state]8"
				if(9 to 10)	filling.icon_state = "[icon_state]10"


			filling.icon += mix_color_from_reagents(reagents.reagent_list)
			overlays += filling

/obj/item/weapon/reagent_containers/drugs/baggie/meth
	New()
		..()
		reagents.add_reagent("methamphetamine", 10)