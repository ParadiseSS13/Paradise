/mob/living/carbon/human/interactive/away
	var/away_area = /area/awaymission   // their overriden job area
	var/override_under = null		   // optional type for uniform, else default for job
	var/squad_member = 0				// was spawned by squad
	var/home_z

/mob/living/carbon/human/interactive/away/New()
	..()
	TRAITS |= TRAIT_ROBUST
	faction += "away"

/mob/living/carbon/human/interactive/away/random()
	if(ispath(override_under, /obj/item/clothing/under))
		equip_to_slot(new override_under(src), slot_w_uniform)
	..()

/mob/living/carbon/human/interactive/away/doSetup()
	..()
	var/datum/data/pda/app/messenger/M = MYPDA.find_program(/datum/data/pda/app/messenger)
	M.toff = 1
	var/datum/data/pda/app/chatroom/C = MYPDA.find_program(/datum/data/pda/app/chatroom)
	C.toff = 1

/mob/living/carbon/human/interactive/away/job2area()
	return away_area

/mob/living/carbon/human/interactive/away/doProcess()
	if(!home_z)
		home_z = get_turf(z)
	if(home_z != get_turf(z))
		gib()
	..()

/obj/effect/spawner/snpc_squad
	name = "squad spawner"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	density = 0
	opacity = 0
	invisibility = 101
	var/squad_type = /mob/living/carbon/human/interactive/away
	var/squad_size = 3

	var/global/list/squads[0]
	var/list/squad

/obj/effect/spawner/snpc_squad/New()
	processing_objects += src

	squad = squads[squad_type]
	if(!squad)
		squad = list()
		squads[squad_type] = squad
	squad += src

/obj/effect/spawner/snpc_squad/Destroy()
	squad = null
	processing_objects -= src
	return ..()

/obj/effect/spawner/snpc_squad/process()
	// check squad memebers
	var/living = 0
	for(var/mob/living/carbon/human/interactive/away/A in squad)
		if(!A.stat)
			living++
		else
			// see if anyone's looking, if not, despawn
			var/can_despawn = 1
			for(var/mob/living/M in viewers(A, world.view + 1))
				if(M.client)
					living++	// dead guy that can be seen still takes up a slot
					can_despawn = 0
					break
			if(can_despawn)
				squad -= A
				qdel(A)

	// spawn new ones
	if(living < squad_size && !length(viewers(src, world.view)))
		var/mob/living/carbon/human/interactive/away/A = new squad_type(loc)
		squad += A
		A.squad_member = 1