//The chests dropped by mob spawner tendrils. Also contains associated loot.

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"
	icon_opened = "necrocrate_open"
	icon_closed = "necrocrate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously."

/obj/structure/closet/crate/necropolis/tendril/populate_contents()
	var/loot = rand(1, 24)
	switch(loot)
		if(1)
			new /obj/item/shared_storage/red(src)
		if(2)
			new /obj/item/clothing/head/helmet/space/cult(src)
			new /obj/item/clothing/suit/space/cult(src)
		if(3)
			new /obj/item/soulstone/anybody(src)
		if(4)
			new /obj/item/organ/internal/cyberimp/arm/katana(src)
		if(5)
			new /obj/item/clothing/glasses/godeye(src)
		if(6)
			new /obj/item/pickaxe/diamond(src)
		if(7)
			new /obj/item/clothing/suit/hooded/cultrobes(src)
			new /obj/item/bedsheet/cult(src)
		if(8)
			if(prob(50))
				new /obj/item/disk/design_disk/modkit_disk/resonator_blast(src)
			else
				new /obj/item/disk/design_disk/modkit_disk/rapid_repeater(src)
		if(9)
			new /obj/item/rod_of_asclepius(src)
		if(10)
			new /obj/item/organ/internal/heart/cursed/wizard(src)
		if(11)
			new /obj/item/ship_in_a_bottle(src)
		if(12)
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/berserker(src)
		if(13)
			new /obj/item/nullrod/scythe/talking(src)
		if(14)
			new /obj/item/nullrod/armblade/mining(src)
		if(15)
			if(prob(50))
				new /obj/item/disk/design_disk/modkit_disk/mob_and_turf_aoe(src)
			else
				new /obj/item/disk/design_disk/modkit_disk/bounty(src)
		if(16)
			new /obj/item/warp_cube/red(src)
		if(17)
			new /obj/item/wisp_lantern(src)
		if(18)
			new /obj/item/immortality_talisman(src)
		if(19)
			new /obj/item/gun/magic/hook(src)
		if(20)
			new /obj/item/grenade/clusterbuster/inferno(src)
		if(21)
			new /obj/item/reagent_containers/food/drinks/bottle/holywater/hell(src)
		if(22)
			new /obj/item/spellbook/oneuse/summonitem(src)
		if(23)
			new /obj/item/book_of_babel(src)
		if(24)
			new /obj/item/borg/upgrade/modkit/lifesteal(src)
			new /obj/item/bedsheet/cult(src)

/obj/structure/closet/crate/necropolis/puzzle
	name = "puzzling chest"

/obj/structure/closet/crate/necropolis/puzzle/populate_contents()
	var/loot = rand(1,2)
	switch(loot)
		if(1)
			new /obj/item/soulstone/anybody(src)
		if(2)
			new /obj/item/wisp_lantern(src)

//KA modkit design discs
/obj/item/disk/design_disk/modkit_disk
	name = "\improper KA mod disk"
	desc = "A design disk containing the design for a unique kinetic accelerator modkit. It's compatible with a research console."
	icon_state = "datadisk1"
	var/modkit_design

/obj/item/disk/design_disk/modkit_disk/New()
	. = ..()
	if(modkit_design)
		blueprint = new modkit_design

/obj/item/disk/design_disk/modkit_disk/mob_and_turf_aoe
	name = "\improper KA mod disk (Offensive mining explosion)"
	modkit_design = /datum/design/offensive_turf_aoe_modkit

/obj/item/disk/design_disk/modkit_disk/rapid_repeater
	name = "\improper KA mod disk (Rapid repeater)"
	modkit_design = /datum/design/rapid_repeater_modkit

/obj/item/disk/design_disk/modkit_disk/resonator_blast
	name = "\improper KA mod disk (Resonator blast)"
	modkit_design = /datum/design/resonator_blast_modkit

