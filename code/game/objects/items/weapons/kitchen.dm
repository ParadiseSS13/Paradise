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
	throwforce = 0.0
	throw_speed = 3
	throw_range = 5
	flags = CONDUCT
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	sharp = FALSE
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
	desc = "Это вилка. Один удар - четыре дырки."
	icon_state = "fork"

/obj/item/kitchen/utensil/pfork
	name = "plastic fork"
	desc = "Ура, её не нужно мыть!"
	icon_state = "pfork"

/obj/item/kitchen/utensil/spoon
	name = "spoon"
	desc = "Это ложка. Ей можно стукнуть по лбу, а также увидеть в ней свое перевернутое отражение."
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")

/obj/item/kitchen/utensil/pspoon
	name = "plastic spoon"
	desc = "Это пластиковая ложка. Как скучно."
	icon_state = "pspoon"
	attack_verb = list("attacked", "poked")

/obj/item/kitchen/utensil/spork
	name = "spork"
	desc = "Это вилколожка. Восхитительный инновационный дизайн."
	icon_state = "spork"
	attack_verb = list("attacked", "sporked")

/obj/item/kitchen/utensil/pspork
	name = "plastic spork"
	desc = "Это пластиковая вилколожка. Не соответствует ничьим ожиданиям!"
	icon_state = "pspork"
	attack_verb = list("attacked", "sporked")

/*
 * Knives
 */
/obj/item/kitchen/knife
	name = "kitchen knife"
	icon_state = "knife"
	desc = "Универсальный поварской нож производства компании Космическая Нарезка. Гарантированно остаётся острым на долгие годы."
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
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	var/bayonet = FALSE	//Can this be attached to a gun?

/obj/item/kitchen/knife/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator/robo)

/obj/item/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting [user.p_their()] wrists with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] throat with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] stomach open with [src]! It looks like [user.p_theyre()] trying to commit seppuku!</span>"))
	return BRUTELOSS

/obj/item/kitchen/knife/plastic
	name = "plastic knife"
	desc = "Самое тупое из лезвий."
	icon_state = "pknife"
	sharp = FALSE

/obj/item/kitchen/knife/ritual
	name = "ritual knife"
	desc = "Сверхъестественные силы, которые когда-то питали этот клинок, теперь бездействуют."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/kitchen/knife/shiv
	name = "glass shiv"
	desc = "Какой-то острый осколок завёрнутый в ткань, так же делала пра-пра-пра-пра-бабушка."
	icon = 'icons/obj/weapons/melee.dmi'
	item_state = "glass_shiv"
	icon_state = "glass_shiv"

/obj/item/kitchen/knife/shiv/carrot
	name = "carrot shiv"
	desc = "В отличие от других морковок, эту, вероятно, стоит держать подальше от глаз."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "carrotshiv"
	item_state = "carrotshiv"
	force = 8
	throwforce = 12 //fuck git
	materials = list()
	origin_tech = "biotech=3;combat=2"
	attack_verb = list("shanked", "shivved")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/kitchen/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	desc = "Огромный нож, используемый для рубки мяса и его нарезки. Это так же включает продукцию из клоунов."
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

/obj/item/kitchen/knife/butcher/meatcleaver/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/butchers_humans)

/obj/item/kitchen/knife/combat
	name = "combat knife"
	icon_state = "combatknife"
	item_state = "knife"
	desc = "Военный боевой нож для выживания."
	force = 20
	throwforce = 20
	origin_tech = "materials=3;combat=4"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "cut")
	bayonet = TRUE

/obj/item/kitchen/knife/combat/survival
	name = "survival knife"
	icon_state = "survivalknife"
	desc = "Охотничий нож для выживания."
	force = 15
	throwforce = 15

/obj/item/kitchen/knife/combat/survival/bone
	name = "bone dagger"
	item_state = "bone_dagger"
	icon_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	desc = "Острый костяной нож. Самый минимум для выживания."
	materials = list()

/obj/item/kitchen/knife/combat/cyborg
	name = "cyborg knife"
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife"
	desc = "Пласталевый нож, устанавливаемый киборгам. Крайне острый и прочный."
	origin_tech = null

/obj/item/kitchen/knife/cheese
	name = "cheese knife"
	desc = "A blunt knife used to slice cheese."
	icon_state = "knife-cheese"
	force = 3

/obj/item/kitchen/knife/pizza_cutter
	name = "pizza cutter"
	desc = "A simple circular blade on a handle, used to cut pizza."
	icon_state = "pizza_cutter"
	force = 8

/*
 * Rolling Pins
 */

/obj/item/kitchen/rollingpin
	name = "скалка"
	desc = "Используется, чтобы вырубить бармена."
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

/obj/item/reagent_containers/cooking/mould
	name = "generic candy mould"
	desc = "Непонятно, что это вообще такое."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mould"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")

/obj/item/reagent_containers/cooking/mould/make_mini()
	transform *= 0.5

/obj/item/reagent_containers/cooking/mould/unmake_mini()
	transform = null

/obj/item/reagent_containers/cooking/mould/bear
	name = "bear-shaped candy mould"
	desc = "Формочка в виде маленького медведя."
	icon_state = "mould_bear"

/obj/item/reagent_containers/cooking/mould/worm
	name = "worm-shaped candy mould"
	desc = "Формочка в виде червячка."
	icon_state = "mould_worm"

/obj/item/reagent_containers/cooking/mould/bean
	name = "bean-shaped candy mould"
	desc = "Формочка в виде боба."
	icon_state = "mould_bean"

/obj/item/reagent_containers/cooking/mould/ball
	name = "ball-shaped candy mould"
	desc = "Формочка в виде маленькой сферы"
	icon_state = "mould_ball"

/obj/item/reagent_containers/cooking/mould/cane
	name = "cane-shaped candy mould"
	desc = "Формочка в виде трости."
	icon_state = "mould_cane"

/obj/item/reagent_containers/cooking/mould/cash
	name = "cash-shaped candy mould"
	desc = "Формочка в виде фальшивых денег"
	icon_state = "mould_cash"

/obj/item/reagent_containers/cooking/mould/coin
	name = "coin-shaped candy mould"
	desc = "Формочка в виде монеты."
	icon_state = "mould_coin"

/obj/item/reagent_containers/cooking/mould/loli
	name = "sucker mould"
	desc = "Формочка в виде леденца."
	icon_state = "mould_loli"

/// circular cutter by Ume

/obj/item/kitchen/cutter
	name = "generic circular cutter"
	desc = "Универсальный круглый резак для печенья и других изделий."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "circular_cutter"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "slashed", "pricked", "thrashed")
