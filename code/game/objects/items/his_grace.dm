// His Grace is a very special weapon granted only to traitor chaplains.
// When awakened, He thirsts for blood and begins ticking a "bloodthirst" counter.
// The wielder of His Grace is immune to stuns and gradually heals.
// If the wielder fails to feed His Grace in time, He will devour them and become incredibly aggressive.
// Leaving His Grace alone for some time will reset His thirst and put Him to sleep.
// Using His Grace effectively requires extreme speed and care.

/obj/item/his_grace
	name = "artistic toolbox"
	desc = "A toolbox painted bright green. Looking at it makes you feel uneasy."
	icon = 'icons/obj/storage.dmi'
	icon_state = "green"
	item_state = "artistic_toolbox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	force = 20
	attack_verb = list("robusted")
	hitsound = 'sound/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound =  'sound/items/handling/toolbox_pickup.ogg'

	/// Is our little toolbox awake?
	var/awakened = FALSE
	/// How hungry is His Grace?
	var/bloodthirst = HIS_GRACE_SATIATED
	var/prev_bloodthirst = HIS_GRACE_SATIATED
	var/force_bonus = 0
	var/ascended = FALSE
	var/victims = 0
	var/victims_needed = 25

	new_attack_chain = TRUE

/obj/item/his_grace/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	GLOB.poi_list |= src
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(move_gracefully))
	update_icon()

/obj/item/his_grace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	SSblackbox.record_feedback("ledger", "his_grace", victims, "victim_count")
	var/mob_counter = 0
	for(var/mob/living/L in src)
		L.forceMove(get_turf(src))
		mob_counter++
	SSblackbox.record_feedback("ledger", "his_grace", mob_counter, "mob_count")
	GLOB.poi_list -= src
	return ..()

/obj/item/his_grace/update_icon_state()
	icon_state = ascended ? "gold" : "green"
	item_state = ascended ? "toolbox_gold" : "artistic_toolbox"

/obj/item/his_grace/update_overlays()
	. = ..()
	if(ascended)
		. += "triple_latch"
	else if(awakened)
		. += "single_latch_open"
	else
		. += "single_latch"

/obj/item/his_grace/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	if(!awakened)
		INVOKE_ASYNC(src, PROC_REF(awaken), user)

/obj/item/his_grace/attack(mob/living/target, mob/living/user, params)
	if(awakened && target.stat)
		consume(target)
		return FINISH_ATTACK
	else
		return ..()

/obj/item/his_grace/attack_obj(obj/attacked_obj, mob/living/user, params)
	if(!awakened && (isstructure(attacked_obj) || ismachinery(attacked_obj)))
		return ..()
	var/mob/living/carbon/human/H = user
	H.changeNext_move(CLICK_CD_MELEE)
	H.do_attack_animation(attacked_obj)
	H.visible_message("<span class='danger'>[H] has hit [attacked_obj] with [src]!</span>", "<span class='danger'>You hit [attacked_obj] with [src]!</span>")
	var/damage = force
	attacked_obj.take_damage(damage * 3, BRUTE, MELEE, TRUE, get_dir(src, user), 30) // yoinked from breaching cleaver

/obj/item/his_grace/can_be_pulled(user, grab_state, force, show_message = FALSE) //you can't pull his grace
	return FALSE

/obj/item/his_grace/examine(mob/user)
	. = ..()

	if(!awakened)
		. += "<span class='his_grace'>[src] is latched closed.</span>"
		return

	switch(bloodthirst)
		if(HIS_GRACE_SATIATED to HIS_GRACE_PECKISH)
			. += "<span class='his_grace'>[src] isn't very hungry. Not yet.</span>"
		if(HIS_GRACE_PECKISH to HIS_GRACE_HUNGRY)
			. += "<span class='his_grace'>[src] would like a snack.</span>"
		if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
			. += "<span class='his_grace'>[src] is quite hungry now.</span>"
		if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
			. += "<span class='his_grace'>[src] is openly salivating at the sight of you. Be careful.</span>"
		if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
			. += "<span class='his_grace bold'>You walk a fine line. [src] is very close to devouring you.</span>"
		if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
			. += "<span class='his_grace bold'>[src] is shaking violently and staring directly at you.</span>"

/obj/item/his_grace/relaymove(mob/living/user, direction) //Allows changelings, etc. to climb out of Him after they revive, provided He isn't active
	if(!awakened)
		user.forceMove(get_turf(src))
		user.visible_message("<span class='warning'>[user] scrambles out of [src]!</span>", "<span class='notice'>You climb out of [src]!</span>")

