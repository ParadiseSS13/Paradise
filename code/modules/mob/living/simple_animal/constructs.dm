/mob/living/simple_animal/hostile/construct
	name = "Construct"
	real_name = "Construct"
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon_dead = "shade_dead"
	speed = 0
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_HIDDEN_RUNES
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("cult")
	flying = TRUE
	pressure_resistance = 100
	universal_speak = TRUE
	AIStatus = AI_OFF //normal constructs don't have AI
	loot = list(/obj/item/reagent_containers/food/snacks/ectoplasm)
	del_on_death = TRUE
	deathmessage = "collapses in a shattered heap."
	var/construct_type = "shade"
	var/list/construct_spells = list()
	var/playstyle_string = "<b>You are a generic construct! Your job is to not exist, and you should probably adminhelp this.</b>"

/mob/living/simple_animal/hostile/construct/New()
	. = ..()
	if(!SSticker.mode)//work around for maps with runes and cultdat is not loaded all the way
		name = "[construct_type] ([rand(1, 1000)])"
		real_name = construct_type
		icon_living = construct_type
		icon_state = construct_type
	else
		name = "[SSticker.cultdat.get_name(construct_type)] ([rand(1, 1000)])"
		real_name = SSticker.cultdat.get_name(construct_type)
		icon_living = SSticker.cultdat.get_icon(construct_type)
		icon_state = SSticker.cultdat.get_icon(construct_type)

	for(var/spell in construct_spells)
		AddSpell(new spell(null))

	set_light(2, 3, l_color = SSticker.cultdat ? SSticker.cultdat.construct_glow : LIGHT_COLOR_BLOOD_MAGIC)

/mob/living/simple_animal/hostile/construct/death(gibbed)
	. = ..()
	SSticker.mode.remove_cultist(mind, FALSE)

/mob/living/simple_animal/hostile/construct/examine(mob/user)
	. = ..()

	var/msg = ""
	if(src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if(src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	. += msg

/mob/living/simple_animal/hostile/construct/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/hostile/construct/builder))
		if(health < maxHealth)
			adjustBruteLoss(-5)
			if(src != M)
				Beam(M,icon_state="sendbeam",time=4)
				M.visible_message("<span class='danger'>[M] repairs some of \the <b>[src]'s</b> dents.</span>", \
						   "<span class='cult'>You repair some of <b>[src]'s</b> dents, leaving <b>[src]</b> at <b>[health]/[maxHealth]</b> health.</span>")
			else
				M.visible_message("<span class='danger'>[M] repairs some of its own dents.</span>", \
						   "<span class='cult'>You repair some of your own dents, leaving you at <b>[M.health]/[M.maxHealth]</b> health.</span>")
		else
			if(src != M)
				to_chat(M, "<span class='cult'>You cannot repair <b>[src]'s</b> dents, as it has none!</span>")
			else
				to_chat(M, "<span class='cult'>You cannot repair your own dents, as you have none!</span>")
	else if(src != M)
		return ..()

/mob/living/simple_animal/hostile/construct/narsie_act()
	return

/mob/living/simple_animal/hostile/construct/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	return FALSE

/////////////////Juggernaut///////////////



/mob/living/simple_animal/hostile/construct/armoured
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A possessed suit of armour driven by the will of the restless dead"
	icon = 'icons/mob/mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 250
	health = 250
	response_harm   = "harmlessly punches"
	harm_intent_damage = 0
	obj_damage = 90
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "smashes their armoured gauntlet into"
	speed = 3
	environment_smash = 2
	attack_sound = 'sound/weapons/punch3.ogg'
	status_flags = 0
	construct_type = "juggernaut"
	mob_size = MOB_SIZE_LARGE
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/night_vision, /obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall)
	force_threshold = 11
	playstyle_string = "<b>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, \
						create shield walls, rip apart enemies and walls alike, and even deflect energy weapons.</b>"

/mob/living/simple_animal/hostile/construct/armoured/hostile //actually hostile, will move around, hit things
	AIStatus = AI_ON
	environment_smash = 1 //only token destruction, don't smash the cult wall NO STOP

/mob/living/simple_animal/hostile/construct/armoured/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
		var/reflectchance = 80 - round(P.damage/3)
		if(prob(reflectchance))
			if((P.damage_type == BRUTE || P.damage_type == BURN))
				adjustBruteLoss(P.damage * 0.5)
			visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s shell!</span>", \
							"<span class='userdanger'>The [P.name] gets reflected by [src]'s shell!</span>")

			P.reflect_back(src, list(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3))

			return -1 // complete projectile permutation

	return (..(P))



