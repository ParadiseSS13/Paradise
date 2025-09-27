/* Toys!
 * Contains:
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy swords
 *		Toy mechs
 *		Snap pops
 *		Water flower
 *		Toy Nuke
 *		Card Deck
 *		Therapy dolls
 *		Inflatable duck
 *		Foam armblade
 *		Mini Gibber
 *		Toy xeno
 *		Toy chainsaws
 *		Action Figures
 */


/obj/item/toy
	throw_speed = 4
	throw_range = 20
	new_attack_chain = TRUE


/*
 * Balloons
 */
/obj/item/toy/balloon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"

/obj/item/toy/balloon/New()
	..()
	create_reagents(10)

/obj/item/toy/balloon/pre_attack(atom/target, mob/living/user, params)
	..()
	return FINISH_ATTACK

/obj/item/toy/balloon/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(istype(target, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/RD = target
		if(RD.reagents.total_volume <= 0)
			to_chat(user, "<span class='warning'>[RD] is empty.</span>")
		else if(reagents.total_volume >= 10)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		else
			target.reagents.trans_to(src, 10)
			to_chat(user, "<span class='notice'>You fill the balloon with the contents of [target].</span>")
			desc = "A translucent balloon with some form of liquid sloshing around in it."
			update_icon()

/obj/item/toy/balloon/wash(mob/user, atom/source)
	if(reagents.total_volume < 10)
		reagents.add_reagent("water", min(10-reagents.total_volume, 10))
		to_chat(user, "<span class='notice'>You fill the balloon from the [source].</span>")
		desc = "A translucent balloon with some form of liquid sloshing around in it."
		update_icon()
	return

/obj/item/toy/balloon/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	if(istype(attacking, /obj/item/reagent_containers/glass) || istype(attacking, /obj/item/reagent_containers/drinks/drinkingglass))
		if(attacking.reagents)
			if(attacking.reagents.total_volume < 1)
				to_chat(user, "[attacking] is empty.")
			else if(attacking.reagents.total_volume >= 1)
				if(attacking.reagents.has_reagent("facid", 1))
					to_chat(user, "The acid chews through the balloon!")
					attacking.reagents.reaction(user)
					qdel(src)
				else
					desc = "A translucent balloon with some form of liquid sloshing around in it."
					to_chat(user, "<span class='notice'>You fill the balloon with the contents of [attacking].</span>")
					attacking.reagents.trans_to(src, 10)
	update_icon()
	return

/obj/item/toy/balloon/throw_impact(atom/hit_atom)
	if(reagents.total_volume >= 1)
		visible_message("<span class='warning'>[src] bursts!</span>","You hear a pop and a splash.")
		reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			reagents.reaction(A)
		icon_state = "burst"
		spawn(5)
			if(src)
				qdel(src)
	return

/obj/item/toy/balloon/update_icon_state()
	if(src.reagents.total_volume >= 1)
		icon_state = "waterballoon"
	else
		icon_state = "waterballoon-e"

/obj/item/toy/syndicateballoon
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	icon_state = "syndballoon"
	w_class = WEIGHT_CLASS_BULKY
	var/lastused = null

/obj/item/toy/syndicateballoon/activate_self(mob/user)
	if(..() || world.time - lastused < CLICK_CD_MELEE)
		return
	var/playverb = pick("bat [src]", "tug on [src]'s string", "play with [src]")
	user.visible_message("<span class='notice'>[user] plays with [src].</span>", "<span class='notice'>You [playverb].</span>")
	lastused = world.time

/obj/item/toy/syndicateballoon/suicide_act(mob/living/user)
	. = ..()
	if(!user)
		return

	user.visible_message("<span class='suicide'>[user] ties [src] around [user.p_their()] neck and starts to float away! It looks like [user.p_theyre()] trying to commit suicide!</span>")

	playsound(get_turf(user), 'sound/magic/fleshtostone.ogg', 80, TRUE)

	user.Immobilize(10 SECONDS)

	// yes im stealing fulton code
	var/obj/effect/extraction_holder/holder_obj = new(get_turf(user))
	holder_obj.appearance = user.appearance

	user.forceMove(holder_obj)
	animate(holder_obj, pixel_z = 1000, time = 50)

	for(var/obj/item/W in user)
		user.drop_item_to_ground(W)

	user.notransform = TRUE
	icon = null
	invisibility = 101
	QDEL_IN(user, 2 SECONDS)
	QDEL_IN(src, 2 SECONDS)
	return OBLITERATION

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink. Blink. Blink. Ages 8 and up."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	inhand_icon_state = "signaler"

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "Gravitational Singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/weapons/energy_melee.dmi'
	icon_state = "sword"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	var/active = FALSE
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "struck", "hit")

/obj/item/toy/sword/activate_self(mob/user)
	if(..())
		return
	active = !active
	if(active)
		to_chat(user, "<span class='notice'>You extend the plastic blade with a quick flick of your wrist.</span>")
		playsound(user, 'sound/weapons/saberon.ogg', 20, 1)
		icon_state = "swordblue"
		w_class = WEIGHT_CLASS_BULKY
	else
		to_chat(user, "<span class='notice'>You push the plastic blade back down into the handle.</span>")
		playsound(user, 'sound/weapons/saberoff.ogg', 20, 1)
		icon_state = "sword"
		w_class = WEIGHT_CLASS_SMALL

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)

/obj/item/toy/sword/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	if(istype(attacking, /obj/item/toy/sword))
		if(attacking == src)
			to_chat(user, "<span class='notice'>You try to attach the end of the plastic sword to... Itself. You're not very smart, are you?</span>")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.adjustBrainLoss(10)
		else if((attacking.flags & NODROP) || (flags & NODROP))
			to_chat(user, "<span class='notice'>\the [flags & NODROP ? src : attacking] is stuck to your hand, you can't attach it to \the [flags & NODROP ? attacking : src]!</span>")
		else
			to_chat(user, "<span class='notice'>You attach the ends of the two plastic swords, making a single double-bladed toy! You're fake-cool.</span>")
			new /obj/item/dualsaber/toy(user.loc)
			qdel(attacking)
			qdel(src)

/obj/item/toy/sword/chaosprank
	name = "energy sword"
	/// Sets to TRUE once the character using it hits something and realises it's not a real energy sword
	var/pranked = FALSE

/obj/item/toy/sword/attack(mob/living/target, mob/living/carbon/human/user)
	if(..() || cigarette_lighter_act(user, target))
		return FINISH_ATTACK

/obj/item/toy/sword/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!active)
		to_chat(user, "<span class='warning'>You must activate [src] before you can light [cig] with it!</span>")
		return TRUE

	user.do_attack_animation(target)

	// 1% chance to light the cig. Somehow...
	if(prob(1))
		if(target == user)
			user.visible_message(
				"<span class='warning'>[user] makes a violent slashing motion, barely missing [user.p_their()] nose as light flashes! \
				[user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [cig] with [src] in the process. Somehow...</span>",
				"<span class='notice'>You casually slash [src] at [cig], lighting it with the blade. Somehow...</span>",
				"<span class='danger'>You hear an energy blade slashing something!</span>"
			)
		else
			user.visible_message(
				"<span class='danger'>[user] makes a violent slashing motion, barely missing the nose of [target] as light flashes! \
				[user.p_they(TRUE)] light[user.p_s()] [cig] in the mouth of [target] with [src] in the process. Somehow...</span>",
				"<span class='notice'>You casually slash [src] at [cig] in the mouth of [target], lighting it with the blade. Somehow...</span>",
				"<span class='danger'>You hear an energy blade slashing something!</span>"
			)
		playsound(user.loc, 'sound/weapons/blade1.ogg', 50, TRUE)
		cig.light(user, target)
		return TRUE

	// Else, bat it out of the target's mouth.
	if(target == user)
		user.visible_message(
			"<span class='warning'>[user] makes a violent slashing motion, barely missing [user.p_their()] nose as light flashes! \
			[user.p_they(TRUE)] instead hit [cig], knocking it out of [user.p_their()] mouth and dropping it to the floor.</span>",
			"<span class='warning'>You casually slash [src] at [cig], swatting it out of your mouth.</span>",
			"<span class='notice'>You hear a gentle tapping.</span>"
		)
	else
		user.visible_message(
			"<span class='warning'>[user] makes a violent slashing motion, barely missing the nose of [target] as light flashes! \
			[user] does hit [cig], knocking it out of the mouth of [target] and dropping it to the floor. Wow, rude!</span>",
			"<span class='warning'>You casually slash [src] at [cig] in the mouth of [target], swatting it to the floor!</span>",
			"<span class='notice'>You hear a gentle tapping.</span>"
		)
	playsound(loc, 'sound/weapons/tap.ogg', vary = TRUE)
	target.drop_item_to_ground(cig, TRUE)
	return TRUE

/obj/item/toy/sword/chaosprank/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!pranked)
		to_chat(user, "<span class='chaosverybad'>Oh... It's a fake.</span>")
		name = "toy sword"
		pranked = TRUE

