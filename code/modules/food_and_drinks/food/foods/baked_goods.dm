#define DONUT_NORMAL	1
#define DONUT_FROSTED	2

//////////////////////
//		Cakes		//
//////////////////////

/obj/item/reagent_containers/food/snacks/sliceable/carrotcake
	name = "carrot cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/reagent_containers/food/snacks/carrotcakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#FFD675"
	list_reagents = list("nutriment" = 20, "oculine" = 10, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "carrot" = 1)

/obj/item/reagent_containers/food/snacks/carrotcakeslice
	name = "carrot cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD675"
	tastes = list("cake" = 5, "sweetness" = 2, "carrot" = 1)


/obj/item/reagent_containers/food/snacks/sliceable/braincake
	name = "brain cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/reagent_containers/food/snacks/braincakeslice
	slices_num = 5
	filling_color = "#E6AEDB"
	bitesize = 3
	list_reagents = list("protein" = 10, "nutriment" = 10, "mannitol" = 10, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "brains" = 1)

/obj/item/reagent_containers/food/snacks/braincakeslice
	name = "brain cake slice"
	desc = "Lemme tell you something about brains. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#E6AEDB"
	tastes = list("cake" = 5, "sweetness" = 2, "brains" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/cheesecake
	name = "cheese cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesecakeslice
	slices_num = 5
	filling_color = "#FAF7AF"
	bitesize = 3
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 4, "cream cheese" = 3)

/obj/item/reagent_containers/food/snacks/cheesecakeslice
	name = "cheese cake slice"
	desc = "Slice of pure cheestisfaction."
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAF7AF"
	tastes = list("cake" = 4, "cream cheese" = 3)

/obj/item/reagent_containers/food/snacks/sliceable/plaincake
	name = "vanilla cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/reagent_containers/food/snacks/plaincakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#F7EDD5"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "vanilla" = 1, "sweetness" = 2)

