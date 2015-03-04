/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = 1
	anchored = 1

/obj/structure/dresser/proc/convUnM(mund)
	return underwear_m.Find(mund)

/obj/structure/dresser/proc/convUnF(fund)
	return underwear_f.Find(fund)

/obj/structure/dresser/proc/convUs(us)
	return undershirt_list.Find(us)

/obj/structure/dresser/attack_hand(mob/user as mob)
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		var/choice = input(user, "Underwear, or Undershirt?", "Changing") as null|anything in list("Underwear","Undershirt")

		if(!Adjacent(user))
			return
		switch(choice)
			if("Underwear")
				if(H.gender == FEMALE)
					var/new_undies = input(user, "Select your underwear", "Changing")  as null|anything in underwear_f
					if(new_undies)
						H << "\red You selected [new_undies]."
						var/freturn = convUnF(new_undies)
						H.underwear = freturn

				else
					var/new_undies = input(user, "Select your underwear", "Changing")  as null|anything in underwear_m
					if(new_undies)
						H << "\red You selected [new_undies]."
						var/mreturn = convUnM(new_undies)
						H.underwear = mreturn

			if("Undershirt")
				var/new_undershirt = input(user, "Select your undershirt", "Changing") as null|anything in undershirt_list
				if(new_undershirt)
					H << "\red You selected [new_undershirt]"
					var/usreturn = convUs(new_undershirt)
					H.undershirt = usreturn

		add_fingerprint(H)
		H.update_body()