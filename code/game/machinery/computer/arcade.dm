/obj/machinery/computer/arcade
	name = "random arcade"
	desc = "random arcade machine."
	icon_state = "arcade"
	icon_keyboard = null
	icon_screen = "invaders"
	light_color = "#00FF00"
	var/prize = /obj/item/stack/tickets

/obj/machinery/computer/arcade/proc/Reset()
	return

/obj/machinery/computer/arcade/Initialize(mapload)
	. = ..()
	if(!circuit)
		var/choice = pick(subtypesof(/obj/machinery/computer/arcade))
		var/obj/machinery/computer/arcade/chosen = new choice(loc)
		chosen.dir = dir
		return INITIALIZE_HINT_QDEL
	Reset()


/obj/machinery/computer/arcade/proc/prizevend(score)
	if(!length(contents))
		var/prize_amount
		if(score)
			prize_amount = score
		else
			prize_amount = rand(1, 10)
		new prize(get_turf(src), prize_amount)
	else
		var/atom/movable/prize = pick(contents)
		prize.loc = get_turf(src)

/obj/machinery/computer/arcade/emp_act(severity)
	..(severity)
	if(stat & (NOPOWER|BROKEN))
		return
	var/num_of_prizes = 0
	switch(severity)
		if(EMP_HEAVY)
			num_of_prizes = rand(1,4)
		if(EMP_LIGHT)
			num_of_prizes = rand(0,2)
	for(var/i = num_of_prizes; i > 0; i--)
		prizevend()
	explosion(get_turf(src), -1, 0, 1+num_of_prizes, flame_range = 1+num_of_prizes, cause = "EMP'd arcade machine")


/obj/machinery/computer/arcade/battle
	name = "arcade machine"
	desc = "Does not support Pinball."
	icon_state = "battle_arcade"
	icon_screen = "battle"
	circuit = /obj/item/circuitboard/arcade/battle
	var/enemy_name = "Space Villain"
	/// event message for attack messages, etc
	var/previous_event = "Make your move!"
	/// Player health/attack points
	var/player_hp = 30
	/// the highest amount of health that the player has held
	var/player_max_hp = 30
	/// player magic points
	var/player_mp = 10
	/// the highest amount of mana that the player has held
	var/player_max_mp = 10
	/// Enemy health/attack points
	var/enemy_hp = 45
	/// the highest amount of health that the enemy achieves - this never changes, but avoids magic numbers
	var/enemy_max_hp = 45
	/// enemy magic points
	var/enemy_mp = 20
	var/gameover = FALSE
	/// a counter of whether the last few player inputs were to heal, incurs a turtling penalty when emagged
	var/passive_streak = 0
	COOLDOWN_DECLARE(spam_cooldown)

/obj/machinery/computer/arcade/battle/proc/generate_name()
	var/name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ", "Ban ")

	var/name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	var/name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "Slime", "Griefer", "ERPer", "Lizard Man", "Unicorn", "Bloopers")

	enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	name = (name_action + name_part1 + name_part2)

/obj/machinery/computer/arcade/battle/Reset()
	previous_event = initial(previous_event)
	player_hp = initial(player_hp)
	player_max_hp = initial(player_max_hp)
	player_mp = initial(player_mp)
	player_max_mp = initial(player_max_mp)
	enemy_hp = initial(enemy_hp)
	enemy_max_hp = initial(enemy_max_hp)
	enemy_mp = initial(enemy_mp)
	gameover = initial(gameover)
	passive_streak = initial(enemy_mp)

/obj/machinery/computer/arcade/battle/Initialize(mapload)
	. = ..()
	generate_name()

/obj/machinery/computer/arcade/battle/attack_hand(mob/user as mob)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/arcade/battle/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArcadeBattle", name)
		ui.open()

/obj/machinery/computer/arcade/battle/ui_data(mob/user)
	var/list/data = list()
	data["enemyName"] = enemy_name
	data["enemyHP"] = enemy_hp
	data["enemyMaxHP"] = enemy_max_hp
	data["playerHP"] = player_hp
	data["playerMaxHP"] = player_max_hp
	data["playerMP"] = player_mp
	data["playerMaxMP"] = player_max_mp
	data["onCooldown"] = !COOLDOWN_FINISHED(src, spam_cooldown)
	data["gameOver"] = gameover
	data["previousEvent"] = previous_event
	return data

