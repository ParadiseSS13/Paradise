/obj/item/udder
	name = "udder"

/obj/item/udder/Initialize(mapload)
	. = ..()
	create_reagents(50)

/obj/item/udder/proc/generateMilk()
	if(prob(5))
		reagents.add_reagent("milk", rand(5, 10))

/obj/item/udder/proc/milkAnimal(obj/O, mob/user)
	var/obj/item/reagent_containers/glass/G = O
	if(G.reagents.total_volume >= G.volume)
		to_chat(user, "<span class='danger'>[O] is full.</span>")
		return
	var/transfered = reagents.trans_to(O, rand(5,10))
	if(transfered)
		user.visible_message("[user] milks [src] using \the [O].", "<span class='notice'>You milk [src] using \the [O].</span>")
	else
		to_chat(user, "<span class='danger'>The udder is dry. Wait a bit longer...</span>")

/obj/item/udder/cow

/obj/item/udder/cow/Initialize(mapload)
	. = ..()
	reagents.add_reagent("milk", 20)
