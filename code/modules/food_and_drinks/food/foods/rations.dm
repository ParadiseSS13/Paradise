// MARK:	Standalone Rations
/obj/item/food/rations
	name = "arbitrary ration"
	desc = "If you can see this, make an issue report on GitHub. Something went wrong!"
	icon = 'icons/obj/food/rations.dmi'
	icon_state = "liquidfood"
	/// For rations with removable packaging.
	var/opened = FALSE
	/// Icon to swap to when the packaging is opened.
	var/opened_icon = "liquidfood"

/obj/item/food/rations/attack(mob/M, mob/user, def_zone)
	if(..())
		return

	if(!opened)
		to_chat(user, "<span class='warning'>[src] cannot be eaten without removing the packaging first!</span>")

/obj/item/food/rations/activate_self(mob/user)
	if(..())
		return

	if(!opened)
		opened = TRUE
		update_icon_state()
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE, -5)
		to_chat(user, "<span class='notice'>You tear open the packaging of [src].</span>")

/obj/item/food/rations/update_icon_state()
	icon_state = opened_icon

/obj/item/food/rations/liquidfood
	name = "\improper LiquidFood ration packet"
	desc = "A prepackaged grey slurry containing all the essential vitamins, nutrients, and calories that a hungry spacefarer needs. Guaranteed to cause mental breakdowns after only 2 consecutive days of consumption."
	consume_sound = 'sound/items/drink.ogg'
	opened = TRUE
	trash = /obj/item/trash/liquidfood
	filling_color = "#A8A8A8"
	list_reagents = list("nutriment" = 20, "iron" = 5, "vitamin" = 10)
	tastes = list("chemicals" = 3, "mush" = 2, "artificial vanilla, struggling to reach your tastebuds" = 1)

/obj/item/food/rations/liquidfood/examine_more(mob/user)
	. = ..()
	. += "LiquidFood rations were created by the startup UltraFood Solutions in response to a call by the Trans-Solar Federation's armed forces to develop an ultra high-performance combat ration for use by elite units."
	. += ""
	. += "Through tireless research, constant re-evaluation, and (some would say) dubious testing methodology, they successfully created what they pitched as the perfect ration: \
	lightweight, compact, requiring no preperation, able to be consumed on the move, full of nutrition that is fully absorbed by all humanoid species, all while being cheap and easy to mass manufacture."
	. += ""
	. += "Unfortunately, the TSF's trials of the new ration revealed that it was almost universally lothed by anyone that consumed it. \
	Whilst it was ultimately rejected, UltraFood simply turned around and started marketing to penny-pinching megacorporations that didn't care about that particular detail."
	// Only show the snarky final part if you actually work for NT.
	if(user.mind.special_role)
		var/role = lowertext(user.mind.special_role)
		if(!role == SPECIAL_ROLE_DEATHSQUAD && !role == ROLE_ERT)
			return
	. += ""
	. += "Like the one <b>you</b> work for..."

/obj/item/food/rations/liquidfood/On_Consume(mob/M, mob/user)
	if(prob(10))
		M.visible_message(
			SPAN_DANGER("[M] vomits on the floor profusely!"),
			SPAN_DANGER("The vile taste of [src] overpowers you, and you empty your stomach onto the floor!"),
			SPAN_DANGER("You hear someone vomiting all over the floor!")
		)
		M.fakevomit(no_text = 1)
		M.adjust_nutrition(-rand(5, 10))

/obj/item/food/rations/nutrient_prism
	name = "type I survival bar"
	desc = "The standard field ration for the USSP. An ultra-dense bar of compressed nutritional components and essential vitamins, known to be difficult to chew. \
	It has a shelf life so long that it has not yet been demonstrated to exist."
	icon_state = "nutrient_prism"
	opened_icon = "nutrient_prism_open"
	bitesize = 5	// It will take a while to get through this thing.
	list_reagents = list("nutriment" = 30, "vitamin" = 20)	// It's PURE, CONCENTRATED NUTRITION, COMRADE!
	tastes = list("malt" = 3, "whey protien" = 2, "expired multivitamins" = 1)

