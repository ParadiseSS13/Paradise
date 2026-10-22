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
 *		Circular cutter
 */

/obj/item/kitchen
	name = "base type kitchen item"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/obj/kitchen.dmi'
	origin_tech = "materials=1"
	materials = list(MAT_METAL = 100)
	new_attack_chain = TRUE

/*
 * Utensils
 */
/obj/item/kitchen/utensil
	name = "base type kitchen utensil"
	lefthand_file = 'icons/mob/inhands/utensil_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/utensil_righthand.dmi'
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	materials = list(MAT_METAL = 100)
	var/max_contents = 1

/obj/item/kitchen/utensil/Initialize(mapload)
	//Initialize(mapload)
	. = ..()
	if(prob(60))
		src.pixel_y = rand(0, 4)

	create_reagents(5)
	RegisterSignal(src, COMSIG_ATTACK, PROC_REF(on_attack))

/obj/item/kitchen/utensil/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(user.a_intent != INTENT_HELP)
		return

	if(!istype(target, /mob/living/carbon))
		return

	var/mob/living/carbon/feed_target = target
	if(length(contents))
		var/obj/item/food/toEat = contents[1]
		if(istype(toEat))
			if(feed_target.eat(toEat, user))
				toEat.On_Consume(feed_target, user)
				overlays.Cut()
			return ITEM_INTERACT_COMPLETE

	return ..()

/obj/item/kitchen/utensil/proc/on_attack(datum/source, mob/living/carbon/target, mob/living/user)
	if(!istype(target) || user.a_intent == INTENT_HELP)
		return
	if(user.zone_selected != "head" && user.zone_selected != "eyes")
		return
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		target = user

	eyestab(target, user)

	return COMPONENT_SKIP_ATTACK

/obj/item/kitchen/utensil/fork
	name = "fork"
	desc = "A multi-pronged eating utensel. Sure is pointy. Keep away from outlets."
	icon_state = "fork"

