/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 *		Spears
 *		Kidan spear
 *		Chainsaw
 *		Singularity hammer
 * 		Mjolnnir
 *		Knighthammer
 */

/*##################################################################
##################### TWO HANDED WEAPONS BE HERE~ -Agouri :3 ########
####################################################################*/

//Rewrote TwoHanded weapons stuff and put it all here. Just copypasta fireaxe to make new ones ~Carn
//This rewrite means we don't have two variables for EVERY item which are used only by a few weapons.
//It also tidies stuff up elsewhere.

/*
 * Twohanded
 */
/obj/item/twohanded
	var/wielded = FALSE
	var/force_unwielded = 0
	var/force_wielded = 0
	var/wieldsound = null
	var/unwieldsound = null
	var/sharp_when_wielded = FALSE

/obj/item/twohanded/proc/unwield(mob/living/carbon/user)
	if(!wielded || !user)
		return FALSE
	wielded = FALSE
	force = force_unwielded
	if(sharp_when_wielded)
		sharp = FALSE
	var/sf = findtext(name," (Wielded)")
	if(sf)
		name = copytext(name, 1, sf)
	else //something wrong
		name = "[initial(name)]"
	update_icon()
	if(user)
		user.update_inv_r_hand()
		user.update_inv_l_hand()
	if(isrobot(user))
		to_chat(user, "<span class='notice'>You free up your module.</span>")
	else
		to_chat(user, "<span class='notice'>You are now carrying [name] with one hand.</span>")
	if(unwieldsound)
		playsound(loc, unwieldsound, 50, 1)
	var/obj/item/twohanded/offhand/O = user.get_inactive_hand()
	if(O && istype(O))
		O.unwield()
	return TRUE

/obj/item/twohanded/proc/wield(mob/living/carbon/user)
	if(wielded)
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna.species.is_small)
			to_chat(user, "<span class='warning'>It's too heavy for you to wield fully.</span>")
			return FALSE
	if(user.get_inactive_hand())
		to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return FALSE
	wielded = TRUE
	force = force_wielded
	if(sharp_when_wielded)
		sharp = TRUE
	name = "[name] (Wielded)"
	update_icon()
	if(user)
		user.update_inv_r_hand()
		user.update_inv_l_hand()
	if(isrobot(user))
		to_chat(user, "<span class='notice'>You dedicate your module to [name].</span>")
	else
		to_chat(user, "<span class='notice'>You grab the [name] with both hands.</span>")
	if(wieldsound)
		playsound(loc, wieldsound, 50, 1)
	var/obj/item/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
	O.name = "[name] - offhand"
	O.desc = "Your second grip on the [name]"
	user.put_in_inactive_hand(O)
	return TRUE

/obj/item/twohanded/dropped(mob/user)
	..()
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(user)
		var/obj/item/twohanded/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield(user)
	return unwield(user)

/obj/item/twohanded/attack_self(mob/user)
	..()
	if(wielded) //Trying to unwield it
		unwield(user)
	else //Trying to wield it
		wield(user)


/obj/item/twohanded/equip_to_best_slot(mob/M)
	if(..())
		unwield(M)
		return

///////////OFFHAND///////////////
/obj/item/twohanded/offhand
	w_class = WEIGHT_CLASS_HUGE
	icon_state = "offhand"
	name = "offhand"
	flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/twohanded/offhand/unwield()
	if(!QDELETED(src))
		qdel(src)

/obj/item/twohanded/offhand/wield()
	if(!QDELETED(src))
		qdel(src)

///////////Two hand required objects///////////////
//This is for objects that require two hands to even pick up
/obj/item/twohanded/required
	w_class = WEIGHT_CLASS_HUGE

/obj/item/twohanded/required/attack_self()
	return

/obj/item/twohanded/required/mob_can_equip(mob/M, slot)
	if(wielded && !slot_flags)
		to_chat(M, "<span class='warning'>[src] is too cumbersome to carry with anything but your hands!</span>")
		return FALSE
	return ..()

/obj/item/twohanded/required/attack_hand(mob/user)//Can't even pick it up without both hands empty
	var/obj/item/twohanded/required/H = user.get_inactive_hand()
	if(get_dist(src, user) > 1)
		return FALSE
	if(H != null)
		to_chat(user, "<span class='notice'>[src] is too cumbersome to carry in one hand!</span>")
		return
	if(loc != user)
		wield(user)
	..()

