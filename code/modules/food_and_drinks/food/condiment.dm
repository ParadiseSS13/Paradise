
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/condiment
	name = "condiment container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "emptycondiment"
	container_type = OPENCONTAINER
	possible_transfer_amounts = list(1, 5, 10, 15, 20, 25, 30, 50)
	visible_transfer_rate = TRUE
	volume = 50
	//Possible_states has the reagent id as key and a list of, in order, the icon_state, the name and the desc as values. Used in the on_reagent_change() to change names, descs and sprites.
	var/list/possible_states = list(
	"bbqsauce" = list("bbqsauce", "BBQ sauce bottle", "Сладкий и пикантный для добавок всюду. Идеален для гриля."),
	"ketchup" = list("ketchup", "ketchup bottle", "Кровь томатов!"),
	"capsaicin" = list("hotsauce", "hotsauce bottle", "Попробуй на вкус ИЗЖОГУ!"),
	"enzyme" = list("enzyme", "universal enzyme bottle", "Используется для приготовления различных блюд."),
	"soysauce" = list("soysauce", "soy sauce bottle", "Соленый соевый соус. Если попал на одежду, то замочи в нём её всю."),
	"frostoil" = list("coldsauce", "coldsauce bottle", "Пробирает до мурашек и оставляет язык онемевшим после потребления."),
	"sodiumchloride" = list("saltshakersmall", "salt shaker", "Соль. Предположительно, из космических океанов."),
	"blackpepper" = list("peppermillsmall", "pepper mill", "Часто используется для придания пряного вкуса блюдам или чтобы заставить кого-то чихнуть."),
	"cornoil" = list("cornoil", "corn oil bottle", "Вкусное масло, используемое в кулинарии. Сделано из кукурузы."),
	"oliveoil" = list("oliveoil","olive oil bottle", "Высококачественное масло, используемое в различных кухнях. Сделано из оливок."),
	"wasabi" = list("wasabibottle", "wasabi bottle", "Пикантная паста, обычно подаваемая в небольших количествах с суши. Острая!"),
	"sugar" = list("emptycondiment", "sugar bottle", "Вкусный космический сахар!"),
	"vinegar" = list("vinegar", "vinegar", "Уксус прекрасно подходит для дезинфекции, консервации, удаления накипи, устранения запахов, полоскания рта, убирания ржавчины, удаление пятна с одежды, обработку зуда после укусов, а также для заправки салатов, соусов и блюд."),
	"mayonnaise" = list("mayonnaise", "mayonnaise bottle", "Прекрасная заправка для всего и отличное сочетание с кетчупом."),
	"yogurt" = list("yogurt", "yogurt tub", "Йогурт, произведённый путём бактериальной ферментации молока. Вкусно!"),
	"cherryjelly" = list("cherryjelly", "Повидло из красной вишни."),
	"peanutbutter" = list("peanutbutter", "Нежная ореховая паста. Отлично подходит для бутербродов и аллергиков."),
	"honey" = list("honey", "honey jar", "Сладкое вещество, производимое пчёлами."),
	"sugar" = list("sugar", "sugar sack", "Большой мешок сахара. Отлично подходит для сладостей!"),
	"flour" = list("flour", "flour sack", "Большой мешок муки. Отлично подходит для выпечки!"),
	"rice" = list("rice", "rice sack", "Большой мешок риса. Отлично подходит для готовки!"))
	var/originalname = "condiment" //Can't use initial(name) for this. This stores the name set by condimasters.

/obj/item/reagent_containers/condiment/mob_act(mob/target, mob/living/user)
	. = TRUE
	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		return
	if(!iscarbon(target)) // Non-carbons can't process reagents
		to_chat(user, "<span class='warning'>You cannot find a way to feed [target].</span>")
		return

	if(target == user)
		to_chat(user, "<span class='notice'>You swallow some of the contents of [src].</span>")
	else
		user.visible_message("<span class='warning'>[user] attempts to feed [target] from [src].</span>")
		if(!do_mob(user, target))
			return
		if(!reagents || !reagents.total_volume)
			return // The condiment might be empty after the delay.
		user.visible_message("<span class='warning'>[user] feeds [target] from [src].</span>")
		add_attack_logs(user, target, "Fed [src] containing [reagents.log_list()]", reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)
	var/fraction = min(10/reagents.total_volume, 1)
	reagents.reaction(target, REAGENT_INGEST, fraction)
	reagents.trans_to(target, 10)
	playsound(target.loc,'sound/items/drink.ogg', rand(10,50), TRUE)

/obj/item/reagent_containers/condiment/normal_act(atom/target, mob/living/user) // Proc is true if any of the if checks go through. Preserves tapping behaviour on certain machinery.
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.
		. = TRUE
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty!</span>")
			return
		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return
		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_refillable() || istype(target, /obj/item/food))
		. = TRUE
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>you can't add anymore to [target]!</span>")
			return
		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the condiment to [target].</span>")

