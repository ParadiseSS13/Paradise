/obj/item/stack
	is_examine_bites = FALSE
	integrity_bite = 1 // stack sheet now
	nutritional_value = 5

/obj/item/stack/item_bite(mob/living/carbon/target, mob/user)
	amount -= integrity_bite
	if(amount <= 0)
		to_chat(user, "<span class='notice'>[target == user ? "Вы доели" : "[target] доел"] [src.name].</span>")
		qdel(src)