/obj/machinery/computer/arcade/battle/ui_act(action, params)
	if(..())
		return
	if(!COOLDOWN_FINISHED(src, spam_cooldown))
		return

	switch(action)
		if("attack")
			var/attack_amount = rand(2,6)
			enemy_hp -= attack_amount
			previous_event = "You attack for [attack_amount] damage!"
			if(passive_streak > 0)
				passive_streak--
			playsound(loc, 'sound/arcade/hit.ogg', 50, TRUE)
			COOLDOWN_START(src, spam_cooldown, 1 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(arcade_action)), 1 SECONDS)

		if("heal")
			var/heal_amount = rand(6,8)
			var/point_amount = rand(1,3)
			player_hp += heal_amount
			player_mp -= point_amount

			if(player_hp > player_max_hp)
				player_max_hp = player_hp
			previous_event = "You use [point_amount] magic to heal for [heal_amount] damage!"
			passive_streak++
			playsound(loc, 'sound/arcade/heal.ogg', 50, TRUE)
			COOLDOWN_START(src, spam_cooldown, 1 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(arcade_action)), 1 SECONDS)

		if("charge")
			var/charge_amount = rand(4,7)
			player_mp += charge_amount
			if(player_mp > player_max_mp)
				player_max_mp = player_mp
			previous_event = "You regain [charge_amount] points!"
			if(passive_streak > 0)
				passive_streak--
			playsound(loc, 'sound/arcade/mana.ogg', 50, TRUE)
			COOLDOWN_START(src, spam_cooldown, 1 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(arcade_action)), 1 SECONDS)

		if("newgame") //Reset everything
			if(emagged)
				emagged = FALSE
				generate_name()
			Reset()

	return TRUE

/obj/machinery/computer/arcade/battle/proc/arcade_action()
	if((enemy_mp <= 0) || (enemy_hp <= 0))
		gameover = TRUE
		previous_event = "[enemy_name] has fallen!"
		playsound(loc, 'sound/arcade/win.ogg', 50, TRUE)

		if(emagged)
			SSblackbox.record_feedback("tally", "arcade_status", 1, "win_emagged")
			new /obj/effect/spawner/newbomb/timer/syndicate(get_turf(src))
			new /obj/item/clothing/head/collectable/petehat(get_turf(src))
			message_admins("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded a bomb.")
			log_game("[key_name(usr)] has outbombed Cuban Pete and been awarded a bomb.")
			Reset()
			generate_name()
			emagged = FALSE
		else
			SSblackbox.record_feedback("tally", "arcade_status", 1, "win_normal")
			prizevend(35)

	else if(emagged && (passive_streak >= 4))
		var/boom_amount = rand(5,10)
		previous_event = "[enemy_name] throws a bomb, exploding you for [boom_amount] damage!"
		playsound(loc, 'sound/arcade/boom.ogg', 50, TRUE)
		player_hp -= boom_amount

	else if((enemy_mp <= 5) && (prob(70)))
		var/steal_amount = rand(2,3)
		previous_event = "[enemy_name] steals [steal_amount] of your power!"
		playsound(loc, 'sound/arcade/steal.ogg', 50, TRUE)
		player_mp -= steal_amount

		if(player_mp <= 0)
			gameover = TRUE
			previous_event = "You have been drained!"
			playsound(loc, 'sound/arcade/lose.ogg', 50, TRUE)
			if(emagged)
				SSblackbox.record_feedback("tally", "arcade_status", 1, "loss_mana_emagged")
				usr.gib()
			else
				SSblackbox.record_feedback("tally", "arcade_status", 1, "loss_mana_normal")

	else if((enemy_hp <= 10) && (enemy_mp > 4))
		previous_event = "[enemy_name] heals for 4 health!"
		playsound(loc, 'sound/arcade/heal.ogg', 50, TRUE)
		enemy_hp += 4
		enemy_mp -= 4

	else
		var/attack_amount = rand(3,6)
		previous_event = "[enemy_name] attacks for [attack_amount] damage!"
		playsound(loc, 'sound/arcade/hit.ogg', 50, TRUE)
		player_hp -= attack_amount

	if((player_mp <= 0) || (player_hp <= 0))
		gameover = TRUE
		previous_event = "You have been crushed!"
		playsound(loc, 'sound/arcade/lose.ogg', 50, TRUE)
		if(emagged)
			SSblackbox.record_feedback("tally", "arcade_status", 1, "loss_hp_emagged")
			usr.gib()
		else
			SSblackbox.record_feedback("tally", "arcade_status", 1, "loss_hp_normal")

	return


/obj/machinery/computer/arcade/battle/emag_act(user as mob)
	if(!emagged)
		Reset()
		emagged = TRUE

		enemy_name = "Cuban Pete"
		name = "Outbomb Cuban Pete"
		previous_event = "If you die in the game, you die for real!"

		add_hiddenprint(user)
		return TRUE

// *** THE ORION TRAIL ** //

#define ORION_TRAIL_WINTURN		9

//Orion Trail Events
#define ORION_TRAIL_RAIDERS		"Raiders"
#define ORION_TRAIL_FLUX		"Interstellar Flux"
#define ORION_TRAIL_ILLNESS		"Illness"
#define ORION_TRAIL_BREAKDOWN	"Breakdown"
#define ORION_TRAIL_LING		"Changelings?"
#define ORION_TRAIL_LING_ATTACK "Changeling Ambush"
#define ORION_TRAIL_MALFUNCTION	"Malfunction"
#define ORION_TRAIL_COLLISION	"Collision"
#define ORION_TRAIL_SPACEPORT	"Spaceport"
#define ORION_TRAIL_BLACKHOLE	"BlackHole"


