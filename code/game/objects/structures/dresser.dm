/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = TRUE
	anchored = TRUE

/obj/structure/dresser/attack_hand(mob/user as mob)
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user) && anchored)
		var/mob/living/carbon/human/H = user

		var/choice = tgui_input_list(user, "Underwear, Undershirt, or Socks?", "Changing", list("Underwear","Undershirt","Socks"))

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
				var/new_underwear = tgui_input_list(user, "Choose your underwear:", "Changing", valid_underwear)
				if(new_underwear)
					H.underwear = new_underwear

			if("Undershirt")
				var/list/valid_undershirts = list()
				for(var/undershirt in GLOB.undershirt_list)
					var/datum/sprite_accessory/S = GLOB.undershirt_list[undershirt]
					if(!(H.dna.species.name in S.species_allowed))
						continue
					valid_undershirts[undershirt] = GLOB.undershirt_list[undershirt]
				var/new_undershirt = tgui_input_list(user, "Choose your undershirt:", "Changing", valid_undershirts)
				if(new_undershirt)
					H.undershirt = new_undershirt

			if("Socks")
				var/list/valid_sockstyles = list()
				for(var/sockstyle in GLOB.socks_list)
					var/datum/sprite_accessory/S = GLOB.socks_list[sockstyle]
					if(!(H.dna.species.name in S.species_allowed))
						continue
					valid_sockstyles[sockstyle] = GLOB.socks_list[sockstyle]
				var/new_socks = tgui_input_list(user, "Choose your socks:", "Changing", valid_sockstyles)
				if(new_socks)
					H.socks = new_socks

		add_fingerprint(H)
		H.update_body()


/obj/structure/dresser/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/dresser/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 20)

/obj/structure/dresser/deconstruct(disassembled = FALSE)
	var/mat_drop = 15
	if(disassembled)
		mat_drop = 30
	new /obj/item/stack/sheet/wood(drop_location(), mat_drop)
	..()