/obj/item/disk/design_disk/modkit_disk/bounty
	name = "\improper KA mod disk (Death syphon)"
	modkit_design = /datum/design/bounty_modkit

/datum/design/offensive_turf_aoe_modkit
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	id = "hyperaoemod"
	materials = list(MAT_METAL = 7000, MAT_GLASS = 3000, MAT_SILVER= 3000, MAT_GOLD = 3000, MAT_DIAMOND = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	category = list("Mining", "Cyborg Upgrade Modules")
	build_type = PROTOLATHE | MECHFAB

/datum/design/rapid_repeater_modkit
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	id = "repeatermod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_URANIUM = 8000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater
	category = list("Mining", "Cyborg Upgrade Modules")
	build_type = PROTOLATHE | MECHFAB

/datum/design/resonator_blast_modkit
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	id = "resonatormod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_SILVER= 5000, MAT_URANIUM = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts
	category = list("Mining", "Cyborg Upgrade Modules")
	build_type = PROTOLATHE | MECHFAB

/datum/design/bounty_modkit
	name = "Kinetic Accelerator Death Syphon Mod"
	desc = "A device which causes kinetic accelerators to permanently gain damage against creature types killed with it."
	id = "bountymod"
	materials = list(MAT_METAL = 4000, MAT_SILVER = 4000, MAT_GOLD = 4000, MAT_BLUESPACE = 4000)
	reagents_list = list("blood" = 40)
	build_path = /obj/item/borg/upgrade/modkit/bounty
	category = list("Mining", "Cyborg Upgrade Modules")
	build_type = PROTOLATHE | MECHFAB

//Spooky special loot

//Rod of Asclepius
#define RIGHT_HAND 0
#define LEFT_HAND 1

/obj/item/rod_of_asclepius
	name = "\improper Rod of Asclepius"
	desc = "A wooden rod about the size of your forearm with a snake carved around it, winding its way up the sides of the rod. Something about it seems to inspire in you the responsibilty and duty to help others."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "asclepius_dormant"
	var/activated = FALSE
	var/usedHand
	var/mob/living/carbon/owner

/obj/item/rod_of_asclepius/attack_self(mob/user)
	if(activated)
		return
	if(!iscarbon(user))
		to_chat(user, "<span class='warning'>The snake carving seems to come alive, if only for a moment, before returning to its dormant state, almost as if it finds you incapable of holding its oath.</span>")
		return
	var/mob/living/carbon/itemUser = user
	if(itemUser.l_hand == src)
		usedHand = LEFT_HAND
	if(itemUser.r_hand == src)
		usedHand = RIGHT_HAND
	if(itemUser.has_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH))
		to_chat(user, "<span class='warning'>You can't possibly handle the responsibility of more than one rod!</span>")
		return
	var/failText = "<span class='warning'>The snake seems unsatisfied with your incomplete oath and returns to its previous place on the rod, returning to its dormant, wooden state. You must stand still while completing your oath!</span>"
	to_chat(itemUser, "<span class='notice'>The wooden snake that was carved into the rod seems to suddenly come alive and begins to slither down your arm! The compulsion to help others grows abnormally strong...</span>")
	if(do_after_once(itemUser, 40, target = itemUser))
		itemUser.say("I swear to fulfill, to the best of my ability and judgment, this covenant:")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 20, target = itemUser))
		itemUser.say("I will apply, for the benefit of the sick, all measures that are required, avoiding those twin traps of overtreatment and therapeutic nihilism.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 30, target = itemUser))
		itemUser.say("I will remember that I remain a member of society, with special obligations to all my fellow human beings, those sound of mind and body as well as the infirm.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 30, target = itemUser))
		itemUser.say("If I do not violate this oath, may I enjoy life and art, respected while I live and remembered with affection thereafter. May I always act so as to preserve the finest traditions of my calling and may I long experience the joy of healing those who seek my help.")
	else
		to_chat(itemUser, failText)
		return
	to_chat(itemUser, "<span class='notice'>The snake, satisfied with your oath, attaches itself and the rod to your forearm with an inseparable grip. Your thoughts seem to only revolve around the core idea of helping others, and harm is nothing more than a distant, wicked memory...</span>")

	activated(itemUser)

/obj/item/rod_of_asclepius/Destroy()
	owner = null
	return ..()

/obj/item/rod_of_asclepius/dropped(mob/user, silent)
	..()
	if(!activated)
		return
	addtimer(CALLBACK(src, .proc/try_attach_to_owner), 0) // Do this once the drop call stack is done. The holding limb might be getting removed

/obj/item/rod_of_asclepius/proc/try_attach_to_owner()
	if(ishuman(owner) && !QDELETED(owner))
		if(ishuman(loc))
			var/mob/living/carbon/human/thief = loc
			thief.unEquip(src, TRUE, TRUE) // You're not my owner!
		if(owner.stat == DEAD)
			qdel(src) // Oh no! Oh well a new rod will be made from the STATUS_EFFECT_HIPPOCRATIC_OATH
			return
		flags |= NODROP // Readd the nodrop
		var/mob/living/carbon/human/H = owner
		var/limb_regrown = FALSE
		if(usedHand == LEFT_HAND)
			limb_regrown = H.regrow_external_limb_if_missing("l_arm")
			limb_regrown = H.regrow_external_limb_if_missing("l_hand") || limb_regrown
			H.drop_l_hand(TRUE)
			H.put_in_l_hand(src, TRUE)
		else
			limb_regrown = H.regrow_external_limb_if_missing("r_arm")
			limb_regrown = H.regrow_external_limb_if_missing("r_hand") || limb_regrown
			H.drop_r_hand(TRUE)
			H.put_in_r_hand(src, TRUE)
		if(!limb_regrown)
			to_chat(H, "<span class='notice'>The Rod of Asclepius suddenly grows back out of your arm!</span>")
		else
			H.update_body() // Update the limb sprites
			to_chat(H, "<span class='notice'>Your arm suddenly grows back with the Rod of Asclepius still attached!</span>")
	else
		deactivate()

/obj/item/rod_of_asclepius/proc/activated(mob/living/carbon/new_owner)
	owner = new_owner
	flags = NODROP
	desc = "A short wooden rod with a mystical snake inseparably gripping itself and the rod to your forearm. It flows with a healing energy that disperses amongst yourself and those around you. "
	icon_state = "asclepius_active"
	activated = TRUE

	owner.apply_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH)
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, .proc/deactivate)

