    
/datum/disease/ThanosPhobia
	form = "Disease"
	name = "Infinity Disease"
	max_stages = 5
	spread_text = "Airborne"
	cure_text = "Only a Major Force can Safe you From the Rage Of Thanos"
	cures = list("Uranium","ephedrine")
	agent = "Infinity Juice"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 4// I trully dont know how do a 50% chance but welp i mean someone will read this and fix it later rigth ? i mean if it gets merged maybe
	desc = "Thanos Killed half of the Galaxy , seems like you are the unlucky 50% so..... enjoy the ride ? "
	severity = DANGEROUS
	bypasses_immunity = TRUE

/datum/disease/tuberculosis/stage_act() // Time to meme
	..()
	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("cough")
				to_chat(affected_mob, "<span class='danger'>You feel weird.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your heart Speeds Up!</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel a cold.</span>")
		if(4)
			if(prob(2))
				to_chat(affected_mob, "<span class='userdanger'>I dont want to Go Mr.Captain</span>")
				affected_mob.Dizzy(20)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>your finguers starts becoming Dust!</span>")
				affected_mob.adjustcloneLoss(50)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel Thanos Dancing In your mind.</span>")
				affected_mob.adjustOxyLoss(30)
				affected_mob.emote("scream")
		if(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='userdanger'>You think you should paid attention to that Bwoink Sound.</span>")
				affected_mob.adjustStaminaLoss(70)
			if(prob(10))
				affected_mob.adjustStaminaLoss(100)
				affected_mob.say( pick( list("Im , sorry Captain!", "PLEAZ DONT LET ME GO MALPRACTICE BAY!") // Insert Last ressort shitty memes here 
				affected_mob.AdjustSleeping(5)
        Affected_mob.AdjustCloneLoss(100)
        affected_mob.delayed_gib()
			
	return
