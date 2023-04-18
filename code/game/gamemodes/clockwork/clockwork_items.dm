// A Clockwork slab. Ratvar's tool to cast most of essential spells.
/obj/item/clockwork/clockslab
	name = "Clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	icon = 'icons/obj/clockwork.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "clock_slab"
	w_class = WEIGHT_CLASS_SMALL
	var/list/plush_colors = list("red fox plushie" = "redfox", "black fox plushie" = "blackfox", "blue fox plushie" = "bluefox",
								"orange fox plushie" = "orangefox", "corgi plushie" = "corgi", "black cat plushie" = "blackcat",
								"deer plushie" = "deer", "octopus plushie" = "loveable", "facehugger plushie" = "huggable")
	var/plushy = FALSE

/obj/item/clockwork/clockslab/Initialize(mapload)
	. = ..()
	enchants = GLOB.clockslab_spells

/obj/item/clockwork/clockslab/update_icon()
	update_overlays()
	..()

/obj/item/clockwork/clockslab/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "clock_slab_overlay_[enchant_type]"

/obj/item/clockwork/clockslab/attack(mob/M as mob, mob/user as mob)
	if(plushy)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 20, 1)	// Play the whoosh sound in local area
	return ..()

/obj/item/clockwork/clockslab/attack_self(mob/user)
	. = ..()
	if(plushy)
		var/cuddle_verb = pick("hugs","cuddles","snugs")
		user.visible_message("<span class='notice'>[user] [cuddle_verb] the [src].</span>")
		playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		if(!isclocker(user))
			return
		if(alert(user, "Do you want to reveal clockwork slab?","Revealing!","Yes","No") != "Yes")
			return
		name = "Clockwork slab"
		desc = "A strange metal tablet. A clock in the center turns around and around."
		icon = 'icons/obj/clockwork.dmi'
		icon_state = "clock_slab"
		attack_verb = null
		deplete_spell()
		plushy = FALSE
	if(!isclocker(user))
		to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
		if(iscarbon(user))
			var/mob/living/carbon/carbon = user
			carbon.Weaken(5)
			carbon.Stuttering(10)
		return
	if(enchant_type == HIDE_SPELL)
		to_chat(user, "<span class='notice'>You disguise your tool as some little toy.</span>")
		playsound(user, 'sound/magic/cult_spell.ogg', 15, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		var/chosen_plush = pick(plush_colors)
		name = chosen_plush
		desc = "An adorable, soft, and cuddly plushie."
		icon = 'icons/obj/toy.dmi'
		icon_state = plush_colors[chosen_plush]
		attack_verb = list("poofed", "bopped", "whapped","cuddled","fluffed")
		enchant_type = CASTING_SPELL
		plushy = TRUE
	if(enchant_type == TELEPORT_SPELL)
		var/list/possible_altars = list()
		var/list/altars = list()
		var/list/duplicates = list()
		for(var/obj/structure/clockwork/functional/altar/altar as anything in GLOB.clockwork_altars)
			if(!altar.anchored)
				continue
			var/result_name = altar.locname
			if(result_name in altars)
				duplicates[result_name]++
				result_name = "[result_name] ([duplicates[result_name]])"
			else
				altars.Add(result_name)
				duplicates[result_name] = 1
			if(is_mining_level(altar.z))
				result_name += ", Lava"
			else if(!is_station_level(altar.z))
				result_name += ", [altar.z] [dir2text(get_dir(user,get_turf(altar)))] sector"
			possible_altars[result_name] = altar
		if(!length(possible_altars))
			to_chat(user, "<span class='warning'>You have no altars teleport to!</span>")
			return
		if(!is_level_reachable(user.z))
			to_chat(user, "<span class='warning'>You are not in the right dimension!</span>")
			return

		var/selected_altar = input(user, "Pick a credence teleport to...", "Teleporation") as null|anything in possible_altars
		if(!selected_altar)
			return
		var/turf/destination = possible_altars[selected_altar]
		to_chat(user, "<span class='notice'> You start invoking teleportation...</span>")
		animate(user, color = COLOR_PURPLE, time = 1.5 SECONDS)
		if(do_after(user, 1.5 SECONDS, target = user) && destination)
			do_sparks(4, 0, user)
			user.forceMove(get_turf(destination))
			playsound(user, 'sound/effects/phasein.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			add_attack_logs(user, destination, "Teleported to by [src]", ATKLOG_ALL)
			deplete_spell()
		user.color = null

/obj/item/clockwork/clockslab/afterattack(atom/target, mob/living/user, proximity, params)
	. = ..()
	if(!isclocker(user))
		if(plushy)
			return
		user.unEquip(src, 1)
		user.emote("scream")
		to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
		if(iscarbon(user))
			var/mob/living/carbon/carbon = user
			carbon.Weaken(5)
			carbon.Stuttering(10)
		return
	switch(enchant_type)
		if(STUN_SPELL)
			if(!isliving(target) || isclocker(target) || !proximity)
				return
			var/mob/living/living = target
			src.visible_message("<span class='warning'>[user]'s [src] sparks for a moment with bright light!</span>")
			user.mob_light(LIGHT_COLOR_HOLY_MAGIC, 3, _duration = 2) //No questions
			if(living.null_rod_check())
				src.visible_message("<span class='warning'>[target]'s holy weapon absorbs the light!</span>")
				deplete_spell()
				return
			living.Weaken(5)
			living.Stun(5)
			living.Silence(8)
			if(isrobot(living))
				var/mob/living/silicon/robot/robot = living
				robot.emp_act(EMP_HEAVY)
			else if(iscarbon(target))
				var/mob/living/carbon/carbon = living
				carbon.Stuttering(16)
				carbon.ClockSlur(16)
			add_attack_logs(user, target, "Stunned by [src]")
			deplete_spell()
		if(KNOCK_SPELL)
			if(!proximity) //magical key only works if you're close enough
				return
			if(istype(target, /obj/machinery/door))
				var/obj/machinery/door/door = target
				if(istype(door, /obj/machinery/door/airlock/hatch/gamma))
					return
				if(istype(door, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/A = door
					A.unlock(TRUE)	//forced because it's magic!
				playsound(get_turf(usr), 'sound/magic/knock.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				door.open()
				deplete_spell()
			else if(istype(target, /obj/structure/closet))
				var/obj/structure/closet/closet = target
				if(istype(closet, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = closet
					SC.locked = FALSE
				playsound(get_turf(usr), 'sound/magic/knock.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				closet.open()
				deplete_spell()
			else
				to_chat(user, "<span class='warning'>You can use only on doors and closets!</span>")
		if(TELEPORT_SPELL)
			if(target.density && !proximity)
				to_chat(user, "<span class='warning'>The path is blocked!</span>")
				return
			if(proximity)
				to_chat(user, "<span class='warning'>You too close to the path point!</span>")
				return
			if(!(target in view(user)))
				return
			to_chat(user, "<span class='notice'> You start invoking teleportation...</span>")
			animate(user, color = COLOR_PURPLE, time = 1.5 SECONDS)
			if(do_after(user, 1.5 SECONDS, target = user))
				do_sparks(4, 0, user)
				user.forceMove(get_turf(target))
				playsound(user, 'sound/effects/phasein.ogg', 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				add_attack_logs(user, target, "Teleported to by [src]", ATKLOG_ALL)
				deplete_spell()
			user.color = null
		if(HEAL_SPELL)
			if(!isliving(target) || !isclocker(target) || !proximity)
				return
			var/mob/living/living = target
			if(ishuman(living))
				living.heal_overall_damage(30, 30, TRUE, FALSE, TRUE)
			else if(isanimal(living))
				var/mob/living/simple_animal/M = living
				if(M.health < M.maxHealth)
					M.adjustHealth(-50)
			add_attack_logs(user, target, "clockslab healed", ATKLOG_ALL)
			deplete_spell()

/obj/item/clockwork
	name = "Clockwork item name"
	icon = 'icons/obj/clockwork.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF

//Ratvarian spear
/obj/item/twohanded/ratvarian_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "ratvarian_spear0"
	slot_flags = SLOT_BACK
	force = 12
	force_unwielded = 12
	force_wielded = 20
	throwforce = 50
	armour_penetration = 40
	sharp = TRUE
	embed_chance = 85
	embedded_ignore_throwspeed_threshold = TRUE
	attack_verb = list("stabbed", "poked", "slashed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_HUGE
	needs_permit = TRUE

/obj/item/twohanded/ratvarian_spear/Initialize(mapload)
	. = ..()
	enchants = GLOB.spear_spells

/obj/item/twohanded/ratvarian_spear/update_icon()
	icon_state = "ratvarian_spear[wielded]"
	update_overlays()
	return ..()

/obj/item/twohanded/ratvarian_spear/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "ratvarian_spear0_overlay_[enchant_type]"

/obj/item/twohanded/ratvarian_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/living = hit_atom
	if(isclocker(living))
		if(ishuman(living) && !living.restrained() && living.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			living.visible_message("<span class='warning'>[living] catches [src] out of the air!</span>")
		else
			do_sparks(5, TRUE, living)
			living.visible_message("<span class='warning'>[src] bounces off of [living], as if repelled by an unseen force!</span>")
		return
	. = ..()

/obj/item/twohanded/ratvarian_spear/attack(mob/living/M, mob/living/user, def_zone)
	if(!isclocker(user))
		user.emote("scream")
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.embed_item_inside(src)
			to_chat(user, "<span class='clocklarge'>\"How does it feel it now?\"</span>")
		else
			user.remove_from_mob(src)
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
		return
	. = ..()

/obj/item/twohanded/ratvarian_spear/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !wielded || !isliving(target))
		return
	if(isclocker(target))
		return

	switch(enchant_type)
		if(CONFUSE_SPELL)
			if(!iscarbon(target))
				return
			var/mob/living/carbon/carbon = target
			if(carbon.mind?.isholy)
				to_chat(carbon, "<span class='danger'>You feel as foreigner thoughts tries to pierce your mind...</span>")
				deplete_spell()
				return
			carbon.AdjustConfused(15)
			to_chat(carbon, "<span class='danger'>Your mind blanks for a moment!</span>")
			add_attack_logs(user, carbon, "Inflicted confusion with [src]")
			deplete_spell()
		if(DISABLE_SPELL)
			new /obj/effect/temp_visual/emp/clock(get_turf(src))
			if(issilicon(target))
				var/mob/living/silicon/S = target
				S.emp_act(EMP_LIGHT)
			else
				target.emp_act(EMP_HEAVY)
			add_attack_logs(user, target, "Point-EMP with [src]")
			deplete_spell()

/obj/item/twohanded/ratvarian_spear/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, "<span class='clocklarge'>\"I wouldn't advise that.\"</span>")
		to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
		user.Confused(10)
		user.Jitter(6)

//Ratvarian borg spear
/obj/item/clock_borg_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "ratvarian_spear0"
	force = 20
	armour_penetration = 30
	sharp = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/clock_borg_spear/Initialize(mapload)
	. = ..()
	enchants = GLOB.spear_spells

/obj/item/clock_borg_spear/update_icon()
	update_overlays()
	return ..()

/obj/item/clock_borg_spear/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "ratvarian_spear0_overlay_[enchant_type]"

/obj/item/clock_borg_spear/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !isliving(target))
		return
	if(isclocker(target))
		return

	switch(enchant_type)
		if(CONFUSE_SPELL)
			if(!iscarbon(target))
				return
			var/mob/living/carbon/carbon = target
			if(carbon.mind?.isholy)
				to_chat(carbon, "<span class='danger'>You feel as foreigner thoughts tries to pierce your mind...</span>")
				deplete_spell()
				return
			carbon.AdjustConfused(15)
			to_chat(carbon, "<span class='danger'>Your mind blanks for a moment!</span>")
			add_attack_logs(user, carbon, "Inflicted confusion with [src]")
			deplete_spell()
		if(DISABLE_SPELL)
			new /obj/effect/temp_visual/emp/clock(get_turf(src))
			if(issilicon(target))
				var/mob/living/silicon/S = target
				S.emp_act(EMP_LIGHT)
			else
				target.emp_act(EMP_HEAVY)
			add_attack_logs(user, target, "Point-EMP with [src]")
			deplete_spell()

//Clock hammer
/obj/item/twohanded/clock_hammer
	name = "hammer clock"
	desc = "A heavy hammer of an elder god. Used to shine like in past times."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_hammer0"
	slot_flags = SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 20
	armour_penetration = 40
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE
	needs_permit = TRUE

/obj/item/twohanded/clock_hammer/Initialize(mapload)
	. = ..()
	enchants = GLOB.hammer_spells

/obj/item/twohanded/clock_hammer/update_icon()
	icon_state = "clock_hammer[wielded]"
	update_overlays()
	return ..()

/obj/item/twohanded/clock_hammer/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "clock_hammer0_overlay_[enchant_type]"

/obj/item/twohanded/clock_hammer/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/living = hit_atom
	if(isclocker(living))
		if(ishuman(living) && !living.restrained() && living.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			living.visible_message("<span class='warning'>[living] catches [src] out of the air!</span>")
		else
			do_sparks(5, TRUE, living)
			living.visible_message("<span class='warning'>[src] bounces off of [living], as if repelled by an unseen force!</span>")
		return
	. = ..()

/obj/item/twohanded/clock_hammer/attack(mob/living/M, mob/living/user, def_zone)
	if(!isclocker(user))
		user.Weaken(5)
		user.unEquip(src, 1)
		user.emote("scream")
		user.visible_message("<span class='warning'>A powerful force shoves [user] away from [M]!</span>",
		"<span class='clocklarge'>\"Don't hit yourself.\"</span>")

		var/wforce = rand(force_unwielded, force_wielded)
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.apply_damage(wforce, BRUTE, "head")
		else
			user.adjustBruteLoss(wforce)
		return
	. = ..()

/obj/item/twohanded/clock_hammer/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !wielded || !isliving(target))
		return
	if(isclocker(target))
		return
	var/mob/living/living = target
	switch(enchant_type)
		if(KNOCKOFF_SPELL)
			var/atom/throw_target = get_edge_target_turf(living, user.dir)
			living.throw_at(throw_target, 200, 20, user) // vroom
			add_attack_logs(user, target, "Knocked-off with [src]")
			deplete_spell()
		if(CRUSH_SPELL)
			if(ishuman(living))
				var/mob/living/carbon/human/human = living
				var/obj/item/rod = human.null_rod_check()
				if(rod)
					human.visible_message("<span class='danger'>[human]'s [rod] shines as it deflects magic from [user]!</span>")
					deplete_spell()
					return
				var/obj/item/organ/external/BP = pick(human.bodyparts)
				BP.emp_act(EMP_HEAVY)
				BP.fracture()
			if(isanimal(living))
				var/mob/living/simple_animal/animal = living
				animal.adjustBruteLoss(force/2)
				animal.emp_act(EMP_LIGHT)
			if(isrobot(living))
				var/mob/living/silicon/robot/robot = living
				var/datum/robot_component/RC = robot.components[pick(robot.components)]
				RC.destroy()
			add_attack_logs(user, target, "Crushed with [src]")
			deplete_spell()

/obj/item/twohanded/clock_hammer/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, "<span class='clocklarge'>\"I wouldn't advise that.\"</span>")
		to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
		user.Confused(10)
		user.Jitter(6)

//Clock sword
/obj/item/melee/clock_sword
	name = "rustless sword"
	desc = "A simplish sword that barely made for fighting, but still has some powders to give."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_sword"
	item_state = "clock_sword"
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 20
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 10
	sharp = TRUE
	attack_verb = list("lunged at", "stabbed")
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/swordsman = FALSE

/obj/item/melee/clock_sword/Initialize(mapload)
	. = ..()
	enchants = GLOB.sword_spells

/obj/item/melee/clock_sword/update_icon()
	update_overlays()
	return ..()

/obj/item/melee/clock_sword/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "clock_sword_overlay_[enchant_type]"

/obj/item/melee/clock_sword/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/living = hit_atom
	if(isclocker(living))
		if(ishuman(living) && !living.restrained() && living.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			living.visible_message("<span class='warning'>[living] catches [src] out of the air!</span>")
		else
			do_sparks(5, TRUE, living)
			living.visible_message("<span class='warning'>[src] bounces off of [living], as if repelled by an unseen force!</span>")
		return
	. = ..()

/obj/item/melee/clock_sword/attack_self(mob/user)
	. = ..()
	if(!isclocker(user))
		user.remove_from_mob(src)
		user.emote("scream")
		to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
		return
	if(enchant_type == FASTSWORD_SPELL && src == user.get_active_hand())
		flags |= NODROP
		enchant_type = CASTING_SPELL
		force = 7
		swordsman = TRUE
		add_attack_logs(user, user, "Sworded [src]", ATKLOG_ALL)
		to_chat(user, "<span class='danger'>The blood inside your veind flows quickly, as you try to sharp someone by any means!</span>")
		addtimer(CALLBACK(src, .proc/reset_swordsman, user), 9 SECONDS)

/obj/item/melee/clock_sword/proc/reset_swordsman(mob/user)
	to_chat(user, "<span class='notice'>The grip on [src] looses...</span>")
	flags &= ~NODROP
	force = initial(force)
	swordsman = FALSE
	deplete_spell()

/obj/item/melee/clock_sword/attack(mob/living/M, mob/living/user, def_zone)
	if(!isclocker(user))
		user.emote("scream")
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.embed_item_inside(src)
			to_chat(user, "<span class='clocklarge'>\"How does it feel it now?\"</span>")
		else
			user.remove_from_mob(src)
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
		return
	. = ..()

/obj/item/melee/clock_sword/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !isliving(target))
		return
	if(isclocker(target))
		return
	if(ishuman(target))
		var/mob/living/carbon/human/human = target
		if(enchant_type == BLOODSHED_SPELL && human.dna && !(NO_BLOOD in human.dna.species.species_traits))
			var/obj/item/organ/external/BP = pick(human.bodyparts)
			to_chat(user, "<span class='warning'> You tear through [human]'s skin releasing the blood from [human.p_their()] [BP.name]!</span>")
			human.custom_pain("Your skin tears in [BP.name] from [src]!")
			playsound(get_turf(human), 'sound/effects/pierce.ogg', 30, TRUE)
			BP.internal_bleeding = TRUE
			human.blood_volume = max(human.blood_volume - 100, 0)
			var/splatter_dir = get_dir(user, human)
			blood_color = human.dna.species.blood_color
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(human.drop_location(), splatter_dir, blood_color)
			human.emote("scream")
			deplete_spell()
	if(swordsman)
		user.changeNext_move(CLICK_CD_RAPID)

/obj/item/melee/clock_sword/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, "<span class='clocklarge'>\"I wouldn't advise that.\"</span>")
		to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
		user.Confused(10)
		user.Jitter(6)

//Buckler
/obj/item/shield/clock_buckler
	name = "brass buckler"
	desc = "Small shield that protects on arm only. But with the right use it can protect a full body."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "brass_buckler"
	item_state = "brass_buckler"
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 3
	attack_verb = list("bumped", "prodded", "shoved", "bashed")
	hitsound = 'sound/weapons/smash.ogg'
	block_chance = 30

/obj/item/shield/clock_buckler/Initialize(mapload)
	. = ..()
	enchants = GLOB.shield_spells

/obj/item/shield/clock_buckler/update_icon()
	update_overlays()
	return ..()

/obj/item/shield/clock_buckler/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "brass_buckler_overlay_[enchant_type]"

/obj/item/shield/clock_buckler/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!proximity || !isliving(target))
		return
	if(isclocker(target))
		return
	if(enchant_type == PUSHOFF_SPELL)
		var/mob/living/living = target
		if(prob(60))
			living.AdjustStunned(1)
		else
			var/atom/throw_target = get_edge_target_turf(target, user.dir)
			living.throw_at(throw_target, 2, 5, spin = FALSE)
			if(iscarbon(living))
				living.AdjustConfused(5)
		deplete_spell()

/obj/item/shield/clock_buckler/equipped(mob/living/user, slot)
	. = ..()
	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] picks [src] up, it flickers off their arms!</span>", "<span class='warning'>The buckler flicker off your arms, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Weaken(5)
		else
			to_chat(user, "<span class='clocklarge'>\"Did you like having head?\"</span>")
			to_chat(user, "<span class='userdanger'>The buckler suddenly hits you in the head!</span>")
			user.emote("scream")
			user.apply_damage(10, BRUTE, "head")
		user.remove_from_mob(src)

// Clockwork robe. Basic robe from clockwork slab.
/obj/item/clothing/suit/hooded/clockrobe
	name = "clock robes"
	desc = "A set of robes worn by the followers of a clockwork cult."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_robe"
	item_state = "clockwork_robe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/clockhood
	allowed = list(/obj/item/clockwork, /obj/item/twohanded/ratvarian_spear, /obj/item/twohanded/clock_hammer, /obj/item/melee/clock_sword)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT
	magical = TRUE

/obj/item/clothing/suit/hooded/clockrobe/can_store_weighted()
	return TRUE

/obj/item/clothing/suit/hooded/clockrobe/Initialize(mapload)
	. = ..()
	enchants = GLOB.robe_spells

/obj/item/clothing/suit/hooded/clockrobe/update_icon()
	update_overlays()
	return ..()

/obj/item/clothing/suit/hooded/clockrobe/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "clockwork_robe_overlay_[enchant_type]"

/obj/item/clothing/suit/hooded/clockrobe/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/activate/enchant)
		if(!iscarbon(user))
			return
		var/mob/living/carbon/carbon = user
		if(carbon.wear_suit != src || !isclocker(carbon))
			return
		if(enchant_type == INVIS_SPELL)
			if(carbon.wear_suit != src)
				return
			playsound(get_turf(carbon), 'sound/magic/smoke.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			enchant_type = CASTING_SPELL
			animate(carbon, alpha = 20, time = 1 SECONDS)
			flags |= NODROP
			sleep(10)
			carbon.alpha = 20
			add_attack_logs(user, user, "cloaked [src]", ATKLOG_ALL)
			addtimer(CALLBACK(src, .proc/uncloak, carbon), 10 SECONDS)
		if(enchant_type == SPEED_SPELL)
			enchant_type = CASTING_SPELL
			flags |= NODROP
			carbon.status_flags |= GOTTAGOFAST
			addtimer(CALLBACK(src, .proc/unspeed, carbon), 8 SECONDS)
			to_chat(carbon, "<span class='danger'>Robe tightens, as it frees you to be flexible around!</span>")
			add_attack_logs(user, user, "speed boosted with [src]", ATKLOG_ALL)
	else
		ToggleHood()

/obj/item/clothing/suit/hooded/clockrobe/proc/uncloak(mob/user)
	animate(user, alpha = 255, time = 1 SECONDS)
	flags &= ~NODROP
	sleep(10)
	user.alpha = 255
	deplete_spell()

/obj/item/clothing/suit/hooded/clockrobe/proc/unspeed(mob/living/carbon/carbon)
	carbon.status_flags &= ~GOTTAGOFAST
	flags &= ~NODROP
	deplete_spell()

/obj/item/clothing/head/hooded/clockhood
	name = "clock hood"
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockhood"
	item_state = "clockhood"
	desc = "A hood worn by the followers of ratvar."
	flags = BLOCKHAIR
	flags_inv = HIDENAME
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)
	magical = TRUE

/obj/item/clothing/suit/hooded/clockrobe/equipped(mob/living/user, slot)
	. = ..()
	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] picks [src] up, it flickers off their arms!</span>", "<span class='warning'>The robe flicker off your arms, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Weaken(5)
		else
			to_chat(user, "<span class='clocklarge'>\"I think this armor is too hot for you to handle.\"</span>")
			user.emote("scream")
			user.apply_damage(7, BURN, "chest")
			user.IgniteMob()
		user.remove_from_mob(src)

// Clockwork Armour. Basically greater robe with more and better spells.
/obj/item/clothing/suit/armor/clockwork
	name = "clockwork cuirass"
	desc = "A bulky cuirass made of brass."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_cuirass"
	item_state = "clockwork_cuirass"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 60, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	flags_inv = HIDEJUMPSUIT
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/clockwork, /obj/item/twohanded/ratvarian_spear, /obj/item/twohanded/clock_hammer, /obj/item/melee/clock_sword)
	var/absorb_uses = 2
	var/reflect_uses = 3
	var/normal_armor
	var/harden_armor = list("melee" = 80, "bullet" = 60, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)

/obj/item/clothing/suit/armor/clockwork/can_store_weighted()
	return TRUE

/obj/item/clothing/suit/armor/clockwork/Initialize(mapload)
	. = ..()
	enchants = GLOB.armour_spells
	normal_armor = armor //initialize, so it will be easier to change armors stats
	harden_armor = getArmor(arglist(harden_armor))

/obj/item/clothing/suit/armor/clockwork/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(enchant_type == ABSORB_SPELL && isclocker(owner))
		owner.visible_message("<span class='danger'>[attack_text] is absorbed by [src] sparks!</span>")
		playsound(loc, "sparks", 100, TRUE)
		new /obj/effect/temp_visual/ratvar/sparks(get_turf(owner))
		if(absorb_uses <= 0)
			absorb_uses = initial(absorb_uses)
			deplete_spell()
		else
			absorb_uses--
		return TRUE
	return FALSE

/obj/item/clothing/suit/armor/clockwork/IsReflect(def_zone)
	if(!ishuman(loc))
		return FALSE
	var/mob/living/carbon/human/owner = loc
	if(owner.wear_suit != src)
		return FALSE
	if(enchant_type == REFLECT_SPELL && isclocker(owner))
		playsound(loc, "sparks", 100, TRUE)
		new /obj/effect/temp_visual/ratvar/sparks(get_turf(owner))
		if(reflect_uses <= 0)
			reflect_uses = initial(reflect_uses)
			deplete_spell()
		else
			reflect_uses--
		return TRUE
	return FALSE

/obj/item/clothing/suit/armor/clockwork/attack_self(mob/user)
	. = ..()
	if(!isclocker(user))
		user.remove_from_mob(src)
		user.emote("scream")
		to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
		return
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon = user
	switch(enchant_type)
		if(ARMOR_SPELL)
			if(carbon.wear_suit != src)
				to_chat(carbon, "<span class='notice'>You should wear [src]!</span>")
				return
			carbon.visible_message("<span class='danger'>[carbon] concentrates as [carbon.p_their()] curiass shifts his plates!</span>",
			"<span class='notice'>The [src.name] becomes more hardened as the plates becomes to shift for any attack!</span>")
			//armor = list("melee" = 80, "bullet" = 60, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
			armor = harden_armor
			flags |= NODROP
			enchant_type = CASTING_SPELL
			add_attack_logs(carbon, carbon, "Hardened [src]", ATKLOG_ALL)
			set_light(1.5, 0.8, COLOR_RED)
			addtimer(CALLBACK(src, .proc/reset_armor, carbon), 12 SECONDS)
		if(FLASH_SPELL)
			if(carbon.wear_suit != src)
				to_chat(carbon, "<span class='notice'>You should wear [src]!</span>")
				return
			playsound(loc, 'sound/effects/phasein.ogg', 100, 1)
			set_light(2, 1, COLOR_WHITE)
			addtimer(CALLBACK(src, /atom./proc/set_light, 0), 0.2 SECONDS)
			carbon.visible_message("<span class='disarm'>[carbon]'s [src.name] emits a blinding light!</span>", "<span class='danger'>Your [src.name] emits a blinding light!</span>")
			for(var/mob/living/carbon/M in oviewers(3, carbon))
				if(isclocker(M))
					return
				if(M.flash_eyes(2, 1))
					M.AdjustConfused(5)
					add_attack_logs(carbon, M, "Flashed with [src]")
			deplete_spell()

/obj/item/clothing/suit/armor/clockwork/proc/reset_armor(mob/user)
	to_chat(user, "<span class='notice'>The [src] stops shifting...</span>")
	set_light(0)
	armor = normal_armor
	flags &= ~NODROP
	deplete_spell()

/obj/item/clothing/suit/armor/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their body!</span>", "<span class='warning'>The curiass flickers off your body, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
				C.Weaken(5)
		else
			to_chat(user, "<span class='clocklarge'>\"I think this armor is too hot for you to handle.\"</span>")
			user.emote("scream")
			user.apply_damage(15, BURN, "chest")
			user.adjust_fire_stacks(2)
			user.IgniteMob()
		user.remove_from_mob(src)

// Gloves
/obj/item/clothing/gloves/clockwork
	name = "clockwork gauntlets"
	desc = "Heavy, fire-resistant gauntlets with brass reinforcement."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_gauntlets"
	item_state = "clockwork_gauntlets"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	var/north_star = FALSE
	var/fire_casting = FALSE

/obj/item/clothing/gloves/clockwork/Initialize(mapload)
	. = ..()
	enchants = GLOB.gloves_spell

/obj/item/clothing/gloves/clockwork/attack_self(mob/user)
	. = ..()
	if(!isclocker(user))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	switch(enchant_type)
		if(FASTPUNCH_SPELL)
			if(human.gloves != src)
				to_chat(human, "<span class='notice'>You should wear [src]!</span>")
				return
			if(human.mind.martial_art)
				to_chat(human, "<span class='warning'>You're too powerful to use it!</span>")
				return
			flags |= NODROP
			to_chat(human, "<span class='notice'>You fastening gloves making your moves agile!</span>")
			enchant_type = CASTING_SPELL
			north_star = TRUE
			add_attack_logs(human, human, "North-starred [src]", ATKLOG_ALL)
			addtimer(CALLBACK(src, .proc/reset), 6 SECONDS)
		if(FIRE_SPELL)
			if(human.gloves != src)
				to_chat(human, "<span class='notice'>You should wear [src]!</span>")
				return
			flags |= NODROP
			to_chat(human, "<span class='notice'>Your gloves becomes in red flames ready to burn any enemy in sight!</span>")
			enchant_type = CASTING_SPELL
			fire_casting = TRUE
			add_attack_logs(human, human, "Fire-casted [src]", ATKLOG_ALL)
			addtimer(CALLBACK(src, .proc/reset), 5 SECONDS)

/obj/item/clothing/gloves/clockwork/Touch(atom/A, proximity)
	var/mob/living/user = loc
	if(!(user.a_intent == INTENT_HARM) || !enchant_type)
		return
	if(!proximity)
		return
	if(enchant_type == STUNHAND_SPELL && isliving(A))
		var/mob/living/living = A
		if(living.null_rod_check())
			src.visible_message("<span class='warning'>[living]'s holy weapon absorbs the light!</span>")
			deplete_spell()
			return
		if(isclocker(living))
			return
		if(iscarbon(living))
			var/mob/living/carbon/carbon = living
			carbon.Weaken(5)
			carbon.Stuttering(10)
		if(isrobot(living))
			var/mob/living/silicon/robot/robot = living
			robot.Weaken(5)
		do_sparks(5, 0, loc)
		playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		add_attack_logs(user, living, "Stunned with [src]")
		deplete_spell()
	if(north_star && !user.mind.martial_art)
		user.changeNext_move(CLICK_CD_RAPID)
	if(fire_casting && iscarbon(A))
		var/mob/living/carbon/C = A
		if(isclocker(C))
			return
		C.adjust_fire_stacks(0.3)
		C.IgniteMob()

/obj/item/clothing/gloves/clockwork/proc/reset()
	north_star = FALSE
	fire_casting = FALSE
	flags &= ~NODROP
	to_chat(usr, "<span class='notice'> [src] depletes last magic they had.</span>")
	deplete_spell()

/obj/item/clothing/gloves/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their arms!</span>", "<span class='warning'>The gauntlets flicker off your arms, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Weaken(5)
		else
			to_chat(user, "<span class='clocklarge'>\"Did you like having arms?\"</span>")
			to_chat(user, "<span class='userdanger'>The gauntlets suddenly squeeze tight, crushing your arms before you manage to get them off!</span>")
			user.emote("scream")
			user.apply_damage(7, BRUTE, "l_arm")
			user.apply_damage(7, BRUTE, "r_arm")
		user.remove_from_mob(src)

// Shoes
/obj/item/clothing/shoes/clockwork
	name = "clockwork treads"
	desc = "Industrial boots made of brass. They're very heavy."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_treads"
	item_state = "clockwork_treads"
	strip_delay = 60
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)