/*
 * Subtype of Double-Bladed Energy Swords
 */
/obj/item/dualsaber/toy
	name = "double-bladed toy sword"
	desc = "A cheap, plastic replica of TWO energy swords. Double the fun!"
	force = 0
	throwforce = 0
	throw_speed = 3
	origin_tech = null
	attack_verb = list("attacked", "struck", "hit")
	brightness_on = 0
	needs_permit = FALSE

/obj/item/dualsaber/toy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, only_sharp_when_wielded = FALSE, force_wielded = 0, force_unwielded = 0)

/obj/item/dualsaber/toy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return 0

/obj/item/dualsaber/toy/IsReflect()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return 2

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "katana"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	flags_2 = ALLOW_BELT_NO_JUMPSUIT_2 //Look, you can strap it to your back. You can strap it to your waist too.
	force = 5
	throwforce = 5
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/toy/katana/suicide_act(mob/user)
	var/dmsg = pick(
		"[user] tries to stab [src] into [user.p_their()] abdomen, but it shatters! [user.p_they(TRUE)] look[user.p_s()] as if [user.p_they()] might die from the shame.",
		"[user] tries to stab [src] into [user.p_their()] abdomen, but [src] bends and breaks in half! [user.p_they(TRUE)] look[user.p_s()] as if [user.p_they()] might die from the shame.",
		"[user] tries to slice [user.p_their()] own throat, but the plastic blade has no sharpness, causing [user.p_them()] to lose [user.p_their()] balance, slip over, and break [user.p_their()] neck with a loud snap!")
	user.visible_message("<span class='suicide'>[dmsg] It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS


/*
 * Snap pops viral shit
 */
/obj/item/toy/snappop/virus
	name = "unstable goo"
	desc = "Your palm is oozing this stuff!"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "red slime extract"
	throwforce = 5.0
	throw_speed = 10
	throw_range = 30


/obj/item/toy/snappop/virus/throw_impact(atom/hit_atom)
	..()
	do_sparks(3, 1, src)
	new /obj/effect/decal/cleanable/ash(src.loc)
	visible_message("<span class='warning'>[src] explodes!</span>","<span class='warning'>You hear a bang!</span>")
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY
	var/ash_type = /obj/effect/decal/cleanable/ash

/obj/item/toy/snappop/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/toy/snappop/proc/pop_burst(n=3, c=1)
	do_sparks(n, c, src)
	new ash_type(loc)
	visible_message("<span class='warning'>[src] explodes!</span>",
		"<span class='italics'>You hear a snap!</span>")
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/obj/item/toy/snappop/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	pop_burst()

/obj/item/toy/snappop/throw_impact(atom/hit_atom)
	..()
	pop_burst()

/obj/item/toy/snappop/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(ishuman(entered) || issilicon(entered)) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = entered
		if(issilicon(entered) || M.m_intent == MOVE_INTENT_RUN)
			to_chat(M, "<span class='danger'>You step on the snap pop!</span>")
			pop_burst(2, 0)

/obj/item/toy/snappop/phoenix
	name = "phoenix snap pop"
	desc = "Wow! And wow! And wow!"
	ash_type = /obj/effect/decal/cleanable/ash/snappop_phoenix

/obj/effect/decal/cleanable/ash/snappop_phoenix
	var/respawn_time = 300

/obj/effect/decal/cleanable/ash/snappop_phoenix/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(respawn)), respawn_time)

/obj/effect/decal/cleanable/ash/snappop_phoenix/proc/respawn()
	new /obj/item/toy/snappop/phoenix(get_turf(src))
	qdel(src)


/obj/item/toy/nuke
	name = "\improper Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoyidle"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/nuke/activate_self(mob/user)
	if(..())
		return
	if(cooldown < world.time)
		cooldown = world.time + 1800 //3 minutes
		user.visible_message("<span class='warning'>[user] presses a button on [src]</span>", "<span class='notice'>You activate [src], it plays a loud noise!</span>", "<span class='notice'>You hear the click of a button.</span>")
		spawn(5) //gia said so
			icon_state = "nuketoy"
			playsound(src, 'sound/machines/alarm.ogg', 100, FALSE, 0)
			sleep(135)
			icon_state = "nuketoycool"
			sleep(cooldown - world.time)
			icon_state = "nuketoyidle"
	else
		var/timeleft = (cooldown - world.time)
		to_chat(user, "<span class='alert'>Nothing happens, and '</span>[round(timeleft/10)]<span class='alert'>' appears on a small display.</span>")

/obj/item/toy/therapy
	name = "therapy doll"
	desc = "A toy for therapeutic and recreational purposes."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapyred"
	inhand_icon_state = "egg4"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	var/cooldown = 0
	/// Color of the doll. Affects appearance, make sure there is appropriate icon_state in icon file
	var/doll_color

/obj/item/toy/therapy/Initialize(mapload)
	. = ..()
	if(doll_color)
		name = "[doll_color] therapy doll"
		desc += " This one is [doll_color]."
		icon_state = "therapy[doll_color]"

/obj/item/toy/therapy/activate_self(mob/user)
	if(..() || !(cooldown < world.time - 8))
		return
	to_chat(user, "<span class='notice'>You relieve some stress with \the [src].</span>")
	playsound(user, 'sound/items/squeaktoy.ogg', 20, TRUE)
	cooldown = world.time

/obj/item/toy/therapy/red
	doll_color = "red"

/obj/item/toy/therapy/purple
	inhand_icon_state = "egg1" // It's the magenta egg in items_left/righthand
	doll_color = "purple"

/obj/item/toy/therapy/blue
	inhand_icon_state = "egg2" // It's the blue egg in items_left/righthand
	doll_color = "blue"

/obj/item/toy/therapy/yellow
	inhand_icon_state = "egg5" // It's the yellow egg in items_left/righthand
	doll_color = "yellow"

/obj/item/toy/therapy/orange
	doll_color = "orange"

/obj/item/toy/therapy/green
	inhand_icon_state = "egg3" // It's the green egg in items_left/righthand
	doll_color = "green"

/*
 * Fake meteor
 */

/obj/item/toy/minimeteor
	name = "Mini-Meteor"
	desc = "Relive the excitement of a meteor shower! SweetMeat-eor. Co is not responsible for any injuries, headaches or hearing loss caused by Mini-Meteor."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minimeteor"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/minimeteor/throw_impact(atom/hit_atom)
	..()
	playsound(src, 'sound/effects/meteorimpact.ogg', 40, 1)
	for(var/mob/M in range(10, src))
		if(!M.stat && !is_ai(M))\
			shake_camera(M, 3, 1)
	qdel(src)

/*
 * Carp plushie
 */

/obj/item/toy/plushie/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon_state = "carpplushie"
	attack_verb = list("bitten", "eaten", "fin slapped")
	poof_sound = list('sound/weapons/bite.ogg' = 1)


/obj/item/toy/plushie/carpplushie/ice
	icon_state = "icecarp"

/obj/item/toy/plushie/carpplushie/silent
	icon_state = "silentcarp"

/obj/item/toy/plushie/carpplushie/electric
	icon_state = "electriccarp"

/obj/item/toy/plushie/carpplushie/gold
	icon_state = "goldcarp"

/obj/item/toy/plushie/carpplushie/toxin
	icon_state = "toxincarp"

/obj/item/toy/plushie/carpplushie/dragon
	icon_state = "dragoncarp"

/obj/item/toy/plushie/carpplushie/pink
	icon_state = "pinkcarp"

/obj/item/toy/plushie/carpplushie/candy
	icon_state = "candycarp"

/obj/item/toy/plushie/carpplushie/nebula
	icon_state = "nebulacarp"

/obj/item/toy/plushie/carpplushie/void
	icon_state = "voidcarp"

/*
 * Plushie
 */


/obj/item/toy/plushie
	name = "plushie"
	desc = "An adorable, soft, and cuddly plushie."
	icon = 'icons/obj/toy.dmi'
	attack_verb = list("poofed", "bopped", "whapped","cuddled","fluffed")
	resistance_flags = FLAMMABLE
	var/list/poof_sound = list('sound/weapons/thudswoosh.ogg' = 1)
	var/has_stuffing = TRUE //If the plushie has stuffing in it
	var/obj/item/grenade/grenade //You can remove the stuffing from a plushie and add a grenade to it for *nefarious uses*
	var/sound/rare_hug_sound
	var/rare_hug_word
	/// This is a variable that stores a mob that has been cursed into a plushie inside it.
	var/mob/living/cursed_plushie_victim
	COOLDOWN_DECLARE(rare_hug_cooldown)


/obj/item/toy/plushie/attack(mob/living/target, mob/living/carbon/human/user)
	if(..())
		return FINISH_ATTACK
	playsound(loc, pickweight(poof_sound), 20, 1)	// Play the whoosh sound in local area
	if(iscarbon(target))
		if(prob(10))
			target.reagents.add_reagent("hugs", 10)

