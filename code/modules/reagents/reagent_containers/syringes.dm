/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe."
	icon = 'icons/goonstation/objects/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	belt_icon = "syringe"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	volume = 15
	sharp = TRUE
	var/busy = FALSE
	var/mode = SYRINGE_DRAW
	var/projectile_type = /obj/item/projectile/bullet/dart/syringe
	materials = list(MAT_METAL=10, MAT_GLASS=20)
	container_type = TRANSPARENT
	///If this variable is true, the syringe will work through hardsuits / modsuits / biosuits.
	var/penetrates_thick = FALSE

/obj/item/reagent_containers/syringe/Initialize(mapload)
	. = ..()
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/syringe/pickup(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

/obj/item/reagent_containers/syringe/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attack(mob/living/M, mob/living/user, def_zone)
	return

/obj/item/reagent_containers/syringe/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bag))
		..()

/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(!target.reagents)
		return

	var/mob/living/L
	if(isliving(target))
		L = target
		if(!L.can_inject(user, TRUE, penetrate_thick = penetrates_thick))
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
					busy = TRUE
					if(!do_mob(user, target))
						busy = FALSE
						return
					if(reagents.holder_full())
						return
				busy = FALSE
				if(L.transfer_blood_to(src, drawn_amount))
					user.visible_message("<span class='notice'>[user] takes a blood sample from [L].</span>")
				else
					to_chat(user, "<span class='warning'>You are unable to draw any blood from [L]!</span>")

			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "<span class='warning'>[target] is empty!</span>")
					return

				if(!target.is_drawable(user))
					to_chat(user, "<span class='warning'>You cannot directly remove reagents from [target]!</span>")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the solution. It now contains [reagents.total_volume] units.</span>")
			if(reagents.holder_full())
				mode = !mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "<span class='notice'>[src] is empty.</span>")
				return

			if(!L && !target.is_injectable(user)) //only checks on non-living mobs, due to how can_inject() handles
				to_chat(user, "<span class='warning'>You cannot directly fill [target]!</span>")
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[target] is full.</span>")
				return

			if(L) //living mob
				if(!L.can_inject(user, TRUE, penetrate_thick = penetrates_thick))
					return
				if(L != user)
					L.visible_message("<span class='danger'>[user] is trying to inject [L]!</span>", \
											"<span class='userdanger'>[user] is trying to inject you!</span>")
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

				add_attack_logs(user, L, "Injected with [name] containing [contained], transfered [amount_per_transfer_from_this] units", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)

			if(istype(target, /obj/item/reagent_containers/food))

				var/list/chemicals = list()
				for(var/datum/reagent/chem in reagents.reagent_list)
					chemicals += chem.name
				var/contained_chemicals = english_list(chemicals)

				add_attack_logs(user, target, "Injected [amount_per_transfer_from_this]u [contained_chemicals] into food item")

			var/fraction = min(amount_per_transfer_from_this / reagents.total_volume, 1)
			reagents.reaction(L, REAGENT_INGEST, fraction)
			reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>You inject [amount_per_transfer_from_this] units of the solution. The syringe now contains [reagents.total_volume] units.</span>")
			if(reagents.total_volume <= 0 && mode == SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()

/obj/item/reagent_containers/syringe/update_icon_state()
	var/rounded_vol
	if(reagents && reagents.total_volume)
		rounded_vol = clamp(round((reagents.total_volume / volume * 15), 5), 1, 15)
	else
		rounded_vol = 0
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

/obj/item/reagent_containers/syringe/update_overlays()
	. = ..()
	var/rounded_vol
	if(reagents && reagents.total_volume)
		rounded_vol = clamp(round((reagents.total_volume / volume * 15), 5), 1, 15)
		var/image/filling_overlay = mutable_appearance('icons/obj/reagentfillings.dmi', "syringe[rounded_vol]")
		filling_overlay.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling_overlay
	if(ismob(loc))
		var/mob/M = loc
		var/injoverlay
		switch(mode)
			if(SYRINGE_DRAW)
				injoverlay = "draw"
			if(SYRINGE_INJECT)
				injoverlay = "inject"
		. += injoverlay
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/reagent_containers/syringe/Crossed(mob/living/carbon/human/H, oldloc)
	if(!istype(H) || !H.reagents || HAS_TRAIT(H, TRAIT_PIERCEIMMUNE) || ismachineperson(H))
		return

	if(H.floating || H.flying || H.buckled)
		return

	if(!IS_HORIZONTAL(H) && (H.shoes || (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))))
		return

	if(IS_HORIZONTAL(H) && ((H.wear_suit && (H.wear_suit.body_parts_covered & UPPER_TORSO)) || (H.w_uniform && (H.w_uniform.body_parts_covered & UPPER_TORSO))))
		return

	H.visible_message("<span class='danger'>[H] is injected by [src].</span>", \
				"<span class='userdanger'>You are injected by [src]!</span>")

	if(IS_HORIZONTAL(H))
		H.apply_damage(5, BRUTE, BODY_ZONE_CHEST)
	else
		H.apply_damage(5, BRUTE, pick(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))

	if(reagents.total_volume && H.reagents.total_volume < H.reagents.maximum_volume)
		var/inject_amount = reagents.total_volume
		reagents.reaction(H, REAGENT_INGEST, inject_amount)
		reagents.trans_to(H, inject_amount)
		update_icon()

