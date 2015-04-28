/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 *		Spears
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
/obj/item/weapon/twohanded
	var/wielded = 0
	var/force_unwielded = 0
	var/force_wielded = 0
	var/wieldsound = null
	var/unwieldsound = null

/obj/item/weapon/twohanded/proc/unwield()
	wielded = 0
	force = force_unwielded
	name = "[initial(name)]"
	update_icon()

/obj/item/weapon/twohanded/proc/wield()
	wielded = 1
	force = force_wielded
	name = "[initial(name)] (Wielded)"
	update_icon()

/obj/item/weapon/twohanded/mob_can_equip(M as mob, slot)
	//Cannot equip wielded items.
	if(wielded)
		M << "<span class='warning'>Unwield the [initial(name)] first!</span>"
		return 0

	return ..()

/obj/item/weapon/twohanded/dropped(mob/user as mob)
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(user)
		var/obj/item/weapon/twohanded/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield()
	return	unwield()

/obj/item/weapon/twohanded/update_icon()
	return

/obj/item/weapon/twohanded/pickup(mob/user)
	unwield()

/obj/item/weapon/twohanded/attack_self(mob/user as mob)
	if( istype(user,/mob/living/carbon/monkey) )
		user << "<span class='warning'>It's too heavy for you to wield fully.</span>"
		return

	..()
	if(wielded) //Trying to unwield it
		unwield()
		user << "<span class='notice'>You are now carrying the [name] with one hand.</span>"
		if (src.unwieldsound)
			playsound(src.loc, unwieldsound, 50, 1)

		var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
		if(O && istype(O))
			O.unwield()

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_l_hand()
			H.update_inv_r_hand()
			add_fingerprint(user)
		return

	else //Trying to wield it
		if(user.get_inactive_hand())
			user << "<span class='warning'>You need your other hand to be empty</span>"
			return
		wield()
		user << "<span class='notice'>You grab the [initial(name)] with both hands.</span>"
		if (src.wieldsound)
			playsound(src.loc, wieldsound, 50, 1)

		var/obj/item/weapon/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
		O.name = "[initial(name)] - offhand"
		O.desc = "Your second grip on the [initial(name)]"
		user.put_in_inactive_hand(O)

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_l_hand()
			H.update_inv_r_hand()
			add_fingerprint(user)
		return

///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	w_class = 5.0
	icon_state = "offhand"
	name = "offhand"
	flags = ABSTRACT

/obj/item/weapon/twohanded/offhand/unwield()
	del(src)

/obj/item/weapon/twohanded/offhand/wield()
	del(src)

/obj/item/weapon/twohanded/offhand/IsShield()//if the actual twohanded weapon is a shield, we count as a shield too!
	var/mob/user = loc
	if(!istype(user)) return 0
	var/obj/item/I = user.get_active_hand()
	if(I == src) I = user.get_inactive_hand()
	if(!I) return 0
	return I.IsShield()

///////////Two hand required objects///////////////
//This is for objects that require two hands to even pick up
/obj/item/weapon/twohanded/required/
	w_class = 5.0

/obj/item/weapon/twohanded/required/attack_self()
	return

/obj/item/weapon/twohanded/required/mob_can_equip(M as mob, slot)
	if(wielded)
		M << "<span class='warning'>[src.name] is too cumbersome to carry with anything but your hands!</span>"
		return 0
	return ..()

/obj/item/weapon/twohanded/required/attack_hand(mob/user)//Can't even pick it up without both hands empty
	var/obj/item/weapon/twohanded/required/H = user.get_inactive_hand()
	if(H != null)
		user.visible_message("<span class='notice'>[src.name] is too cumbersome to carry in one hand!</span>")
		return
	var/obj/item/weapon/twohanded/offhand/O = new(user)
	user.put_in_inactive_hand(O)
	..()
	wielded = 1


obj/item/weapon/twohanded/

/*
 * Fireaxe
 */
