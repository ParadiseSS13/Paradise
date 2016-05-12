
/obj/item/weapon/bee_briefcase
	name = "briefcase"
	desc = "This briefcase has easy-release clasps and smells vaguely of honey and blood..."
	icon = 'icons/obj/storage.dmi'
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = CONDUCT
	hitsound = "swing_hit"
	force = 10
	throw_speed = 2
	throw_range = 4
	w_class = 4
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	var/bees_left = 10
	var/list/blood_list = list()
	var/sound_file = 'sound/misc/briefcase_bees.ogg'
	var/next_sound = 0

/obj/item/weapon/bee_briefcase/examine(mob/user)
	..()
	if(loc == user)
		if(bees_left)
			to_chat(user, "<span class='warning'>There are [bees_left] bees still inside in briefcase!</span>")
		else
			to_chat(user, "<span class='danger'>The bees are gone... Colony collapse disorder?</span>")

/obj/item/weapon/bee_briefcase/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))

		var/obj/item/weapon/reagent_containers/syringe/S = I
		if(!bees_left)
			to_chat(user, "<span class='warning'>The briefcase is empty, so there is no point in injecting something into it.</span>")
			return
		if(S.reagents && S.reagents.total_volume)
			to_chat(user, "<span class='notice'>You inject [src] with [S].</span>")
			for(var/datum/reagent/A in S.reagents.reagent_list)
				if(A.id == "blood")
					if(!(A.data["donor"] in blood_list))
						blood_list += A.data["donor"]
				if(A.id == "strange_reagent")		//RELOAD THE BEES (1 bee per 1 unit, max 15 bees)
					if(bees_left < 15)
						bees_left = min(15, round((bees_left + A.volume), 1))	//No partial bees, max 15 bees in case at any given time
						to_chat(user, "<span class='warning'>The buzzing inside the briefcase intensifies as new bees form inside.</span>")
					else
						to_chat(user, "<span class='warning'>The buzzing inside the briefcase swells momentarily, then returns to normal. Guess it was too cramped...</span>")
				S.reagents.clear_reagents()
				S.update_icon()

	else if(istype(I, /obj/item/weapon/plantspray))
		var/obj/item/weapon/plantspray/PS = I
		user.drop_item(PS)
		bees_left = max(0, (bees_left - PS.pest_kill_str))
		to_chat(user, "You spray [PS] into \the [src].")
		playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
		qdel(PS)

/obj/item/weapon/bee_briefcase/attack_self(mob/user as mob)
	if(!bees_left)
		to_chat(user, "<span class='danger'>The lack of all and any bees at this event has been somewhat of a let-down...</span>")
		return
	else
		if(world.time >= next_sound)		//This cooldown doesn't prevent us from releasing bees, just stops the sound
			next_sound = world.time + 90
			//Play sound through the station intercomms, so everyone knows the doom you have wrought.
			for(var/O in global_intercoms)
				var/obj/item/device/radio/intercom/I = O
				if(I.z != ZLEVEL_STATION)	//Only broadcast to the station intercoms
					continue
				if(!I.on)					//Only broadcast to active intercoms (powered, switched on)
					continue
				playsound(I, sound_file, 35)

		//Release up to 5 bees per use. Without using strange reagent, that means two uses. WITH strange reagent, you can get more if you don't release the last bee
		for(var/bee = min(5, bees_left), bee > 0, bee--)
			var/mob/living/simple_animal/hostile/poison/bees/syndi/B = new /mob/living/simple_animal/hostile/poison/bees/syndi(null)
			B.master_and_friends = blood_list	//Doesn't automatically add the person who opens the case, so the bees will attack the user unless they gave their blood
			B.forceMove(get_turf(user))			//RELEASE THE BEES!
		bees_left -= 5