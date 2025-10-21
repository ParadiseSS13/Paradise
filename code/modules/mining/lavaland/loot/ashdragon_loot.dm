// Spectral Blade

/obj/item/melee/ghost_sword
	name = "spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage."
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "spectral"
	flags = CONDUCT
	sharp = TRUE
	w_class = WEIGHT_CLASS_BULKY
	force = 1
	throwforce = 1
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")
	flags_2 = RANDOM_BLOCKER_2
	var/summon_cooldown = 0
	/// List of wisps we have active, for cleanup purposes in case a ghost gets randomly deleted.
	var/list/obj/effect/wisp/ghost/orbs
	/// List of ghosts currently orbiting us.
	var/list/mob/dead/observer/ghosts
	var/datum/component/parry/parry_comp

/obj/item/melee/ghost_sword/Initialize(mapload)
	. = ..()
	ghosts = list()
	orbs = list()
	register_signals(src)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	GLOB.poi_list |= src
	parry_comp = AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 1, _parryable_attack_types = NON_PROJECTILE_ATTACKS, _parry_cooldown = (10 / 3) SECONDS)

/obj/item/melee/ghost_sword/proc/update_parry(orbs)
	var/counter = length(orbs)
	// scaling stamina coeff. 0 ghosts being 1, 20 being 0.5
	parry_comp.stamina_coefficient = 1 - clamp(counter * 0.025, 0, 0.5)
	// scaling uptime. 0 ghosts being 30%, 20 ghosts being 70%
	parry_comp.parry_cooldown = ((10 / 3) - clamp(counter * 0.095, 0, 1.9)) SECONDS

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in ghosts)
		remove_ghost(G)
	// if there are any orbs left (possibly detached from ghosts) ensure they don't stick around
	for(var/spirit as anything in orbs)
		qdel(spirit)
	remove_signals(src)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	GLOB.poi_list -= src
	. = ..()

/obj/item/melee/ghost_sword/examine()
	. = ..()
	if(length(orbs))
		. += "It appears to pulse with the power of [length(orbs)] vengeful spirit\s!"
	else
		. += "It glows weakly."

/obj/item/melee/ghost_sword/attack_self__legacy__attackchain(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, "You just recently called out for aid. You don't want to annoy the spirits.")
		return
	to_chat(user, "You call out for aid, attempting to summon spirits to your side.")

	notify_ghosts("[user] is raising [user.p_their()] [src], calling for your help!", enter_link="<a href=byond://?src=[UID()];follow=1>(Click to help)</a>", source = user, action = NOTIFY_FOLLOW)

	summon_cooldown = world.time + 600

