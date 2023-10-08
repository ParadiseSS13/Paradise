/mob/living/simple_animal/hostile/mushroom
	name = "walking mushroom"
	desc = "It's a massive mushroom... with legs?"
	icon_state = "mushroom_color"
	icon_living = "mushroom_color"
	icon_dead = "mushroom_dead"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	speak_chance = 0
	turns_per_move = 1
	maxHealth = 10
	health = 10
	butcher_results = list(/obj/item/reagent_containers/food/snacks/hugemushroomslice = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	obj_damage = 0
	melee_damage_lower = 1
	melee_damage_upper = 1
	attack_same = 2 // this is usually a bool, but mushrooms are a special case
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("mushroom", "jungle")
	environment_smash = 0
	stat_attack = DEAD
	mouse_opacity = MOUSE_OPACITY_ICON
	speed = 1
	ventcrawler = 2
	robust_searching = TRUE
	speak_emote = list("squeaks")
	deathmessage = "fainted"
	var/powerlevel = 0 //Tracks our general strength level gained from eating other shrooms
	var/bruised = 0 //If someone tries to cheat the system by attacking a shroom to lower its health, punish them so that it wont award levels to shrooms that eat it
	var/recovery_cooldown = 0 //So you can't repeatedly revive it during a fight
	var/faint_ticker = 0 //If we hit three, another mushroom's gonna eat us
	var/image/cap_living = null //Where we store our cap icons so we dont generate them constantly to update our icon
	var/image/cap_dead = null

/mob/living/simple_animal/hostile/mushroom/examine(mob/user)
	. = ..()
	if(health >= maxHealth)
		. += "<span class='info'>It looks healthy.</span>"
	else
		. += "<span class='info'>It looks like it's been roughed up.</span>"

/mob/living/simple_animal/hostile/mushroom/Life(seconds, times_fired)
	..()
	if(!stat)//Mushrooms slowly regenerate if conscious, for people who want to save them from being eaten
		adjustBruteLoss(-2)

/mob/living/simple_animal/hostile/mushroom/Initialize(mapload)  //Makes every shroom a little unique
	. = ..()
	melee_damage_lower += rand(3, 5)
	melee_damage_upper += rand(10,20)
	maxHealth += rand(40,60)
	move_to_delay = rand(3,11)
	var/cap_color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	cap_living = image('icons/mob/animal.dmi',icon_state = "mushroom_cap")
	cap_dead = image('icons/mob/animal.dmi',icon_state = "mushroom_cap_dead")
	cap_living.color = cap_color
	cap_dead.color = cap_color
	UpdateMushroomCap()
	health = maxHealth

/mob/living/simple_animal/hostile/mushroom/CanAttack(atom/the_target) // Mushroom-specific version of CanAttack to handle stupid attack_same = 2 crap so we don't have to do it for literally every single simple_animal/hostile because this shit never gets spawned
	if(!the_target || isturf(the_target) || istype(the_target, /atom/movable/lighting_object))
		return FALSE

	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(isliving(the_target))
		var/mob/living/L = the_target

		if(!faction_check_mob(L) && attack_same == 2)
			return FALSE
		if(L.stat > stat_attack)
			return FALSE

		return TRUE

	return FALSE

/mob/living/simple_animal/hostile/mushroom/adjustHealth(amount, updating_health = TRUE)//Possibility to flee from a fight just to make it more visually interesting
	if(!retreat_distance && prob(33))
		retreat_distance = 5
		addtimer(CALLBACK(src, PROC_REF(stop_retreat)), 30)
	. = ..()

/mob/living/simple_animal/hostile/mushroom/proc/stop_retreat()
	retreat_distance = null

/mob/living/simple_animal/hostile/mushroom/attack_animal(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/mushroom) && stat == DEAD)
		var/mob/living/simple_animal/hostile/mushroom/M = L
		if(faint_ticker < 2)
			M.visible_message("[M] chews a bit on [src].")
			faint_ticker++
			return TRUE
		M.visible_message("<span class='warning'>[M] devours [src]!</span>")
		var/level_gain = (powerlevel - M.powerlevel)
		if(level_gain >= -1 && !bruised && !M.ckey)//Player shrooms can't level up to become robust gods.
			if(level_gain < 1)//So we still gain a level if two mushrooms were the same level
				level_gain = 1
			M.LevelUp(level_gain)
		M.adjustBruteLoss(-M.maxHealth)
		qdel(src)
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/mushroom/revive()
	..()
	icon_state = "mushroom_color"
	UpdateMushroomCap()

/mob/living/simple_animal/hostile/mushroom/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	UpdateMushroomCap()

/mob/living/simple_animal/hostile/mushroom/proc/UpdateMushroomCap()
	overlays.Cut()
	if(health == 0)
		overlays += cap_dead
	else
		overlays += cap_living

/mob/living/simple_animal/hostile/mushroom/proc/Recover()
	visible_message("<span class='notice'>[src] slowly begins to recover.</span>")
	faint_ticker = 0
	revive()
	UpdateMushroomCap()
	recovery_cooldown = 1
	spawn(300)
		recovery_cooldown = 0

/mob/living/simple_animal/hostile/mushroom/proc/LevelUp(level_gain)
	if(powerlevel <= 9)
		powerlevel += level_gain
		if(prob(25))
			melee_damage_lower += (level_gain * rand(1,5))
		else
			melee_damage_upper += (level_gain * rand(1,5))
		maxHealth += (level_gain * rand(1,5))
	adjustBruteLoss(-maxHealth) //They'll always heal, even if they don't gain a level, in case you want to keep this shroom around instead of harvesting it

/mob/living/simple_animal/hostile/mushroom/proc/Bruise()
	if(!bruised && !stat)
		src.visible_message("<span class='notice'>[src] was bruised!</span>")
		bruised = 1

/mob/living/simple_animal/hostile/mushroom/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/grown/mushroom))
		if(stat == DEAD && !recovery_cooldown)
			Recover()
			qdel(I)
		else
			to_chat(user, "<span class='notice'>[src] won't eat it!</span>")
		return
	if(I.force)
		Bruise()
	..()

/mob/living/simple_animal/hostile/mushroom/attack_hand(mob/living/carbon/human/M as mob)
	..()
	if(M.a_intent == INTENT_HARM)
		Bruise()

/mob/living/simple_animal/hostile/mushroom/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	..()
	if(isitem(AM))
		var/obj/item/T = AM
		if(T.throwforce)
			Bruise()

/mob/living/simple_animal/hostile/mushroom/bullet_act()
	..()
	Bruise()

/mob/living/simple_animal/hostile/mushroom/harvest()
	var/counter
	for(counter=0, counter<=powerlevel, counter++)
		var/obj/item/reagent_containers/food/snacks/hugemushroomslice/S = new /obj/item/reagent_containers/food/snacks/hugemushroomslice(src.loc)
		S.reagents.add_reagent("psilocybin", powerlevel)
		S.reagents.add_reagent("omnizine", powerlevel)
		S.reagents.add_reagent("synaptizine", powerlevel)
	qdel(src)
