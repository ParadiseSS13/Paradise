/obj/structure/closet/crate/necropolis/dragon
	name = "dragon chest"

/obj/structure/closet/crate/necropolis/dragon/New()
	..()
	var/loot = rand(1,4)
	switch(loot)
		if(1)
			new /obj/item/melee/ghost_sword(src)
		if(2)
			new /obj/item/lava_staff(src)
		if(3)
			new /obj/item/spellbook/oneuse/sacredflame(src)
			new /obj/item/gun/magic/wand/fireball(src)
		if(4)
			new /obj/item/dragons_blood(src)


/obj/structure/closet/crate/necropolis/dragon/crusher
	name = "firey dragon chest"

/obj/structure/closet/crate/necropolis/dragon/crusher/New()
	..()
	new /obj/item/crusher_trophy/tail_spike(src)


// Spectral Blade

/obj/item/melee/ghost_sword
	name = "spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon_state = "spectral"
	item_state = "spectral"
	flags = CONDUCT
	sharp = 1
	w_class = WEIGHT_CLASS_BULKY
	force = 1
	throwforce = 1
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/melee/ghost_sword/New()
	..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.invisibility = initial(G.invisibility)
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list -= src
	. = ..()

/obj/item/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, "You just recently called out for aid. You don't want to annoy the spirits.")
		return
	to_chat(user, "You call out for aid, attempting to summon spirits to your side.")

	notify_ghosts("[user] is raising [user.p_their()] [src], calling for your help!", enter_link="<a href=?src=[UID()];follow=1>(Click to help)</a>", source = user, action = NOTIFY_FOLLOW)

	summon_cooldown = world.time + 600

/obj/item/melee/ghost_sword/Topic(href, href_list)
	if(href_list["follow"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/item/melee/ghost_sword/process()
	ghost_check()

/obj/item/melee/ghost_sword/proc/ghost_check()
	var/ghost_counter = 0
	var/turf/T = get_turf(src)
	var/list/contents = T.GetAllContents()
	var/mob/dead/observer/current_spirits = list()

	for(var/mob/dead/observer/O in GLOB.player_list)
		if((O.following in contents))
			ghost_counter++
			O.invisibility = 0
			current_spirits |= O

	for(var/mob/dead/observer/G in spirits - current_spirits)
		G.invisibility = initial(G.invisibility)

	spirits = current_spirits

	return ghost_counter

/obj/item/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = ghost_check()

	force = Clamp((ghost_counter * 4), 0, 75)
	user.visible_message("<span class='danger'>[user] strikes with the force of [ghost_counter] vengeful spirits!</span>")
	..()

/obj/item/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/ghost_counter = ghost_check()
	final_block_chance += Clamp((ghost_counter * 5), 0, 75)
	owner.visible_message("<span class='danger'>[owner] is protected by a ring of [ghost_counter] ghosts!</span>")
	return ..()

// Blood

/obj/item/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/H = user
	var/random = rand(1,3)

	switch(random)
		if(1)
			to_chat(user, "<span class='danger'>Your flesh begins to melt! Miraculously, you seem fine otherwise.</span>")
			H.set_species(/datum/species/skeleton)
		if(2)
			to_chat(user, "<span class='danger'>Power courses through you! You can now shift your form at will.")
			if(user.mind)
				var/obj/effect/proc_holder/spell/targeted/shapeshift/dragon/D = new
				user.mind.AddSpell(D)
		if(3)
			to_chat(user, "<span class='danger'>You feel like you could walk straight through lava now.</span>")
			H.weather_immunities |= "lava"

	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)

/datum/disease/transformation/dragon
	name = "dragon transformation"
	cure_text = "nothing"
	cures = list("adminordrazine")
	agent = "dragon's blood"
	desc = "What do dragons have to do with Space Station 13?"
	stage_prob = 20
	severity = BIOHAZARD
	visibility_flags = 0
	stage1	= list("Your bones ache.")
	stage2	= list("Your skin feels scaley.")
	stage3	= list("<span class='danger'>You have an overwhelming urge to terrorize some peasants.</span>", "<span class='danger'>Your teeth feel sharper.</span>")
	stage4	= list("<span class='danger'>Your blood burns.</span>")
	stage5	= list("<span class='danger'>You're a fucking dragon. However, any previous allegiances you held still apply. It'd be incredibly rude to eat your still human friends for no reason.</span>")
	new_form = /mob/living/simple_animal/hostile/megafauna/dragon/lesser

//Lava Staff

/obj/item/lava_staff
	name = "staff of lava"
	desc = "The ability to fill the emergency shuttle with lava. What more could you want out of life?"
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = SLOT_BACK
	item_state = "staffofstorms"
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/turf_type = /turf/simulated/floor/plating/lava/smooth
	var/transform_string = "lava"
	var/reset_turf_type = /turf/simulated/floor/plating/asteroid/basalt
	var/reset_string = "basalt"
	var/create_cooldown = 100
	var/create_delay = 30
	var/reset_cooldown = 50
	var/timer = 0
	var/banned_turfs

/obj/item/lava_staff/New()
	. = ..()
	banned_turfs = typecacheof(list(/turf/space/transit, /turf/unsimulated))

/obj/item/lava_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(timer > world.time)
		return

	if(is_type_in_typecache(target, banned_turfs))
		return

	if(target in view(user.client.view, get_turf(user)))

		var/turf/simulated/T = get_turf(target)
		if(!istype(T))
			return
		if(!istype(T, turf_type))
			var/obj/effect/temp_visual/lavastaff/L = new /obj/effect/temp_visual/lavastaff(T)
			L.alpha = 0
			animate(L, alpha = 255, time = create_delay)
			user.visible_message("<span class='danger'>[user] points [src] at [T]!</span>")
			timer = world.time + create_delay + 1
			if(do_after(user, create_delay, target = T))
				user.visible_message("<span class='danger'>[user] turns \the [T] into [transform_string]!</span>")
				message_admins("[key_name_admin(user)] fired the lava staff at [get_area(target)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>).")
				log_game("[key_name(user)] fired the lava staff at [get_area(target)] ([T.x], [T.y], [T.z]).")
				T.TerraformTurf(turf_type, keep_icon = FALSE)
				timer = world.time + create_cooldown
				qdel(L)
			else
				timer = world.time
				qdel(L)
				return
		else
			user.visible_message("<span class='danger'>[user] turns \the [T] into [reset_string]!</span>")
			T.TerraformTurf(reset_turf_type, keep_icon = FALSE)
			timer = world.time + reset_cooldown
		playsound(T,'sound/magic/fireball.ogg', 200, 1)

/obj/effect/temp_visual/lavastaff
	icon_state = "lavastaff_warn"
	duration = 50
