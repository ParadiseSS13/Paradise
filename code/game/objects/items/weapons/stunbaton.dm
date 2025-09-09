/obj/item/melee/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "stunbaton"
	belt_icon = "stunbaton"
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	origin_tech = "combat=2"
	attack_verb = list("beaten")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, RAD = 0, FIRE = 80, ACID = 80)
	new_attack_chain = TRUE
	var/base_icon = "stunbaton"
	/// How many seconds does the knockdown last for?
	var/knockdown_duration = 10 SECONDS
	/// how much stamina damage does this baton do?
	var/stam_damage = 60 // 2 hits or 1 hit + 2 disabler shots
	/// Is the baton currently turned on
	var/turned_on = FALSE
	/// How much power does it cost to stun someone
	var/hitcost = 1000
	var/obj/item/stock_parts/cell/cell = null // Adminbus tip: make this something that isn't a cell :)
	/// the initial cooldown tracks the time between swings. tracks the world.time when the baton is usable again.
	var/cooldown = 3.5 SECONDS
	/// the time it takes before the target falls over
	var/knockdown_delay = 2.5 SECONDS
	COOLDOWN_DECLARE(stun_cooldown)

/obj/item/melee/baton/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/melee/baton/loaded/Initialize(mapload) //this one starts with a cell pre-installed.
	link_new_cell()
	return ..()

/obj/item/melee/baton/Destroy()
	if(cell?.loc == src)
		QDEL_NULL(cell)
	return ..()

/**
 * Updates the linked power cell on the baton.
 *
 * If the baton is held by a cyborg, link it to their internal cell.
 * Else, spawn a new cell and use that instead.
 * Arguments:
 * * unlink - If TRUE, sets the `cell` variable to `null` rather than linking it to a new one.
 */
/obj/item/melee/baton/proc/link_new_cell(unlink = FALSE)
	if(unlink)
		cell = null
		return

	if(isrobot(loc?.loc)) // First loc is the module
		var/mob/living/silicon/robot/R = loc.loc
		cell = R.cell
		return

	if(!cell)
		var/powercell = /obj/item/stock_parts/cell/high
		cell = new powercell(src)
	else
		cell = new cell(src)

/obj/item/melee/baton/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return FIRELOSS

/obj/item/melee/baton/update_icon_state()
	if(turned_on)
		icon_state = "[base_icon]_active"
	else if(!cell)
		icon_state = "[base_icon]_nocell"
	else
		icon_state = "[base_icon]"

/obj/item/melee/baton/examine(mob/user)
	. = ..()
	if(isrobot(user))
		. += "<span class='notice'>This baton is drawing power directly from your own internal charge.</span>"
	if(cell)
		. += "<span class='notice'>The baton is [round(cell.percent())]% charged.</span>"
	else
		. += "<span class='warning'>The baton does not have a power source installed.</span>"
	. += "<span class='notice'>When turned on this item will knockdown anyone it hits after a short delay. While on harm intent, this item will also do some brute damage, even if turned on.</span>"
	. += "<span class='notice'>This item can be recharged in a recharger. Using a screwdriver on this item will allow you to access its power cell, which can be replaced.</span>"


/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/mob_can_equip(mob/user, slot, disable_warning = TRUE) // disable the warning
	if(turned_on && (slot == ITEM_SLOT_BELT || slot == ITEM_SLOT_SUIT_STORE))
		to_chat(user, "<span class='warning'>You can't equip [src] while it's active!</span>")
		return FALSE
	return ..()

/obj/item/melee/baton/can_enter_storage(obj/item/storage/S, mob/user)
	if(turned_on)
		to_chat(user, "<span class='warning'>[S] can't hold [src] while it's active!</span>")
		return FALSE
	return TRUE

/**
  * Removes the specified amount of charge from the batons power cell.
  *
  * If `src` is a cyborg baton, this removes the charge from the borg's internal power cell instead.
  * Arguments:
  * * amount - The amount of battery charge to be used.
  */