/obj/item/twohanded/required/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	var/obj/item/twohanded/required/H = receiver.get_inactive_hand()
	if(H != null) //Check if he can wield it
		receiver.drop_item() //Can't wear it so drop it
		to_chat(receiver, "<span class='notice'>[src] is too cumbersome to carry in one hand!</span>")
		return
	equipped(receiver,receiver.hand ? slot_l_hand : slot_r_hand)

/obj/item/twohanded/required/equipped(mob/user, slot)
	..()
	if(slot == slot_l_hand || slot == slot_r_hand)
		wield(user)
		if(!wielded) // Drop immediately if we couldn't wield
			user.unEquip(src)
			to_chat(user, "<span class='notice'>[src] is too cumbersome to carry in one hand!</span>")
	else
		unwield(user)

/*
 * Fireaxe
 */
/obj/item/twohanded/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	sharp = TRUE
	embed_chance = 25
	embedded_ignore_throwspeed_threshold = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 5
	force_wielded = 24
	toolspeed = 0.25
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/crowbar.ogg'
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 30)
	resistance_flags = FIRE_PROOF

/obj/item/twohanded/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "fireaxe[wielded]"
	..()

/obj/item/twohanded/fireaxe/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(wielded) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille))
			var/obj/structure/W = A
			W.obj_destruction("fireaxe")

/obj/item/twohanded/fireaxe/boneaxe  // Blatant imitation of the fireaxe, but made out of bone.
	icon_state = "bone_axe0"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	force_wielded = 23
	needs_permit = TRUE

/obj/item/twohanded/fireaxe/boneaxe/update_icon()
	icon_state = "bone_axe[wielded]"

/obj/item/twohanded/fireaxe/energized
	desc = "Someone with a love for fire axes decided to turn this one into a high-powered energy weapon. Seems excessive."
	force_wielded = 30
	armour_penetration = 20
	var/charge = 30
	var/max_charge = 30

/obj/item/twohanded/fireaxe/energized/update_icon()
	if(wielded)
		icon_state = "fireaxe2"
	else
		icon_state = "fireaxe0"

/obj/item/twohanded/fireaxe/energized/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/fireaxe/energized/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/twohanded/fireaxe/energized/process()
	charge = min(charge + 1, max_charge)

/obj/item/twohanded/fireaxe/energized/attack(mob/M, mob/user)
	. = ..()
	if(wielded && charge == max_charge)
		if(isliving(M))
			charge = 0
			playsound(loc, 'sound/magic/lightningbolt.ogg', 5, 1)
			user.visible_message("<span class='danger'>[user] slams the charged axe into [M.name] with all [user.p_their()] might!</span>")
			do_sparks(1, 1, src)
			M.Weaken(3)
			var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
			M.throw_at(throw_target, 5, 1)

/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/twohanded/dualsaber
	var/hacked = FALSE
	var/blade_color
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	force_unwielded = 3
	force_wielded = 34
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	armour_penetration = 35
	origin_tech = "magnets=4;syndicate=5"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 75
	sharp_when_wielded = TRUE // only sharp when wielded
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70)
	resistance_flags = FIRE_PROOF
	light_power = 2
	needs_permit = TRUE
	var/brightness_on = 2
	var/colormap = list(red=LIGHT_COLOR_RED, blue=LIGHT_COLOR_LIGHTBLUE, green=LIGHT_COLOR_GREEN, purple=LIGHT_COLOR_PURPLE, rainbow=LIGHT_COLOR_WHITE)

/obj/item/twohanded/dualsaber/New()
	..()
	if(!blade_color)
		blade_color = pick("red", "blue", "green", "purple")

/obj/item/twohanded/dualsaber/update_icon()
	if(wielded)
		icon_state = "dualsaber[blade_color][wielded]"
		set_light(brightness_on, l_color=colormap[blade_color])
	else
		icon_state = "dualsaber0"
		set_light(0)
	..()