/obj/item/rod_of_asclepius/proc/deactivate()
	if(owner)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
		owner = null

	flags = NONE
	activated = FALSE
	desc = initial(desc)
	icon_state = initial(icon_state)

#undef RIGHT_HAND
#undef LEFT_HAND

/obj/item/organ/internal/cyberimp/arm/katana
	name = "dark shard"
	desc = "An eerie metal shard surrounded by dark energies."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "cursed_katana_organ"
	status = 0
	contents = newlist(/obj/item/cursed_katana)


/obj/item/organ/internal/cyberimp/arm/katana/attack_self(mob/user, modifiers)
	. = ..()
	to_chat(user,"<span class='userdanger'>The mass goes up your arm and goes inside it!</span>")
	playsound(user, 'sound/misc/demon_consume.ogg', 50, TRUE)
	user.drop_item()
	insert(user)

/obj/item/organ/internal/cyberimp/arm/katana/emp_act() //Organic, no emp stuff
	return

/obj/item/organ/internal/cyberimp/arm/katana/Retract()
	var/obj/item/cursed_katana/katana = holder
	if(!katana || katana.shattered)
		return FALSE
	if(!katana.drew_blood)
		to_chat(owner, "<span class='userdanger'>[katana] lashes out at you in hunger!</span>")
		playsound(owner, 'sound/misc/demon_attack1.ogg', 50, TRUE)
		if(parent_organ)
			owner.apply_damage(25, BRUTE, parent_organ, TRUE)
	katana.drew_blood = FALSE
	katana.clean_blood()
	return ..()

