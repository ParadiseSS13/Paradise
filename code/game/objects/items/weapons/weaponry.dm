/obj/item/banhammer
	desc = "A banhammer"
	name = "banhammer"
	icon = 'icons/obj/items.dmi'
	icon_state = "toyhammer"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	attack_verb = list("banned")
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70)
	resistance_flags = FIRE_PROOF


/obj/item/banhammer/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='suicide'>[user] is hitting [user.p_them()]self with the [src.name]! It looks like [user.p_theyre()] trying to ban [user.p_them()]self from life.</span>")
	return BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS

/obj/item/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	slot_flags = SLOT_BELT
	force = 2
	throwforce = 1
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/sord/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is trying to impale [user.p_them()]self with [src]! It might be a suicide attempt if it weren't so shitty.</span>", \
	"<span class='suicide'>You try to impale yourself with [src], but it's USELESS...</span>")
	return SHAME

/obj/item/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	flags = CONDUCT
	hitsound = 'sound/weapons/bladeslice.ogg'
	slot_flags = SLOT_BELT
	force = 40
	throwforce = 10
	sharp = 1
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF

/obj/item/claymore/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is falling on the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return BRUTELOSS

/obj/item/claymore/ceremonial
	name = "ceremonial claymore"
	desc = "An engraved and fancy version of the claymore. It appears to be less sharp than it's more functional cousin."
	force = 20

/obj/item/katana
	name = "katana"
	desc = "Woefully underpowered in D20"
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 40
	throwforce = 10
	sharp = 1
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 50
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF

/obj/item/katana/cursed
	slot_flags = null

/obj/item/katana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] stomach open with [src]! It looks like [user.p_theyre()] trying to commit seppuku.</span>")
	return BRUTELOSS

/obj/item/harpoon
	name = "harpoon"
	sharp = 1
	desc = "Tharr she blows!"
	icon_state = "harpoon"
	item_state = "harpoon"
	force = 20
	throwforce = 15
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("jabbed","stabbed","ripped")

/obj/item/wirerod
	name = "Wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	flags = CONDUCT
	force = 9
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=1150, MAT_GLASS=75)
	attack_verb = list("hit", "bludgeoned", "whacked", "bonked")

/obj/item/wirerod/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/shard))
		var/obj/item/twohanded/spear/S = new /obj/item/twohanded/spear
		if(istype(I, /obj/item/shard/plasma))
			S.force_wielded = 19
			S.force_unwielded = 11
			S.throwforce = 21
			S.icon_prefix = "spearplasma"
			S.update_icon()
		if(!remove_item_from_storage(user))
			user.unEquip(src)
		user.unEquip(I)

		user.put_in_hands(S)
		to_chat(user, "<span class='notice'>You fasten the glass shard to the top of the rod with the cable.</span>")
		qdel(I)
		qdel(src)

	else if(istype(I, /obj/item/assembly/igniter) && !(I.flags & NODROP))
		var/obj/item/melee/baton/cattleprod/P = new /obj/item/melee/baton/cattleprod

		if(!remove_item_from_storage(user))
			user.unEquip(src)
		user.unEquip(I)

		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You fasten [I] to the top of the rod with the cable.</span>")
		qdel(I)
		qdel(src)

/obj/item/throwing_star
	name = "throwing star"
	desc = "An ancient weapon still used to this day due to it's ease of lodging itself into victim's body parts"
	icon_state = "throwingstar"
	item_state = "eshield0"
	force = 2
	throwforce = 20 //This is never used on mobs since this has a 100% embed chance.
	throw_speed = 4
	embedded_pain_multiplier = 4
	w_class = WEIGHT_CLASS_SMALL
	embed_chance = 100
	embedded_fall_chance = 0 //Hahaha!
	sharp = 1
	materials = list(MAT_METAL=500, MAT_GLASS=500)
	resistance_flags = FIRE_PROOF

/obj/item/spear/kidan
	icon_state = "kidanspear"
	name = "Kidan spear"
	desc = "A one-handed spear brought over from the Kidan homeworld."
	icon_state = "kidanspear"
	item_state = "kidanspear"
	force = 10
	throwforce = 15

/obj/item/melee/baseball_bat
	name = "baseball bat"
	desc = "There ain't a skull in the league that can withstand a swatter."
	icon = 'icons/obj/items.dmi'
	icon_state = "baseball_bat"
	item_state = "baseball_bat"
	var/deflectmode = FALSE // deflect small/medium thrown objects
	var/lastdeflect
	force = 10
	throwforce = 12
	attack_verb = list("beat", "smacked")
	w_class = WEIGHT_CLASS_HUGE
	var/homerun_ready = 0
	var/homerun_able = 0