/obj/item/clothing/shoes/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their feet!</span>", "<span class='warning'>The treads flicker off your feet, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
				C.Weaken(5)
		else
			to_chat(user, "<span class='clocklarge'>\"Let's see if you can dance with these.\"</span>")
			to_chat(user, "<span class='userdanger'>The treads turn searing hot as you scramble to get them off!</span>")
			user.emote("scream")
			user.apply_damage(7, BURN, "l_leg")
			user.apply_damage(7, BURN, "r_leg")
		user.remove_from_mob(src)

// Helmet
/obj/item/clothing/head/helmet/clockwork
	name = "clockwork helmet"
	desc = "A heavy helmet made of brass."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_helmet"
	item_state = "clockwork_helmet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	armor = list(melee = 45, bullet = 65, laser = 10, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)

/obj/item/clothing/head/helmet/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their head!</span>", "<span class='warning'>The helmet flickers off your head, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
				C.Weaken(5)
		else
			to_chat(user, "<span class='heavy_brass'>\"Do you have a hole in your head? You're about to.\"</span>")
			to_chat(user, "<span class='userdanger'>The helmet tries to drive a spike through your head as you scramble to remove it!</span>")
			user.emote("scream")
			user.apply_damage(30, BRUTE, "head")
			user.adjustBrainLoss(30)
		user.remove_from_mob(src)

