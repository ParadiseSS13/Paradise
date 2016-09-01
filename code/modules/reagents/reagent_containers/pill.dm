////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/pill
	name = "pill"
	desc = "a pill."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "pill"
	possible_transfer_amounts = null
	volume = 50
	consume_sound = null

/obj/item/weapon/reagent_containers/food/pill/New()
	..()
	if(!icon_state)
		icon_state = "pill[rand(1,20)]"

/obj/item/weapon/reagent_containers/food/pill/attack_self(mob/user)
	return

/obj/item/weapon/reagent_containers/food/pill/attack(mob/living/carbon/M, mob/user, def_zone)
	if(!istype(M))
		return 0
	bitesize = reagents.total_volume
	if(M.eat(src, user))
		spawn(0)
			qdel(src)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/pill/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return

	if(target.is_open_container() != 0 && target.reagents)
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty. Cant dissolve [src].</span>")
			return

		to_chat(user, "<span class='notify'>You dissolve [src] in [target].</span>")
		reagents.trans_to(target, reagents.total_volume)
		for(var/mob/O in viewers(2, user))
			O.show_message("<span class='warning'>[user] puts something in [target].</span>", 1)
		spawn(5)
			qdel(src)

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/weapon/reagent_containers/food/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"
	list_reagents = list("toxin" = 50)

/obj/item/weapon/reagent_containers/food/pill/initropidril
	name = "initropidril pill"
	desc = "Don't swallow this."
	icon_state = "pill5"
	list_reagents = list("initropidril" = 50)

/obj/item/weapon/reagent_containers/food/pill/adminordrazine
	name = "Adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill16"
	list_reagents = list("adminordrazine" = 50)

/obj/item/weapon/reagent_containers/food/pill/methamphetamine
	name = "Methamphetamine pill"
	desc = "Helps improve the ability to concentrate."
	icon_state = "pill8"
	list_reagents = list("methamphetamine" = 5)

/obj/item/weapon/reagent_containers/food/pill/haloperidol
	name = "Haloperidol pill"
	desc = "Haloperidol is an anti-psychotic use to treat psychiatric problems."
	icon_state = "pill8"
	list_reagents = list("haloperidol" = 15)

/obj/item/weapon/reagent_containers/food/pill/paroxetine
	name = "Paroxetine pill"
	desc = "Heavy anti-depressant."
	icon_state = "pill8"
	list_reagents = list("paroxetine" = 15)

/obj/item/weapon/reagent_containers/food/pill/happy
	name = "Happy pill"
	desc = "Happy happy joy joy!"
	icon_state = "pill18"
	list_reagents = list("space_drugs" = 15, "sugar" = 15)

/obj/item/weapon/reagent_containers/food/pill/zoom
	name = "Zoom pill"
	desc = "Zoooom!"
	icon_state = "pill18"
	list_reagents = list("synaptizine" = 5, "methamphetamine" = 5)

/obj/item/weapon/reagent_containers/food/pill/charcoal
	name = "Charcoal pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"
	list_reagents = list("charcoal" = 25)

/obj/item/weapon/reagent_containers/food/pill/salicylic
	name = "Salicylic Acid pill"
	desc = "Commonly used to treat moderate pain and fevers."
	icon_state = "pill4"
	list_reagents = list("sal_acid" = 20)

/obj/item/weapon/reagent_containers/food/pill/salbutamol
	name = "Salbutamol pill"
	desc = "Used to treat respiratory distress."
	icon_state = "pill8"
	list_reagents = list("salbutamol" = 20)