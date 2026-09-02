/obj/item/food/fried_vox
	name = "Kentucky Fried Vox"
	desc = "Bucket of voxxy, yaya!"
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "fried_vox"
	trash = /obj/item/trash/fried_vox
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("quills" = 1, "the shoal" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/fried_nian
	name = "Moffolo Wings"
	desc = "A bucket of Moffolo Wings. The 'B' on the bucket is crossed out in blue pen, and the letter 'M' has been crudely written above."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "fried_nian"
	trash = /obj/item/trash/fried_nian
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("fluff" = 1, "debt" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/fried_nian_bbq
	name = "Moffolo Wild Wings"
	desc = "A bucket of Moffolo Wild Wings. The 'B' on the bucket is crossed out in blue pen, and the letter 'M' has been crudely written above."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "fried_nian_bbq"
	trash = /obj/item/trash/fried_nian
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("fluff" = 1, "debt" = 1, "bbq sauce" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/bug_bar
	name = "Bug Bar"
	desc = "A bar made of what seems to be made of ground exoskeleton and meat. The wrapper is already open and crinkled, with a mealworm depicted on the wrapper."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "bug_bar"
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("ink" = 1, "formic acid" = 1, "bitter" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/bug_burger
	name = "Bug Burger"
	desc = "A burger made of what seems to be made of ground exoskeleton and meat for its patty."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "bug_burger"
	list_reagents = list("nutriment" = 4, "protein" = 5)
	tastes = list("lemongrass" = 1, "pork" = 1, "peanuts" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/calamari
	name = "Calamari"
	desc = "A fried ring of seafood meat covered in batter."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "calamari_1"
	var/list/possible_iconstates = list("calamri_1", "calamari_2", "calamari_3", "calamari_4")
	list_reagents = list("nutriment" = 1, "protein" = 1)
	tastes = list("squid" = 1, "batter" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/calamari/Initialize(mapload)
	icon_state = pick(possible_iconstates)
	update_icon()
	. = ..()

/obj/item/food/feline_mignon
	name = "Feline Mignon"
	desc = "A plate of rare steak. Is that fur?"
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "feline_mignon"
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("rare steak" = 1, "fur" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/frankfurrter
	name = "Frankfurrter"
	desc = "A piece of mixed and cased meat. Is that fur?"
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "frankfurrter"
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("meat" = 1, "fur" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/frog_leg
	name = "Frog Leg"
	desc = "A fried leg of a frog. Are frogs normally that color?"
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "frog_leg"
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("chicken" = 1, "fish" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/grey_gruel
	name = "Grey Gruel"
	desc = "A grey-looking gruel, with some purple streaks running through it."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "grey_gruel"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("synthetic meat" = 1, "blood" = 1, "acidic" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/hiss_kebab
	name = "Hiss Kebab"
	desc = "A bone rod with grilled meat. Are those scales?"
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "hiss_kebab"
	trash = /obj/item/stack/bone_rods
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("meat" = 1, "scales" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/ham_leg
	name = "Leg of Ham"
	desc = "A leg of ham."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "ham_leg"
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("long pork" = 1, "burnt hair" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/plasmabone_broth
	name = "Plasma-Bone Broth"
	desc = "A bowl of liquid plasma ."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "plasmabone_broth"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 3, "protein" = 5, "plasma" = 3)
	tastes = list("bitter" = 1, "corporate assets going to waste" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/plasmabone_broth/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, volume = I.tool_volume))
		log_and_set_aflame(user, I)
	return TRUE

/obj/item/food/plasmabone_broth/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!used.get_heat())
		return ..()
	log_and_set_aflame(user, used)
	return ITEM_INTERACT_COMPLETE

/obj/item/food/plasmabone_broth/proc/log_and_set_aflame(mob/user, obj/item/I)
	var/turf/T = get_turf(src)
	message_admins("Plasma-Bone Broth ignited by [key_name_admin(user)]([ADMIN_QUE(user, "?")]) ([ADMIN_FLW(user, "FLW")]) in ([COORD(T)] - [ADMIN_JMP(T)]")
	log_game("Plasma-Bone Broth ignited by [key_name(user)] in [COORD(T)]")
	investigate_log("was <font color='red'><b>ignited</b></font> by [key_name(user)]", INVESTIGATE_ATMOS)
	user.create_log(MISC_LOG, "Plasma-Bone Broth ignited using [I]", src)
	fire_act()

/obj/item/food/plasmabone_broth/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 30) // Borrowing from plasma sheets, 3 sheets' worth * the 10
	qdel(src)

/obj/item/food/pork_rind
	name = "Pork Rind"
	desc = "A piece of pork rind."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "pork_rind_1" // Just in case
	var/list/possible_iconstates = list("pork_rind_1", "pork_rind_2", "pork_rind_3", "pork_rind_4")
	list_reagents = list("nutriment" = 1, "protein" = 1)
	tastes = list("long pork" = 1, "salty" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/pork_rind/Initialize(mapload)
	icon_state = pick(possible_iconstates)
	update_icon()
	. = ..()

/obj/item/food/tree_salad
	name = "Tree Salad"
	desc = "A salad composed of bark and leaves. Is that a Nymph eye?"
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "tree_salad"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 3, "plantmatter" = 5)
	tastes = list("tree bark" = 1, "leaves" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/turkish_delight
	name = "Turkish Delight"
	desc = "Cubes of flavoured gelatin with sugar covering them."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "turkish_delight"
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("jelly" = 1, "sugar" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/wafers
	name = "Wafers"
	desc = "A section of metal with exposed circuit wafers."
	icon = 'icons/obj/food/cannibalism.dmi'
	icon_state = "wafers"
	list_reagents = list("lead" = 3, "iron" = 5, "gold" = 1)
	tastes = list("sweet" = 1, "metallic" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE
