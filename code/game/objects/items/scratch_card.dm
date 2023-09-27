/obj/item/scratch
	name = "scratch card"
	desc = "Scratch this with a card or coin to discover if you are the winner!"
	icon = 'icons/obj/economy.dmi'
	icon_state = "scard"
	w_class = WEIGHT_CLASS_TINY
	/// Has this been scratched yet?
	var/scratched = FALSE
	/// The prob chance for it to be the winner card
	var/winning_chance = 0.1
	/// Is this the winner card?
	var/winner = FALSE

/obj/item/scratch/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(scratched)
		return
	if(istype(I, /obj/item/card) || istype(I, /obj/item/coin))
		if(prob(winning_chance))
			desc = "Congratulations! Redeem your prize at the nearest ATM!"
			icon_state = "scard_winner"
			winner = TRUE
		else
			desc = "Good luck next time."
			icon_state = "scard_loser"
		playsound(user, 'sound/items/scratching.ogg', 50, TRUE)
		scratched = TRUE
		update_icon_state()

/obj/item/scratch/attack_obj(obj/O, mob/living/user, params)
	if(winner && istype(O, /obj/machinery/economy/atm))
		playsound(user, 'sound/machines/ping.ogg', 50, TRUE)
		O.atom_say("Congratulations for winning the lottery!")
		var/obj/item/reward = new /obj/item/stack/spacecash/c1000
		user.put_in_hands(reward)
		qdel(src)
		return
	..()

/obj/item/storage/box/scratch_cards
	name = "scratch cards box"
	desc = "Try your luck with five scratch cards!"
	can_hold = list(/obj/item/scratch)

/obj/item/storage/box/scratch_cards/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/scratch(src)
