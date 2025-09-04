/mob/living/simple_animal/slime
	name = "grey baby slime (123)"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	hud_type = /datum/hud/slime
	pass_flags = PASSTABLE | PASSGRILLE
	ventcrawler = VENTCRAWLER_ALWAYS
	gender = NEUTER
	var/is_adult = FALSE
	var/docile = FALSE
	faction = list("slime", "neutral")

	harm_intent_damage = 5
	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	bubble_icon = "slime"

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 150
	health = 150
	healable = FALSE

	see_in_dark = 8

	// canstun and canknockdown don't affect slimes because they ignore stun and knockdown variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE | CANPUSH

	footstep_type = FOOTSTEP_MOB_SLIME

	var/cores = 1 // the number of /obj/item/slime_extract's the slime has left inside
	var/mutation_chance = 30 // Chance of mutating, should be between 25 and 35

	var/powerlevel = 0 // 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the slime has been overfed, if 10, grows or reproduces

	var/number = 0 // Used to understand when someone is talking to it

	var/mob/living/Target = null // AI variable - tells the slime to hunt this down

	var/attacked = 0 // Determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/rabid = FALSE // If set to 1, the slime will attack and eat anything it comes in contact with
	var/target_patience = 0 // AI variable, cooloff-ish for how long it's going to follow its target

	var/mood = "" // To show its face
	var/mutator_used = FALSE // So you can't shove a dozen mutators into a single slime
	var/force_stasis = FALSE

	var/static/regex/slime_name_regex = new("\\w+ (baby|adult) slime \\(\\d+\\)")

	/// Determines if the AI loop is activated
	var/AIproc = FALSE
	/// Attack cooldown
	var/Atkcool = FALSE
	/// Temporary temperature stuns
	var/Tempstun = FALSE
	/// If a slime has been hit with a freeze gun, or wrestled/attacked off a human, they become disciplined and don't attack anymore for a while
	var/Discipline = 0
	/// Stun variable
	var/SStun = 0
	// does this slime have a xeno organ inserted into it already?
	var/obj/item/xeno_organ/holding_organ
	// An elevated form of discipline. Is this slime trained and ready to begin organ therapy?
	var/trained = FALSE
	// how far along in the organ processing are we
	var/organ_progress = 0

	///////////TIME FOR SUBSPECIES

	var/colour = "grey"
	var/coretype = /obj/item/slime_extract/grey
	var/list/slime_mutation[4]

	var/static/list/slime_colours = list("rainbow", "grey", "purple", "metal", "orange",
	"blue", "dark blue", "dark purple", "yellow", "silver", "pink", "red",
	"gold", "green", "adamantine", "oil", "light pink", "bluespace",
	"cerulean", "sepia", "black", "pyrite")

	///////////CORE-CROSSING CODE

	var/effectmod //What core modification is being used.
	var/applied = 0 //How many extracts of the modtype have been applied.


/mob/living/simple_animal/slime/Initialize(mapload, new_colour = "grey", new_is_adult = FALSE)
	var/datum/action/innate/slime/feed/F = new
	F.Grant(src)

	is_adult = new_is_adult

	if(is_adult)
		var/datum/action/innate/slime/reproduce/R = new
		R.Grant(src)
		health = 200
		maxHealth = 200
	else
		var/datum/action/innate/slime/evolve/E = new
		E.Grant(src)
	create_reagents(100)
	set_colour(new_colour)
	. = ..()
	set_nutrition(700)
	add_language("Bubblish")

/mob/living/simple_animal/slime/Destroy()
	walk_to(src, 0)
	for(var/A in actions)
		var/datum/action/AC = A
		AC.Remove(src)
		qdel(AC)
	Target = null
	return ..()

/mob/living/simple_animal/slime/update_overlays()
	. = ..()
	if(stat != DEAD)
		. += "aslime-[mood]"
		if(holding_organ)
			var/mutable_appearance/underlay_appearance = mutable_appearance(layer = 3.9, plane = GAME_PLANE) // 3.9 so it wont potentially layer weird if someones laying below
			underlay_appearance.icon = icon = 'icons/mob/slimes.dmi'
			underlay_appearance.icon_state = "xeno_organ"
			underlays += underlay_appearance

/mob/living/simple_animal/slime/proc/set_colour(new_colour)
	colour = new_colour
	update_appearance(UPDATE_NAME)
	slime_mutation = mutation_table(colour)
	var/sanitizedcolour = replacetext(colour, " ", "")
	coretype = text2path("/obj/item/slime_extract/[sanitizedcolour]")
	regenerate_icons()

