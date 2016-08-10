/* Kitchen tools
 * Contains:
 *		Utensils
 *		Spoons
 *		Forks
 *		Knives
 *		Kitchen knives
 *		Butcher's cleaver
 *		Rolling Pins
 *		Candy Moulds
 */

/obj/item/weapon/kitchen
	icon = 'icons/obj/kitchen.dmi'

/*
 * Utensils
 */
/obj/item/weapon/kitchen/utensil
	force = 5.0
	w_class = 1
	throwforce = 0.0
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	origin_tech = "materials=1"
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 0
	var/max_contents = 1

/obj/item/weapon/kitchen/utensil/New()
	if(prob(60))
		src.pixel_y = rand(0, 4)

	create_reagents(5)
	return

/obj/item/weapon/kitchen/utensil/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(user.a_intent != I_HELP)
		if(user.zone_sel.selecting == "head" || user.zone_sel.selecting == "eyes")
			if((CLUMSY in user.mutations) && prob(50))
				M = user
			return eyestab(M,user)
		else
			return ..()

	if(contents.len)
		var/obj/item/weapon/reagent_containers/food/snacks/toEat = contents[1]
		if(istype(toEat))
			if(M.eat(toEat, user))
				toEat.On_Consume(M, user)
				spawn(0)
					if(toEat)
						qdel(toEat)
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
/obj/item/weapon/kitchen/knife
	name = "kitchen knife"
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = CONDUCT
	force = 10
	w_class = 2
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 6
	materials = list(MAT_METAL=12000)
	origin_tech = "materials=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	no_embed = 1
	sharp = 1
	edge = 1

/obj/item/weapon/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/weapon/kitchen/knife/plastic
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	item_state = "knife"
	sharp = 0
	edge = 0

/obj/item/weapon/kitchen/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	w_class = 3

/obj/item/weapon/kitchen/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = CONDUCT
	force = 15
	throwforce = 8
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = 3

/obj/item/weapon/kitchen/knife/butcher/meatcleaver
	name = "Meat Cleaver"
	icon_state = "mcleaver"
	item_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	force = 25.0
	throwforce = 15.0

/obj/item/weapon/kitchen/knife/combat
	name = "combat knife"
	icon_state = "combatknife"
	item_state = "knife"
	desc = "A military combat utility survival knife."
	force = 20
	throwforce = 20
	origin_tech = "materials=2;combat=4"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "cut")

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
	w_class = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/* Trays moved to /obj/item/weapon/storage/bag */

/*
 * Candy Moulds
 */

/obj/item/weapon/kitchen/mould
	name = "generic candy mould"
	desc = "You aren't sure what it's supposed to be."
	icon_state = "mould"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = 2
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")

/obj/item/weapon/kitchen/mould/bear
	name = "bear-shaped candy mould"
	desc = "It has the shape of a small bear imprinted into it."
	icon_state = "mould_bear"

/obj/item/weapon/kitchen/mould/worm
	name = "worm-shaped candy mould"
	desc = "It has the shape of a worm imprinted into it."
	icon_state = "mould_worm"

/obj/item/weapon/kitchen/mould/bean
	name = "bean-shaped candy mould"
	desc = "It has the shape of a bean imprinted into it."
	icon_state = "mould_bean"

/obj/item/weapon/kitchen/mould/ball
	name = "ball-shaped candy mould"
	desc = "It has a small sphere imprinted into it."
	icon_state = "mould_ball"

/obj/item/weapon/kitchen/mould/cane
	name = "cane-shaped candy mould"
	desc = "It has the shape of a cane imprinted into it."
	icon_state = "mould_cane"

/obj/item/weapon/kitchen/mould/cash
	name = "cash-shaped candy mould"
	desc = "It has the shape and design of fake money imprinted into it."
	icon_state = "mould_cash"

/obj/item/weapon/kitchen/mould/coin
	name = "coin-shaped candy mould"
	desc = "It has the shape of a coin imprinted into it."
	icon_state = "mould_coin"

/obj/item/weapon/kitchen/mould/loli
	name = "sucker mould"
	desc = "It has the shape of a sucker imprinted into it."
	icon_state = "mould_loli"
