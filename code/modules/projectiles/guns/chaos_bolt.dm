/obj/item/projectile/magic/chaos
	name = "chaos bolt"
	icon_state = "ice_1"
	var/obj/item/item_to_summon
	var/explosion_amount = 0 //If left at 0, item goes in backpack or floor, if set, throw that many items around the target
	var/chaos_effect

/obj/item/projectile/magic/chaos/on_hit(atom/target, blocked = 0)
	. = ..()

	if(target && isliving(target))
		chaos_chaos(target)

/obj/item/projectile/magic/chaos/proc/chaos_chaos(mob/living/target, blocked = 0)
	var/category = pick(prob(80);"lethal", prob(5);"negative", prob(5);"misc", prob(5);"gift", prob(5);"great gift")
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
	if(item_to_summon) //TODO check if mob's alive, no effect on dead mobs
		//if(!target.mind) //no abusing mindless mobs for free stuff
		//	target.visible_message("<span class='warning'>[target] glows faintly, but nothing else happens.</span>")
		//	return
		if(explosion_amount)
			target.visible_message("<span class='chaosneutral'>A bunch of [item_to_summon.name] scatter around [target]!</span>", "<span class='chaosneutral'>A bunch of [item_to_summon.name] scatter around you!</span>")
			for(var/i in 1 to explosion_amount)
				var/obj/item/I = new item_to_summon(get_turf(target))
				throwforce = 0
				INVOKE_ASYNC(I, TYPE_PROC_REF(/atom/movable, throw_at), pick(oview(7, get_turf(src))), 10, 1)
				throwforce = initial(throwforce)
		else
			if(!ishuman(target))
				var/obj/item/I = new item_to_summon(get_turf(target))
				target.visible_message("<span class='chaosgood'>\A [I] drops next to [target]!</span>", "<span class='chaosgood'>\A [I] drops on the floor!</span>")
				return
			var/mob/living/carbon/human/H = target
			var/obj/item/I = new item_to_summon(src)
			if(H.back && isstorage(H.back))
				var/obj/item/storage/S = H.back
				S.handle_item_insertion(I, TRUE) //We don't check if it can be inserted because it's magic, GET IN THERE!
				H.visible_message("<span class='chaosgood'>[H]'s [S.name] glows bright!</span>", "<span class='chaosverygood'>\A [I] suddenly appears in your glowing [S.name]!</span>")
				return
			if(H.back && ismodcontrol(H.back))
				var/obj/item/mod/control/C = H.back
				if(C.bag)
					C.handle_item_insertion(I, TRUE)
					H.visible_message("<span class='chaosgood'>[H]'s [C] glows bright!</span>", "<span class='chaosverygood'>\A [I] suddenly appears in your glowing [C.name]!</span>")
					return
			I.forceMove(get_turf(H))
			H.visible_message("<span class='chaosgood'>\A [I] drops next to [H]!</span>", "<span class='chaosverygood'>\A [I] drops on the floor!</span>")

/obj/item/projectile/magic/chaos/proc/apply_lethal_effect(mob/living/target)
	if(!ishuman(target))
		target.death(FALSE)
		target.visible_message("<span class='chaosverybad'>[target] suddenly dies!</span>", "<span class='chaosverybad'>Game over!</span>")
		return
	chaos_effect = pick("ded", "heart deleted", "gibbed", "cluwned", "spaced", "decapitated", "banned", \
		"exploded", "cheese morphed", "supermattered", "borged", "animal morphed", "trick revolver")
	chaos_effect = pick("banned", "supermattered", "spaced", "borged", "animal morphed")
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
				H.unEquip(I, TRUE)
			var/turf/T = safepick(get_area_turfs(/area/space/nearstation))
			if(!T) //Shouldn't happen but just in case
				T = safepick(get_area_turfs(/area/space))
			if(!T) //What do you mean there's no space? Okay well just die then
				H.visible_message("<span class='chaosverybad'>[H] drops dead!</span>", "<span class='chaosverybad'>Game over!</span>")
				H.death(FALSE)
			else
				H.visible_message("<span class='chaosverybad'>[H] disappears!</span>", "<span class='chaosverybad'>COLD! CAN'T BREATH!</span>")
				do_teleport(H, T)
		if("decapitated")
			H.visible_message("<span class='chaosverybad'>[H]'s head goes flying!'</span>", "<span class='chaosverybad'>You watch the floor fly to your face as you rapidly lose consciousness...</span>")
			var/obj/item/organ/external/affected = target.get_organ("head")
			var/atom/movable/A = affected.droplimb(1, DROPLIMB_SHARP)
			INVOKE_ASYNC(A, TYPE_PROC_REF(/atom/movable, throw_at), pick(oview(7, get_turf(src))), 10, 1)
		if("banned")
			H.visible_message("<span class='chaosverybad'>[H] gets <span class='adminhelp'>BWOINKED</span> out of existence!</span>", "<span class='chaosverybad'>You get <span class='adminhelp'>BWOINKED</span> out of existence!</span>")
			playsound(H, 'sound/effects/adminhelp.ogg', 100, FALSE)
			qdel(H)
		if("exploded")
			H.visible_message("<span class='chaosverybad'>[H] explodes!</span>", "<span class='chaosverybad'>Boom!</span>")
			explosion(get_turf(H), 1, 1, 1, cause = "staff of chaos random effect")
		if("cheese morphed")
			H.visible_message("<span class='chaosverybad'>[H] transforms into cheese!</span>", "<span class='chaosverybad'>You've been transformed into cheese!</span>")
			new /obj/item/reagent_containers/food/snacks/cheesewedge(get_turf(H))
			qdel(H)
		if("supermattered")
			var/obj/machinery/atmospherics/supermatter_crystal/supercrystal = locate(/obj/machinery/atmospherics/supermatter_crystal)
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

