/obj/item/flag/nation
	density = 1
	anchored = 1
	var/turf/startloc = null
	var/captured = 0
	var/list/vassals = list()
	var/datum/nations/liege = null
	var/datum/nations/nation = null

/obj/item/flag/nation/New()
	..()
	flag_list += src

/obj/item/flag/nation/fire_act()
	return

/obj/item/flag/nation/Ignite()
	return

/obj/item/flag/nation/light()
	return

/obj/item/flag/nation/attackby(var/obj/item/weapon/W, var/mob/user)
	return

/obj/item/flag/nation/attack_paw()
	return

/obj/item/flag/nation/ex_act()
	return

/obj/item/flag/nation/blob_act()
	return


/obj/item/flag/nation/attack_hand(mob/user as mob)
	if(user.mind)
		if(user.mind.nation)
			var/obj/item/flag/nation/F = locate(user.mind.nation.flagpath)
			if(istype(user.mind.nation,nation)) //Same team as flag
				if(liege && liege == F.liege)
					user << "<span class='warning'>You can't steal your liege's flags!</span>"
					return
				else if(loc != startloc)
					loc = startloc
					user.visible_message("[user] sends [src] back to base!", "You return [src] to your base!")
					return
				else
					user << "<span class='warning'>You can't move your flag from it's home location!</span>"
					return
			else
				if(captured && Adjacent(F.startloc))
					user << "<span class='warning'>This flag has already been captured by your team!</span>"
					return
				else if(..())
					captured = 0
					anchored = 0
					var/obj/item/flag/nation/N = null
					if(liege)
						N = locate(liege.flagpath)
					for(var/mob/living/carbon/human/H in player_list)
						if(H.mind && H.mind.nation && liege && nation)
							if(H.mind.nation.name == liege.name)	//we have to check based on the name var since they will be different instances of the nation datum
								H.mind.current << "<span class='warning'>You are no longer the liege of [nation]!</span>"
							if(H.mind.nation.name == nation.name)
								H.mind.current << "<span class='warning'>You are no longer vassals of [liege]!</span>"
					if(N)
						N.vassals -= nation
					liege = null
		else
			user << "<span class='warning'>You are not part of a nation and therefore cannot pick up any flags!</span>"
			return
	return

/obj/item/flag/nation/dropped(mob/user as mob)
	..()
	spawn(20)
		anchored = 1
		var/obj/item/flag/nation/F = locate(user.mind.nation.flagpath)
		if(F.loc != F.startloc) return
		for(var/obj/item/flag/nation/S in orange(1,F.startloc))
			if(S == src)
				captured = 1
				liege = F.nation
				F.vassals += nation
				//Announce capture/vassalage here.
				for(var/mob/living/carbon/human/H in player_list)
					if(H.mind && H.mind.nation && F.nation && nation)
						if(H.mind.nation.name == F.nation.name)
							H.mind.current << "<span class='warning'>You have just vassalized [nation]! They must now obey any members of your nation!</span>"
							continue
						if(H.mind.nation.name == nation.name)
							H.mind.current << "<span class='warning'>You are now vassals of [liege]! You must now obey the orders of any of their members!</span>"
							continue
				//Check for Victory
				for(var/obj/item/flag/nation/N in flag_list)
					if(F.nation && N.nation)
						if(F.nation.name == N.nation.name)
							continue
					if(N.liege && F.nation)
						if(N.captured && N.liege.name == F.nation.name)
							continue
					else
						return
				ticker.mode.declare_completion(F.nation)



//Nations/Department flags --Nations Gamemode Specific
/obj/item/flag/nation/cargo
	name = "Cargonia flag"
	desc = "The flag of the independent, sovereign nation of Cargonia."
	icon_state = "cargoflag"
	nation = new /datum/nations/cargonia

/obj/item/flag/nation/med
	name = "Medistan flag"
	desc = "The flag of the independent, sovereign nation of Medistan."
	icon_state = "medflag"
	nation = new /datum/nations/medistan

/obj/item/flag/nation/sec
	name = "Brigston flag"
	desc = "The flag of the independent, sovereign nation of Brigston."
	icon_state = "secflag"
	nation = new /datum/nations/brigston

/obj/item/flag/nation/rnd
	name = "Scientopia flag"
	desc = "The flag of the independent, sovereign nation of Scientopia."
	icon_state = "rndflag"
	nation = new /datum/nations/scientopia

/obj/item/flag/nation/atmos
	name = "Atmosia flag"
	desc = "The flag of the independent, sovereign nation of Atmosia."
	icon_state = "atmosflag"
	nation = new /datum/nations/atmosia

/obj/item/flag/nation/command
	name = "People's Republic of Commandzakstan flag"
	desc = "The flag of the independent, sovereign nation of the People's Republic of Commandzakstan."
	icon_state = "ntflag"
	nation = new /datum/nations/command