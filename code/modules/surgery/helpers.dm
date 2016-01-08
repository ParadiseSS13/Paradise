/proc/attempt_initiate_surgery(obj/item/I, mob/living/M, mob/user, var/override )
	world << "[istype(M)]"
	if(istype(M))
		var/mob/living/carbon/human/H
		var/obj/item/organ/external/affecting
		var/selected_zone = user.zone_sel.selecting
		if(istype(M, /mob/living/carbon/human))
			H = M
			affecting = H.get_organ(check_zone(selected_zone))

		if(can_operate(H))	//if they're prone or a slime
			var/datum/surgery/current_surgery
			world << "line 15"

			for(var/datum/surgery/S in M.surgeries)
				if(S.location == selected_zone)
					current_surgery = S

			if(!current_surgery)
				var/list/all_surgeries = surgeries_list.Copy()
				var/list/available_surgeries = list()

				for(var/datum/surgery/S in all_surgeries)
					if(!S.possible_locs.Find(selected_zone))
						continue
					if(affecting && S.requires_organic_bodypart && affecting.status == ORGAN_ROBOT)
						continue
					if(!S.can_start(user, M))
						continue

					for(var/path in S.allowed_species)
						if(istype(M, path))
							available_surgeries[S.name] = S
							break

				if(override)
					if(I == /obj/item/weapon/circular_saw)
						var/datum/surgery/S = available_surgeries["amputation"]
						if(S)//we might be targetting a zone without the named procedure.
							var/datum/surgery/procedure = new S.type
							if(procedure)
								procedure.location = selected_zone
								M.surgeries += procedure
								procedure.organ_ref = affecting
								procedure.next_step(user, M)
					else if(I == /obj/item/robot_parts)
						var/datum/surgery/S = available_surgeries["robotic limb attachment"]
						if(S)//we might be targetting a zone without the named procedure.
							var/datum/surgery/procedure = new S.type
							if(procedure)
								procedure.location = selected_zone
								M.surgeries += procedure
								procedure.organ_ref = affecting
								procedure.next_step(user, M)

				else
					var/P = input("Begin which procedure?", "Surgery", null, null) as null|anything in available_surgeries
					if(P && user && user.Adjacent(M) && (I in user))
						var/datum/surgery/S = available_surgeries[P]
						var/datum/surgery/procedure = new S.type
						if(procedure)
							procedure.location = selected_zone
							M.surgeries += procedure
							procedure.organ_ref = affecting
							user.visible_message("[user] prepares to operate on [M]'s [parse_zone(selected_zone)].", \
							"<span class='notice'>You prepare to operate on [M]'s [parse_zone(selected_zone)].</span>")

			else if(!current_surgery.step_in_progress)
				if(current_surgery.status == 1)
					M.surgeries -= current_surgery
					//need a new message
					//user.visible_message("[user] removes the drapes from [M]'s [parse_zone(selected_zone)].", \
					//	"<span class='notice'>You remove the drapes from [M]'s [parse_zone(selected_zone)].</span>")
					qdel(current_surgery)
				else if(istype(user.get_inactive_hand(), /obj/item/weapon/cautery) && current_surgery.can_cancel)
					M.surgeries -= current_surgery
					user.visible_message("[user] mends the incision on [M]'s [parse_zone(selected_zone)] with the [I] .", \
						"<span class='notice'>You mend the incision on [M]'s [parse_zone(selected_zone)].</span>")
					qdel(current_surgery)
				else if(current_surgery.can_cancel)
					user << "<span class='warning'>You need to hold a cautery in inactive hand to stop [M]'s surgery!</span>"


			return 1
	return 0



proc/get_location_modifier(mob/M)
	var/turf/T = get_turf(M)
	if(locate(/obj/machinery/optable, T))
		return 1
	else if(locate(/obj/structure/table, T))
		return 0.8
	else if(locate(/obj/structure/stool/bed, T))
		return 0.7
	else
		return 0.5


//just until i update maps....
/obj/item/organ/brain/New()
	new /obj/item/organ/internal/brain(src.loc)