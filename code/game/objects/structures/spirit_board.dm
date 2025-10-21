/obj/structure/spirit_board
	name = "spirit board"
	desc = "A wooden board with letters etched into it, used in seances."
	icon = 'icons/obj/objects.dmi'
	icon_state = "spirit_board"
	density = TRUE
	var/used = FALSE
	var/cooldown = 0
	var/planchette = "A"
	var/lastuser = null

/obj/structure/spirit_board/examine(mob/user)
	. = ..()
	. += "The planchette is sitting at \"[planchette]\"."

/obj/structure/spirit_board/attack_hand(mob/user as mob)
	if(..())
		return
	spirit_board_pick_letter(user)


/obj/structure/spirit_board/attack_ghost(mob/dead/observer/user as mob)
	spirit_board_pick_letter(user)


/obj/structure/spirit_board/proc/spirit_board_pick_letter(mob/M)
	if(!spirit_board_checks(M))
		return 0

	if(!used)
		used = TRUE
		notify_ghosts("Someone has begun playing with a [src.name] in [get_area(src)]!", source = src)

	planchette = input("Choose the letter.", "Seance!") in list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
	add_attack_logs(M, src, "Picked a letter on [src] which was \"[planchette]\".")
	cooldown = world.time
	lastuser = M.ckey

	var/turf/T = loc
	sleep(rand(20,30))
	if(T == loc)
		visible_message("<span class='notice'>The planchette slowly moves... and stops at the letter \"[planchette]\".</span>")


/obj/structure/spirit_board/proc/spirit_board_checks(mob/M)
	//cooldown
	var/bonus = 0
	if(M.ckey == lastuser)
		bonus = 10 //Give some other people a chance, hog.

	if(cooldown > world.time - (30 + bonus))
		return 0 //No feedback here, hiding the cooldown a little makes it harder to tell who's really picking letters.

	//lighting check
	var/light_amount = 0
	var/turf/T = get_turf(src)
	if(T)
		light_amount = T.get_lumcount(0.5) * 10
	else
		light_amount = 10

	if(light_amount > 2)
		to_chat(M, "<span class='warning'>It's too bright here to use [src.name]!</span>")
		return 0

	//mobs in range check
	var/users_in_range = 0
	for(var/mob/living/L in orange(1,src))
		if(L.ckey && L.client)
			if((world.time - L.client.inactivity) < (world.time - 300) || L.stat != CONSCIOUS || L.restrained())//no playing with braindeads or corpses or handcuffed dudes.
				to_chat(M, "<span class='warning'>[L] doesn't seem to be paying attention...</span>")
			else
				users_in_range++

	if(users_in_range < 2)
		to_chat(M, "<span class='warning'>There aren't enough people to use [src]!</span>")
		return 0

	return 1

/obj/structure/spirit_board/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 4 SECONDS)
