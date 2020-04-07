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
 *		Sushi Mat
 *		Circular cutter
 */

/obj/item/kitchen
	icon = 'icons/obj/kitchen.dmi'
	origin_tech = "materials=1"




/*
 * Utensils
 */
/obj/item/kitchen/utensil
	force = 5.0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0.0
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	sharp = 0
	var/max_contents = 1

/obj/item/kitchen/utensil/New()
	..()
	if(prob(60))
		src.pixel_y = rand(0, 4)

	create_reagents(5)

/obj/item/kitchen/utensil/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(user.a_intent != INTENT_HELP)
		if(user.zone_selected == "head" || user.zone_selected == "eyes")
			if((CLUMSY in user.mutations) && prob(50))
				M = user
			return eyestab(M,user)
		else
			return ..()

	if(contents.len)
		var/obj/item/reagent_containers/food/snacks/toEat = contents[1]
		if(istype(toEat))
			if(M.eat(toEat, user))
				toEat.On_Consume(M, user)
				spawn(0)
					if(toEat)
						qdel(toEat)
				overlays.Cut()
				return


/obj/item/kitchen/utensil/fork
	name = "fork"
	desc = "It's a fork. Sure is pointy."
	icon_state = "fork"

/obj/item/kitchen/utensil/pfork
	name = "plastic fork"
	desc = "Yay, no washing up to do."
	icon_state = "pfork"

/obj/item/kitchen/utensil/spoon
	name = "spoon"
	desc = "It's a spoon. You can see your own upside-down face in it."
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")

/obj/item/kitchen/utensil/pspoon
	name = "plastic spoon"
	desc = "It's a plastic spoon. How dull."
	icon_state = "pspoon"
	attack_verb = list("attacked", "poked")

/obj/item/kitchen/utensil/spork
	name = "spork"
	desc = "It's a spork. Marvel at its innovative design."
	icon_state = "spork"
	attack_verb = list("attacked", "sporked")

/obj/item/kitchen/utensil/pspork
	name = "plastic spork"
	desc = "It's a plastic spork. It's the fork side of the spoon!"
	icon_state = "pspork"
	attack_verb = list("attacked", "sporked")

/*
 * Knives
 */
/obj/item/kitchen/knife
	name = "kitchen knife"
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags = CONDUCT
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 6
	materials = list(MAT_METAL=12000)
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = TRUE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	var/bayonet = FALSE	//Can this be attached to a gun?

/obj/item/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting [user.p_their()] wrists with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] throat with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>"))
	return BRUTELOSS

/obj/item/kitchen/knife/plastic
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	item_state = "knife"
	sharp = 0

/obj/item/kitchen/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	flags = CONDUCT
	force = 15
	throwforce = 8
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/butcher/meatcleaver
	name = "meat cleaver"
	icon_state = "mcleaver"
	item_state = "butch"
	force = 25
	throwforce = 15

/obj/item/kitchen/knife/combat
	name = "combat knife"
	icon_state = "combatknife"
	item_state = "knife"
	desc = "A military combat utility survival knife."
	force = 20
	throwforce = 20
	origin_tech = "materials=3;combat=4"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "cut")
	bayonet = TRUE

/obj/item/kitchen/knife/combat/survival
	name = "survival knife"
	icon_state = "survivalknife"
	desc = "A hunting grade survival knife."
	force = 15
	throwforce = 15

/obj/item/kitchen/knife/combat/survival/bone
	name = "bone dagger"
	item_state = "bone_dagger"
	icon_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	desc = "A sharpened bone. The bare minimum in survival."
	materials = list()

/obj/item/kitchen/knife/combat/cyborg
	name = "cyborg knife"
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife"
	desc = "A cyborg-mounted plasteel knife. Extremely sharp and durable."
	origin_tech = null

/obj/item/kitchen/knife/carrotshiv
	name = "carrot shiv"
	icon_state = "carrotshiv"
	item_state = "carrotshiv"
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."
	force = 8
	throwforce = 12 //fuck git
	materials = list()
	origin_tech = "biotech=3;combat=2"
	attack_verb = list("shanked", "shivved")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)


/*
 * Rolling Pins
 */

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/* Trays moved to /obj/item/storage/bag */

/*
 * Candy Moulds
 */

/obj/item/kitchen/mould
	name = "generic candy mould"
	desc = "You aren't sure what it's supposed to be."
	icon_state = "mould"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")

/obj/item/kitchen/mould/bear
	name = "bear-shaped candy mould"
	desc = "It has the shape of a small bear imprinted into it."
	icon_state = "mould_bear"

/obj/item/kitchen/mould/worm
	name = "worm-shaped candy mould"
	desc = "It has the shape of a worm imprinted into it."
	icon_state = "mould_worm"

/obj/item/kitchen/mould/bean
	name = "bean-shaped candy mould"
	desc = "It has the shape of a bean imprinted into it."
	icon_state = "mould_bean"

/obj/item/kitchen/mould/ball
	name = "ball-shaped candy mould"
	desc = "It has a small sphere imprinted into it."
	icon_state = "mould_ball"

/obj/item/kitchen/mould/cane
	name = "cane-shaped candy mould"
	desc = "It has the shape of a cane imprinted into it."
	icon_state = "mould_cane"

/obj/item/kitchen/mould/cash
	name = "cash-shaped candy mould"
	desc = "It has the shape and design of fake money imprinted into it."
	icon_state = "mould_cash"

/obj/item/kitchen/mould/coin
	name = "coin-shaped candy mould"
	desc = "It has the shape of a coin imprinted into it."
	icon_state = "mould_coin"

/obj/item/kitchen/mould/loli
	name = "sucker mould"
	desc = "It has the shape of a sucker imprinted into it."
	icon_state = "mould_loli"

/*
 * Sushi Mat
 */
/obj/item/kitchen/sushimat
	name = "Sushi Mat"
	desc = "A wooden mat used for efficient sushi crafting."
	icon_state = "sushi_mat"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("rolled", "cracked", "battered", "thrashed")



/// circular cutter by Ume

/obj/item/kitchen/cutter
	name = "generic circular cutter"
	desc = "A generic circular cutter for cookies and other things."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "circular_cutter"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "slashed", "pricked", "thrashed")
