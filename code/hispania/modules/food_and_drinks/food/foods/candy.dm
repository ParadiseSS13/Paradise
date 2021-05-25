/obj/item/reagent_containers/food/snacks/nisperocandy
	name = "Nispero Candy"
	desc = "A jar full of sticky candys of nispero."
	icon = 'icons/hispania/obj/food/candy.dmi'
	icon_state = "nisperocandy"
	bitesize = 0.8
	trash = /obj/item/trash/empty_jar
	list_reagents = list("nutriment" = 1, "sugar" = 4)
	filling_color = "#A0522D"
	tastes = list("sweet citric" = 1)

/obj/item/reagent_containers/food/snacks/mousse
	name = "Mousse"
	desc = "An mousse made of avocado and cacao."
	icon = 'icons/hispania/obj/food/candy.dmi'
	icon_state = "mousse"
	bitesize = 1
	trash = /obj/item/trash/empty_plasticcup
	list_reagents = list("nutriment" = 1, "chocolate" = 4, "cream" = 3)
	filling_color = "#462B00"
	tastes = list("quality chocolate" = 1)

/obj/item/reagent_containers/food/snacks/mre_cracker
	name = "enriched cracker"
	desc = "It's a salted cracker, the surface looks saturated with oil."
	icon = 'icons/hispania/obj/food/candy.dmi'
	icon_state = "mre_cracker"
	bitesize = 2
	list_reagents = list("nutriment" = 0.25, "teporone" = 1, "weak_omnizine" = 1)
	tastes = list("salty" = 1, "oily" = 1)

/obj/item/reagent_containers/food/snacks/choco_mre
	name = "morale bar"
	desc = "Some brand of non-melting military chocolate with a lot of stimulants. It has a label that says \"WARNING DO NOT EAT MORE THAN ONE\"."
	icon = 'icons/hispania/obj/food/candy.dmi'
	icon_state = "mre_candy"
	list_reagents = list("sugar" = 4, "coffee" = 8, "nicotine" = 20, "epinephrine" = 12, "nutriment" = 0.25)
	var/open = FALSE
	tastes = list("chocolate" = 1, "chemical" = 1, "coffee" = 1)
	bitesize = 25

/obj/item/reagent_containers/food/snacks/choco_mre/attack_self()
	if(!open)
		open = TRUE
		to_chat(usr, "<span class='notice'>You tear \the [src] open.</span>")
		playsound(src, 'sound/items/poster_ripped.ogg', 50, 1)
		icon_state = "mre_candy_open"
		return

/obj/item/reagent_containers/food/snacks/choco_mre/attack(mob/M as mob, mob/user as mob, def_zone)
	if(!open && (M == user))
		open = TRUE
		to_chat(user,("You viciously rip \the [src] open with your teeth, swallowing some plastic in the process, you animal."))
		playsound(src, 'sound/items/poster_ripped.ogg', 50, 1)
		icon_state = "mre_candy_open"
		return
	if(!open)
		to_chat(usr, "<span class='warning'>Open \the [src] first!</span>")
		return
	else
		..()
