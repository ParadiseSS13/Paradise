/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 5
	max_amount = 5
	w_class = 1
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/stack/medical/attack(mob/living/carbon/M as mob, mob/user as mob)
	if (!istype(M))
		user << "<span class='danger'>\The [src] cannot be applied to [M]!</span>"
		return 1

	if (!(istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon)))
		user << "<span class='danger'>You don't have the dexterity to do this!</span>"
		return 1


	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(isliving(M))
			if(!M.can_inject(user, 1))
				return 1

		if(!affecting)
			user << "<span class='danger'>That limb is missing!</span>"
			return 1

		if(affecting.status & ORGAN_ROBOT)
			user << "<span class='danger'>This can't be used on a robotic limb.</span>"
			return 1


		H.UpdateDamageIcon()

	else
		M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))
		user.visible_message("<span class='notice'>[M] has been applied with [src] by [user].</span>","<span class='notice'>You apply \the [src] to [M].</span>")
		use(1)

	M.updatehealth()

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "gauze"
	origin_tech = "biotech=1"

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.bandage())
				user << "\red The wounds on [M]'s [affecting.name] have already been bandaged."
				return 1
			else
				for (var/datum/wound/W in affecting.wounds)
					if (W.internal)
						continue
					if (W.current_stage <= W.max_bleeding_stage)
						user.visible_message( 	"\blue [user] bandages \the [W.desc] on [M]'s [affecting.name].", \
										"\blue You bandage \the [W.desc] on [M]'s [affecting.name]." )
					else if (istype(W,/datum/wound/bruise))
						user.visible_message( 	"\blue [user] places a bruise patch over \the [W.desc] on [M]'s [affecting.name].", \
										"\blue You place a bruise patch over \the [W.desc] on [M]'s [affecting.name]." )
					else
						user.visible_message( 	"\blue [user] places a bandaid over \the [W.desc] on [M]'s [affecting.name].", \
										"\blue You place a bandaid over \the [W.desc] on [M]'s [affecting.name]." )

					affecting.heal_damage(src.heal_brute, src.heal_burn, 0)
					use(1)
		else
			M.heal_organ_damage((src.heal_brute/2), (src.heal_burn/2))
			use(1)

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	heal_burn = 1
	origin_tech = "biotech=1"

/obj/item/stack/medical/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.salve())
				user << "\red The wounds on [M]'s [affecting.name] have already been salved."
				return 1
			else
				user.visible_message( 	"\blue [user] salves the wounds on [M]'s [affecting.name].", \
										"\blue You salve the wounds on [M]'s [affecting.name]." )
				affecting.heal_damage(src.heal_brute, src.heal_burn, 0)
				use(1)
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.name] is cut open, you'll need more than some ointment!</span>"

/obj/item/stack/medical/bruise_pack/tajaran
	name = "\improper S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A soft leaf that is rubbed on bruises."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "shand"
	heal_brute = 7

/obj/item/stack/medical/ointment/tajaran
	name = "\improper Messa's Tear leaf"
	singular_name = "Messa's Tear leaf"
	desc = "A cold leaf that is rubbed on burns."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "mtear"
	heal_burn = 7

/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 12
	origin_tech = "biotech=1"

/obj/item/stack/medical/advanced/bruise_pack/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			var/bandaged = affecting.bandage()
			var/disinfected = affecting.disinfect()

			if(!(bandaged || disinfected))
				user << "\red The wounds on [M]'s [affecting.name] have already been treated."
				return 1
			else
				for (var/datum/wound/W in affecting.wounds)
					if (W.internal)
						continue
					if (W.current_stage <= W.max_bleeding_stage)
						user.visible_message( 	"\blue [user] cleans \the [W.desc] on [M]'s [affecting.name] and seals the edges with bioglue.", \
										"\blue You clean and seal \the [W.desc] on [M]'s [affecting.name]." )
						//H.add_side_effect("Itch")
					else if (istype(W,/datum/wound/bruise))
						user.visible_message( 	"\blue [user] places a medicine patch over \the [W.desc] on [M]'s [affecting.name].", \
										"\blue You place a medicine patch over \the [W.desc] on [M]'s [affecting.name]." )
					else
						user.visible_message( 	"\blue [user] smears some bioglue over [W.desc] on [M]'s [affecting.name].", \
										"\blue You smear some bioglue over [W.desc] on [M]'s [affecting.name]." )
				if (bandaged)
					affecting.heal_damage(heal_brute,0)
				use(1)
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>"

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 12
	origin_tech = "biotech=1"


/obj/item/stack/medical/advanced/ointment/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.salve())
				user << "\red The wounds on [M]'s [affecting.name] have already been salved."
				return 1
			else
				user.visible_message( 	"\blue [user] covers the wounds on [M]'s [affecting.name] with regenerative membrane.", \
										"\blue You cover the wounds on [M]'s [affecting.name] with regenerative membrane." )
				affecting.heal_damage(0,heal_burn)
				use(1)
		else
			if (can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>The [affecting.name] is cut open, you'll need more than a bandage!</span>"

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5

/obj/item/stack/medical/splint/single
	amount = 1


/obj/item/stack/medical/splint/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(..())
		return 1

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
		var/limb = affecting.name
		if(!(affecting.limb_name in list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")))
			user << "\red You can't apply a splint there!"
			return
		if(affecting.status & ORGAN_SPLINTED)
			user << "\red [M]'s [limb] is already splinted!"
			return
		if (M != user)
			user.visible_message("\red [user] starts to apply \the [src] to [M]'s [limb].", "\red You start to apply \the [src] to [M]'s [limb].", "\red You hear something being wrapped.")
		else
			if((!user.hand && affecting.limb_name in list("r_arm", "r_hand")) || (user.hand && affecting.limb_name in list("l_arm", "l_hand")))
				user << "\red You can't apply a splint to the arm you're using!"
				return
			user.visible_message("\red [user] starts to apply \the [src] to their [limb].", "\red You start to apply \the [src] to your [limb].", "\red You hear something being wrapped.")
		if(do_after(user, 50, target = M))
			if (M != user)
				user.visible_message("\red [user] finishes applying \the [src] to [M]'s [limb].", "\red You finish applying \the [src] to [M]'s [limb].", "\red You hear something being wrapped.")
			else
				if(prob(25))
					user.visible_message("\red [user] successfully applies \the [src] to their [limb].", "\red You successfully apply \the [src] to your [limb].", "\red You hear something being wrapped.")
				else
					user.visible_message("\red [user] fumbles \the [src].", "\red You fumble \the [src].", "\red You hear something being wrapped.")
					return
			affecting.status |= ORGAN_SPLINTED
			use(1)
		return