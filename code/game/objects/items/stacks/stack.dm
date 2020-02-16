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
	var/list/recipes = list() // /datum/stack_recipe
	var/singular_name
	var/amount = 1
	var/to_transfer = 0
	var/max_amount = 50 //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/merge_type = null // This path and its children should merge with this stack, defaults to src.type

/obj/item/stack/New(loc, new_amount, merge = TRUE)
	..()
	if(new_amount != null)
		amount = new_amount
	while(amount > max_amount)
		amount -= max_amount
		new type(loc, max_amount, FALSE)
	if(!merge_type)
		merge_type = type
	if(merge && !(amount >= max_amount))
		for(var/obj/item/stack/S in loc)
			if(S.merge_type == merge_type)
				merge(S)

/obj/item/stack/Crossed(obj/O, oldloc)
	if(amount >= max_amount || ismob(loc)) // Prevents unnecessary call. Also prevents merging stack automatically in a mob's inventory
		return
	if(istype(O, merge_type) && !O.throwing)
		merge(O)
	..()

/obj/item/stack/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(istype(AM, merge_type) && !(amount >= max_amount))
		merge(AM)
	. = ..()

/obj/item/stack/Destroy()
	if(usr && usr.machine == src)
		usr << browse(null, "window=stack")
	return ..()

/obj/item/stack/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(singular_name)
			. += "There are [amount] [singular_name]\s in the stack."
		else
			. += "There are [amount] [name]\s in the stack."
		. +="<span class='notice'>Alt-click to take a custom amount.</span>"

/obj/item/stack/proc/add(newamount)
	amount += newamount
	update_icon()

/obj/item/stack/attack_self(mob/user)
	list_recipes(user)

/obj/item/stack/attack_self_tk(mob/user)
	list_recipes(user)

/obj/item/stack/attack_tk(mob/user)
	if(user.stat || !isturf(loc)) return
	// Allow remote stack splitting, because telekinetic inventory managing
	// is really cool
	if(src in user.tkgrabbed_objects)
		var/obj/item/stack/F = split(user, 1)
		F.attack_tk(user)
		if(src && user.machine == src)
			spawn(0)
				interact(user)
	else
		..()


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

	var/t1 = "Amount Left: [amount]<br>"
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
			var/max_multiplier = round(amount / R.req_amount)
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
						t1 += " <A href='?src=[UID()];make=[i];multiplier=[n]'>[n * R.res_amount]x</A>"
				if(!(max_multiplier in multipliers))
					t1 += " <A href='?src=[UID()];make=[i];multiplier=[max_multiplier]'>[max_multiplier * R.res_amount]x</A>"

	var/datum/browser/popup = new(user, "stack", name, 400, 400)
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
		if(amount < 1)
			qdel(src) //Never should happen

		var/list/recipes_list = recipes
		if(href_list["sublist"])
			var/datum/stack_recipe_list/srl = recipes_list[text2num(href_list["sublist"])]
			recipes_list = srl.recipes

		var/datum/stack_recipe/R = recipes_list[text2num(href_list["make"])]
		var/multiplier = text2num(href_list["multiplier"])
		if(!multiplier || multiplier <= 0 || multiplier > 50) // Href exploit checks
			multiplier = 1

		if(amount < R.req_amount * multiplier)
			if(R.req_amount * multiplier>1)
				to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.req_amount * multiplier] [R.title]\s!</span>")
			else
				to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.title]!</span>")
			return 0

		if(R.window_checks && !valid_window_location(usr.loc, usr.dir))
			to_chat(usr, "<span class='warning'>The [R.title] won't fit here!</span>")
			return FALSE

		if(R.one_per_turf && (locate(R.result_type) in usr.drop_location()))
			to_chat(usr, "<span class='warning'>There is another [R.title] here!</span>")
			return 0

		if(R.on_floor && !istype(usr.drop_location(), /turf/simulated))
			to_chat(usr, "<span class='warning'>\The [R.title] must be constructed on the floor!</span>")
			return 0

		if(R.time)
			to_chat(usr, "<span class='notice'>Building [R.title] ...</span>")
			if(!do_after(usr, R.time, target = usr))
				return 0

		if(amount < R.req_amount * multiplier)
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
			src = null //dont kill proc after del()
			usr.unEquip(oldsrc, 1)
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

