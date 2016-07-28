/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 5
	max_amount = 5
	w_class = 1
	throw_speed = 3
	throw_range = 7
	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/stack/medical/attack(mob/living/carbon/M, mob/user)
	if(!istype(M))
		to_chat(user, "<span class='danger'>[src] cannot be applied to [M]!</span>")
		return 1

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='danger'>You don't have the dexterity to do this!</span>")
		return 1


	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(isliving(M))
			if(!M.can_inject(user, 1))
				return 1

		if(!affecting)
			to_chat(user, "<span class='danger'>That limb is missing!</span>")
			return 1

		if(affecting.status & ORGAN_ROBOT)
			to_chat(user, "<span class='danger'>This can't be used on a robotic limb.</span>")
			return 1


		H.UpdateDamageIcon()

	else
		M.heal_organ_damage(heal_brute/2, heal_burn/2)
		user.visible_message("<span class='notice'>[M] has been applied with [src] by [user].</span>", \
							 "<span class='notice'>You apply [src] to [M].</span>")
		use(1)

	M.updatehealth()

//Bruise Packs//

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "gauze"
	origin_tech = "biotech=1"

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/M, mob/user)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			var/bandaged = affecting.bandage()
			var/disinfected = affecting.disinfect()

			if(!(bandaged || disinfected))
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been bandaged.</span>")
				return 1
			else
				for(var/datum/wound/W in affecting.wounds)
					if(W.internal)
						continue
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>[user] bandages \the [W.desc] on [M]'s [affecting.name].</span>", \
											 "<span class='notice'>You bandage \the [W.desc] on [M]'s [affecting.name].</span>" )
					else if(istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>[user] places a bruise patch over \the [W.desc] on [M]'s [affecting.name].</span>", \
											 "<span class='notice'>You place a bruise patch over \the [W.desc] on [M]'s [affecting.name].</span>" )
					else
						user.visible_message("<span class='notice'>[user] places a bandaid over \the [W.desc] on [M]'s [affecting.name].</span>", \
											 "<span class='notice'>You place a bandaid over \the [W.desc] on [M]'s [affecting.name].</span>" )
				if(bandaged)
					affecting.heal_damage(heal_brute, heal_burn)
				use(1)
		else
			to_chat(user, "<span class='notice'>[affecting] is cut open, you'll need more than a bandage!</span>")


/obj/item/stack/medical/bruise_pack/advanced
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 12



//Ointment//


/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	origin_tech = "biotech=1"

/obj/item/stack/medical/ointment/attack(mob/living/carbon/M, mob/user)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.salve())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.name] have already been salved.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>[user] salves the wounds on [M]'s [affecting.name].", \
									 "<span class='notice'>You salve the wounds on [M]'s [affecting.name].</span>" )
				affecting.heal_damage(heal_brute, heal_burn)
				use(1)
		else
			to_chat(user, "<span class='notice'>[affecting] is cut open, you'll need more than some ointment!</span>")


/obj/item/stack/medical/ointment/advanced
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 12



//Medical Herbs//


/obj/item/stack/medical/bruise_pack/comfrey
	name = "\improper Comfrey leaf"
	singular_name = "Comfrey leaf"
	desc = "A soft leaf that is rubbed on bruises."
	icon = 'icons/obj/hydroponics_products.dmi'
	icon_state = "alien3-product"
	color = "#378C61"
	heal_brute = 7


/obj/item/stack/medical/ointment/aloe
	name = "\improper Aloe Vera leaf"
	singular_name = "Aloe Vera leaf"
	desc = "A cold leaf that is rubbed on burns."
	icon = 'icons/obj/hydroponics_products.dmi'
	icon_state = "ambrosia-product"
	color = "#4CC5C7"
	heal_burn = 7



//Splits//


/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5

/obj/item/stack/medical/splint/attack(mob/living/carbon/M, mob/user)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
		var/limb = affecting.name
		if(!(affecting.limb_name in list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")))
			to_chat(user, "<span class='danger'>You can't apply a splint there!</span>")
			return
		if(affecting.status & ORGAN_SPLINTED)
			to_chat(user, "<span class='danger'>[M]'s [limb] is already splinted!</span>")
			if(alert(user, "Would you like to remove the splint from [M]'s [limb]?", "Removing.", "Yes", "No") == "Yes")
				affecting.status &= ~ORGAN_SPLINTED
				to_chat(user, "<span class='notice'>You remove the splint from [M]'s [limb].</span>")
			return
		if(M != user)
			user.visible_message("<span class='notice'>[user] starts to apply [src] to [M]'s [limb].</span>", \
								 "<span class='notice'>You start to apply [src] to [M]'s [limb].</span>", \
								 "<span class='notice'>You hear something being wrapped.</span>")
		else
			if((!user.hand && affecting.limb_name in list("r_arm", "r_hand")) || (user.hand && affecting.limb_name in list("l_arm", "l_hand")))
				to_chat(user, "<span class='danger'>You can't apply a splint to the arm you're using!</span>")
				return
			user.visible_message("<span class='notice'>[user] starts to apply [src] to their [limb].</span>", \
								 "<span class='notice'>You start to apply [src] to your [limb].</span>", \
								 "<span class='notice'>You hear something being wrapped.</span>")
		if(do_after(user, 50, target = M))
			if(M != user)
				user.visible_message("<span class='notice'>[user] finishes applying [src] to [M]'s [limb].</span>", \
									"<span class='notice'>You finish applying [src] to [M]'s [limb].</span>", \
									"<span class='notice'>You hear something being wrapped.</span>")
			else
				if(prob(25))
					user.visible_message("<span class='notice'>[user] successfully applies [src] to their [limb].</span>", \
										 "<span class='notice'>You successfully apply [src] to your [limb].</span>", \
										 "<span class='notice'>You hear something being wrapped.</span>")
				else
					user.visible_message("<span class='warning'>[user] fumbles [src].</span>",
										 "<span class='warning'>You fumble [src].</span>",
										 "<span class='warning'>You hear something being wrapped.</span>")
					return
			affecting.status |= ORGAN_SPLINTED
			use(1)