/obj/item/melee/baseball_bat/homerun
	name = "home run bat"
	desc = "This thing looks dangerous... Dangerously good at baseball, that is."
	homerun_able = 1

/obj/item/melee/baseball_bat/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if(!isitem(hitby) || attack_type != THROWN_PROJECTILE_ATTACK)
		return FALSE
	var/obj/item/I = hitby
	if(I.w_class <= WEIGHT_CLASS_NORMAL || istype(I, /obj/item/beach_ball)) // baseball bat deflecting
		if(deflectmode)
			if(prob(10))
				visible_message("<span class='boldwarning'>[owner] Deflects [I] directly back at the thrower! It's a home run!</span>", "<span class='boldwarning'>You deflect the [I] directly back at the thrower! It's a home run!</span>")
				playsound(get_turf(owner), 'sound/weapons/homerun.ogg', 100, 1)
				do_attack_animation(I, ATTACK_EFFECT_DISARM)
				I.throw_at(I.thrownby, 20, 20, owner)
				deflectmode = FALSE
				if(!istype(I, /obj/item/beach_ball))
					lastdeflect = world.time + 3000
				return TRUE
			else if(prob(30))
				visible_message("<span class='warning'>[owner] swings! And [p_they()] miss[p_es()]! How embarassing.</span>", "<span class='warning'>You swing! You miss! Oh no!</span>")
				playsound(get_turf(owner), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				do_attack_animation(get_step(owner, pick(alldirs)), ATTACK_EFFECT_DISARM)
				deflectmode = FALSE
				if(!istype(I, /obj/item/beach_ball))
					lastdeflect = world.time + 3000
				return FALSE
			else
				visible_message("<span class='warning'>[owner] swings and deflects [I]!</span>", "<span class='warning'>You swing and deflect the [I]!</span>")
				playsound(get_turf(owner), 'sound/weapons/baseball_hit.ogg', 50, 1, -1)
				do_attack_animation(I, ATTACK_EFFECT_DISARM)
				I.throw_at(get_edge_target_turf(owner, pick(cardinal)), rand(8,10), 14, owner)
				deflectmode = FALSE
				if(!istype(I, /obj/item/beach_ball))
					lastdeflect = world.time + 3000
				return TRUE

/obj/item/melee/baseball_bat/attack_self(mob/user)
	if(!homerun_able)
		if(!deflectmode && world.time >= lastdeflect)
			to_chat(user, "<span class='notice'>You prepare to deflect objects thrown at you. You cannot attack during this time.</span>")
			deflectmode = TRUE
		else if(deflectmode && world.time >= lastdeflect)
			to_chat(user, "<span class='notice'>You no longer deflect objects thrown at you. You can attack during this time</span>")
			deflectmode = FALSE
		else
			to_chat(user, "<span class='warning'>You need to wait until you can deflect again. The ability will be ready in [time2text(lastdeflect - world.time, "m:ss")]</span>")
		return ..()
	if(homerun_ready)
		to_chat(user, "<span class='notice'>You're already ready to do a home run!</span>")
		return ..()
	to_chat(user, "<span class='warning'>You begin gathering strength...</span>")
	playsound(get_turf(src), 'sound/magic/lightning_chargeup.ogg', 65, 1)
	if(do_after(user, 90, target = user))
		to_chat(user, "<span class='userdanger'>You gather power! Time for a home run!</span>")
		homerun_ready = 1
	..()

/obj/item/melee/baseball_bat/attack(mob/living/target, mob/living/user)
	if(deflectmode)
		to_chat(user, "<span class='warning'>You cannot attack in deflect mode!</span>")
		return
	. = ..()
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	if(homerun_ready)
		user.visible_message("<span class='userdanger'>It's a home run!</span>")
		target.throw_at(throw_target, rand(8,10), 14, user)
		target.ex_act(2)
		playsound(get_turf(src), 'sound/weapons/homerun.ogg', 100, 1)
		homerun_ready = 0
		return
	else if(!target.anchored)
		target.throw_at(throw_target, rand(1,2), 7, user)

/obj/item/melee/baseball_bat/ablative
	name = "metal baseball bat"
	desc = "This bat is made of highly reflective, highly armored material."
	icon_state = "baseball_bat_metal"
	item_state = "baseball_bat_metal"
	force = 12
	throwforce = 15

/obj/item/melee/baseball_bat/ablative/IsReflect()//some day this will reflect thrown items instead of lasers
	var/picksound = rand(1,2)
	var/turf = get_turf(src)
	if(picksound == 1)
		playsound(turf, 'sound/weapons/effects/batreflect1.ogg', 50, 1)
	if(picksound == 2)
		playsound(turf, 'sound/weapons/effects/batreflect2.ogg', 50, 1)
	return 1
