/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = 1
	anchored = 1

/obj/structure/dresser/attack_hand(mob/user as mob)
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user) && anchored)
		var/mob/living/carbon/human/H = user

		var/choice = input(user, "Underwear, Undershirt, or Socks?", "Changing") as null|anything in list("Underwear","Undershirt","Socks")

		if(!Adjacent(user))
			return
		switch(choice)
			if("Underwear")
				var/list/valid_underwear = list()
				for(var/underwear in GLOB.underwear_list)
					var/datum/sprite_accessory/S = GLOB.underwear_list[underwear]
					if(!(H.dna.species.name in S.species_allowed))
						continue
					valid_underwear[underwear] = GLOB.underwear_list[underwear]
				var/new_underwear = input(user, "Choose your underwear:", "Changing") as null|anything in valid_underwear
				if(new_underwear)
					H.underwear = new_underwear

			if("Undershirt")
				var/list/valid_undershirts = list()
				for(var/undershirt in GLOB.undershirt_list)
					var/datum/sprite_accessory/S = GLOB.undershirt_list[undershirt]
					if(!(H.dna.species.name in S.species_allowed))
						continue
					valid_undershirts[undershirt] = GLOB.undershirt_list[undershirt]
				var/new_undershirt = input(user, "Choose your undershirt:", "Changing") as null|anything in valid_undershirts
				if(new_undershirt)
					H.undershirt = new_undershirt

			if("Socks")
				var/list/valid_sockstyles = list()
				for(var/sockstyle in GLOB.socks_list)
					var/datum/sprite_accessory/S = GLOB.socks_list[sockstyle]
					if(!(H.dna.species.name in S.species_allowed))
						continue
					valid_sockstyles[sockstyle] = GLOB.socks_list[sockstyle]
				var/new_socks = input(user, "Choose your socks:", "Changing")  as null|anything in valid_sockstyles
				if(new_socks)
					H.socks = new_socks

		add_fingerprint(H)
		H.update_body()


/obj/structure/dresser/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE


/obj/structure/dresser/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		WRENCH_UNANCHOR_MESSAGE
		anchored = FALSE
	else
		if(!isfloorturf(loc))
			user.visible_message("<span class='warning'>A floor must be present to secure [src]!</span>")
			return
		WRENCH_ANCHOR_MESSAGE
		anchored = TRUE

/obj/structure/dresser/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/wood(drop_location(), 30)
	qdel(src)