////////////////////////Wraith/////////////////////////////////////////////



/mob/living/simple_animal/hostile/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "A wicked bladed shell contraption piloted by a bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "floating"
	icon_living = "floating"
	maxHealth = 75
	health = 75
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	construct_type = "wraith"
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/night_vision, /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift)
	retreat_distance = 2 //AI wraiths will move in and out of combat
	playstyle_string = "<b>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</b>"

/mob/living/simple_animal/hostile/construct/wraith/hostile //actually hostile, will move around, hit things
	AIStatus = AI_ON

/////////////////////////////Artificer/////////////////////////



/mob/living/simple_animal/hostile/construct/builder
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining Cult armies."
	icon = 'icons/mob/mob.dmi'
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm = "viciously beats"
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "rams"
	environment_smash = 2
	retreat_distance = 10
	minimum_distance = 10 //AI artificers will flee like fuck
	attack_sound = 'sound/weapons/punch2.ogg'
	construct_type = "builder"
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/night_vision,
							/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/pylon,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone)

	playstyle_string = "<b>You are an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, \
						use magic missile, repair allied constructs (by clicking on them), \
						<i>and, most important of all,</i> create new constructs by producing soulstones to capture souls, \
						and shells to place those soulstones into.</b>"


/mob/living/simple_animal/hostile/construct/builder/Found(atom/A) //what have we found here?
	if(isconstruct(A)) //is it a construct?
		var/mob/living/simple_animal/hostile/construct/C = A
		if(C.health < C.maxHealth) //is it hurt? let's go heal it if it is
			return 1
		else
			return 0
	else
		return 0

/mob/living/simple_animal/hostile/construct/builder/CanAttack(atom/the_target)
	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return 0
	if(Found(the_target) || ..()) //If we Found it or Can_Attack it normally, we Can_Attack it as long as it wasn't invisible
		return 1 //as a note this shouldn't be added to base hostile mobs because it'll mess up retaliate hostile mobs

/mob/living/simple_animal/hostile/construct/builder/MoveToTarget(var/list/possible_targets)
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(isconstruct(L) && L.health >= L.maxHealth) //is this target an unhurt construct? stop trying to heal it
			LoseTarget()
			return 0
		if(L.health <= melee_damage_lower+melee_damage_upper) //ey bucko you're hurt as fuck let's go hit you
			retreat_distance = null
			minimum_distance = 1

/mob/living/simple_animal/hostile/construct/builder/Aggro()
	..()
	if(isconstruct(target)) //oh the target is a construct no need to flee
		retreat_distance = null
		minimum_distance = 1

/mob/living/simple_animal/hostile/construct/builder/LoseAggro()
	..()
	retreat_distance = initial(retreat_distance)
	minimum_distance = initial(minimum_distance)

/mob/living/simple_animal/hostile/construct/builder/hostile //actually hostile, will move around, hit things, heal other constructs
	AIStatus = AI_ON
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES //only token destruction, don't smash the cult wall NO STOP


/////////////////////////////Behemoth/////////////////////////


/mob/living/simple_animal/hostile/construct/behemoth
	name = "Behemoth"
	real_name = "Behemoth"
	desc = "The pinnacle of occult technology, Behemoths are the ultimate weapon in the Cult's arsenal."
	icon = 'icons/mob/mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 750
	health = 750
	speak_emote = list("rumbles")
	response_harm = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage_lower = 50
	melee_damage_upper = 50
	attacktext = "brutally crushes"
	speed = 5
	environment_smash = 2
	attack_sound = 'sound/weapons/punch4.ogg'
	force_threshold = 11
	construct_type = "behemoth"
	var/energy = 0
	var/max_energy = 1000

/mob/living/simple_animal/hostile/construct/behemoth/hostile //actually hostile, will move around, hit things
	AIStatus = AI_ON
	environment_smash = 1 //only token destruction, don't smash the cult wall NO STOP

/mob/living/simple_animal/hostile/construct/behemoth/Life(seconds, times_fired)
	weakened = 0
	return ..()


/////////////////////////////Harvester/////////////////////////

