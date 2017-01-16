////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

/obj/item/weapon/reagent_containers/syringe
	name = "Syringe"
	desc = "A syringe."
	icon = 'icons/goonstation/objects/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	w_class = 1
	sharp = 1
	var/mode = SYRINGE_DRAW
	var/projectile_type = /obj/item/projectile/bullet/dart/syringe

/obj/item/weapon/reagent_containers/syringe/New()
	..()
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_self(mob/user)
	switch(mode)
		if(SYRINGE_DRAW)
			mode = SYRINGE_INJECT
		if(SYRINGE_INJECT)
			mode = SYRINGE_DRAW
		if(SYRINGE_BROKEN)
			return
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack(mob/living/M, mob/living/user, def_zone)
	return

/obj/item/weapon/reagent_containers/syringe/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/storage/bag))
		..()
	return

/obj/item/weapon/reagent_containers/syringe/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return
	if(!target.reagents) return

	if(isliving(target))
		var/mob/living/M = target
		if(!M.can_inject(user, 1))
			return

	if(mode == SYRINGE_BROKEN)
		to_chat(user, "\red This syringe is broken!")
		return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "\red The syringe is full.")
				return

			if(ismob(target))//Blood!
				if(istype(target, /mob/living/carbon/slime))
					to_chat(user, "\red You are unable to locate any blood.")
					return
				if(reagents.has_reagent("blood"))
					to_chat(user, "\red There is already a blood sample in this syringe")
					return
				if(istype(target, /mob/living/carbon))//maybe just add a blood reagent to all mobs. Then you can suck them dry...With hundreds of syringes. Jolly good idea.
					var/mob/living/carbon/T = target
					if(!T.dna)
						to_chat(usr, "You are unable to locate any blood. (To be specific, your target seems to be missing their DNA datum)")
						return
					if(NOCLONE in T.mutations) //target done been et, no more blood in him
						to_chat(user, "\red You are unable to locate any blood.")
						return


					var/time = 30
					if(istype(target,/mob/living/carbon/human))
						var/mob/living/carbon/human/H = T
						if(H.species.flags & NO_BLOOD)
							to_chat(usr, "<span class='warning'>You are unable to locate any blood.</span>")
							return
					if(target == user)
						time = 0
					else
						for(var/mob/O in viewers(world.view, user))
							O.show_message(text("<span class='danger'>[] is trying to take a blood sample from []!</span>", user, target), 1)
					if(!do_mob(user, target, time))
						return

					var/amount = reagents.maximum_volume - reagents.total_volume
					if(amount == 0)
						to_chat(usr, "<span class='warning'>The syringe is full!</span>")
						return

					var/datum/reagent/B
					if(istype(T,/mob/living/carbon/human))
						var/mob/living/carbon/human/H = T
						if(H.species && H.species.exotic_blood && H.vessel.total_volume)
							H.vessel.trans_to(src,amount)
						else
							B = T.take_blood(src,amount)
					else
						B = T.take_blood(src,amount)

					if(B)
						reagents.reagent_list |= B
						reagents.update_total()
						on_reagent_change()
						reagents.handle_reactions()

						to_chat(user, "\blue You take a blood sample from [target]")
						for(var/mob/O in viewers(4, user))
							O.show_message("\red [user] takes a blood sample from [target].", 1)
					else
						user.visible_message("<span class='warning'>[user] takes a sample from [target].</span>", "<span class='notice'>You take a sample from [target].</span>")

			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "\red [target] is empty.")
					return

				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers) && !istype(target,/obj/item/slime_extract))
					to_chat(user, "\red You cannot directly remove reagents from this object.")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "\blue You fill the syringe with [trans] units of the solution.")
			if(reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "\red The Syringe is empty.")
				return
			if(istype(target, /obj/item/weapon/implantcase/chem))
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/slime_extract) && !istype(target, /obj/item/clothing/mask/cigarette) && !istype(target, /obj/item/weapon/storage/fancy/cigarettes))
				to_chat(user, "\red You cannot directly fill this object.")
				return
			if(istype(target, /obj/item/clothing/mask/cigarette))
				var/obj/item/clothing/mask/cigarette/C = target
				if(istype(C.loc, /obj/item/weapon/storage/fancy/cigarettes))
					to_chat(user, "\red You cannot inject a cigarette while it's still in the pack.")
					return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "\red [target] is full.")
				return

			var/mob/living/carbon/human/H = target
			if(istype(H))
				var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
				if(!affected)
					to_chat(user, "<span class='danger'>\The [H] is missing that limb!</span>")
					return
				/* else if(affected.status & ORGAN_ROBOT)
					to_chat(user, "<span class='danger'>You cannot inject a robotic limb.</span>")
					return */

			if(ismob(target) && target != user)
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("<span class='danger'>[] is trying to inject []!</span>", user, target), 1)

				if(!do_mob(user, target, 30)) return

				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red [] injects [] with the syringe!", user, target), 1)

				if(istype(target,/mob/living))
					var/mob/living/M = target
					var/list/injected = list()
					for(var/datum/reagent/R in reagents.reagent_list)
						injected += R.name
					var/contained = english_list(injected)
					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [key_name(user)]. Reagents: [contained]</font>")
					user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to inject [key_name(M)]. Reagents: [contained]</font>")
					if(M.ckey)
						msg_admin_attack("[key_name_admin(user)] injected [key_name_admin(M)] with [name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)])")
					if(!iscarbon(user))
						M.LAssailant = null
					else
						M.LAssailant = user

				reagents.reaction(target, INGEST)
			if(ismob(target) && target == user)
				reagents.reaction(target, INGEST)

			spawn(5)
				var/datum/reagent/blood/B
				for(var/datum/reagent/blood/d in reagents.reagent_list)
					B = d
					break
				var/trans
				if(B && istype(target,/mob/living/carbon))
					var/mob/living/carbon/C = target
					C.inject_blood(src, 5)
				else
					trans = reagents.trans_to(target, amount_per_transfer_from_this)
					to_chat(user, "\blue You inject [trans] units of the solution. The syringe now contains [reagents.total_volume] units.")
					if(istype(target, /obj/item/weapon/reagent_containers/food/pill/patch))
						var/obj/item/weapon/reagent_containers/food/pill/patch/P = target
						if(P.instant_application)
							to_chat(user, "<span class=warning>You break the medical seal on the [P]!</span>")
							P.instant_application = 0

				if(reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
					mode = SYRINGE_DRAW
					update_icon()

	return

/obj/item/weapon/reagent_containers/syringe/update_icon()
	if(mode == SYRINGE_BROKEN)
		icon_state = "broken"
		overlays.Cut()
		return
	var/rounded_vol = round(reagents.total_volume,5)
	overlays.Cut()
	if(ismob(loc))
		var/injoverlay
		switch(mode)
			if(SYRINGE_DRAW)
				injoverlay = "draw"
			if(SYRINGE_INJECT)
				injoverlay = "inject"
		overlays += injoverlay
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")

		filling.icon_state = "syringe[rounded_vol]"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/ld50_syringe
	name = "Lethal Injection Syringe"
	desc = "A syringe used for lethal injections."
	icon = 'icons/goonstation/objects/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null //list(5,10,15)
	volume = 50
	var/mode = SYRINGE_DRAW

/obj/item/weapon/reagent_containers/ld50_syringe/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attackby(obj/item/I, mob/user)
	return

/obj/item/weapon/reagent_containers/ld50_syringe/afterattack(obj/target, mob/user , flag)
	if(!target.reagents)
		return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "\red The syringe is full.")
				return

			if(ismob(target))
				if(istype(target, /mob/living/carbon))//I Do not want it to suck 50 units out of people
					to_chat(usr, "This needle isn't designed for drawing blood.")
					return
			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "\red [target] is empty.")
					return

				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
					to_chat(user, "\red You cannot directly remove reagents from this object.")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "\blue You fill the syringe with [trans] units of the solution.")
			if(reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "\red The Syringe is empty.")
				return
			if(istype(target, /obj/item/weapon/implantcase/chem))
				return
			if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food))
				to_chat(user, "\red You cannot directly fill this object.")
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "\red [target] is full.")
				return

			if(ismob(target) && target != user)
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("<span class='danger'>[] is trying to inject [] with a giant syringe!</span>", user, target), 1)
				if(!do_mob(user, target, 300)) return
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red [] injects [] with a giant syringe!", user, target), 1)
				reagents.reaction(target, INGEST)
			if(ismob(target) && target == user)
				reagents.reaction(target, INGEST)
			spawn(5)
				var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
				to_chat(user, "\blue You inject [trans] units of the solution. The syringe now contains [reagents.total_volume] units.")
				if(reagents.total_volume >= reagents.maximum_volume && mode==SYRINGE_INJECT)
					mode = SYRINGE_DRAW
					update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/update_icon()
	var/rounded_vol = round(reagents.total_volume,50)
	if(ismob(loc))
		var/mode_t
		switch(mode)
			if(SYRINGE_DRAW)
				mode_t = "d"
			if(SYRINGE_INJECT)
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
	list_reagents = list("spaceacillin" = 15)

/obj/item/weapon/reagent_containers/ld50_syringe/lethal
	list_reagents = list("cyanide" = 10, "neurotoxin2" = 40)

/obj/item/weapon/reagent_containers/syringe/charcoal
	name = "Syringe (charcoal)"
	desc = "Contains charcoal - used to treat toxins and damage from toxins."
	list_reagents = list("charcoal" = 15)

/obj/item/weapon/reagent_containers/syringe/epinephrine
	name = "Syringe (Epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	list_reagents = list("epinephrine" = 15)

/obj/item/weapon/reagent_containers/syringe/insulin
	name = "Syringe (insulin)"
	desc = "Contains insulin - used to treat diabetes."
	list_reagents = list("insulin" = 15)

/obj/item/weapon/reagent_containers/syringe/bioterror
	name = "bioterror syringe"
	desc = "Contains several paralyzing reagents."
	list_reagents = list("neurotoxin" = 5, "capulettium_plus" = 5, "sodium_thiopental" = 5)