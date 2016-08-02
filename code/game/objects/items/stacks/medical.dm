/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 6
	max_amount = 6
	w_class = 1
	throw_speed = 3
	throw_range = 7
	var/heal_brute = 0
	var/heal_burn = 0
	var/self_delay = 20
	var/unique_handling = 0 //some things give a special prompt, do we want to bypass some checks in parent?

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	if(!iscarbon(M) && !isanimal(M))
		to_chat(user, "<span class='danger'>[src] cannot be applied to [M]!</span>")
		return 1

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='danger'>You don't have the dexterity to do this!</span>")
		return 1


	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(!H.can_inject(user, 1))
			return 1

		if(!affecting)
			to_chat(user, "<span class='danger'>That limb is missing!</span>")
			return 1

		if(affecting.status & ORGAN_ROBOT)
			to_chat(user, "<span class='danger'>This can't be used on a robotic limb.</span>")
			return 1

		if(M == user && !unique_handling)
			user.visible_message("<span class='notice'>[user] starts to apply [src] on [H]...</span>")
			if(!do_mob(user, H, self_delay))
				return 1
		return

	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if(!(critter.healable))
			to_chat(user, "<span class='notice'>You cannot use [src] on [critter]!</span>")
			return
		else if (critter.health == critter.maxHealth)
			to_chat(user, "<span class='notice'>[critter] is at full health.</span>")
			return
		else if(heal_brute < 1)
			to_chat(user, "<span class='notice'>[src] won't help [critter] at all.</span>")
			return

		critter.heal_organ_damage(heal_brute, heal_burn)
		user.visible_message("<span class='green'>[user] applies [src] on [critter].</span>", \
							 "<span class='green'>You apply [src] on [critter].</span>")

		use(1)

	else
		M.heal_organ_damage(heal_brute, heal_burn)
		M.updatehealth()
		user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", \
							 "<span class='green'>You apply [src] on [M].</span>")
		use(1)

//Bruise Packs//

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "gauze"
	origin_tech = "biotech=1"

/obj/item/stack/medical/bruise_pack/attack(mob/living/M, mob/user)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			var/bandaged = affecting.bandage()
			var/disinfected = affecting.disinfect()

			if(!(bandaged || disinfected))
				to_chat(user, "<span class='warning'>The wounds on [H]'s [affecting.name] have already been bandaged.</span>")
				return 1
			else
				user.visible_message("<span class='green'>[user] bandages the wounds on [H]'s [affecting.name].", \
								 	 "<span class='green'>You bandage the wounds on [H]'s [affecting.name].</span>" )

				affecting.heal_damage(heal_brute, heal_burn)
				H.UpdateDamageIcon()
				use(1)
		else
			to_chat(user, "<span class='warning'>[affecting] is cut open, you'll need more than a bandage!</span>")


/obj/item/stack/medical/bruise_pack/advanced
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 25



//Ointment//


/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	origin_tech = "biotech=1"

/obj/item/stack/medical/ointment/attack(mob/living/M, mob/user)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(!affecting.salve())
				to_chat(user, "<span class='warning'>The wounds on [H]'s [affecting.name] have already been salved.</span>")
				return 1
			else
				user.visible_message("<span class='green'>[user] salves the wounds on [H]'s [affecting.name].", \
								 	 "<span class='green'>You salve the wounds on [H]'s [affecting.name].</span>" )
				affecting.heal_damage(heal_brute, heal_burn)
				H.UpdateDamageIcon()
				use(1)
		else
			to_chat(user, "<span class='warning'>[affecting] is cut open, you'll need more than some ointment!</span>")


/obj/item/stack/medical/ointment/advanced
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 25



//Medical Herbs//


/obj/item/stack/medical/bruise_pack/comfrey
	name = "\improper Comfrey leaf"
	singular_name = "Comfrey leaf"
	desc = "A soft leaf that is rubbed on bruises."
	icon = 'icons/obj/hydroponics_products.dmi'
	icon_state = "alien3-product"
	color = "#378C61"
	heal_brute = 12


/obj/item/stack/medical/ointment/aloe
	name = "\improper Aloe Vera leaf"
	singular_name = "Aloe Vera leaf"
	desc = "A cold leaf that is rubbed on burns."
	icon = 'icons/obj/hydroponics_products.dmi'
	icon_state = "ambrosia-product"
	color = "#4CC5C7"
	heal_burn = 12



//Splits//


/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	unique_handling = 1
	self_delay = 100

/obj/item/stack/medical/splint/attack(mob/living/M, mob/user)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
		var/limb = affecting.name
		if(!(affecting.limb_name in list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")))
			to_chat(user, "<span class='danger'>You can't apply a splint there!</span>")
			return
		if(affecting.status & ORGAN_SPLINTED)
			to_chat(user, "<span class='danger'>[H]'s [limb] is already splinted!</span>")
			if(alert(user, "Would you like to remove the splint from [H]'s [limb]?", "Removing.", "Yes", "No") == "Yes")
				affecting.status &= ~ORGAN_SPLINTED
				to_chat(user, "<span class='notice'>You remove the splint from [H]'s [limb].</span>")
			return
		if(M == user)
			user.visible_message("<span class='notice'>[user] starts to apply [src] to [H]'s [limb].</span>", \
								 "<span class='notice'>You start to apply [src] to [H]'s [limb].</span>", \
								 "<span class='notice'>You hear something being wrapped.</span>")
			if(!do_mob(user, H, self_delay))
				return
		else
			user.visible_message("<span class='green'>[user] applies [src] to their [limb].</span>", \
								 "<span class='green'>You apply [src] to your [limb].</span>", \
								 "<span class='green'>You hear something being wrapped.</span>")

		affecting.status |= ORGAN_SPLINTED
		use(1)
