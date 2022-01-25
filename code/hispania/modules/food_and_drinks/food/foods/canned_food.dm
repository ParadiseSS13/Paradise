///Bases comida enlatada
/obj/item/reagent_containers/food/snacks/canned_food
	name = "canned air"
	desc = "In the distant future air its expensive."
	icon = 'icons/hispania/obj/food/canned_food.dmi'
	icon_state = "blank"
	trash = /obj/item/trash/canned_food
	antable = FALSE
	var/sealed = TRUE

/obj/item/reagent_containers/food/snacks/canned_food/examine(mob/user)
	. = ..()
	to_chat(user, "It is [sealed ? "" : "un"]sealed.")

/obj/item/reagent_containers/food/snacks/canned_food/attack_self(mob/user)
	if(sealed)
		playsound(loc,'sound/effects/canopen.ogg', rand(10,50), 1)
		to_chat(user, "<span class='notice'>You unseal \the [src] with a crack of metal.</span>")
		unseal()

/obj/item/reagent_containers/food/snacks/canned_food/proc/unseal()
	sealed = FALSE
	update_icon()

/obj/item/reagent_containers/food/snacks/canned_food/attack(mob/M, mob/user, proximity)
	if(sealed)
		to_chat(user, "<span class='notice'>You need to open the can!</span>")
		antable = TRUE
		return
	return ..()

/obj/item/reagent_containers/food/snacks/canned_food/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return
	else
		return ..(target, user, proximity)

/obj/item/reagent_containers/food/snacks/canned_food/update_icon()
	if(!sealed)
		icon_state = "[initial(icon_state)]-open"

///Comida Enlatada
/obj/item/reagent_containers/food/snacks/canned_food/beef
	name = "canned beef"
	icon_state = "beef"
	desc = "Proteins carefully cloned from extinct stock of holstein in the meat foundries of Mars."
	trash = /obj/item/trash/canned_beef
	filling_color = "#663300"
	tastes = list("beef" = 1)
	list_reagents = list("nutriment" = 4, "sodiumchloride" = 4)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/canned_food/beans
	name = "canned beans"
	icon_state = "beans"
	desc = "Luna Colony beans. Carefully synthethized from soy."
	trash = /obj/item/trash/canned_beans
	filling_color = "#ff6633"
	list_reagents = list("beans" = 4, "sodiumchloride" = 4)
	tastes = list("beans" = 1)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/canned_food/tomato
	name = "canned tomato soup"
	icon_state = "tomato"
	desc = "Plain old unseasoned tomato soup. This can predates the formation of the SCG."
	trash = /obj/item/trash/canned_tomato
	filling_color = "#ae0000"
	list_reagents = list("tomatojuice" = 4, "sodiumchloride" = 4)
	tastes = list("tomato" = 1)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/canned_food/spinach
	name = "canned spinach"
	icon_state = "spinach"
	desc = "Wup-Az! Brand canned spinach. Notably has less iron in it than a watermelon."
	trash = /obj/item/trash/canned_spinach
	filling_color = "#003300"
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 2, "sodiumchloride" = 1) //WEEDEATER
	tastes = list("soggy" = 1, "vegetable" = 1)
	bitesize = 4

/obj/item/reagent_containers/food/snacks/canned_food/true
	name = "canned ilegal caviar"
	icon_state = "carpeggs"
	desc = "Terran caviar, or space carp eggs. Banned by the Sol Food Health Administration for exceeding the legally set amount of carpotoxins in foodstuffs."
	trash = /obj/item/trash/canned_carpegg
	filling_color = "#330066"
	list_reagents = list("protein" = 1, "carpotoxin" = 2, "vitamin" = 1)
	tastes = list("fish" = 1, "salt" = 1, "numbing sensation" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/canned_food/caviar
	name = "canned caviar"
	icon_state = "fisheggs"
	desc = "Terran caviar, or space carp eggs. Carefully faked using alginate, artificial flavoring and salt. Skrell approved!"
	trash = /obj/item/trash/canned_fishegg
	filling_color = "#000000"
	list_reagents = list("protein" = 3, "sodiumchloride" = 1)
	tastes = list("fish" = 1, "salt" = 1)
	bitesize = 2