/mob/living/simple_animal/slime/update_name()
	. = ..()
	if(slime_name_regex.Find(name))
		number = rand(1, 1000)
		name = "[colour] [is_adult ? "adult" : "baby"] slime ([number])"
		real_name = name

/mob/living/simple_animal/slime/proc/random_colour()
	set_colour(pick(slime_colours))

/mob/living/simple_animal/slime/regenerate_icons()
	..()
	var/icon_text = "[colour] [is_adult ? "adult" : "baby"] slime"
	icon_dead = "[icon_text] dead"
	if(stat != DEAD)
		icon_state = icon_text
		if(mood && stat == CONSCIOUS)
			update_appearance(UPDATE_OVERLAYS)
	else
		icon_state = icon_dead

/mob/living/simple_animal/slime/movement_delay()
	if(bodytemperature >= 330.23) // 135 F or 57.08 C
		return -1	// slimes become supercharged at high temperatures

	. = ..()

	var/health_deficiency = (maxHealth - health)
	if(health_deficiency >= 45)
		. += (health_deficiency / 25)

	if(bodytemperature < 183.222)
		. += (283.222 - bodytemperature) / 10 * 1.75

	if(reagents)
		if(reagents.has_reagent("morphine")) // morphine slows slimes down
			. *= 2

		if(reagents.has_reagent("frostoil")) // Frostoil also makes them move VEEERRYYYYY slow
			. *= 5

	if(health <= 0) // if damaged, the slime moves twice as slow
		. *= 2

	. += GLOB.configuration.movement.slime_delay

/mob/living/simple_animal/slime/update_health_hud()
	if(hud_used)
		if(!client)
			return

		if(healths)
			var/severity = 0
			var/healthpercent = (health / maxHealth) * 100
			switch(healthpercent)
				if(100 to INFINITY)
					healths.icon_state = "slime_health0"
				if(80 to 100)
					healths.icon_state = "slime_health1"
					severity = 1
				if(60 to 80)
					healths.icon_state = "slime_health2"
					severity = 2
				if(40 to 60)
					healths.icon_state = "slime_health3"
					severity = 3
				if(20 to 40)
					healths.icon_state = "slime_health4"
					severity = 4
				if(1 to 20)
					healths.icon_state = "slime_health5"
					severity = 5
				else
					healths.icon_state = "slime_health7"
					severity = 6
			if(severity > 0)
				overlay_fullscreen("brute", /atom/movable/screen/fullscreen/stretch/brute, severity)
			else
				clear_fullscreen("brute")

/mob/living/simple_animal/slime/ObjBump(obj/O)
	if(!client && powerlevel > 0)
		var/probab = 10
		switch(powerlevel)
			if(1 to 2)
				probab = 20
			if(3 to 4)
				probab = 30
			if(5 to 6)
				probab = 40
			if(7 to 8)
				probab = 60
			if(9)
				probab = 70
			if(10)
				probab = 95
		if(prob(probab))
			if(istype(O, /obj/structure/window) || istype(O, /obj/structure/grille))
				if(nutrition <= get_hunger_nutrition() && !Atkcool)
					if(is_adult || prob(5))
						O.attack_slime(src)
						Atkcool = TRUE
						addtimer(VARSET_CALLBACK(src, Atkcool, FALSE), 4.5 SECONDS)

/mob/living/simple_animal/slime/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 2

/mob/living/simple_animal/slime/resist_buckle()
	..()
	Feedstop()

/mob/living/simple_animal/slime/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(!docile)
		status_tab_data[++status_tab_data.len] = list("Nutrition:", "[nutrition]/[get_max_nutrition()]")
	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD)
		status_tab_data[++status_tab_data.len] = list("You can:", is_adult ? "reproduce!" : "evolve!")

	else
		status_tab_data[++status_tab_data.len] = list("Power Level:", "[powerlevel]")


/mob/living/simple_animal/slime/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced)
		amount = -abs(amount)
	return ..() //Heals them

/mob/living/simple_animal/slime/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return
	attacked += 10
	if(Proj.damage_type == BURN)
		adjustBruteLoss(-abs(Proj.damage)) //fire projectiles heals slimes.
		Proj.on_hit(src)
	else
		..(Proj)
	return FALSE

/mob/living/simple_animal/slime/emp_act(severity)
	..()
	powerlevel = 0 // oh no, the power!

/mob/living/simple_animal/slime/MouseDrop(atom/movable/A)
	if(isliving(A) && A != src && usr == src)
		var/mob/living/Food = A
		if(CanFeedon(Food))
			Feedon(Food)
			return
	return ..()

/mob/living/simple_animal/slime/unequip_to(obj/item/target, atom/destination, force = FALSE, silent = FALSE, drop_inventory = TRUE, no_move = FALSE)
	return