/obj/item/melee/ghost_sword/Topic(href, href_list)
	if(href_list["follow"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.manual_follow(src)

/obj/item/melee/ghost_sword/proc/add_ghost(atom/movable/orbited, atom/orbiter)
	SIGNAL_HANDLER	// COMSIG_ATOM_ORBIT_BEGIN
	var/mob/dead/observer/ghost = orbiter
	if(!istype(ghost) || !isobserver(orbiter) || (ghost in ghosts))
		return

	if(!ismob(loc))
		// Don't count any new ghosts while the sword isn't being held in hand
		// they'll get added to spirits (and turned visible) when the sword enters a mob's hand then
		return

	register_signals(ghost) // Pull in any ghosts that may be orbiting other ghosts


	var/obj/effect/wisp/ghost/orb = new(src)
	orb.color = ghost.get_runechat_color()
	orb.alpha = 128
	orb.orbit(src, clockwise = FALSE)
	ghosts[ghost] = orb
	orbs.Add(orb)

	update_parry(orbs)
	// if a ghost gets deleted, the orb cleans itself up
	// which then passes the torch to us to clean ourselves up
	RegisterSignal(orb, COMSIG_PARENT_QDELETING, PROC_REF(on_orb_qdel))

/obj/item/melee/ghost_sword/proc/remove_ghost(atom/movable/orbited, atom/orbiter)
	SIGNAL_HANDLER	// COMSIG_ATOM_ORBIT_STOP

	var/mob/dead/observer/ghost = orbiter

	if(!istype(ghost) || !(ghost in ghosts))
		return

	remove_signals(ghost)

	var/obj/effect/wisp/ghost/attached_orb = ghosts[ghost]
	attached_orb.stop_orbit()
	qdel(attached_orb)
	ghosts -= ghost

/obj/item/melee/ghost_sword/proc/remove_signals(atom/A)
	UnregisterSignal(A, COMSIG_ATOM_ORBIT_STOP)
	UnregisterSignal(A, COMSIG_ATOM_ORBIT_BEGIN)

/obj/item/melee/ghost_sword/proc/register_signals(atom/A)
	RegisterSignal(A, COMSIG_ATOM_ORBIT_BEGIN, PROC_REF(add_ghost), override = TRUE)
	RegisterSignal(A, COMSIG_ATOM_ORBIT_STOP, PROC_REF(remove_ghost), override = TRUE)

/**
 *  When moving into something's contents
 */
/obj/item/melee/ghost_sword/proc/on_move(atom/movable/this, atom/old_loc, direction)
	SIGNAL_HANDLER  // COMSIG_MOVABLE_MOVED
	// We should only really care about the wielder of the sword and the sword itself when checking ghosts

	if(ismob(old_loc))
		remove_signals(old_loc)
		for(var/mob/dead/observer/orbiter in ghosts)
			remove_ghost(src, orbiter)

	if(ismob(loc))
		register_signals(loc)
		// Add ghosts directly orbiting
		for(var/mob/dead/observer/orbiter in get_orbiters_up_hierarchy(recursive = TRUE))
			add_ghost(src, orbiter)

// clean up wisps
/obj/item/melee/ghost_sword/proc/on_orb_qdel(obj/effect/wisp/ghost/orb)
	SIGNAL_HANDLER  // COMSIG_PARENT_QDELETING
	orbs -= orb
	update_parry(orbs)
	for(var/ghost in ghosts)
		if(ghosts[ghost] == orb)
			ghosts -= ghost
			break


/obj/item/melee/ghost_sword/attack__legacy__attackchain(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = length(orbs)

	force = clamp((ghost_counter * 3), 0, 50)
	user.visible_message("<span class='danger'>[user] strikes with the force of [ghost_counter] vengeful spirit\s!</span>")
	..()

/obj/effect/wisp/ghost
	name = "mischievous wisp"
	desc = "A wisp that seems to want to get up to shenanigans. It often seems disappointed, for some reason."
	light_range = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/wisp/ghost/Initialize(mapload, mob/dead/observer/ghost)
	. = ..()
	RegisterSignal(ghost, COMSIG_PARENT_QDELETING, PROC_REF(on_ghost_qdel))

/obj/effect/wisp/ghost/proc/on_ghost_qdel(mob/dead/observer/ghost)
	SIGNAL_HANDLER  // COMSIG_PARENT_QDELETING
	stop_orbit()
	// we only live as long as our attached ghost
	qdel(src)


// Blood

/obj/item/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/dragons_blood/attack_self__legacy__attackchain(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/H = user
	var/random = rand(1, 3)

	switch(random)
		if(1)
			to_chat(user, "<span class='danger'>Your flesh begins to melt! Miraculously, you seem fine otherwise.</span>")
			H.set_species(/datum/species/skeleton)
		if(2)
			to_chat(user, "<span class='danger'>Power courses through you! You can now shift your form at will.")
			if(user.mind)
				var/datum/spell/shapeshift/dragon/D = new
				user.mind.AddSpell(D)
		if(3)
			to_chat(user, "<span class='danger'>You feel like you could walk straight through lava now.</span>")
			H.weather_immunities |= "lava"

	playsound(user.loc, 'sound/items/drink.ogg', rand(10, 50), 1)
	qdel(src)

/datum/disease/transformation/dragon
	name = "dragon transformation"
	cure_text = "nothing"
	cures = list("adminordrazine")
	agent = "dragon's blood"
	desc = "What do dragons have to do with Space Station 13?"
	stage_prob = 20
	stage1	= list("Your bones ache.")
	stage2	= list("Your skin feels scaley.")
	stage3	= list("<span class='danger'>You have an overwhelming urge to terrorize some peasants.</span>", "<span class='danger'>Your teeth feel sharper.</span>")
	stage4	= list("<span class='danger'>Your blood burns.</span>")
	stage5	= list("<span class='danger'>You're a fucking dragon. However, any previous allegiances you held still apply. It'd be incredibly rude to eat your still human friends for no reason.</span>")
	new_form = /mob/living/simple_animal/hostile/megafauna/dragon/lesser

//Lava Staff

/obj/item/lava_staff
	name = "staff of lava"
	desc = "The power of fire and rocks in your hands!"
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "lavastaff"
	lefthand_file = 'icons/mob/inhands/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/staves_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	needs_permit = TRUE
	var/turf_type = /turf/simulated/floor/lava
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
	banned_turfs = typecacheof(list(/turf/space/transit, /turf/simulated/wall, /turf/simulated/mineral))

/obj/item/lava_staff/attack__legacy__attackchain(mob/target, mob/living/user)
	if(!cigarette_lighter_act(user, target))
		return ..()

/obj/item/lava_staff/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(target == user)
		user.visible_message(
			"<span class='notice'>[user] holds the tip of [src] near [user.p_their()] [cig.name] until it is suddenly set alight.</span>",
			"<span class='notice'>You hold the tip of [src] near [cig] until it is suddenly set alight.</span>",
		)
	else
		user.visible_message(
			"<span class='notice'>[user] points [src] at [target] until [target.p_their()] [cig.name] is suddenly set alight.</span>",
			"<span class='notice'>You point [src] at [target] until [target.p_their()] [cig] is suddenly set alight.</span>",
		)
	cig.light(user, target)
	return TRUE

/obj/item/lava_staff/afterattack__legacy__attackchain(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(timer > world.time)
		return

	if(is_type_in_typecache(target, banned_turfs))
		return

	if(!is_mining_level(user.z) && !iswizard(user)) //Will only spawn a few sparks if not on mining z level, unless a wizard uses it.
		timer = world.time + create_delay + 1
		user.visible_message("<span class='danger'>[user]'s [src] malfunctions!</span>")
		do_sparks(5, FALSE, user)
		return

	if(target in view(user.client.maxview(), get_turf(user)))

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
				message_admins("[key_name_admin(user)] fired the lava staff at [get_area(target)] (<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>).")
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