/obj/item/his_grace/process()
	if(!bloodthirst)
		drowse()
		return
	if(bloodthirst < HIS_GRACE_CONSUME_OWNER)
		adjust_bloodthirst(0.5 + round(length(contents) * (1 / 10), 1))
	else
		adjust_bloodthirst(0.5) //don't cool off rapidly once we're at the point where His Grace consumes all.

	var/mob/living/carbon/human/master = get_atom_on_turf(src, /mob/living/carbon/human) // Only humans may wield Him
	if(!master || !istype(master))
		go_rabid()
		return

	if(!master.is_holding(src))
		go_rabid()
		return

	if(bloodthirst <= HIS_GRACE_CONSUME_OWNER || ascended)
		master.apply_status_effect(STATUS_EFFECT_HISGRACE)
		return

	// They didn't sacrifice enough people, so this is where we go ham
	master.visible_message("<span class='boldwarning'>[src] turns on [master]!</span>",
							"<span class='his_grace big bold'>[src] turns on you!</span>")
	do_attack_animation(master, used_item = src)
	master.emote("scream")
	master.remove_status_effect(STATUS_EFFECT_HISGRACE)
	set_nodrop(FALSE, master)
	master.Weaken(6 SECONDS)
	master.adjustBruteLoss(1000)
	playsound(master, 'sound/effects/splat.ogg', 100, FALSE)
	go_rabid()

/obj/item/his_grace/proc/go_rabid() // She Caerbannog on my rabid till I-
	forceMove(get_turf(src)) //no you can't put His Grace in a locker you just have to deal with Him
	if(bloodthirst < HIS_GRACE_CONSUME_OWNER)
		return
	if(bloodthirst >= HIS_GRACE_FALL_ASLEEP)
		drowse()
		return
	var/list/targets = list()
	for(var/mob/living/L in oview(2, src))
		targets += L
	if(!length(targets))
		return
	var/mob/living/L = pick(targets)
	step_to(src, L)
	if(Adjacent(L))
		if(!L.stat)
			L.visible_message("<span class='warning'>[src] lunges at [L]!</span>", "<span class='his_grace big bold'>[src] lunges at you!</span>")
			do_attack_animation(L, null, src)
			playsound(L, 'sound/weapons/smash.ogg', 50, TRUE)
			playsound(L, 'sound/misc/desceration-01.ogg', 50, TRUE)
			L.adjustBruteLoss(force)
			adjust_bloodthirst(-5) //Don't stop attacking they're right there!
		else
			consume(L)

/obj/item/his_grace/proc/awaken(mob/user) //Good morning, Mr. Grace.
	if(awakened)
		return
	awakened = TRUE
	user.visible_message("<span class='boldwarning'>[src] begins to rattle. He thirsts.</span>", "<span class='his_grace'>You flick [src]'s latch up. You hope this is a good idea.</span>")
	name = "His Grace"
	desc = "A bloodthirsty artifact created by a profane rite."
	gender = MALE
	adjust_bloodthirst(1)
	force_bonus = HIS_GRACE_FORCE_BONUS * length(contents)
	playsound(user, 'sound/effects/pope_entry.ogg', 100)
	update_icon()
	move_gracefully()

/obj/item/his_grace/proc/move_gracefully()
	SIGNAL_HANDLER

	if(!awakened)
		return
	animate_rumble(src)

/obj/item/his_grace/proc/drowse() //Good night, Mr. Grace.
	if(!awakened || ascended)
		return
	var/turf/T = get_turf(src)
	T.visible_message("<span class='boldwarning'>[src] slowly stops rattling and falls still, His latch snapping shut.</span>")
	playsound(loc, 'sound/weapons/batonextend.ogg', 100, TRUE)
	name = initial(name)
	desc = initial(desc)
	animate(src, transform = matrix())
	gender = initial(gender)
	force = initial(force)
	force_bonus = initial(force_bonus)
	awakened = FALSE
	bloodthirst = 0
	update_icon()

/obj/item/his_grace/proc/consume(mob/living/meal) //Here's your dinner, Mr. Grace.
	if(!meal)
		return

	meal.visible_message("<span class='warning'>[src] swings open and devours [meal]!</span>", "<span class='his_grace big bold'>[src] consumes you!</span>")
	meal.adjustBruteLoss(300)
	playsound(meal, 'sound/misc/desceration-02.ogg', 75, TRUE)
	playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
	meal.forceMove(src)

	force_bonus += (ascended ? ASCEND_BONUS : HIS_GRACE_FORCE_BONUS)

	prev_bloodthirst = bloodthirst
	if(ascended) // Otherwise there might be fractions where His Grace is droppable while ascended
		bloodthirst = prev_bloodthirst
	else if(prev_bloodthirst < HIS_GRACE_CONSUME_OWNER)
		bloodthirst = length(contents) //Never fully sated, and His hunger will only grow.
	else
		bloodthirst = HIS_GRACE_CONSUME_OWNER

	if(meal.mind)
		victims++
	if(victims >= victims_needed)
		ascend()
	update_stats()

