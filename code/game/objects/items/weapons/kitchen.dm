/* Kitchen tools
 * Contains:
 *		Utensils
 *		Spoons
 *		Forks
 *		Knives
 *		Kitchen knives
 *		Butcher's cleaver
 *		Rolling Pins
 */

/obj/item/weapon/kitchen
	icon = 'icons/obj/kitchen.dmi'

/*
 * Utensils
 */
/obj/item/weapon/kitchen/utensil
	force = 5.0
	w_class = 1.0
	throwforce = 0.0
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	origin_tech = "materials=1"
	attack_verb = list("attacked", "stabbed", "poked")
	sharp = 0

	var/loaded      //Descriptive string for currently loaded food object.

/obj/item/weapon/kitchen/utensil/New()
	if (prob(60))
		src.pixel_y = rand(0, 4)

	create_reagents(5)
	return

/obj/item/weapon/kitchen/utensil/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(user.a_intent != "help")
		if(user.zone_sel.selecting == "head" || user.zone_sel.selecting == "eyes")
			if((CLUMSY in user.mutations) && prob(50))
				M = user
			return eyestab(M,user)
		else
			return ..()

	if (reagents.total_volume > 0)
		reagents.trans_to_ingest(M, reagents.total_volume)
		if(M == user)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\blue [] eats some [] from \the [].", user, loaded, src), 1)
				M.reagents.add_reagent("nutriment", 1)
		else
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\blue [] feeds [] some [] from \the []", user, M, loaded, src), 1)
				M.reagents.add_reagent("nutriment", 1)
		playsound(M.loc,'sound/items/eatfood.ogg', rand(10,40), 1)
		overlays.Cut()
		return

/obj/item/weapon/kitchen/utensil/fork
	name = "fork"
	desc = "It's a fork. Sure is pointy."
	icon_state = "fork"

/obj/item/weapon/kitchen/utensil/pfork
	name = "plastic fork"
	desc = "Yay, no washing up to do."
	icon_state = "pfork"

/obj/item/weapon/kitchen/utensil/spoon
	name = "spoon"
	desc = "It's a spoon. You can see your own upside-down face in it."
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")

/obj/item/weapon/kitchen/utensil/pspoon
	name = "plastic spoon"
	desc = "It's a plastic spoon. How dull."
	icon_state = "pspoon"
	attack_verb = list("attacked", "poked")

/*
 * Knives
 */
/obj/item/weapon/kitchen/utensil/knife
	name = "knife"
	desc = "Can cut through any food."
	icon_state = "knife"
	force = 10.0
	throwforce = 10.0
	sharp = 1
	edge = 1

	suicide_act(mob/user)
		viewers(user) << pick("<span class='suicide'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
							"<span class='suicide'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
							"<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>")
		return (BRUTELOSS)

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red You accidentally cut yourself with the [src]."
		user.take_organ_damage(20)
		return
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/kitchen/utensil/pknife
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	force = 10.0
	throwforce = 10.0

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red You somehow managed to cut yourself with the [src]."
		user.take_organ_damage(20)
		return
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/*
 * Kitchen knives
 */
/obj/item/weapon/kitchenknife
	name = "kitchen knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = CONDUCT
	sharp = 1
	edge = 1
	force = 10.0
	w_class = 3.0
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		viewers(user) << pick("<span class='suicide'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
							"<span class='suicide'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
							"<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>")
		return (BRUTELOSS)

/obj/item/weapon/kitchenknife/combat
	name = "combat knife"
	force = 15.0
	throwforce = 10.0
	origin_tech = "materials=2;combat=2"
	desc = "A razor sharp knife, built from advanced alloys, designed for quick, melee killing. Also not half bad as a kitchen knife."
	slot_flags = SLOT_BELT
	icon = 'icons/obj/weapons.dmi'
	icon_state = "combatknife"


/obj/item/weapon/kitchenknife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"

/*
 * Bucher's cleaver
 */
/obj/item/weapon/butch
	name = "butcher's Cleaver"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = CONDUCT
	force = 15.0
	w_class = 3.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = 1
	edge = 1

/obj/item/weapon/butch/meatcleaver
	name = "Meat Cleaver"
	icon_state = "mcleaver"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	force = 25.0
	throwforce = 15.0
	no_embed = 1

/obj/item/weapon/butch/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/*
 * Rolling Pins
 */

/obj/item/weapon/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	w_class = 3.0
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/* Trays moved to /obj/item/weapon/storage/bag */