/*
//////////////////////////////////////
Sensory-Restoration
	Very very very very noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	Fatal.
Bonus
	The body generates Sensory restorational chemicals.
	oculine for ears
	antihol for removal of alcohol
	synaptizine to purge sensory hallucigens
	mannitol to kickstart the mind

//////////////////////////////////////
*/
/datum/symptom/sensory_restoration
	name = "Sensory Restoration"
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 0

/datum/symptom/sensory_restoration/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 3))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(2)
				if(M.reagents.get_reagent_amount("oculine")<10)
					M.reagents.add_reagent("oculine", 10)
					to_chat(M, "<span class='notice'>Your hearing feels clearer and crisp.</span>")
			if(3)
				if(M.reagents.get_reagent_amount("antihol") < 10 && M.reagents.get_reagent_amount("oculine") < 10 )
					M.reagents.add_reagent_list(list("antihol"=10, "oculine"=10))
					to_chat(M, "<span class='notice'>You feel sober.</span>")
			if(4)
				if(M.reagents.get_reagent_amount("antihol") < 10 && M.reagents.get_reagent_amount("oculine") < 10 && M.reagents.get_reagent_amount("synaphydramine") < 10)
					M.reagents.add_reagent_list(list("antihol"=10, "oculine"=10, "synaphydramine"=5))
					to_chat(M, "<span class='notice'>You feel focused.</span>")
			if(5)
				if(M.reagents.get_reagent_amount("antihol") < 10 && M.reagents.get_reagent_amount("oculine") < 10 && M.reagents.get_reagent_amount("synaphydramine") < 10 && M.reagents.get_reagent_amount("mannitol") < 10)
					M.reagents.add_reagent_list(list("mannitol"=10, "antihol"=10, "oculine"=10, "synaphydramine"=10))
					to_chat(M, "<span class='notice'>Your mind feels relaxed.</span>")
	return

/*
//////////////////////////////////////
Sensory-Destruction
	noticable.
	Lowers resistance
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	the drugs hit them so hard they have to focus on not dying

Bonus
	The body generates Sensory destructive chemicals.
	You cannot taste anything anymore.
	ethanol for extremely drunk victim
	lsd to break the mind
	impedrezene to ruin the brain

//////////////////////////////////////
*/
/datum/symptom/sensory_destruction
	name = "Sensory destruction"
	stealth = -1
	resistance = -2
	stage_speed = -3
	transmittable = -4
	level = 6
	severity = 5

/datum/symptom/sensory_destruction/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				to_chat(M, "<span class='warning'><b>You can't taste a thing.</b></span>")
			if(2)
				to_chat(M, "<span class='warning'><b>You can't feel anything.</b></span>")
				if(prob(10))
					M.reagents.add_reagent("morphine",rand(5,7))
			if(3)
				M.reagents.add_reagent("ethanol",rand(5,7))
				to_chat(M, "<span class='warning'><b>You feel absolutely hammered.</b></span>")
				if(prob(15))
					M.reagents.add_reagent("morphine",rand(5,7))
			if(4)
				M.reagents.add_reagent_list(list("ethanol"=rand(7,15),"lsd"=rand(5,10)))
				to_chat(M, "<span class='warning'><b>You try to focus on not dying.</b></span>")
				if(prob(20))
					M.reagents.add_reagent("morphine",rand(5,7))
			if(5)
				M.reagents.add_reagent_list(list("haloperidol"=rand(5,15),"ethanol"=rand(7,20),"lsd"=rand(5,15)))
				to_chat(M, "<span class='warning'><b>u can count 2 potato!</b></span>")
				if(prob(25))
					M.reagents.add_reagent("morphine",rand(5,7))
	return