// Glasses
/obj/item/clothing/glasses/clockwork
	name = "judicial visor"
	desc = "A strange purple-lensed visor. Looking at it inspires an odd sense of guilt."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "judicial_visor_0"
	item_state = "sunglasses"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/active = FALSE //If the visor is online
	actions_types = list(/datum/action/item_action/toggle)
	flash_protect = TRUE
	see_in_dark = 0
	lighting_alpha = null

/obj/item/clothing/glasses/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if(!isclocker(user))
		if(!iscultist(user))
			to_chat(user, "<span class='clocklarge'>\"I think you need some different glasses. This too bright for you.\"</span>")
			user.flash_eyes()
			user.Weaken()
			playsound(loc, 'sound/weapons/flash.ogg', 50, TRUE)
		else
			to_chat(user, "<span class='clocklarge'>\"Consider yourself judged, whelp.\"</span>")
			to_chat(user, "<span class='userdanger'>You suddenly catch fire!</span>")
			user.adjust_fire_stacks(5)
			user.IgniteMob()
		user.remove_from_mob(src)

/obj/item/clothing/glasses/clockwork/attack_self(mob/user)
	if(!isclocker(user))
		to_chat(user, "<span class='warning'>You fiddle around with [src], to no avail.</span>")
		return
	active = !active

	icon_state = "judicial_visor_[active]"
	flash_protect = !active
	see_in_dark = active ? 8 : 0
	lighting_alpha = active ? LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE : null
	switch(active)
		if(TRUE)
			to_chat(user, "<span class='notice'>You toggle [src], its lens begins to glow.</span>")
		if(FALSE)
			to_chat(user, "<span class='notice'>You toggle [src], its lens darkens once more.</span>")

	user.update_action_buttons_icon()
	user.update_inv_glasses()
	user.update_sight()

