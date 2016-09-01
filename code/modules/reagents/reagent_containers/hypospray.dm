////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/hypo.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = list(1,2,3,4,5,10,15,20,25,30)
	flags = OPENCONTAINER
	slot_flags = SLOT_BELT
	var/ignore_flags = 0

/obj/item/weapon/reagent_containers/hypospray/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	if(!iscarbon(M))
		return

	if(reagents.total_volume && (ignore_flags || M.can_inject(user, 1))) // Ignore flag should be checked first or there will be an error message.
		to_chat(M, "<span class='warning'>You feel a tiny prick!</span>")
		to_chat(user, "<span class='notice'>You inject [M] with [src].</span>")

		if(M.reagents)
			var/list/injected = list()
			for(var/datum/reagent/R in reagents.reagent_list)
				injected += R.name

			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)

			to_chat(user, "<span class='notice'>[trans] unit\s injected.  [reagents.total_volume] unit\s remaining in [src].</span>")

			var/contained = english_list(injected)

			add_logs(user, M, "injected", src, "([contained])")

/obj/item/weapon/reagent_containers/hypospray/CMO
	list_reagents = list("omnizine" = 30)

/obj/item/weapon/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat."
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	icon_state = "combat_hypo"
	volume = 75
	ignore_flags = 1 // So they can heal their comrades.
	list_reagents = list("epinephrine" = 30, "omnizine" = 30, "teporone" = 15)

/obj/item/weapon/reagent_containers/hypospray/combat/nanites
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with expensive medical nanites for rapid healing."
	volume = 100
	list_reagents = list("nanites" = 100)

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
	list_reagents = list("epinephrine" = 10)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/attack(mob/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	..()
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/update_icon()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/examine()
	..()
	if(reagents && reagents.reagent_list.len)
		to_chat(usr, "<span class='notice'>It is currently loaded.</span>")
	else
		to_chat(usr, "<span class='notice'>It is spent.</span>")

/obj/item/weapon/reagent_containers/hypospray/autoinjector/teporone //basilisks
	name = "teporone autoinjector"
	desc = "A rapid way to regulate your body's temperature in the event of a hardsuit malfunction."
	icon_state = "lepopen"
	list_reagents = list("teporone" = 10)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack //goliath kiting
	name = "stimpack autoinjector"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor."
	icon_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list("methamphetamine" = 10, "coffee" = 10)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimulants
	name = "Stimulants autoinjector"
	desc = "Rapidly stimulates and regernates the body's organ system."
	icon_state = "stimpen"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(50)
	volume = 50
	list_reagents = list("stimulants" = 50)
