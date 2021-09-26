/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 175
	health = 175
	icon_state = "aliens_s"

	amount_grown = 0
	max_grown = 180

/mob/living/carbon/alien/humanoid/sentinel/New()
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/sentinel
	alien_organs += new /obj/item/organ/internal/xenos/acidgland
	alien_organs += new /obj/item/organ/internal/xenos/neurotoxin
	..()

/mob/living/carbon/alien/humanoid/sentinel/Stat()
	..()
	stat(null, "Evolution Progress: [amount_grown]/[max_grown]")


/mob/living/carbon/alien/humanoid/sentinel/verb/evolve()
	set name = "Evolve (250)"
	set desc = "Evolve into a Praetorian, Royal Guard to the Queen."
	set category = "Alien"

	if(stat != CONSCIOUS)
		return

	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>You cannot evolve when you are cuffed.</span>")

	if(amount_grown >= max_grown && powerc(250))
		to_chat(src, "<span class='boldnotice'>You are able to grow into an Praetorian!</span>")
		to_chat(src, "<B>Praetorians</B> <span class='notice'> tough, able to spit like Sentinels and take twice as much punishment.</span>")
		var/alien_caste = alert(src, "Do you want to evolve into a Praetorian?","Evolve","Yes","No")

		var/mob/living/carbon/alien/humanoid/new_xeno
		switch(alien_caste)
			if("Yes")
				adjustPlasma(-250)
				new_xeno = new /mob/living/carbon/alien/humanoid/praetorian(loc)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("<span class='alertalien'>[src] begins to twist and contort, changing shape!</span>"), 1)
		if(mind)
			mind.transfer_to(new_xeno)
		else
			new_xeno.key = key
		new_xeno.mind.name = new_xeno.name
		qdel(src)
		return
	else
		if(!powerc(250))
			to_chat(src, "<span class='warning'>You do not have enough plasma.</span>")
		else
			to_chat(src, "<span class='warning'>You are not fully grown.</span>")
		return
