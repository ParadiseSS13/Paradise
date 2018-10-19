/mob/living/simple_animal/hostile/asteroid/hivelord
	name = "hivelord"
	desc = "A truly alien creature, it is a mass of unknown organic material, constantly fluctuating. When attacking, pieces of it split off and attack in tandem with the original."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Hivelord"
	icon_living = "Hivelord"
	icon_aggro = "Hivelord_alert"
	icon_dead = "Hivelord_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_to_delay = 14
	ranged = 1
	vision_range = 5
	aggro_vision_range = 9
	idle_vision_range = 5
	speed = 3
	maxHealth = 75
	health = 75
	harm_intent_damage = 5
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "lashes out at"
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "falls right through the strange body of the"
	ranged_cooldown = 0
	ranged_cooldown_time = 20
	environment_smash = 0
	retreat_distance = 3
	minimum_distance = 3
	pass_flags = PASSTABLE
	loot = list(/obj/item/organ/internal/hivelord_core)
	var/brood_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood

/mob/living/simple_animal/hostile/asteroid/hivelord/OpenFire(the_target)
	if(world.time >= ranged_cooldown)
		var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/A = new brood_type(src.loc)
		A.admin_spawned = admin_spawned
		A.GiveTarget(target)
		A.friends = friends
		A.faction = faction.Copy()
		ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/asteroid/hivelord/AttackingTarget()
	OpenFire()

/mob/living/simple_animal/hostile/asteroid/hivelord/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	mouse_opacity = MOUSE_OPACITY_ICON

/obj/item/organ/internal/hivelord_core
	name = "hivelord remains"
	desc = "All that remains of a hivelord, it seems to be what allows it to break pieces of itself off without being hurt... its healing properties will soon become inert if not used quickly."
	icon_state = "roro core 2"
	flags = NOBLUDGEON
	slot = "hivecore"
	force = 0
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/inert = 0
	var/preserved = 0

/obj/item/organ/internal/hivelord_core/New()
	..()
	addtimer(CALLBACK(src, .proc/inert_check), 2400)

/obj/item/organ/internal/hivelord_core/proc/inert_check()
	if(owner)
		preserved(implanted = 1)
	else if(preserved)
		preserved()
	else
		go_inert()

/obj/item/organ/internal/hivelord_core/proc/preserved(implanted = 0)
	inert = FALSE
	preserved = TRUE
	update_icon()

	if(implanted)
		feedback_add_details("hivelord_core", "[type]|implanted")
	else
		feedback_add_details("hivelord_core", "[type]|stabilizer")


/obj/item/organ/internal/hivelord_core/proc/go_inert()
	inert = TRUE
	desc = "The remains of a hivelord that have become useless, having been left alone too long after being harvested."
	feedback_add_details("hivelord_core", "[src.type]|inert")
	update_icon()

/obj/item/organ/internal/hivelord_core/ui_action_click()
	owner.revive()
	qdel(src)

/obj/item/organ/internal/hivelord_core/on_life()
	..()
	if(owner.health < config.health_threshold_crit)
		ui_action_click()

