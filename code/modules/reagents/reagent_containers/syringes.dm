////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

/obj/item/weapon/reagent_containers/syringe
	name = "Syringe"
	desc = "A syringe."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	w_class = 1
	sharp = 1
	var/mode = SYRINGE_DRAW

	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_self(mob/user as mob)

		switch(mode)
			if(SYRINGE_DRAW)
				mode = SYRINGE_INJECT
			if(SYRINGE_INJECT)
				mode = SYRINGE_DRAW
			if(SYRINGE_BROKEN)
				return
		update_icon()

	attack_hand()
		..()
		update_icon()

	attack_paw()
		return attack_hand()

	attackby(obj/item/I as obj, mob/user as mob, params)

		return

	afterattack(obj/target, mob/user, proximity)
		if(!proximity) return
		if(!target.reagents) return

		if(isliving(target))
			var/mob/living/M = target
			if(!M.can_inject(user, 1))
				return

		if(mode == SYRINGE_BROKEN)
			user << "\red This syringe is broken!"
			return

/*		if (user.a_intent == "harm" && ismob(target))
			if((CLUMSY in user.mutations) && prob(50))
				target = user
			syringestab(target, user)
			return */


		switch(mode)
			if(SYRINGE_DRAW)

				if(reagents.total_volume >= reagents.maximum_volume)
					user << "\red The syringe is full."
					return

				if(ismob(target))//Blood!
					if(istype(target, /mob/living/carbon/slime))
						user << "\red You are unable to locate any blood."
						return
					if(src.reagents.has_reagent("blood"))
						user << "\red There is already a blood sample in this syringe"
						return
					if(istype(target, /mob/living/carbon))//maybe just add a blood reagent to all mobs. Then you can suck them dry...With hundreds of syringes. Jolly good idea.
						var/mob/living/carbon/T = target
						if(!T.dna)
							usr << "You are unable to locate any blood. (To be specific, your target seems to be missing their DNA datum)"
							return
						if(NOCLONE in T.mutations) //target done been et, no more blood in him
							user << "\red You are unable to locate any blood."
							return


						var/time = 30 //Injecting through a hardsuit takes longer due to needing to find a port.
						if(istype(target,/mob/living/carbon/human))
							var/mob/living/carbon/human/H = T
							if((H.species.bloodflags & BLOOD_SLIME) || (H.species.flags & NO_BLOOD))
								usr << "<span class='warning'>You are unable to locate any blood.</span>"
								return
							if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
								time = 60
						if(target == user)
							time = 0
						else
							for(var/mob/O in viewers(world.view, user))
								O.show_message(text("\red <B>[] is trying to take a blood sample from []!</B>", user, target), 1)
						if(!do_mob(user, target, time))
							return

						var/amount = src.reagents.maximum_volume - src.reagents.total_volume
						if(amount == 0)
							usr << "<span class='warning'>The syringe is full!</span>"
							return

						var/datum/reagent/B
						if(istype(T,/mob/living/carbon/human))
							var/mob/living/carbon/human/H = T
							if(H.species && H.species.flags & NO_BLOOD)
								H.reagents.trans_to(src,amount)
							else
								B = T.take_blood(src,amount)
						else
							B = T.take_blood(src,amount)

						if (B)
							src.reagents.reagent_list += B
							src.reagents.update_total()
							src.on_reagent_change()
							src.reagents.handle_reactions()

							user << "\blue You take a blood sample from [target]"
							for(var/mob/O in viewers(4, user))
								O.show_message("\red [user] takes a blood sample from [target].", 1)

				else //if not mob
					if(!target.reagents.total_volume)
						user << "\red [target] is empty."
						return

					if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers) && !istype(target,/obj/item/slime_extract))
						user << "\red You cannot directly remove reagents from this object."
						return

					var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

					user << "\blue You fill the syringe with [trans] units of the solution."
				if (reagents.total_volume >= reagents.maximum_volume)
					mode=!mode
					update_icon()

			if(SYRINGE_INJECT)
				if(!reagents.total_volume)
					user << "\red The Syringe is empty."
					return
				if(istype(target, /obj/item/weapon/implantcase/chem))
					return

				if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/slime_extract) && !istype(target, /obj/item/clothing/mask/cigarette) && !istype(target, /obj/item/weapon/storage/fancy/cigarettes))
					user << "\red You cannot directly fill this object."
					return
				if(istype(target, /obj/item/clothing/mask/cigarette))
					var/obj/item/clothing/mask/cigarette/C = target
					if(istype(C.loc, /obj/item/weapon/storage/fancy/cigarettes))
						user << "\red You cannot inject a cigarette while it's still in the pack."
						return
				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					user << "\red [target] is full."
					return

				if(ismob(target) && target != user)
					var/time = 30 //Injecting through a hardsuit takes longer due to needing to find a port.
					if(istype(target,/mob/living/carbon/human))
						var/mob/living/carbon/human/H = target
						if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
							time = 60

					for(var/mob/O in viewers(world.view, user))
						if(time == 30)
							O.show_message(text("\red <B>[] is trying to inject []!</B>", user, target), 1)
						else
							O.show_message(text("\red <B>[] begins hunting for an injection port on []'s suit!</B>", user, target), 1)

					if(!do_mob(user, target, time)) return

					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red [] injects [] with the syringe!", user, target), 1)

					if(istype(target,/mob/living))
						var/mob/living/M = target
						var/list/injected = list()
						for(var/datum/reagent/R in src.reagents.reagent_list)
							injected += R.name
						var/contained = english_list(injected)
						M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
						user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject [M.name] ([M.key]). Reagents: [contained]</font>")
						if(M.ckey)
							msg_admin_attack("[user.name] ([user.ckey])[isAntag(user) ? "(ANTAG)" : ""] injected [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
						if(!iscarbon(user))
							M.LAssailant = null
						else
							M.LAssailant = user

					src.reagents.reaction(target, INGEST)
				if(ismob(target) && target == user)
					src.reagents.reaction(target, INGEST)

				if(isobj(target))
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

				spawn(5)
					var/datum/reagent/blood/B
					for(var/datum/reagent/blood/d in src.reagents.reagent_list)
						B = d
						break
					var/datum/reagent/water/W
					for(var/datum/reagent/water/r in src.reagents.reagent_list)
						W = r
						break
					var/trans
					if(W && istype(target,/mob/living/carbon/human/slime))
						var/mob/living/carbon/human/slime/S = target
						S.vessel.add_reagent("water", 5)
						S.vessel.update_total()
					if(B && istype(target,/mob/living/carbon))
						if(istype(target,/mob/living/carbon/human/slime))
							var/mob/living/carbon/human/slime/S = target
							S.reagents.add_reagent("blood", 5)
							S.reagents.update_total()
						else
							var/mob/living/carbon/C = target
							C.inject_blood(src,5)
					else
						trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
					user << "\blue You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units."
					if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
						mode = SYRINGE_DRAW
						update_icon()

		return

	update_icon()
		if(mode == SYRINGE_BROKEN)
			icon_state = "broken"
			overlays.Cut()
			return
		var/rounded_vol = round(reagents.total_volume,5)
		overlays.Cut()
		if(ismob(loc))
			var/injoverlay
			switch(mode)
				if (SYRINGE_DRAW)
					injoverlay = "draw"
				if (SYRINGE_INJECT)
					injoverlay = "inject"
			overlays += injoverlay
		icon_state = "[rounded_vol]"
		item_state = "syringe_[rounded_vol]"

		if(reagents.total_volume)
			var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")

			filling.icon_state = "syringe[rounded_vol]"

			filling.icon += mix_color_from_reagents(reagents.reagent_list)
			overlays += filling


	/obj/item/weapon/reagent_containers/syringe/proc/syringestab(mob/living/carbon/target as mob, mob/living/carbon/user as mob)

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [target.name] ([target.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
		if(target.ckey)
			msg_admin_attack("[user.name] ([user.ckey])[isAntag(user) ? "(ANTAG)" : ""] attacked [target.name] ([target.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = user

		if(istype(target, /mob/living/carbon/human))

			var/target_zone = ran_zone(check_zone(user.zone_sel.selecting, target))
			var/obj/item/organ/external/affecting = target:get_organ(target_zone)

			if (!affecting || (affecting.status & ORGAN_DESTROYED) || affecting.is_stump())
				user << "<span class='danger'>They are missing that limb!</span>"
				return
			var/hit_area = affecting.name

			var/mob/living/carbon/human/H = target
			if((user != target) && H.check_shields(7, "the [src.name]"))
				return

			if (target != user && target.getarmor(target_zone, "melee") > 5 && prob(50))
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red <B>[user] tries to stab [target] in \the [hit_area] with [src.name], but the attack is deflected by armor!</B>"), 1)
				user.unEquip(src)
				del(src)
				return

			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red <B>[user] stabs [target] in \the [hit_area] with [src.name]!</B>"), 1)

			if(affecting.take_damage(3))
				target:UpdateDamageIcon()

		else
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red <B>[user] stabs [target] with [src.name]!</B>"), 1)
			target.take_organ_damage(3)// 7 is the same as crowbar punch

		src.reagents.reaction(target, INGEST)
		var/syringestab_amount_transferred = rand(0, (reagents.total_volume - 5)) //nerfed by popular demand
		src.reagents.trans_to(target, syringestab_amount_transferred)
		src.desc += " It is broken."
		src.mode = SYRINGE_BROKEN
		src.add_blood(target)
		src.add_fingerprint(usr)
		src.update_icon()


/obj/item/weapon/reagent_containers/ld50_syringe
	name = "Lethal Injection Syringe"
	desc = "A syringe used for lethal injections."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null //list(5,10,15)
	volume = 50
	var/mode = SYRINGE_DRAW

	on_reagent_change()
		update_icon()

	pickup(mob/user)
		..()
		update_icon()

	dropped(mob/user)
		..()
		update_icon()

	attack_self(mob/user as mob)
		mode = !mode
		update_icon()

	attack_hand()
		..()
		update_icon()

	attack_paw()
		return attack_hand()

	attackby(obj/item/I as obj, mob/user as mob)

		return

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		switch(mode)
			if(SYRINGE_DRAW)

				if(reagents.total_volume >= reagents.maximum_volume)
					user << "\red The syringe is full."
					return

				if(ismob(target))
					if(istype(target, /mob/living/carbon))//I Do not want it to suck 50 units out of people
						usr << "This needle isn't designed for drawing blood."
						return
				else //if not mob
					if(!target.reagents.total_volume)
						user << "\red [target] is empty."
						return

					if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
						user << "\red You cannot directly remove reagents from this object."
						return

					var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

					user << "\blue You fill the syringe with [trans] units of the solution."
				if (reagents.total_volume >= reagents.maximum_volume)
					mode=!mode
					update_icon()

			if(SYRINGE_INJECT)
				if(!reagents.total_volume)
					user << "\red The Syringe is empty."
					return
				if(istype(target, /obj/item/weapon/implantcase/chem))
					return
				if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food))
					user << "\red You cannot directly fill this object."
					return
				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					user << "\red [target] is full."
					return

				if(ismob(target) && target != user)
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red <B>[] is trying to inject [] with a giant syringe!</B>", user, target), 1)
					if(!do_mob(user, target, 300)) return
					for(var/mob/O in viewers(world.view, user))
						O.show_message(text("\red [] injects [] with a giant syringe!", user, target), 1)
					src.reagents.reaction(target, INGEST)
				if(ismob(target) && target == user)
					src.reagents.reaction(target, INGEST)
				spawn(5)
					var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
					user << "\blue You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units."
					if (reagents.total_volume >= reagents.maximum_volume && mode==SYRINGE_INJECT)
						mode = SYRINGE_DRAW
						update_icon()
		return


	update_icon()
		var/rounded_vol = round(reagents.total_volume,50)
		if(ismob(loc))
			var/mode_t
			switch(mode)
				if (SYRINGE_DRAW)
					mode_t = "d"
				if (SYRINGE_INJECT)
					mode_t = "i"
			icon_state = "[mode_t][rounded_vol]"
		else
			icon_state = "[rounded_vol]"
		item_state = "syringe_[rounded_vol]"


////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////


/obj/item/weapon/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	New()
		..()
		reagents.add_reagent("spaceacillin", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/lethal
	New()
		..()
		reagents.add_reagent("sulfonal", 4)
		reagents.add_reagent("pancuronium", 6)
		reagents.add_reagent("neurotoxin2", 40)
		mode = SYRINGE_INJECT
		update_icon()


//Robot syringes
//Not special in any way, code wise. They don't have added variables or procs.
/obj/item/weapon/reagent_containers/syringe/robot/charcoal
	name = "Syringe (charcoal)"
	desc = "Contains charcoal."
	New()
		..()
		reagents.add_reagent("charcoal", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/epinephrine
	name = "Syringe (Epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	New()
		..()
		reagents.add_reagent("epinephrine", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/mixed
	name = "Syringe (mixed)"
	desc = "Contains epinephrine & charcoal."
	New()
		..()
		reagents.add_reagent("epinephrine", 7)
		reagents.add_reagent("charcoal", 8)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/charcoal
	name = "Syringe (charcoal)"
	desc = "Contains charcoal - used to treat toxins and damage from toxins."
	New()
		..()
		reagents.add_reagent("charcoal", 15)
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/insulin
	name = "Syringe (insulin)"
	desc = "Contains insulin - used to treat diabetes."
	New()
		..()
		reagents.add_reagent("insulin", 15)
		mode = SYRINGE_INJECT
		update_icon()