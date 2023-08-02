/* Stack type objects!
 * Contains:
 * 		Stacks
 * 		Recipe datum
 * 		Recipe list datum
 */

/*
 * Stacks
 */
/obj/item/stack
	origin_tech = "materials=1"
	/// A list to all recipies this stack item can create.
	var/list/recipes = list()
	/// What's the name of just 1 of this stack. You have a stack of leather, but one piece of leather
	var/singular_name
	/// How much is in this stack?
	var/amount = 1
	/// See stack recipes initialization. "max_res_amount" must be equal to this max_amount
	var/max_amount = 50
	/// The weight class the stack has at amount > 2/3rds of max_amount
	var/full_w_class = WEIGHT_CLASS_NORMAL
	/// This path and its children should merge with this stack, defaults to src.type
	var/merge_type = null
	/// Width of the recipe popup
	var/recipe_width = 400
	/// Height of the recipe popup
	var/recipe_height = 400
	/// If TRUE, this stack is a module used by a cyborg (doesn't run out like normal / etc)
	var/is_cyborg = FALSE
	/// Related to above. If present, the energy we draw from when using stack items, for cyborgs
	var/datum/robot_energy_storage/source
	/// Related to above. How much energy it costs from storage to use stack items
	var/cost = 1
	/// Related to above. Determines what stack will actually be put in machine when using cyborg stacks on construction to avoid spawning those on deconstruction.
	var/cyborg_construction_stack


/obj/item/stack/Initialize(mapload, new_amount, merge = TRUE)
	if(new_amount != null)
		amount = new_amount
	while(amount > max_amount)
		amount -= max_amount
		new type(loc, max_amount, FALSE)
	if(!merge_type)
		merge_type = type

	. = ..()

	if(merge)
		for(var/obj/item/stack/item_stack in loc)
			if(item_stack == src)
				continue
			if(can_merge(item_stack))
				INVOKE_ASYNC(src, PROC_REF(merge_without_del), item_stack)
				if(is_zero_amount(delete_if_zero = FALSE))
					return INITIALIZE_HINT_QDEL

	update_weight()
	update_icon()


/obj/item/stack/Destroy()
	if(usr && usr.machine == src)
		usr << browse(null, "window=stack")
	return ..()