/*
 * Consumables.
 */

//Intergration Cog. Can be used on an open APC to replace its guts with clockwork variants, and begin passively siphoning power from it
/obj/item/clockwork/integration_cog
	name = "integration cog"
	desc = "A small cogwheel that fits in the palm of your hand."
	icon_state = "gear"
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/power/apc/apc

/obj/item/clockwork/integration_cog/Initialize()
	. = ..()
	transform *= 0.5 //little cog!
	START_PROCESSING(SSobj, src)

/obj/item/clockwork/integration_cog/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clockwork/integration_cog/process()
	if(!apc)
		if(istype(loc, /obj/machinery/power/apc))
			apc = loc
		else
			STOP_PROCESSING(SSobj, src)
	else
		var/obj/item/stock_parts/cell/cell = apc.get_cell()
		if(!cell)
			return
		if(cell.charge / cell.maxcharge > COG_MAX_SIPHON_THRESHOLD)
			cell.use(round(0.001*cell.maxcharge,1))
			adjust_clockwork_power(CLOCK_POWER_COG) //Power is shared, so only do it once; this runs very quickly so it's about CLOCK_POWER_COG(1)/second
			if(prob(1))
				playsound(apc, 'sound/machines/clockcult/steam_whoosh.ogg', 5, TRUE, SILENCED_SOUND_EXTRARANGE)
				new/obj/effect/temp_visual/small_smoke(get_turf(apc))

