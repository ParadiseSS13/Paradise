/datum/disease/transformation
	name = "Transformation"
	max_stages = 5
	spread_text = "Acute"
	spread_flags = SPREAD_SPECIAL
	cure_text = "A coder's love (theoretical)."
	agent = "Shenanigans"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/alien)
	severity = VIRUS_BIOHAZARD
	stage_prob = 10
	disease_flags = VIRUS_CURABLE
	var/list/stage1 = list("You feel unremarkable.")
	var/list/stage2 = list("You feel boring.")
	var/list/stage3 = list("You feel utterly plain.")
	var/list/stage4 = list("You feel white bread.")
	var/list/stage5 = list("Oh the humanity!")
	var/transformation_text = null
	var/new_form = /mob/living/carbon/human
	var/job_role = null

/datum/disease/transformation/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(1)
			if(prob(stage_prob) && stage1)
				to_chat(affected_mob, pick(stage1))
		if(2)
			if(prob(stage_prob) && stage2)
				to_chat(affected_mob, pick(stage2))
		if(3)
			if(prob(stage_prob*2) && stage3)
				to_chat(affected_mob, pick(stage3))
		if(4)
			if(prob(stage_prob*2) && stage4)
				to_chat(affected_mob, pick(stage4))
		if(5)
			do_disease_transformation(affected_mob)

/datum/disease/transformation/proc/do_disease_transformation(mob/living/affected_mob)
	if(iscarbon(affected_mob) && affected_mob.stat != DEAD)
		if(stage5)
			to_chat(affected_mob, pick(stage5))
		if(jobban_isbanned(affected_mob, job_role))
			affected_mob.death()
			return
		if(affected_mob.notransform)
			return
		if(transformation_text)
			to_chat(affected_mob, transformation_text)
		affected_mob.notransform = TRUE
		affected_mob.icon = null
		affected_mob.overlays.Cut()
		affected_mob.invisibility = 101
		for(var/obj/item/W in affected_mob)
			if(istype(W, /obj/item/bio_chip))
				qdel(W)
				continue
			W.layer = initial(W.layer)
			W.plane = initial(W.plane)
			W.loc = affected_mob.loc
			W.dropped(affected_mob)
		if(isobj(affected_mob.loc))
			var/obj/O = affected_mob.loc
			O.force_eject_occupant(affected_mob)
		var/mob/living/new_mob = new new_form(affected_mob.loc)
		affected_mob.create_log(MISC_LOG, "has transformed into [new_mob], due to having the virus \"[src]\"")
		if(istype(new_mob))
			new_mob.a_intent = "harm"
			if(affected_mob.mind)
				affected_mob.mind.transfer_to(new_mob)
			else
				new_mob.key = affected_mob.key
			if(isrobot(new_mob))
				new_mob.rename_self("Cyborg", TRUE, TRUE)
		qdel(affected_mob)



/datum/disease/transformation/jungle_fever
	name = "Jungle Fever"
	cure_text = "Bananas"
	cures = list("banana")
	spread_text = "Monkey Bites"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 1
	desc = "Monkeys with this disease will bite humans, causing humans to mutate into a monkey."
	stage_prob = 4
	agent = "Kongey Vibrion M-909"
	new_form = /mob/living/carbon/human/monkey

	stage1	= null
	stage2	= null
	stage3	= null
	stage4	= list("<span class='warning'>Your back hurts.</span>", "<span class='warning'>You breathe through your mouth.</span>",
					"<span class='warning'>You have a craving for bananas.</span>", "<span class='warning'>Your mind feels clouded.</span>")
	stage5	= list("<span class='warning'>You feel like monkeying around.</span>")

/datum/disease/transformation/jungle_fever/do_disease_transformation(mob/living/carbon/human/affected_mob)
	if(!issmall(affected_mob))
		affected_mob.monkeyize()

/datum/disease/transformation/jungle_fever/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='notice'>Your [pick("back", "arm", "leg", "elbow", "head")] itches.</span>")
		if(3)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>You feel a stabbing pain in your head.</span>")
				affected_mob.AdjustConfused(20 SECONDS)
		if(4)
			if(prob(3))
				affected_mob.say(pick("Eeek, ook ook!", "Eee-eeek!", "Eeee!", "Ungh, ungh."))


/datum/disease/transformation/robot

	name = "Robotic Transformation"
	cure_text = "An injection of copper."
	cures = list("copper")
	cure_chance = 5
	agent = "R2D2 Nanomachines"
	desc = "This disease, actually acute nanomachine infection, converts the victim into a cyborg."
	stage1	= null
	stage2	= list("Your joints feel stiff.", "<span class='danger'>Beep...boop..</span>")
	stage3	= list("<span class='danger'>Your joints feel very stiff.</span>", "Your skin feels loose.", "<span class='danger'>You can feel something move...inside.</span>")
	stage4	= list("<span class='danger'>Your skin feels very loose.</span>", "<span class='danger'>You can feel... something...inside you.</span>")
	stage5	= list("<span class='danger'>Your skin feels as if it's about to burst off!</span>")
	new_form = /mob/living/silicon/robot
	job_role = "Cyborg"