/obj/item/weapon/twohanded/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	sharp = 1
	edge = 1
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_unwielded = 5
	force_wielded = 24
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/twohanded/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "fireaxe[wielded]"
	return

/obj/item/weapon/twohanded/fireaxe/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	..()
	if(A && wielded && (istype(A,/obj/structure/window) || istype(A,/obj/structure/grille))) //destroys windows and grilles in one hit

		if(istype(A,/obj/structure/window))
		/*	var/pdiff=performWallPressureCheck(A.loc)
			if(pdiff>0)
				message_admins("[A] with pdiff [pdiff] fire-axed by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(A.loc)]!")
				log_admin("[A] with pdiff [pdiff] fire-axed by [user.real_name] ([user.ckey]) at [A.loc]!")*///TODO: Figure out how the hell to remake this proc
			var/obj/structure/window/W = A
			W.destroy()
		else
			qdel(A)


/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/weapon/twohanded/dualsaber
	var/hacked = 0
	var/blade_color
	icon_override = 'icons/mob/in-hand/swords.dmi'
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	force_unwielded = 3
	force_wielded = 34
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	flags = NOSHIELD
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = 1
	edge = 1
	no_embed = 1 // Like with the single-handed esword, this shouldn't be embedding in people.

/obj/item/weapon/twohanded/dualsaber/New()
	blade_color = pick("red", "blue", "green", "purple")

/obj/item/weapon/twohanded/dualsaber/update_icon()
	if(wielded)
		icon_state = "dualsaber[blade_color][wielded]"
		reflect_chance = 100
	else
		icon_state = "dualsaber0"
		reflect_chance = 0

/obj/item/weapon/twohanded/dualsaber/attack(target as mob, mob/living/user as mob)
	..()
	if((CLUMSY in user.mutations) && (wielded) &&prob(40))
		user << "\red You twirl around a bit before losing your balance and impaling yourself on the [src]."
		user.take_organ_damage(20,25)
		return
	if((wielded) && prob(50))
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
				user.dir = i
				sleep(1)

/obj/item/weapon/twohanded/dualsaber/IsShield()
	if(wielded)
		return 1
	else
		return 0

/obj/item/weapon/twohanded/dualsaber/green
	New()
		blade_color = "green"

/obj/item/weapon/twohanded/dualsaber/red
	New()
		blade_color = "red"

/obj/item/weapon/twohanded/dualsaber/purple
	New()
		blade_color = "purple"

/obj/item/weapon/twohanded/dualsaber/blue
	New()
		blade_color = "blue"

/obj/item/weapon/twohanded/dualsaber/unwield()
	..()
	hitsound = "swing_hit"

/obj/item/weapon/twohanded/dualsaber/wield()
	..()
	hitsound = 'sound/weapons/blade1.ogg'

/obj/item/weapon/twohanded/dualsaber/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			user << "<span class='warning'>2XRNBW_ENGAGE</span>"
			blade_color = "rainbow"
			update_icon()
		else
			user << "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>"


//spears
/obj/item/weapon/twohanded/spear
	icon_state = "spearglass0"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 18 // Was 13, Buffed - RR
	throwforce = 20
	throw_speed = 3
	no_spin = 1
	flags = NOSHIELD
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")

/obj/item/weapon/twohanded/spear/update_icon()
	icon_state = "spearglass[wielded]"
	return

/obj/item/weapon/twohanded/spear/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

//Putting heads on spears
/obj/item/weapon/organ/head/attackby(var/obj/item/weapon/W, var/mob/living/user, params)
	if(istype(W, /obj/item/weapon/twohanded/spear))
		user << "<span class='notice'>You stick the head onto the spear and stand it upright on the ground.</span>"
		var/obj/structure/headspear/HS = new /obj/structure/headspear(user.loc)
		var/matrix/M = matrix()
		src.transform = M
		user.drop_item()
		src.loc = HS
		var/image/IM = image(src.icon,src.icon_state)
		IM.overlays = src.overlays.Copy()
		HS.overlays += IM
		qdel(W)
		return
	return ..()

