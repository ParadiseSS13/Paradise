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
	flags = OPENCONTAINER
	slot_flags = SLOT_BELT
	var/ignore_flags = 0

/obj/item/weapon/reagent_containers/hypospray/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		user << "\red [src] is empty."
		return
	if(!istype(M))
		return
	if(reagents.total_volume && (ignore_flags || M.can_inject(user, 1)))
		user << "\blue You inject [M] with [src]."
		M << "\red You feel a tiny prick!"

		src.reagents.add_reagent(M)
		if(M.reagents)

			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [src.name] by [key_name(user)]. Reagents: [contained]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject [key_name(M)]. Reagents: [contained]</font>")
			if(M.ckey)
				msg_admin_attack("[key_name_admin(user)] injected [key_name_admin(M)] with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)])")
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user

			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			user << "\blue [trans] units injected. [reagents.total_volume] units remaining in [src]."

	return

/obj/item/weapon/reagent_containers/hypospray/CMO/New()
	..()
	reagents.add_reagent("omnizine", 30)

/obj/item/weapon/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat."
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	icon_state = "combat_hypo"
	volume = 60
	ignore_flags = 1 // So they can heal their comrades.

/obj/item/weapon/reagent_containers/hypospray/combat/New()
	..()
	reagents.add_reagent("synaptizine", 30)

/obj/item/weapon/reagent_containers/hypospray/combat/nanites
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector filled with expensive regeneration nanites."
	volume = 100

/obj/item/weapon/reagent_containers/hypospray/combat/nanites/New()
	..()
	reagents.add_reagent("nanites", 70)

/obj/item/weapon/reagent_containers/hypospray/autoinjector
	name = "emergency autoinjector"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge."
	icon_state = "autoinjector"
	item_state = "autoinjector"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	volume = 10
	ignore_flags = 1 //so you can medipen through hardsuits
	flags = null

/obj/item/weapon/reagent_containers/hypospray/autoinjector/New()
	..()
	reagents.add_reagent("epinephrine", 10)
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

/obj/item/weapon/reagent_containers/hypospray/autoinjector/teporone //basilisks
	name = "teporone autoinjector"
	desc = "A rapid way to regulate your body's temperature in the event of a hardsuit malfunction at the cost of some shortness of breath."
	icon_state = "lepopen"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/teporone/New()
	..()
	reagents.remove_reagent("epinephrine", 10)
	reagents.add_reagent("teporone", 9)
	reagents.add_reagent("lexorin", 1)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack //goliath kiting
	name = "stimpack autoinjector"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor at the cost of some shortness of breath."
	icon_state = "stimpen"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack/New()
	..()
	reagents.remove_reagent("epinephrine", 10)
	reagents.add_reagent("methamphetamine", 9)
	reagents.add_reagent("lexorin", 1)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimulants
	name = "Stimulants autoinjector"
	desc = "Rapidly stimulates and regernates the body's organ system."
	icon_state = "stimpen"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(50)
	volume = 50

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimulants/New()
	..()
	reagents.remove_reagent("epinephrine", 10)
	reagents.add_reagent("stimulants", 50)
	update_icon()
	return