/obj/item/organ/internal/cyberimp/arm/katana/Extend()
	for(var/obj/item/cursed_katana/katana in contents)
		if(katana.shattered)
			to_chat(owner, "<span class='warning'> Your cursed katana has not reformed yet!</span>")
			return FALSE
	return ..()


#define LEFT_SLASH "Harm"
#define RIGHT_SLASH "Disarm"
#define COMBO_STEPS "steps"
#define COMBO_PROC "proc"
#define ATTACK_STRIKE "Hilt Strike"
#define ATTACK_SLICE "Wide Slice"
#define ATTACK_DASH "Dash Attack"
#define ATTACK_CUT "Tendon Cut"
#define ATTACK_CLOAK "Dark Cloak"
#define ATTACK_SHATTER "Shatter"


/obj/item/cursed_katana
	name = "cursed katana"
	desc = "A katana used to seal something vile away long ago. \
	Even with the weapon destroyed, all the pieces containing the creature have coagulated back together to find a new host."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "cursed_katana"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 15
	armour_penetration_percentage = 40
	armour_penetration_flat = 10
	block_chance = 50
	sharp = TRUE
	w_class = WEIGHT_CLASS_HUGE
	attack_verb = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/shattered = FALSE
	var/drew_blood = FALSE
	var/timerid
	var/cloak_on_cooldown = FALSE // 10 second cooldown between cloaks. We do not want someone to be *always invisible* with this
	var/list/input_list = list()
	var/list/combo_strings = list()
	var/static/list/combo_list = list(
		ATTACK_STRIKE = list(COMBO_STEPS = list(LEFT_SLASH, LEFT_SLASH, RIGHT_SLASH), COMBO_PROC = .proc/strike),
		ATTACK_SLICE = list(COMBO_STEPS = list(RIGHT_SLASH, LEFT_SLASH, LEFT_SLASH), COMBO_PROC = .proc/slice),
		ATTACK_DASH = list(COMBO_STEPS = list(LEFT_SLASH, RIGHT_SLASH, RIGHT_SLASH), COMBO_PROC = .proc/dash),
		ATTACK_CUT = list(COMBO_STEPS = list(RIGHT_SLASH, RIGHT_SLASH, LEFT_SLASH), COMBO_PROC = .proc/cut),
		ATTACK_CLOAK = list(COMBO_STEPS = list(LEFT_SLASH, RIGHT_SLASH, LEFT_SLASH, RIGHT_SLASH), COMBO_PROC = .proc/cloak),
		ATTACK_SHATTER = list(COMBO_STEPS = list(RIGHT_SLASH, LEFT_SLASH, RIGHT_SLASH, LEFT_SLASH), COMBO_PROC = .proc/shatter),
		)

/obj/item/cursed_katana/Initialize(mapload)
	. = ..()
	for(var/combo in combo_list)
		var/list/combo_specifics = combo_list[combo]
		var/step_string = english_list(combo_specifics[COMBO_STEPS])
		combo_strings += ("<span class='notice'><b>[combo]</b> - [step_string]</span>")

/obj/item/cursed_katana/examine(mob/user)
	. = ..()
	. += drew_blood ? ("<span class='notice'>It's sated... for now.</span>") : ("<span class='danger'>It will not be sated until it tastes blood.</span>")
	. += combo_strings

/obj/item/cursed_katana/dropped(mob/user)
	. = ..()
	reset_inputs(null, TRUE)

/obj/item/cursed_katana/attack_self(mob/user)
	. = ..()
	reset_inputs(user, TRUE)

