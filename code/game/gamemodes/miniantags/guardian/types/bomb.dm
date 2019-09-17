/mob/living/simple_animal/hostile/guardian/bomb
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_transfer = 0.6
	range = 13
	playstyle_string = "As an <b>Explosive</b> type, you have only moderate close combat abilities, but are capable of converting any adjacent item into a disguised bomb via alt click."
	magic_fluff_string = "..And draw the Scientist, master of explosive death."
	tech_fluff_string = "Boot sequence complete. Explosive modules active. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of stealthily booby trapping items."
	var/bomb_cooldown = 0
	var/default_bomb_cooldown = 20 SECONDS

/mob/living/simple_animal/hostile/guardian/bomb/Stat()
	..()
	if(statpanel("Status"))
		if(bomb_cooldown >= world.time)
			stat(null, "Bomb Cooldown Remaining: [max(round((bomb_cooldown - world.time)*0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/bomb/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(get_dist(get_turf(src), get_turf(A)) > 1)
		to_chat(src, "<span class='danger'>You're too far from [A] to disguise it as a bomb.</span>")
		return
	if(istype(A, /obj/))
		if(bomb_cooldown <= world.time && !stat)
			var/obj/item/guardian_bomb/B = new /obj/item/guardian_bomb(get_turf(A))
			to_chat(src, "<span class='danger'>Success! Bomb on [A] armed!</span>")
			if(summoner)
				to_chat(summoner, "<span class='warning'>Your guardian has primed [A] to explode!</span>")
			bomb_cooldown = world.time + default_bomb_cooldown
			B.spawner = src
			B.disguise (A)
		else
			to_chat(src, "<span class='danger'>Your power is on cooldown! You must wait another [max(round((bomb_cooldown - world.time)*0.1, 0.1), 0)] seconds before you can place next bomb.</span>")

/obj/item/guardian_bomb
	name = "bomb"
	desc = "You shouldn't be seeing this!"
	var/obj/stored_obj
	var/mob/living/spawner


/obj/item/guardian_bomb/proc/disguise(var/obj/A)
	A.forceMove(src)
	stored_obj = A
	opacity = A.opacity
	anchored = A.anchored
	density = A.density
	appearance = A.appearance
	dir = A.dir
	addtimer(CALLBACK(src, .proc/disable), 600)

/obj/item/guardian_bomb/proc/disable()
	stored_obj.forceMove(get_turf(src))
	if(spawner)
		to_chat(spawner, "<span class='danger'>Failure! Your trap on [stored_obj] didn't catch anyone this time.</span>")
	qdel(src)

/obj/item/guardian_bomb/proc/detonate(var/mob/living/user)
	if(!istype(user))
		return
	to_chat(user, "<span class='danger'>The [src] was boobytrapped!</span>")
	if(istype(spawner, /mob/living/simple_animal/hostile/guardian))
		var/mob/living/simple_animal/hostile/guardian/G = spawner
		if(user == G.summoner)
			to_chat(user, "<span class='danger'>You knew this because of your link with your guardian, so you smartly defuse the bomb.</span>")
			stored_obj.forceMove(get_turf(loc))
			qdel(src)
			return
	to_chat(spawner, "<span class='danger'>Success! Your trap on [src] caught [user]!</span>")
	stored_obj.forceMove(get_turf(loc))
	playsound(get_turf(src),'sound/effects/explosion2.ogg', 200, 1)
	user.ex_act(2)
	qdel(src)

/obj/item/guardian_bomb/attackby(obj/item/W, mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/pickup(mob/living/user)
	detonate(user)
	return FALSE // Disarm or blow up. No picking up

/obj/item/guardian_bomb/examine(mob/user)
	stored_obj.examine(user)
	if(get_dist(user,src) <= 2)
		to_chat(user, "<span class='notice'>Looks odd!</span>")
