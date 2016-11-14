/datum/food_processor_process/mob/cat
	input = /mob/living/simple_animal/pet/cat
	output = null

/datum/food_processor_process/mob/cat/process_food(loc, what, processor)
	var/mob/living/simple_animal/pet/cat/C = what
	if(C.client)
		C.loc = loc
		C.visible_message("<span class='notice'>[C] with a loud meowing jumped out of the processor!</span>")
		return
	var/obj/item/weapon/reagent_containers/food/snacks/catbread/Podumoi = new(loc) //snack!
	var/datum/reagent/psilocybin/Neesh = new() //snack
	Neesh.holder = Podumoi // catbread
	Neesh.volume = 10 //Podumoi
	Podumoi.reagents.reagent_list += Neesh
	..()
