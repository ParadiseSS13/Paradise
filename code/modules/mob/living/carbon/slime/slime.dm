/mob/living/carbon/slime
	name = "baby slime"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE
	ventcrawler = 2
	speak_emote = list("telepathically chirps")

	layer = 5

	maxHealth = 150
	health = 150
	gender = NEUTER

	nutrition = 700

	see_in_dark = 8
	update_slimes = 0

	// canstun and canweaken don't affect slimes because they ignore stun and weakened variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE|CANPUSH

	var/cores = 1 // the number of /obj/item/slime_extract's the slime has left inside
	var/mutation_chance = 30 // Chance of mutating, should be between 25 and 35

	var/powerlevel = 0 // 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the slime has been overfed, if 10, grows or reproduces

	var/number = 0 // Used to understand when someone is talking to it

	var/mob/living/Victim = null // the person the slime is currently feeding on
	var/mob/living/Target = null // AI variable - tells the slime to hunt this down
	var/mob/living/Leader = null // AI variable - tells the slime to follow this person

	var/attacked = 0 // Determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/rabid = 0 // If set to 1, the slime will attack and eat anything it comes in contact with
	var/holding_still = 0 // AI variable, cooloff-ish for how long it's going to stay in one place
	var/target_patience = 0 // AI variable, cooloff-ish for how long it's going to follow its target

	var/list/Friends = list() // A list of friends; they are not considered targets for feeding; passed down after splitting

	var/list/speech_buffer = list() // Last phrase said near it and person who said it

	var/mood = "" // To show its face
	var/is_adult = 0

	var/core_removal_stage = 0 //For removing cores.
	var/mutator_used = FALSE //So you can't shove a dozen mutators into a single slime

	///////////TIME FOR SUBSPECIES

	var/colour = "grey"
	var/coretype = /obj/item/slime_extract/grey
	var/list/slime_mutation[4]

/mob/living/carbon/slime/New()
	create_reagents(100)
	spawn (0)
		number = rand(1, 1000)
		name = "[colour] [is_adult ? "adult" : "baby"] slime ([number])"
		icon_state = "[colour] [is_adult ? "adult" : "baby"] slime"
		real_name = name
		slime_mutation = mutation_table(colour)
		var/sanitizedcolour = replacetext(colour, " ", "")
		coretype = text2path("/obj/item/slime_extract/[sanitizedcolour]")
	..()

/mob/living/carbon/slime/Destroy()
	for(var/obj/machinery/computer/camera_advanced/xenobio/X in machines)
		if(src in X.stored_slimes)
			X.stored_slimes -= src
	return ..()

/mob/living/carbon/slime/regenerate_icons()
	icon_state = "[colour] [is_adult ? "adult" : "baby"] slime"
	overlays.len = 0
	if(mood)
		overlays += image('icons/mob/slimes.dmi', icon_state = "aslime-[mood]")
	..()