/obj/item/twohanded/dualsaber/attack(mob/target, mob/living/user)
	..()
	if((CLUMSY in user.mutations) && (wielded) && prob(40))
		to_chat(user, "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on the [src].</span>")
		user.take_organ_damage(20, 25)
		return
	if((wielded) && prob(50))
		INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/twohanded/dualsaber/proc/jedi_spin(mob/living/user)
	for(var/i in list(NORTH, SOUTH, EAST, WEST, EAST, SOUTH, NORTH, SOUTH, EAST, WEST, EAST, SOUTH))
		user.setDir(i)
		if(i == WEST)
			user.SpinAnimation(7, 1)
		sleep(1)

/obj/item/twohanded/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		return ..()
	return FALSE

/obj/item/twohanded/dualsaber/green
	blade_color = "green"

/obj/item/twohanded/dualsaber/red
	blade_color = "red"

/obj/item/twohanded/dualsaber/purple
	blade_color = "purple"

/obj/item/twohanded/dualsaber/blue
	blade_color = "blue"

/obj/item/twohanded/dualsaber/unwield()
	. = ..()
	if(!.)
		return
	hitsound = "swing_hit"
	w_class = initial(w_class)

/obj/item/twohanded/dualsaber/IsReflect()
	if(wielded)
		return TRUE

/obj/item/twohanded/dualsaber/wield(mob/living/carbon/M) //Specific wield () hulk checks due to reflection chance for balance issues and switches hitsounds.
	if(HULK in M.mutations)
		to_chat(M, "<span class='warning'>You lack the grace to wield this!</span>")
		return
	. = ..()
	if(!.)
		return
	hitsound = 'sound/weapons/blade1.ogg'
	w_class = w_class_on

/obj/item/twohanded/dualsaber/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!hacked)
		hacked = TRUE
		to_chat(user, "<span class='warning'>2XRNBW_ENGAGE</span>")
		blade_color = "rainbow"
		update_icon()
	else
		to_chat(user, "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")

//spears
/obj/item/twohanded/spear
	icon_state = "spearglass0"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 18
	throwforce = 20
	throw_speed = 4
	armour_penetration = 10
	materials = list(MAT_METAL = 1150, MAT_GLASS = 2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharp = TRUE
	embed_chance = 50
	embedded_ignore_throwspeed_threshold = TRUE
	no_spin_thrown = TRUE
	var/obj/item/grenade/explosive = null
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	needs_permit = TRUE
	var/icon_prefix = "spearglass"

/obj/item/twohanded/spear/update_icon()
	icon_state = "[icon_prefix][wielded]"

/obj/item/twohanded/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
	if(istype(tip, /obj/item/shard/plasma))
		force_wielded = 19
		force_unwielded = 11
		throwforce = 21
		icon_prefix = "spearplasma"
	update_icon()
	qdel(tip)
	..()


/obj/item/twohanded/spear/afterattack(atom/movable/AM, mob/user, proximity)
	if(!proximity)
		return
	if(isturf(AM)) //So you can actually melee with it
		return
	if(explosive && wielded)
		explosive.forceMove(AM)
		explosive.prime()
		qdel(src)

/obj/item/twohanded/spear/throw_impact(atom/target)
	. = ..()
	if(explosive)
		explosive.prime()
		qdel(src)

/obj/item/twohanded/spear/bonespear	//Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	icon_state = "bone_spear0"
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."
	force = 11
	force_unwielded = 11
	force_wielded = 20					//I have no idea how to balance
	throwforce = 22
	armour_penetration = 15				//Enhanced armor piercing
	icon_prefix = "bone_spear"

//GREY TIDE
/obj/item/twohanded/spear/grey_tide
	icon_state = "spearglass0"
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	force_unwielded = 15
	force_wielded = 25
	throwforce = 20
	throw_speed = 4
	attack_verb = list("gored")

/obj/item/twohanded/spear/grey_tide/afterattack(atom/movable/AM, mob/living/user, proximity)
	..()
	if(!proximity)
		return
	user.faction |= "greytide(\ref[user])"
	if(isliving(AM))
		var/mob/living/L = AM
		if(istype (L, /mob/living/simple_animal/hostile/illusion))
			return
		if(!L.stat && prob(50))
			var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
			M.faction = user.faction.Copy()
			M.attack_sound = hitsound
			M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
			M.GiveTarget(L)

//Putting heads on spears
/obj/item/twohanded/spear/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/organ/external/head))
		if(user.unEquip(src) && user.drop_item())
			to_chat(user, "<span class='notice'>You stick [I] onto the spear and stand it upright on the ground.</span>")
			var/obj/structure/headspear/HS = new /obj/structure/headspear(get_turf(src))
			var/matrix/M = matrix()
			I.transform = M
			var/image/IM = image(I.icon, I.icon_state)
			IM.overlays = I.overlays.Copy()
			HS.overlays += IM
			I.forceMove(HS)
			HS.mounted_head = I
			forceMove(HS)
			HS.contained_spear = src
	else
		return ..()

