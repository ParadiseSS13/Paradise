
var/global/list/fish_items_list = list("goldfish" = /obj/item/weapon/fish/goldfish,
									"clownfish" = /obj/item/weapon/bananapeel/clownfish,
									"shark" = /obj/item/weapon/fish/shark,
									"baby space carp" = /obj/item/weapon/fish/babycarp,
									"catfish" = /obj/item/weapon/fish/catfish,
									"feederfish" = /obj/item/weapon/reagent_containers/food/snacks/feederfish,
									"salmon" = /obj/item/weapon/fish/salmon,
									"shrimp" = /obj/item/weapon/reagent_containers/food/snacks/shrimp,
									"electric eel" = /obj/item/weapon/fish/electric_eel,
									"glofish" = /obj/item/weapon/fish/glofish
,
									)

//////////////////////////////////////////////
//			Aquarium Supplies				//
//////////////////////////////////////////////

/obj/item/weapon/egg_scoop
	name = "fish egg scoop"
	desc = "A small scoop to collect fish eggs with."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "egg_scoop"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2
	throw_speed = 3
	throw_range = 7

/obj/item/weapon/fish_net
	name = "fish net"
	desc = "A tiny net to capture fish with. It's a death sentence!"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "net"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2
	throw_speed = 3
	throw_range = 7

	suicide_act(mob/user)			//"A tiny net is a death sentence: it's a net and it's tiny!" https://www.youtube.com/watch?v=FCI9Y4VGCVw
		to_chat(viewers(user), "<span class='warning'>[user] places the [src.name] on top of \his head, \his fingers tangled in the netting! It looks like \he's trying to commit suicide.</span>")
		return(OXYLOSS)

/obj/item/weapon/fishfood
	name = "fish food can"
	desc = "A small can of Carp's Choice brand fish flakes. The label shows a smiling Space Carp."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "fish_food"
	throwforce = 1
	w_class = 2
	throw_speed = 3
	throw_range = 7

/obj/item/weapon/tank_brush
	name = "aquarium brush"
	desc = "A brush for cleaning the inside of aquariums. Contains a built-in odor neutralizer."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "brush"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2
	throw_speed = 3
	throw_range = 7
	attack_verb = list("scrubbed", "brushed", "scraped")

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='warning'>[user] is vigorously scrubbing \himself raw with the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return(BRUTELOSS|FIRELOSS)

//////////////////////////////////////////////
//				Fish Items					//
//////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/shrimp
	name = "shrimp"
	desc = "A single raw shrimp."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_raw"
	filling_color = "#FF1C1C"

	New()
		..()
		desc = pick("Anyway, like I was sayin', shrimp is the fruit of the sea.", "You can barbecue it, boil it, broil it, bake it, saute it.")
		reagents.add_reagent("protein", 1)
		src.bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/feederfish
	name = "feeder fish"
	desc = "A tiny feeder fish. Sure doesn't look very filling..."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "feederfish"
	filling_color = "#FF1C1C"

	New()
		..()
		reagents.add_reagent("protein", 1)
		src.bitesize = 1

/obj/item/weapon/fish
	name = "fish"
	desc = "A generic fish"
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "fish"
	throwforce = 1
	w_class = 2
	throw_speed = 3
	throw_range = 7
	force = 1
	attack_verb = list("slapped", "humiliated", "hit", "rubbed")
	hitsound = 'sound/effects/snap.ogg'

/obj/item/weapon/fish/glofish
	name = "glofish"
	desc = "A small bio-luminescent fish. Not very bright, but at least it's pretty!"
	icon_state = "glofish"

/obj/item/weapon/fish/glofish/New()
		..()
		set_light(2,1,"#99FF66")

/obj/item/weapon/fish/electric_eel
	name = "electric eel"
	desc = "An eel capable of producing a mild electric shock. Luckily it's rather weak out of water."
	icon_state = "electric_eel"

/obj/item/weapon/fish/shark
	name = "shark"
	desc = "Warning: Keep away from tornadoes."
	icon_state = "shark"
	hitsound = 'sound/weapons/bite.ogg'
	force = 3

/obj/item/weapon/fish/shark/attackby(var/obj/item/O, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/wirecutters))
		to_chat(user, "You rip out the teeth of \the [src.name]!")
		new /obj/item/weapon/fish/toothless_shark(get_turf(src))
		new /obj/item/weapon/shard/shark_teeth(get_turf(src))
		qdel(src)
		return
	..()

/obj/item/weapon/fish/toothless_shark
	name = "toothless shark"
	desc = "Looks like someone ripped it's teeth out!"
	icon_state = "shark"
	hitsound = 'sound/effects/snap.ogg'

/obj/item/weapon/shard/shark_teeth
	name = "shark teeth"
	desc = "A number of teeth, supposedly from a shark."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "teeth"
	force = 2.0
	throwforce = 5.0
	materials = list()

/obj/item/weapon/shard/shark_teeth/New()
	src.pixel_x = rand(-5,5)
	src.pixel_y = rand(-5,5)

/obj/item/weapon/fish/catfish
	name = "catfish"
	desc = "Apparently, catfish don't purr like you might have expected them to. Such a confusing name!"
	icon_state = "catfish"

/obj/item/weapon/fish/catfish/attackby(var/obj/item/O, var/mob/user as mob)
	if(is_sharp(O))
		to_chat(user, "You carefully clean and gut \the [src.name].")
		new /obj/item/weapon/reagent_containers/food/snacks/catfishmeat(get_turf(src))
		new /obj/item/weapon/reagent_containers/food/snacks/catfishmeat(get_turf(src))
		qdel(src)
		return
	..()

/obj/item/weapon/fish/goldfish
	name = "goldfish"
	desc = "A goldfish, just like the one you never won at the county fair."
	icon_state = "goldfish"

/obj/item/weapon/fish/salmon
	name = "salmon"
	desc = "The second-favorite food of Space Bears, right behind crew members."
	icon_state = "salmon"

/obj/item/weapon/fish/salmon/attackby(var/obj/item/O, var/mob/user as mob)
	if(is_sharp(O))
		to_chat(user, "You carefully clean and gut \the [src.name].")
		new /obj/item/weapon/reagent_containers/food/snacks/salmonmeat(get_turf(src))
		new /obj/item/weapon/reagent_containers/food/snacks/salmonmeat(get_turf(src))
		qdel(src)
		return
	..()

/obj/item/weapon/fish/babycarp
	name = "baby space carp"
	desc = "Substantially smaller than the space carp lurking outside the hull, but still unsettling."
	icon_state = "babycarp"
	hitsound = 'sound/weapons/bite.ogg'
	force = 3

/obj/item/weapon/fish/babycarp/attackby(var/obj/item/O, var/mob/user as mob)
	if(is_sharp(O))
		to_chat(user, "You carefully clean and gut \the [src.name].")
		new /obj/item/weapon/reagent_containers/food/snacks/carpmeat(get_turf(src)) //just one fillet; this is a baby, afterall.
		qdel(src)
		return
	..()


/obj/item/weapon/bananapeel/clownfish
	name = "clown fish"
	desc = "Even underwater, you cannot escape HONKing."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "clownfish"
	throwforce = 1
	force = 1
	attack_verb = list("slapped", "humiliated", "hit", "rubbed")
