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
	lefthand_file = 'icons/mob/inhands/utensil_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/utensil_righthand.dmi'
	force = 5.0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	var/max_contents = 1

/obj/item/kitchen/utensil/New()
	..()
	if(prob(60))
		src.pixel_y = rand(0, 4)

	create_reagents(5)

/obj/item/kitchen/utensil/attack__legacy__attackchain(mob/living/carbon/C, mob/living/carbon/user)
	if(!istype(C))
		return ..()

	if(user.a_intent != INTENT_HELP)
		if(user.zone_selected == "head" || user.zone_selected == "eyes")
			if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
				C = user
			return eyestab(C, user)
		else
			return ..()

	if(length(contents))
		var/obj/item/food/toEat = contents[1]
		if(istype(toEat))
			if(C.eat(toEat, user))
				toEat.On_Consume(C, user)
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
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	var/bayonet = FALSE	//Can this be attached to a gun?

/obj/item/kitchen/knife/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator/robo)
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

/obj/item/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting [user.p_their()] wrists with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] throat with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] stomach open with [src]! It looks like [user.p_theyre()] trying to commit seppuku!</span>"))
	return BRUTELOSS

/obj/item/kitchen/knife/plastic
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	sharp = FALSE

/obj/item/kitchen/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/shiv
	name = "glass shiv"
	desc = "A haphazard sharp object wrapped in cloth, just like great-great-great-great grandma used to make."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "glass_shiv"

/obj/item/kitchen/knife/shiv/carrot
	name = "carrot shiv"
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "carrotshiv"
	force = 8
	throwforce = 12 //fuck git
	materials = list()
	origin_tech = "biotech=3;combat=2"
	attack_verb = list("shanked", "shivved")
	armor = null

/obj/item/kitchen/knife/butcher
	name = "butcher's cleaver"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	icon_state = "butch"
	force = 15
	throwforce = 8
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/butcher/meatcleaver
	name = "meat cleaver"
	icon_state = "mcleaver"
	inhand_icon_state = "butch"
	force = 25
	throwforce = 15

/obj/item/kitchen/knife/butcher/meatcleaver/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/butchers_humans)

/obj/item/kitchen/knife/combat
	name = "combat knife"
	desc = "A military combat utility survival knife."
	icon_state = "combatknife"
	worn_icon_state = "knife"
	inhand_icon_state = "knife"
	force = 20
	throwforce = 20
	origin_tech = "materials=3;combat=4"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "cut")
	bayonet = TRUE

/obj/item/kitchen/knife/combat/survival
	name = "survival knife"
	desc = "A hunting grade survival knife."
	icon_state = "survivalknife"
	force = 15
	throwforce = 15

/obj/item/kitchen/knife/combat/survival/bone
	name = "bone dagger"
	desc = "A sharpened bone. The bare minimum in survival."
	icon_state = "bone_dagger"
	inhand_icon_state = "bone_dagger"
	materials = list()

/obj/item/kitchen/knife/combat/cyborg
	name = "cyborg knife"
	desc = "A cyborg-mounted plasteel knife. Extremely sharp and durable."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife"
	origin_tech = null

/obj/item/kitchen/knife/cheese
	name = "cheese knife"
	desc = "A blunt knife used to slice cheese."
	icon_state = "knife-cheese"
	materials = list(MAT_METAL = 4000)
	force = 3
	materials = list(MAT_METAL = 4000)

/obj/item/kitchen/knife/pizza_cutter
	name = "pizza cutter"
	desc = "A simple circular blade on a handle, used to cut pizza."
	icon_state = "pizza_cutter"
	materials = list(MAT_METAL = 10000)
	force = 8
	materials = list(MAT_METAL = 10000)

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
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/* Trays moved to /obj/item/storage/bag */

/*
 * Candy Moulds
 */

/obj/item/reagent_containers/cooking/mould
	name = "generic candy mould"
	desc = "You aren't sure what it's supposed to be."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mould"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")

/obj/item/reagent_containers/cooking/mould/make_mini()
	transform *= 0.5

/obj/item/reagent_containers/cooking/mould/unmake_mini()
	transform = null

/obj/item/reagent_containers/cooking/mould/bear
	name = "bear-shaped candy mould"
	desc = "It has the shape of a small bear imprinted into it."
	icon_state = "mould_bear"

/obj/item/reagent_containers/cooking/mould/worm
	name = "worm-shaped candy mould"
	desc = "It has the shape of a worm imprinted into it."
	icon_state = "mould_worm"

/obj/item/reagent_containers/cooking/mould/bean
	name = "bean-shaped candy mould"
	desc = "It has the shape of a bean imprinted into it."
	icon_state = "mould_bean"

/obj/item/reagent_containers/cooking/mould/ball
	name = "ball-shaped candy mould"
	desc = "It has a small sphere imprinted into it."
	icon_state = "mould_ball"

/obj/item/reagent_containers/cooking/mould/cane
	name = "cane-shaped candy mould"
	desc = "It has the shape of a cane imprinted into it."
	icon_state = "mould_cane"

/obj/item/reagent_containers/cooking/mould/cash
	name = "cash-shaped candy mould"
	desc = "It has the shape and design of fake money imprinted into it."
	icon_state = "mould_cash"

/obj/item/reagent_containers/cooking/mould/coin
	name = "coin-shaped candy mould"
	desc = "It has the shape of a coin imprinted into it."
	icon_state = "mould_coin"

/obj/item/reagent_containers/cooking/mould/loli
	name = "sucker mould"
	desc = "It has the shape of a sucker imprinted into it."
	icon_state = "mould_loli"

/// circular cutter by Ume

/obj/item/kitchen/cutter
	name = "generic circular cutter"
	desc = "A generic circular cutter for cookies and other things."
	icon_state = "circular_cutter"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "slashed", "pricked", "thrashed")