/obj/item/toy/plushie/activate_self(mob/user as mob)
	if(..())
		return
	if(has_stuffing || grenade)
		if(rare_hug_sound && rare_hug_word && COOLDOWN_FINISHED(src, rare_hug_cooldown))
			playsound(src, rare_hug_sound , 10, FALSE)
			visible_message("<span class='danger'>[rare_hug_word]</span>")
			COOLDOWN_START(src, rare_hug_cooldown, 3 SECONDS)
		else
			var/cuddle_verb = pick("hugs", "cuddles", "snugs")
			user.visible_message("<span class='notice'>[user] [cuddle_verb] [src].</span>")
			playsound(get_turf(src), pickweight(poof_sound), 50, TRUE, -1)
		if(grenade && !grenade.active)
			add_attack_logs(user, user, "activated a hidden grenade in [src].", ATKLOG_MOST)
			playsound(loc, 'sound/weapons/armbomb.ogg', 10, TRUE, -3)
			//We call with grenade as argument, so cutting the grenade out doesn't magically defuse it
			addtimer(CALLBACK(src, PROC_REF(explosive_betrayal), grenade), rand(1, 3) SECONDS)
	else
		to_chat(user, "<span class='notice'>You try to pet [src], but it has no stuffing. Aww...</span>")


/obj/item/toy/plushie/proc/explosive_betrayal(obj/item/grenade/grenade_callback)
	var/grenade_inside = FALSE //Any grenade, even non-explosive, will destroy the plushie.
	if(grenade)
		grenade_inside = TRUE
	grenade_callback.prime()
	if(grenade_inside && !QDELETED(src))
		qdel(src)

/obj/item/toy/plushie/Destroy()
	QDEL_NULL(grenade)
	QDEL_NULL(cursed_plushie_victim)
	return ..()

/obj/item/toy/plushie/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	if(attacking.sharp)
		if(!grenade)
			if(!has_stuffing)
				to_chat(user, "<span class='warning'>You already murdered it!</span>")
				return FINISH_ATTACK
			user.visible_message("<span class='warning'>[user] tears out the stuffing from [src]!</span>", "<span class='notice'>You rip a bunch of the stuffing from [src]. Murderer.</span>")
			attacking.play_tool_sound(src)
			has_stuffing = FALSE
		else
			to_chat(user, "<span class='notice'>You remove the grenade from [src].</span>")
			grenade.forceMove(get_turf(src))
			user.put_in_hands(grenade)
			grenade = null
		return FINISH_ATTACK
	if(istype(attacking, /obj/item/grenade))
		if(has_stuffing)
			to_chat(user, "<span class='warning'>You need to remove some stuffing first!</span>")
			return FINISH_ATTACK
		if(grenade)
			to_chat(user, "<span class='warning'>[src] already has a grenade!</span>")
			return FINISH_ATTACK
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[attacking] is stuck to you and cannot be placed into [src].</span>")
			return FINISH_ATTACK
		user.visible_message("<span class='warning'>[user] slides [attacking] into [src].</span>", \
		"<span class='warning'>You slide [attacking] into [src].</span>")
		attacking.forceMove(src)
		grenade = attacking
		add_attack_logs(user, user, "placed a hidden grenade in [src].", ATKLOG_ALMOSTALL)
		return FINISH_ATTACK

/obj/item/toy/plushie/proc/un_plushify()
	if(!cursed_plushie_victim)
		return
	cursed_plushie_victim.forceMove(get_turf(src))
	cursed_plushie_victim.status_flags &= ~GODMODE
	cursed_plushie_victim.notransform = FALSE

	for(var/mob/living/simple_animal/shade/sword/generic_item/B in contents)
		cursed_plushie_victim.key = B.key
		break
	cursed_plushie_victim = null
	qdel(src)

/obj/item/toy/plushie/corgi
	name = "corgi plushie"
	icon_state = "corgi"

/obj/item/toy/plushie/girly_corgi
	name = "corgi plushie"
	icon_state = "girlycorgi"

/obj/item/toy/plushie/robo_corgi
	name = "borgi plushie"
	icon_state = "robotcorgi"

/obj/item/toy/plushie/octopus
	name = "octopus plushie"
	icon_state = "loveable"

/obj/item/toy/plushie/face_hugger
	name = "facehugger plushie"
	icon_state = "huggable"

//foxes are basically the best

/obj/item/toy/plushie/red_fox
	name = "red fox plushie"
	icon_state = "redfox"

/obj/item/toy/plushie/black_fox
	name = "black fox plushie"
	icon_state = "blackfox"

/obj/item/toy/plushie/marble_fox
	name = "marble fox plushie"
	icon_state = "marblefox"

/obj/item/toy/plushie/blue_fox
	name = "blue fox plushie"
	icon_state = "bluefox"

/obj/item/toy/plushie/orange_fox
	name = "orange fox plushie"
	icon_state = "orangefox"

/obj/item/toy/plushie/orange_fox/grump
	name = "grumpy fox"
	desc = "An ancient plushie that seems particularly grumpy."

/obj/item/toy/plushie/orange_fox/grump/Initialize(mapload)
	. = ..()
	var/static/list/grumps = list("Ahh, yes, you're so clever, var editing that.", "Really?", "If you make a runtime with var edits, it's your own damn fault.",
	"Don't you dare post issues on the git when you don't even know how this works.", "Was that necessary?", "Ohhh, setting admin edited var must be your favorite pastime!",
	"Oh, so you have time to var edit, but you don't have time to ban that greytider?", "Oh boy, is this another one of those 'events'?", "Seriously, just stop.", "You do realize this is incurring proc call overhead.",
	"Congrats, you just left a reference with your dirty client and now that thing you edited will never garbage collect properly.", "Is it that time of day, again, for unecessary adminbus?")
	AddComponent(/datum/component/edit_complainer, grumps)

/obj/item/toy/plushie/coffee_fox
	name = "coffee fox plushie"
	icon_state = "coffeefox"

/obj/item/toy/plushie/pink_fox
	name = "pink fox plushie"
	icon_state = "pinkfox"

/obj/item/toy/plushie/purple_fox
	name = "purple fox plushie"
	icon_state = "purplefox"

/obj/item/toy/plushie/crimson_fox
	name = "crimson fox plushie"
	icon_state = "crimsonfox"

/obj/item/toy/plushie/deer
	name = "deer plushie"
	icon_state = "deer"

/obj/item/toy/plushie/black_cat
	name = "black cat plushie"
	icon_state = "blackcat"

/obj/item/toy/plushie/grey_cat
	name = "grey cat plushie"
	icon_state = "greycat"

/obj/item/toy/plushie/white_cat
	name = "white cat plushie"
	icon_state = "whitecat"

/obj/item/toy/plushie/orange_cat
	name = "orange cat plushie"
	icon_state = "orangecat"

/obj/item/toy/plushie/siamese_cat
	name = "siamese cat plushie"
	icon_state = "siamesecat"

/obj/item/toy/plushie/tabby_cat
	name = "tabby cat plushie"
	icon_state = "tabbycat"

/obj/item/toy/plushie/tuxedo_cat
	name = "tuxedo cat plushie"
	icon_state = "tuxedocat"

/obj/item/toy/plushie/greyplushie
	name = "grey plushie"
	desc = "A plushie of a grey wearing a sweatshirt. As a part of the 'The Alien' series, the doll features a sweater, an oversized head, and cartoonish eyes."
	icon_state = "plushie_grey"
	var/hug_cooldown = FALSE //Defaults the plushie to being off coolodown. Sets the hug_cooldown var.
	var/scream_cooldown = FALSE //Defaults the plushie to being off cooldown. Sets the scream_cooldown var.
	var/singed = FALSE

/obj/item/toy/plushie/greyplushie/water_act(volume, temperature, source, method = REAGENT_TOUCH) //If water touches the plushie the following code executes.
	. = ..()
	if(scream_cooldown)
		return
	scream_cooldown = TRUE //water_act executes the scream_cooldown var, setting it on cooldown.
	addtimer(CALLBACK(src, PROC_REF(reset_screamdown)), 30 SECONDS) //After 30 seconds the reset_coolodown() proc will execute, resetting the cooldown. Hug interaction is unnaffected by this.
	playsound(src, 'sound/goonstation/voice/male_scream.ogg', 10, FALSE)//If the plushie gets wet it screams and "AAAAAH!" appears in chat.
	visible_message("<span class='danger'>AAAAAAH!</span>")
	if(singed)
		return
	singed = TRUE
	icon_state = "grey_singed"
	desc = "A ruined plushie of a grey. It looks like someone ran it under some water."

/obj/item/toy/plushie/greyplushie/proc/reset_screamdown()
	scream_cooldown = FALSE //Resets the scream interaction cooldown.

/obj/item/toy/plushie/greyplushie/proc/reset_hugdown()
	hug_cooldown = FALSE //Resets the hug interaction cooldown.