/obj/item/kitchen/utensil/fork/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!istype(target, /obj/machinery))
		return ..()

	if(istype(target, /obj/machinery/nuclearbomb)) // We're trying to be a little silly, not very silly.
		return ..()

	var/obj/machinery/machine = target
	var/wiresexposed = FALSE

	if(istype(machine, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/air_lock = machine
		if(air_lock.security_level) //the door has a plating protecting the wires
			to_chat(user, SPAN_NOTICE("You scrape at the shielding of \the [target] with \the [src], to no effect."))
			return ITEM_INTERACT_COMPLETE

	//these have different variable names for if the panel is open or not. For some reason.
	if(istype(machine, /obj/machinery/alarm))
		var/obj/machinery/alarm/air_alarm = machine
		wiresexposed = air_alarm.wiresexposed

	if(istype(machine, /obj/machinery/firealarm))
		var/obj/machinery/firealarm/fire_alarm = machine
		wiresexposed = fire_alarm.wiresexposed

	// If we cant access the wires.
	if(!machine.panel_open && !wiresexposed)
		return ITEM_INTERACT_COMPLETE

	var/datum/wires/internal_wires = machine.get_internal_wires()
	var/uncut_wire_count = 0
	if(internal_wires)
		uncut_wire_count = length(internal_wires.wires - internal_wires.cut_wires)

	if(prob(50))
		// If the machine isn't powered or we're using a non-conductive fork, we waste our attempt at getting shocked.
		if(!machine.has_power() || !(flags & CONDUCT))
			to_chat(user, SPAN_NOTICE("You clumsily stick [src] into the open panel of [target]."))
			return ITEM_INTERACT_COMPLETE

		to_chat(user, SPAN_DANGER("You stick [src] into the open panel of [target]."))
		do_sparks(3, TRUE, machine)
		// Electrocute the mob, we're not checking distance because some machines are bigger than 1x1.
		electrocute_mob(user, get_area(machine), machine, machine.siemens_strength, FALSE)
	else if(prob(50) && uncut_wire_count) // 50% of 50% = 25%
		to_chat(user, SPAN_NOTICE("You stick [src] into the open panel of [target] and tear one of the wires."))
		internal_wires.cut_random_uncut_wire()
	else
		to_chat(user, SPAN_NOTICE("You stick [src] into the open panel of [target]. That was fun!"))

	return ITEM_INTERACT_COMPLETE

/obj/item/kitchen/utensil/pfork
	name = "plastic fork"
	desc = "A fork made of plastic, perfect for people that still haven't gotten over the urge to stick forks into electrical sockets."
	icon_state = "pfork"
	force = 3 // Not as rigid as a metal fork.
	flags = NONE
	materials = list(MAT_PLASTIC = 2000)

/obj/item/kitchen/utensil/spoon
	name = "spoon"
	desc = "Essentially a tiny bowl on a stick. You can see your own upside-down face in it."
	icon_state = "spoon"
	force = 2
	attack_verb = list("attacked", "poked")

/obj/item/kitchen/utensil/pspoon
	name = "plastic spoon"
	desc = "It's a plastic spoon. How dull."
	icon_state = "pspoon"
	force = 1
	attack_verb = list("attacked", "poked")
	flags = NONE
	materials = list(MAT_PLASTIC = 2000)

/obj/item/kitchen/utensil/pspoon/mre
	name = "\improper MRE spoon"
	desc = "A military-grade plastic spoon. Robust construction, thin end towards enemy."
	icon_state = "pspoon_mre"
	force = 10
	attack_verb = list("attacked", "poked", "stabbed", "shanked")

/obj/item/kitchen/utensil/spork
	name = "spork"
	desc = "The powers of a spoon and a fork combined into one! Marvel at its innovative design."
	icon_state = "spork"
	attack_verb = list("attacked", "sporked")

/obj/item/kitchen/utensil/pspork
	name = "plastic spork"
	desc = "It's a plastic spork. It's the fork side of the spoon!"
	icon_state = "pspork"
	force = 3
	attack_verb = list("attacked", "sporked")
	flags = NONE
	materials = list(MAT_PLASTIC = 2000)

/*
 * Knives
 */
/obj/item/kitchen/knife
	name = "kitchen knife"
	desc = "A general purpose chef's knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
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
	materials = list(MAT_METAL = 12000)
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = TRUE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	// Can this be attached to a gun?
	var/bayonet = FALSE

/obj/item/kitchen/knife/examine()
	. = ..()
	if(bayonet)
		. += SPAN_NOTICE("It has a socket for attaching to a gun's bayonet lug.")

/obj/item/kitchen/knife/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator/robo/sharp)
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

/obj/item/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick(SPAN_SUICIDE("[user] is slitting [user.p_their()] wrists with [src]! It looks like [user.p_theyre()] trying to commit suicide!"), \
						SPAN_SUICIDE("[user] is slitting [user.p_their()] throat with [src]! It looks like [user.p_theyre()] trying to commit suicide!"), \
						SPAN_SUICIDE("[user] is slitting [user.p_their()] stomach open with [src]! It looks like [user.p_theyre()] trying to commit seppuku!")))
	return BRUTELOSS

/obj/item/kitchen/knife/plastic
	name = "plastic knife"
	desc = "A semi-flexible knife made of plastic. The blade is so thick and blunt that it has trouble cutting up food, let alone people."
	icon_state = "pknife"
	sharp = FALSE
	flags = NONE
	force = 3 // It's a floppy blunt knife suitable for prison usage. You want a good knife? Make a shiv.
	materials = list(MAT_PLASTIC = 2000)

/obj/item/kitchen/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/shiv
	name = "glass shiv"
	desc = "An improvised knife made by haphazardly wrapping a sharp object in cloth, just like great-great-great-great grandma used to make."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "glass_shiv"
	flags = NONE
	materials = list(MAT_METAL = 100, MAT_GLASS = 2000)