//Clockwork module
/obj/item/borg/upgrade/clockwork
	name = "Clockwork Module"
	desc = "An unique brass board, used by cyborg warriors."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_mod"

/obj/item/borg/upgrade/clockwork/action(mob/living/silicon/robot/R)
	if(..())
		if(R.module?.type == /obj/item/robot_module/clockwork)
			R.emp_protection = TRUE
			R.speed = -0.5
			R.pdahide = TRUE
		else
			R.ratvar_act()
		R.opened = FALSE
		R.locked = TRUE
		return TRUE

// A drone shell. Just click on it and it will boot up itself!
/obj/item/clockwork/cogscarab
	name = "unactivated cogscarab"
	desc = "A strange, drone-like machine. It looks lifeless."
	icon_state = "cogscarab_shell"
	var/searching = FALSE

/obj/item/clockwork/cogscarab/attack_self(mob/user)
	if(!isclocker(user))
		to_chat(user, "<span class='warning'>You fiddle around with [src], to no avail.</span>")
		return FALSE
	if(searching)
		return
	searching = TRUE
	to_chat(user, "<span class='notice'>You're trying to boot up [src] as the gears inside start to hum.</span>")
	var/list/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Servant of Ratvar?", ROLE_CLOCKER, FALSE, poll_time = 10 SECONDS, source = /mob/living/silicon/robot/cogscarab)
	if(candidates.len)
		var/mob/dead/observer/O = pick(candidates)
		var/mob/living/silicon/robot/cogscarab/cog = new /mob/living/silicon/robot/cogscarab(get_turf(src))
		cog.key = O.key
		if(SSticker.mode.add_clocker(cog.mind))
			cog.create_log(CONVERSION_LOG, "[cog.mind] became clock drone by [user.name]")
		user.unEquip()
		qdel(src)
	else
		visible_message("<span class='notice'>[src] stops to hum. Perhaps you could try again?</span>")
		searching = FALSE
	return TRUE

