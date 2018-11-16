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
	faction = list("slime","neutral")
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
	var/docile = 0
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

/mob/living/carbon/slime/random/New()
	colour = pick("grey","orange", "metal", "blue", "purple", "dark purple", "dark blue", "green", "silver", "yellow", "gold", "yellow", "red", "silver", "pink", "cerulean", "sepia", "bluespace", "pyrite", "light pink", "oil", "adamantine", "black")
	..()

/mob/living/carbon/slime/Destroy()
	for(var/obj/machinery/computer/camera_advanced/xenobio/X in GLOB.machines)
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

	. = ..()

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45)
		. += (health_deficiency / 25)

	if(bodytemperature < 183.222)
		. += (283.222 - bodytemperature) / 10 * 1.75

	if(reagents)
		if(reagents.has_reagent("methamphetamine")) // Meth slows slimes down
			. *= 2

		if(reagents.has_reagent("frostoil")) // Frostoil also makes them move VEEERRYYYYY slow
			. *= 5

	if(health <= 0) // if damaged, the slime moves twice as slow
		. *= 2

	. += config.slime_delay

/mob/living/carbon/slime/ObjBump(obj/O)
	if(!client && powerlevel > 0)
		var/chance = 10
		switch(powerlevel)
			if(1 to 2)	chance = 20
			if(3 to 4)	chance = 30
			if(5 to 6)	chance = 40
			if(7 to 8)	chance = 60
			if(9)		chance = 70
			if(10)		chance = 95
		if(prob(chance))
			if(istype(O, /obj/structure/window) || istype(O, /obj/structure/grille))
				if(nutrition <= get_hunger_nutrition() && !Atkcool)
					if(is_adult || prob(5))
						O.attack_slime(src)
						Atkcool = 1
						spawn(45)
							Atkcool = 0

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
		if(!docile)
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

/mob/living/carbon/slime/MouseDrop(atom/movable/A)
	if(isliving(A) && A != src && usr == src)
		var/mob/living/Food = A
		if(Food.Adjacent(src) && !stat && Food.stat != DEAD) //messy
			Feedon(Food)
	..()

/mob/living/carbon/slime/unEquip(obj/item/W as obj)
	return

/mob/living/carbon/slime/attack_ui(slot)
	return

/mob/living/carbon/slime/attack_slime(mob/living/carbon/slime/M)
	..()
	if(Victim)
		Victim = null
		visible_message("<span class='danger'>[M] pulls [src] off!</span>")
		return
	attacked += 5
	if(nutrition >= 100) //steal some nutrition. negval handled in life()
		nutrition -= (50 + (5 * M.amount_grown))
		M.add_nutrition(50 + (5 * M.amount_grown))
	if(health > 0)
		adjustBruteLoss(4 + (2 * M.amount_grown)) //amt_grown isn't very linear but it works
		updatehealth()
		M.adjustBruteLoss(-4 + (-2 * M.amount_grown))
		M.updatehealth()

/mob/living/carbon/slime/attack_animal(mob/living/simple_animal/M)
	if(..())
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		attacked += 10
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/slime/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			adjustBruteLoss(damage)
			updatehealth()

/mob/living/carbon/slime/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		if(Victim || Target)
			Victim = null
			Target = null
			anchored = 0
			if(prob(80) && !client)
				Discipline++
		spawn(0)
			step_away(src, user, 15)
			sleep(3)
			step_away(src, user, 15)
		..(user, TRUE)
		playsound(loc, "punch", 25, 1, -1)
		visible_message("<span class='danger'>[user] has punched [src]!</span>", "<span class='userdanger'>[user] has punched [src]!</span>")
		adjustBruteLoss(15)
		return TRUE

/mob/living/carbon/slime/attack_hand(mob/living/carbon/human/M)
	if(Victim)
		M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		if(Victim == M)
			if(prob(60))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'> [M] manages to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(90) && !client)
					Discipline++

				SStun = 1
				spawn(rand(45,60))
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

				SStun = 1
				spawn(rand(55,65))
					SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

			return

	if(..()) //To allow surgery to return properly.
		return

	switch(M.a_intent)

		if(INTENT_HELP)
			help_shake_act(M)

		if(INTENT_GRAB)
			grabbedby(M)

		else
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			var/damage = rand(1, 9)
			attacked += 10
			if(prob(90))
				playsound(loc, "punch", 25, 1, -1)
				add_attack_logs(M, src, "Melee attacked with fists")
				visible_message("<span class='danger'>[M] has punched [src]!</span>", \
						"<span class='userdanger'>[M] has punched [src]!</span>")
				if(stat != DEAD)
					adjustBruteLoss(damage)
					updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")
	return

/mob/living/carbon/slime/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		if(M.a_intent == INTENT_HARM)
			if(prob(95))
				attacked += 10
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if(damage >= 25)
					damage = rand(20, 40)
					visible_message("<span class='danger'>[M] has slashed [name]!</span>", \
							"<span class='userdanger'>[M] has slashed [name]!</span>")
				else
					visible_message("<span class='danger'>[M] has wounded [name]!</span>", \
							"<span class='userdanger'>)[M] has wounded [name]!</span>")
				add_attack_logs(M, src, "Alien attacked")
				if(stat != DEAD)
					adjustBruteLoss(damage)
					updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to lunge at [name]!</span>", \
						"<span class='userdanger'>[M] has attempted to lunge at [name]!</span>")

		if(M.a_intent == INTENT_DISARM)
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
						if(!isslime(src))
							if(Discipline == 1)
								attacked = 0

				SStun = 1
				spawn(rand(5,20))
					SStun = 0

				spawn(0)

					step_away(src,M,15)
					sleep(3)
					step_away(src,M,15)

			else
				drop_item()
				visible_message("<span class='danger'>[M] has disarmed [name]!</span>",
						"<span class='userdanger'>[M] has disarmed [name]!</span>")
			add_attack_logs(M, src, "Alien disarmed")
			adjustBruteLoss(damage)
			updatehealth()
	return

/mob/living/carbon/slime/attackby(obj/item/W, mob/living/user, params)
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
			user.do_attack_animation(src)
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

					SStun = 1
					spawn(rand(5,20))
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
					SStun = 1
					spawn(rand(5,20))
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

/mob/living/carbon/slime/forceFed(var/obj/item/reagent_containers/food/toEat, mob/user, fullness)
	if(istype(toEat, /obj/item/reagent_containers/food/drinks))
		return 1
	to_chat(user, "This creature does not seem to have a mouth!")
	return 0

/mob/living/carbon/slime/can_hear()
	. = TRUE //honestly fuck slimes and organ bullshit