/datum/disease/xeno_transformation

	name = "Xenomorph Transformation"
	cure_text = "Spaceacillin & Glycerol"
	cures = list("spaceacillin", "glycerol")
	cure_chance = 5
	agent = "Rip-LEY Alien Microbes"
	desc = "This disease changes the victim into a xenomorph."
	severity = BIOHAZARD
	visibility_flags = 0
	stage1	= null
	stage2	= list("Your throat feels scratchy.", "<span class='danger'>Kill...</span>")
	stage3	= list("<span class='danger'>Your throat feels very scratchy.</span>", "Your skin feels tight.", "<span class='danger'>You can feel something move...inside.</span>")
	stage4	= list("<span class='danger'>Your skin feels very tight.</span>", "<span class='danger'>Your blood boils!</span>", "<span class='danger'>You can feel... something...inside you.</span>")
	stage5	= list("<span class='danger'>Your skin feels as if it's about to burst off!</span>")
	new_form = /mob/living/carbon/alien/humanoid/hunter

/datum/disease/xeno_transformation/stage_act()
	..()
	switch(stage)
		if(3)
			if (prob(4))
				affected_mob << "<span class='danger'>You feel a stabbing pain in your head.</span>"
				affected_mob.Paralyse(2)
		if(4)
			if (prob(20))
				affected_mob.say(pick("You look delicious.", "Going to... devour you...", "Hsssshhhhh!"))