/obj/item/stack/use(used, check = TRUE)
	if(check && zero_amount())
		return FALSE
	if(amount < used)
		return FALSE
	amount -= used
	if(check)
		zero_amount()
	update_icon()
	return TRUE

/obj/item/stack/proc/get_amount()
	return amount

/obj/item/stack/proc/get_max_amount()
	return max_amount

/obj/item/stack/proc/get_amount_transferred()
	return to_transfer

/obj/item/stack/proc/split(mob/user, amt)
	var/obj/item/stack/F = new type(loc, amt)
	F.copy_evidences(src)
	if(isliving(user))
		add_fingerprint(user)
		F.add_fingerprint(user)
	use(amt)
	return F

/obj/item/stack/attack_hand(mob/user)
	if(user.is_in_inactive_hand(src) && amount > 1)
		change_stack(user, 1)
		if(src && usr.machine == src)
			spawn(0)
				interact(usr)
	else
		..()

/obj/item/stack/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	if(!ishuman(usr))
		return
	if(amount < 1)
		return
	//get amount from user
	var/min = 0
	var/max = get_amount()
	var/stackmaterial = round(input(user, "How many sheets do you wish to take out of this stack? (Maximum: [max])") as null|num)
	if(stackmaterial == null || stackmaterial <= min || stackmaterial > get_amount())
		return
	change_stack(user,stackmaterial)
	to_chat(user, "<span class='notice'>You take [stackmaterial] sheets out of the stack.</span>")

/obj/item/stack/proc/change_stack(mob/user,amount)
	var/obj/item/stack/F = new type(user, amount, FALSE)
	. = F
	F.copy_evidences(src)
	user.put_in_hands(F)
	add_fingerprint(user)
	F.add_fingerprint(user)
	use(amount)

/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if(istype(W, merge_type))
		var/obj/item/stack/S = W
		merge(S)
		to_chat(user, "<span class='notice'>Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s.</span>")
	else
		return ..()

// Returns TRUE if the stack amount is zero.
// Also qdels the stack gracefully if it is.
/obj/item/stack/proc/zero_amount()
	if(amount < 1)
		if(isrobot(loc))
			var/mob/living/silicon/robot/R = loc
			if(locate(src) in R.module.modules)
				R.module.modules -= src
		if(ismob(loc))
			var/mob/living/L = loc // At this stage, stack code is so horrible and atrocious, I wouldn't be all surprised ghosts can somehow have stacks. If this happens, then the world deserves to burn.
			L.unEquip(src, TRUE)
		if(amount < 1)
			// If you stand on top of a stack, and drop a - different - 0-amount stack on the floor,
			// the two get merged, so the amount of items in the stack can increase from the 0 that it had before.
			// Check the amount again, to be sure we're not qdeling healthy stacks.
			qdel(src)
		return TRUE
	return FALSE

/obj/item/stack/proc/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(QDELETED(S) || QDELETED(src) || S == src) //amusingly this can cause a stack to consume itself, let's not allow that.
		return FALSE
	var/transfer = get_amount()
	transfer = min(transfer, S.max_amount - S.amount)
	if(transfer <= 0)
		return
	if(pulledby)
		pulledby.start_pulling(S)
	S.copy_evidences(src)
	S.add(transfer)
	use(transfer)

/obj/item/stack/proc/copy_evidences(obj/item/stack/from)
	blood_DNA			= from.blood_DNA
	fingerprints		= from.fingerprints
	fingerprintshidden	= from.fingerprintshidden
	fingerprintslast	= from.fingerprintslast
