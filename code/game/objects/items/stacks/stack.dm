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
	var/list/datum/stack_recipe/recipes
	var/singular_name
	var/amount = 1
	var/max_amount //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount

/obj/item/stack/New(var/loc, var/amount=null)
	..()
	if (amount!=null)	//Allow for stacks with the amount=0
		src.amount=amount
	return

/obj/item/stack/Destroy()
	if (usr && usr.machine==src)
		usr << browse(null, "window=stack")
	return ..()

/obj/item/stack/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "There are [src.amount] [src.singular_name]\s in the stack.")


/obj/item/stack/attack_self(mob/user as mob)
	list_recipes(user)

/obj/item/stack/proc/list_recipes(mob/user as mob, recipes_sublist)
	if (!recipes)
		return
	if (!src || amount<=0)
		user << browse(null, "window=stack")
	user.set_machine(src) //for correct work of onclose
	var/list/recipe_list = recipes
	if (recipes_sublist && recipe_list[recipes_sublist] && istype(recipe_list[recipes_sublist], /datum/stack_recipe_list))
		var/datum/stack_recipe_list/srl = recipe_list[recipes_sublist]
		recipe_list = srl.recipes
	var/t1 = text("<HTML><HEAD><title>Constructions from []</title></HEAD><body><TT>Amount Left: []<br>", src, src.amount)
	for(var/i=1;i<=recipe_list.len,i++)
		var/E = recipe_list[i]
		if (isnull(E))
			t1 += "<hr>"
			continue

		if (i>1 && !isnull(recipe_list[i-1]))
			t1+="<br>"

		if (istype(E, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/srl = E
			if (src.amount >= srl.req_amount)
				t1 += "<a href='?src=\ref[src];sublist=[i]'>[srl.title] ([srl.req_amount] [src.singular_name]\s)</a>"
			else
				t1 += "[srl.title] ([srl.req_amount] [src.singular_name]\s)<br>"

		if (istype(E, /datum/stack_recipe))
			var/datum/stack_recipe/R = E
			var/max_multiplier = round(src.amount / R.req_amount)
			var/title as text
			var/can_build = 1
			can_build = can_build && (max_multiplier>0)
			/*
			if (R.one_per_turf)
				can_build = can_build && !(locate(R.result_type) in usr.loc)
			if (R.on_floor)
				can_build = can_build && istype(usr.loc, /turf/simulated/floor)
			*/
			if (R.res_amount>1)
				title+= "[R.res_amount]x [R.title]\s"
			else
				title+= "[R.title]"
			title+= " ([R.req_amount] [src.singular_name]\s)"
			if (can_build)
				t1 += text("<A href='?src=\ref[src];sublist=[recipes_sublist];make=[i]'>[title]</A>  ")
			else
				t1 += text("[]", title)
				continue
			if (R.max_res_amount>1 && max_multiplier>1)
				max_multiplier = min(max_multiplier, round(R.max_res_amount/R.res_amount))
				t1 += " |"
				var/list/multipliers = list(5,10,25)
				for (var/n in multipliers)
					if (max_multiplier>=n)
						t1 += " <A href='?src=\ref[src];make=[i];multiplier=[n]'>[n*R.res_amount]x</A>"
				if (!(max_multiplier in multipliers))
					t1 += " <A href='?src=\ref[src];make=[i];multiplier=[max_multiplier]'>[max_multiplier*R.res_amount]x</A>"

	t1 += "</TT></body></HTML>"
	user << browse(t1, "window=stack")
	onclose(user, "stack")
	return

/obj/item/stack/Topic(href, href_list)
	..()
	if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
		return

	if (href_list["sublist"] && !href_list["make"])
		list_recipes(usr, text2num(href_list["sublist"]))

	if (href_list["make"])
		if (src.amount < 1) del(src) //Never should happen

		var/list/recipes_list = recipes
		if (href_list["sublist"])
			var/datum/stack_recipe_list/srl = recipes_list[text2num(href_list["sublist"])]
			recipes_list = srl.recipes
		var/datum/stack_recipe/R = recipes_list[text2num(href_list["make"])]
		var/multiplier = text2num(href_list["multiplier"])
		if (!multiplier) multiplier = 1
		if (src.amount < R.req_amount*multiplier)
			if (R.req_amount*multiplier>1)
				to_chat(usr, "\red You haven't got enough [src] to build \the [R.req_amount*multiplier] [R.title]\s!")
			else
				to_chat(usr, "\red You haven't got enough [src] to build \the [R.title]!")
			return
		if (R.one_per_turf && (locate(R.result_type) in usr.loc))
			to_chat(usr, "\red There is another [R.title] here!")
			return
		if (R.on_floor && !istype(usr.loc, /turf/simulated))
			to_chat(usr, "\red \The [R.title] must be constructed on the floor!")
			return
		if (R.time)
			to_chat(usr, "\blue Building [R.title] ...")
			if (!do_after(usr, R.time, target = usr))
				return
		if (src.amount < R.req_amount*multiplier)
			return
		var/atom/O = new R.result_type( usr.loc )
		O.dir = usr.dir
		if (R.max_res_amount>1)
			var/obj/item/stack/new_item = O
			new_item.amount = R.res_amount*multiplier
			//new_item.add_to_stacks(usr)
		src.amount-=R.req_amount*multiplier
		if (src.amount < 1) // Just in case a stack's amount ends up fractional somehow
			var/oldsrc = src
			src = null //dont kill proc after del()
			usr.unEquip(oldsrc, 1)
			del(oldsrc) // Not qdel, because qdel'd stacks act strange for cyborgs
			if (istype(O,/obj/item))
				usr.put_in_hands(O)
		O.add_fingerprint(usr)
		//BubbleWrap - so newly formed boxes are empty
		if ( istype(O, /obj/item/weapon/storage) )
			for (var/obj/item/I in O)
				del(I)
		//BubbleWrap END
	if (src && usr.machine==src) //do not reopen closed window
		spawn( 0 )
			src.interact(usr)
			return
	return

/obj/item/stack/proc/use(var/used)
	if (amount < used)
		return 0
	amount -= used
	if (amount < 1) // Just in case a stack's amount ends up fractional somehow
		if(usr)
			usr.unEquip(src, 1)
		spawn()
			del(src) // Not qdel, because qdel'd stacks act strange for cyborgs
	update_icon()
	return 1

/obj/item/stack/proc/add_to_stacks(mob/usr as mob)
	var/obj/item/stack/oldsrc = src
	src = null
	for (var/obj/item/stack/item in usr.loc)
		if (item==oldsrc)
			continue
		if (!istype(item, oldsrc.type))
			continue
		if (item.amount>=item.max_amount)
			continue
		oldsrc.attackby(item, usr)
		to_chat(usr, "You add new [item.singular_name] to the stack. It now contains [item.amount] [item.singular_name]\s.")
		if(oldsrc.amount <= 0)
			break
	oldsrc.update_icon()

/obj/item/stack/proc/get_amount()
	return amount

/obj/item/stack/proc/get_max_amount()
	return max_amount

/obj/item/stack/proc/split(mob/user, amt)
	var/obj/item/stack/F = new type(user, amt)
	F.copy_evidences(src)
	if(isliving(user))
		add_fingerprint(user)
		F.add_fingerprint(user)
	use(amt)
	return F

/obj/item/stack/attack_hand(mob/user as mob)
	if (user.get_inactive_hand() == src)
		var/obj/item/stack/F = split(user, 1)
		user.put_in_hands(F)
		if(src && usr.machine == src)
			spawn(0)
				interact(usr)
	else
		..()

/obj/item/stack/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if (istype(W, src.type))
		var/obj/item/stack/S = W
		if (S.amount >= max_amount)
			return 1
		var/to_transfer as num
		if (user.get_inactive_hand()==src)
			var/desired = input("How much would you like to transfer from this stack?", "How much?", 1) as null|num
			if(!desired)
				return
			desired = round(desired)
			to_transfer = max(1,min(desired,S.max_amount-S.amount,src.amount))
		else
			to_transfer = min(src.amount, S.max_amount-S.amount)
		S.amount+=to_transfer
		if (S && usr.machine==S)
			spawn(0) S.interact(usr)
		src.use(to_transfer)
		if (src && usr.machine==src)
			spawn(0) src.interact(usr)
		S.update_icon()
	else return ..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from as obj)
	src.blood_DNA = from.blood_DNA
	src.fingerprints  = from.fingerprints
	src.fingerprintshidden  = from.fingerprintshidden
	src.fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/*
 * Recipe datum
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = 0
	var/on_floor = 0
	New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0)
		src.title = title
		src.result_type = result_type
		src.req_amount = req_amount
		src.res_amount = res_amount
		src.max_res_amount = max_res_amount
		src.time = time
		src.one_per_turf = one_per_turf
		src.on_floor = on_floor

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null
	var/req_amount = 1
	New(title, recipes, req_amount = 1)
		src.title = title
		src.recipes = recipes
		src.req_amount = req_amount