/mob/living/simple_animal/hostile/construct/harvester
	name = "Harvester"
	real_name = "Harvester"
	desc = "A harbinger of enlightenment. It'll be all over soon."
	icon = 'icons/mob/mob.dmi'
	icon_state = "harvester"
	icon_living = "harvester"
	maxHealth = 60
	health = 60
	melee_damage_lower = 1
	melee_damage_upper = 5
	attacktext = "prods"
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	attack_sound = 'sound/weapons/tap.ogg'
	construct_type = "harvester"
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/night_vision,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
							/obj/effect/proc_holder/spell/targeted/smoke/disable)
	retreat_distance = 2 //AI harvesters will move in and out of combat, like wraiths, but shittier
	playstyle_string = "<B>You are a Harvester. You are not strong, but your powers of domination will assist you in your role: \
						Bring those who still cling to this world of illusion back to the master so they may know Truth.</B>"


/mob/living/simple_animal/hostile/construct/harvester/Process_Spacemove(var/movement_dir = 0)
	return TRUE


/mob/living/simple_animal/hostile/construct/harvester/hostile //actually hostile, will move around, hit things
	AIStatus = AI_ON
	environment_smash = 1 //only token destruction, don't smash the cult wall NO STOP

///ui stuff

/mob/living/simple_animal/hostile/construct/armoured/update_health_hud()
	if(!client)
		return
	if(healths)
		switch(health)
			if(250 to INFINITY)
				healths.icon_state = "juggernaut_health0"
			if(208 to 249)
				healths.icon_state = "juggernaut_health1"
			if(167 to 207)
				healths.icon_state = "juggernaut_health2"
			if(125 to 166)
				healths.icon_state = "juggernaut_health3"
			if(84 to 124)
				healths.icon_state = "juggernaut_health4"
			if(42 to 83)
				healths.icon_state = "juggernaut_health5"
			if(1 to 41)
				healths.icon_state = "juggernaut_health6"
			else
				healths.icon_state = "juggernaut_health7"


/mob/living/simple_animal/hostile/construct/behemoth/update_health_hud()
	if(!client)
		return
	if(healths)
		switch(health)
			if(750 to INFINITY)
				healths.icon_state = "juggernaut_health0"
			if(625 to 749)
				healths.icon_state = "juggernaut_health1"
			if(500 to 624)
				healths.icon_state = "juggernaut_health2"
			if(375 to 499)
				healths.icon_state = "juggernaut_health3"
			if(250 to 374)
				healths.icon_state = "juggernaut_health4"
			if(125 to 249)
				healths.icon_state = "juggernaut_health5"
			if(1 to 124)
				healths.icon_state = "juggernaut_health6"
			else
				healths.icon_state = "juggernaut_health7"

/mob/living/simple_animal/hostile/construct/builder/update_health_hud()
	if(!client)
		return
	if(healths)
		switch(health)
			if(50 to INFINITY)
				healths.icon_state = "artificer_health0"
			if(42 to 49)
				healths.icon_state = "artificer_health1"
			if(34 to 41)
				healths.icon_state = "artificer_health2"
			if(26 to 33)
				healths.icon_state = "artificer_health3"
			if(18 to 25)
				healths.icon_state = "artificer_health4"
			if(10 to 17)
				healths.icon_state = "artificer_health5"
			if(1 to 9)
				healths.icon_state = "artificer_health6"
			else
				healths.icon_state = "artificer_health7"



/mob/living/simple_animal/hostile/construct/wraith/update_health_hud()
	if(!client)
		return
	if(healths)
		switch(health)
			if(75 to INFINITY)
				healths.icon_state = "wraith_health0"
			if(62 to 74)
				healths.icon_state = "wraith_health1"
			if(50 to 61)
				healths.icon_state = "wraith_health2"
			if(37 to 49)
				healths.icon_state = "wraith_health3"
			if(25 to 36)
				healths.icon_state = "wraith_health4"
			if(12 to 24)
				healths.icon_state = "wraith_health5"
			if(1 to 11)
				healths.icon_state = "wraith_health6"
			else
				healths.icon_state = "wraith_health7"


/mob/living/simple_animal/hostile/construct/harvester/update_health_hud()
	if(!client)
		return
	if(healths)
		switch(health)
			if(150 to INFINITY)
				healths.icon_state = "harvester_health0"
			if(125 to 149)
				healths.icon_state = "harvester_health1"
			if(100 to 124)
				healths.icon_state = "harvester_health2"
			if(75 to 99)
				healths.icon_state = "harvester_health3"
			if(50 to 74)
				healths.icon_state = "harvester_health4"
			if(25 to 49)
				healths.icon_state = "harvester_health5"
			if(1 to 24)
				healths.icon_state = "harvester_health6"
			else
				healths.icon_state = "harvester_health7"