/mob/living/simple_animal/slime/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	return

/mob/living/simple_animal/slime/attack_ui(slot)
	return

/mob/living/simple_animal/slime/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		if(M == src)
			return
		if(buckled)
			Feedstop(silent = TRUE)
			visible_message("<span class='danger'>[M] pulls [src] off!</span>", \
				"<span class='danger'>You pull [src] off!</span>")
			return
		attacked += 5
		if(nutrition >= 100) //steal some nutrition. negval handled in life()
			adjust_nutrition(-(50 + (40 * M.is_adult)))
			M.add_nutrition(50 + (40 * M.is_adult))
		if(health > 0)
			M.adjustBruteLoss(-10 + (-10 * M.is_adult))
			M.updatehealth()

/mob/living/simple_animal/slime/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		attacked += 10

/mob/living/simple_animal/slime/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		attacked += 10

/mob/living/simple_animal/slime/attack_hulk(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HARM)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>You don't want to hurt [src]!</span>")
			return FALSE
		discipline_slime(user)
		return ..()

/mob/living/simple_animal/slime/attack_hand(mob/living/carbon/human/M)
	if(buckled)
		M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		if(buckled == M)
			if(prob(60))
				M.visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off!</span>", \
					"<span class='danger'>You attempt to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)

			else
				M.visible_message("<span class='warning'>[M] manages to wrestle \the [name] off!</span>", \
					"<span class='notice'>You manage to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

				discipline_slime(M)

		else
			if(prob(30))
				buckled.visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off of [buckled]!</span>", \
					"<span class='warning'>[M] attempts to wrestle \the [name] off of you!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)

			else
				buckled.visible_message("<span class='warning'>[M] manages to wrestle \the [name] off of [buckled]!</span>", \
					"<span class='notice'>[M] manage to wrestle \the [name] off of you!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

				discipline_slime(M)
	else
		if(stat == DEAD && length(surgeries))
			if(M.a_intent == INTENT_HELP || M.a_intent == INTENT_DISARM)
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(M, src))
						return 1
		if(M.a_intent == INTENT_HELP)
			new /obj/effect/temp_visual/heart(src.loc)
			if(prob(4))
				discipline_slime(M, positive_reinforcement = TRUE)

		if(..()) //successful attack
			attacked += 10

/mob/living/simple_animal/slime/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		attacked += 10
		discipline_slime(M)

/mob/living/simple_animal/slime/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(stat == DEAD && length(surgeries))
		if(user.a_intent == INTENT_HELP || user.a_intent == INTENT_DISARM)
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, src))
					return ITEM_INTERACT_COMPLETE
	if(istype(I, /obj/item/xeno_organ) && stat == CONSCIOUS)
		if(!is_adult)
			to_chat(user, "<span class='notice'>The slime is not old enough yet to process organs!</span>")
			return ITEM_INTERACT_COMPLETE
		if(holding_organ)
			to_chat(user, "<span class='warning'>The slime is already processing an organ!</span>")
			return ITEM_INTERACT_COMPLETE
		if(trained)
			if(src.mind)
				src.visible_message("<span class='notice'>Sentient slimes are unable to process organs!</span>")
				return ITEM_INTERACT_COMPLETE
			if(user.transfer_item_to(I, src, force = TRUE))
				holding_organ = I
				src.visible_message("<span class='notice'>The slime gently pulls the offered organ into itself.</span>")
				update_appearance(UPDATE_OVERLAYS)
				return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='notice'>The slime seems puzzled at what you want it to do with the organ! It needs to be trained first.</span>")
			return ITEM_INTERACT_COMPLETE
	if(istype(I, /obj/item/stack/sheet/mineral/plasma) && stat == CONSCIOUS) //Let's you feed slimes plasma.
		var/obj/item/stack/sheet/mineral/plasma/S = I
		if(S.amount < 5)
			to_chat(user, "<span class='notice'>You need at least five sheets of plasma to feed the slime!</span>")
			return ITEM_INTERACT_COMPLETE
		new /obj/effect/temp_visual/heart(loc)
		visible_message("<span class='notice'>[user] feeds the slime some plasma. It chirps happily!</span>", "<span class='notice'>[user] feeds you a few sheets of plasma! Yummy!!!</span>")
		S.use(5)
		if(Discipline)
			if(!trained)
				trained = TRUE
				name = "tamed [name]"
		else
			discipline_slime(user, positive_reinforcement = TRUE)
		return ITEM_INTERACT_COMPLETE
	if(I.force > 0)
		attacked += 10
		if(prob(25))
			user.do_attack_animation(src)
			user.changeNext_move(CLICK_CD_MELEE)
			to_chat(user, "<span class='danger'>[I] passes right through [src]!</span>")
			return ITEM_INTERACT_COMPLETE
		if(Discipline && prob(50) && !trained) // wow, buddy, why am I getting attacked??
			Discipline = 0
			return ITEM_INTERACT_COMPLETE
		if(trained && prob(20)) // trained slimes are more resistant to losing discipline
			trained = FALSE
			name = initial(name)
			visible_message("<span class='warning'>[src] gets spooked and cowers from [user]!</span>")