/obj/item/cursed_katana/attack(mob/living/target, mob/user, click_parameters)
	if(target.stat == DEAD || target == user) //No, you can not stab yourself to cloak / not take the penalty for not drawing blood
		return ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm [target]!</span>")
		return
	drew_blood = TRUE
	if(user.a_intent == INTENT_DISARM)
		input_list += RIGHT_SLASH
	if(user.a_intent == INTENT_HARM)
		input_list += LEFT_SLASH
	if(ishostile(target))
		user.changeNext_move(CLICK_CD_RAPID)
	if(length(input_list) > 4)
		reset_inputs(user, TRUE)
	if(check_input(target, user))
		reset_inputs(null, TRUE)
		return TRUE
	else
		timerid = addtimer(CALLBACK(src, .proc/reset_inputs, user, FALSE), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return ..()

/obj/item/cursed_katana/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/cursed_katana/proc/check_input(mob/living/target, mob/user)
	for(var/combo in combo_list)
		var/list/combo_specifics = combo_list[combo]
		if(compare_list(input_list,combo_specifics[COMBO_STEPS]))
			INVOKE_ASYNC(src, combo_specifics[COMBO_PROC], target, user)
			return TRUE
	return FALSE

/obj/item/cursed_katana/proc/reset_inputs(mob/user, deltimer)
	input_list.Cut()
	if(user)
		to_chat(user, "<span class='notice'>You return to neutral stance</span>")
	if(deltimer && timerid)
		deltimer(timerid)

/obj/item/cursed_katana/proc/strike(mob/living/target, mob/user)
	user.visible_message("<span class='warning'>[user] strikes [target] with [src]'s hilt!</span>",
		"<span class='notice'>You hilt strike [target]</span>!")
	to_chat(target, "<span class='userdanger'>You've been struck by [user]!</span>")
	playsound(src, 'sound/weapons/genhit3.ogg', 50, TRUE)
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, .proc/strike_throw_impact)
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	target.throw_at(throw_target, 5, 3, user, FALSE)
	target.apply_damage(17, BRUTE, "chest")
	to_chat(target, "<span class='userdanger'>You've been struck by [user]!</span>")
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)

/obj/item/cursed_katana/proc/strike_throw_impact(mob/living/source, atom/hit_atom, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	source.apply_damage(5, BRUTE, "chest")
	if(ishostile(source))
		var/mob/living/simple_animal/hostile/target = source
		target.ranged_cooldown += 2 SECONDS
	else if(iscarbon(source))
		var/mob/living/carbon/target = source
		target.AdjustConfused(8 SECONDS)
	return NONE // the fuck is return none?

/obj/item/cursed_katana/proc/slice(mob/living/target, mob/user)
	user.visible_message("<span class='warning'>[user] does a wide slice!</span>",
		"<span class='notice'>You do a wide slice!</span>")
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)
	var/turf/user_turf = get_turf(user)
	var/dir_to_target = get_dir(user_turf, get_turf(target))
	var/static/list/cursed_katana_slice_angles = list(0, -45, 45, -90, 90) //so that the animation animates towards the target clicked and not towards a side target
	for(var/iteration in cursed_katana_slice_angles)
		var/turf/turf = get_step(user_turf, turn(dir_to_target, iteration))
		user.do_attack_animation(turf, ATTACK_EFFECT_CLAW)
		for(var/mob/living/additional_target in turf)
			if(user.Adjacent(additional_target) && additional_target.density)
				additional_target.apply_damage(15, BRUTE, "chest", TRUE)
				to_chat(additional_target, "<span class='userdanger'>You've been sliced by [user]!</span>")
	target.apply_damage(5, BRUTE, "chest", TRUE)

/obj/item/cursed_katana/proc/cloak(mob/living/target, mob/user)
	if(cloak_on_cooldown)
		to_chat(user, "<span class='warning'>You can not cloak again so soon!</span>")
		target.apply_damage(5, BRUTE, "chest", TRUE) //small damage to make up for it
		return
	user.visible_message("<span class='warning'>[user] vanishes into thin air!</span>",
		"<span class='notice'>You enter the dark cloak.</span>")
	playsound(src, 'sound/magic/smoke.ogg', 50, TRUE)
	user.make_invisible()
	user.sight |= SEE_SELF // so we can see us
	cloak_on_cooldown = TRUE
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/hostile_target = target
		hostile_target.LoseTarget()

	addtimer(CALLBACK(src, .proc/uncloak, user), 5 SECONDS, TIMER_UNIQUE)
	addtimer(VARSET_CALLBACK(src, cloak_on_cooldown, FALSE), 15 SECONDS)