/obj/item/toy/plushie/greyplushie/activate_self(mob/user)//code for talking when hugged.
	if(..() || hug_cooldown)
		return
	hug_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_hugdown)), 5 SECONDS) //Hug interactions only put the plushie on a 5 second cooldown.
	if(singed)//If the plushie is water damaged it'll say Ow instead of talking in wingdings.
		visible_message("<span class='danger'>Ow...</span>")
	else//If the plushie has not touched water they'll say Greetings in wingdings.
		visible_message("<span class='danger'>☝︎❒︎♏︎♏︎⧫︎♓︎■︎♑︎⬧︎📬︎</span>")

/obj/item/toy/plushie/voxplushie
	name = "vox plushie"
	desc = "A stitched-together vox, fresh from the skipjack. Press its belly to hear it skree!"
	icon_state = "plushie_vox"
	rare_hug_sound = 'sound/voice/shriek1.ogg'
	rare_hug_word = "Skreee!"

/obj/item/toy/plushie/ipcplushie
	name = "IPC plushie"
	desc = "An adorable IPC plushie, straight from New Canaan. Arguably more durable than the real deal. Toaster functionality included."
	icon_state = "plushie_ipc"

/obj/item/toy/plushie/ipcplushie/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	if(istype(attacking, /obj/item/food/sliced/bread))
		new /obj/item/food/toast(get_turf(loc))
		to_chat(user, "<span class='notice'>You insert bread into the toaster.</span>")
		playsound(loc, 'sound/machines/ding.ogg', 50, 1)
		qdel(attacking)
		return FINISH_ATTACK

//New generation TG plushies

/obj/item/toy/plushie/lizardplushie
	name = "lizard plushie"
	desc = "An adorable stuffed toy that resembles a lizardperson."
	icon_state = "plushie_lizard"

/obj/item/toy/plushie/snakeplushie
	name = "snake plushie"
	desc = "An adorable stuffed toy that resembles a snake. Not to be mistaken for the real thing."
	icon_state = "plushie_snake"

/obj/item/toy/plushie/nukeplushie
	name = "operative plushie"
	desc = "An stuffed toy that resembles a syndicate nuclear operative. The tag claims operatives to be purely fictitious."
	icon_state = "plushie_nuke"

/obj/item/toy/plushie/slimeplushie
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon_state = "plushie_slime"

/obj/item/toy/plushie/nianplushie
	name = "nian plushie"
	desc = "A silky nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian"
	rare_hug_sound = 'sound/voice/scream_moth.ogg'
	rare_hug_word = "Buzzzz!"

/obj/item/toy/plushie/nianplushie/monarch
	name = "monarch nian plushie"
	desc = "A monarch nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_monarch"

/obj/item/toy/plushie/nianplushie/luna
	name = "luna nian plushie"
	desc = "A luna nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_luna"

/obj/item/toy/plushie/nianplushie/atlas
	name = "atlas nian plushie"
	desc = "An atlas nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_atlas"

/obj/item/toy/plushie/nianplushie/reddish
	name = "reddish nian plushie"
	desc = "A reddish nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_reddish"

/obj/item/toy/plushie/nianplushie/royal
	name = "royal nian plushie"
	desc = "A royal nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_royal"

/obj/item/toy/plushie/nianplushie/gothic
	name = "gothic nian plushie"
	desc = "A gothic nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_gothic"

/obj/item/toy/plushie/nianplushie/lovers
	name = "lovers nian plushie"
	desc = "A lovers nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_lovers"

/obj/item/toy/plushie/nianplushie/whitefly
	name = "whitefly nian plushie"
	desc = "A whitefly nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_whitefly"

/obj/item/toy/plushie/nianplushie/punished
	name = "punished nian plushie"
	desc = "A punnished nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_punished"

/obj/item/toy/plushie/nianplushie/firewatch
	name = "firewatch nian plushie"
	desc = "A firewtach nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_firewatch"

/obj/item/toy/plushie/nianplushie/deadhead
	name = "deathshead nian plushie"
	desc = "A deathshead nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_deadhead"

/obj/item/toy/plushie/nianplushie/poison
	name = "poison nian plushie"
	desc = "A poison nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_poison"

/obj/item/toy/plushie/nianplushie/ragged
	name = "ragged nian plushie"
	desc = "A ragged nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_ragged"

/obj/item/toy/plushie/nianplushie/snow
	name = "snow nian plushie"
	desc = "A snow nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_snow"

/obj/item/toy/plushie/nianplushie/clockwork
	name = "clockwork nian plushie"
	desc = "A clockwork nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_clockwork"

/obj/item/toy/plushie/nianplushie/moonfly
	name = "moonfly nian plushie"
	desc = "A moonfly nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_moonfly"

/obj/item/toy/plushie/nianplushie/rainbow
	name = "rainbow nian plushie"
	desc = "A rainbow nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian_rainbow"

/obj/item/toy/plushie/shark
	name = "shark plushie"
	desc = "A plushie depicting a somewhat cartoonish shark. The tag calls it a 'hákarl', noting that it was made by an obscure furniture manufacturer in old Scandinavia."
	icon_state = "blahaj"
	attack_verb = list("gnawed", "gnashed", "chewed")

/obj/item/toy/plushie/abductor
	name = "abductor plushie"
	desc = "A plushie depicting an alien abductor. The tag on it is in an indecipherable language."
	icon_state = "abductor"
	attack_verb = list("abducted", "probed")
	poof_sound = list('sound/weather/ashstorm/inside/weak_end.ogg' = 1) //very faint sound since abductors are silent as far as "speaking" is concerned.

/obj/item/toy/plushie/abductor/agent
	name = "abductor agent plushie"
	desc = "A plushie depicting an alien abductor agent. The stun baton is attached to the hand of the plushie, and appears to be inert. I wouldn't stay alone with it."
	icon_state = "abductor_agent"
	attack_verb = list("abducted", "probed", "stunned")
	poof_sound = list(
		'sound/weapons/egloves.ogg' = 2,
		'sound/weapons/cablecuff.ogg' = 1,
	)

/obj/item/toy/plushie/skrellplushie
	name = "skrell plushie"
	desc = "The latest from 'SoftSkrells.net', features its very own headpocket! Warble!"
	icon_state = "plushie_skrell"
	rare_hug_sound = 'sound/effects/warble.ogg'
	rare_hug_word = "Warble!"
	var/obj/item/headpocket_item

/obj/item/toy/plushie/skrellplushie/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to put something small inside the headpocket, or take an item out.</span>"

