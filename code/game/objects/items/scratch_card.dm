/obj/item/scratch
	name = "scratch card"
	desc = "Scratch this with a card or coin to discover if you are the winner!"
	icon = 'icons/obj/economy.dmi'
	icon_state = "scard"
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE
	/// Has this been scratched yet?
	var/scratched = FALSE
	/// The prob chance for it to be the winner card
	var/winning_chance = 1
	/// Is this the winner card?
	var/winner = FALSE

/obj/item/scratch/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ..()
	if(scratched)
		return

	if(!(istype(used, /obj/item/card) || istype(used, /obj/item/coin))) // We scratch with cards or coins!
		return

	if(prob(winning_chance))
		to_chat(user, "<span class='notice'>Congratulations! Redeem your prize at the nearest ATM!</span>")
		icon_state = "scard_winner"
		winner = TRUE
	else
		to_chat(user, "Good luck next time.")
		icon_state = "scard_loser"
	playsound(user, 'sound/items/scratching.ogg', 25, TRUE)
	scratched = TRUE
	update_icon(UPDATE_ICON_STATE)
	return ITEM_INTERACT_COMPLETE

/obj/item/scratch/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!winner || !istype(target, /obj/machinery/economy/atm))
		return ..()
	
	playsound(user, 'sound/machines/ping.ogg', 50, TRUE)
	target.atom_say("Congratulations for winning the lottery!")
	var/obj/item/reward = new /obj/item/stack/spacecash/c1000
	qdel(src)
	user.put_in_hands(reward)
	return ITEM_INTERACT_COMPLETE

/obj/item/storage/box/scratch_cards
	name = "scratch cards box"
	desc = "Try your luck with five scratch cards!"
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(/obj/item/scratch)

/obj/item/storage/box/scratch_cards/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/scratch(src)
