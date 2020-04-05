/obj/structure/closet/crate/necropolis/bubblegum
	name = "bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/New()
	..()
	new /obj/item/clothing/suit/space/hostile_environment(src)
	new /obj/item/clothing/head/helmet/space/hostile_environment(src)
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/mayhem(src)
		if(2)
			new /obj/item/blood_contract(src)
		if(3)
			new /obj/item/gun/magic/staff/spellblade(src)

/obj/structure/closet/crate/necropolis/bubblegum/crusher
	name = "bloody bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/crusher/New()
	..()
	new /obj/item/crusher_trophy/demon_claws(src)

// Mayhem

/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "A magically infused bottle of blood, the scent of which will drive anyone nearby into a murderous frenzy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/mayhem/attack_self(mob/user)
	for(var/mob/living/carbon/human/H in range(7,user))
		spawn()
			var/obj/effect/mine/pickup/bloodbath/B = new(H)
			B.mineEffect(H)
	to_chat(user, "<span class='notice'>You shatter the bottle!</span>")
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
	qdel(src)

// Blood Contract

/obj/item/blood_contract
	name = "blood contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	color = "#FF0000"
	desc = "Mark your target for death."
	var/used = FALSE

/obj/item/blood_contract/attack_self(mob/user)
	if(used)
		return

	used = TRUE
	var/choice = input(user,"Who do you want dead?","Choose Your Victim") as null|anything in GLOB.player_list

	if(!choice)
		used = FALSE
		return
	else if(!isliving(choice))
		to_chat(user, "[choice] is already dead!")
		used = FALSE
		return
	else if(choice == user)
		to_chat(user, "You feel like writing your own name into a cursed death warrant would be unwise.")
		used = FALSE
		return
	else
		var/mob/living/L = choice

		message_admins("[key_name_admin(L)] has been marked for death by [key_name_admin(user)].")
		log_admin("[key_name(L)] has been marked for death by [key_name(user)].")

		var/datum/objective/survive/survive = new
		survive.owner = L.mind
		L.mind.objectives += survive
		to_chat(L, "<span class='userdanger'>You've been marked for death! Don't let the demons get you!</span>")
		L.color = "#FF0000"
		spawn()
			var/obj/effect/mine/pickup/bloodbath/B = new(L)
			B.mineEffect(L)

		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H == L)
				continue
			to_chat(H, "<span class='userdanger'>You have an overwhelming desire to kill [L]. [L.p_they(TRUE)] [L.p_have()] been marked red! Go kill [L.p_them()]!</span>")
			H.put_in_hands(new /obj/item/kitchen/knife/butcher(H))

	qdel(src)
