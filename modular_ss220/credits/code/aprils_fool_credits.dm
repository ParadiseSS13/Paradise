/datum/credits/aprils_fool/fill_credits()
	credits += new /datum/credit/episode_title/aprils_fool()

	var/list/jokes = file2list("config/credits/aprils_fool/jokes.txt")
	jokes.Remove("")


	for(var/i = 0, i < 7, i++)
		var/joke = pick(jokes)
		credits += new /datum/credit/joke(joke)
		jokes -= joke

	credits += new /datum/credit/crewlist()

	credits += new /datum/credit/disclaimer()

/datum/credit/episode_title/aprils_fool/New()
	var/mob/living/carbon/human/fool = pick(GLOB.alive_mob_list| GLOB.dead_mob_list)
	content += "<center><h1>EPISODE [GLOB.round_id]<br><h1>[fool?.real_name] - дурак смены</h1></h1></center>"

/datum/credit/joke/New(joke)
	content += "<hr>"
	content += "<center>[joke]</center>"
	content += "<hr>"