/obj/item/stack/proc/list_recipes(mob/user, recipes_sublist)
	if(!recipes)
		return

	if(amount <= 0)
		user << browse(null, "window=stack")
		return

	user.set_machine(src) //for correct work of onclose

	var/list/recipe_list = recipes
	if(recipes_sublist && recipe_list[recipes_sublist] && istype(recipe_list[recipes_sublist], /datum/stack_recipe_list))
		var/datum/stack_recipe_list/srl = recipe_list[recipes_sublist]
		recipe_list = srl.recipes

	var/t1 = "Amount Left: [get_amount()]<br>"
	for(var/i in 1 to recipe_list.len)
		var/E = recipe_list[i]
		if(isnull(E))
			t1 += "<hr>"
			continue

		if(i > 1 && !isnull(recipe_list[i - 1]))
			t1 += "<br>"

		if(istype(E, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/srl = E
			t1 += "<a href='?src=[UID()];sublist=[i]'>[srl.title]</a>"

		if(istype(E, /datum/stack_recipe))
			var/datum/stack_recipe/R = E
			var/max_multiplier = round(get_amount() / R.req_amount)
			var/title
			var/can_build = 1
			can_build = can_build && (max_multiplier > 0)

			if(R.res_amount > 1)
				title += "[R.res_amount]x [R.title]\s"
			else
				title += "[R.title]"
			title += " ([R.req_amount] [src.singular_name]\s)"
			if(can_build)
				t1 += "<A href='?src=[UID()];sublist=[recipes_sublist];make=[i]'>[title]</A>  "
			else
				t1 += "[title]"
				continue
			if(R.max_res_amount > 1 && max_multiplier > 1)
				max_multiplier = min(max_multiplier, round(R.max_res_amount / R.res_amount))
				t1 += " |"

				var/list/multipliers = list(5, 10, 25)
				for(var/n in multipliers)
					if(max_multiplier >= n)
						t1 += " <A href='?src=[UID()];sublist=[recipes_sublist];make=[i];multiplier=[n]'>[n * R.res_amount]x</A>"
				if(!(max_multiplier in multipliers))
					t1 += " <A href='?src=[UID()];sublist=[recipes_sublist];make=[i];multiplier=[max_multiplier]'>[max_multiplier * R.res_amount]x</A>"

	var/datum/browser/popup = new(user, "stack", name, recipe_width, recipe_height)
	popup.set_content(t1)
	popup.open(0)
	onclose(user, "stack")


/obj/item/stack/Topic(href, href_list)
	..()
	if(usr.incapacitated() || !usr.is_in_active_hand(src))
		return 0

	if(href_list["sublist"] && !href_list["make"])
		list_recipes(usr, text2num(href_list["sublist"]))

	if(href_list["make"])
		if(get_amount() < 1 && !is_cyborg)
			qdel(src) //Never should happen

		var/list/recipes_list = recipes
		if(href_list["sublist"])
			var/datum/stack_recipe_list/srl = recipes_list[text2num(href_list["sublist"])]
			recipes_list = srl.recipes

		var/datum/stack_recipe/R = recipes_list[text2num(href_list["make"])]
		var/multiplier = text2num(href_list["multiplier"])
		if(!multiplier || multiplier <= 0 || multiplier > 50) // Href exploit checks
			multiplier = 1

		if(get_amount() < R.req_amount * multiplier)
			if(R.req_amount * multiplier>1)
				to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.req_amount * multiplier] [R.title]\s!</span>")
			else
				to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.title]!</span>")
			return FALSE

		if(R.window_checks && !valid_window_location(usr.loc, usr.dir))
			to_chat(usr, "<span class='warning'>The [R.title] won't fit here!</span>")
			return FALSE

		if(R.one_per_turf && (locate(R.result_type) in usr.drop_location()))
			to_chat(usr, "<span class='warning'>There is another [R.title] here!</span>")
			return FALSE

		if(R.on_floor && !istype(usr.drop_location(), /turf/simulated))
			if(!R.on_lattice)
				to_chat(usr, "<span class='warning'>\The [R.title] must be constructed on the floor!</span>")
				return FALSE
			if(!(locate(/obj/structure/lattice) in usr.drop_location()))
				to_chat(usr, "<span class='warning'>\The [R.title] must be constructed on the floor or lattice!</span>")
				return FALSE

		if(R.cult_structure)
			if(!is_level_reachable(usr.z))
				to_chat(usr, "<span class='warning'>The energies of this place interfere with the metal shaping!</span>")
				return FALSE
			if(locate(/obj/structure/cult) in usr.drop_location())
				to_chat(usr, "<span class='warning'>There is a structure here!</span>")
				return FALSE
			if(locate(/obj/structure/clockwork) in usr.drop_location())
				to_chat(usr, "<span class='warning'>There is a structure here!</span>")
				return FALSE
		var/area/A = get_area(usr)
		if(R.result_type == /obj/structure/clockwork/functional/beacon)
			if(!is_station_level(usr.z))
				to_chat(usr, "<span class='warning'>The beacon cannot guide from this place! It must be on station!</span>")
				return FALSE
			if(istype(A, /area/space))
				to_chat(usr, "<span class='warning'>The beacon must be inside the station itself to properly work.")
				return FALSE
			if(A.get_beacon())
				to_chat(usr, "<span class='warning'>This area already has beacon!</span>")
				return FALSE
		if(R.time)
			to_chat(usr, "<span class='notice'>Building [R.title] ...</span>")
			if(!do_after(usr, R.time, target = usr))
				return FALSE

		if(R.cult_structure && locate(/obj/structure/cult) in get_turf(src)) //Check again after do_after to prevent queuing construction exploit.
			to_chat(usr, "<span class='warning'>There is a structure here!</span>")
			return FALSE
		if(R.cult_structure && locate(/obj/structure/clockwork) in get_turf(src))
			to_chat(usr, "<span class='warning'>There is a structure here!</span>")
			return FALSE

		if(get_amount() < R.req_amount * multiplier)
			return

		var/atom/O
		if(R.max_res_amount > 1) //Is it a stack?
			O = new R.result_type(usr.drop_location(), R.res_amount * multiplier)
		else
			O = new R.result_type(usr.drop_location())
		O.setDir(usr.dir)
		use(R.req_amount * multiplier)

		R.post_build(src, O)

		if(amount < 1) // Just in case a stack's amount ends up fractional somehow
			var/oldsrc = src
			src = null //dont kill proc after qdel()
			usr.temporarily_remove_item_from_inventory(oldsrc, force = TRUE)
			qdel(oldsrc)
			if(istype(O, /obj/item))
				usr.put_in_hands(O)

		O.add_fingerprint(usr)
		//BubbleWrap - so newly formed boxes are empty
		if(istype(O, /obj/item/storage))
			for(var/obj/item/I in O)
				qdel(I)
		//BubbleWrap END

	if(src && usr.machine == src) //do not reopen closed window
		spawn(0)
			interact(usr)
			return