/obj/item/projectile/magic/chaos/proc/apply_negative_effect(mob/living/target)
	if(!iscarbon(target))
		//damage target
		return
	chaos_effect = pick("fireballed", "ice spiked", "rathend", "stabbed", "slashed", "burned", "poisoned", \
		"plasma fire", "clowned", "mimed", "teleport", "teleport roulette", "scatter inventory", \
		"electrocuted", "firecrackerd", "beartrapped")
	switch(chaos_effect)
		if("fireballed")
			return
		if("ice spiked")
			return
		if("rathend")
			return
		if("stabbed")
			return
		if("slashed")
			return
		if("burned")
			return
		if("poisoned")
			return
		if("plasma fire")
			return
		if("clowned")
			return
		if("mimed")
			return
		if("teleport")
			return
		if("teleport roulette")
			return
		if("scatter inventory")
			return
		if("electrocuted")
			return
		if("firecrackerd")
			return
		if("beartrapped")
			return

/obj/item/projectile/magic/chaos/proc/apply_misc_effect(mob/living/target)
	if(!iscarbon(target))
		//random effect like fireworks/confetti/etc
		return
	chaos_effect = pick("bark", "fireworks", "smoke", "blink", "blink spam", "spin", "flip", "confetti", "slip", \
		"wand of nothing", "help maint", "fake callout", "switcharoo", "spacetime distortion", "bike horn", "wizard robes")
	switch(chaos_effect)
		if("bark")
			return
		if("fireworks")
			return
		if("smoke")
			return
		if("blink")
			return
		if("blink spam")
			return
		if("spin")
			return
		if("flip")
			return
		if("confetti")
			return
		if("slip")
			return
		if("wand of nothing")
			item_to_summon = /obj/item/gun/magic/wand
			explosion_amount = rand(2, 5)
		if("help maint")
			return
		if("fake callout")
			return
		if("switcharoo")
			return
		if("spacetime distortion")
			return
		if("bike horn")
			item_to_summon = /obj/item/bikehorn
			explosion_amount = rand(2, 3)
		if("wizard robes")
			return

/obj/item/projectile/magic/chaos/proc/apply_gift_effect(mob/living/target)
	if(!iscarbon(target))
		//slightly heal target
		return
	chaos_effect = pick("toy sword", "toy revolver", /*"dosh",*/ "cheese", "food", "medkit", "heal", \
		"dwarf", "insulated gloves", "wand of doors", "golden bike horn", "ban hammer", "banana")
	switch(chaos_effect)
		if("toy sword")
			item_to_summon = /obj/item/toy/sword/chaosprank
		if("toy revolver")
			item_to_summon = /obj/item/gun/projectile/revolver/capgun/chaosprank
		//if("dosh") //ISSUE : the cash stacks together instead of splitting sometimes, add effect where target throws overtime?
		//	item_to_summon = /obj/item/stack/spacecash/c20
	//		explosion_amount = rand(10, 20)
		if("cheese")
			item_to_summon = /obj/item/reagent_containers/food/snacks/cheesewedge
			explosion_amount = rand(5, 10)
		if("food")
			target.visible_message("<span class='chaosneutral'>Food scatter around [target]!</span>", "<span class='chaosneutral'>A bunch of food scatter around you!</span>")
			var/limit = rand(5, 10)
			for(var/i in 1 to limit)
				var/type = pick(typesof(/obj/item/reagent_containers/food/snacks))
				var/obj/item/I = new type(get_turf(target))
				INVOKE_ASYNC(I, TYPE_PROC_REF(/atom/movable, throw_at), pick(oview(7, get_turf(src))), 10, 1)

		if("medkit")
			item_to_summon = pick(/obj/item/storage/firstaid/brute, /obj/item/storage/firstaid/fire, /obj/item/storage/firstaid/adv)
		if("heal")
			return
		if("dwarf")
			return
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
			item_to_summon = /obj/item/reagent_containers/food/snacks/grown/banana

/obj/item/projectile/magic/chaos/proc/apply_great_gift_effect(mob/living/target)
	if(!iscarbon(target))
		//aheal target
		return
	chaos_effect = pick("esword", "emag", "chaos wand", "revolver", "aeg", "aheal", "meth mix", \
		"bluespace banana", "banana grenade", "hulk", "jump", "disco ball", "syndicate minibomb", "crystal ball")
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
		if("aheal")
			return
		if("meth mix")
			return
		if("bluespace banana")
			item_to_summon = /obj/item/reagent_containers/food/snacks/grown/banana/bluespace
		if("banana grenade")
			item_to_summon = /obj/item/grenade/clown_grenade
		if("hulk")
			return
		if("jump")
			return
		if("disco ball")
			if(prob(20)) //TODO : code plasmafire
				new /obj/machinery/disco/chaos_staff/plasmafire(get_turf(target))
			else
				new /obj/machinery/disco/chaos_staff(get_turf(target))
			target.visible_message("<span class='chaosverygood'>DANCE TILL YOU'RE DEAD!</span>")
		if("syndicate minibomb")
			item_to_summon = /obj/item/grenade/syndieminibomb
		if("crystal ball")
			item_to_summon = /obj/item/scrying