/obj/item/weapon/twohanded/spear/attackby(var/obj/item/I, var/mob/living/user)
	if(istype(I, /obj/item/weapon/organ/head))
		user << "<span class='notice'>You stick the head onto the spear and stand it upright on the ground.</span>"
		var/obj/structure/headspear/HS = new /obj/structure/headspear(user.loc)
		var/matrix/M = matrix()
		I.transform = M
		usr.drop_item()
		I.loc = HS
		var/image/IM = image(I.icon,I.icon_state)
		IM.overlays = I.overlays.Copy()
		HS.overlays += IM
		qdel(src)
		return
	return ..()

/obj/structure/headspear
	name = "head on a spear"
	desc = "How barbaric."
	icon_state = "headspear"
	density = 0
	anchored = 1


/obj/structure/headspear/attack_hand(mob/living/user)
	user.visible_message("<span class='warning'>[user] kicks over \the [src]!</span>", "<span class='danger'>You kick down \the [src]!</span>")
	new /obj/item/weapon/twohanded/spear(user.loc)
	for(var/obj/item/weapon/organ/head/H in src)
		H.loc = user.loc
	qdel(src)

/obj/item/weapon/twohanded/spear/kidan
	icon_state = "kidanspear0"
	name = "Kidan spear"
	desc = "A spear brought over from the Kidan homeworld."


///CHAINSAW///

/obj/item/weapon/twohanded/chainsaw
	icon_override = 'icons/mob/in-hand/swords.dmi'
	icon_state = "chainsaw0"
	name = "Chainsaw"
	desc = "Perfect for felling trees or fellow spaceman."
	force = 15
	throwforce = 15
	throw_speed = 1
	throw_range = 5
	w_class = 4.0 // can't fit in backpacks
	force_unwielded = 15 //still pretty robust
	force_wielded = 50  //you'll gouge their eye out! Or a limb...maybe even their entire body!
	wieldsound = 'sound/weapons/chainsawstart.ogg'
	hitsound = null
	flags = NOSHIELD
	origin_tech = "materials=6;syndicate=4"
	attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")
	sharp = 1
	edge = 1
	no_embed = 1


/obj/item/weapon/twohanded/chainsaw/update_icon()
	if(wielded)
		icon_state = "chainsaw[wielded]"
	else
		icon_state = "chainsaw0"


/obj/item/weapon/twohanded/chainsaw/attack(mob/target as mob, mob/living/user as mob)
	if(wielded)
		playsound(loc, 'sound/weapons/chainsaw.ogg', 100, 1, -1) //incredibly loud; you ain't goin' for stealth with this thing. Credit to Lonemonk of Freesound for this sound.
		if(isrobot(target))
			..()
			return
		if(!isliving(target))
			return
		else
			target.Weaken(4)
			..()
		return
	else
		playsound(loc, "swing_hit", 50, 1, -1)
		return ..()

/obj/item/weapon/twohanded/chainsaw/IsShield() //Disarming someone with a chainsaw should be difficult.
	if(wielded)
		return 1
	else
		return 0

// SINGULOHAMMER

/obj/item/weapon/twohanded/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."

	icon_override = 'icons/mob/in-hand/swords.dmi'
	icon_state = "mjollnir0"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	no_embed = 1
	force = 5
	force_unwielded = 5
	force_wielded = 20
	throwforce = 15
	throw_range = 1
	w_class = 5
	var/charged = 5
	origin_tech = "combat=5;bluespace=4"



/obj/item/weapon/twohanded/singularityhammer/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/twohanded/singularityhammer/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/twohanded/singularityhammer/process()
	if(charged < 5)
		charged++
	return

/obj/item/weapon/twohanded/singularityhammer/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir[wielded]"
	return