/obj/machinery/computer/arcade/orion_trail
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"
	icon_screen = "orion"
	circuit = /obj/item/circuitboard/arcade/orion_trail
	var/busy = FALSE //prevent clickspam that allowed people to ~speedrun~ the game.
	var/engine = 0
	var/hull = 0
	var/electronics = 0
	var/food = 80
	var/fuel = 60
	var/turns = 4
	var/playing = 0
	var/gameover = 0
	var/alive = 4
	var/eventdat = null
	var/event = null
	var/list/settlers = list("Harry","Larry","Bob")
	var/list/events = list(ORION_TRAIL_RAIDERS		= 3,
						ORION_TRAIL_FLUX			= 1,
						ORION_TRAIL_ILLNESS		= 3,
						ORION_TRAIL_BREAKDOWN	= 2,
						ORION_TRAIL_LING			= 3,
						ORION_TRAIL_MALFUNCTION	= 2,
						ORION_TRAIL_COLLISION	= 1,
						ORION_TRAIL_SPACEPORT	= 2
						)
	var/list/stops = list()
	var/list/stopblurbs = list()
	var/lings_aboard = 0
	var/spaceport_raided = 0
	var/spaceport_freebie = 0
	var/last_spaceport_action = ""

/obj/machinery/computer/arcade/orion_trail/Reset()
	// Sets up the main trail
	stops = list("Pluto","Asteroid Belt","Proxima Centauri","Dead Space","Rigel Prime","Tau Ceti Beta","Black Hole","Space Outpost Beta-9","Orion Prime")
	stopblurbs = list(
		"Pluto, long since occupied with long-range sensors and scanners, stands ready to, and indeed continues to probe the far reaches of the galaxy.",
		"At the edge of the Sol system lies a treacherous asteroid belt. Many have been crushed by stray asteroids and misguided judgement.",
		"The nearest star system to Sol, in ages past it stood as a reminder of the boundaries of sub-light travel, now a low-population sanctuary for adventurers and traders.",
		"This region of space is particularly devoid of matter. Such low-density pockets are known to exist, but the vastness of it is astounding.",
		"Rigel Prime, the center of the Rigel system, burns hot, basking its planetary bodies in warmth and radiation.",
		"Tau Ceti Beta has recently become a waypoint for colonists headed towards Orion. There are many ships and makeshift stations in the vicinity.",
		"Sensors indicate that a black hole's gravitational field is affecting the region of space we were headed through. We could stay of course, but risk of being overcome by its gravity, or we could change course to go around, which will take longer.",
		"You have come into range of the first man-made structure in this region of space. It has been constructed not by travellers from Sol, but by colonists from Orion. It stands as a monument to the colonists' success.",
		"You have made it to Orion! Congratulations! Your crew is one of the few to start a new foothold for mankind!"
		)

/obj/machinery/computer/arcade/orion_trail/proc/newgame()
	// Set names of settlers in crew
	settlers = list()
	for(var/i = 1; i <= 3; i++)
		add_crewmember()
	add_crewmember("[usr]")
	// Re-set items to defaults
	engine = 1
	hull = 1
	electronics = 1
	food = 80
	fuel = 60
	alive = 4
	turns = 1
	event = null
	playing = 1
	gameover = 0
	lings_aboard = 0

	//spaceport junk
	spaceport_raided = 0
	spaceport_freebie = 0
	last_spaceport_action = ""

