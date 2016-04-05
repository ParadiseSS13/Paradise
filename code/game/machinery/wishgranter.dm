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
	var/inuse = 0

/obj/machinery/wish_granter/New()
	for(var/supname in all_superheroes)
		types |= supname
	..()

/obj/machinery/wish_granter/attack_hand(var/mob/user as mob)
	usr.set_machine(src)

	if(!istype(user, /mob/living/carbon/human))
		to_chat(user, "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's.")
		return

	if(is_special_character(user))
		to_chat(user, "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away.")
		return

	if(inuse)
		to_chat(user, "Someone is already communing with the Wish Granter.")
		return

	to_chat(user, "The power of the Wish Granter have turned you into the superhero the station deserves. You are a masked vigilante, and answer to no man. Will you use your newfound strength to protect the innocent, or will you hunt the guilty?")

	inuse = 1
	var/wish
	if(types.len == 1)
		wish = pick(types)
	else
		wish = input("You want to become...","Wish") as null|anything in types
	if(!wish)
		inuse=0
		return
	types -= wish
	var/mob/living/carbon/human/M = user
	var/datum/superheroes/S = all_superheroes[wish]
	if(S)
		S.create(M)
	inuse=0

	//Remove the wishgranter or teleport it randomly on the station
	if(!types.len)
		to_chat(user, "The wishgranter slowly fades into mist...")
		qdel(src)
		return
	else
		var/impact_area = findEventArea()
		var/turf/T = pick(get_area_turfs(impact_area))
		if(T)
			src.loc = T
	return