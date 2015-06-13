
/obj/item/fish_eggs
	name = "fish eggs"
	desc = "Eggs laid by a fish. This cluster seems... empty?"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "eggs"
	w_class = 2.0
	var/fish_type = null			//Holds the name of the fish that the egg is for

/obj/item/fish_eggs/New()
	..()

var/global/list/fish_eggs_list = list("dud" = /obj/item/fish_eggs,
									"goldfish" = /obj/item/fish_eggs/goldfish,
									"clownfish" = /obj/item/fish_eggs/clownfish,
									"shark" = /obj/item/fish_eggs/shark,
									"babycarp" = /obj/item/fish_eggs/babycarp,
									)

/obj/item/fish_eggs/goldfish
	name = "goldfish eggs"
	desc = "Goldfish eggs, surprisingly, don't contain actual gold."
	icon_state = "gold_eggs"
	fish_type = "goldfish"

/obj/item/fish_eggs/clownfish
	name = "clownfish eggs"
	desc = "Even as eggs, they are funnier than the clown. HONK!"
	icon_state = "clown_eggs"
	fish_type = "clownfish"

/obj/item/fish_eggs/shark
	name = "shark eggs"
	desc = "We're gonna need a- Oh wait, they're still eggs."
	icon_state = "shark_eggs"
	fish_type = "shark"

/obj/item/fish_eggs/babycarp
	name = "baby space carp eggs"
	desc = "Eggs from the substantially smaller form of the intergalactic terror."
	icon_state = "babycarp_eggs"
	fish_type = "babycarp"