/obj/item/food/rations/nutrient_prism/examine_more(mob/user)
	. = ..()
	. += "The Type I Survival Bar replaced the USSP's older ramshackle collection of canned rations in 2530, \
	with the dual aim of reducing the carry mass and volume of its soldiers, and massively simplifying the food logistics involved with supplying its vast armies."
	. += ""
	. += "Weighing just 600 grams and small enough to fit into any pocket, it is a testement to the genius minds of the USSP's food scientists. \
	It also takes forever to chew through it thanks to its sheer density and chewy texture, and the flavour is quite bland - with no menu variation. \
	Rumors are abound that the Type II may finally be on the horizon, giving a glimmer of hope that something better will come along."

/obj/item/food/rations/nutrient_prism/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!ishuman(target))
		return ..()

	if(!opened)
		to_chat(user, "<span class = 'warning'>[src] cannot be eaten without removing the packaging first!</span>")
		return ITEM_INTERACT_COMPLETE

	to_chat(user, "<span class = 'notice'>You start to bite into [src] and try to rip a small piece off.</span>")
	if(!do_after_once(user, delay = 5 SECONDS, target = user))	// It's VERY VERY chewy. A few months of service and you shall have the most strong, chiseled jaw ever. Like the soldiers on propagana posters have.
		to_chat(user, "<span class = 'notice'>You give up on trying to bite through [src].</span>")
		return ITEM_INTERACT_COMPLETE

	to_chat(user, "<span class = 'notice'>You successfully manage to rip a small chunk out of [src].</span>")
	return ..()


// MARK:	MRE Mains
/obj/item/food/rations/mre/chicken
	name = "fried chicken breast"
	desc = "It's a little tough, but the taste is still fine."
	icon_state = "ration_pouch"
	opened_icon = "chicken"
	list_reagents = list("nutriment" = 3, "vitamin" = 5, "protein" = 12, "salt" = 3)
	tastes = list("chicken" = 3, "salt and spices" = 2)

/obj/item/food/rations/mre/pork
	name = "Boneless BBQ Pork"
	desc = "Smokey, meaty, delicous. The sauce is a little dry."
	icon_state = "ration_pouch"
	opened_icon = "boneless_pork"
	list_reagents = list("nutriment" = 3, "vitamin" = 5, "protein" = 12, "bbqsauce" = 10, "salt" = 3)
	tastes = list("pork" = 2, "BBQ sauce" = 3, "salt" = 1)

/obj/item/food/rations/mre/pizza
	name = "pepperoni pizza square"
	desc = "Unfortunately, you can go wrong with pizza."
	icon_state = "ration_pouch"
	opened_icon = "pizza_square"
	list_reagents = list("nutriment" = 10, "protein" = 5, "tomatojuice" = 6)
	tastes = list("cheese" = 2, "cardboard" = 3, "bread" = 1)

/obj/item/food/rations/mre/sushi
	name = "suishi bites"
	desc = "Multiple bits of assorted sushi. The fish is cooked..."
	icon_state = "ration_pouch"
	opened_icon = "sushi_bites"
	list_reagents = list("vitamin" = 4, "protein" = 8, "plantmatter" = 8)
	tastes = list("rice" = 3, "fish" = 2, "egg" = 2, "seaweed" = 1)

/obj/item/food/rations/mre/spaghetti
	name = "spaghetti bolognese"
	desc = "A mass of overcooked spaghetti in tomato purée."
	icon_state = "ration_pouch"
	opened_icon = "spaghetti_pouch"
	list_reagents = list("vitamin" = 6, "plantmatter" = 12, "tomatojuice" = 6, "salt" = 3)
	tastes = list("spaghetti" = 2, "tomato" = 3)

/obj/item/food/rations/mre/fettuccini
	name = "spinach fettuccini"
	desc = "A mixture of pasta and spinach in a creamy sauce. Doesn't smell inviting."
	icon_state = "ration_pouch"
	opened_icon = "fettuccini_pouch"
	list_reagents = list("nutriment" = 4, "vitamin" = 10, "plantmatter" = 12, "salt" = 3)
	tastes = list("rubbery pasta" = 2, "earthy spinach" = 2, "an unsettling cream sauce" = 3, "herbs" = 1, "salt" = 1)