/obj/item/melee/baton/proc/deductcharge(amount)
	if(!cell)
		return

	cell.use(amount)
	if(cell.rigged)
		cell = null
		turned_on = FALSE
		update_icon(UPDATE_ICON_STATE)
		return

	if(cell.charge < (hitcost)) // If after the deduction the baton doesn't have enough charge for a stun hit it turns off.
		turned_on = FALSE
		update_icon()
		playsound(src, "sparks", 75, TRUE, -1)

/obj/item/melee/baton/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ..()
	if(istype(used, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = used
		if(cell)
			to_chat(user, "<span class='warning'>[src] already has a cell!</span>")
			return ITEM_INTERACT_COMPLETE

		if(C.maxcharge < hitcost)
			to_chat(user, "<span class='warning'>[src] requires a higher capacity cell!</span>")
			return ITEM_INTERACT_COMPLETE

		if(!user.unequip(used))
			to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE

		used.forceMove(src)
		cell = used
		to_chat(user, "<span class='notice'>You install [used] into [src].</span>")
		update_icon(UPDATE_ICON_STATE)
		return ITEM_INTERACT_COMPLETE

/obj/item/melee/baton/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, "<span class='warning'>There's no cell installed!</span>")
		return

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	user.put_in_hands(cell)
	to_chat(user, "<span class='notice'>You remove [cell] from [src].</span>")
	cell.update_icon()
	cell = null
	turned_on = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/item/melee/baton/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	// Sometimes the borg baton spawns without linking to the cyborg's cell for reasons beyond my ken. That is VERY bad. This will fix it on the spot.
	// They have to turn it on to use it, after all.
	if(isrobot(loc) && !cell)
		link_new_cell()

	if(cell?.charge >= hitcost)
		turned_on = !turned_on
		to_chat(user, "<span class='notice'>[src] is now [turned_on ? "on" : "off"].</span>")
		playsound(src, "sparks", 75, TRUE, -1)
	else
		if(isrobot(loc))
			to_chat(user, "<span class='warning'>You do not have enough reserve power to charge [src]!</span>")
		else if(!cell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is out of charge.</span>")
	update_icon()
	add_fingerprint(user)

/obj/item/melee/baton/throw_impact(mob/living/carbon/human/hit_mob)
	. = ..()
	if(!. && turned_on && istype(hit_mob))
		thrown_baton_stun(hit_mob)

/obj/item/melee/baton/pre_attack(atom/atom_target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK

	if(turned_on && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		// For those super edge cases where you clumsy baton yourself in quick succession.
		if(baton_stun(user, user, skip_cooldown = TRUE))
			user.visible_message(
				"<span class='danger'>[user] accidentally hits [user.p_themselves()] with [src]!</span>",
				"<span class='userdanger'>You accidentally hit yourself with [src]!</span>"
				)
		return FINISH_ATTACK

	if(user.mind?.martial_art?.no_baton && user.mind?.martial_art?.can_use(user))
		to_chat(user, user.mind.martial_art.no_baton_reason)
		return FINISH_ATTACK

	if(!ismob(atom_target))
		return

	var/mob/living/target = atom_target

	if(user.a_intent == INTENT_HARM)
		return // Harmbaton!

	if(!turned_on)
		user.do_attack_animation(target)
		target.visible_message(
			"<span class='warning'>[user] has prodded [target] with [src]. Luckily it was off.</span>",
			"<span class='danger'>[target == user ? "You prod yourself" : "[user] has prodded you"] with [src]. Luckily it was off.</span>"
			)
		playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
		return FINISH_ATTACK | MELEE_COOLDOWN_PREATTACK

	// Only human mobs can be stunned.
	if(!ishuman(target))
		user.do_attack_animation(target)
		target.visible_message(
			"<span class='warning'>[user] has prodded [target] with [src]. It doesn't seem to have an effect.</span>",
			"<span class='danger'>[target == user ? "You prod yourself" : "[user] has prodded you"] with [src]. It doesn't seem to have an effect.</span>"
		)
		playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
		return FINISH_ATTACK | MELEE_COOLDOWN_PREATTACK

	if(baton_stun(target, user))
		user.do_attack_animation(target)
	return FINISH_ATTACK | MELEE_COOLDOWN_PREATTACK

/obj/item/melee/baton/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(ishuman(target) && turned_on)
		var/mob/living/carbon/human/H = target
		baton_stun(H, user)

/// returning false results in no baton attack animation, returning true results in an animation.
/obj/item/melee/baton/proc/baton_stun(mob/living/L, mob/user, skip_cooldown = FALSE)
	if(!COOLDOWN_FINISHED(src, stun_cooldown) && !skip_cooldown)
		return FALSE

	var/user_UID = user.UID()
	if(HAS_TRAIT_FROM(L, TRAIT_WAS_BATONNED, user_UID)) // prevents double baton cheese.
		return FALSE

	if(hitcost > 0 && cell?.charge < hitcost)
		to_chat(user, "<span class='warning'>[src] fizzles weakly as it makes contact. It needs more power!</span>")
		return FALSE

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			user.do_attack_animation(H)
			return FALSE

		H.Confused(10 SECONDS)
		H.Jitter(10 SECONDS)
		H.apply_damage(stam_damage, STAMINA)
		H.SetStuttering(10 SECONDS)

	COOLDOWN_START(src, stun_cooldown, cooldown)
	ADD_TRAIT(L, TRAIT_WAS_BATONNED, user_UID) // so one person cannot hit the same person with two separate batons
	L.apply_status_effect(STATUS_EFFECT_DELAYED, knockdown_delay, CALLBACK(L, TYPE_PROC_REF(/mob/living/, KnockDown), knockdown_duration), COMSIG_LIVING_CLEAR_STUNS)
	addtimer(CALLBACK(src, PROC_REF(baton_delay), L, user_UID), knockdown_delay)

	SEND_SIGNAL(L, COMSIG_LIVING_MINOR_SHOCK, 33)

	if(user)
		L.store_last_attacker(user)
		L.visible_message(
			"<span class='danger'>[user] has stunned [L] with [src]!</span>",
			"<span class='userdanger'>[L == user ? "You stun yourself" : "[user] has stunned you"] with [src]!</span>"
			)
		add_attack_logs(user, L, "stunned")
	play_hit_sound()
	deductcharge(hitcost)
	return TRUE

/obj/item/melee/baton/proc/play_hit_sound()
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)

/obj/item/melee/baton/proc/thrown_baton_stun(mob/living/carbon/human/L)
	if(!COOLDOWN_FINISHED(src, stun_cooldown))
		return FALSE

	var/user_UID = thrownby
	var/mob/user = locateUID(thrownby)
	if(!istype(user) || (user.mind?.martial_art?.no_baton && user.mind?.martial_art?.can_use(user)))
		return

	if(HAS_TRAIT_FROM(L, TRAIT_WAS_BATONNED, user_UID))
		return FALSE

	COOLDOWN_START(src, stun_cooldown, cooldown)
	L.Confused(4 SECONDS)
	L.Jitter(4 SECONDS)
	L.apply_damage(30, STAMINA)
	L.SetStuttering(4 SECONDS)

	ADD_TRAIT(L, TRAIT_WAS_BATONNED, user_UID) // so one person cannot hit the same person with two separate batons
	addtimer(CALLBACK(src, PROC_REF(baton_delay), L, user_UID), 2 SECONDS)

	SEND_SIGNAL(L, COMSIG_LIVING_MINOR_SHOCK, 33)

	L.store_last_attacker(user)
	L.visible_message("<span class='danger'>[src] stuns [L]!</span>")
	add_attack_logs(user, L, "stunned")
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	deductcharge(hitcost)
	return TRUE

/obj/item/melee/baton/proc/baton_delay(mob/living/target, user_UID)
	REMOVE_TRAIT(target, TRAIT_WAS_BATONNED, user_UID)

/obj/item/melee/baton/emp_act(severity)
	. = ..()
	if(cell)
		deductcharge(1000 / severity)

/obj/item/melee/baton/wash(mob/living/user, atom/source)
	if(turned_on && cell?.charge)
		flick("baton_active", source)
		baton_stun(user, user, skip_cooldown = TRUE)
		user.visible_message(
			"<span class='warning'>[user] shocks [user.p_themselves()] while attempting to wash the active [src]!</span>",
			"<span class='userdanger'>You unwisely attempt to wash [src] while it's still on.</span>"
			)
		return TRUE
	..()

/// baton used for security bots
/obj/item/melee/baton/infinite_cell
	hitcost = 0
	turned_on = TRUE

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod_nocell"
	base_icon = "stunprod"
	force = 3
	throwforce = 5
	knockdown_duration = 6 SECONDS
	w_class = WEIGHT_CLASS_BULKY
	hitcost = 2000
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	flags_2 = ALLOW_BELT_NO_JUMPSUIT_2 //Look, you can strap it to your back. You can strap it to your waist too.
	var/obj/item/assembly/igniter/sparkler = null

/obj/item/melee/baton/cattleprod/Initialize(mapload)
	. = ..()
	sparkler = new(src)

/obj/item/melee/baton/cattleprod/Destroy()
	QDEL_NULL(sparkler)
	return ..()

/obj/item/melee/baton/cattleprod/baton_stun(mob/living/L, mob/user, skip_cooldown = FALSE)
	if(sparkler.activate())
		return ..()

/obj/item/melee/baton/loaded/borg_stun_arm
	name = "electrically-charged arm"
	desc = "A piece of scrap metal wired directly to your power cell."
	icon = 'icons/mob/robot_items.dmi'
	base_icon = "elecarm"
	icon_state = "elecarm"
	hitcost = 100

/obj/item/melee/baton/loaded/borg_stun_arm/screwdriver_act(mob/living/user, obj/item/I)
	return FALSE

/obj/item/melee/baton/flayerprod
	name = "stunprod"
	desc = "A mechanical mass which you can use to incapacitate someone with."
	icon_state = "swarmprod"
	base_icon = "swarmprod"
	inhand_icon_state = "swarmprod"
	throwforce = 0 // Just in case
	knockdown_duration = 6 SECONDS
	knockdown_delay = 0 SECONDS
	w_class = WEIGHT_CLASS_BULKY
	flags = ABSTRACT | NODROP
	turned_on = TRUE
	cell = /obj/item/stock_parts/cell/flayerprod
	/// The duration that stunning someone will disable their radio for
	var/radio_disable_time = 8 SECONDS

/obj/item/melee/baton/flayerprod/Initialize(mapload) // We are not making a flayerprod without a cell
	link_new_cell()
	RegisterSignal(src, COMSIG_ACTIVATE_SELF, TYPE_PROC_REF(/datum, signal_cancel_activate_self))
	return ..()

/obj/item/melee/baton/flayerprod/update_icon_state()
	return

/obj/item/melee/baton/flayerprod/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/item/melee/baton/flayerprod/play_hit_sound()
	playsound(src, 'sound/weapons/egloves.ogg', 25, TRUE, -1, ignore_walls = FALSE)

/obj/item/melee/baton/flayerprod/baton_stun(mob/living/L, mob/user, skip_cooldown)
	if(..())
		disable_radio(L)
		return TRUE
	return FALSE

/obj/item/melee/baton/flayerprod/proc/disable_radio(mob/living/L)
	var/list/all_items = L.GetAllContents()
	for(var/obj/item/radio/R in all_items)
		R.radio_enable_timer = addtimer(CALLBACK(src, PROC_REF(enable_radio), R), radio_disable_time, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE | TIMER_DELETE_ME)
		R.on = FALSE
		R.listening = FALSE
		R.broadcasting = FALSE
		L.visible_message("<span class='warning'>[R] buzzes loudly as it short circuits!</span>", blind_message = "<span class='notice'>You hear a loud, electronic buzzing.</span>")

/obj/item/melee/baton/flayerprod/proc/enable_radio(obj/item/radio/R)
	if(QDELETED(R))
		return
	R.on = TRUE
	R.listening = TRUE

/obj/item/melee/baton/flayerprod/deductcharge(amount)
	if(cell.charge < hitcost)
		return
	cell.use(amount)

/obj/item/melee/baton/flayerprod/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This one seems to be able to interfere with radio headsets.</span>"
