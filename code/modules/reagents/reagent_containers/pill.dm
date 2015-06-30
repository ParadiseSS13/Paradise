////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/pill
	name = "pill"
	desc = "a pill."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "pill"
	possible_transfer_amounts = null
	volume = 50
	var/apply_type = INGEST
	var/apply_method = "swallow"

	New()
		..()
		if(!icon_state)
			icon_state = "pill[rand(1,20)]"

	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		if(M == user)
			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.species.flags & IS_SYNTHETIC)
					H << "<span class='warning'>You have a monitor for a head, where do you think you're going to put that?</span>"
					return

			M << "<span class='notify'>You [apply_method] [src].</span>"
			M.unEquip(src) //icon update
			if(reagents.total_volume)
				reagents.reaction(M, apply_type)
				spawn(0)
					reagents.trans_to_ingest(M, reagents.total_volume)
					qdel(src)
			else
				qdel(src)
			return 1

		else if(istype(M, /mob/living/carbon/human) )

			var/mob/living/carbon/human/H = M
			if(H.species.flags & IS_SYNTHETIC)
				user << "<span class='warning'>They have a monitor for a head, where do you think you're going to put that?</span>"
				return

			for(var/mob/O in viewers(world.view, user))
				O.show_message("<span class='warning'>[user] attempts to force [M] to [apply_method] [src].</span>", 1)

			if(!do_mob(user, M)) return

			user.unEquip(src) //icon update
			for(var/mob/O in viewers(world.view, user))
				O.show_message("<span class='warning'>[user] forces [M] to [apply_method] [src].</span>", 1)

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
			if(M.ckey)
				msg_admin_attack("[user.name] ([user.ckey])[isAntag(user) ? "(ANTAG)" : ""] fed [M.name] ([M.ckey]) with [src.name] Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user

			if(reagents.total_volume)
				reagents.reaction(M, apply_type)
				spawn(0)
					reagents.trans_to_ingest(M, reagents.total_volume)
					qdel(src)
			else
				qdel(src)

			return 1

		return 0

	afterattack(obj/target, mob/user, proximity)
		if(!proximity) return

		if(target.is_open_container() != 0 && target.reagents)
			if(!target.reagents.total_volume)
				user << "<span class='warning'>[target] is empty. Cant dissolve [src].</span>"
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

			user << "<span class='notify'>You dissolve [src] in [target].</span>"
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
/obj/item/weapon/reagent_containers/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"
	New()
		..()
		reagents.add_reagent("toxin", 50)

/obj/item/weapon/reagent_containers/pill/initropidril
	name = "initropidril pill"
	desc = "Don't swallow this."
	icon_state = "pill5"
	New()
		..()
		reagents.add_reagent("initropidril", 50)

/obj/item/weapon/reagent_containers/pill/adminordrazine
	name = "Adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill16"
	New()
		..()
		reagents.add_reagent("adminordrazine", 50)

/obj/item/weapon/reagent_containers/pill/methamphetamine
	name = "Methamphetamine pill"
	desc = "Helps improve the ability to concentrate."
	icon_state = "pill8"
	New()
		..()
		reagents.add_reagent("methamphetamine", 5)

/obj/item/weapon/reagent_containers/pill/haloperidol
	name = "Haloperidol pill"
	desc = "Haloperidol is an anti-psychotic use to treat psychiatric problems."
	icon_state = "pill8"
	New()
		..()
		reagents.add_reagent("haloperidol", 15)

/obj/item/weapon/reagent_containers/pill/paroxetine
	name = "Paroxetine pill"
	desc = "Heavy anti-depressant."
	icon_state = "pill8"
	New()
		..()
		reagents.add_reagent("paroxetine", 15)


/obj/item/weapon/reagent_containers/pill/happy
	name = "Happy pill"
	desc = "Happy happy joy joy!"
	icon_state = "pill18"
	New()
		..()
		reagents.add_reagent("space_drugs", 15)
		reagents.add_reagent("sugar", 15)

/obj/item/weapon/reagent_containers/pill/zoom
	name = "Zoom pill"
	desc = "Zoooom!"
	icon_state = "pill18"
	New()
		..()
		reagents.add_reagent("synaptizine", 5)
		reagents.add_reagent("methamphetamine", 5)

/obj/item/weapon/reagent_containers/pill/charcoal
	name = "Chacoal pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"
	New()
		..()
		reagents.add_reagent("charcoal", 25)

/obj/item/weapon/reagent_containers/pill/salicylic
	name = "Salicylic Acid pill"
	desc = "Commonly used to treat moderate pain and fevers."
	icon_state = "pill4"
	New()
		..()
		reagents.add_reagent("sal_acid", 20)

/obj/item/weapon/reagent_containers/pill/salbutamol
	name = "Salbutamol pill"
	desc = "Used to treat respiratory distress."
	icon_state = "pill8"
	New()
		..()
		reagents.add_reagent("salbutamol", 20)