/obj/item/reagent_containers/condiment/on_reagent_change()
	if(!length(possible_states))
		return
	if(length(reagents.reagent_list) > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			name = temp_list[2]
			desc = temp_list[3]

		else
			name = "[originalname] bottle"
			main_reagent = reagents.get_master_reagent_name()
			desc = "Looks like it is [lowertext(main_reagent)], but you are not sure."
			if(length(reagents.reagent_list)==1)
				desc = "A mixture of various condiments. [lowertext(main_reagent)] is one of them."
			icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "condiment bottle"
		desc = "Пустая бутылка для соуса"
	update_appearance(UPDATE_NAME)

/obj/item/reagent_containers/condiment/enzyme
	name = "universal enzyme"
	desc = "Используется для приготовления различных блюд."
	icon_state = "enzyme"
	list_reagents = list("enzyme" = 50)

/obj/item/reagent_containers/condiment/enzyme/cyborg_recharge(coeff, emagged)
	reagents.check_and_add("enzyme", volume, 2 * coeff) // Only recharge if the current amount of enzyme is under `volume`.

/obj/item/reagent_containers/condiment/sugar
	name = "sugar sack"
	desc = "Космический сахар. Слаще, чем кажется."
	icon_state = "sugar"
	item_state = "sugar"
	list_reagents = list("sugar" = 50)
	possible_states = list()

/// Seperate from above since it's a small shaker rather then
/obj/item/reagent_containers/condiment/saltshaker
	name = "salt shaker"											//	a large one.
	desc = "Соль. Предположительно, из космических океанов."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("sodiumchloride" = 20)
	possible_states = list()

/obj/item/reagent_containers/condiment/saltshaker/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to swap forms with the salt shaker! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	var/newname = "[name]"
	name = "[user.name]"
	user.name = newname
	user.real_name = newname
	desc = "Соль. Предположительно, из мёртвого члена экипажа"
	var/space = reagents.maximum_volume - reagents.total_volume
	if(space > 0)
		reagents.add_reagent("sodiumchloride", space)
	return BRUTELOSS

/obj/item/reagent_containers/condiment/peppermill
	name = "pepper mill"
	desc = "Часто используется для придания пряного вкуса блюдам или чтобы заставить кого-то чихнуть."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("blackpepper" = 20)
	possible_states = list()

/obj/item/reagent_containers/condiment/milk
	name = "space milk"
	desc = "Пейте дети и скелеты молоко - будете здоровы!"
	icon_state = "milk"
	item_state = "carton"
	list_reagents = list("milk" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/flour
	name = "flour sack"
	desc = "Большой мешок муки. Отлично подходит для выпечки!"
	icon_state = "flour"
	item_state = "flour"
	list_reagents = list("flour" = 30)
	possible_states = list()

/obj/item/reagent_containers/condiment/bbqsauce
	name = "BBQ sauce"
	desc = "Сладкий и пикантный, подходит в качестве добавки всюду. Идеален для гриля."
	icon_state = "bbqsauce"
	list_reagents = list("bbqsauce" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/soymilk
	name = "soy milk"
	desc = "Это соевое молоко. Подходит, если у вас непереносимость лактозы."
	icon_state = "soymilk"
	item_state = "carton"
	list_reagents = list("soymilk" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/rice
	name = "rice sack"
	desc = "Большой мешок риса. Отлично подходит для готовки!"
	icon_state = "rice"
	item_state = "flour"
	list_reagents = list("rice" = 30)
	possible_states = list()

/obj/item/reagent_containers/condiment/soysauce
	name = "soy sauce"
	desc = "Соленый соевый соус. Если попал на одежду, то замочи в нём её всю."
	icon_state = "soysauce"
	list_reagents = list("soysauce" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/syndisauce
	name = "\improper Chef Excellence's Special Sauce"
	desc = "Мощный соус, изготовленный из ядовитых грибов-амманитов. Смерть никогда не имела такого восхитительного привкуса."
	list_reagents = list("amanitin" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/mayonnaise
	name = "mayonnaise"
	desc = "Прекрасная заправка для всего и отличное сочетание с кетчупом."
	icon_state = "mayonnaise"
	list_reagents = list("mayonnaise" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/yogurt
	name = "yogurt tub"
	desc = "Йогурт, произведённый путём бактериальной ферментации молока. Вкусно!"
	icon_state = "yogurt"
	list_reagents = list("yogurt" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/cherryjelly
	name = "cherry jelly"
	desc = "Повидло из красной вишни."
	icon_state = "cherryjelly"
	list_reagents = list("cherryjelly" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/peanutbutter
	name = "peanut butter"
	desc = "Нежная ореховая паста. Отлично подходит для бутербродов и аллергиков."
	icon_state = "peanutbutter"
	list_reagents = list("peanutbutter" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/honey
	name = "honey"
	desc = "Сладкое вещество, производимое пчёлами."
	icon_state = "honey"
	list_reagents = list("honey" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/oliveoil
	name = "olive oil"
	desc = "Высококачественное масло, используемое в различных кухнях. Сделано из оливок."
	icon_state = "oliveoil"
	list_reagents = list("oliveoil" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/frostoil
	name = "cold sauce"
	desc = "Пробирает до мурашек и оставляет язык онемевшим после потребления."
	icon_state = "coldsauce"
	list_reagents = list("frostoil" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/capsaicin
	name = "hot sauce"
	desc = "Попробуй на вкус ИЗЖОГУ!"
	icon_state = "hotsauce"
	list_reagents = list("capsaicin" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/wasabi
	name = "wasabi"
	desc= "Пикантная паста, обычно подаваемая в небольших количествах с суши. Острая!"
	icon_state = "wasabibottle"
	list_reagents = list("wasabi" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/vinegar
	name = "vinegar"
	desc = "Подходит для засолки. Лучше не пить даже бесплатно."
	icon_state = "vinegar"
	list_reagents = list("vinegar" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/ketchup
	name = "ketchup"
	desc = "Кровь томатов!"
	icon_state = "ketchup"
	list_reagents = list("ketchup" = 50)
	possible_states = list()

//Food packs. To easily apply deadly toxi... delicious sauces to your food!

/obj/item/reagent_containers/condiment/pack
	name = "condiment pack"
	desc = "Небольшая пластиковая упаковка с приправой для добавления в пищу."
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null
	possible_states = list(
	"ketchup" = list("condi_ketchup", "Ketchup", "Кровь томатов!"),
	"capsaicin" = list("condi_hotsauce", "Hotsauce", "Попробуй на вкус ИЗЖОГУ!"),
	"soysauce" = list("condi_soysauce", "Soy Sauce", "Соленый соевый соус. Если попал на одежду, то замочи в нём её всю."),
	"frostoil" = list("condi_frostoil", "Coldsauce", "Пробирает до мурашек и оставляет язык онемевшим после потребления."),
	"sodiumchloride" = list("condi_salt", "Salt Shaker", "Соль. Предположительно, из космических океанов."),
	"blackpepper" = list("condi_pepper", "Pepper Mill", "Часто используется для придания вкуса блюдам или чтобы заставить кого-то чихнуть."),
	"cornoil" = list("condi_cornoil", "Corn Oil", "Вкусное масло, используемое в кулинарии. Сделано из кукурузы."),
	"sugar" = list("condi_sugar", "Sugar", "Небольшой пакетик с сахаром."),
	"vinegar" =list("condi_mixed", "vinegar", "Уксус прекрасно подходит для дезинфекции, консервации, удаления накипи, устранения запахов, полоскания рта, убирания ржавчины, удаление пятна с одежды, обработку зуда после укусов, а также для заправки салатов, соусов и блюд."))

/obj/item/reagent_containers/condiment/pack/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	//You can tear the bag open above food to put the condiments on it, obviously.
	if(istype(target, /obj/item/food))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>You tear open [src], but there's nothing in it.</span>")
			qdel(src)
			return ITEM_INTERACT_COMPLETE
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>You tear open [src], but [target] is stacked so high that it just drips off!</span>") //Not sure if food can ever be full, but better safe than sorry.
			qdel(src)
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='notice'>You tear open [src] above [target] and the condiments drip onto it.</span>")
			reagents.trans_to(target, amount_per_transfer_from_this)
			qdel(src)
			return ITEM_INTERACT_COMPLETE

	if(isliving(target)) // Ignore mobs. Don't tap mobs.
		return ITEM_INTERACT_COMPLETE

/obj/item/reagent_containers/condiment/pack/on_reagent_change()
	if(length(reagents.reagent_list) > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			desc = temp_list[3]
		else
			icon_state = "condi_mixed"
			desc = "Небольшая упаковка с приправой. На ярлыке написано, что она содержит [originalname]."
	else
		icon_state = "condi_empty"
		desc = "Небольшая упаковка для приправ. Она пуста."

//Ketchup
/obj/item/reagent_containers/condiment/pack/ketchup
	name = "ketchup pack"
	originalname = "ketchup"
	list_reagents = list("ketchup" = 10)

//Hot sauce
/obj/item/reagent_containers/condiment/pack/hotsauce
	name = "hotsauce pack"
	originalname = "hotsauce"
	list_reagents = list("capsaicin" = 10)