/datum/disease/transformation/robot/stage_act()
	..()
	switch(stage)
		if(3)
			if(prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>You feel a stabbing pain in your head.</span>")
				affected_mob.Paralyse(4 SECONDS)
		if(4)
			if(prob(20))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."))


/datum/disease/transformation/xeno

	name = "Xenomorph Transformation"
	cure_text = "Spaceacillin & Glycerol"
	cures = list("spaceacillin", "glycerol")
	cure_chance = 5
	agent = "Rip-LEY Alien Microbes"
	desc = "This disease changes the victim into a xenomorph."
	stage1	= null
	stage2	= list("Your throat feels scratchy.", "<span class='danger'>Kill...</span>")
	stage3	= list("<span class='danger'>Your throat feels very scratchy.</span>", "Your skin feels tight.", "<span class='danger'>You can feel something move...inside.</span>")
	stage4	= list("<span class='danger'>Your skin feels very tight.</span>", "<span class='danger'>Your blood boils!</span>", "<span class='danger'>You can feel... something...inside you.</span>")
	stage5	= list("<span class='danger'>Your skin feels as if it's about to burst off!</span>")
	new_form = /mob/living/carbon/alien/humanoid/hunter
	job_role = ROLE_ALIEN

/datum/disease/transformation/xeno/stage_act()
	..()
	switch(stage)
		if(3)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>You feel a stabbing pain in your head.</span>")
				affected_mob.Paralyse(4 SECONDS)
		if(4)
			if(prob(20))
				affected_mob.say(pick("You look delicious.", "Going to... devour you...", "Hsssshhhhh!"))


/datum/disease/transformation/slime
	name = "Advanced Mutation Transformation"
	cure_text = "frost oil"
	cures = list("frostoil")
	cure_chance = 80
	agent = "Advanced Mutation Toxin"
	desc = "This highly concentrated extract converts anything into more of itself."
	stage1	= list("You don't feel very well.")
	stage2	= list("Your skin feels a little slimy.")
	stage3	= list("<span class='danger'>Your appendages are melting away.</span>", "<span class='danger'>Your limbs begin to lose their shape.</span>")
	stage4	= list("<span class='danger'>You are turning into a slime.</span>")
	stage5	= list("<span class='danger'>You have become a slime.</span>")
	new_form = /mob/living/simple_animal/slime/random

/datum/disease/transformation/slime/stage_act()
	..()
	switch(stage)
		if(1)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/H = affected_mob
				if(isslimeperson(H))
					stage = 5
		if(3)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/human = affected_mob
				if(!isslimeperson(human))
					human.set_species(/datum/species/slime)

/datum/disease/transformation/corgi
	name = "The Barkening"
	cure_text = "Death"
	cures = list("adminordrazine")
	agent = "Fell Doge Majicks"
	desc = "This disease transforms the victim into a corgi."
	stage1	= list("BARK.")
	stage2	= list("You feel the need to wear silly hats.")
	stage3	= list("<span class='danger'>Must... eat... chocolate....</span>", "<span class='danger'>YAP</span>")
	stage4	= list("<span class='danger'>Visions of washing machines assail your mind!</span>")
	stage5	= list("<span class='danger'>AUUUUUU!!!</span>")
	new_form = /mob/living/simple_animal/pet/dog/corgi

/datum/disease/transformation/corgi/stage_act()
	..()
	switch(stage)
		if(3)
			if(prob(8))
				affected_mob.say(pick("YAP", "Woof!"))
		if(4)
			if(prob(20))
				affected_mob.say(pick("Bark!", "AUUUUUU"))

/datum/disease/transformation/morph
	name = "Gluttony's Blessing"
	cure_text = "nothing"
	cures = list("adminordrazine")
	agent = "Gluttony's Blessing"
	desc = "A 'gift' from somewhere terrible."
	stage_prob = 20
	stage1	= list("Your stomach rumbles.")
	stage2	= list("Your skin feels saggy.")
	stage3	= list("<span class='danger'>Your appendages are melting away.</span>", "<span class='danger'>Your limbs begin to lose their shape.</span>")
	stage4	= list("<span class='danger'>You're ravenous.</span>")
	stage5	= list("<span class='danger'>You have become a morph.</span>")
	transformation_text = "<span class='userdanger'>This transformation does NOT make you an antagonist if you were not one already. If you were not an antagonist, you should not eat any steal objectives or the contents of the armory.</span>"
	new_form = /mob/living/simple_animal/hostile/morph
	job_role = ROLE_MORPH