/obj/item/toy/plushie/skrellplushie/AltClick(mob/user)
	if(!Adjacent(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	var/obj/item/I = user.get_active_hand()
	if(I == src)
		return
	if(!I)
		if(!headpocket_item)
			return
		to_chat(user, "<span class='notice'>You remove [headpocket_item] from [src].</span>")
		headpocket_item.forceMove(get_turf(src))
		user.put_in_hands(headpocket_item)
		headpocket_item = null
		return
	if(I.w_class > WEIGHT_CLASS_SMALL)
		to_chat(user, "<span class='warning'>You cannot fit [I] in [src]!</span>")
		return
	if(!iscarbon(user))
		return
	if(headpocket_item)
		to_chat(user, "<span class='warning'>[src] already has an item in its headpocket!</span>")
		return
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>You cannot slip [I] inside [src]!</span>")
		return
	user.visible_message("<span class='notice'>[user] places [I] into [src].</span>", "<span class='notice'>You place [I] into [src].</span>")
	add_fingerprint(user)
	I.forceMove(src)
	headpocket_item = I

/obj/item/toy/plushie/skrellplushie/Destroy()
	if(headpocket_item)
		headpocket_item.forceMove(get_turf(src))
		headpocket_item = null
	return ..()

/obj/item/toy/plushie/humanplushie
	name = "human plushie"
	desc = "This plushie is slightly less popular than its counterparts. The designers obviously didn't find humans that endearing..."
	icon_state = "plushie_human"
	poof_sound = list('sound/weapons/thudswoosh.ogg' = 30,
					'sound/goonstation/voice/male_scream.ogg' = 1)

/obj/item/toy/plushie/borgplushie
	name = "borg plushie"
	desc = "The synthetic backbone of the station, rendered in plush form. Features a built-in flashlight and polychromic fabric."
	icon_state = "plushie_borg"
	var/borg_plushie_overlay = "plushie_borgassist"
	var/plushie_module_selected = FALSE
	var/on = FALSE

/obj/item/toy/plushie/borgplushie/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/toy/plushie/borgplushie/examine(mob/user)
	. = ..()
	if(!plushie_module_selected)
		. += "<span class='notice'><b>Alt-Click</b> [src] to select a module.</span>"
	else
		. += "<span class='notice'>You can use a cyborg module reset board to change [src] back into standard mode.</span>"

/obj/item/toy/plushie/borgplushie/AltClick(mob/user)
	if(!istype(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	pick_borg_plush_module(user)

/obj/item/toy/plushie/borgplushie/proc/pick_borg_plush_module(mob/user)
	if(plushie_module_selected)
		return

	var/static/list/menu_options = list(
		"Security"		= image('icons/mob/robots.dmi', "security-radial"),
		"Engineering"	= image('icons/mob/robots.dmi', "engi-radial"),
		"Mining"		= image('icons/mob/robots.dmi', "mining-radial"),
		"Service"		= image('icons/mob/robots.dmi', "serv-radial"),
		"Medical"		= image('icons/mob/robots.dmi', "med-radial"),
		"Janitor"		= image('icons/mob/robots.dmi', "jan-radial")
	)
	var/static/list/plushie_module_overlays = list(
		"Security"		= "plushie_borgsec",
		"Engineering"	= "plushie_borgengi",
		"Mining"		= "plushie_borgmine",
		"Service"		= "plushie_borgserv",
		"Medical"		= "plushie_borgmed",
		"Janitor"		= "plushie_borgjan"
	)
	playsound(src, 'sound/effects/pop.ogg', 50, TRUE)
	var/user_selection = show_radial_menu(user, src, menu_options, require_near = TRUE, radius = 42)

	if(!user_selection)
		return

	borg_plushie_overlay = plushie_module_overlays[user_selection]
	to_chat(user, "<span class='notice'>The fabric on [src] changes color, transforming it into \a [lowertext(user_selection)] plush!</span>")
	update_icon()
	plushie_module_selected = TRUE

/obj/item/toy/plushie/borgplushie/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/borg/upgrade/reset))
		return ..()

	if(!plushie_module_selected)
		to_chat(user, "<span class='warning'>[src] is already in standard mode!</span>")
		return ITEM_INTERACT_COMPLETE

	borg_plushie_overlay = "plushie_borgassist"
	update_icon()
	to_chat(user, "<span class='notice'>The fabric on [src] changes color, reverting it back to standard mode.</span>")
	plushie_module_selected = FALSE
	qdel(used)
	return ITEM_INTERACT_COMPLETE

/obj/item/toy/plushie/borgplushie/activate_self(mob/user)
	if(..())
		return
	on = !on
	update_brightness()

/obj/item/toy/plushie/borgplushie/proc/update_brightness()
	if(on)
		set_light(4)
	else
		set_light(0)
	update_icon()

/obj/item/toy/plushie/borgplushie/update_overlays()
	. = ..()
	add_overlay(borg_plushie_overlay)
	if(on)
		add_overlay("borglights")
	else
		cut_overlay("borglights")

/obj/item/toy/plushie/borgplushie/extinguish_light(force = FALSE)
	if(!force)
		if(on)
			visible_message("<span class='danger'>[src]'s light grows dim...</span>")
			on = !on
			update_brightness()
	else
		atom_say("Self-destruct command received!</span>")
		visible_message("<span class='danger'>[src] explodes!</span>")
		var/turf/T = get_turf(src)
		playsound(T, 'sound/goonstation/effects/robogib.ogg', 50, TRUE)
		robogibs(T)
		if(grenade)
			explosive_betrayal(grenade)
		if(!QDELETED(src))
			qdel(src)

/obj/item/toy/plushie/borgplushie/random

/obj/item/toy/plushie/borgplushie/random/Initialize(mapload)
	. = ..()
	borg_plushie_overlay = pick("plushie_borgjan", "plushie_borgsec", "plushie_borgmed", "plushie_borgmine", "plushie_borgserv", "plushie_borgassist", "plushie_borgengi")
	if(borg_plushie_overlay != "plushie_borgassist")
		plushie_module_selected = TRUE
	update_icon()

/obj/item/toy/plushie/dionaplushie
	name = "diona plushie"
	desc = "This plushy is seemingly comprised of other, smaller, nymph plushies. They really went all out on the realism! Keep away from plantkiller."
	icon_state = "plushie_diona"
	rare_hug_sound = 'sound/voice/dionatalk1.ogg'
	rare_hug_word = "Creak..."

/obj/item/toy/plushie/nymphplushie
	name = "nymph plushie"
	desc = "Life-sized plushie of a diona nymph, perhaps if you find another you could make a diona!"
	icon_state = "plushie_nymph"
	rare_hug_sound = 'sound/creatures/nymphchirp.ogg'
	rare_hug_word = "Chirp!"

/obj/item/toy/plushie/nymphplushie/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	if(istype(attacking, /obj/item/toy/plushie/nymphplushie))
		var/obj/item/toy/plushie/nymphplushie/NP = attacking
		var/found_grenade = FALSE
		if(grenade)
			found_grenade = TRUE
			explosive_betrayal(grenade)
		if(NP.grenade)
			found_grenade = TRUE
			NP.explosive_betrayal(NP.grenade)
		if(found_grenade)
			return FINISH_ATTACK
		new /obj/item/toy/plushie/dionaplushie(get_turf(loc))
		to_chat(user, "<span class='notice'>The nymph plushies combine seamlessly into an diona plushie!</span>")
		playsound(loc, 'sound/voice/dionatalk1.ogg', 50, TRUE)
		qdel(NP)
		qdel(src)
		return FINISH_ATTACK

/obj/item/toy/plushie/plasmamanplushie
	name = "plasmaman plushie"
	desc = "A friendly plasma-being in plush form. WARNING: KEEP AWAY FROM OPEN FLAME!"
	icon_state = "plushie_plasma"
	rare_hug_sound = 'sound/voice/plas_rattle.ogg'
	rare_hug_word = "Rattle!"

/obj/item/toy/plushie/plasmamanplushie/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, volume = I.tool_volume))
		bakoom()
	return TRUE

/obj/item/toy/plushie/plasmamanplushie/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	if(attacking.get_heat())
		bakoom()
		return FINISH_ATTACK

/obj/item/toy/plushie/plasmamanplushie/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	bakoom()

/obj/item/toy/plushie/plasmamanplushie/proc/bakoom()
	visible_message("<span class='danger'>[src] explodes!</span>")
	if(grenade)
		explosive_betrayal(grenade)
	explosion(get_turf(src), -1, 0, 1, 1, flame_range = 1, cause = "Plasmaman plushie caught on fire")
	if(!QDELETED(src))
		qdel(src)

/obj/item/toy/plushie/draskplushie
	name = "drask plushie"
	desc = "This plushie is cool as a cucumber, featuring realistic soap-munching action."
	icon_state = "plushie_drask"
	rare_hug_sound = 'sound/voice/drasktalk.ogg'
	rare_hug_word = "Ruuuumble..."

/obj/item/toy/plushie/draskplushie/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	if(istype(attacking, /obj/item/soap))
		if(prob(20))
			visible_message("<span class='danger'>[src] consumes the soap...</span>")
			qdel(attacking)
			return FINISH_ATTACK
		visible_message("<span class='danger'>[src] munches the soap...</span>")
		playsound(loc, 'sound/items/eatfood.ogg', 50, TRUE)

/obj/item/toy/plushie/kidanplushie
	name = "kidan plushie"
	desc = "F-ANT-asticly fun kidan plushie! Exoskeleton has never been so soft. The label says to keep it away from insecticides"
	icon_state = "plushie_kidan"
	var/sadbug = FALSE
	rare_hug_sound = 'sound/effects/Kidanclack.ogg'
	rare_hug_word = "Click clack!"

/obj/item/toy/plushie/kidanplushie/activate_self(mob/user)
	if(..())
		return
	if(prob(10) && sadbug)
		visible_message("<span class='notice'>[src] begins to cheer up!</span>")
		icon_state = "plushie_kidan"
		sadbug = FALSE

/obj/item/toy/plushie/kidanplushie/proc/make_cry()
	visible_message("<span class='danger'>[src] starts to cry...</span>")
	icon_state = "plushie_kidansad"
	sadbug = TRUE

/*
 * Foam Armblade
 */

/obj/item/toy/foamblade
	name = "foam armblade"
	desc = "it says \"Sternside Changs #1 fan\" on it. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamblade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	attack_verb = list("pricked", "absorbed", "gored")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE

/obj/item/toy/windup_toolbox
	name = "windup toolbox"
	desc = "A replica toolbox that rumbles when you turn the key."
	icon = 'icons/obj/storage.dmi'
	icon_state = "green"
	inhand_icon_state = "artistic_toolbox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	hitsound = 'sound/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound =  'sound/items/handling/toolbox_pickup.ogg'
	attack_verb = list("robusted")
	var/active = FALSE

/obj/item/toy/windup_toolbox/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/toy/windup_toolbox/update_overlays()
	. = ..()
	if(active)
		. += "single_latch_open"
	else
		. += "single_latch"

/obj/item/toy/windup_toolbox/activate_self(mob/user)
	if(..())
		return
	if(!active)
		to_chat(user, "<span class='notice'>You wind up [src], it begins to rumble.</span>")
		active = TRUE
		update_icon(UPDATE_OVERLAYS)
		playsound(src, 'sound/effects/pope_entry.ogg', 100)
		animate_rumble(src)
		addtimer(CALLBACK(src, PROC_REF(stopRumble)), 60 SECONDS)
	else
		to_chat(user, "<span class='warning'>[src] is already active!</span>")