/obj/item/food/rations/mre/vomlette
	name = "cheese and vegetable omlette"
	desc = "Also known as the \"Vomlette\". It doesn't look like an omlette, it doesn't taste like an omlette, and it sure as hell doesn't <b>smell</b> like an omlette! No redeeming qualities whatsoever."
	icon_state = "ration_pouch"
	opened_icon = "vomlette"
	list_reagents = list("nutriment" = 10, "plantmatter" = 15)
	tastes = list("very artifical cheese" = 3, "chemicals" = 2 , "artificial preservatives" = 1, "something resembling a vegetable" = 2)

// MARK:	MRE Sides
/obj/item/food/rations/mre/cavatelli
	name = "cavatelli pasta"
	desc = "Lots of bits of cavatelli. Some of them are still hard and crunchy."
	icon_state = "ration_pouch"
	opened_icon = "pasta_pouch"
	list_reagents = list("nutriment" = 5, "vitamin" = 3, "salt" = 3)
	tastes = list("pasta" = 3, "salt" = 1)

/obj/item/food/rations/mre/rice
	name = "fried rice"
	desc = "A portion of dry fried rice."
	icon_state = "ration_pouch"
	opened_icon = "rice_pouch"
	list_reagents = list("nutriment" = 5, "plantmatter" = 5, "salt" = 1)
	tastes = list("rice" = 3, "salt" = 1)

/obj/item/food/rations/mre/cheese_crackers
	name = "cheese crackers"
	desc = "Crackers injected with imitation cheese product."
	icon_state = "ration_packet"
	opened_icon = "cheese_cracker"
	list_reagents = list("nutriment" = 5, "plantmatter" = 5, "salt" = 3)
	tastes = list("cracker" = 2, "artificial cheese" = 2, "salt" = 1)

/obj/item/food/rations/mre/onigiri
	name = "rice onigiri"
	desc = "A ball of sticky white rice with a strip of seaweed wrapped around the base. This one is actually okay."
	icon_state = "ration_packet"
	opened_icon = "onigiri"
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "plantmatter" = 4)
	tastes = list("rice" = 2, "sweetness" = 3, "seaweed" = 1)

/obj/item/food/rations/mre/meatballs
	name = "meatballs"
	desc = "A collection of small meatballs. Some of them are charred."
	icon_state = "ration_pouch"
	opened_icon = "meatball_cluster"
	list_reagents = list("nutriment" = 1, "vitamin" = 4, "protein" = 4)
	tastes = list("meat" = 3)

/obj/item/food/rations/mre/pretzel_nugget
	name = "pretzel nuggets"
	desc = "A collection of crunchy treats, flavoured with honey mustard and big salt crystals."
	icon_state = "ration_packet"
	opened_icon = "pretzel_nuggets"
	list_reagents = list("nutriment" = 8, "plantmatter" = 1, "salt" = 5)
	tastes = list("mustard" = 2, "tangy sweetness" = 2, "salt" = 2)

// MARK:	MRE Snacks
/obj/item/food/rations/mre/peanut_crackers
	name = "peanut butter crackers"
	desc = "Crackers injected with peanut butter. The crackers are liable to crumble before you can get them to your mouth."
	icon_state = "ration_packet"
	opened_icon = "peanut_cracker"
	list_reagents = list("nutriment" = 5, "peanutbutter" = 5, "salt" = 3)
	tastes = list("peanut butter" = 3, "cracker" = 2, "salt" = 1)

/obj/item/food/rations/mre/fighting_fuel	// Powerful ration bar, can also be found on its own.
	name = "fighting fuel"
	desc = "A nutritious, calorie-dense energy bar that is also found in the pre-emptive strike ration - manufactured by SolGov. Makes you want to scream <b>\"OORAH!\"</b>. \
	People are known to save the label to affix it to various items."
	icon_state = "fighting_fuel"
	opened_icon = "fighting_fuel_open"
	list_reagents = list("vitamin" = 13, "chocolate" = 5)
	tastes = list("chocolate" = 2, "fruits and nuts" = 2, "<b>FREEDOM</b>" = 3)

