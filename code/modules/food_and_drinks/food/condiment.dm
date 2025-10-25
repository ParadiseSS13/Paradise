
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
	volume = 50
	//Possible_states has the reagent id as key and a list of, in order, the icon_state, the name and the desc as values. Used in the on_reagent_change() to change names, descs and sprites.
	var/list/possible_states = list(
	"bbqsauce" = list("bbqsauce", "BBQ sauce bottle", "Sweet, smoky, savory, and gets everywhere. Perfect for grilling."),
	"ketchup" = list("ketchup", "ketchup bottle", "You feel more American already."),
	"capsaicin" = list("hotsauce", "hotsauce bottle", "You can almost TASTE the stomach ulcers now!"),
	"enzyme" = list("enzyme", "universal enzyme bottle", "Used in cooking various dishes."),
	"soysauce" = list("soysauce", "soy sauce bottle", "A salty soy-based flavoring."),
	"frostoil" = list("coldsauce", "coldsauce bottle", "Leaves the tongue numb in it's passage."),
	"sodiumchloride" = list("saltshakersmall", "salt shaker", "Salt. From space oceans, presumably."),
	"blackpepper" = list("peppermillsmall", "pepper mill", "Often used to flavor food or make people sneeze."),
	"cornoil" = list("cornoil", "corn oil bottle", "A delicious oil used in cooking. Made from corn."),
	"oliveoil" = list("oliveoil","olive oil bottle", "A high quality oil used in a variety of cuisine. Made from olives."),
	"wasabi" = list("wasabibottle", "wasabi bottle", "A pungent paste commonly served in tiny amounts with sushi. Spicy!"),
	"sugar" = list("emptycondiment", "sugar bottle", "Tasty spacey sugar!"),
	"vinegar" = list("vinegar", "vinegar", "Perfect for chips, if you're feeling Space British."),
	"mayonnaise" = list("mayonnaise", "mayonnaise bottle", "An oily condiment made from egg yolks."),
	"yogurt" = list("yogurt", "yogurt tub", "Some yogurt, produced by bacterial fermentation of milk. Yum."),
	"cherryjelly" = list("cherryjelly", "cherry jelly jar", "A sweet jelly made out of red cherries."),
	"peanutbutter" = list("peanutbutter", "peanut butter jar", "A smooth, nutty spread. Perfect for sandwiches."),
	"honey" = list("honey", "honey jar", "A sweet substance produced by bees."),
	"sugar" = list("sugar", "sugar sack", "Tasty spacey sugar!"),
	"flour" = list("flour", "flour sack", "A big bag of flour. Good for baking!"),
	"rice" = list("rice", "rice sack", "A big bag of rice. Good for cooking!"))
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
		desc = "An empty condiment bottle."
	update_appearance(UPDATE_NAME)

/obj/item/reagent_containers/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	list_reagents = list("enzyme" = 50)

/obj/item/reagent_containers/condiment/enzyme/cyborg_recharge(coeff, emagged)
	reagents.check_and_add("enzyme", volume, 2 * coeff) // Only recharge if the current amount of enzyme is under `volume`.

/obj/item/reagent_containers/condiment/sugar
	name = "sugar sack"
	desc = "Tasty spacey sugar!"
	icon_state = "sugar"
	inhand_icon_state = "carton"
	list_reagents = list("sugar" = 50)
	possible_states = list()

/// Seperate from above since it's a small shaker rather then
/obj/item/reagent_containers/condiment/saltshaker
	name = "salt shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
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
	desc = "Salt. From dead crew, presumably."
	var/space = reagents.maximum_volume - reagents.total_volume
	if(space > 0)
		reagents.add_reagent("sodiumchloride", space)
	return BRUTELOSS

/obj/item/reagent_containers/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("blackpepper" = 20)
	possible_states = list()

