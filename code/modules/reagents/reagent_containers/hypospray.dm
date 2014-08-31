////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = list(1,2,3,4,5,10,15,20,25,30)
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	slot_flags = SLOT_BELT

/obj/item/weapon/reagent_containers/hypospray/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/item/weapon/reagent_containers/hypospray/New() //comment this to make hypos start off empty
	..()
	reagents.add_reagent("tricordrazine", 30)
	return

/obj/item/weapon/reagent_containers/hypospray/attack(mob/M as mob, mob/user as mob)
	if(!reagents.total_volume)
		user << "\red [src] is empty."
		return
	if (!( istype(M, /mob) ))
		return
	if (reagents.total_volume)
		user << "\blue You inject [M] with [src]."
		M << "\red You feel a tiny prick!"

		src.reagents.reaction(M, INGEST)
		if(M.reagents)

			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject [M.name] ([M.key]). Reagents: [contained]</font>")
			if(M.ckey)
				msg_admin_attack("[user.name] ([user.ckey]) injected [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user

			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			user << "\blue [trans] units injected. [reagents.total_volume] units remaining in [src]."

	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector
	name = "emergency autoinjector"
	desc = "A potent mix of pain killers and muscle stimulants."
	icon_state = "autoinjector"
	item_state = "autoinjector"
	amount_per_transfer_from_this = 5
	volume = 5

/obj/item/weapon/reagent_containers/hypospray/autoinjector/New()
	..()
	reagents.remove_reagent("tricordrazine", 30)
	reagents.add_reagent("tramadol", 4)
	reagents.add_reagent("hyperzine", 1)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/attack(mob/M as mob, mob/user as mob)
	..()
	if(reagents.total_volume <= 0) //Prevents autoinjectors to be refilled.
		flags &= ~OPENCONTAINER
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/update_icon()
	if(reagents.total_volume > 0)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/examine()
	..()
	if(reagents && reagents.reagent_list.len)
		usr << "\blue It is currently loaded."
	else
		usr << "\blue It is spent."


/obj/item/weapon/reagent_containers/hypospray/hyperzine
	name = "emergency stimulant autoinjector"
	desc = "A potent mix of pain killers and muscle stimulants."
	icon_state = "autoinjector"
	item_state = "autoinjector"
	amount_per_transfer_from_this = 5
	volume = 5

/obj/item/weapon/reagent_containers/hypospray/hyperzine/New()
	..()
	reagents.add_reagent("hyperzine", 5)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/hyperzine/attack(mob/M as mob, mob/user as mob)
	..()