// A real fighter. Doesn't have any ability except passive range reflect chance but a good soldier with solid speed and attack.
/obj/item/clockwork/marauder
	name = "unactivated marauder"
	desc = "The stalwart apparition of a soldier. It looks lifeless."
	icon_state = "marauder_shell"

/obj/item/clockwork/marauder/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/mmi/robotic_brain/clockwork))
		if(!isclocker(user))
			to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you attempt to place the soul vessel into the marauder shell.</span>")
			user.Confused(10)
			user.Jitter(6)
			return
		if(isdrone(user))
			to_chat(user, "<span class='warning'>You are not dexterous enough to do this!</span>")
			return
		var/obj/item/mmi/robotic_brain/clockwork/soul = I
		if(!soul.brainmob.mind)
			to_chat(user, "<span class='warning'> There is no soul in [I]!</span>")
			return
		var/mob/living/simple_animal/hostile/clockwork/marauder/cog = new (get_turf(src))
		soul.brainmob.mind.transfer_to(cog)
		playsound(cog, 'sound/effects/constructform.ogg', 50)
		user.unEquip(soul)
		qdel(soul)
		qdel(src)

//Shard
/obj/item/clockwork/shard
	name = "A brass shard"
	desc = "Unique crystal powered by some unknown magic."
	icon_state = "shard"
	sharp = TRUE //youch!!
	force = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clockwork/shard/Initialize(mapload)
	. = ..()
	enchants = GLOB.shard_spells