/obj/item/toy/windup_toolbox/proc/stopRumble()
	active = FALSE
	update_icon(UPDATE_OVERLAYS)
	visible_message("<span class='warning'>[src] slowly stops rattling and falls still, its latch snapping shut.</span>") //subtle difference
	playsound(loc, 'sound/weapons/batonextend.ogg', 100, TRUE)
	animate(src, transform = matrix())

/*
 * Toy/fake flash
 */
/obj/item/toy/flash
	name = "toy flash"
	desc = "FOR THE REVOLU- Oh wait, that's just a toy."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	inhand_icon_state = "flashtool"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/flash/attack(mob/living/target, mob/living/carbon/human/user)
	if(..())
		return FINISH_ATTACK
	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("[initial(icon_state)]2", src)
	user.visible_message("<span class='disarm'>[user] blinds [target] with the flash!</span>")


/*
 * Toy big red button
 */
/obj/item/toy/redbutton
	name = "big red button"
	desc = "A big, plastic red button. Reads 'From HonkCo Pranks?' on the back."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/redbutton/activate_self(mob/user)
	if(..())
		return
	if(cooldown >= world.time)
		to_chat(user, "<span class='alert'>Nothing happens.</span>")
		return

	cooldown = (world.time + 300) // Sets cooldown at 30 seconds
	user.visible_message("<span class='warning'>[user] presses the big red button.</span>", "<span class='notice'>You press the button, it plays a loud noise!</span>", "<span class='notice'>The button clicks loudly.</span>")
	playsound(src, 'sound/effects/explosionfar.ogg', 50, FALSE, 0)
	flick("bigred_press", src)
	for(var/mob/M in range(10, src)) // Checks range
		if(!M.stat && !is_ai(M)) // Checks to make sure whoever's getting shaken is alive/not the AI
			sleep(8) // Short delay to match up with the explosion sound
			shake_camera(M, 2, 1) // Shakes player camera 2 squares for 1 second.

/*
 * AI core prizes
 */
/obj/item/toy/ai
	name = "toy AI"
	desc = "A little toy model AI core with real law announcing action!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/ai/activate_self(mob/user)
	if(..() || cooldown) //for the sanity of everyone
		return
	var/message = generate_ion_law()
	to_chat(user, "<span class='notice'>You press the button on [src].</span>")
	playsound(user, 'sound/machines/click.ogg', 20, TRUE)
	visible_message("<span class='danger'>[bicon(src)] [message]</span>")
	cooldown = 1
	spawn(30) cooldown = 0

/obj/item/toy/codex_gigas
	name = "Toy Codex Gigas"
	desc = "A tool to help you write fictional devils!"
	icon = 'icons/obj/library.dmi'
	icon_state = "demonomicon"
	w_class = WEIGHT_CLASS_SMALL
	var/list/messages = list("You must challenge the devil to a dance-off!", "The devils true name is Ian", "The devil hates salt!", "Would you like infinite power?", "Would you like infinite wisdom?", " Would you like infinite healing?")
	var/cooldown = FALSE

/obj/item/toy/codex_gigas/activate_self(mob/user)
	if(..() || cooldown)
		return
	user.visible_message(
		"<span class='notice'>[user] presses the button on \the [src].</span>",
		"<span class='notice'>You press the button on \the [src].</span>",
		"<span class='notice'>You hear a soft click.</span>")
	playsound(loc, 'sound/machines/click.ogg', 20, TRUE)
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 60)
	for(var/message in pick(messages))
		user.loc.visible_message("<span class='danger'>[bicon(src)] [message]</span>")
		sleep(10)

// DND Character minis. Use the naming convention (type)character for the icon states.
/obj/item/toy/character
	icon = 'icons/obj/toy.dmi'
	w_class = WEIGHT_CLASS_TINY
	pixel_z = 5

/obj/item/toy/character/alien
	name = "Xenomorph Miniature"
	desc = "A miniature xenomorph. Scary!"
	icon_state = "aliencharacter"
/obj/item/toy/character/cleric
	name = "Cleric Miniature"
	desc = "A wee little cleric, with his wee little staff."
	icon_state = "clericcharacter"
/obj/item/toy/character/warrior
	name = "Warrior Miniature"
	desc = "That sword would make a decent toothpick."
	icon_state = "warriorcharacter"
/obj/item/toy/character/thief
	name = "Thief Miniature"
	desc = "Hey, where did my wallet go!?"
	icon_state = "thiefcharacter"
/obj/item/toy/character/wizard
	name = "Wizard Miniature"
	desc = "MAGIC!"
	icon_state = "wizardcharacter"
/obj/item/toy/character/cthulhu
	name = "Cthulhu Miniature"
	desc = "The dark lord has risen!"
	icon_state = "darkmastercharacter"
/obj/item/toy/character/lich
	name = "Lich Miniature"
	desc = "Murderboner extraordinaire."
	icon_state = "lichcharacter"

// Pet Rocks, just like from the 70's!
/obj/item/toy/pet_rock
	name = "pet rock"
	desc = "The perfect pet!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "pet_rock"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 5
	attack_verb = list("attacked", "bashed", "smashed", "stoned")
	hitsound = "swing_hit"

/obj/item/toy/pet_rock/activate_self(mob/user)
	. = ..()
	var/cuddle_verb = pick("admires", "respects", "cherises", "appreciates")
	user.visible_message("<span class='notice'>[user] [cuddle_verb] [src].</span>")

/obj/item/toy/pet_rock/fred
	name = "fred"
	desc = "Fred, the bestest boy pet in the whole wide universe!"
	icon_state = "fred"

/obj/item/toy/pet_rock/roxie
	name = "roxie"
	desc = "Roxie, the bestest girl pet in the whole wide universe!"
	icon_state = "roxie"

// Minigibber, so cute
/obj/item/toy/minigibber
	name = "miniature gibber"
	desc = "A miniature recreation of Nanotrasen's famous meat grinder."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minigibber"
	attack_verb = list("grinded", "gibbed")
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/obj/stored_minature = null

/obj/item/toy/minigibber/activate_self(mob/user)
	if(..())
		return
	if(stored_minature)
		to_chat(user, "<span class='danger'>\The [src] makes a violent grinding noise as it tears apart the miniature figure inside!</span>")
		QDEL_NULL(stored_minature)
		playsound(user, 'sound/goonstation/effects/gib.ogg', 20, 1)
		cooldown = world.time

	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You hit the gib button on \the [src].</span>")
		playsound(user, 'sound/goonstation/effects/gib.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/minigibber/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	if(istype(attacking,/obj/item/toy/character) && attacking.loc == user)
		to_chat(user, "<span class='notice'>You start feeding \the [attacking] [bicon(attacking)] into \the [src]'s mini-input.</span>")
		if(do_after(user, 10, target = src))
			if(attacking.loc != user)
				to_chat(user, "<span class='alert'>\The [attacking] is too far away to feed into \the [src]!</span>")
			else
				to_chat(user, "<span class='notice'>You feed \the [attacking] [bicon(attacking)] into \the [src]!</span>")
				user.transfer_item_to(attacking, src)
				stored_minature = attacking
		else
			to_chat(user, "<span class='warning'>You stop feeding \the [attacking] into \the [src]'s mini-input.</span>")
		return FINISH_ATTACK

/obj/item/toy/russian_revolver
	name = "russian revolver"
	desc = "For fun and games!"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "russian_revolver"
	worn_icon_state = "gun"
	inhand_icon_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	hitsound = "swing_hit"
	flags =  CONDUCT
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=2000)
	throwforce = 5
	throw_range = 5
	force = 5
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")
	var/bullets_left = 0
	var/max_shots = 6
	var/cursed_shot = FALSE

/obj/item/toy/russian_revolver/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] quickly loads six bullets into [src]'s cylinder and points it at [user.p_their()] head before pulling the trigger! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/gunshots/gunshot_strong.ogg', 50, 1)
	return BRUTELOSS

/obj/item/toy/russian_revolver/New()
	..()
	spin_cylinder()

/obj/item/toy/russian_revolver/activate_self(mob/user)
	if(..())
		return
	if(!bullets_left)
		user.visible_message("<span class='warning'>[user] loads a bullet into [src]'s cylinder before spinning it.</span>")
		spin_cylinder()
	else
		user.visible_message("<span class='warning'>[user] spins the cylinder on [src]!</span>")
		spin_cylinder()

/obj/item/toy/russian_revolver/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	return ITEM_INTERACT_SKIP_TO_AFTER_ATTACK

/obj/item/toy/russian_revolver/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag)
		if(target in user.contents)
			return
		if(!ismob(target))
			return
	shoot_gun(user)

/obj/item/toy/russian_revolver/proc/spin_cylinder()
	bullets_left = rand(1, max_shots)

/obj/item/toy/russian_revolver/proc/post_shot(mob/user)
	return

