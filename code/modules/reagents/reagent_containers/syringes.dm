////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

/obj/item/reagent_containers/syringe
	name = "Syringe"
	desc = "A syringe."
	icon = 'icons/goonstation/objects/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	w_class = WEIGHT_CLASS_TINY
	sharp = 1
	container_type = TRANSPARENT
	var/busy = 0
	var/mode = SYRINGE_DRAW
	var/projectile_type = /obj/item/projectile/bullet/dart/syringe

/obj/item/reagent_containers/syringe/New()
	..()
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_self(mob/user)
	switch(mode)
		if(SYRINGE_DRAW)
			mode = SYRINGE_INJECT
		if(SYRINGE_INJECT)
			mode = SYRINGE_DRAW
		if(SYRINGE_BROKEN)
			return
	update_icon()

/obj/item/reagent_containers/syringe/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attack(mob/living/M, mob/living/user, def_zone)
	return

/obj/item/reagent_containers/syringe/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/storage/bag))
		..()
	return

/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(!target.reagents)
		return

	var/mob/living/L
	if(isliving(target))
		L = target
		if(!L.can_inject(user, 1))
			return

	if(mode == SYRINGE_BROKEN)
		to_chat(user, "<span class='warning'>This syringe is broken!</span>")
		return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.holder_full())
				to_chat(user, "<span class='notice'>The syringe is full.</span>")
				return

			if(L) //living mob
				var/drawn_amount = reagents.maximum_volume - reagents.total_volume
				if(target != user)
					target.visible_message("<span class='danger'>[user] is trying to take a blood sample from [target]!</span>", \
									"<span class='userdanger'>[user] is trying to take a blood sample from [target]!</span>")
					busy = 1
					if(!do_mob(user, target))
						busy = 0
						return
					if(reagents.holder_full())
						return
				busy = 0
				if(L.transfer_blood_to(src, drawn_amount))
					user.visible_message("[user] takes a blood sample from [L].")
				else
					to_chat(user, "<span class='warning'>You are unable to draw any blood from [L]!</span>")

			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "<span class='warning'>[target] is empty!</span>")
					return

				if(!target.is_drawable())
					to_chat(user, "<span class='warning'>You cannot directly remove reagents from [target]!</span>")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the solution.</span>")
			if(reagents.holder_full())
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "<span class='notice'>[src] is empty.</span>")
				return

			if(!L && !target.is_injectable())
				to_chat(user, "<span class='warning'>You cannot directly fill [target]!</span>")
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[target] is full.</span>")
				return

			if(L) //living mob
				if(L != user)
					L.visible_message("<span class='danger'>[user] is trying to inject [L]!</span>", \
											"<span class='userdanger'>[user] is trying to inject [L]!</span>")
					if(!do_mob(user, L))
						return
					if(!reagents.total_volume)
						return
					if(L.reagents.total_volume >= L.reagents.maximum_volume)
						return
					L.visible_message("<span class='danger'>[user] injects [L] with the syringe!", \
									"<span class='userdanger'>[user] injects [L] with the syringe!")

				var/list/rinject = list()
				for(var/datum/reagent/R in reagents.reagent_list)
					rinject += R.name
				var/contained = english_list(rinject)

				add_attack_logs(user, L, "Injected with [name] containing [contained], transfered [amount_per_transfer_from_this] units")

			var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
			reagents.reaction(L, INGEST, fraction)
			reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>You inject [amount_per_transfer_from_this] units of the solution. The syringe now contains [reagents.total_volume] units.</span>")
			if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()

/obj/item/reagent_containers/syringe/update_icon()
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

/obj/item/reagent_containers/ld50_syringe
	name = "Lethal Injection Syringe"
	desc = "A syringe used for lethal injections."
	icon = 'icons/goonstation/objects/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null //list(5,10,15)
	volume = 50
	var/mode = SYRINGE_DRAW

/obj/item/reagent_containers/ld50_syringe/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/ld50_syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/ld50_syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/ld50_syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

/obj/item/reagent_containers/ld50_syringe/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/ld50_syringe/attackby(obj/item/I, mob/user)
	return

/obj/item/reagent_containers/ld50_syringe/afterattack(obj/target, mob/user , flag)
	if(!target.reagents)
		return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class='warning'>The syringe is full.</span>")
				return

			if(ismob(target))
				if(istype(target, /mob/living/carbon))//I Do not want it to suck 50 units out of people
					to_chat(usr, "This needle isn't designed for drawing blood.")
					return
			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "<span class='warning'>[target] is empty.</span>")
					return

				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
					to_chat(user, "<span class='warning'>You cannot directly remove reagents from this object.</span>")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "<span class='notice'>You fill the syringe with [trans] units of the solution.</span>")
			if(reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "<span class='warning'>The Syringe is empty.</span>")
				return
			if(istype(target, /obj/item/implantcase/chem))
				return
			if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/reagent_containers/food))
				to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "<span class='warning'>[target] is full.</span>")
				return

			if(ismob(target) && target != user)
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("<span class='danger'>[] is trying to inject [] with a giant syringe!</span>", user, target), 1)
				if(!do_mob(user, target, 300)) return
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("<span class='warning'>[] injects [] with a giant syringe!</span>", user, target), 1)
				reagents.reaction(target, INGEST)
			if(ismob(target) && target == user)
				reagents.reaction(target, INGEST)
			spawn(5)
				var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
				to_chat(user, "<span class='notice'>You inject [trans] units of the solution. The syringe now contains [reagents.total_volume] units.</span>")
				if(reagents.total_volume >= reagents.maximum_volume && mode==SYRINGE_INJECT)
					mode = SYRINGE_DRAW
					update_icon()

/obj/item/reagent_containers/ld50_syringe/update_icon()
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


/obj/item/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	list_reagents = list("spaceacillin" = 15)

/obj/item/reagent_containers/ld50_syringe/lethal
	list_reagents = list("cyanide" = 10, "neurotoxin2" = 40)

/obj/item/reagent_containers/syringe/charcoal
	name = "Syringe (charcoal)"
	desc = "Contains charcoal - used to treat toxins and damage from toxins."
	list_reagents = list("charcoal" = 15)

/obj/item/reagent_containers/syringe/epinephrine
	name = "Syringe (Epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	list_reagents = list("epinephrine" = 15)

/obj/item/reagent_containers/syringe/insulin
	name = "Syringe (insulin)"
	desc = "Contains insulin - used to treat diabetes."
	list_reagents = list("insulin" = 15)

/obj/item/reagent_containers/syringe/bioterror
	name = "bioterror syringe"
	desc = "Contains several paralyzing reagents."
	list_reagents = list("neurotoxin" = 5, "capulettium_plus" = 5, "sodium_thiopental" = 5)