/obj/item/clockwork/shard/update_icon()
	update_overlays()
	return ..()

/obj/item/clockwork/shard/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "shard_overlay_[enchant_type]"

/obj/item/clockwork/shard/attack_self(mob/user)
	if(!isclocker(user) && isliving(user))
		var/mob/living/L = user
		user.emote("scream")
		if(ishuman(L))
			to_chat(L, "<span class='danger'>[src] pierces into your hand!</span>")
			var/mob/living/carbon/human/H = L
			H.embed_item_inside(src)
			to_chat(user, "<span class='clocklarge'>\"How does it feel it now?\"</span>")
		else
			to_chat(L, "<span class='danger'>[src] pierces into you!</span>")
			L.adjustBruteLoss(force)
		return
	if(!enchant_type)
		to_chat(user, "<span class='warning'>There is no spell stored!</span>")
		return
	else
		if(!ishuman(user))
			to_chat(user,"<span class='warning'>You are too weak to crush this massive shard!</span>")
			return
		user.visible_message("<span class='warning'>[user] crushes [src] in his hands!</span>", "<span class='notice'>You crush [src] in your hand!</span>")
		playsound(src, "shatter", 50, TRUE)
		switch(enchant_type)
			if(EMP_SPELL)
				add_attack_logs(user, user, "Clock EMP with [src]")
				empulse(src, 4, 6, cause="clock")
				qdel(src)
			if(TIME_SPELL)
				add_attack_logs(user, user, "Time stopped with [src]")
				qdel(src)
				new /obj/effect/timestop/clockwork(get_turf(user))
			if(RECONSTRUCT_SPELL)
				add_attack_logs(user, user, "Reconstructed with [src]")
				qdel(src)
				new /obj/effect/temp_visual/ratvar/reconstruct(get_turf(user))
	return