/obj/item/reagent_containers/syringe/antiviral
	name = "syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	list_reagents = list("spaceacillin" = 15)

/obj/item/reagent_containers/syringe/charcoal
	name = "syringe (charcoal)"
	desc = "Contains charcoal - used to treat toxins and damage from toxins."
	list_reagents = list("charcoal" = 15)

/obj/item/reagent_containers/syringe/epinephrine
	name = "syringe (Epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	list_reagents = list("epinephrine" = 15)

/obj/item/reagent_containers/syringe/insulin
	name = "syringe (insulin)"
	desc = "Contains insulin - used to treat diabetes."
	list_reagents = list("insulin" = 15)

/obj/item/reagent_containers/syringe/calomel
	name = "syringe (calomel)"
	desc = "Contains calomel, which be used to purge impurities, but is highly toxic itself."
	list_reagents = list("calomel" = 15)

/obj/item/reagent_containers/syringe/heparin
	name = "syringe (heparin)"
	desc = "Contains heparin, a blood anticoagulant."
	list_reagents = list("heparin" = 15)

/obj/item/reagent_containers/syringe/bioterror
	name = "bioterror syringe"
	desc = "Contains several paralyzing reagents."
	list_reagents = list("neurotoxin" = 5, "capulettium_plus" = 5, "sodium_thiopental" = 5)

/obj/item/reagent_containers/syringe/gluttony
	name = "Gluttony's Blessing"
	desc = "A syringe recovered from a dread place. It probably isn't wise to use."
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list("gluttonytoxin" = 1)

/obj/item/reagent_containers/syringe/capulettium_plus
	name = "capulettium plus syringe"
	desc = "For silencing targets. Allows for fake deaths."
	list_reagents = list("capulettium_plus" = 15)

/obj/item/reagent_containers/syringe/sarin
	name = "sarin syringe"
	desc = "A deadly neurotoxin, for killing."
	list_reagents = list("sarin" = 15)

/obj/item/reagent_containers/syringe/pancuronium
	name = "pancuronium syringe"
	desc = "A powerful paralyzing poison."
	list_reagents = list("pancuronium" = 15)

/obj/item/reagent_containers/syringe/lethal
	name = "lethal injection syringe"
	desc = "A syringe used for lethal injections. It can hold up to 50 units."
	amount_per_transfer_from_this = 50
	volume = 50
	list_reagents = list("toxin" = 15, "pancuronium" = 10, "cyanide" = 5, "facid" = 10, "fluorine" = 10)
