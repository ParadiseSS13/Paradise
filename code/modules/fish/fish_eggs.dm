
/obj/item/fish_eggs
	name = "fish eggs"
	desc = "Eggs laid by a fish. This cluster seems... empty?"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "eggs"
	w_class = WEIGHT_CLASS_SMALL
	var/datum/fish/fish_type = null			//Holds the datum of the fish that the egg is for, null means dud eggs

/obj/item/fish_eggs/goldfish
	name = "goldfish eggs"
	desc = "Goldfish eggs, surprisingly, don't contain actual gold."
	icon_state = "gold_eggs"
	fish_type = /datum/fish/goldfish

/obj/item/fish_eggs/clownfish
	name = "clownfish eggs"
	desc = "Even as eggs, they are funnier than the clown. HONK!"
	icon_state = "clown_eggs"
	fish_type = /datum/fish/clownfish

/obj/item/fish_eggs/shark
	name = "shark eggs"
	desc = "We're gonna need a- Oh wait, they're still eggs."
	icon_state = "shark_eggs"
	fish_type = /datum/fish/shark

/obj/item/fish_eggs/babycarp
	name = "baby space carp eggs"
	desc = "Eggs from the substantially smaller form of the intergalactic terror."
	icon_state = "babycarp_eggs"
	fish_type = /datum/fish/babycarp

/obj/item/fish_eggs/catfish
	name = "catfish eggs"
	desc = "A bottom-feeding species noted for their similarity to cats and Tajaran."
	icon_state = "catfish_eggs"
	fish_type = /datum/fish/catfish

/obj/item/fish_eggs/feederfish
	name = "feeder fish eggs"
	desc = "These generic fish are commonly found being eaten by larger fish."
	icon_state = "feederfish_eggs"
	fish_type = /datum/fish/feederfish

/obj/item/fish_eggs/salmon
	name = "salmon eggs"
	desc = "A collection of salmon eggs."
	icon_state = "salmon_eggs"
	fish_type = /datum/fish/salmon

/obj/item/fish_eggs/shrimp
	name = "shrimp eggs"
	desc = "Eggs for shrimp. You figured they'd be smaller though..."
	icon_state = "shrimp_eggs"
	fish_type = /datum/fish/shrimp

/obj/item/fish_eggs/electric_eel
	name = "electric eel eggs"
	desc = "A pile of eggs for a slimy, shocking, sea-serpent."
	icon_state = "electric_eel_eggs"
	fish_type = /datum/fish/electric_eel

/obj/item/fish_eggs/glofish
	name = "glofish eggs"
	desc = "A cluster of bright neon eggs belonging to a bio-luminescent species of fish."
	icon_state = "glofish_eggs"
	fish_type = /datum/fish/glofish
