/datum/action/changeling/bioadaptaion
	name = "Selective Bioadaptaion"
	desc = "We improve our transformative abilites, and allow us to keep benificial organs with any DNA. Passive evolution"
	helptext = "We now can keep cybernetic organs and other benificial special organs on transforming. Does not allow us to dna sting someone with cybernetic implants and gain them."
	dna_cost = 1
	req_stat = DEAD
	needs_button = FALSE


/datum/action/changeling/bioadaptaion/on_purchase(var/mob/user)
	..()
	user.mind.changeling.bioadaptive = TRUE

/datum/action/changeling/bioadaptaion/Remove(var/mob/user)
	user.mind.changeling.bioadaptive = FALSE
	..()
