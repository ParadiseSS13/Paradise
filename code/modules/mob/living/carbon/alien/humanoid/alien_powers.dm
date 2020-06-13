/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/


/mob/living/carbon/proc/powerc(X, Y)//Y is optional, checks for weed planting. X can be null.
	if(stat)
		to_chat(src, "<span class='noticealien'>You must be conscious to do this.</span>")
		return 0
	else if(X && getPlasma() < X)
		to_chat(src, "<span class='noticealien'>Not enough plasma stored.</span>")
		return 0
	else if(Y && (!isturf(src.loc) || istype(src.loc, /turf/space)))
		to_chat(src, "<span class='noticealien'>You can't place that here!</span>")
		return 0
	else	return 1

/mob/living/carbon/alien/humanoid/verb/plant()
	set name = "Plant Weeds (50)"
	set desc = "Plants some alien weeds"
	set category = "Alien"

	if(locate(/obj/structure/alien/weeds/node) in get_turf(src))
		to_chat(src, "<span class='noticealien'>There's already a weed node here.</span>")
		return

	if(powerc(50,1))
		adjustPlasma(-50)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span class='alertalien'>[src] has planted some alien weeds!</span>"), 1)
		new /obj/structure/alien/weeds/node(loc)
	return

/mob/living/carbon/alien/humanoid/verb/whisp(mob/M as mob in oview())
	set name = "Whisper (10)"
	set desc = "Whisper to someone"
	set category = "Alien"

	if(powerc(10))
		adjustPlasma(-10)
		var/msg = sanitize(input("Message:", "Alien Whisper") as text|null)
		if(msg)
			log_say("(AWHISPER to [key_name(M)]) [msg]", src)
			to_chat(M, "<span class='noticealien'>You hear a strange, alien voice in your head...<span class='noticealien'>[msg]")
			to_chat(src, "<span class='noticealien'>You said: [msg] to [M]</span>")
			for(var/mob/dead/observer/G in GLOB.player_list)
				G.show_message("<i>Alien message from <b>[src]</b> ([ghost_follow_link(src, ghost=G)]) to <b>[M]</b> ([ghost_follow_link(M, ghost=G)]): [msg]</i>")
	return

/mob/living/carbon/alien/humanoid/verb/transfer_plasma(mob/living/carbon/alien/M as mob in oview())
	set name = "Transfer Plasma"
	set desc = "Transfer Plasma to another alien"
	set category = "Alien"

	if(isalien(M))
		var/amount = input("Amount:", "Transfer Plasma to [M]") as num
		if(amount)
			amount = abs(round(amount))
			if(powerc(amount))
				if(get_dist(src,M) <= 1)
					M.adjustPlasma(amount)
					adjustPlasma(-amount)
					to_chat(M, "<span class='noticealien'>[src] has transfered [amount] plasma to you.</span>")
					to_chat(src, {"<span class='noticealien'>You have trasferred [amount] plasma to [M]</span>"})
				else
					to_chat(src, "<span class='noticealien'>You need to be closer.</span>")
	return


/mob/living/carbon/alien/humanoid/proc/corrosive_acid(atom/target) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrossive Acid (200)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = "Alien"

	if(powerc(200))
		if(target in oview(1))
			if(target.acid_act(200, 100))
				visible_message("<span class='alertalien'>[src] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
				adjustPlasma(-200)
			else
				to_chat(src, "<span class='noticealien'>You cannot dissolve this object.</span>")
		else
			to_chat(src, "<span class='noticealien'>[target] is too far away.</span>")

/mob/living/carbon/alien/humanoid/proc/neurotoxin() // ok
	set name = "Spit Neurotoxin (50)"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time."
	set category = "Alien"

	if(powerc(50))
		adjustPlasma(-50)
		src.visible_message("<span class='danger'>[src] spits neurotoxin!", "<span class='alertalien'>You spit neurotoxin.</span>")

		var/turf/T = loc
		var/turf/U = get_step(src, dir) // Get the tile infront of the move, based on their direction
		if(!isturf(U) || !isturf(T))
			return

		var/obj/item/projectile/bullet/neurotoxin/A = new /obj/item/projectile/bullet/neurotoxin(usr.loc)
		A.current = U
		A.firer = src
		A.yo = U.y - T.y
		A.xo = U.x - T.x
		A.fire()
		A.newtonian_move(get_dir(U, T))
		newtonian_move(get_dir(U, T))
	return

/mob/living/carbon/alien/humanoid/proc/resin() // -- TLE
	set name = "Secrete Resin (55)"
	set desc = "Secrete tough malleable resin."
	set category = "Alien"

	if(powerc(55))
		var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin wall","resin membrane","resin nest") //would do it through typesof but then the player choice would have the type path and we don't want the internal workings to be exposed ICly - Urist

		if(!choice || !powerc(55))	return
		adjustPlasma(-55)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span class='alertalien'>[src] vomits up a thick purple substance and shapes it!</span>"), 1)
		switch(choice)
			if("resin wall")
				new /obj/structure/alien/resin/wall(loc)
			if("resin membrane")
				new /obj/structure/alien/resin/membrane(loc)
			if("resin nest")
				new /obj/structure/bed/nest(loc)
	return

/mob/living/carbon/alien/humanoid/verb/regurgitate()
	set name = "Regurgitate"
	set desc = "Empties the contents of your stomach"
	set category = "Alien"

	if(powerc())
		if(stomach_contents.len)
			for(var/mob/M in src)
				if(M in stomach_contents)
					stomach_contents.Remove(M)
					M.forceMove(loc)
					//Paralyse(10)
			src.visible_message("<span class='alertalien'><B>[src] hurls out the contents of [p_their()] stomach!</span>")
	return

/mob/living/carbon/proc/getPlasma()
 	var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
 	if(!vessel) return 0
 	return vessel.stored_plasma


/mob/living/carbon/proc/adjustPlasma(amount)
 	var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
 	if(!vessel) return
 	vessel.stored_plasma = max(vessel.stored_plasma + amount,0)
 	vessel.stored_plasma = min(vessel.stored_plasma, vessel.max_plasma) //upper limit of max_plasma, lower limit of 0
 	return 1

/mob/living/carbon/alien/adjustPlasma(amount)
	. = ..()
	updatePlasmaDisplay()

/mob/living/carbon/proc/usePlasma(amount)
	if(getPlasma() >= amount)
		adjustPlasma(-amount)
		return 1

 	return 0
