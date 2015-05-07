/obj/machinery/wish_granter
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	use_power = 0
	anchored = 1
	density = 1
	var/datum/mind/target
	var/list/types = list()

/obj/machinery/wish_granter/New()
	for(var/supname in all_superheroes)
		types |= supname
	..()

/obj/machinery/wish_granter/attack_hand(var/mob/user as mob)
	usr.set_machine(src)

	if(!istype(user, /mob/living/carbon/human))
		user << "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's."
		return

	else if(is_special_character(user))
		user << "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away."

	else
		user << "The power of the Wish Granter have turned you into the superhero the station deserves. You are a masked vigilante, and answer to no man. Will you use your newfound strength to protect the innocent, or will you hunt the guilty?"


		var/wish
		if(types.len == 1)
			wish = pick(types)
		else
			wish = input("You want to become...","Wish") as null|anything in types
		if(!wish) return
		types -= wish
		var/mob/living/carbon/human/M = user
		var/datum/superheroes/S = all_superheroes[wish]
		if(S)
			S.create(M)

		//Remove the wishgranter or teleport it randomly on the station
		if(!types.len)
			user << "The wishgranter slowly fades into mist..."
			qdel(src)
			return
		else
			var/impact_area = findEventArea()
			var/turf/T = pick(get_area_turfs(impact_area))
			if(T)
				src.loc = T
	return