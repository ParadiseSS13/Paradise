/datum/nano_module/virus2
	name = "Virus Creator"

	var/mob/virus_target = null
	var/datum/disease2/disease/curr_virus = null

/datum/nano_module/virus2/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = admin_state)
	var/data[0]

	data["virus_target"] = virus_target
	data["curr_virus"] = curr_virus ? curr_virus.uniqueID : null
	if(curr_virus)
		var/effects[0]
		for(var/datum/disease2/effectholder/E in curr_virus.effects)
			var/subeffect[0]
			subeffect["name"] = E.effect.name
			subeffect["stage"] = E.stage
			subeffect["chance"] = E.chance
			subeffect["multiplier"] = E.multiplier
			subeffect["badness"] = E.effect.badness

			effects.Add(list(subeffect))
		data["virus_effects"] = effects

		var/virusstats[0]
		virusstats["antigen"] = antigens2string(curr_virus.antigen)
		virusstats["spreadType"] = curr_virus.spreadtype
		virusstats["affectedSpecies"] = jointext(curr_virus.affected_species, ", ")
		virusstats["speed"] = curr_virus.speed
		data["virusStats"] = virusstats



	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "virus2_creator.tmpl", "[src]", 800, 450, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/virus2/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["setTarget"])
		var/list/mob_list_l = list()
		for(var/mob/living/carbon/human/H in mob_list)
			mob_list_l += H
		mob_list_l = sortList(mob_list_l)
		mob_list_l += "Random"

		var/newTarget = input(usr, "Who do you want to infect?", "Infection", "Random") as null|anything in mob_list_l
		if(newTarget)
			if(newTarget == "Random")
				virus_target = null
			else
				if(ismob(newTarget))
					virus_target = newTarget
		return 1

	if(href_list["createVirus"])
		if(curr_virus)
			if(alert(usr, "Would you like to delete the current virus and generate a new one?", "Regenerate Virus", "Yes", "No") == "Yes")
				qdel(curr_virus)
				curr_virus = null
			else
				return 0

		var/datum/disease2/disease/new_virus = new()
		new_virus.makerandom()
		curr_virus = new_virus
		new_virus.affected_species = list("Human","Unathi","Skrell","Tajaran","Vox","Kidan","Slime People","Grey","Diona", "Vulpkanin") //restore to default
		usr << "New virus generated: [new_virus.uniqueID]."
		return 1

	if(href_list["deleteCurrVirus"])
		if(curr_virus)
			qdel(curr_virus)
			curr_virus = null
		return 1

	if(href_list["changeEffect"])
		if(curr_virus)
			var/stage = text2num(href_list["changeEffect"])
			if(stage)
				var/list/L = list()

				for(var/effect in (subtypesof(/datum/disease2/effect)))
					var/datum/disease2/effect/E = new effect
					if(initial(E.stage) == stage)
						L[initial(E.name)] = E

				var/datum/disease2/effectholder/holder = curr_virus.effects[stage]
				if(holder)
					var/datum/disease2/effect/current_effect = holder.effect

					var/C = input("Select effect for stage [stage]:", "Stage [stage]", current_effect.name) as null|anything in L
					if(!C)
						return 0

					var/datum/disease2/effect/applied_effect = L[C]
					if(istype(applied_effect))
						holder.effect = applied_effect
						qdel(current_effect)
					else

				return 1

	if(href_list["changeStat"])
		if(curr_virus)
			var/stat = href_list["changeStat"]
			var/stage = text2num(href_list["cSEffect"])
			if(stat && stage)
				switch(stat)
					if("C")
						var/C = input(usr, "What would you like to change the chance to? ", "Edit Chance", null) as null|num
						if(C)
							var/datum/disease2/effectholder/holder = curr_virus.effects[stage]
							if(holder)
								holder.chance = Clamp(C, 0, holder.effect.chance_maxm)

					if("M")
						var/C = input(usr, "What would you like to change the multiplier to?", "Edit Multiplier", null) as null|num
						if(C)
							var/datum/disease2/effectholder/holder = curr_virus.effects[stage]
							if(holder)
								holder.multiplier = Clamp(C, 1, holder.effect.maxm)
		return 1

	if(href_list["spreadToTarget"])
		if(curr_virus)
			if(virus_target)
				infect_virus2(virus_target, curr_virus, 1) //no protection from gods
			else //random
				var/list/mob_list_l = list()
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.client)
						mob_list_l += H

				var/mob/living/carbon/human/H = pick(mob_list_l)
				if(H && H.client)
					infect_virus2(H, curr_virus, 1) //no protection from gods