/obj/item/toy/russian_revolver/proc/shoot_gun(mob/living/carbon/human/user)
	if(bullets_left > 1)
		bullets_left--
		user.visible_message("<span class='danger'>*click*</span>")
		playsound(src, 'sound/weapons/empty.ogg', 100, 1)
		return FALSE
	if(bullets_left == 1)
		bullets_left = 0
		var/zone = "head"
		if(!(user.has_organ(zone))) // If they somehow don't have a head.
			zone = "chest"
		playsound(src, 'sound/weapons/gunshots/gunshot_strong.ogg', 50, 1)
		user.visible_message("<span class='danger'>[src] goes off!</span>")
		post_shot(user)
		if(cursed_shot)
			var/obj/item/soulstone/anybody/SS = new /obj/item/soulstone/anybody(get_turf(src))
			SS.transfer_soul("FORCE", user)
			user.death(FALSE)
			user.visible_message("<span class='danger'>[user.name]'s soul is captured by [src]!</span>", "<span class='userdanger'>You've lost the gamble! Your soul is forfeit!</span>")
		user.apply_damage(300, BRUTE, zone, sharp = TRUE, used_weapon = "Self-inflicted gunshot wound to the [zone].")
		user.bleed(BLOOD_VOLUME_NORMAL)
		user.death() // Just in case
		if(SSticker.mode.tdm_gamemode)
			SSblackbox.record_feedback("nested tally", "TDM_quitouts", 1, list(SSticker.mode.name, "TDM Revolver Suicide"))
		return TRUE
	else
		to_chat(user, "<span class='warning'>[src] needs to be reloaded.</span>")
		return FALSE

/obj/item/toy/russian_revolver/soul
	name = "cursed russian revolver"
	desc = "To play with this revolver requires wagering your very soul."
	cursed_shot = TRUE

/*
 * Rubber Chainsaw
 */
/obj/item/toy/chainsaw
	name = "Toy Chainsaw"
	desc = "A toy chainsaw with a rubber edge. Ages 8 and up."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "chainsaw"
	base_icon_state = "chainsaw"
	attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")

/obj/item/toy/chainsaw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, wieldsound = 'sound/weapons/chainsawstart.ogg', icon_wielded = "[base_icon_state]_on")

/obj/item/toy/chainsaw/update_icon_state()
	icon_state = base_icon_state

/*
 * Cat Toy
  */
/obj/item/toy/cattoy
	name = "toy mouse"
	desc = "A colorful toy mouse!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_mouse"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	var/cooldown = 0

/*
 * Action Figures
 */


/obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	desc = "A \"Space Life\" brand... wait, what the hell is this thing?"
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"
	w_class = WEIGHT_CLASS_TINY
	var/cooldown = 0
	var/cooldown_time = 3 SECONDS

/obj/item/toy/figure/activate_self(mob/user)
	if(..())
		return
	if(cooldown < world.time)
		cooldown = world.time + cooldown_time
		activate(user)
	else
		on_cooldown(user)

/obj/item/toy/figure/proc/activate(mob/user)
	return

/obj/item/toy/figure/proc/on_cooldown(mob/user)
	return

/obj/item/toy/figure/crew
	var/toysay = "What the fuck did you do?"

/obj/item/toy/figure/crew/activate(mob/user)
	atom_say(toysay)
	playsound(user, 'sound/machines/click.ogg', 20, TRUE)

/obj/item/toy/figure/crew/cmo
	name = "\improper Chief Medical Officer action figure"
	desc = "The ever-suffering CMO, from Space Life's SS12 figurine collection."
	icon_state = "cmo"
	toysay = "Suit sensors!"

/obj/item/toy/figure/crew/assistant
	name = "\improper Assistant action figure"
	desc = "The faceless, hairless scourge of the station, from Space Life's SS12 figurine collection."
	icon_state = "assistant"
	toysay = "Grey tide station wide!"

/obj/item/toy/figure/crew/atmos
	name = "\improper Atmospheric Technician action figure"
	desc = "The faithful atmospheric technician, from Space Life's SS12 figurine collection."
	icon_state = "atmos"
	toysay = "Glory to Atmosia!"

/obj/item/toy/figure/crew/bartender
	name = "\improper Bartender action figure"
	desc = "The suave bartender, from Space Life's SS12 figurine collection."
	icon_state = "bartender"
	toysay = "Wheres my monkey?"

/obj/item/toy/figure/crew/borg
	name = "\improper Cyborg action figure"
	desc = "The iron-willed cyborg, from Space Life's SS12 figurine collection."
	icon_state = "borg"
	toysay = "I. LIVE. AGAIN."

/obj/item/toy/figure/crew/botanist
	name = "\improper Botanist action figure"
	desc = "The drug-addicted botanist, from Space Life's SS12 figurine collection."
	icon_state = "botanist"
	toysay = "Dude, I see colors..."

/obj/item/toy/figure/crew/captain
	name = "\improper Captain action figure"
	desc = "The inept captain, from Space Life's SS12 figurine collection."
	icon_state = "captain"
	toysay = "Crew, the Nuke Disk is safely up my ass."

/obj/item/toy/figure/crew/cargotech
	name = "\improper Cargo Technician action figure"
	desc = "The hard-working cargo tech, from Space Life's SS12 figurine collection."
	icon_state = "cargotech"
	toysay = "For Cargonia!"

/obj/item/toy/figure/crew/explorer
	name = "\improper Explorer action figure"
	desc = "The oblivious explorer, from Space Life's SS12 figurine collection."
	icon_state = "explorer"
	toysay = "I f-foun-nd-d it-t in-n s-spac-ce!"

/obj/item/toy/figure/crew/ce
	name = "\improper Chief Engineer action figure"
	desc = "The expert Chief Engineer, from Space Life's SS12 figurine collection."
	icon_state = "ce"
	toysay = "Wire the solars!"

/obj/item/toy/figure/crew/chaplain
	name = "\improper Chaplain action figure"
	desc = "The obsessed Chaplain, from Space Life's SS12 figurine collection."
	icon_state = "chaplain"
	toysay = "Gods make me a killing machine please!"

/obj/item/toy/figure/crew/chef
	name = "\improper Chef action figure"
	desc = "The cannibalistic chef, from Space Life's SS12 figurine collection."
	icon_state = "chef"
	toysay = "I swear it's not human meat."

/obj/item/toy/figure/crew/chemist
	name = "\improper Chemist action figure"
	desc = "The legally dubious Chemist, from Space Life's SS12 figurine collection."
	icon_state = "chemist"
	toysay = "Get your pills!"

/obj/item/toy/figure/crew/clown
	name = "\improper Clown action figure"
	desc = "The mischievous Clown, from Space Life's SS12 figurine collection."
	icon_state = "clown"
	toysay = "Honk!"

/obj/item/toy/figure/crew/ian
	name = "\improper Ian action figure"
	desc = "The adorable corgi, from Space Life's SS12 figurine collection."
	icon_state = "ian"
	toysay = "Arf!"

/obj/item/toy/figure/crew/detective
	name = "\improper Detective action figure"
	desc = "The clever detective, from Space Life's SS12 figurine collection."
	icon_state = "detective"
	toysay = "This airlock has grey jumpsuit and insulated glove fibers on it."

/obj/item/toy/figure/crew/dsquad
	name = "\improper Death Squad Officer action figure"
	desc = "It's a member of the DeathSquad, a TV drama where loose-cannon ERT officers face up against the threats of the galaxy! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "dsquad"
	toysay = "Eliminate all threats!"

/obj/item/toy/figure/crew/engineer
	name = "\improper Engineer action figure"
	desc = "The frantic engineer, from Space Life's SS12 figurine collection."
	icon_state = "engineer"
	toysay = "Oh god, the singularity is loose!"

/obj/item/toy/figure/crew/geneticist
	name = "\improper Geneticist action figure"
	desc = "The balding geneticist, from Space Life's SS12 figurine collection."
	icon_state = "geneticist"
	toysay = "I'm not qualified for this job."

/obj/item/toy/figure/crew/hop
	name = "\improper Head of Personnel action figure"
	desc = "The officious Head of Personnel, from Space Life's SS12 figurine collection."
	icon_state = "hop"
	toysay = "Papers, please!"

/obj/item/toy/figure/crew/hos
	name = "\improper Head of Security action figure"
	desc = "The bloodlust-filled Head of Security, from Space Life's SS12 figurine collection."
	icon_state = "hos"
	toysay = "Space law? What?"

/obj/item/toy/figure/crew/qm
	name = "\improper Quartermaster action figure"
	desc = "The nationalistic Quartermaster, from Space Life's SS12 figurine collection."
	icon_state = "qm"
	toysay = "Hail Cargonia!"

/obj/item/toy/figure/crew/janitor
	name = "\improper Janitor action figure"
	desc = "The water-using Janitor, from Space Life's SS12 figurine collection."
	icon_state = "janitor"
	toysay = "Look at the signs, you idiot."

/obj/item/toy/figure/crew/iaa
	name = "\improper Internal Affairs Agent action figure"
	desc = "The unappreciated Internal Affairs Agent, from Space Life's SS12 figurine collection."
	icon_state = "internal_affairs"
	toysay = "Standard Operating Procedure says they're guilty! Hacking is proof they're an Enemy of the Corporation!"