/obj/item/clockwork/shard/attack(mob/living/M, mob/living/user, def_zone)
	if(!isclocker(user))
		user.emote("scream")
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.embed_item_inside(src)
			to_chat(user, "<span class='clocklarge'>\"How does it feel it now?\"</span>")
		else
			user.remove_from_mob(src)
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
		return
	. = ..()

/obj/item/clockwork/shard/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!ishuman(target) || !isclocker(user))
		return
	if(!proximity)
		return
	var/mob/living/carbon/human/human = target
	if(human.stat == DEAD && isclocker(human)) // dead clocker
		user.unEquip(src)
		qdel(src)
		if(!human.client)
			give_ghost(human)
		else
			human.revive()
			human.set_species(/datum/species/golem/clockwork)
			to_chat(human, "<span class='clocklarge'><b>\"You are back once again.\"</b></span>")

/obj/item/clockwork/shard/pickup(mob/living/user)
	. = ..()
	if(!isclocker(user))
		to_chat(user, "<span class='clocklarge'>\"I wouldn't advise that.\"</span>")
		to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
		user.Confused(10)
		user.Jitter(6)

/obj/item/clockwork/shard/proc/give_ghost(var/mob/living/carbon/human/golem)
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Brass Golem?", ROLE_CLOCKER, TRUE, poll_time = 10 SECONDS, source = /obj/item/clockwork/clockslab)
	if(length(candidates))
		var/mob/dead/observer/C = pick(candidates)
		golem.ghostize(FALSE)
		golem.key = C.key
		golem.revive()
		golem.set_species(/datum/species/golem/clockwork)
		SEND_SOUND(golem, 'sound/ambience/antag/clockcult.ogg')
	else
		golem.visible_message("<span class='warning'>[golem] twitches as their body twists and rapidly changes the form!</span>")
		new /obj/effect/mob_spawn/human/golem/clockwork(get_turf(golem))
		golem.dust()

/obj/effect/temp_visual/ratvar/reconstruct
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_active"
	layer = BELOW_OBJ_LAYER
	alpha = 128
	duration = 40
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/ratvar/reconstruct/Initialize(mapload)
	. = ..()
	transform = matrix() * 0.1
	reconstruct()

/obj/effect/temp_visual/ratvar/reconstruct/proc/reconstruct()
	playsound(src, 'sound/magic/clockwork/reconstruct.ogg', 50, TRUE)
	animate(src, transform = matrix() * 1, time = 2 SECONDS)
	sleep(20)
	for(var/atom/affected in range(4, get_turf(src)))
		if(isliving(affected))
			var/mob/living/living = affected
			living.ratvar_act(TRUE)
			if(!isclocker(living) && !ishuman(living))
				continue
			living.heal_overall_damage(60, 60, TRUE, FALSE, TRUE)
			living.reagents?.add_reagent("epinephrine", 5)
			var/mob/living/carbon/human/H = living
			for(var/thing in H.bodyparts)
				var/obj/item/organ/external/E = thing
				E.internal_bleeding = FALSE
				E.mend_fracture()
		else
			affected.ratvar_act()
	animate(src, transform = matrix() * 0.1, time = 2 SECONDS)