/obj/structure/headspear
	name = "head on a spear"
	desc = "How barbaric."
	icon_state = "headspear"
	density = FALSE
	anchored = TRUE
	var/obj/item/organ/external/head/mounted_head = null
	var/obj/item/twohanded/spear/contained_spear = null

/obj/structure/headspear/Destroy()
	QDEL_NULL(mounted_head)
	QDEL_NULL(contained_spear)
	return ..()

/obj/structure/headspear/attack_hand(mob/living/user)
	user.visible_message("<span class='warning'>[user] kicks over [src]!</span>", "<span class='danger'>You kick down [src]!</span>")
	playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
	var/turf/T = get_turf(src)
	if(contained_spear)
		contained_spear.forceMove(T)
		contained_spear = null
	if(mounted_head)
		mounted_head.forceMove(T)
		mounted_head = null
	qdel(src)

/obj/item/twohanded/spear/kidan
	icon_state = "kidanspear0"
	name = "Kidan spear"
	desc = "A spear brought over from the Kidan homeworld."

// DIY CHAINSAW
/obj/item/twohanded/required/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon_state = "gchainsaw_off"
	flags = CONDUCT
	force = 13
	var/force_on = 24
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	materials = list(MAT_METAL = 13000)
	origin_tech = "materials=3;engineering=4;combat=2"
	attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")
	hitsound = "swing_hit"
	sharp = TRUE
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE
	actions_types = list(/datum/action/item_action/startchainsaw)
	var/on = FALSE

/obj/item/twohanded/required/chainsaw/attack_self(mob/user)
	on = !on
	to_chat(user, "As you pull the starting cord dangling from [src], [on ? "it begins to whirr." : "the chain stops moving."]")
	if(on)
		playsound(loc, 'sound/weapons/chainsawstart.ogg', 50, 1)
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(throwforce)
	icon_state = "gchainsaw_[on ? "on" : "off"]"

	if(hitsound == "swing_hit")
		hitsound = 'sound/weapons/chainsaw.ogg'
	else
		hitsound = "swing_hit"

	if(src == user.get_active_hand()) //update inhands
		user.update_inv_l_hand()
		user.update_inv_r_hand()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/twohanded/required/chainsaw/attack_hand(mob/user)
	. = ..()
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(throwforce)

/obj/item/twohanded/required/chainsaw/on_give(mob/living/carbon/giver, mob/living/carbon/receiver)
	. = ..()
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(throwforce)

/obj/item/twohanded/required/chainsaw/doomslayer
	name = "OOOH BABY"
	desc = "<span class='warning'>VRRRRRRR!!!</span>"
	armour_penetration = 100
	force_on = 30

/obj/item/twohanded/required/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message("<span class='danger'>Ranged attacks just make [owner] angrier!</span>")
		playsound(src, pick('sound/weapons/bulletflyby.ogg','sound/weapons/bulletflyby2.ogg','sound/weapons/bulletflyby3.ogg'), 75, 1)
		return TRUE
	return FALSE


///CHAINSAW///
/obj/item/twohanded/chainsaw
	icon_state = "chainsaw0"
	name = "Chainsaw"
	desc = "Perfect for felling trees or fellow spacemen."
	force = 15
	throwforce = 15
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_BULKY // can't fit in backpacks
	force_unwielded = 15 //still pretty robust
	force_wielded = 40  //you'll gouge their eye out! Or a limb...maybe even their entire body!
	hitsound = null // Handled in the snowflaked attack proc
	wieldsound = 'sound/weapons/chainsawstart.ogg'
	hitsound = null
	armour_penetration = 35
	origin_tech = "materials=6;syndicate=4"
	attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")
	sharp = TRUE
	embed_chance = 10
	embedded_ignore_throwspeed_threshold = TRUE

