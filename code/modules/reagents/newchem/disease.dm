/datum/reagent/spider_eggs
	name = "spider eggs"
	id = "spidereggs"
	description = "A fine dust containing spider eggs. Oh gosh."
	reagent_state = SOLID
	color = "#FFFFFF"

/datum/reagent/spider_eggs/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(volume > 2.5)
		if(iscarbon(M))
			if(!M.get_int_organ(/obj/item/organ/internal/body_egg))
				new/obj/item/organ/internal/body_egg/spider_eggs(M) //Yes, even Xenos can fall victim to the plague that is spider infestation.
	..()