/obj/item/kitchen/knife/shiv/carrot
	name = "carrot shiv"
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "carrotshiv"
	force = 8
	throwforce = 12
	materials = list()
	origin_tech = "biotech=3;combat=2"
	attack_verb = list("shanked", "shivved")
	armor = null
	materials = list()

/obj/item/kitchen/knife/butcher
	name = "butcher's cleaver"
	desc = "A large rectangular knife designed for chopping through meat and bone. This includes clowns and clown-by-products."
	icon_state = "butch"
	force = 15
	throwforce = 8
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 18000)

/obj/item/kitchen/knife/butcher/meatcleaver
	name = "meat cleaver"
	desc = "A specially designed cleaver with an ultra-strong plasteel blade and fine-ground edge. This bad boy can chop through any meat you can find with ease!"
	icon_state = "mcleaver"
	inhand_icon_state = "butch"
	force = 25
	throwforce = 15
	materials = list(MAT_METAL = 18000, MAT_PLASMA = 18000)
	origin_tech = "materials=5;combat=5;syndicate=2"

/obj/item/kitchen/knife/butcher/meatcleaver/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/butchers_humans)

/obj/item/kitchen/knife/combat
	name = "combat knife"
	desc = "A military-grade combat utility survival knife forged from plasteel. It has a wickedly sharp edge and a serrated spine."
	icon_state = "combatknife"
	worn_icon_state = "knife"
	inhand_icon_state = "knife"
	force = 20
	throwforce = 20
	materials = list(MAT_METAL = 12000, MAT_PLASMA = 12000)
	origin_tech = "materials=5;combat=5"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "cut")
	bayonet = TRUE

/obj/item/kitchen/knife/combat/survival
	name = "survival knife"
	desc = "A versatile utility knife used in hunting and survival situations."
	icon_state = "survivalknife"
	force = 15
	throwforce = 15
	origin_tech = "materials=3;combat=4"
	materials = list(MAT_METAL = 12000)

/obj/item/kitchen/knife/combat/survival/bone
	name = "bone dagger"
	desc = "A knife carved from an animal bone. Despite the crude appearance, it holds a surprisingly sharp edge."
	icon_state = "bone_dagger"
	inhand_icon_state = "bone_dagger"
	materials = list()
	origin_tech = "materials=2;biotech=2" // Same as bones.
	flags = NONE

/obj/item/kitchen/knife/combat/cyborg
	name = "cyborg knife"
	desc = "A cyborg-mounted plasteel knife. Extremely sharp and durable."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife"

/obj/item/kitchen/knife/cheese
	name = "cheese knife"
	desc = "A blunt knife used to cut cheese into presentable slices. A requirement for any true connoisseur of cheese."
	icon_state = "knife-cheese"
	materials = list(MAT_METAL = 4000)
	force = 3

/obj/item/kitchen/knife/pizza_cutter
	name = "pizza cutter"
	desc = "A circular blade attached to its handle with an axle, allowing it to freely rotate. These are usually used to cut pizza, but it can cut other things too. Don't let the system hold you back!"
	icon_state = "pizza_cutter"
	materials = list(MAT_METAL = 10000)
	force = 8

/*
 * Rolling Pins
 */

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "A cylindrical kitchen utensel used to shape and flatten dough. Also sometimes used to smash skulls."
	icon_state = "rolling_pin"
	force = 8
	throwforce = 10
	throw_speed = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	materials = list(MAT_WOOD = 10000)

/*
 * Candy Moulds
 */
/obj/item/reagent_containers/cooking/mould
	name = "generic candy mould"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mould"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	materials = list(MAT_PLASTIC = 2000)

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
	name = "circular cutter"
	desc = "A circular cutter for cookies and other things."
	icon_state = "circular_cutter"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "slashed", "pricked", "thrashed")