/obj/item/reagent_containers/food/snacks/plaincakeslice
	name = "vanilla cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#F7EDD5"
	tastes = list("cake" = 5, "vanilla" = 1, "sweetness" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/orangecake
	name = "orange cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/reagent_containers/food/snacks/orangecakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#FADA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "oranges" = 2)

/obj/item/reagent_containers/food/snacks/orangecakeslice
	name = "orange cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FADA8E"
	tastes = list("cake" = 5, "sweetness" = 2, "oranges" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/bananacake
	name = "banana cake"
	desc = "A cake with added bananas."
	icon_state = "bananacake"
	slice_path = /obj/item/reagent_containers/food/snacks/bananacakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#FADA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "banana" = 2)

/obj/item/reagent_containers/food/snacks/bananacakeslice
	name = "banana cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "bananacake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FADA8E"
	tastes = list("cake" = 5, "sweetness" = 2, "banana" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/limecake
	name = "lime cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	bitesize = 3
	slice_path = /obj/item/reagent_containers/food/snacks/limecakeslice
	slices_num = 5
	filling_color = "#CBFA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "unbearable sourness" = 2)

/obj/item/reagent_containers/food/snacks/limecakeslice
	name = "lime cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#CBFA8E"
	tastes = list("cake" = 5, "sweetness" = 2, "unbearable sourness" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/lemoncake
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/reagent_containers/food/snacks/lemoncakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#FAFA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "sourness" = 2)

/obj/item/reagent_containers/food/snacks/lemoncakeslice
	name = "lemon cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAFA8E"
	tastes = list("cake" = 5, "sweetness" = 2, "sourness" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/chocolatecake
	name = "chocolate cake"
	desc = "A cake with added chocolate."
	icon_state = "chocolatecake"
	slice_path = /obj/item/reagent_containers/food/snacks/chocolatecakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#805930"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "chocolate" = 4)

/obj/item/reagent_containers/food/snacks/chocolatecakeslice
	name = "chocolate cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#805930"
	tastes = list("cake" = 5, "sweetness" = 1, "chocolate" = 4)

/obj/item/reagent_containers/food/snacks/sliceable/birthdaycake
	name = "birthday cake"
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/reagent_containers/food/snacks/birthdaycakeslice
	slices_num = 5
	filling_color = "#FFD6D6"
	bitesize = 3
	list_reagents = list("nutriment" = 20, "sprinkles" = 10, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 1)

/obj/item/reagent_containers/food/snacks/birthdaycakeslice
	name = "birthday cake slice"
	desc = "A slice of your birthday"
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD6D6"
	tastes = list("cake" = 5, "sweetness" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/applecake
	name = "apple cake"
	desc = "A cake centered with Apple."
	icon_state = "applecake"
	slice_path = /obj/item/reagent_containers/food/snacks/applecakeslice
	slices_num = 5
	bitesize = 3
	filling_color = "#EBF5B8"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "apple" = 1)

/obj/item/reagent_containers/food/snacks/applecakeslice
	name = "apple cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#EBF5B8"
	tastes = list("cake" = 5, "sweetness" = 1, "apple" = 1)


//////////////////////
//		Cookies		//
//////////////////////

/obj/item/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	bitesize = 1
	filling_color = "#DBC94F"
	list_reagents = list("nutriment" = 1, "sugar" = 3, "hot_coco" = 5 )
	tastes = list("cookie" = 1, "crunchy chocolate" = 1)

/obj/item/reagent_containers/food/snacks/fortunecookie
	name = "fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	filling_color = "#E8E79E"
	list_reagents = list("nutriment" = 3)
	trash = /obj/item/paper/fortune
	tastes = list("cookie" = 1)

/obj/item/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"
	list_reagents = list("nutriment" = 1, "sugar" = 3)
	tastes = list("sweetness" = 1)


//////////////////////
//		Pies		//
//////////////////////

/obj/item/reagent_containers/food/snacks/pie
	name = "banana cream pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	filling_color = "#FBFFB8"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "banana" = 5, "vitamin" = 2)
	tastes = list("pie" = 1)

/obj/item/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/pie_smudge(loc)
	visible_message("<span class='warning'>[src] splats.</span>","<span class='warning'>You hear a splat.</span>")
	qdel(src)

/obj/item/reagent_containers/food/snacks/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/plate
	filling_color = "#948051"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "tofu" = 1)

/obj/item/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	filling_color = "#FFCCCC"
	bitesize = 4
	list_reagents = list("nutriment" = 6, "amanitin" = 3, "psilocybin" = 1, "vitamin" = 4)
	tastes = list("pie" = 1, "mushroom" = 1)

/obj/item/reagent_containers/food/snacks/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	filling_color = "#B8279B"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "mushroom" = 1)

/obj/item/reagent_containers/food/snacks/plump_pie/Initialize(mapload)
	. = ..()
	if(prob(10))
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!" // What
		reagents.add_reagent("omnizine", 5)

/obj/item/reagent_containers/food/snacks/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	filling_color = "#43DE18"
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "meat" = 1, "acid" = 1)


/obj/item/reagent_containers/food/snacks/applepie
	name = "apple pie"
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	filling_color = "#E0EDC5"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "apple" = 1)


/obj/item/reagent_containers/food/snacks/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	filling_color = "#FF525A"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "cherries" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	bitesize = 3
	filling_color = "#F5B951"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("pie" = 1, "pumpkin" = 1)

/obj/item/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#F5B951"
	tastes = list("pie" = 1, "pumpkin" = 1)

//////////////////////
//		Donuts		//
//////////////////////

/obj/item/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	bitesize = 5
	list_reagents = list("nutriment" = 3, "sugar" = 2)
	var/extra_reagent = null
	filling_color = "#D2691E"
	var/randomized_sprinkles = 1
	var/donut_sprite_type = DONUT_NORMAL
	tastes = list("donut" = 1)

/obj/item/reagent_containers/food/snacks/donut/Initialize(mapload)
	. = ..()
	if(randomized_sprinkles && prob(30))
		icon_state = "donut2"
		name = "frosted donut"
		reagents.add_reagent("sprinkles", 2)
		donut_sprite_type = DONUT_FROSTED
		filling_color = "#FF69B4"

/obj/item/reagent_containers/food/snacks/donut/sprinkles
	name = "frosted donut"
	icon_state = "donut2"
	list_reagents = list("nutriment" = 3, "sugar" = 2, "sprinkles" = 2)
	filling_color = "#FF69B4"
	donut_sprite_type = DONUT_FROSTED
	randomized_sprinkles = 0

/obj/item/reagent_containers/food/snacks/donut/chaos
	name = "chaos donut"
	desc = "Like life, it never quite tastes the same."
	bitesize = 10
	tastes = list("donut" = 3, "chaos" = 1)

/obj/item/reagent_containers/food/snacks/donut/chaos/Initialize(mapload)
	. = ..()
	extra_reagent = pick("nutriment", "capsaicin", "frostoil", "krokodil", "plasma", "cocoa", "slimejelly", "banana", "berryjuice", "omnizine")
	reagents.add_reagent("[extra_reagent]", 3)
	if(prob(30))
		icon_state = "donut2"
		name = "frosted chaos donut"
		reagents.add_reagent("sprinkles", 2)
		filling_color = "#FF69B4"

/obj/item/reagent_containers/food/snacks/donut/jelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	extra_reagent = "berryjuice"
	tastes = list("jelly" = 1, "donut" = 3)

/obj/item/reagent_containers/food/snacks/donut/jelly/Initialize(mapload)
	. = ..()
	if(extra_reagent)
		reagents.add_reagent("[extra_reagent]", 3)
	if(prob(30))
		icon_state = "jdonut2"
		name = "frosted jelly Donut"
		donut_sprite_type = DONUT_FROSTED
		reagents.add_reagent("sprinkles", 2)
		filling_color = "#FF69B4"

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	extra_reagent = "slimejelly"

/obj/item/reagent_containers/food/snacks/donut/jelly/cherryjelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	extra_reagent = "cherryjelly"

//////////////////////
//		Pancakes	//
//////////////////////

/obj/item/reagent_containers/food/snacks/pancake
	name = "pancake"
	desc = "A plain pancake."
	icon_state = "pancake"
	filling_color = "#E7D8AB"
	bitesize = 2
	list_reagents = list("nutriment" = 3, "sugar" = 3)

/obj/item/reagent_containers/food/snacks/pancake/attack_tk(mob/user)
	if(src in user.tkgrabbed_objects)
		to_chat(user, "<span class='notice'>You start channeling psychic energy into [src].</span>")
		visible_message("<span class='danger'>The syrup on [src] starts to boil...</span>")
		if(do_after_once(user, 4 SECONDS, target = src))
			visible_message("<span class='danger'>[src] suddenly combust!</span>")
			to_chat(user, "<span class='warning'>You combust [src] with your mind!</span>")
			explosion(get_turf(src), light_impact_range = 2, flash_range = 2)
			add_attack_logs(user, src, "blew up [src] with TK", ATKLOG_ALL)
			qdel(src)
			return
		to_chat(user, "<span class='notice'>You decide against the destruction of [src].</span>")
		return
	return ..()

/obj/item/reagent_containers/food/snacks/pancake/berry_pancake
	name = "berry pancake"
	desc = "A pancake loaded with berries."
	icon_state = "berry_pancake"
	list_reagents = list("nutriment" = 3, "sugar" = 3, "berryjuice" = 3)

/obj/item/reagent_containers/food/snacks/pancake/choc_chip_pancake
	name = "choc-chip pancake"
	desc = "A pancake loaded with chocolate chips."
	icon_state = "choc_chip_pancake"
	list_reagents = list("nutriment" = 3, "sugar" = 3, "cocoa" = 3)

//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
	filling_color = "#E0CF9B"
	list_reagents = list("nutriment" = 6)
	tastes = list("muffin" = 1)

/obj/item/reagent_containers/food/snacks/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate
	bitesize = 3
	list_reagents = list("nutriment" = 10, "berryjuice" = 5, "vitamin" = 2)
	tastes = list("pie" = 1, "blackberries" = 1)


/obj/item/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "A large soft pretzel full of POP! It's all twisted up!"
	icon_state = "poppypretzel"
	filling_color = "#916E36"
	list_reagents = list("nutriment" = 5)
	tastes = list("pretzel" = 1)

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	filling_color = "#CFB4C4"
	list_reagents = list("nutriment" = 5)
	tastes = list("mushroom" = 1, "biscuit" = 1)

/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit/Initialize(mapload)
	. = ..()
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!" // Is this a reference?
		reagents.add_reagent("omnizine", 5)

/obj/item/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	filling_color = "#FFFF00"
	bitesize = 3
	list_reagents = list("nutriment" = 8, "gold" = 5, "vitamin" = 4)
	tastes = list("pie" = 1, "apple" = 1, "expensive metal" = 1)


/obj/item/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	bitesize = 1
	filling_color = "#F5DEB8"
	list_reagents = list("nutriment" = 1)
	tastes = list("cracker" = 1)

/obj/item/reagent_containers/food/snacks/croissant
	name = "croissant"
	desc = "Once a pastry reserved for the bourgeois, this flaky goodness is now on your table."
	icon_state = "croissant"
	bitesize = 4
	filling_color = "#ecb54f"
	list_reagents = list("nutriment" = 4, "sugar" = 2)
	tastes = list("croissant" = 1)

/obj/item/reagent_containers/food/snacks/croissant/throwing
	throwforce = 20
	throw_range = 9 //now with extra throwing action
	tastes = list("croissant" = 2, "butter" = 1, "metal" = 1)
	list_reagents = list("nutriment" = 4, "sugar" = 2, "iron" = 1)

/obj/item/reagent_containers/food/snacks/croissant/throwing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/boomerang, throw_range, TRUE)

#undef DONUT_NORMAL
#undef DONUT_FROSTED