/obj/item/weapon/twohanded/singularityhammer/proc/vortex(var/turf/pull as turf, mob/wielder as mob)
	for(var/atom/X in orange(5,pull))
		if(istype(X, /atom/movable))
			if(X == wielder) continue
			if((X) &&(!X:anchored) && (!istype(X,/mob/living/carbon/human)))
				step_towards(X,pull)
				step_towards(X,pull)
				step_towards(X,pull)
			else if(istype(X,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = X
				if(istype(H.shoes,/obj/item/clothing/shoes/magboots))
					var/obj/item/clothing/shoes/magboots/M = H.shoes
					if(M.magpulse)
						continue
				H.apply_effect(1, WEAKEN, 0)
				step_towards(H,pull)
				step_towards(H,pull)
				step_towards(H,pull)
	return



/obj/item/weapon/twohanded/singularityhammer/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	if(wielded)
		if(charged == 5)
			charged = 0
			if(istype(A, /mob/living/))
				var/mob/living/Z = A
				Z.take_organ_damage(20,0)
			playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			var/turf/target = get_turf(A)
			vortex(target,user)


/obj/item/weapon/twohanded/mjollnir
	name = "Mjollnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon_override = 'icons/mob/in-hand/swords.dmi'
	icon_state = "mjollnir0"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	no_embed = 1
	force = 5
	force_unwielded = 5
	force_wielded = 20
	throwforce = 30
	throw_range = 7
	w_class = 5
	//var/charged = 5
	origin_tech = "combat=5;powerstorage=5"

/obj/item/weapon/twohanded/mjollnir/proc/shock(mob/living/target as mob)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(5, 1, target.loc)
	s.start()
	target.take_organ_damage(0,30)
	target.visible_message("<span class='danger'>[target.name] was shocked by the [src.name]!</span>", \
		"<span class='userdanger'>You feel a powerful shock course through your body sending you flying!</span>", \
		"<span class='danger'>You hear a heavy electrical crack.</span>")
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)
	return


/obj/item/weapon/twohanded/mjollnir/attack(mob/M as mob, mob/user as mob)
	..()
	spawn(0)
	if(wielded)
		//if(charged == 5)
		//charged = 0
		playsound(src.loc, "sparks", 50, 1)
		if(istype(M, /mob/living))
			M.Stun(10)
			shock(M)


/obj/item/weapon/twohanded/mjollnir/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir[wielded]"
	return



/obj/item/weapon/twohanded/knighthammer
	name = "singuloth knight's hammer"
	desc = "A hammer made of sturdy metal with a golden skull adorned with wings on either side of the head. <br>This weapon causes devastating damage to those it hits due to a power field sustained by a mini-singularity inside of the hammer."

	icon_override = 'icons/mob/in-hand/swords.dmi'
	icon_state = "adrhammer0"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	no_embed = 1
	force = 5
	force_unwielded = 5
	force_wielded = 30
	throwforce = 15
	throw_range = 1
	w_class = 5
	var/charged = 5
	origin_tech = "combat=5;bluespace=4"



/obj/item/weapon/twohanded/knighthammer/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/twohanded/knighthammer/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/twohanded/knighthammer/process()
	if(charged < 5)
		charged++
	return

/obj/item/weapon/twohanded/knighthammer/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "adrhammer[wielded]"
	return


/obj/item/weapon/twohanded/knighthammer/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	if(charged == 5)
		charged = 0
		if(istype(A, /mob/living/))
			var/mob/living/Z = A
			if(Z.health >= 1)
				Z.visible_message("<span class='danger'>[Z.name] was sent flying by a blow from the [src.name]!</span>", \
					"<span class='userdanger'>You feel a powerful blow connect with your body and send you flying!</span>", \
					"<span class='danger'>You hear something heavy impact flesh!.</span>")
				var/atom/throw_target = get_edge_target_turf(Z, get_dir(src, get_step_away(Z, src)))
				Z.throw_at(throw_target, 200, 4)
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			else if(wielded && Z.health < 1)
				Z.visible_message("<span class='danger'>[Z.name] was blown to peices by the power of [src.name]!</span>", \
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
			else if (istype(A, /obj/structure) || istype(A, /obj/mecha/))
				var/obj/Z = A
				Z.ex_act(2)
				charged = 3
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