/obj/machinery/computer/arcade/orion_trail/attack_hand(mob/user)
	if(..())
		return
	if(fuel <= 0 || food <=0 || length(settlers) == 0)
		gameover = 1
		event = null
	user.set_machine(src)
	var/dat = ""
	if(gameover)
		dat = "<center><h1>Game Over</h1></center>"
		dat += "Like many before you, your crew never made it to Orion, lost to space... <br><b>Forever</b>."
		if(length(settlers) == 0)
			dat += "<br>Your entire crew died, your ship joins the fleet of ghost-ships littering the galaxy."
		else
			if(food <= 0)
				dat += "<br>You ran out of food and starved."
				if(emagged)
					user.set_nutrition(0) //yeah you pretty hongry
					to_chat(user, SPAN_USERDANGER("<font size=3>Your body instantly contracts to that of one who has not eaten in months. Agonizing cramps seize you as you fall to the floor."))
			if(fuel <= 0)
				dat += "<br>You ran out of fuel, and drift, slowly, into a star."
				if(emagged)
					var/mob/living/M = user
					M.adjust_fire_stacks(5)
					M.IgniteMob() //flew into a star, so you're on fire
					to_chat(user, SPAN_USERDANGER("<font size=3>You feel an immense wave of heat emanate from the arcade machine. Your skin bursts into flames."))
		dat += "<br><P ALIGN=Right><a href='byond://?src=[UID()];menu=1'>OK...</a></P>"

		if(emagged)
			to_chat(user, "[SPAN_USERDANGER("<font size=3>You're never going to make it to Orion...")]</font>")
			user.death()
			emagged = FALSE //removes the emagged status after you lose
			playing = 0 //also a new game
			name = "The Orion Trail"
			desc = "Learn how our ancestors got to Orion, and have fun in the process!"

	else if(event)
		dat = eventdat
	else if(playing)
		var/title = stops[turns]
		var/subtext = stopblurbs[turns]
		dat = "<center><h1>[title]</h1></center>"
		dat += "[subtext]"
		dat += "<h3><b>Crew:</b></h3>"
		dat += english_list(settlers)
		dat += "<br><b>Food: </b>[food] | <b>Fuel: </b>[fuel]"
		dat += "<br><b>Engine Parts: </b>[engine] | <b>Hull Panels: </b>[hull] | <b>Electronics: </b>[electronics]"
		if(turns == 7)
			dat += "<P ALIGN=Right><a href='byond://?src=[UID()];pastblack=1'>Go Around</a> <a href='byond://?src=[UID()];blackhole=1'>Continue</a></P>"
		else
			dat += "<P ALIGN=Right><a href='byond://?src=[UID()];continue=1'>Continue</a></P>"
		dat += "<P ALIGN=Right><a href='byond://?src=[UID()];killcrew=1'>Kill a crewmember</a></P>"
		dat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"
	else
		dat = "<center><h2>The Orion Trail</h2></center>"
		dat += "<br><center><h3>Experience the journey of your ancestors!</h3></center><br><br>"
		dat += "<center><b><a href='byond://?src=[UID()];newgame=1'>New Game</a></b></center>"
		dat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"
	var/datum/browser/popup = new(user, "arcade", "The Orion Trail",400,700)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/computer/arcade/orion_trail/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")

	if(busy)
		return
	busy = TRUE

	if(href_list["continue"]) //Continue your travels
		if(turns >= ORION_TRAIL_WINTURN)
			win()
		else
			food -= (alive+lings_aboard)*2
			fuel -= 5
			if(turns == 2 && prob(30))
				event = ORION_TRAIL_COLLISION
				event()
			else if(prob(75))
				event = pickweight(events)
				if(lings_aboard)
					if(event == ORION_TRAIL_LING || prob(55))
						event = ORION_TRAIL_LING_ATTACK
				event()
			turns += 1
		if(emagged)
			var/mob/living/carbon/M = usr //for some vars
			switch(event)
				if(ORION_TRAIL_RAIDERS)
					if(prob(50))
						to_chat(usr, SPAN_USERDANGER("You hear battle shouts. The tramping of boots on cold metal. Screams of agony. The rush of venting air. Are you going insane?"))
						M.AdjustHallucinate(30 SECONDS)
					else
						to_chat(usr, SPAN_USERDANGER("Something strikes you from behind! It hurts like hell and feel like a blunt weapon, but nothing is there..."))
						M.take_organ_damage(30)
						playsound(loc, 'sound/weapons/genhit2.ogg', 100, TRUE)
				if(ORION_TRAIL_ILLNESS)
					var/severity = rand(1,3) //pray to RNGesus. PRAY, PIGS
					if(severity == 1)
						to_chat(M, SPAN_USERDANGER("You suddenly feel slightly nauseous."))//got off lucky

					if(severity == 2)
						to_chat(usr, SPAN_USERDANGER("You suddenly feel extremely nauseous and hunch over until it passes."))
						M.Stun(6 SECONDS)
					if(severity >= 3) //you didn't pray hard enough
						to_chat(M, SPAN_WARNING("An overpowering wave of nausea consumes over you. You hunch over, your stomach's contents preparing for a spectacular exit."))
						M.Stun(10 SECONDS)
						sleep(30)
						atom_say("[M] violently throws up!")
						playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
						M.adjust_nutrition(-50) //lose a lot of food
						var/turf/location = usr.loc
						if(issimulatedturf(location))
							location.add_vomit_floor(TRUE)
				if(ORION_TRAIL_FLUX)
					if(prob(75))
						M.Weaken(6 SECONDS)
						atom_say("A sudden gust of powerful wind slams [M] into the floor!")
						M.take_organ_damage(25)
						playsound(loc, 'sound/weapons/genhit.ogg', 100, TRUE)
					else
						to_chat(M, SPAN_USERDANGER("A violent gale blows past you, and you barely manage to stay standing!"))
				if(ORION_TRAIL_COLLISION) //by far the most damaging event
					if(prob(90))
						playsound(loc, 'sound/effects/bang.ogg', 100, TRUE)
						var/turf/simulated/floor/F
						for(F in orange(1, src))
							F.ChangeTurf(F.baseturf)
						atom_say("Something slams into the floor around [src], exposing it to space!")
						if(hull)
							sleep(10)
							atom_say("A new floor suddenly appears around [src]. What the hell?")
							playsound(loc, 'sound/weapons/genhit.ogg', 100, TRUE)
							var/turf/space/T
							for(T in orange(1, src))
								T.ChangeTurf(/turf/simulated/floor/plating)
					else
						atom_say("Something slams into the floor around [src] - luckily, it didn't get through!")
						playsound(loc, 'sound/effects/bang.ogg', 50, TRUE)
				if(ORION_TRAIL_MALFUNCTION)
					playsound(loc, 'sound/effects/empulse.ogg', 50, TRUE)
					visible_message(SPAN_DANGER("[src] malfunctions, randomizing in-game stats!"))
					var/oldfood = food
					var/oldfuel = fuel
					food = rand(10,80) / rand(1,2)
					fuel = rand(10,60) / rand(1,2)
					if(electronics)
						sleep(10)
						if(oldfuel > fuel && oldfood > food)
							audible_message(SPAN_DANGER("[src] lets out a somehow reassuring chime."))
						else if(oldfuel < fuel || oldfood < food)
							audible_message(SPAN_DANGER("[src] lets out a somehow ominous chime."))
						food = oldfood
						fuel = oldfuel
						playsound(loc, 'sound/machines/chime.ogg', 50, TRUE)

	else if(href_list["newgame"]) //Reset everything
		newgame()
	else if(href_list["menu"]) //back to the main menu
		playing = 0
		event = null
		gameover = 0
		food = 80
		fuel = 60
		settlers = list("Harry","Larry","Bob")
	else if(href_list["slow"]) //slow down
		food -= (alive+lings_aboard)*2
		fuel -= 5
		event = null
	else if(href_list["pastblack"]) //slow down
		food -= ((alive+lings_aboard)*2)*3
		fuel -= 15
		turns += 1
		event = null
	else if(href_list["useengine"]) //use parts
		engine = max(0, --engine)
		event = null
	else if(href_list["useelec"]) //use parts
		electronics = max(0, --electronics)
		event = null
	else if(href_list["usehull"]) //use parts
		hull = max(0, --hull)
		event = null
	else if(href_list["wait"]) //wait 3 days
		food -= ((alive+lings_aboard)*2)*3
		event = null
	else if(href_list["keepspeed"]) //keep speed
		if(prob(75))
			event = "Breakdown"
			event()
		else
			event = null
	else if(href_list["blackhole"]) //keep speed past a black hole
		if(prob(75))
			event = ORION_TRAIL_BLACKHOLE
			event()
			if(emagged) //has to be here because otherwise it doesn't work
				playsound(loc, 'sound/effects/supermatter.ogg', 100, TRUE)
				atom_say("A miniature black hole suddenly appears in front of [src], devouring [usr] alive!")
				if(isliving(usr))
					var/mob/living/L = usr
					L.Stun(20 SECONDS) //you can't run :^)
				var/S = new /obj/singularity/onetile(usr.loc)
				emagged = FALSE //immediately removes emagged status so people can't kill themselves by sprinting up and interacting
				sleep(50)
				atom_say("[S] winks out, just as suddenly as it appeared.")
				qdel(S)
		else
			event = null
			turns += 1
	else if(href_list["holedeath"])
		gameover = 1
		event = null
	else if(href_list["eventclose"]) //end an event
		event = null

	else if(href_list["killcrew"]) //shoot a crewmember
		if(length(settlers) <= 0 || alive <= 0)
			return
		var/sheriff = remove_crewmember() //I shot the sheriff
		playsound(loc, 'sound/weapons/gunshots/gunshot.ogg', 100, TRUE)

		if(length(settlers) == 0 || alive == 0)
			atom_say("The last crewmember [sheriff], shot themselves, GAME OVER!")
			if(emagged)
				usr.death(FALSE)
				emagged = FALSE
			gameover = TRUE
			event = null
		else if(emagged)
			if(usr.name == sheriff)
				atom_say("The crew of the ship chose to kill [usr.name]!")
				usr.death(FALSE)

		if(event == ORION_TRAIL_LING) //only ends the ORION_TRAIL_LING event, since you can do this action in multiple places
			event = null

	//Spaceport specific interactions
	//they get a header because most of them don't reset event (because it's a shop, you leave when you want to)
	//they also call event() again, to regen the eventdata, which is kind of odd but necessary
	else if(href_list["buycrew"]) //buy a crewmember
		var/bought = add_crewmember()
		last_spaceport_action = "You hired [bought] as a new crewmember."
		fuel -= 10
		food -= 10
		event()

	else if(href_list["sellcrew"]) //sell a crewmember
		var/sold = remove_crewmember()
		last_spaceport_action = "You sold your crewmember, [sold]!"
		fuel += 7
		food += 7
		event()

	else if(href_list["leave_spaceport"])
		event = null
		spaceport_raided = 0
		spaceport_freebie = 0
		last_spaceport_action = ""

	else if(href_list["raid_spaceport"])
		var/success = min(15 * alive,100) //default crew (4) have a 60% chance
		spaceport_raided = 1

		var/FU = 0
		var/FO = 0
		if(prob(success))
			FU = rand(5,15)
			FO = rand(5,15)
			last_spaceport_action = "You successfully raided the spaceport! you gained [FU] Fuel and [FO] Food! (+[FU]FU,+[FO]FO)"
		else
			FU = rand(-5,-15)
			FO = rand(-5,-15)
			last_spaceport_action = "You failed to raid the spaceport! you lost [FU*-1] Fuel and [FO*-1] Food in your scramble to escape! ([FU]FU,[FO]FO)"

			//your chance of lose a crewmember is 1/2 your chance of success
			//this makes higher % failures hurt more, don't get cocky space cowboy!
			if(prob(success*5))
				var/lost_crew = remove_crewmember()
				last_spaceport_action = "You failed to raid the spaceport! you lost [FU*-1] Fuel and [FO*-1] Food, AND [lost_crew] in your scramble to escape! ([FU]FI,[FO]FO,-Crew)"
				if(emagged)
					atom_say("WEEWOO WEEWOO, Spaceport Security en route!")
					for(var/i, i<=3, i++)
						var/mob/living/simple_animal/hostile/syndicate/ranged/orion/O = new/mob/living/simple_animal/hostile/syndicate/ranged/orion(get_turf(src))
						O.target = usr


		fuel += FU
		food += FO
		event()

	else if(href_list["buyparts"])
		switch(text2num(href_list["buyparts"]))
			if(1) //Engine Parts
				engine++
				last_spaceport_action = "Bought Engine Parts"
			if(2) //Hull Plates
				hull++
				last_spaceport_action = "Bought Hull Plates"
			if(3) //Spare Electronics
				electronics++
				last_spaceport_action = "Bought Spare Electronics"
		fuel -= 5 //they all cost 5
		event()

	else if(href_list["trade"])
		switch(text2num(href_list["trade"]))
			if(1) //Fuel
				fuel -= 5
				food += 5
				last_spaceport_action = "Traded Fuel for Food"
			if(2) //Food
				fuel += 5
				food -= 5
				last_spaceport_action = "Traded Food for Fuel"
		event()

	add_fingerprint(usr)
	updateUsrDialog()
	busy = FALSE
	return


/obj/machinery/computer/arcade/orion_trail/proc/event()
	eventdat = "<center><h1>[event]</h1></center>"

	switch(event)
		if(ORION_TRAIL_RAIDERS)
			eventdat += "Raiders have come aboard your ship!"
			if(prob(50))
				var/sfood = rand(1,10)
				var/sfuel = rand(1,10)
				food -= sfood
				fuel -= sfuel
				eventdat += "<br>They have stolen [sfood] <b>Food</b> and [sfuel] <b>Fuel</b>."
			else if(prob(10))
				var/deadname = remove_crewmember()
				eventdat += "<br>[deadname] tried to fight back but was killed."
			else
				eventdat += "<br>Fortunately you fended them off without any trouble."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Continue</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

		if(ORION_TRAIL_FLUX)
			eventdat += "This region of space is highly turbulent. <br>If we go slowly we may avoid more damage, but if we keep our speed we won't waste supplies."
			eventdat += "<br>What will you do?"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];slow=1'>Slow Down</a> <a href='byond://?src=[UID()];keepspeed=1'>Continue</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

		if(ORION_TRAIL_ILLNESS)
			eventdat += "A deadly illness has been contracted!"
			var/deadname = remove_crewmember()
			eventdat += "<br>[deadname] was killed by the disease."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Continue</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

		if(ORION_TRAIL_BREAKDOWN)
			eventdat += "Oh no! The engine has broken down!"
			eventdat += "<br>You can repair it with an engine part, or you can make repairs for 3 days."
			if(engine >= 1)
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];useengine=1'>Use Part</a><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
			else
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

		if(ORION_TRAIL_MALFUNCTION)
			eventdat += "The ship's systems are malfunctioning!"
			eventdat += "<br>You can replace the broken electronics with spares, or you can spend 3 days troubleshooting the AI."
			if(electronics >= 1)
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];useelec=1'>Use Part</a><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
			else
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

		if(ORION_TRAIL_COLLISION)
			eventdat += "Something hit us! Looks like there's some hull damage."
			if(prob(25))
				var/sfood = rand(5,15)
				var/sfuel = rand(5,15)
				food -= sfood
				fuel -= sfuel
				eventdat += "<br>[sfood] <b>Food</b> and [sfuel] <b>Fuel</b> was vented out into space."
			if(prob(10))
				var/deadname = remove_crewmember()
				eventdat += "<br>[deadname] was killed by rapid depressurization."
			eventdat += "<br>You can repair the damage with hull plates, or you can spend the next 3 days welding scrap together."
			if(hull >= 1)
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];usehull=1'>Use Part</a><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
			else
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];wait=1'>Wait</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

		if(ORION_TRAIL_BLACKHOLE)
			eventdat += "You were swept away into the black hole."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];holedeath=1'>Oh...</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"
			settlers = list()

		if(ORION_TRAIL_LING)
			eventdat += "Strange reports warn of changelings infiltrating crews on trips to Orion..."
			if(length(settlers) <= 2)
				eventdat += "<br>Your crew's chance of reaching Orion is so slim the changelings likely avoided your ship..."
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Continue</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"
				if(prob(10)) // "likely", I didn't say it was guaranteed!
					lings_aboard = min(++lings_aboard,2)
			else
				if(lings_aboard) //less likely to stack lings
					if(prob(20))
						lings_aboard = min(++lings_aboard,2)
				else if(prob(70))
					lings_aboard = min(++lings_aboard,2)

				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];killcrew=1'>Kill a crewmember</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Risk it</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"

		if(ORION_TRAIL_LING_ATTACK)
			if(lings_aboard <= 0) //shouldn't trigger, but hey.
				eventdat += "Haha, fooled you, there are no changelings on board!"
				eventdat += "<br>(You should report this to a coder :S)"
			else
				var/ling1 = remove_crewmember()
				var/ling2 = ""
				if(lings_aboard >= 2)
					ling2 = remove_crewmember()

				eventdat += "Oh no, some of your crew are Changelings!"
				if(ling2)
					eventdat += "<br>[ling1] and [ling2]'s arms twist and contort into grotesque blades!"
				else
					eventdat += "<br>[ling1]'s arm twists and contorts into a grotesque blade!"

				var/chance2attack = alive*20
				if(prob(chance2attack))
					var/chancetokill = 30*lings_aboard-(5*alive) //eg: 30*2-(10) = 50%, 2 lings, 2 crew is 50% chance
					if(prob(chancetokill))
						var/deadguy = remove_crewmember()
						eventdat += "<br>The Changeling[ling2 ? "s":""] run[ling2 ? "":"s"] up to [deadguy] and capitulates them!"
					else
						eventdat += "<br>You valiantly fight off the Changeling[ling2 ? "s":""]!"
						eventdat += "<br>You cut the Changeling[ling2 ? "s":""] up into meat... Eww"
						if(ling2)
							food += 30
							lings_aboard = max(0,lings_aboard-2)
						else
							food += 15
							lings_aboard = max(0,--lings_aboard)
				else
					eventdat += "<br>The Changeling[ling2 ? "s":""] run[ling2 ? "":"s"] away, What wimps!"
					if(ling2)
						lings_aboard = max(0,lings_aboard-2)
					else
						lings_aboard = max(0,--lings_aboard)

			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];eventclose=1'>Continue</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"


		if(ORION_TRAIL_SPACEPORT)
			if(spaceport_raided)
				eventdat += "The Spaceport is on high alert! They wont let you dock since you tried to attack them!"
				if(last_spaceport_action)
					eventdat += "<br>Last Spaceport Action: [last_spaceport_action]"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];leave_spaceport=1'>Depart Spaceport</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];close=1'>Close</a></P>"
			else
				eventdat += "You pull the ship up to dock at a nearby Spaceport, lucky find!"
				eventdat += "<br>This Spaceport is home to travellers who failed to reach Orion, but managed to find a different home..."
				eventdat += "<br>Trading terms: FU = Fuel, FO = Food"
				if(last_spaceport_action)
					eventdat += "<br>Last Spaceport Action: [last_spaceport_action]"
				eventdat += "<h3><b>Crew:</b></h3>"
				eventdat += english_list(settlers)
				eventdat += "<br><b>Food: </b>[food] | <b>Fuel: </b>[fuel]"
				eventdat += "<br><b>Engine Parts: </b>[engine] | <b>Hull Panels: </b>[hull] | <b>Electronics: </b>[electronics]"


				//If your crew is pathetic you can get freebies (provided you haven't already gotten one from this port)
				if(!spaceport_freebie && (fuel < 20 || food < 20))
					spaceport_freebie++
					var/FU = 10
					var/FO = 10
					var/freecrew = 0
					if(prob(30))
						FU = 25
						FO = 25

					if(prob(10))
						add_crewmember()
						freecrew++

					eventdat += "<br>The traders of the spaceport take pitty on you, and give you some food and fuel (+[FU]FU,+[FO]FO)"
					if(freecrew)
						eventdat += "<br>You also gain a new crewmember!"

					fuel += FU
					food += FO

				//CREW INTERACTIONS
				eventdat += "<P ALIGN=Right>Crew Management:</P>"

				//Buy crew
				if(food > 10 && fuel > 10)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buycrew=1'>Hire a new Crewmember (-10FU,-10FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Cant afford a new Crewmember</P>"

				//Sell crew
				if(length(settlers) > 1)
					eventdat += "<p ALIGN=Right><a href='byond://?src=[UID()];sellcrew=1'>Sell crew for Fuel and Food (+7FU,+7FO)</a></p>"
				else
					eventdat += "<P ALIGN=Right>Cant afford to sell a Crewmember</P>"

				//BUY/SELL STUFF
				eventdat += "<P ALIGN=Right>Spare Parts:</P>"

				//Engine parts
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buyparts=1'>Buy Engine Parts (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Cant afford to buy Engine Parts</a>"

				//Hull plates
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buyparts=2'>Buy Hull Plates (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Cant afford to buy Hull Plates</a>"

				//Electronics
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];buyparts=3'>Buy Spare Electronics (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Cant afford to buy Spare Electronics</a>"

				//Trade
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];trade=1'>Trade Fuel for Food (-5FU,+5FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Cant afford to Trade Fuel for Food</P"

				if(food > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];trade=2'>Trade Food for Fuel (+5FU,-5FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Cant afford to Trade Food for Fuel</P"

				//Raid the spaceport
				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];raid_spaceport=1'>!! Raid Spaceport !!</a></P>"

				eventdat += "<P ALIGN=Right><a href='byond://?src=[UID()];leave_spaceport=1'>Depart Spaceport</a></P>"


