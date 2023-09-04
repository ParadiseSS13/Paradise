GLOBAL_LIST_INIT(rod_recipes, list (
	new /datum/stack_recipe("grille", /obj/structure/grille, 2, time = 1 SECONDS, one_per_turf = TRUE, on_floor_or_lattice = TRUE),
	new /datum/stack_recipe("table frame", /obj/structure/table_frame, 2, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("catwalk tile", /obj/item/stack/tile/catwalk, 2, 4, 20),
	null,
	new /datum/stack_recipe("railing", /obj/structure/railing, 3, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	new /datum/stack_recipe("railing corner", /obj/structure/railing/corner, 3, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new /datum/stack_recipe_list("chainlink fence", list(
		new /datum/stack_recipe("chainlink fence", /obj/structure/fence, 5, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("chainlink fence post", /obj/structure/fence/post, 5, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("chainlink fence corner", /obj/structure/fence/corner, 5, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("chainlink fence door", /obj/structure/fence/door, 10, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("chainlink fence end", /obj/structure/fence/end, 3, time = 1 SECONDS, one_per_turf = TRUE, on_floor = TRUE),
		)),
	))

/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon = 'icons/obj/stacks/minerals.dmi'
	icon_state = "rods-5"
	item_state = "rods"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_NORMAL
	force = 9.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=1000)
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'
	merge_type = /obj/item/stack/rods



/obj/item/stack/rods/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Using rods on a floor plating will install a reinforced floor. You can make reinforced glass by combining rods and normal glass sheets.</span>"


/obj/item/stack/rods/cyborg
	energy_type = /datum/robot_energy_storage/rods
	is_cyborg = TRUE
	materials = list()

/obj/item/stack/rods/cyborg/update_icon_state()
	return // icon_state should always be a full stack of rods.

/obj/item/stack/rods/ten
	amount = 10

/obj/item/stack/rods/twentyfive
	amount = 25

/obj/item/stack/rods/fifty
	amount = 50

/obj/item/stack/rods/New(loc, amount=null)
	..()
	recipes = GLOB.rod_recipes
	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/rods/update_icon_state()
	var/amount = get_amount()
	icon_state = "rods-[clamp(amount, 1, 5)]"

/obj/item/stack/rods/welder_act(mob/user, obj/item/I)
	if(get_amount() < 2)
		to_chat(user, "<span class='warning'>You need at least two rods to do this!</span>")
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/obj/item/stack/sheet/metal/new_item = new(drop_location())
	if(new_item.get_amount() <= 0)
		// stack was moved into another one on the pile
		new_item = locate() in user.loc
	visible_message("<span class='notice'>[user.name] shapes [src] into metal with [I]!</span>", \
					"<span class='notice'>You shape [src] into metal with [I]!</span>", \
					"<span class='warning'>You hear welding.</span>")
	var/replace = user.is_in_inactive_hand(src)
	use(2)
	if(get_amount() <= 0 && replace)
		user.unEquip(src, 1)
		if(new_item)
			user.put_in_hands(new_item)