/obj/item/twohanded/chainsaw/update_icon()
	if(wielded)
		icon_state = "chainsaw[wielded]"
	else
		icon_state = "chainsaw0"
	..()

/obj/item/twohanded/chainsaw/attack(mob/target, mob/living/user)
	if(wielded)
		playsound(loc, 'sound/weapons/chainsaw.ogg', 100, 1, -1) //incredibly loud; you ain't goin' for stealth with this thing. Credit to Lonemonk of Freesound for this sound.
		if(isrobot(target))
			..()
			return
		if(!isliving(target))
			return
		else
			target.Weaken(1)
			..()
		return
	else
		playsound(loc, "swing_hit", 50, 1, -1)
		return ..()

/obj/item/twohanded/chainsaw/wield() //you can't disarm an active chainsaw, you crazy person.
	. = ..()
	if(.)
		flags |= NODROP

/obj/item/twohanded/chainsaw/unwield()
	. = ..()
	if(.)
		flags &= ~NODROP

// SINGULOHAMMER
/obj/item/twohanded/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	icon_state = "mjollnir0"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 20
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/charged = 5
	origin_tech = "combat=4;bluespace=4;plasmatech=7"

/obj/item/twohanded/singularityhammer/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/singularityhammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/twohanded/singularityhammer/process()
	if(charged < 5)
		charged++

/obj/item/twohanded/singularityhammer/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir[wielded]"
	..()

/obj/item/twohanded/singularityhammer/proc/vortex(turf/pull, mob/wielder)
	for(var/atom/movable/X in orange(5, pull))
		if(X == wielder)
			continue
		if((X) && (!X.anchored) && (!ishuman(X)))
			step_towards(X, pull)
			step_towards(X, pull)
			step_towards(X, pull)
		else if(ishuman(X))
			var/mob/living/carbon/human/H = X
			if(istype(H.shoes, /obj/item/clothing/shoes/magboots))
				var/obj/item/clothing/shoes/magboots/M = H.shoes
				if(M.magpulse)
					continue
			H.apply_effect(1, WEAKEN, 0)
			step_towards(H, pull)
			step_towards(H, pull)
			step_towards(H, pull)

/obj/item/twohanded/singularityhammer/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(wielded)
		if(charged == 5)
			charged = 0
			if(isliving(A))
				var/mob/living/Z = A
				Z.take_organ_damage(20, 0)
			playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			var/turf/target = get_turf(A)
			vortex(target, user)

/obj/item/twohanded/mjollnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon_state = "mjollnir0"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 25
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE
	//var/charged = 5
	origin_tech = "combat=4;powerstorage=7"

/obj/item/twohanded/mjollnir/proc/shock(mob/living/target)
	do_sparks(5, 1, target.loc)
	target.visible_message("<span class='danger'>[target.name] was shocked by the [name]!</span>", \
		"<span class='userdanger'>You feel a powerful shock course through your body sending you flying!</span>", \
		"<span class='italics'>You hear a heavy electrical crack!</span>")
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)

/obj/item/twohanded/mjollnir/attack(mob/M, mob/user)
	..()
	if(wielded)
		//if(charged == 5)
		//charged = 0
		playsound(loc, "sparks", 50, 1)
		if(isliving(M))
			M.Stun(2)
			shock(M)