/mob/living/carbon/slime/movement_delay()
	if(bodytemperature >= 330.23) // 135 F
		return -1	// slimes become supercharged at high temperatures

	var/tally = 0

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45) tally += (health_deficiency / 25)

	if(bodytemperature < 183.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(reagents)
		if(reagents.has_reagent("methamphetamine")) // Meth slows slimes down
			tally *= 2

		if(reagents.has_reagent("frostoil")) // Frostoil also makes them move VEEERRYYYYY slow
			tally *= 5

	if(health <= 0) // if damaged, the slime moves twice as slow
		tally *= 2

	return tally + config.slime_delay

/mob/living/carbon/slime/Bump(atom/movable/AM as mob|obj, yes)
	if((!(yes) || now_pushing))
		return
	now_pushing = 1

	if(isobj(AM))
		if(!client && powerlevel > 0)
			var/probab = 10
			switch(powerlevel)
				if(1 to 2)	probab = 20
				if(3 to 4)	probab = 30
				if(5 to 6)	probab = 40
				if(7 to 8)	probab = 60
				if(9)		probab = 70
				if(10)		probab = 95
			if(prob(probab))
				if(istype(AM, /obj/structure/window) || istype(AM, /obj/structure/grille))
					if(nutrition <= get_hunger_nutrition() && !Atkcool)
						if(is_adult || prob(5))
							AM.attack_slime(src)
							spawn()
								Atkcool = 1
								sleep(45)
								Atkcool = 0

	if(ismob(AM))
		var/mob/tmob = AM

		if(is_adult)
			if(istype(tmob, /mob/living/carbon/human))
				if(prob(90))
					now_pushing = 0
					return
		else
			if(istype(tmob, /mob/living/carbon/human))
				now_pushing = 0
				return

	now_pushing = 0
	..()
	if(!istype(AM, /atom/movable))
		return
	if(!( now_pushing ))
		now_pushing = 1
		if(!( AM.anchored ))
			var/t = get_dir(src, AM)
			if(istype(AM, /obj/structure/window))
				if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
			step(AM, t)
		now_pushing = null

/mob/living/carbon/slime/Process_Spacemove(var/movement_dir = 0)
	return 2

/mob/living/carbon/slime/Stat()
	..()

	statpanel("Status")
	if(is_adult)
		stat(null, "Health: [round((health / 200) * 100)]%")
	else
		stat(null, "Health: [round((health / 150) * 100)]%")

	if(client.statpanel == "Status")
		stat(null, "Nutrition: [nutrition]/[get_max_nutrition()]")
		if(amount_grown >= 10)
			if(is_adult)
				stat(null, "You can reproduce!")
			else
				stat(null, "You can evolve!")

		stat(null,"Power Level: [powerlevel]")

/mob/living/carbon/slime/adjustFireLoss(amount)
	..(-abs(amount)) // Heals them
	return

/mob/living/carbon/slime/bullet_act(var/obj/item/projectile/Proj)
	attacked += 10
	..(Proj)
	return 0

/mob/living/carbon/slime/emp_act(severity)
	powerlevel = 0 // oh no, the power!
	..()

/mob/living/carbon/slime/ex_act(severity)
	..()

	var/b_loss = null
	var/f_loss = null
	switch(severity)
		if(1.0)
			qdel(src)
			return

		if(2.0)

			b_loss += 60
			f_loss += 60


		if(3.0)
			b_loss += 30

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()


/mob/living/carbon/slime/blob_act()
	show_message("<span class='userdanger'> The blob attacks you!</span>")
	adjustBruteLoss(20)
	updatehealth()
	return


/mob/living/carbon/slime/unEquip(obj/item/W as obj)
	return

/mob/living/carbon/slime/attack_ui(slot)
	return

/mob/living/carbon/slime/attack_slime(mob/living/carbon/slime/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(Victim) return // can't attack while eating!

	if(health > -100)

		M.do_attack_animation(src)
		visible_message("<span class='danger'> The [M.name] has glomped [src]!</span>", \
				"<span class='userdanger'> The [M.name] has glomped [src]!</span>")
		var/damage = rand(1, 3)
		attacked += 5

		if(M.is_adult)
			damage = rand(1, 6)
		else
			damage = rand(1, 3)

		adjustBruteLoss(damage)

		updatehealth()
	return

/mob/living/carbon/slime/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.custom_emote(1, "[M.friendly] [src]")
	else
		M.do_attack_animation(src)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>", \
				"<span class='userdanger'>[M] [M.attacktext] [src]!</span>")
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		attacked += 10
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/slime/attack_larva(mob/living/carbon/alien/larva/L as mob)

	switch(L.a_intent)

		if(I_HELP)
			visible_message("<span class='notice'>[L] rubs its head against [src].</span>")


		else
			L.do_attack_animation(src)
			attacked += 10
			visible_message("<span class='danger'>[L] bites [src]!</span>", \
					"<span class='userdanger'>[L] bites [src]!</span>")
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)

			if(stat != DEAD)
				var/damage = rand(1, 3)
				L.amount_grown = min(L.amount_grown + damage, L.max_grown)
				adjustBruteLoss(damage)

/mob/living/carbon/slime/attack_hand(mob/living/carbon/human/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	..()

	if(Victim)
		if(Victim == M)
			if(prob(60))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'> [M] manages to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(90) && !client)
					Discipline++

				spawn()
					SStun = 1
					sleep(rand(45,60))
					if(src)
						SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

			return

		else
			if(prob(30))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off of [Victim]!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'> [M] manages to wrestle \the [name] off of [Victim]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(80) && !client)
					Discipline++

					if(!is_adult)
						if(Discipline == 1)
							attacked = 0

				spawn()
					SStun = 1
					sleep(rand(55,65))
					if(src)
						SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

			return
	else
		if(stat == DEAD && surgeries.len)
			if(M.a_intent == I_HELP)
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(M, src))
						return 1

/*
	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == "hurt")//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.use(2500)
					visible_message("<span class='warning'>[src] has been touched with the stun gloves by [M]!</span>")
					return
				else
					to_chat(M, "\red Not enough charge! ")
					return
*/

	switch(M.a_intent)

		if(I_HELP)
			help_shake_act(M)

		if(I_GRAB)
			grabbedby(M)

		else
			M.do_attack_animation(src)
			var/damage = rand(1, 9)

			attacked += 10
			if(prob(90))
				if(HULK in M.mutations)
					damage += 15
					if(Victim || Target)
						Victim = null
						Target = null
						anchored = 0
						if(prob(80) && !client)
							Discipline++
					spawn(0)

						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)


				playsound(loc, "punch", 25, 1, -1)
				visible_message("<span class='danger'>[M] has punched [src]!</span>", \
						"<span class='userdanger'>[M] has punched [src]!</span>")

				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")
	return



