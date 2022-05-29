// A Clockwork slab. Ratvar's tool to cast most of essential spells.
/obj/item/clockwork/clockslab
	name = "Clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	icon = 'icons/obj/clockwork.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "clock_slab"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clockwork/clockslab/Initialize(mapload)
	. = ..()
	enchants = GLOB.clockslab_spells

/obj/item/clockwork/clockslab/update_icon()
	update_overlays()
	//if(enchant_type)
	//	add_overlay("overlay_temp")
	..()

/obj/item/clockwork/clockslab/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "clock_slab_overlay_[enchant_type]"

/obj/item/clockwork/clockslab/attack_self(mob/user)
	. = ..()
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
			log_game("Teleport spell failed - no other teleport runes")
			return
		if(!is_level_reachable(user.z))
			to_chat(user, "<span class='warning'>You are not in the right dimension!</span>")
			log_game("Teleport spell failed - user in away mission")
			return

		var/selected_altar = input(user, "Pick a credence teleport to...", "Teleporation") as null|anything in possible_altars
		if(!selected_altar)
			return
		var/turf/destination = possible_altars[selected_altar]
		to_chat(user, "<span class='notice'> You start invoking teleportation...</span>")
		animate(user, color = COLOR_PURPLE, time = 5 SECONDS)
		if(do_after(user, 5 SECONDS, target = user))
			do_teleport(user, get_turf(destination), asoundin = 'sound/effects/phasein.ogg')
			add_attack_logs(user, destination, "Teleported to by [src]", ATKLOG_ALL)
			deplete_spell()
		user.color = null