/obj/item/twohanded/mjollnir/throw_impact(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.Stun(2)
		shock(L)

/obj/item/twohanded/mjollnir/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir[wielded]"
	..()

/obj/item/twohanded/knighthammer
	name = "singuloth knight's hammer"
	desc = "A hammer made of sturdy metal with a golden skull adorned with wings on either side of the head. <br>This weapon causes devastating damage to those it hits due to a power field sustained by a mini-singularity inside of the hammer."
	icon_state = "knighthammer0"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	force = 5
	force_unwielded = 5
	force_wielded = 30
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	var/charged = 5
	origin_tech = "combat=5;bluespace=4"

/obj/item/twohanded/knighthammer/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/twohanded/knighthammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/twohanded/knighthammer/process()
	if(charged < 5)
		charged++

/obj/item/twohanded/knighthammer/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "knighthammer[wielded]"
	..()

/obj/item/twohanded/knighthammer/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(charged == 5)
		charged = 0
		if(isliving(A))
			var/mob/living/Z = A
			if(Z.health >= 1)
				Z.visible_message("<span class='danger'>[Z.name] was sent flying by a blow from the [name]!</span>", \
					"<span class='userdanger'>You feel a powerful blow connect with your body and send you flying!</span>", \
					"<span class='danger'>You hear something heavy impact flesh!.</span>")
				var/atom/throw_target = get_edge_target_turf(Z, get_dir(src, get_step_away(Z, src)))
				Z.throw_at(throw_target, 200, 4)
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			else if(wielded && Z.health < 1)
				Z.visible_message("<span class='danger'>[Z.name] was blown to pieces by the power of [name]!</span>", \
					"<span class='userdanger'>You feel a powerful blow rip you apart!</span>", \
					"<span class='danger'>You hear a heavy impact and the sound of ripping flesh!.</span>")
				Z.gib()
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
		if(wielded)
			if(istype(A, /turf/simulated/wall))
				var/turf/simulated/wall/Z = A
				Z.ex_act(2)
				charged = 3
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			else if(istype(A, /obj/structure) || istype(A, /obj/mecha))
				var/obj/Z = A
				Z.ex_act(2)
				charged = 3
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)

/obj/item/twohanded/pitchfork
	icon_state = "pitchfork0"
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	force_unwielded = 7
	force_wielded = 15
	attack_verb = list("attacked", "impaled", "pierced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 30)
	resistance_flags = FIRE_PROOF

/obj/item/twohanded/pitchfork/demonic
	name = "demonic pitchfork"
	desc = "A red pitchfork, it looks like the work of the devil."
	force = 19
	throwforce = 24
	force_unwielded = 19
	force_wielded = 25

/obj/item/twohanded/pitchfork/demonic/greater
	force = 24
	throwforce = 50
	force_unwielded = 24
	force_wielded = 34

/obj/item/twohanded/pitchfork/demonic/ascended
	force = 100
	throwforce = 100
	force_unwielded = 100
	force_wielded = 500000 // Kills you DEAD.

/obj/item/twohanded/pitchfork/update_icon()
	icon_state = "pitchfork[wielded]"

/obj/item/twohanded/pitchfork/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] impales \himself in \his abdomen with [src]! It looks like \he's trying to commit suicide...</span>")
	return BRUTELOSS

/obj/item/twohanded/pitchfork/demonic/pickup(mob/user)
	. = ..()
	if(istype(user, /mob/living))
		var/mob/living/U = user
		if(U.mind && !U.mind.devilinfo && (U.mind.soulOwner == U.mind)) //Burn hands unless they are a devil or have sold their soul
			U.visible_message("<span class='warning'>As [U] picks [src] up, [U]'s arms briefly catch fire.</span>", \
				"<span class='warning'>\"As you pick up the [src] your arms ignite, reminding you of all your past sins.\"</span>")
			if(ishuman(U))
				var/mob/living/carbon/human/H = U
				H.apply_damage(rand(force/2, force), BURN, pick("l_arm", "r_arm"))
			else
				U.adjustFireLoss(rand(force/2,force))

/obj/item/twohanded/pitchfork/demonic/attack(mob/target, mob/living/carbon/human/user)
	if(user.mind && !user.mind.devilinfo && (user.mind.soulOwner != user.mind))
		to_chat(user, "<span class ='warning'>The [src] burns in your hands.</span>")
		user.apply_damage(rand(force/2, force), BURN, pick("l_arm", "r_arm"))
	..()

// It's no fun being the lord of all hell if you can't get out of a simple room
/obj/item/twohanded/pitchfork/demonic/ascended/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !wielded)
		return
	if(istype(target, /turf/simulated/wall))
		var/turf/simulated/wall/W = target
		user.visible_message("<span class='danger'>[user] blasts \the [target] with \the [src]!</span>")
		playsound(target, 'sound/magic/Disintegrate.ogg', 100, 1)
		W.devastate_wall(TRUE)
		return 1
	..()

/obj/item/twohanded/bamboospear
	icon_state = "bamboo_spear0"
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 18
	throwforce = 22
	throw_speed = 4
	armour_penetration = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "tore", "gored")
	sharp = TRUE
	embed_chance = 50
	embedded_ignore_throwspeed_threshold = TRUE

/obj/item/twohanded/bamboospear/update_icon()
	icon_state = "bamboo_spear[wielded]"