/obj/item/stack/examine(mob/user)
	. = ..()
	if(is_cyborg)
		if(singular_name)
			. += "There is enough energy for [get_amount()] [singular_name]\s."
		else
			. += "There is enough energy for [get_amount()]."
		return
	if(in_range(user, src))
		if(singular_name)
			. += "There are [amount] [singular_name]\s in the stack."
		else
			. += "There are [amount] [name]\s in the stack."
		. += SPAN_NOTICE("<b>Alt-click</b> with an empty hand to take a custom amount.")


/obj/item/stack/Crossed(obj/item/crossing, oldloc)
	if(can_merge(crossing, inhand = FALSE))
		merge(crossing)
	. = ..()


/obj/item/stack/hitby(atom/movable/hitting, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(can_merge(hitting, inhand = TRUE))
		merge(hitting)
	. = ..()


/obj/item/stack/attack_self(mob/user)
	list_recipes(user)


/obj/item/stack/attack_self_tk(mob/user)
	list_recipes(user)


/obj/item/stack/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, SPAN_WARNING("You can't do that right now!</span>"))
		return
	if(!in_range(src, user))
		return
	if(!ishuman(user))
		return
	if(amount < 1)
		return
	//get amount from user
	var/max = get_amount()
	var/stackmaterial = round(input(user, "How many sheets do you wish to take out of this stack? (Maximum: [max])") as null|num)
	if(stackmaterial == null || stackmaterial <= 0 || stackmaterial > get_amount())
		return
	if(!Adjacent(user, 1))
		return
	split_stack(user, stackmaterial)
	do_pickup_animation(user)
	to_chat(user, SPAN_NOTICE("You take [stackmaterial] sheets out of the stack."))


/obj/item/stack/attack_tk(mob/user)
	if(user.stat || !isturf(loc))
		return
	// Allow remote stack splitting, because telekinetic inventory managing
	// is really cool
	if(src in user.tkgrabbed_objects)
		var/obj/item/stack/F = split_stack(user, 1)
		F.attack_tk(user)
		. = F
		if(src && user.machine == src)
			spawn(0)
				interact(user)
	else
		. = ..()


/obj/item/stack/attack_hand(mob/user)
	if(user.is_in_inactive_hand(src))
		if(is_zero_amount(delete_if_zero = TRUE))
			return FALSE
		. = split_stack(user, 1)
		if(src && user.machine == src)
			spawn(0)
				interact(user)
	else
		. = ..()


/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if(can_merge(W, inhand = TRUE))
		do_pickup_animation(user)
		var/obj/item/stack/S = W
		if(merge(S))
			to_chat(user, SPAN_NOTICE("Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s."))
	else
		. = ..()


/obj/item/stack/proc/copy_evidences(obj/item/stack/from)
	blood_DNA			= from.blood_DNA
	fingerprints		= from.fingerprints
	fingerprintshidden	= from.fingerprintshidden
	fingerprintslast	= from.fingerprintslast


/**
 * Returns TRUE if the item stack is the equivalent of a 0 amount item.
 *
 * Also deletes the item if delete_if_zero is TRUE and the stack does not have
 * is_cyborg set to true.
 */
/obj/item/stack/proc/is_zero_amount(delete_if_zero = TRUE)
	if(is_cyborg)
		return source.energy < cost
	if(amount < 1)
		if(delete_if_zero)
			qdel(src)
		return TRUE
	return FALSE


/obj/item/stack/proc/get_amount()
	if(is_cyborg)
		. = round(source?.energy / cost)
	else
		. = amount


/** Adds some number of units to this stack.
 *
 * Arguments:
 * * newamount: The number of units to add to this stack.
 */