/obj/item/his_grace/proc/adjust_bloodthirst(amt)
	prev_bloodthirst = bloodthirst
	if(ascended)
		bloodthirst = HIS_GRACE_CONSUME_OWNER // As to maximize their healing buff
		update_stats()
		return
	if(prev_bloodthirst < HIS_GRACE_CONSUME_OWNER)
		bloodthirst = clamp(bloodthirst + amt, HIS_GRACE_SATIATED, HIS_GRACE_CONSUME_OWNER)
	else
		bloodthirst = clamp(bloodthirst + amt, HIS_GRACE_CONSUME_OWNER, HIS_GRACE_FALL_ASLEEP)
	update_stats()

/obj/item/his_grace/proc/update_stats()
	var/mob/living/master = get_atom_on_turf(src, /mob/living)
	if(ascended) // Ascended is set to a specific bloodthirst anyways
		force = initial(force) + force_bonus
		set_nodrop(TRUE, master)
		return

	set_nodrop(FALSE, master)
	switch(bloodthirst)
		if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
			if(HIS_GRACE_CONSUME_OWNER > prev_bloodthirst)
				master.visible_message("<span class='userdanger'>[src] enters a frenzy!</span>")
		if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
			set_nodrop(TRUE, master)
			if(HIS_GRACE_STARVING > prev_bloodthirst)
				master.visible_message("<span class='boldwarning'>[src] is starving!</span>", "<span class='his_grace big'>[src]'s bloodlust overcomes you. [src] must be fed, or you will become His meal.\
				[force_bonus < 15 ? " And still, His power grows.":""]</span>")
				force_bonus = max(force_bonus, 15)
		if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
			set_nodrop(TRUE, master)
			if(HIS_GRACE_FAMISHED > prev_bloodthirst)
				master.visible_message("<span class='warning'>[src] is very hungry!</span>", "<span class='his_grace big'>Spines sink into your hand. [src] must feed immediately.\
				[force_bonus < 10 ? " His power grows.":""]</span>")
				force_bonus = max(force_bonus, 10)
			if(prev_bloodthirst >= HIS_GRACE_STARVING)
				master.visible_message("<span class='warning'>[src] is now only very hungry!</span>", "<span class='his_grace big'>Your bloodlust recedes.</span>")
		if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
			if(HIS_GRACE_HUNGRY > prev_bloodthirst)
				master.visible_message("<span class='warning'>[src] is getting hungry.</span>", "<span class='his_grace big'>You feel [src]'s hunger within you.\
				[force_bonus < 5 ? " His power grows.":""]</span>")
				force_bonus = max(force_bonus, 5)
			if(prev_bloodthirst >= HIS_GRACE_FAMISHED)
				master.visible_message("<span class='warning'>[src] is now only somewhat hungry.</span>", "<span class='his_grace'>[src]'s hunger recedes a little...</span>")
		if(HIS_GRACE_PECKISH to HIS_GRACE_HUNGRY)
			if(HIS_GRACE_PECKISH > prev_bloodthirst)
				master.visible_message("<span class='warning'>[src] is feeling snackish.</span>", "<span class='his_grace'>[src] begins to hunger.</span>")
			if(prev_bloodthirst >= HIS_GRACE_HUNGRY)
				master.visible_message("<span class='warning'>[src] is now only a little peckish.</span>", "<span class='his_grace big'>[src]'s hunger recedes somewhat...</span>")
		if(HIS_GRACE_SATIATED to HIS_GRACE_PECKISH)
			if(prev_bloodthirst >= HIS_GRACE_PECKISH)
				master.visible_message("<span class='warning'>[src] is satiated.</span>", "<span class='his_grace big'>[src]'s hunger recedes...</span>")
	force = initial(force) + force_bonus

/obj/item/his_grace/proc/ascend()
	if(ascended)
		return
	desc = "A legendary toolbox and a distant artifact from The Age of Three Powers. On its three latches engraved are the words \"The Sun\", \"The Moon\", and \"The Stars\". The entire toolbox has the words \"The World\" engraved into its sides."
	icon_state = "his_grace_ascended"
	item_state = "toolbox_gold"
	ascended = TRUE
	SSblackbox.record_feedback("amount", "his_grace_ascended", 1)
	update_icon()
	playsound(src, 'sound/effects/his_grace_ascend.ogg', 100)
	var/mob/living/carbon/human/master = loc
	if(istype(master))
		master.visible_message("<span class='his_grace big bold'>Gods will be watching.</span>")
		name = "[master]'s mythical toolbox of three powers"
		master.update_inv_l_hand()
		master.update_inv_r_hand()