/obj/item/organ/internal/hivelord_core/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(inert)
			to_chat(user, "<span class='notice'>[src] has become inert, its healing properties are no more.</span>")
			return
		else
			if(H.stat == DEAD)
				to_chat(user, "<span class='notice'>[src] are useless on the dead.</span>")
				return
			if(H != user)
				H.visible_message("[user] forces [H] to apply [src]... They quickly regenerate all injuries!")
				feedback_add_details("hivelord_core","[src.type]|used|other")
			else
				to_chat(user, "<span class='notice'>You start to smear [src] on yourself. It feels and smells disgusting, but you feel amazingly refreshed in mere moments.</span>")
				feedback_add_details("hivelord_core","[src.type]|used|self")
			playsound(src.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			H.revive()
			user.drop_item()
			qdel(src)
	..()

/obj/item/organ/internal/hivelord_core/prepare_eat()
	return null

/mob/living/simple_animal/hostile/asteroid/hivelordbrood
	name = "hivelord brood"
	desc = "A fragment of the original Hivelord, rallying behind its original. One isn't much of a threat, but..."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Hivelordbrood"
	icon_living = "Hivelordbrood"
	icon_aggro = "Hivelordbrood"
	icon_dead = "Hivelordbrood"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_to_delay = 1
	friendly = "buzzes near"
	vision_range = 10
	speed = 3
	maxHealth = 1
	health = 1
	flying = 1
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "slashes"
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "falls right through the strange body of the"
	environment_smash = 0
	pass_flags = PASSTABLE
	del_on_death = 1

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/New()
	..()
	addtimer(CALLBACK(src, .proc/death), 100)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood
	name = "blood brood"
	desc = "A living string of blood and alien materials."
	icon_state = "bloodbrood"
	icon_living = "bloodbrood"
	icon_aggro = "bloodbrood"
	attacktext = "pierces"
	color = "#C80000"

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/death()
	if(can_die() && loc)
		// Splash the turf we are on with blood
		reagents.reaction(get_turf(src))
	return ..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/New()
	create_reagents(30)
	..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/AttackingTarget()
	..()
	if(iscarbon(target))
		transfer_reagents(target, 1)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/attack_hand(mob/living/carbon/human/M)
	if("\ref[M]" in faction)
		reabsorb_host(M)
	else
		return ..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/attack_alien(mob/living/carbon/alien/humanoid/M)
	if("\ref[M]" in faction)
		reabsorb_host(M)
	else
		return ..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/proc/reabsorb_host(mob/living/carbon/C)
	C.visible_message("<span class='notice'>[src] is reabsorbed by [C]'s body.</span>", \
								"<span class='notice'>[src] is reabsorbed by your body.</span>")
	transfer_reagents(C)
	death()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/proc/transfer_reagents(mob/living/carbon/C, volume = 30)
	if(!reagents.total_volume)
		return

	volume = min(volume, reagents.total_volume)

	var/fraction = min(volume/reagents.total_volume, 1)
	reagents.reaction(C, INGEST, fraction)
	reagents.trans_to(C, volume)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/proc/link_host(mob/living/carbon/C)
	faction = list("\ref[src]", "\ref[C]") // Hostile to everyone except the host.
	C.transfer_blood_to(src, 30)
	color = mix_color_from_reagents(reagents.reagent_list)

// Legion
/mob/living/simple_animal/hostile/asteroid/hivelord/legion
	name = "legion"
	desc = "You can still see what was once a human under the shifting mass of corruption."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "legion"
	icon_living = "legion"
	icon_aggro = "legion"
	icon_dead = "legion"
	icon_gib = "syndicate_gib"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "lashes out at"
	speak_emote = list("echoes")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "bounces harmlessly off of"
	loot = list(/obj/item/organ/internal/hivelord_core/legion)
	brood_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion
	del_on_death = 1
	stat_attack = 1
	robust_searching = 1
	var/mob/living/carbon/human/stored_mob

/mob/living/simple_animal/hostile/asteroid/hivelord/legion/death(gibbed)
	if(can_die())
		visible_message("<span class='warning'>The skulls on [src] wail in anger as they flee from their dying host!</span>")
		var/turf/T = get_turf(src)
		if(T)
			if(stored_mob)
				stored_mob.forceMove(get_turf(src))
				stored_mob = null
			else
				new /obj/effect/mob_spawn/human/corpse/charredskeleton(T)
	// due to `del_on_death`
	return ..(gibbed)


/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion
	name = "legion"
	desc = "One of many."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_head"
	icon_living = "legion_head"
	icon_aggro = "legion_head"
	icon_dead = "legion_head"
	icon_gib = "syndicate_gib"
	friendly = "buzzes near"
	vision_range = 10
	maxHealth = 1
	health = 5
	harm_intent_damage = 5
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites"
	speak_emote = list("echoes")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "is shrugged off by"
	pass_flags = PASSTABLE
	del_on_death = 1
	stat_attack = 1
	robust_searching = 1

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/Life(seconds, times_fired)
	if(isturf(loc))
		for(var/mob/living/carbon/human/H in view(src,1)) //Only for corpse right next to/on same tile
			if(H.stat == UNCONSCIOUS)
				infest(H)
	..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/proc/infest(mob/living/carbon/human/H)
	visible_message("<span class='warning'>[name] burrows into the flesh of [H]!</span>")
	var/mob/living/simple_animal/hostile/asteroid/hivelord/legion/L = new(H.loc)
	visible_message("<span class='warning'>[L] staggers to their feet!</span>")
	H.death()
	H.adjustBruteLoss(1000)
	L.stored_mob = H
	H.forceMove(L)
	qdel(src)

/obj/item/organ/internal/hivelord_core/legion
	name = "legion's soul"
	desc = "A strange rock that still crackles with power... its \
		healing properties will soon become inert if not used quickly."
	icon_state = "legion_soul"

/obj/item/organ/internal/hivelord_core/legion/New()
	..()
	update_icon()

/obj/item/organ/internal/hivelord_core/legion/update_icon()
	icon_state = inert ? "legion_soul_inert" : "legion_soul"
	overlays.Cut()
	if(!inert && !preserved)
		overlays += image(icon, "legion_soul_crackle")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/internal/hivelord_core/legion/go_inert()
	. = ..()
	desc = "[src] has become inert, it crackles no more and is useless for \
		healing injuries."

/obj/item/organ/internal/hivelord_core/legion/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. It no longer crackles with power, but it's healing properties are preserved indefinitely."

/obj/item/legion_skull
	name = "legion's head"
	desc = "The once living, now empty eyes of the former human's skull cut deep into your soul."
	icon = 'icons/obj/mining.dmi'
	icon_state = "skull"


/obj/effect/mob_spawn/human/corpse/charredskeleton
	name = "charred skeletal remains"
	burn_damage = 1000
	mob_name = "ashen skeleton"
	mob_gender = NEUTER
	husk = FALSE
	mob_species = /datum/species/skeleton
	mob_color = "#454545"
