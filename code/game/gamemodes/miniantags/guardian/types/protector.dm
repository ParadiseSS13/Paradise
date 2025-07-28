#define LEFT_SHIELD FALSE
#define RIGHT_SHEILD TRUE

/mob/living/simple_animal/hostile/guardian/protector
	range = 15 //worse for it due to how it leashes
	damage_transfer = 0.4
	playstyle_string = "As a <b>Protector</b> type you cause your summoner to leash to you instead of you leashing to them and have two modes; Combat Mode, where you do and take medium damage, and Protection Mode, where you do and take almost no damage, but move slightly slower, as well as have a protective shield. Nobody can walk through your shield, but you can still move your shield through them."
	magic_fluff_string = "..And draw the Guardian, a stalwart protector that never leaves the side of its charge."
	tech_fluff_string = "Boot sequence complete. Protector modules loaded. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, ready to defend you."
	var/toggle = FALSE
	/// The shields the guardian has, and brings with it as it moves
	var/list/connected_shields = list()

/mob/living/simple_animal/hostile/guardian/protector/ex_act(severity)
	if(severity == EXPLODE_DEVASTATE)
		adjustBruteLoss(200) //if in protector mode, will do 20 damage and not actually necessarily kill the summoner
	else
		..()
	if(toggle)
		visible_message("<span class='danger'>The explosion glances off [src]'s energy shielding!</span>")


/mob/living/simple_animal/hostile/guardian/protector/Manifest()
	. = ..()
	if(toggle && cooldown < world.time)
		var/dir_left = turn(dir, -90)
		var/dir_right = turn(dir, 90)
		connected_shields += new /obj/effect/guardianshield(get_step(src, dir_left), src, FALSE)
		connected_shields += new /obj/effect/guardianshield(get_step(src, dir_right), src, TRUE)

/mob/living/simple_animal/hostile/guardian/protector/Recall(forced)
	. = ..()
	if(cooldown > world.time && !forced)
		QDEL_LIST_CONTENTS(connected_shields)

/mob/living/simple_animal/hostile/guardian/protector/Move()
	. = ..()
	for(var/obj/effect/guardianshield/G in connected_shields)
		var/dir_chosen
		if(G.shield_orientation)
			dir_chosen = turn(dir, 90)
		else
			dir_chosen = turn(dir, -90)
		G.forceMove(get_step(src, dir_chosen))

/mob/living/simple_animal/hostile/guardian/protector/ToggleMode()
	if(cooldown > world.time)
		return 0
	cooldown = world.time + 10
	if(toggle)
		overlays.Cut()
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		obj_damage = initial(obj_damage)
		move_resist = initial(move_resist)
		speed = initial(speed)
		damage_transfer = 0.4
		to_chat(src, "<span class='danger'>You switch to combat mode.</span>")
		toggle = FALSE
		QDEL_LIST_CONTENTS(connected_shields)
	else
		if(!isturf(loc))
			return
		if(get_turf(summoner) == get_turf(src))
			to_chat(src, "<span class='warning'>You cannot deploy your shield while on your host!</span>")
			return
		var/icon/shield_overlay = icon('icons/effects/effects.dmi', "shield-grey")
		shield_overlay *= name_color
		overlays.Add(shield_overlay)
		melee_damage_lower = 2
		melee_damage_upper = 2
		obj_damage = 6 //40/7.5 rounded up, we don't want a protector guardian 2 shotting blob tiles while taking 5% damage, thats just silly.
		move_resist = MOVE_FORCE_STRONG
		speed = 1
		damage_transfer = 0.1 //damage? what's damage?
		to_chat(src, "<span class='danger'>You switch to protection mode.</span>")
		toggle = TRUE
		var/dir_left = turn(dir, -90)
		var/dir_right = turn(dir, 90)
		connected_shields += new /obj/effect/guardianshield(get_step(src, dir_left), src, LEFT_SHIELD)
		connected_shields += new /obj/effect/guardianshield(get_step(src, dir_right), src, RIGHT_SHEILD)

/mob/living/simple_animal/hostile/guardian/protector/snapback() //snap to what? snap to the guardian!
	// If the summoner dies instantly, the summoner's ghost may be drawn into null space as the protector is deleted. This check should prevent that.
	if(summoner && loc && summoner.loc)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			if(iseffect(summoner.loc))
				to_chat(src, "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]!</span>")
				visible_message("<span class='danger'>[src] jumps back to its user.</span>")
				Recall(TRUE)
			else
				to_chat(summoner, "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from <b>[src]</b>!</span>")
				summoner.visible_message("<span class='danger'>[summoner] jumps back to [summoner.p_their()] protector.</span>")
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(summoner))
				summoner.forceMove(get_turf(src))
				new /obj/effect/temp_visual/guardian/phase(get_turf(summoner))//Protector

/mob/living/simple_animal/hostile/guardian/protector/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(toggle && isliving(mover)) //No crawling under a protector
		return FALSE

/mob/living/simple_animal/hostile/guardian/protector/Destroy()
	QDEL_LIST_CONTENTS(connected_shields)
	return ..()

/obj/effect/guardianshield
	name = "guardian's shield"
	desc = "A guardian's defensive wall."
	icon_state = "shield-grey"
	can_be_hit = TRUE
	var/mob/living/simple_animal/hostile/guardian/protector/linked_guardian
	///Is the guardians shield the left or right shield?
	var/shield_orientation = LEFT_SHIELD

/obj/effect/guardianshield/Initialize(mapload, mob/living/simple_animal/hostile/guardian/protector/creator, left_or_right)
	. = ..()
	linked_guardian = creator
	color = linked_guardian.name_color
	shield_orientation = left_or_right

/obj/effect/guardianshield/CanPass(atom/movable/mover, border_dir)
	if(mover == linked_guardian)
		return TRUE
	return FALSE

/obj/effect/guardianshield/bullet_act(obj/item/projectile/P)
	if(!P)
		return
	linked_guardian.apply_damage(P.damage, P.damage_type)
	P.on_hit(src, 0)
	return FALSE

/obj/effect/guardianshield/attack_by(obj/item/attacking, mob/user, params)
	if(..() || !attacking.force)
		return FINISH_ATTACK

	user.visible_message("<span class='danger'>[user] has hit [src] with [attacking]!</span>", "<span class='danger'>You hit [src] with [attacking]!</span>")
	linked_guardian.apply_damage(attacking.force, attacking.damtype)
	return FINISH_ATTACK

/obj/effect/guardianshield/Destroy()
	linked_guardian = null
	return ..()


#undef LEFT_SHIELD
#undef RIGHT_SHEILD
