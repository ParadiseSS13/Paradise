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

	New()
		..()
		if(!icon_state)
			icon_state = "pill[rand(1,20)]"

/obj/item/weapon/reagent_containers/food/pill/attack_self(mob/user as mob)
		return
/obj/item/weapon/reagent_containers/food/pill/attack(var/mob/living/carbon/M, mob/user as mob, def_zone)
	if(!istype(M))
		return 0
	bitesize = reagents.total_volume
	if(M.eat(src, user))
		spawn(0)
			qdel(src)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/pill/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return

	if(target.is_open_container() != 0 && target.reagents)
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty. Cant dissolve [src].</span>")

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

		to_chat(user, "<span class='notify'>You dissolve [src] in [target].</span>")

		reagents.trans_to(target, reagents.total_volume)
		for(var/mob/O in viewers(2, user))
			O.show_message("<span class='warning'>[user] puts something in [target].</span>", 1)
		spawn(5)
			qdel(src)

	return

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/weapon/reagent_containers/food/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"
	New()
		..()
		reagents.add_reagent("toxin", 50)

/obj/item/weapon/reagent_containers/food/pill/initropidril
	name = "initropidril pill"
	desc = "Don't swallow this."
	icon_state = "pill5"
	New()
		..()
		reagents.add_reagent("initropidril", 50)

/obj/item/weapon/reagent_containers/food/pill/adminordrazine
	name = "Adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill16"
	New()
		..()
		reagents.add_reagent("adminordrazine", 50)

/obj/item/weapon/reagent_containers/food/pill/methamphetamine
	name = "Methamphetamine pill"
	desc = "Helps improve the ability to concentrate."
	icon_state = "pill8"
	New()
		..()
		reagents.add_reagent("methamphetamine", 5)

/obj/item/weapon/reagent_containers/food/pill/haloperidol
	name = "Haloperidol pill"
	desc = "Haloperidol is an anti-psychotic use to treat psychiatric problems."
	icon_state = "pill8"
	New()
		..()
		reagents.add_reagent("haloperidol", 15)

/obj/item/weapon/reagent_containers/food/pill/paroxetine
	name = "Paroxetine pill"
	desc = "Heavy anti-depressant."
	icon_state = "pill8"
	New()
		..()
		reagents.add_reagent("paroxetine", 15)


/obj/item/weapon/reagent_containers/food/pill/happy
	name = "Happy pill"
	desc = "Happy happy joy joy!"
	icon_state = "pill18"
	New()
		..()
		reagents.add_reagent("space_drugs", 15)
		reagents.add_reagent("sugar", 15)

/obj/item/weapon/reagent_containers/food/pill/zoom
	name = "Zoom pill"
	desc = "Zoooom!"
	icon_state = "pill18"
	New()
		..()
		reagents.add_reagent("synaptizine", 5)
		reagents.add_reagent("methamphetamine", 5)

/obj/item/weapon/reagent_containers/food/pill/charcoal
	name = "Charcoal pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"
	New()
		..()
		reagents.add_reagent("charcoal", 25)

/obj/item/weapon/reagent_containers/food/pill/salicylic
	name = "Salicylic Acid pill"
	desc = "Commonly used to treat moderate pain and fevers."
	icon_state = "pill4"
	New()
		..()
		reagents.add_reagent("sal_acid", 20)

/obj/item/weapon/reagent_containers/food/pill/salbutamol
	name = "Salbutamol pill"
	desc = "Used to treat respiratory distress."
	icon_state = "pill8"
	New()
		..()
		reagents.add_reagent("salbutamol", 20)