/obj/item/toy/figure/crew/librarian
	name = "\improper Librarian action figure"
	desc = "The quiet Librarian, from Space Life's SS12 figurine collection."
	icon_state = "librarian"
	toysay = "One day while..."

/obj/item/toy/figure/crew/md
	name = "\improper Medical Doctor action figure"
	desc = "The stressed-out doctor, from Space Life's SS12 figurine collection."
	icon_state = "md"
	toysay = "The patient is already dead!"

/obj/item/toy/figure/crew/mime
	name = "\improper Mime action figure"
	desc = "... from Space Life's SS12 figurine collection."
	icon_state = "mime"
	toysay = "..."

/obj/item/toy/figure/crew/miner
	name = "\improper Shaft Miner action figure"
	desc = "The gun-toting Shaft Miner, from Space Life's SS12 figurine collection."
	icon_state = "miner"
	toysay = "Oh god it's eating my intestines!"

/obj/item/toy/figure/crew/ninja
	name = "\improper Ninja action figure"
	desc = "It's the mysterious ninja! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "ninja"
	toysay = "Oh god! Stop shooting, I'm friendly!"

/obj/item/toy/figure/crew/wizard
	name = "\improper Wizard action figure"
	desc = "It's the deadly, spell-slinging wizard! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "wizard"
	toysay = "Ei Nath!"

/obj/item/toy/figure/crew/rd
	name = "\improper Research Director action figure"
	desc = "The ambitious RD, from Space Life's SS12 figurine collection."
	icon_state = "rd"
	toysay = "Blowing all of the borgs!"

/obj/item/toy/figure/crew/roboticist
	name = "\improper Roboticist action figure"
	desc = "The skillful Roboticist, from Space Life's SS12 figurine collection."
	icon_state = "roboticist"
	toysay = "He asked to be borged!"

/obj/item/toy/figure/crew/scientist
	name = "\improper Scientist action figure"
	desc = "The mad Scientist, from Space Life's SS12 figurine collection."
	icon_state = "scientist"
	toysay = "Someone else must have made those bombs!"

/obj/item/toy/figure/crew/syndie
	name = "\improper Nuclear Operative action figure"
	desc = "It's the red-suited Nuclear Operative! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "syndie"
	toysay = "Get that fucking disk!"

/obj/item/toy/figure/crew/secofficer
	name = "\improper Security Officer action figure"
	desc = "The power-tripping Security Officer, from Space Life's SS12 figurine collection."
	icon_state = "secofficer"
	toysay = "I am the law!"

/obj/item/toy/figure/crew/virologist
	name = "\improper Virologist action figure"
	desc = "The pandemic-starting Virologist, from Space Life's SS12 figurine collection."
	icon_state = "virologist"
	toysay = "It's not my virus!"

/obj/item/toy/figure/crew/warden
	name = "\improper Warden action figure"
	desc = "The amnesiac Warden, from Space Life's SS12 figurine collection."
	icon_state = "warden"
	toysay = "Execute him for breaking in!"

/*
 * Xenomorph action figure
 */

/obj/item/toy/figure/xeno
	name = "\improper Xenomorph action figure"
	desc = "MEGA presents the new Xenos Isolated action figure! Comes complete with realistic sounds! Pull back string to use."
	icon_state = "toy_xeno"
	bubble_icon = "alien"
	cooldown_time = 5 SECONDS


/obj/item/toy/figure/xeno/activate(mob/user)
	user.visible_message("<span class='notice'>[user] pulls back the string on [src].</span>")
	icon_state = "[initial(icon_state)]_used"
	addtimer(CALLBACK(src, PROC_REF(hiss)), 0.5 SECONDS)

/obj/item/toy/figure/xeno/proc/hiss()
	atom_say("Hiss!")
	playsound(src, get_sfx("hiss"), 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(reset_icon)), 4.5 SECONDS)

/obj/item/toy/figure/xeno/proc/reset_icon()
	icon_state = "[initial(icon_state)]"

/obj/item/toy/figure/xeno/on_cooldown(mob/user)
	to_chat(user, "<span class='warning'>The string on [src] hasn't rewound all the way!</span>")

/obj/item/toy/figure/owl
	name = "\improper Owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon_state = "owlprize"

/obj/item/toy/figure/owl/activate(mob/user)
	var/message = pick("You won't get away this time, Griffin!", "Stop right there, criminal!", "Hoot! Hoot!", "I am the night!")
	to_chat(user, "<span class='notice'>You pull the string on [src].</span>")
	playsound(src, 'sound/creatures/hoot.ogg', 25, TRUE)
	atom_say("<span class='danger'>[message]</span>")

/obj/item/toy/figure/griffin
	name = "\improper Griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon_state = "griffinprize"


/obj/item/toy/figure/griffin/activate(mob/user)
	var/message = pick("You can't stop me, Owl!", "My plan is flawless! The vault is mine!", "Caaaawwww!", "You will never catch me!")
	to_chat(user, "<span class='notice'>You pull the string on [src].</span>")
	playsound(src, 'sound/creatures/caw.ogg', 25, TRUE)
	atom_say("<span class='danger'>[message]</span>")

/*
 * Mech prizes
 */
/obj/item/toy/figure/mech
	icon_state = "ripleytoy"
	cooldown_time = 8

//all credit to skasi for toy mech fun ideas
/obj/item/toy/figure/mech/activate(mob/user)
	to_chat(user, "<span class='notice'>You play with [src].</span>")
	playsound(src, 'sound/mecha/mechstep.ogg', 20, TRUE)

/obj/item/toy/figure/mech/ripley
	name = "toy Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11. This one is a ripley, a mining and engineering mecha."

/obj/item/toy/figure/mech/fireripley
	name = "toy Firefighting Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11. This one is a firefighter ripley, a fireproof mining and engineering mecha."
	icon_state = "fireripleytoy"

/obj/item/toy/figure/mech/deathripley
	name = "toy Deathsquad Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11. This one is the black ripley used by the hero of Deathsquad, that TV drama about loose-cannon ERT officers!"
	icon_state = "deathripleytoy"

/obj/item/toy/figure/mech/gygax
	name = "toy Gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11. This one is the speedy gygax combat mecha. Zoom zoom, pew pew!"
	icon_state = "gygaxtoy"

/obj/item/toy/figure/mech/durand
	name = "toy Durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11. This one is the heavy durand combat mecha. Stomp stomp!"
	icon_state = "durandprize"

/obj/item/toy/figure/mech/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11. This one is the infamous H.O.N.K mech!"
	icon_state = "honkprize"

/obj/item/toy/figure/mech/marauder
	name = "toy Marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11. This one is the powerful marauder combat mecha! Run for cover!"
	icon_state = "marauderprize"

/obj/item/toy/figure/mech/seraph
	name = "toy Seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11. This one is the powerful seraph combat mecha! Someone's in trouble!"
	icon_state = "seraphprize"

/obj/item/toy/figure/mech/mauler
	name = "toy Mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11. This one is the deadly mauler combat mecha! Look out!"
	icon_state = "maulerprize"

/obj/item/toy/figure/mech/odysseus
	name = "toy Odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11. This one is the spindly, syringe-firing odysseus medical mecha."
	icon_state = "odysseusprize"

/obj/item/toy/figure/mech/phazon
	name = "toy Phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11. This one is the mysterious Phazon combat mecha! Nobody's safe!"
	icon_state = "phazonprize"


//////////////////////////////////////////////////////
//				Magic 8-Ball / Conch				//
//////////////////////////////////////////////////////

/obj/item/toy/eight_ball
	name = "\improper Magic 8-Ball"
	desc = "Mystical! Magical! Ages 8+!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "eight-ball"
	var/use_action = "shakes the ball"
	var/cooldown = 0
	var/list/possible_answers = list("Definitely", "All signs point to yes.", "Most likely.", "Yes.", "Ask again later.", "Better not tell you now.", "Future Unclear.", "Maybe.", "Doubtful.", "No.", "Don't count on it.", "Never.")

/obj/item/toy/eight_ball/activate_self(mob/user as mob)
	if(..() || cooldown)
		return
	var/answer = pick(possible_answers)
	user.visible_message("<span class='notice'>[user] focuses on [user.p_their()] question and [use_action]...</span>")
	user.visible_message("<span class='notice'>[bicon(src)] [src] says \"[answer]\"</span>")
	spawn(30)
		cooldown = 0

/obj/item/toy/eight_ball/conch
	name = "\improper Magic Conch Shell"
	desc = "All hail the Magic Conch!"
	icon_state = "conch"
	use_action = "pulls the string"
	possible_answers = list("Yes.", "No.", "Try asking again.", "Nothing.", "I don't think so.", "Neither.", "Maybe someday.")

/*
 *Fake cuffs (honk honk)
 */

/obj/item/restraints/handcuffs/toy
	desc = "Toy handcuffs. Plastic and extremely cheaply made."
	throwforce = 0
	breakouttime = 0
	ignoresClumsy = TRUE