/mob/living/simple_animal/slime/attacked_by(obj/item/I, mob/living/user)
	if(..())
		return FINISH_ATTACK

	if(I.force >= 3)
		var/force_effect = 2 * I.force
		if(is_adult)
			force_effect = round(I.force / 2)
		if(prob(10 + force_effect))
			discipline_slime(user)

/mob/living/simple_animal/slime/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	var/water_damage = rand(10, 15) * volume
	adjustBruteLoss(water_damage)
	// Extinguishers just piss them off more
	if(!client && istype(source, /obj/effect/particle_effect/water))
		adjustBruteLoss(5) // extra potent
		if(trained && prob(75))
			say("Ow! HEY!!!", pick(speak_emote))
			trained = FALSE
			name = initial(name)
			rabid = TRUE
	if(!client && Target && volume >= 3) // Like cats
		Target = null
		discipline_slime(FALSE)
		if(prob(5))
			say("Ow ow ow!", pick(speak_emote))

/mob/living/simple_animal/slime/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This is [bicon(src)] \a <EM>[src]</EM>!"
	if(stat == DEAD)
		. += "<span class='deadsay'>It is limp and unresponsive.</span>"
	else
		if(stat == UNCONSCIOUS) // Slime stasis
			. += "<span class='deadsay'>It appears to be alive but unresponsive.</span>"
		if(getBruteLoss())
			. += "<span class='warning'>"
			if(getBruteLoss() < 40)
				. += "It has some punctures in its flesh!"
			else
				. += "<B>It has severe punctures and tears in its flesh!</B>"
			. += "</span>\n"
		if(holding_organ)
			. += "It seems to be currently processing something inside of itself."
		switch(powerlevel)
			if(2 to 3)
				. += "It is flickering gently with a little electrical activity."

			if(4 to 5)
				. += "It is glowing gently with moderate levels of electrical activity."

			if(6 to 9)
				. += "<span class='warning'>It is glowing brightly with high levels of electrical activity.</span>"

			if(10)
				. += "<span class='warning'><B>It is radiating with massive levels of electrical activity!</B></span>"

	. += "</span>"

/mob/living/simple_animal/slime/proc/discipline_slime(mob/user, positive_reinforcement = FALSE)
	if(stat)
		return

	if(!client)
		Discipline++

		if(!is_adult)
			if(Discipline >= 1)
				attacked = 0

	if(trained && !positive_reinforcement)
		say("Sorry...", pick(speak_emote))
		Target = null

	if(buckled)
		Feedstop(silent = TRUE) //we unbuckle the slime from the mob it latched onto.

	SStun = world.time + rand(20,60)

	if(positive_reinforcement)
		mood = ":33"
		regenerate_icons()
		return
	spawn(0)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_TRAIT)
		if(user)
			step_away(src,user,15)
		sleep(3)
		if(user)
			step_away(src,user,15)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_TRAIT)

/mob/living/simple_animal/slime/pet
	docile = TRUE

/mob/living/simple_animal/slime/can_unbuckle()
	return FALSE

/mob/living/simple_animal/slime/can_buckle()
	return FALSE

/mob/living/simple_animal/slime/get_mob_buckling_height(mob/seat)
	if(..())
		return 3

/mob/living/simple_animal/slime/random/Initialize(mapload, new_colour, new_is_adult)
	. = ..(mapload, pick(slime_colours), prob(50))

/mob/living/simple_animal/slime/handle_ventcrawl(atom/A)
	if(buckled)
		to_chat(src, "<i>I can't vent crawl while feeding...</i>")
		return
	..()

/mob/living/simple_animal/slime/unit_test_dummy
	wander = FALSE
	stop_automated_movement = TRUE

/mob/living/simple_animal/slime/proc/eject_organ()
	holding_organ.forceMove(loc)
	visible_message("<span class='notice'>[src] drops \the [holding_organ.name] as it splits!</span>")
	holding_organ = null
	update_appearance()

/mob/living/simple_animal/slime/sentience_act()
	. = ..()
	eject_organ()
