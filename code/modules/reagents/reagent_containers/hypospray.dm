////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	icon_override = 'icons/mob/in-hand/tools.dmi'
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = list(1,2,3,4,5,10,15,20,25,30)
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	slot_flags = SLOT_BELT

/obj/item/weapon/reagent_containers/hypospray/attack_paw(mob/user as mob)
	return src.attack_hand(user)


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

/obj/item/weapon/reagent_containers/hypospray/CMO/New()
	..()
	reagents.add_reagent("doctorsdelight", 30)

/obj/item/weapon/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat."
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	icon_state = "combat_hypo"
	volume = 60

/obj/item/weapon/reagent_containers/hypospray/combat/New()
	..()
	reagents.add_reagent("synaptizine", 30)


/obj/item/weapon/reagent_containers/hypospray/autoinjector
	name = "emergency autoinjector"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge."
	icon_state = "autoinjector"
	item_state = "autoinjector"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	volume = 10
	flags = null

/obj/item/weapon/reagent_containers/hypospray/autoinjector/New()
	..()
	reagents.add_reagent("inaprovaline", 10)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/attack(mob/M as mob, mob/user as mob)
	..()
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

/obj/item/weapon/reagent_containers/hypospray/autoinjector/leporazine //basilisks
	name = "leporazine autoinjector"
	desc = "A rapid way to regulate your body's temperature in the event of a hardsuit malfunction at the cost of some shortness of breath."
	icon_state = "lepopen"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/leporazine/New()
	..()
	reagents.remove_reagent("inaprovaline", 10)
	reagents.add_reagent("leporazine", 9)
	reagents.add_reagent("lexorin", 1)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack //goliath kiting
	name = "stimpack autoinjector"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor at the cost of some shortness of breath."
	icon_state = "stimpen"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack/New()
	..()
	reagents.remove_reagent("inaprovaline", 10)
	reagents.add_reagent("hyperzine", 9)
	reagents.add_reagent("lexorin", 1)
	update_icon()
	return