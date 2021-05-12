/obj/item/storage/toolbox/mre //godoforeos: Jason Conrad
	name = "emergency ration pack"
	desc = "Silvery plastic package, with the letters \"ERP\" pasted onto the front. Seems air tight, and vacuumed sealed. \
	The packaging holds usage information within the fineprint: \
	\"Instructions: Remove contents from packaging, open both mre container and ration can. \
	Enriched crackers and morale bar contains medicinal additives for field performace, DO NOT OVERCONSUME.\""
	icon = 'icons/hispania/obj/items.dmi'
	icon_state = "erp_closed"
	item_state = "erp"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 0
	storage_slots = 5
	hispania_icon = TRUE
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	var/openmre = FALSE

/obj/item/storage/toolbox/mre/New()
	..()
	new /obj/item/storage/toolbox/comida_mre(src)
	new /obj/item/storage/toolbox/lata_arepa(src)
	new /obj/item/storage/fancy/mre_cracker(src)
	new /obj/item/reagent_containers/food/snacks/choco_mre(src)
	new /obj/item/kitchen/utensil/fork(src)

/obj/item/storage/toolbox/mre/show_to(mob/user)
	if(!openmre)
		to_chat(user, "<span class='warning'>You tear \the [src] open.")
		icon_state = "erp_open"
		openmre = TRUE
		playsound(src, 'sound/items/poster_ripped.ogg', 50, 1)
	..()

/obj/item/storage/toolbox/lata_arepa
	name = "emergency arepa can"
	desc = "A silver can that contains a random arepa, made for special emergencies."
	icon_state = "ration_can"
	item_state = "erp"
	force = 1
	throwforce = 1
	w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 0
	storage_slots = 1
	hispania_icon = TRUE
	var/openmre = FALSE

/obj/item/storage/toolbox/lata_arepa/New()
	..()
	var/newarepa = pick(/obj/item/reagent_containers/food/snacks/arepa_ham_cheese, /obj/item/reagent_containers/food/snacks/arepa_salmon, /obj/item/reagent_containers/food/snacks/fruit_arepa, /obj/item/reagent_containers/food/snacks/cheese_arepa, /obj/item/reagent_containers/food/snacks/sweet_arepa, /obj/item/reagent_containers/food/snacks/ghost_arepa, /obj/item/reagent_containers/food/snacks/arepa_ham_cheese, /obj/item/reagent_containers/food/snacks/arepa_ham, /obj/item/reagent_containers/food/snacks/arepa_cheese)
	new newarepa(src)


/obj/item/storage/toolbox/lata_arepa/remove_from_storage(obj/item/I, atom/new_location)
	if(!openmre)
		to_chat(usr, "<span class='warning'>You open \the [src] .")
		icon_state = "ration_open"
		openmre = TRUE
	..()

/obj/item/storage/toolbox/comida_mre
	name = "emergency ration"
	desc = "A pouch that contains a random meal, made for emergencies"
	icon_state = "mre"
	item_state = "erp"
	force = 1
	throwforce = 1
	w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 0
	storage_slots = 1
	hispania_icon = TRUE
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	var/openmre = FALSE

/obj/item/storage/toolbox/comida_mre/New()
	..()
	var/newfood = pick(/obj/item/reagent_containers/food/snacks/hot_dog, /obj/item/reagent_containers/food/snacks/macacosoup, /obj/item/reagent_containers/food/snacks/avocadosandwich, /obj/item/reagent_containers/food/snacks/mushrooms_curry, /obj/item/reagent_containers/food/snacks/empanada, /obj/item/reagent_containers/food/snacks/fried_vox, /obj/item/reagent_containers/food/snacks/cheeseburger, /obj/item/reagent_containers/food/snacks/lasagna, /obj/item/reagent_containers/food/snacks/pastatomato, /obj/item/reagent_containers/food/snacks/meatsteak_cactus, /obj/item/reagent_containers/food/snacks/meatpizzaslice)
	new newfood(src)


/obj/item/storage/toolbox/comida_mre/remove_from_storage(obj/item/I, atom/new_location)
	if(!openmre)
		to_chat(usr, "<span class='warning'>You open \the [src] .")
		playsound(src, 'sound/items/poster_ripped.ogg', 50, 1)
		icon_state = "mre_open"
		openmre = TRUE
	..()