/obj/item/cursed_katana/proc/uncloak(mob/user)
	user.reset_visibility()
	user.sight &= ~SEE_SELF
	user.visible_message("<span class='warning'>[user] appears from thin air!</span>",
		"<span class='notice'>You exit the dark cloak.</span>")
	playsound(src, 'sound/magic/summonitems_generic.ogg', 50, TRUE)

/obj/item/cursed_katana/proc/cut(mob/living/target, mob/user)
	user.visible_message("<span class='warning'>[user] cuts [target]'s tendons!</span>",
		"<span class='notice'>You tendon cut [target]!</span>")
	to_chat(target, "<span class='userdanger'>Your tendons have been cut by [user]!</span>")
	target.apply_damage(15, BRUTE, "chest", TRUE)
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(src, 'sound/weapons/rapierhit.ogg', 50, TRUE)
	var/datum/status_effect/saw_bleed/bloodletting/A = target.has_status_effect(STATUS_EFFECT_BLOODLETTING)
	if(!A)
		target.apply_status_effect(STATUS_EFFECT_BLOODLETTING)
	else
		A.add_bleed(6)

/obj/item/cursed_katana/proc/dash(mob/living/target, mob/user)
	user.visible_message("<span class='warning'>[user] dashes through [target]!</span>",
		"<span class='notice'>You dash through [target]!</span>")
	to_chat(target, ("<span class='userdanger'>[user] dashes through you!</span>"))
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)
	target.apply_damage(17, BRUTE, "chest", TRUE)
	var/turf/dash_target = get_turf(target)
	var/turf/user_turf = get_turf(user)
	for(var/distance in 0 to 8)
		var/turf/current_dash_target = dash_target
		current_dash_target = get_step(current_dash_target, user.dir)
		if(!current_dash_target.density)
			dash_target = current_dash_target
		else
			break
	user_turf.Beam(dash_target, icon_state = "warp_beam", icon = 'icons/effects/effects.dmi', time = 0.3 SECONDS, maxdistance = INFINITY) //Currently not working, need to look into, if anyone has an idea why please tell
	user.forceMove(dash_target)

/obj/item/cursed_katana/proc/shatter(mob/living/target, mob/user)
	user.visible_message("<span class='warning'>[user] shatters [src] over [target]!</span>",
		"<span class='notice'>You shatter [src] over [target]!</span>")
	to_chat(target, "<span class='userdanger'>[user] shatters [src] over you!</span>")
	target.apply_damage((ishostile(target) ? 75 : 35), BRUTE, "chest", TRUE)
	target.KnockDown(3 SECONDS)
	user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(src, 'sound/effects/glassbr3.ogg', 100, TRUE)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/obj/item/organ/internal/cyberimp/arm/katana/O in H.internal_organs)
			if(O.holder == src)
				O.Retract()
	shattered = TRUE
	addtimer(CALLBACK(src, .proc/coagulate, user), 45 SECONDS)

/obj/item/cursed_katana/proc/coagulate(mob/user)
	to_chat(user, "<span class='notice'>[src] reforms!</span>")
	shattered = FALSE
	playsound(src, 'sound/misc/demon_consume.ogg', 50, TRUE)

#undef LEFT_SLASH
#undef RIGHT_SLASH
#undef COMBO_STEPS
#undef COMBO_PROC
#undef ATTACK_STRIKE
#undef ATTACK_SLICE
#undef ATTACK_DASH
#undef ATTACK_CUT
#undef ATTACK_CLOAK
#undef ATTACK_SHATTER