/mob/living/carbon/slime/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	switch(M.a_intent)
		if(I_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")

		if(I_HARM)
			M.do_attack_animation(src)
			if(prob(95))
				attacked += 10
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if(damage >= 25)
					damage = rand(20, 40)
					visible_message("<span class='danger'>[M] has attacked [name]!</span>", \
							"<span class='userdanger'>[M] has attacked [name]!</span>")
				else
					visible_message("<span class='danger'>[M] has wounded [name]!</span>", \
							"<span class='userdanger'>)[M] has wounded [name]!</span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to lunge at [name]!</span>", \
						"<span class='userdanger'>[M] has attempted to lunge at [name]!</span>")

		if(I_GRAB)
			grabbedby(M)

		if(I_DISARM)
			M.do_attack_animation(src)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			var/damage = 5
			attacked += 10

			if(prob(95))
				visible_message("<span class='danger'>[M] has tackled [name]!</span>", \
						"<span class='userdanger'>[M] has tackled [name]!</span>")

				if(Victim || Target)
					Victim = null
					Target = null
					anchored = 0
					if(prob(80) && !client)
						Discipline++
						if(!istype(src, /mob/living/carbon/slime))
							if(Discipline == 1)
								attacked = 0

				spawn()
					SStun = 1
					sleep(rand(5,20))
					SStun = 0

				spawn(0)

					step_away(src,M,15)
					sleep(3)
					step_away(src,M,15)

			else
				drop_item()
				visible_message("<span class='danger'>[M] has disarmed [name]!</span>",
						"<span class='userdanger'>[M] has disarmed [name]!</span>")
			adjustBruteLoss(damage)
			updatehealth()
	return

/mob/living/carbon/slime/attackby(obj/item/W, mob/user, params)
	if(stat == DEAD && surgeries.len)
		if(user.a_intent == I_HELP)
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, src))
					return 1
	if(istype(W,/obj/item/stack/sheet/mineral/plasma)) //Lets you feed slimes plasma.
		if(user in Friends)
			++Friends[user]
		else
			Friends[user] = 1
		to_chat(user, "You feed the slime the plasma. It chirps happily.")
		var/obj/item/stack/sheet/mineral/plasma/S = W
		S.use(1)
		return
	else if(W.force > 0)
		attacked += 10
		if(prob(25))
			to_chat(user, "<span class='danger'>[W] passes right through [src]!</span>")
			return
		if(Discipline && prob(50)) // wow, buddy, why am I getting attacked??
			Discipline = 0
	else if(W.force >= 3)
		if(is_adult)
			if(prob(5 + round(W.force/2)))
				if(Victim || Target)
					if(prob(80) && !client)
						Discipline++

					Victim = null
					Target = null
					anchored = 0

					spawn()
						SStun = 1
						sleep(rand(5,20))
						SStun = 0

					spawn(0)
						if(user)
							canmove = 0
							step_away(src, user)
							if(prob(25 + W.force))
								sleep(2)
								if(user)
									step_away(src, user)
								canmove = 1

		else
			if(prob(10 + W.force*2))
				if(Victim || Target)
					if(prob(80) && !client)
						Discipline++
					if(Discipline == 1)
						attacked = 0
					spawn()
						SStun = 1
						sleep(rand(5,20))
						SStun = 0

					Victim = null
					Target = null
					anchored = 0

					spawn(0)
						if(user)
							canmove = 0
							step_away(src, user)
							if(prob(25 + W.force*4))
								sleep(2)
								if(user)
									step_away(src, user)
							canmove = 1
	..()

/mob/living/carbon/slime/restrained()
	return 0

mob/living/carbon/slime/var/temperature_resistance = T0C+75

/mob/living/carbon/slime/show_inv(mob/user)
	return

/mob/living/carbon/slime/toggle_throw_mode()
	return

/mob/living/carbon/slime/proc/apply_water()
	adjustToxLoss(rand(15,20))
	if(!client)
		if(Target) // Like cats
			Target = null
			++Discipline
	return

/mob/living/carbon/slime/can_use_vents()
	if(Victim)
		return "You cannot ventcrawl while feeding."
	..()

/mob/living/carbon/slime/forceFed(var/obj/item/weapon/reagent_containers/food/toEat, mob/user, fullness)
	if(istype(toEat, /obj/item/weapon/reagent_containers/food/drinks))
		return 1
	to_chat(user, "This creature does not seem to have a mouth!")
	return 0