/datum/disease2/disease
	var/infectionchance = 70
	var/speed = 1
	var/spreadtype = "Contact" // Can also be "Airborne"
	var/stage = 1
	var/stageprob = 10
	var/dead = 0
	var/clicks = 0
	var/uniqueID = 0
	var/list/datum/disease2/effectholder/effects = list()
	var/antigen = 0 // 16 bits describing the antigens, when one bit is set, a cure with that bit can dock here
	var/max_stage = 4
	var/list/affected_species = list("Human","Unathi","Skrell","Tajaran")

/datum/disease2/disease/New()
	uniqueID = rand(0,10000)
	..()

/datum/disease2/disease/proc/makerandom(var/greater=0)
	for(var/i=1 ; i <= max_stage ; i++ )
		var/datum/disease2/effectholder/holder = new /datum/disease2/effectholder
		holder.stage = i
		if(greater)
			holder.getrandomeffect(2)
		else
			holder.getrandomeffect()
		effects += holder
	uniqueID = rand(0,10000)
	infectionchance = rand(60,90)
	antigen |= text2num(pick(ANTIGENS))
	antigen |= text2num(pick(ANTIGENS))
	spreadtype = prob(70) ? "Airborne" : "Contact"

	if(all_species.len)
		affected_species = get_infectable_species()

/proc/get_infectable_species()
	var/list/meat = list()
	var/list/res = list()
	for (var/specie in all_species)
		var/datum/species/S = all_species[specie]
		if(!(S.flags & IS_SYNTHETIC))
			meat += S.name
	if(meat.len)
		var/num = rand(1,meat.len)
		for(var/i=0,i<num,i++)
			var/picked = pick(meat)
			meat -= picked
			res += picked
	return res

/datum/disease2/disease/proc/activate(var/mob/living/carbon/mob)
	if(dead)
		cure(mob)
		return

	if(mob.stat == 2)
		return
	if(stage <= 1 && clicks == 0) 	// with a certain chance, the mob may become immune to the disease before it starts properly
		if(prob(5))
			mob.antibodies |= antigen
	if(mob.radiation > 50)
		if(prob(1))
			majormutateinactivate(mob)

	//Space antibiotics stop disease completely
	if(mob.reagents.has_reagent("spaceacillin"))
		if(stage == 1 && prob(20))
			src.cure()
		return

	//Virus food speeds up disease progress
	if(mob.reagents.has_reagent("virusfood"))
		mob.reagents.remove_reagent("virusfood",0.1)
		clicks += 10

	//Moving to the next stage
	if(clicks > stage*100 && prob(10))
		/*if(stage == max_stage)
			src.cure(mob)
			mob.antibodies |= src.antigen*/ //NO AUTOCURE FOR YOU
		stage++
		clicks = 0
	//Do nasty effects
	for(var/datum/disease2/effectholder/e in effects)
		e.runeffect(mob,stage)

	//Short airborne spread
	if(src.spreadtype == "Airborne")
		for(var/mob/living/carbon/M in oview(1,mob))
			if(airborne_can_reach(get_turf(mob), get_turf(M)))
				infect_virus2(M,src)

	//fever
	mob.bodytemperature = max(mob.bodytemperature, min(310+5*stage ,mob.bodytemperature+5*stage))
	clicks+=speed

/datum/disease2/disease/proc/cure(var/mob/living/carbon/mob)
	for(var/datum/disease2/effectholder/e in effects)
		e.effect.deactivate(mob)
	mob.virus2.Remove("[uniqueID]")
	mob.hud_updateflag |= 1 << STATUS_HUD

/datum/disease2/disease/proc/minormutate()
	//uniqueID = rand(0,10000)
	var/datum/disease2/effectholder/holder = pick(effects)
	holder.minormutate()
	infectionchance = min(50,infectionchance + rand(0,10))

/datum/disease2/disease/proc/majormutate()
	uniqueID = rand(0,10000)
	var/datum/disease2/effectholder/holder = pick(effects)
	holder.majormutate()
	if (prob(5))
		antigen = text2num(pick(ANTIGENS))
		antigen |= text2num(pick(ANTIGENS))
	if (prob(5) && all_species.len)
		affected_species = get_infectable_species()

