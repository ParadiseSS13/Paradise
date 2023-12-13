/obj/item/book/granter/spell/summon_cheese
	name = "Lusty Xenomorph Maid vol. III - Cheese Bakery"
	desc = "Wonderful! Time for a celebration... Cheese for everyone!"
	icon_state = "cheese_book"
	spell_name = "summon cheese"
	granted_spell = /obj/effect/proc_holder/spell/aoe/conjure/summon_cheese
	remarks = list(
		"Always forward, never back...",
		"Are these pages... cheese slices?..",
		"Healthy snacks for unsuspecting victims...",
		"I never knew so many types of cheese existed...",
		"Madness reeks of goat cheese...",
		"Was it order or biscuits?..",
		"Who wouldn't like that?..",
		"Why cheese, of all things?..",
		"Why do I need a reason for everything?..",
		"Cheddar days are coming...",
		"Leicester the Red's gouda guide to getting feta at Caseiculture...",
		"A passage from Cheesus Christ, the gouda saint...",
		"What is the cheese tax and how do I pay it?!..."
	)

/obj/item/book/granter/spell/summon_cheese/recoil(mob/living/user)
	to_chat(user, "<span class='warning'>[src] turns into a wedge of cheese!</span>")
	var/obj/item/reagent_containers/food/snacks/cheesewedge/presliced/book_cheese = new
	user.drop_item()
	user.put_in_hands(book_cheese)
	qdel(src)

/obj/effect/proc_holder/spell/aoe/conjure/summon_cheese
	name = "Summon Cheese"
	desc = "Summon cheesy goodness around you!"
	base_cooldown = 1 MINUTES
	clothes_req = FALSE
	overlay = null
	action_icon_state = "cheese_wedge"
	action_background_icon_state = "bg_spell"
	summon_type = list(/obj/item/reagent_containers/food/snacks/cheesewedge/presliced)
	summon_amt = 9
	aoe_range = 1
	summon_ignore_prev_spawn_points = TRUE