/obj/item/reagent_containers/condiment/milk
	name = "space milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	inhand_icon_state = "contvapour"
	list_reagents = list("milk" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	inhand_icon_state = "contvapour"
	list_reagents = list("flour" = 30)
	possible_states = list()

/obj/item/reagent_containers/condiment/bbqsauce
	name = "BBQ sauce"
	desc = "Sweet, smoky, savory, and gets everywhere. Perfect for grilling."
	icon_state = "bbqsauce"
	list_reagents = list("bbqsauce" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	inhand_icon_state = "contvapour"
	list_reagents = list("soymilk" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/rice
	name = "rice sack"
	desc = "A big bag of rice. Good for cooking!"
	icon_state = "rice"
	inhand_icon_state = "carton"
	list_reagents = list("rice" = 30)
	possible_states = list()

/obj/item/reagent_containers/condiment/soysauce
	name = "soy sauce"
	desc = "A salty soy-based flavoring."
	icon_state = "soysauce"
	list_reagents = list("soysauce" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/syndisauce
	name = "\improper Chef Excellence's Special Sauce"
	desc = "A potent sauce extracted from the potent amanita mushrooms. Death never tasted quite so delicious."
	list_reagents = list("amanitin" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/mayonnaise
	name = "mayonnaise"
	desc = "An oily condiment made from egg yolks."
	icon_state = "mayonnaise"
	list_reagents = list("mayonnaise" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/yogurt
	name = "yogurt tub"
	desc = "Some yogurt, produced by bacterial fermentation of milk. Yum."
	icon_state = "yogurt"
	list_reagents = list("yogurt" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/cherryjelly
	name = "cherry jelly"
	desc = "A sweet jelly made out of red cherries."
	icon_state = "cherryjelly"
	list_reagents = list("cherryjelly" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/peanutbutter
	name = "peanut butter"
	desc = "A smooth, nutty spread. Perfect for sandwiches."
	icon_state = "peanutbutter"
	list_reagents = list("peanutbutter" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/honey
	name = "honey"
	desc = "A sweet substance produced by bees."
	icon_state = "honey"
	list_reagents = list("honey" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/oliveoil
	name = "olive oil"
	desc = "A high quality oil derived from olives."
	icon_state = "oliveoil"
	list_reagents = list("oliveoil" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/frostoil
	name = "cold sauce"
	desc = "A special oil that noticeably chills the body. Extracted from chilly peppers."
	icon_state = "coldsauce"
	list_reagents = list("frostoil" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/capsaicin
	name = "hot sauce"
	desc = "You can almost TASTE the stomach ulcers now!"
	icon_state = "hotsauce"
	list_reagents = list("capsaicin" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/wasabi
	name = "wasabi"
	desc= "A pungent paste commonly served in tiny amounts with sushi. Spicy!"
	icon_state = "wasabibottle"
	list_reagents = list("wasabi" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/vinegar
	name = "vinegar"
	desc = "Useful for pickling, or putting on chips."
	icon_state = "vinegar"
	list_reagents = list("vinegar" = 50)
	possible_states = list()

/obj/item/reagent_containers/condiment/ketchup
	name = "ketchup"
	desc = "You feel more American already."
	icon_state = "ketchup"
	list_reagents = list("ketchup" = 50)
	possible_states = list()

//Food packs. To easily apply deadly toxi... delicious sauces to your food!

/obj/item/reagent_containers/condiment/pack
	name = "condiment pack"
	desc = "A small plastic pack with condiments to put on your food."
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null
	possible_states = list(
	"ketchup" = list("condi_ketchup", "Ketchup", "You feel more American already."),
	"capsaicin" = list("condi_hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"),
	"soysauce" = list("condi_soysauce", "Soy Sauce", "A salty soy-based flavoring."),
	"frostoil" = list("condi_frostoil", "Coldsauce", "Leaves the tongue numb in it's passage."),
	"sodiumchloride" = list("condi_salt", "Salt Shaker", "Salt. From space oceans, presumably."),
	"blackpepper" = list("condi_pepper", "Pepper Mill", "Often used to flavor food or make people sneeze."),
	"cornoil" = list("condi_cornoil", "Corn Oil", "A delicious oil used in cooking. Made from corn."),
	"sugar" = list("condi_sugar", "Sugar", "Tasty spacey sugar!"),
	"vinegar" =list("condi_mixed", "vinegar", "Perfect for chips, if you're feeling Space British."))

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
			desc = "A small condiment pack. The label says it contains [originalname]."
	else
		icon_state = "condi_empty"
		desc = "A small condiment pack. It is empty."

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