/datum/disease2/disease/proc/majormutateinactivate(var/mob/living/carbon/mob) //Bone White - Duplicate of majormutate() with adminlogs, for use only in activate()
	var/oldID = uniqueID
	uniqueID = rand(0,10000)
	var/datum/disease2/effectholder/holder = pick(effects)
	holder.majormutate()
	if (prob(5))
		var/oldAntigen = antigen
		antigen = text2num(pick(ANTIGENS))
		antigen |= text2num(pick(ANTIGENS))
		log_admin("Stamm #[oldID] ([oldAntigen]) mutated antigens in [mob.name] to Stamm #[uniqueID] ([antigen])")
		message_admins("Stamm #[oldID] ([oldAntigen]) mutated antigens in [mob.name] to Stamm #[uniqueID] ([antigen])")
	else if (prob(10) && all_species.len)
		var/old_species = affected_species
		affected_species = get_infectable_species()
		log_admin("Stamm #[oldID] ([old_species]) mutated affected species in [mob.name] to Stamm #[uniqueID] ([affected_species])")
		message_admins("Stamm #[oldID] ([old_species]) mutated affected species in [mob.name] to Stamm #[uniqueID] ([affected_species])")
	else
		log_admin("Stamm #[oldID] mutated in [mob.name] to Stamm #[uniqueID] ([antigen])")
		message_admins("Stamm #[oldID]  mutated in a [mob.name] to Stamm #[uniqueID] ([antigen])")

/datum/disease2/disease/proc/getcopy()
	var/datum/disease2/disease/disease = new /datum/disease2/disease
	disease.infectionchance = infectionchance
	disease.spreadtype = spreadtype
	disease.stageprob = stageprob
	disease.antigen   = antigen
	disease.uniqueID = uniqueID
	disease.speed = speed
	disease.stage = stage
	disease.clicks = clicks
	disease.affected_species = affected_species.Copy()
	for(var/datum/disease2/effectholder/holder in effects)
		var/datum/disease2/effectholder/newholder = new /datum/disease2/effectholder
		newholder.effect = new holder.effect.type
		newholder.chance = holder.chance
		newholder.cure = holder.cure
		newholder.multiplier = holder.multiplier
		newholder.happensonce = holder.happensonce
		newholder.stage = holder.stage
		disease.effects += newholder
	return disease

/datum/disease2/disease/proc/issame(var/datum/disease2/disease/disease)
	var/list/types = list()
	var/list/types2 = list()
	for(var/datum/disease2/effectholder/d in effects)
		types += d.effect.type
	var/equal = 1

	for(var/datum/disease2/effectholder/d in disease.effects)
		types2 += d.effect.type

	for(var/type in types)
		if(!(type in types2))
			equal = 0

	if (antigen != disease.antigen)
		equal = 0
	return equal

/proc/virus_copylist(var/list/datum/disease2/disease/viruses)
	var/list/res = list()
	for (var/ID in viruses)
		var/datum/disease2/disease/V = viruses[ID]
		if(istype(V))
			res["[V.uniqueID]"] = V.getcopy()
		else
			testing("Got a NULL disease2 in virus_copylist!")
	return res


var/global/list/virusDB = list()

/datum/disease2/disease/proc/name()
	.= "stamm #[add_zero("[uniqueID]", 4)]"
	if ("[uniqueID]" in virusDB)
		var/datum/data/record/V = virusDB["[uniqueID]"]
		.= V.fields["name"]

/datum/disease2/disease/proc/get_info()
	var/r = {"
	<small>Analysis determined the existence of a GNAv2-based viral lifeform.</small><br>
	<u>Designation:</u> [name()]<br>
	<u>Antigen:</u> [antigens2string(antigen)]<br>
	<u>Transmitted By:</u> [spreadtype]<br>
	<u>Rate of Progression:</u> [stageprob * 10]<br>
	<u>Species Affected:</u> [list2text(affected_species, ", ")]<br>
"}

	r += "<u>Symptoms:</u><br>"
	for(var/datum/disease2/effectholder/E in effects)
		r += "([E.stage]) [E.effect.name]    "
		r += "<small><u>Strength:</u> [E.multiplier >= 3 ? "Severe" : E.multiplier > 1 ? "Above Average" : "Average"]    "
		r += "<u>Verosity:</u> [E.chance * 15]</small><br>"

	return r

/datum/disease2/disease/proc/addToDB()
	if ("[uniqueID]" in virusDB)
		return 0
	var/datum/data/record/v = new()
	v.fields["id"] = uniqueID
	v.fields["name"] = name()
	v.fields["description"] = get_info()
	v.fields["antigen"] = antigens2string(antigen)
	v.fields["spread type"] = spreadtype
	virusDB["[uniqueID]"] = v
	return 1

proc/virus2_lesser_infection()
	var/list/candidates = list()	//list of candidate keys

	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G

	if(!candidates.len)	return

	candidates = shuffle(candidates)

	infect_mob_random_lesser(candidates[1])

proc/virus2_greater_infection()
	var/list/candidates = list()	//list of candidate keys

	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)	return

	candidates = shuffle(candidates)

	infect_mob_random_greater(candidates[1])

proc/virology_letterhead(var/report_name)
	return {"
		<center><h1><b>[report_name]</b></h1></center>
		<center><small><i>[station_name()] Virology Lab</i></small></center>
		<hr>
"}