//Add Random/Specific crewmember
/obj/machinery/computer/arcade/orion_trail/proc/add_crewmember(specific = "")
	var/newcrew = ""
	if(specific)
		newcrew = specific
	else
		if(prob(50))
			newcrew = pick(GLOB.first_names_male)
		else
			newcrew = pick(GLOB.first_names_female)
	if(newcrew)
		settlers += newcrew
		alive++
	return newcrew

//Remove Random/Specific crewmember
/obj/machinery/computer/arcade/orion_trail/proc/remove_crewmember(specific = "", dont_remove = "")
	var/list/safe2remove = settlers
	var/removed = ""
	if(dont_remove)
		safe2remove -= dont_remove
	if(specific && specific != dont_remove)
		safe2remove = list(specific)
	else
		if(length(safe2remove) >= 1) //need to make sure we even have anyone to remove
			removed = pick(safe2remove)

	if(removed)
		if(lings_aboard && prob(40*lings_aboard)) //if there are 2 lings you're twice as likely to get one, obviously
			lings_aboard = max(0,--lings_aboard)
		settlers -= removed
		alive--
	return removed


/obj/machinery/computer/arcade/orion_trail/proc/win()
	playing = 0
	turns = 1
	atom_say("Congratulations, you made it to Orion!")
	if(emagged)
		new /obj/item/orion_ship(get_turf(src))
		message_admins("[key_name_admin(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
		log_game("[key_name(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
	else
		var/score = 10 * (alive - lings_aboard) + 5 * (engine + hull + electronics)
		prizevend(score)
	emagged = FALSE
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"

/obj/machinery/computer/arcade/orion_trail/emag_act(mob/user)
	if(!emagged)
		to_chat(user, SPAN_NOTICE("You override the cheat code menu and skip to Cheat #[rand(1, 50)]: Realism Mode."))
		name = "The Orion Trail: Realism Edition"
		desc = "Learn how our ancestors got to Orion, and try not to die in the process!"
		add_hiddenprint(user)
		newgame()
		emagged = TRUE
		return TRUE

/mob/living/simple_animal/hostile/syndicate/ranged/orion
	name = "spaceport security"
	desc = "Premier corporate security forces for all spaceports found along the Orion Trail."
	faction = list("orion")
	loot = list()

/obj/item/orion_ship
	name = "model settler ship"
	desc = "A model spaceship, it looks like those used back in the day when travelling to Orion! It even has a miniature FX-293 reactor, which was renowned for its instability and tendency to explode..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "ship"
	w_class = WEIGHT_CLASS_SMALL
	var/active = FALSE //if the ship is on

/obj/item/orion_ship/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(!active)
			. += SPAN_NOTICE("There's a little switch on the bottom. It's flipped down.")
		else
			. += SPAN_NOTICE("There's a little switch on the bottom. It's flipped up.")

/obj/item/orion_ship/attack_self__legacy__attackchain(mob/user) //Minibomb-level explosion. Should probably be more because of how hard it is to survive the machine! Also, just over a 5-second fuse
	if(active)
		return

	message_admins("[key_name_admin(usr)] primed an explosive Orion ship for detonation.")
	log_game("[key_name(usr)] primed an explosive Orion ship for detonation.")

	to_chat(user, SPAN_WARNING("You flip the switch on the underside of [src]."))
	active = TRUE
	visible_message(SPAN_NOTICE("[src] softly beeps and whirs to life!"))
	playsound(loc, 'sound/machines/defib_saftyon.ogg', 25, TRUE)
	atom_say("This is ship ID #[rand(1,1000)] to Orion Port Authority. We're coming in for landing, over.")
	sleep(20)
	visible_message(SPAN_WARNING("[src] begins to vibrate..."))
	atom_say("Uh, Port? Having some issues with our reactor, could you check it out? Over.")
	sleep(30)
	atom_say("Oh, God! Code Eight! CODE EIGHT! IT'S GONNA BL-")
	playsound(loc, 'sound/machines/buzz-sigh.ogg', 25, TRUE)
	sleep(3.6)
	visible_message(SPAN_USERDANGER("[src] explodes!"))
	explosion(src.loc, 1,2,4, flame_range = 3, cause = "Orion Ship Minibomb")
	qdel(src)


#undef ORION_TRAIL_WINTURN
#undef ORION_TRAIL_RAIDERS
#undef ORION_TRAIL_FLUX
#undef ORION_TRAIL_ILLNESS
#undef ORION_TRAIL_BREAKDOWN
#undef ORION_TRAIL_LING
#undef ORION_TRAIL_LING_ATTACK
#undef ORION_TRAIL_MALFUNCTION
#undef ORION_TRAIL_COLLISION
#undef ORION_TRAIL_SPACEPORT
#undef ORION_TRAIL_BLACKHOLE