/obj/item/food/rations/mre/bun
	name = "cinnamon bun"
	desc = "Despite alledgedly being a bun, it's more like cake. Contains so much sugar that your teeth are getting cavities just from looking at this thing."
	icon_state = "ration_pouch"
	opened_icon = "cinnamon_bun"
	list_reagents = list("nutriment" = 5, "sugar" = 15)
	tastes = list("overwhelming sweetness" = 3, "cinnamon" = 2, "cake" = 3, "bread" = 1)

/obj/item/food/rations/mre/trail_mix
	name = "recovery trail mix"
	desc = "A healthy mix of dried fruit and nuts, helps keep hunger at bay."
	icon_state = "ration_packet"
	opened_icon = "trail_mix"
	list_reagents = list("vitamin" = 6)
	tastes = list("fruits" = 2, "nuts" = 2)

// MARK:	MRE Desserts
/obj/item/food/rations/mre/brownie
	name = "chocolate brownie"
	desc = "The flavour is so good, you don't really mind that it's dry and crumbly."
	icon_state = "ration_packet"
	opened_icon = "brownie"
	list_reagents = list("nutriment" = 6, "chocolate" = 5, "sugar" = 3)
	tastes = list("chocolate" = 3, "sweetness" = 2)

/obj/item/food/rations/mre/flan
	name = "honey flan"
	desc = "A sweet dessert made from condensed milk, caramel sauce, and honey. This jackpot item has high value in ration trading."
	icon_state = "ration_packet"
	opened_icon = "flan"
	list_reagents = list("nutriment" = 5, "honey" = 2, "cream" = 2, "milk" = 2, "sugar" = 3)
	tastes = list("honey" = 3, "caramel" = 2, "sweetness" = 2)

/obj/item/food/rations/mre/pbj
	name = "peanut butter & jelly cracker"
	desc = "A large cracker filled with a PB&J mix. Takes the edge off."
	icon_state = "ration_packet"
	opened_icon = "pbj_cracker"
	list_reagents = list("nutriment" = 6, "peanutbutter" = 3, "cherryjelly" = 3, "sugar" = 2)
	tastes = list("peanut butter" = 2, "jelly" = 2, "cracker" = 1)

/obj/item/food/rations/mre/spiced_apple
	name = "spiced apple"
	desc = "An apple, sliced into sections, drenched in a spiced cinnamon sauce."
	icon_state = "ration_pouch"
	opened_icon = "spiced_apple"
	list_reagents = list("nutriment" = 6, "sugar" = 4)
	tastes = list("cinnamon" = 2, "apple" = 2, "spices" = 1)

/obj/item/food/rations/mre/smores
	name = "military-grade smores bar"
	desc = "A bunch of marshmallows and chocolate bits stuck together with sticky granola. Surprisingly tastes better than any smores bar you can find in stores."
	icon_state = "ration_bar"
	opened_icon = "smores"
	list_reagents = list("nutriment" = 6, "chocolate" = 3, "sugar" = 8)
	tastes = list("chocolate" = 2, "marshmallow" = 2, "sweet sticky granola" = 3)

/obj/item/food/rations/mre/pancake
	name = "maple syrup pancake"
	desc = "A pancake fortified with maple syrup and butter. A wonder of modern food technology."
	icon_state = "ration_pouch"
	opened_icon = "pancake"
	list_reagents = list("nutriment" = 5, "sugar" = 12)
	tastes = list("pancake" = 2, "maple syrup" = 3, "butter" = 1)

/obj/item/food/rations/mre/granola
	name = "blueberry granola"
	desc = "Blueberry granola suspended in milk. It's less bad than it sounds."
	icon_state = "ration_pouch"
	opened_icon = "granola_drink"
	list_reagents = list("vitamin" = 3, "milk" = 5, "sugar" = 5)
	tastes = list("blueberry" = 3, "granola" = 2, "milk" = 3)