/obj/item/stack/proc/add(newamount)
	if(is_cyborg)
		source.add_charge(newamount * cost)
	else
		amount += newamount
		update_icon()
		update_weight()
		if(isstorage(loc))
			var/obj/item/storage/container = loc
			addtimer(CALLBACK(container, TYPE_PROC_REF(/obj/item/storage, drop_overweight)), 0)


/obj/item/stack/proc/update_weight()
	if(amount <= (max_amount * (1/3)))
		w_class = clamp(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
	else if (amount <= (max_amount * (2/3)))
		w_class = clamp(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
	else
		w_class = full_w_class


/obj/item/storage/proc/drop_overweight()
	if(QDELETED(src))
		return

	for(var/obj/item/stack/item_stack in contents)
		if(item_stack.is_cyborg)
			continue

		if(item_stack.w_class > max_w_class)
			var/drop_loc = get_turf(src)
			item_stack.pixel_x = pixel_x
			item_stack.pixel_y = pixel_y
			item_stack.forceMove(drop_loc)
			var/mob/holder = usr
			if(holder)
				to_chat(holder, span_warning("[item_stack] exceeds [src] weight limits and drops to [drop_loc]"))


/obj/item/stack/use(used, transfer = FALSE, check = TRUE)
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return FALSE
	if(is_cyborg)
		return source.use_charge(used * cost)
	if(amount < used)
		return FALSE
	amount -= used
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return TRUE
	update_weight()
	update_icon()
	return TRUE


/** Splits the stack into two stacks.
 *
 * Arguments:
 * - [user][/mob]: The mob splitting the stack.
 * - amount: The number of units to split from this stack.
 */
/obj/item/stack/proc/split_stack(mob/user, amount)
	if(!use(amount, FALSE))
		return null
	var/obj/item/stack/F = new type(user ? user : drop_location(), amount, FALSE)
	. = F
	F.copy_evidences(src)

	if(user)
		if(!user.put_in_hands(F, merge_stacks = FALSE))
			F.forceMove(user.drop_location())
		add_fingerprint(user)
		F.add_fingerprint(user)

	is_zero_amount(delete_if_zero = TRUE)


/** Checks whether this stack can merge itself into another stack.
 *
 * Arguments:
 * - [check][/obj/item/stack]: The stack to check for mergeability.
 * - [inhand][boolean]: Whether or not the stack to check should act like it's in a mob's hand.
 */
/obj/item/stack/proc/can_merge(obj/item/stack/check, inhand = FALSE)
	if(!istype(check, merge_type))
		return FALSE
	if(is_cyborg) // No merging cyborg stacks into other stacks
		return FALSE
	if(ismob(loc) && !inhand) // no merging with items that are on the mob
		return FALSE
	if(check.throwing)	// no merging for items in middle air
		return FALSE
	if(istype(loc, /obj/machinery)) // no merging items in machines that aren't both in componentparts
		var/obj/machinery/machine = loc
		if(!(src in machine.component_parts) || !(check in machine.component_parts))
			return FALSE
	return TRUE


/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This calls use() without check = FALSE, preventing the item from qdeling itself if it reaches 0 stack size.
 *
 * As a result, this proc can leave behind a 0 amount stack.
 */
/obj/item/stack/proc/merge_without_del(obj/item/stack/target_stack, limit)
	// Cover edge cases where multiple stacks are being merged together and haven't been deleted properly.
	// Also cover edge case where a stack is being merged into itself, which is supposedly possible.
	if(!target_stack)
		CRASH("Stack merge attempted on qdeleted target stack.")
	if(!src)
		CRASH("Stack merge attempted on qdeleted source stack.")
	if(target_stack == src)
		CRASH("Stack attempted to merge into itself.")

	var/transfer = get_amount()
	if(target_stack.is_cyborg)
		transfer = min(transfer, round((target_stack.source.max_energy - target_stack.source.energy) / target_stack.cost))
	else
		transfer = min(transfer, (limit ? limit : target_stack.max_amount) - target_stack.amount)
	if(pulledby)
		pulledby.start_pulling(target_stack)
	target_stack.copy_evidences(src)
	use(transfer, transfer = TRUE, check = FALSE)
	target_stack.add(transfer)
	return transfer


/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This proc deletes src if the remaining amount after the transfer is 0.
 */
/obj/item/stack/proc/merge(obj/item/stack/target_stack, limit)
	. = merge_without_del(target_stack, limit)
	is_zero_amount(delete_if_zero = TRUE)
