/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = 1
	anchored = 1
	burn_state = FLAMMABLE
	burntime = 25

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

/obj/structure/dresser/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(iswrench(W))
		if(anchored)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] is loosening [src]'s bolts.", \
								 "<span class='notice'>You are loosening [src]'s bolts...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!loc || !anchored)
					return
				user.visible_message("[user] loosened [src]'s bolts!", \
									 "<span class='notice'>You loosen [src]'s bolts!</span>")
				anchored = 0
		else
			if(!isfloorturf(loc))
				user.visible_message("<span class='warning'>A floor must be present to secure [src]!</span>")
				return
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] is securing [src]'s bolts...", \
								 "<span class='notice'>You are securing [src]'s bolts...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!loc || anchored)
					return
				user.visible_message("[user] has secured [src]'s bolts.", \
									 "<span class='notice'>You have secured [src]'s bolts.</span>")
				anchored = 1
	else
		if(iscrowbar(W) && !anchored)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] is attempting to dismantle [src].", \
								"<span class='notice'>You begin to dismantle [src]...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				new /obj/item/stack/sheet/wood (loc, 30)
				qdel(src)
