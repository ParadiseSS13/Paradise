#define CHAOS_STAFF_DAMAGE 30 //Damaging effects will use this number, multiplied or divided depending on effect
#define CHAOS_STAFF_LETHAL_CHANCE 5 //These should add up to 100
#define CHAOS_STAFF_NEGATIVE_CHANCE 45
#define CHAOS_STAFF_MISC_CHANCE 30
#define CHAOS_STAFF_GIFT_CHANCE 15
#define CHAOS_STAFF_GREAT_GIFT_CHANCE 5

/obj/item/projectile/magic/chaos
	name = "chaos bolt"
	icon_state = "ice_1"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/chaos
	/// Set by random effet to be summoned in target mob's backpack, on the floor under mob, or around mob if explosion_amount is set.
	var/obj/item/item_to_summon
	/// If left at 0, item goes in backpack or floor, if set, throw that many items around the target.
	var/explosion_amount = 0
	/// Name of random effect to be applied on target mob.
	var/chaos_effect

/obj/item/projectile/magic/chaos/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!.)
		return
	if(iswallturf(target) || isobj(target))
		target.color = pick(GLOB.random_color_list)
		return

	if(target && isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			L.visible_message("<span class='warning'>[target] glows faintly, but nothing else happens.</span>")
			return
		chaos_chaos(L)

/obj/item/projectile/magic/chaos/Initialize(mapload)
	. = ..()
	icon_state = pick("bluespace", "pulse1", "magicm", "declone", "fireball", "blood_bolt", "arcane_barrage", "laser", "u_laser")


 /**
  * Picks and call a subproc to apply a random effect on mob/living/target.
  *
  * First pick a category of random effect,
  * then calls a sub-proc to pick and apply an effect in that category,
  * then summons any item_to_summon set by effects.
  * Arguments:
  * * target - mob/living that will have effect applied on them
  */
/obj/item/projectile/magic/chaos/proc/chaos_chaos(mob/living/target)
	var/category = pick(prob(CHAOS_STAFF_LETHAL_CHANCE);"lethal", prob(CHAOS_STAFF_NEGATIVE_CHANCE);"negative", prob(CHAOS_STAFF_MISC_CHANCE);"misc",\
		prob(CHAOS_STAFF_GIFT_CHANCE);"gift", prob(CHAOS_STAFF_GREAT_GIFT_CHANCE);"great gift")
	switch(category)
		if("lethal") //Target is either dead on the spot or might as well be
			apply_lethal_effect(target)
		if("negative") //Target is damaged, crippled or otherwise negatively affected. Effect can be lethal in some circumstances.
			apply_negative_effect(target)
		if("misc") //Miscellaneous effect, can be positive, negative, or just humorous
			apply_misc_effect(target)
		if("gift") //Grants a gift or positive effect to the target. Usually a gag or mildly useful item... if you weren't being killed by a wizard
			apply_gift_effect(target)
		if("great gift") //Grants a gift or positive effect to the target. Usually a weapon or useful item.
			apply_great_gift_effect(target)
	if(!item_to_summon)
		return
	if(!target.mind) //no abusing mindless mobs for free stuff
		target.visible_message("<span class='warning'>[target] glows faintly, but nothing else happens.</span>")
		return
	if(explosion_amount)
		target.visible_message("<span class='chaosneutral'>A bunch of [item_to_summon.name] scatter around [target]!</span>", \
			"<span class='chaosneutral'>A bunch of [item_to_summon.name] scatter around you!</span>")
		for(var/i in 1 to explosion_amount)
			var/obj/item/I = new item_to_summon(get_turf(target))
			throwforce = 0
			INVOKE_ASYNC(I, TYPE_PROC_REF(/atom/movable, throw_at), pick(oview(7, get_turf(src))), 10, 1)
			throwforce = initial(throwforce)
		return
	if(!ishuman(target))
		var/obj/item/I = new item_to_summon(get_turf(target))
		target.visible_message("<span class='chaosgood'>\A [I] drops next to [target]!</span>", "<span class='chaosgood'>\A [I] drops on the floor!</span>")
		return
	var/mob/living/carbon/human/H = target
	var/obj/item/I = new item_to_summon(src)
	if(H.back && isstorage(H.back))
		var/obj/item/storage/S = H.back
		S.handle_item_insertion(I, H, TRUE) //We don't check if it can be inserted because it's magic, GET IN THERE!
		H.visible_message("<span class='chaosgood'>[H]'s [S.name] glows bright!</span>", "<span class='chaosverygood'>\A [I] suddenly appears in your glowing [S.name]!</span>")
		return
	if(H.back && ismodcontrol(H.back))
		var/obj/item/mod/control/C = H.back
		if(C.bag)
			C.handle_item_insertion(I, H, TRUE)
			H.visible_message("<span class='chaosgood'>[H]'s [C] glows bright!</span>", "<span class='chaosverygood'>\A [I] suddenly appears in your glowing [C.name]!</span>")
			return
	I.forceMove(get_turf(H))
	H.visible_message("<span class='chaosgood'>\A [I] drops next to [H]!</span>", "<span class='chaosverygood'>\A [I] drops on the floor!</span>")

/**
  * Picks and apply a lethal effect on mob/living/target. Some are more instantaneous than others.
  */
/obj/item/projectile/magic/chaos/proc/apply_lethal_effect(mob/living/target)
	if(!ishuman(target))
		target.visible_message("<span class='chaosverybad'>[target] suddenly dies!</span>", "<span class='chaosverybad'>Game over!</span>")
		target.death(FALSE)
		return
	chaos_effect = pick("ded", "heart deleted", "gibbed", "cluwned", "spaced", "decapitated", "banned", \
		"exploded", "cheese morphed", "supermattered", "borged", "animal morphed", "trick revolver", "prions")
	var/mob/living/carbon/human/H = target
	switch(chaos_effect)
		if("ded")
			H.visible_message("<span class='chaosverybad'>[H] drops dead!</span>", "<span class='chaosverybad'>Game over!</span>")
			H.death()
		if("heart deleted")
			H.visible_message("<span class='chaosverybad'>[H] looks like they're about to die!</span>", "<span class='chaosverybad'>HEARTUS DELETUS!</span>")
			var/obj/item/organ/internal/heart/target_heart = H.get_int_organ(/obj/item/organ/internal/heart)
			if(target_heart)
				target_heart.remove(H)
				qdel(target_heart)
		if("gibbed")
			H.visible_message("<span class='chaosverybad'>[H] falls into gibs!</span>", "<span class='chaosverybad'>Oof!</span>")
			H.gib()
		if("cluwned")
			H.visible_message("<span class='chaosverybad'>[H] turns into a cluwne!</span>", "<span class='chaosverybad'>Oh no.</span>")
			H.makeCluwne()
		if("spaced")
			for(var/obj/item/I in H)
				H.drop_item_to_ground(I, force = TRUE)
			var/turf/T = safepick(get_area_turfs(/area/space/nearstation)) //Send in space next to the station
			if(!T) //Shouldn't happen but just in case
				T = safepick(get_area_turfs(/area/space))
			if(!T) //What do you mean there's no space? Okay well just die then
				H.visible_message("<span class='chaosverybad'>[H] drops dead!</span>", "<span class='chaosverybad'>Game over!</span>")
				H.death(FALSE)
			else
				H.visible_message("<span class='chaosverybad'>[H] disappears!</span>", "<span class='chaosverybad'>COLD! CAN'T BREATHE!</span>")
				do_teleport(H, T)
		if("decapitated")
			H.visible_message("<span class='chaosverybad'>[H]'s head goes flying!'</span>", \
				"<span class='chaosverybad'>You watch the floor fly to your face as you rapidly lose consciousness...</span>")
			var/obj/item/organ/external/affected = target.get_organ("head")
			var/atom/movable/A = affected.droplimb(1, DROPLIMB_SHARP)
			INVOKE_ASYNC(A, TYPE_PROC_REF(/atom/movable, throw_at), pick(oview(7, get_turf(src))), 10, 1)
		if("banned")
			H.visible_message("<span class='chaosverybad'>[H] gets <span class='adminhelp'>BWOINKED</span> out of existence!</span>", \
				"<span class='chaosverybad'>You get <span class='adminhelp'>BWOINKED</span> out of existence!</span>")
			playsound(H, 'sound/effects/adminhelp.ogg', 100, FALSE)
			qdel(H)
		if("exploded")
			H.visible_message("<span class='chaosverybad'>[H] explodes!</span>", "<span class='chaosverybad'>Boom!</span>")
			explosion(get_turf(H), 1, 1, 1, cause = "staff of chaos lethal explosion effect, fired by [key_name(firer)]")
		if("cheese morphed")
			H.visible_message("<span class='chaosverybad'>[H] transforms into cheese!</span>", "<span class='chaosverybad'>You've been transformed into cheese!</span>")
			new /obj/item/food/sliced/cheesewedge(get_turf(H))
			qdel(H)
		if("supermattered")
			var/obj/machinery/atmospherics/supermatter_crystal/supercrystal = GLOB.main_supermatter_engine
			if(!supercrystal)
				H.visible_message("<span class='chaosverybad'>[H] drops dead!</span>", "<span class='chaosverybad'>Game over!</span>")
				H.death()
			else
				H.visible_message("<span class='chaosverybad'>[H] disappears!</span>", "<span class='chaosverybad'>All you see is yellow before you fall to dust...</span>")
				do_teleport(H, supercrystal, 1)
				H.throw_at(supercrystal, 10, 2)
				if(H && H.stat == CONSCIOUS)
					to_chat(H, "<span class='chaosverybad'>... not? You're alive? Huh. Neat.</span>")
		if("borged")
			H.visible_message("<span class='chaosverybad'>[H] turns into a cyborg!</span>", "<span class='chaosverybad'>Beep boop!</span>")
			wabbajack(H, force_borg = TRUE)
		if("animal morphed")
			H.visible_message("<span class='chaosverybad'>[H] turns into an animal!</span>", "<span class='chaosverybad'>Welcome to the jungle!</span>")
			wabbajack(H, force_animal = TRUE)
		if("trick revolver")
			item_to_summon = /obj/item/gun/projectile/revolver/fake
		if("prions")
			H.visible_message("<span class='chaosverybad'>[H] laughs uncontrollably!</span>", "<span class='chaosverybad'>You feel like you're going to die of laughter!</span>")
			H.reagents.add_reagent("prions", 5)

/**
  * Picks and apply a negative effect on mob/living/target. Usually causes damage and/or incapacitating effect.
  */
/obj/item/projectile/magic/chaos/proc/apply_negative_effect(mob/living/target)
	if(!ishuman(target))
		if(prob(50))
			target.apply_damage(CHAOS_STAFF_DAMAGE, BRUTE)
			target.visible_message("<span class='chaosbad'>[target] gets slashed by [src]!</span>", "<span class='chaosbad'>You get slashed by [src]!</span>")
		else
			target.apply_damage(CHAOS_STAFF_DAMAGE, BURN)
			target.visible_message("<span class='chaosbad'>[target] gets burned by [src]!</span>", "<span class='chaosbad'>You get burned by [src]!</span>")
		return
	chaos_effect = pick("fireballed", "ice spiked", "rathend", "stabbed", "slashed", "burned", "poisoned", \
		"plasma", "teleport", "teleport roulette", "electrocuted")
	var/mob/living/carbon/human/H = target
	switch(chaos_effect)
		if("fireballed")
			H.visible_message("<span class='chaosbad'>[H] is hit by a fireball! </span>", "<span class='chaosverybad'>You get hit by a fireball!</span>")
			H.apply_damage(CHAOS_STAFF_DAMAGE / 3, BRUTE)
			explosion(get_turf(H), -1, 0, 2, 3, flame_range = 2, cause = "staff of chaos fireball effect, fired by [key_name(firer)]")
		if("ice spiked")
			H.visible_message("<span class='chaosbad'>[H]'s chest get pierced by an ice spike!</span>", "<span class='chaosverybad'>An ice spike pierces your chest!</span>")
			H.apply_damage(CHAOS_STAFF_DAMAGE, BRUTE, "chest")
			H.bodytemperature = 250
		if("rathend")
			var/obj/item/organ/internal/appendix/A = H.get_int_organ(/obj/item/organ/internal/appendix)
			if(!A)
				H.apply_damage(CHAOS_STAFF_DAMAGE / 3, BRUTE, "chest")
				new/obj/effect/decal/cleanable/blood/gibs(get_turf(H))
				to_chat(H, "<span class='chaosbad'>Blood flows out of your body!</span>")
				H.KnockDown(6 SECONDS)
				return
			A.remove(H)
			A.forceMove(get_turf(H))
			A.throw_at(get_edge_target_turf(H, pick(GLOB.alldirs)), rand(1, 10), 5)
			H.visible_message("<span class='chaosbad'>[H]'s [A.name] flies out of their body in a magical explosion!</span>",\
							"<span class='chaosbad'>Your [A.name] flies out of your body in a magical explosion!</span>")
			H.KnockDown(4 SECONDS)
		if("stabbed")
			H.visible_message("<span class='chaosbad'>[H] gets stabbed by a magical knife!</span>", "<span class='chaosbad'>You get stabbed by a magical knife!</span>")
			H.apply_damage(CHAOS_STAFF_DAMAGE, BRUTE, "chest")
		if("slashed")
			H.visible_message("<span class='chaosbad'>[H] gets slashed by a magical knife!</span>", "<span class='chaosbad'>You get slashed by a magical knife!</span>")
			H.apply_damage(CHAOS_STAFF_DAMAGE, BRUTE, pick("l_arm", "r_arm"))
		if("burned")
			H.visible_message("<span class='chaosbad'>[H] gets set on fire!</span>", "<span class='chaosverybad'>You're on fire! Literally!</span>")
			H.apply_damage(CHAOS_STAFF_DAMAGE / 2, BURN)
			H.adjust_fire_stacks(14)
			H.IgniteMob()
			H.emote("scream")
		if("poisoned")
			H.visible_message("<span class='chaosbad'>[H] looks ill!</span>", "<span class='chaosbad'>You feel sick...</span>")
			var/random_reagent = pick("carpotoxin", "cyanide", "amanitin", "sarin", "venom")
			H.reagents.add_reagent(random_reagent, CHAOS_STAFF_DAMAGE / 3)
		if("plasma")
			H.visible_message("<span class='chaosbad'>A cloud of plasma surrounds [H]!</span>", "<span class='chaosbad'>You're covered in plasma gas!</span>")
			H.atmos_spawn_air(LINDA_SPAWN_TOXINS | LINDA_SPAWN_20C, 200)
		if("teleport")
			var/turf/T
			T = find_safe_turf() //Get a safe station turf
			if(T)
				H.visible_message("<span class='chaosverybad'>[H] disappears!</span>", "<span class='chaosverybad'>You've been teleported!</span>")
				do_teleport(H, T)
		if("teleport roulette")
			H.apply_status_effect(STATUS_EFFECT_TELEPORT_ROULETTE)
			var/turf/T
			T = find_safe_turf() //Get a safe station turf
			if(T)
				H.visible_message("<span class='chaosverybad'>[H] disappears!</span>", "<span class='chaosverybad'>You feel sick as you're teleported around the station!</span>")
				do_teleport(H, T)
		if("electrocuted")
			H.visible_message("<span class='chaosbad'>[H] gets electrocuted!</span>", "<span class='chaosbad'>You get electrocuted!</span>")
			H.electrocute_act(CHAOS_STAFF_DAMAGE, src)

/datum/status_effect/teleport_roulette
	id = "teleport_roulette"
	duration = 16 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 2 SECONDS
	alert_type = null

/datum/status_effect/teleport_roulette/tick()
	var/turf/T
	T = find_safe_turf() //Get a safe station turf
	if(T && prob(80))
		do_teleport(owner, T)

/**
  * Picks and apply a random miscellaneous effect on mob/living/target. Can be negative or mildly positive.
  */
/obj/item/projectile/magic/chaos/proc/apply_misc_effect(mob/living/target)
	if(!ishuman(target))
		chaos_effect = pick("recolor", "bark", "confetti", "smoke", "wand of nothing", "bike horn")
	else
		chaos_effect = pick("bark", "smoke", "spin", "flip", "confetti", "slip", "wand of nothing", \
			"help maint", "fake callout", "bike horn", "tarot card")
	switch(chaos_effect)
		if("recolor") //non-humans only because recoloring humans is kinda meh
			target.color = pick(GLOB.random_color_list)
		if("bark")
			target.visible_message("<span class='chaosneutral'>[target] barks!</span>", "<span class='chaosneutral'>Bark!</span>")
			playsound(target, 'sound/creatures/dog_bark1.ogg', 100, FALSE)
		if("smoke")
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(4, FALSE, target)
			INVOKE_ASYNC(smoke, TYPE_PROC_REF(/datum/effect_system, start))
		if("spin")
			target.emote("spin")
		if("flip")
			target.emote("flip")
		if("confetti")
			confettisize(get_turf(target), 20, 4)
		if("slip")
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				H.slip("your own foot", 6 SECONDS, 0, 0, 1, "trip")
		if("wand of nothing")
			item_to_summon = /obj/item/gun/magic/wand
			explosion_amount = rand(2, 5)
		if("help maint")
			target.say(";HELP MAINT")
			target.Silence(10 SECONDS)
		if("fake callout")
			var/message = ";WIZ "
			message += pick("SCIENCE", "MED", "BRIG", "BRIDGE", "ARRIVALS", "ARRIVALS MAINT", "CHAPEL", "SCIENCE MAINT", "CARGO", "MINING MAINT", "TURBINE", "ENGI", "ATMOS")
			target.say(message)
			target.Silence(10 SECONDS)
		if("bike horn")
			item_to_summon = /obj/item/bikehorn
			explosion_amount = rand(2, 3)
		if("tarot card")
			if(ishuman(target) && target.mind)
				var/mob/living/carbon/human/H = target
				var/obj/item/magic_tarot_card/spawned_card = new /obj/item/magic_tarot_card(H)
				H.visible_message("<span class='chaosneutral'>[H] is forced to use [spawned_card]!</span>", "<span class='chaosneutral'>[spawned_card] appears in front of you and glows bright!</span>")
				spawned_card.pre_activate(H)
			else
				target.visible_message("<span class='warning'>[target] glows faintly, but nothing else happens.</span>")
/**
  * Picks a random gift to be given to mob/living/target. Should be mildly useful and/or funny.
  */
/obj/item/projectile/magic/chaos/proc/apply_gift_effect(mob/living/target)
	chaos_effect = pick("toy sword", "toy revolver", "cheese", "food", "medkit", "tarot pack", \
		"insulated gloves", "wand of doors", "golden bike horn", "ban hammer", "banana")
	switch(chaos_effect)
		if("toy sword")
			item_to_summon = /obj/item/toy/sword/chaosprank
		if("toy revolver")
			item_to_summon = /obj/item/gun/projectile/revolver/capgun/chaosprank
		if("cheese")
			item_to_summon = /obj/item/food/sliced/cheesewedge
			explosion_amount = rand(5, 10)
		if("food")
			target.visible_message("<span class='chaosneutral'>Food scatters around [target]!</span>", "<span class='chaosneutral'>A bunch of food scatters around you!</span>")
			var/limit = rand(5, 10)
			for(var/i in 1 to limit)
				var/type = pick(typesof(/obj/item/food))
				var/obj/item/I = new type(get_turf(target))
				INVOKE_ASYNC(I, TYPE_PROC_REF(/atom/movable, throw_at), pick(oview(7, get_turf(src))), 10, 1)

		if("medkit")
			item_to_summon = pick(/obj/item/storage/firstaid/brute, /obj/item/storage/firstaid/fire, /obj/item/storage/firstaid/adv)
		if("tarot pack")
			item_to_summon = pick(/obj/item/tarot_card_pack, /obj/item/tarot_card_pack/jumbo, /obj/item/tarot_card_pack/mega)
		if("insulated gloves")
			item_to_summon = /obj/item/clothing/gloves/color/yellow
			explosion_amount = rand(2, 5)
		if("wand of doors")
			item_to_summon = /obj/item/gun/magic/wand/door
		if("golden bike horn")
			item_to_summon = /obj/item/bikehorn/golden
			explosion_amount = rand(2, 3)
		if("ban hammer")
			item_to_summon = /obj/item/banhammer
			explosion_amount = rand(2, 5)
		if("banana")
			item_to_summon = /obj/item/food/grown/banana

/**
  * Picks a random gift to be given to mob/living/target. Should be valuable and/or threatening to the wizard.
  */
/obj/item/projectile/magic/chaos/proc/apply_great_gift_effect(mob/living/target)
	chaos_effect = pick("esword", "emag", "chaos wand", "revolver", "aeg", "tarot deck", \
		"bluespace banana", "banana grenade", "disco ball", "syndicate minibomb", "crystal ball")
	switch(chaos_effect)
		if("esword")
			item_to_summon = /obj/item/melee/energy/sword/saber/blue
		if("emag")
			item_to_summon = /obj/item/card/emag
		if("chaos wand")
			item_to_summon = /obj/item/gun/magic/wand/chaos
		if("revolver")
			item_to_summon = /obj/item/gun/projectile/revolver
		if("aeg")
			item_to_summon = /obj/item/gun/energy/gun/nuclear
		if("tarot deck")
			item_to_summon = /obj/item/tarot_generator
		if("bluespace banana")
			item_to_summon = /obj/item/food/grown/banana/bluespace
		if("banana grenade")
			item_to_summon = /obj/item/grenade/clown_grenade
		if("disco ball")
			new /obj/machinery/disco/chaos_staff(get_turf(target))
			target.visible_message("<span class='chaosverygood'>DANCE TILL YOU'RE DEAD!</span>")
		if("syndicate minibomb")
			item_to_summon = /obj/item/grenade/syndieminibomb
		if("crystal ball")
			item_to_summon = /obj/item/scrying

#undef CHAOS_STAFF_DAMAGE
#undef CHAOS_STAFF_LETHAL_CHANCE
#undef CHAOS_STAFF_NEGATIVE_CHANCE
#undef CHAOS_STAFF_MISC_CHANCE
#undef CHAOS_STAFF_GIFT_CHANCE
#undef CHAOS_STAFF_GREAT_GIFT_CHANCE
