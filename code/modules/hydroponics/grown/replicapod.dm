// A very special plant, deserving it's own file.

/obj/item/seeds/replicapod
	name = "pack of replica pod seeds"
	desc = "These seeds grow into replica pods. They say these are used to harvest humans."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Replica Pod"
	product = /mob/living/carbon/human/diona //verrry special -- Urist
	lifespan = 50
	endurance = 8
	maturation = 10
	production = 1
	yield = 1 //seeds if there isn't a dna inside
	potency = 30
	var/ckey = null
	var/realName = null
	var/datum/mind/mind = null
	var/blood_gender = null
	var/blood_type = null
	var/factions = null
	var/contains_sample = 0

/obj/item/seeds/replicapod/Destroy()
	mind = null
	return ..()

/obj/item/seeds/replicapod/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/reagent_containers/syringe))
		if(!contains_sample)
			for(var/datum/reagent/blood/bloodSample in W.reagents.reagent_list)
				var/datum/dna/dna = bloodSample.data["dna"]
				if(bloodSample.data["mind"] && bloodSample.data["cloneable"] && !(NO_CLONESCAN in dna.species.species_traits))
					mind = bloodSample.data["mind"]
					ckey = bloodSample.data["ckey"]
					realName = bloodSample.data["real_name"]
					blood_gender = bloodSample.data["gender"]
					blood_type = bloodSample.data["blood_type"]
					factions = bloodSample.data["factions"]
					W.reagents.clear_reagents()
					to_chat(user, "<span class='notice'>You inject the contents of the syringe into the seeds.</span>")
					contains_sample = 1
				else
					to_chat(user, "<span class='warning'>The seeds reject the sample!</span>")
		else
			to_chat(user, "<span class='warning'>The seeds already contain a genetic sample!</span>")
	else
		return ..()

/obj/item/seeds/replicapod/get_analyzer_text()
	var/text = ..()
	if(contains_sample)
		text += "\n It contains a blood sample!"
	return text


/obj/item/seeds/replicapod/harvest(mob/user = usr) //now that one is fun -- Urist
	var/obj/machinery/hydroponics/parent = loc
	var/make_podman = 0
	var/ckey_holder = null
	if(config.revival_pod_plants)
		if(ckey)
			for(var/mob/M in GLOB.player_list)
				if(isobserver(M))
					var/mob/dead/observer/O = M
					if(O.ckey == ckey && O.can_reenter_corpse)
						make_podman = 1
						break
				else
					if(M.ckey == ckey && M.stat == DEAD && !M.suiciding)
						make_podman = 1
						break
		else //If the player has ghosted from his corpse before blood was drawn, his ckey is no longer attached to the mob, so we need to match up the cloned player through the mind key
			for(var/mob/M in GLOB.player_list)
				if(mind && M.mind && ckey(M.mind.key) == ckey(mind.key) && M.ckey && M.client && M.stat == DEAD && !M.suiciding)
					if(isobserver(M))
						var/mob/dead/observer/O = M
						if(!O.can_reenter_corpse)
							break
					make_podman = 1
					ckey_holder = M.ckey
					break

	if(make_podman)	//all conditions met!
		var/mob/living/carbon/human/pod_diona/podman = new /mob/living/carbon/human/pod_diona(parent.loc)
		if(realName)
			podman.real_name = realName
		mind.transfer_to(podman)
		if(ckey)
			podman.ckey = ckey
		else
			podman.ckey = ckey_holder
		podman.gender = blood_gender
		podman.faction |= factions

	else //else, one packet of seeds. maybe two
		var/seed_count = 1
		if(prob(getYield() * 20))
			seed_count++
		var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK
		for(var/i=0,i<seed_count,i++)
			var/obj/item/seeds/replicapod/harvestseeds = src.Copy()
			harvestseeds.forceMove(output_loc)

	parent.update_tray()