/obj/item/clockwork/clockslab/afterattack(atom/target, mob/living/user, proximity, params)
	. = ..()
	if(!isclocker(user))
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
			if(istype(target, /obj/machinery/door))
				var/obj/machinery/door/door = target
				if(istype(door, /obj/machinery/door/airlock/hatch/gamma))
					return
				if(istype(door, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/A = door
					A.unlock(TRUE)	//forced because it's magic!
				playsound(get_turf(usr), 'sound/magic/knock.ogg', 10, TRUE)
				door.open()
				deplete_spell()
			else if(istype(target, /obj/structure/closet))
				var/obj/structure/closet/closet = target
				if(istype(closet, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = closet
					SC.locked = FALSE
				playsound(get_turf(usr), 'sound/magic/knock.ogg', 10, TRUE)
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
			animate(user, color = COLOR_PURPLE, time = 50)
			if(do_after(user, 50, target = user))
				do_teleport(user, get_turf(target), asoundin = 'sound/effects/phasein.ogg')
				add_attack_logs(user, target, "Teleported to by [src]", ATKLOG_ALL)
				deplete_spell()
			user.color = null

/obj/item/clockwork
	name = "Clockwork item name"
	icon = 'icons/obj/clockwork.dmi'

//Ratvarian spear
/obj/item/twohanded/ratvarian_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "ratvarian_spear0"
	force_unwielded = 12
	force_wielded = 20
	throwforce = 40
	armour_penetration = 30
	sharp = TRUE
	embed_chance = 70
	embedded_ignore_throwspeed_threshold = TRUE
	attack_verb = list("stabbed", "poked", "slashed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY

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
		overlays += "ratvarian_spear_overlay_[enchant_type]"

/obj/item/twohanded/ratvarian_spear/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!isclocker(user))
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			human.embed_item_inside(src)
			user.emote("scream")
			to_chat(user, "<span class='clocklarge'>\"How does it feel it now?\"</span>")
		else
			user.remove_from_mob(src)
			user.emote("scream")
			to_chat(user, "<span class='clocklarge'>\"Now now, this is for my servants, not you.\"</span>")
		return
	if(!wielded || !isliving(target))
		return
	var/mob/living/living = target
	switch(enchant_type)
		if(CONFUSE_SPELL)
			if(living.mind.isholy)
				to_chat(living, "span class='danger'>You feel as foreigner thoughts tries to pierce your mind...</span>")
				deplete_spell()
				return
			living.SetConfused(10)
			to_chat(living, "<span class='danger'>Your mind blanks for a moment!</span>")
			add_attack_logs(user, living, "Inflicted confusion with [src]")
			deplete_spell()
		if(DISABLE_SPELL)
			new /obj/effect/temp_visual/emp/clock(get_turf(src))
			if(issilicon(living))
				var/mob/living/silicon/S = living
				S.emp_act(EMP_LIGHT)
			else
				living.emp_act(EMP_HEAVY)
			add_attack_logs(user, living, "Point-EMP with [src]")
			deplete_spell()

/obj/item/clock_borg_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "ratvarian_spear0"
	force = 20
	armour_penetration = 30
	sharp = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'


/obj/item/twohanded/clock_hammer
	name = "hammer clock"
	desc = "A heavy hammer of an elder god. Used to shine like in past times."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_hammer0"
	slot_flags = SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 25
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE

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
		overlays += "clock_hammer_overlay_[enchant_type]"

/obj/item/twohanded/clock_hammer/attack(mob/living/target, mob/living/user, def_zone)
	. = ..()
	if(!isclocker(user))
		target = user
		to_chat(user, "<span class='clocklarge'>\"Don't hit yourself.\"</span>")
		target.adjustBruteLoss(25)
		user.remove_from_mob(src)
	if(!wielded)
		return
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	switch(enchant_type)
		if(KNOCKOFF_SPELL)
			if(isclocker(target))
				return
			target.throw_at(throw_target, 200, 20, user) // vroom
			add_attack_logs(user, target, "Knocked-off with [src]")
			deplete_spell()
		if(CRUSH_SPELL)
			if(isclocker(target))
				return
			if(ishuman(target))
				var/mob/living/carbon/human/human = target
				var/obj/item/rod = human.null_rod_check()
				if(rod)
					human.visible_message("<span class='danger'>[human]'s [rod] shines as it deflects magic from [user]!</span>")
					deplete_spell()
					return
				var/obj/item/organ/external/BP = pick(human.bodyparts)
				BP.emp_act(EMP_HEAVY)
				BP.fracture()
			if(isrobot(target))
				var/mob/living/silicon/robot/robot = target
				var/datum/robot_component/RC = pick(robot.components)
				RC.destroy()
			add_attack_logs(user, target, "Crushed with [src]")
			deplete_spell()

// Clockwork robe. Basic robe from clockwork slab.
/obj/item/clothing/suit/hooded/clockrobe
	name = "clock robes"
	desc = "A set of robes worn by the followers of a clockwork cult."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockwork_robe"
	item_state = "clockwork_robe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/clockhood
	allowed = list(/obj/item/clockwork, /obj/item/twohanded/ratvarian_spear, /obj/item/twohanded/clock_hammer)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT
	magical = TRUE

/obj/item/clothing/head/hooded/clockhood
	name = "clock hood"
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clockhood"
	item_state = "clockhood"
	desc = "A hood worn by the followers of ratvar."
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)
	magical = TRUE

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
	allowed = list(/obj/item/clockwork, /obj/item/twohanded/ratvarian_spear, /obj/item/twohanded/clock_hammer)
	var/reflect_uses = 2

/obj/item/clothing/suit/armor/clockwork/Initialize(mapload)
	. = ..()
	enchants = GLOB.armour_spells

/obj/item/clothing/suit/armor/clockwork/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(enchant_type == REFLECT_SPELL && isclocker(owner))
		owner.visible_message("<span class='danger'>[attack_text] is deflected by [src] sparks!</span>")
		playsound(loc, "sparks", 100, TRUE)
		new /obj/effect/temp_visual/ratvar/sparks(get_turf(owner))
		if(reflect_uses <= 0)
			reflect_uses = 2
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
	switch(enchant_type)
		if(ARMOR_SPELL)
			if(!iscarbon(user))
				return
			var/mob/living/carbon/carbon = user
			if(carbon.wear_suit != src)
				return
			user.visible_message("<span class='danger'>[usr] concentrates as [user.p_their()] curiass shifts his plates!</span>",
			"<span class='notice'>The [src] becomes more hardened as the plates becomes to shift for any attack!</span>")
			armor = list("melee" = 70, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = 90, "bio" = 50, "rad" = 50, "fire" = 100, "acid" = 100)
			flags |= NODROP
			enchant_type = CASTING_SPELL
			add_attack_logs(user, user, "Hardened [src]", ATKLOG_ALL)
			addtimer(CALLBACK(src, .proc/reset_armor, user), 6 SECONDS)
		if(FLASH_SPELL)
			playsound(loc, 'sound/effects/phasein.ogg', 100, 1)
			set_light(2, 1, COLOR_WHITE)
			addtimer(CALLBACK(src, /atom./proc/set_light, 0), 0.2 SECONDS)
			usr.visible_message("<span class='disarm'>[user]'s [src] emits a blinding light!</span>", "<span class='danger'>Your [src] emits a blinding light!</span>")
			for(var/mob/living/carbon/M in oviewers(3, src))
				if(isclocker(M))
					return
				if(M.flash_eyes(2, 1))
					M.AdjustConfused(2)
					add_attack_logs(user, M, "Flashed with [src]")
			deplete_spell()

/obj/item/clothing/suit/armor/clockwork/proc/reset_armor(mob/user)
	to_chat(user, "<span class='notice'>The [src] stops shifting...</span>")
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 60, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	flags &= ~NODROP
	deplete_spell()


/obj/item/clothing/suit/armor/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if(slot == slot_wear_suit && !isclocker(user))
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
	desc = "Heavy, shock-resistant gauntlets with brass reinforcement."
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
	switch(enchant_type)
		if(FASTPUNCH_SPELL)
			if(user.mind.martial_art)
				to_chat(user, "<span class='warning'>You're too powerful to use it!</span>")
				return
			to_chat(user, "<span class='notice'>You fastening gloves making your moves agile!</span>")
			enchant_type = CASTING_SPELL
			north_star = TRUE
			add_attack_logs(user, user, "North-starred [src]", ATKLOG_ALL)
			addtimer(CALLBACK(src, .proc/reset), 8 SECONDS)
		if(FIRE_SPELL)
			user.visible_message("<span class='danger'>[user]'s gloves starts to burn!</span>", "<span class='notice>Your gloves becomes in red flames ready to burn any enemy in sight!</span>")
			enchant_type = CASTING_SPELL
			fire_casting = TRUE
			add_attack_logs(user, user, "Fire-casted [src]", ATKLOG_ALL)
			addtimer(CALLBACK(src, .proc/reset), 5 SECONDS)


/obj/item/clothing/gloves/clockwork/Touch(atom/A, proximity)
	var/mob/living/user = loc
	if(!(user.a_intent == INTENT_HARM) || !enchant_type)
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
	to_chat(usr, "<span class='notice'> [src] depletes last magic they had.</span>")
	deplete_spell()

/obj/item/clothing/gloves/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if(slot == slot_gloves && !isclocker(user))
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

/obj/item/clothing/shoes/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if(slot == slot_shoes && !isclocker(user))
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
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(melee = 50, bullet = 70, laser = 10, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)

/obj/item/clothing/head/helmet/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if(slot == slot_head && !isclocker(user))
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
			if(prob(2))
				playsound(apc, 'sound/machines/clockcult/steam_whoosh.ogg', 10, TRUE)
				new/obj/effect/temp_visual/small_smoke(get_turf(apc))

// Soul vessel (Posi Brain)
/obj/item/mmi/robotic_brain/clockwork
	name = "soul vessel"
	desc = "A heavy brass cube, three inches to a side, with a single protruding cogwheel."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "soul_vessel"
	blank_icon = "soul_vessel"
	searching_icon = "soul_vessel_search"
	occupied_icon = "soul_vessel_occupied"
	requires_master = FALSE
	ejected_flavor_text = "brass cube"
	dead_icon = "soul_vessel"
	clock = TRUE


/obj/item/mmi/robotic_brain/clockwork/proc/try_to_transfer(mob/living/target)
	for(var/obj/item/I in target)
		target.unEquip(I)
	if(target.client && target.ghost_can_reenter())
		transfer_personality(target)
		to_chat(target, "<span class='clocklarge'><b>\"You belong to me now.\"</b></span>")
		target.dust()
	else
		target.dust()
		icon_state = searching_icon
		searching = TRUE
		var/list/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Servant of Ratvar?", ROLE_CLOCKER, FALSE, poll_time = 10 SECONDS, source = /obj/item/mmi/robotic_brain/clockwork)
		if(candidates.len)
			transfer_personality(pick(candidates))
		reset_search()

	 // In any way we still make some power from him


/obj/item/mmi/robotic_brain/clockwork/transfer_personality(mob/candidate)
	searching = FALSE
	brainmob.key = candidate.key
	brainmob.name = "[pick(list("Nycun", "Oenib", "Havsbez", "Ubgry", "Fvreen"))]-[rand(10, 99)]"
	name = "[src] ([brainmob.name])"
	brainmob.mind.assigned_role = "Soul Vessel Cube"
	visible_message("<span class='notice'>[src] chimes quietly.</span>")
	become_occupied(occupied_icon)
	if(SSticker.mode.add_clocker(brainmob.mind))
		brainmob.create_log(CONVERSION_LOG, "[brainmob.mind] been converted by [src.name]")

/obj/item/mmi/robotic_brain/clockwork/attack_self(mob/living/user)
	if(!isclocker(user))
		to_chat(user, "<span class='warning'>You fiddle around with [src], to no avail.</span>")
		return
	to_chat(user, "<span class='warning'>You have to find a dead body to fill a vessel.</span>")

/obj/item/mmi/robotic_brain/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/storage/bible) && !isclocker(user) && user.mind.isholy)
		to_chat(user, "<span class='notice'>You begin to exorcise [src].</span>")
		playsound(src, 'sound/hallucinations/veryfar_noise.ogg', 40, TRUE)
		if(do_after(user, 40, target = src))
			var/obj/item/mmi/robotic_brain/purified = new(get_turf(src))
			if(brainmob.key)
				SSticker.mode.remove_clocker(brainmob.mind)
				purified.transfer_identity(brainmob)
			qdel(src)


/obj/item/mmi/robotic_brain/clockwork/attack(mob/living/M, mob/living/user, def_zone)
	if(!isclocker(user))
		user.Weaken(5)
		user.emote("scream")
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		to_chat(user, "<span class='clocklarge'>\"Don't even try.\"</span>")
		return

	if(!ishuman(M))
		return ..()

	if(M == user)
		return
	if(brainmob.key)
		to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
		return
	if(isclocker(M))
		to_chat(user, "<span class='clocklarge'>\"It would be more wise to revive your allies, friend.\"</span>")
		return
	if(jobban_isbanned(M, ROLE_CLOCKER) || jobban_isbanned(M, ROLE_SYNDICATE))
		to_chat(user, "<span class='warning'>A mysterious force prevents you from claiming [M]'s mind.</span>")
		return
	var/mob/living/carbon/human/H = M
	if(H.stat == CONSCIOUS)
		to_chat(user, "<span class='warning'>[H] must be dead or unconscious for you to claim [H.p_their()] mind!</span>")
		return
	if(H.has_brain_worms())
		to_chat(user, "<span class='warning'>[H] is corrupted by an alien intelligence and cannot claim [H.p_their()] mind!</span>")
		return
	if(!H.bodyparts_by_name["head"])
		to_chat(user, "<span class='warning'>[H] has no head, and thus no mind to claim!</span>")
		return
	if(!H.get_int_organ(/obj/item/organ/internal/brain))
		to_chat(user, "<span class='warning'>[H] has no brain, and thus no mind to claim!</span>")
		return

	user.visible_message("<span class='warning'>[user] starts pressing [src] to [H]'s head, ripping through the skull</span>", \
	"<span class='clock'>You start extracting [H]'s consciousness from [H.p_their()] body.</span>")
	if(searching)
		return
	if(do_after(user, 40, target = src))
		user.visible_message("<span class='warning'>[user] pressed [src] through [H]'s skull and extracted the brain!", \
		"<span class='clock'>You extracted [H]'s consciousness, trapping it in the soul vessel.")
		if(searching)
			return
		searching = TRUE
		try_to_transfer(H)
		return TRUE
	return

/obj/item/borg/upgrade/clockwork
	name = "Clockwork Module"
	desc = "An unique brass board, used by cyborg warriors."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "clock_mod"
	require_module = FALSE

/obj/item/borg/upgrade/clockwork/action(mob/living/silicon/robot/R)
	if(..())
		return
	R.ratvar_act() // weak false
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
		var/obj/item/mmi/robotic_brain/clockwork/soul = I
		if(!soul.brainmob.mind)
			to_chat(user, "<span class='warning'> There is no soul in [I]!</span>")
			return
		var/mob/living/simple_animal/hostile/clockwork/marauder/cog = new (get_turf(src))
		soul.brainmob.mind.transfer_to(cog)
		SSticker.mode.add_clock_actions(cog.mind)
		playsound(cog, 'sound/effects/constructform.ogg', 50)
		user.unEquip(soul)
		qdel(soul)
		qdel(src)

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

/obj/item/twohanded/clock_hammer/update_icon()
	update_overlays()
	return ..()

/obj/item/clockwork/shard/proc/update_overlays()
	cut_overlays()
	if(enchant_type)
		overlays += "shard_overlay_[enchant_type]"

/obj/item/clockwork/shard/attack_self(mob/user)
	if(!isclocker(user) && isliving(user))
		var/mob/living/L = user
		if(ishuman(L))
			to_chat(L, "<span class='danger'>[src] pierces into your hand!</span>")
			var/mob/living/carbon/human/H = L
			H.embed_item_inside(src)
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
				empulse(src, 4, 6, cause="clock")
				qdel(src)
			if(TIME_SPELL)
				qdel(src)
				add_attack_logs(user, user, "Time stopped with [src]")
				new /obj/effect/timestop/clockwork(get_turf(user))
			if(RECONSTRUCT_SPELL)
				add_attack_logs(user, user, "Reconstructed with [src]")
				new /obj/effect/temp_visual/ratvar/reconstruct(get_turf(src))
				qdel(src)
	return

/obj/effect/temp_visual/ratvar/reconstruct
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_active"
	layer = BELOW_OBJ_LAYER
	alpha = 128
	duration = 30
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/ratvar/reconstruct/Initialize(mapload)
	. = ..()
	transform = matrix() * 0.1
	reconstruct()

/obj/effect/temp_visual/ratvar/reconstruct/proc/reconstruct()
	playsound(src, 'sound/magic/clockwork/reconstruct.ogg', 50, TRUE)
	animate(src, transform = matrix() * 1, time = 1.5 SECONDS)
	sleep(15)
	for(var/atom/affected in range(3, get_turf(src)))
		if(isliving(affected))
			var/mob/living/living = affected
			living.ratvar_act(TRUE)
		else
			affected.ratvar_act()
	animate(src, transform = matrix() * 0.1, time = 1.5 SECONDS)
