/obj/item/projectile/magic/chaos
	name = "chaos bolt"
	icon_state = "ice_1"
	var/obj/item/item_to_summon
	var/explosion_amount = 0
	var/chaos_effect

/obj/item/projectile/magic/chaos/on_hit(atom/target, blocked = 0)
	. = ..()
	if(target && isliving(target))
		var/mob/living/L = target
		var/category = pick(prob(5);"lethal", prob(45);"damaging", prob(30);"misc", prob(15);"gift", prob(5);"great gift")
		switch(category)
			if("lethal") //Target is either dead on the spot or might as well be
				apply_lethal_effect(L)
			if("damaging") //Target is damaged or crippled. Effect can be lethal in some circumstances.
				apply_damaging_effect(L)
			if("misc") //Miscellaneous effect, can be positive, negative, or just humorous
				apply_misc_effect(L)
			if("gift") //Grants a gift or positive effect to the target. Usually a gag or mildly useful item... if you weren't being killed by a wizard
				apply_gift_effect(L)
			if("great gift") //Grants a gift or positive effect to the target. Usually a weapon or useful item.
				apply_great_gift_effect(L)
		target.visible_message("[target] is hit by [chaos_effect]") //DEBUG, REMOVE
		if(item_to_summon) //TODO check if mob's alive, no effect on dead mobs
			if(!L.mind) //no abusing mindless mobs for free stuff
				L.visible_message("<span class='notice'>[target] glows brightly, but nothing else happens.</span>")
				return
			if(explosion_amount)
				//spawn and throw a bunch of the items around the target
				return
			else
				//put item in backpack even if it doesnt fit, it's magic
				return

/obj/item/projectile/magic/chaos/proc/apply_lethal_effect(mob/living/target)
	if(!iscarbon(target))
		target.death(FALSE)
		return
	chaos_effect = pick("ded", "heart deleted", "gibbed", "cluwned", "spaced", "decapitated", "banned", \
		"exploded", "cheese morphed", "time erased", "supermattered", "borged", "animal morphed")
	switch(chaos_effect)
		if("ded")
			return
		if("heart deleted")
			return
		if("gibbed")
			return
		if("cluwned")
			return
		if("spaced")
			return
		if("decapitated")
			return
		if("banned")
			return
		if("exploded")
			return
		if("cheese morphed")
			return
		if("time erased")
			return
		if("supermattered")
			return
		if("borged")
			return
		if("animal morphed")
			return

/obj/item/projectile/magic/chaos/proc/apply_damaging_effect(mob/living/target)
	if(!iscarbon(target))
		//damage target
		return
	chaos_effect = pick("fireballed", "ice spiked", "rathend", "stabbed", "slashed", "burned", "poisoned", \
		"plasma fire", "clowned", "mimed", "teleport", "scatter inventory", "forced to dance")
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
		if("forced to dance")
			return

/obj/item/projectile/magic/chaos/proc/apply_misc_effect(mob/living/target)
	if(!iscarbon(target))
		//random effect like fireworks/confetti/etc
		return
	chaos_effect = pick("bark", "meow", "fireworks", "smoke", "blink", "spin", "flip", "confetti", "slip", \
		"wand of nothing", "help maint", "fake callout", "switcharoo", "spacetime distortion", "bike horn", "slippables", "wizard robes")
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
		if("slippables")
			item_to_summon = pick(/obj/item/grown/bananapeel, /obj/item/grown/bananapeel/clownfish, /obj/item/grown/bananapeel/bluespace, /obj/item/grown/bananapeel/mimanapeel)
			explosion_amount = rand(10, 20)
		if("wizard robes")
			return

/obj/item/projectile/magic/chaos/proc/apply_gift_effect(mob/living/target)
	if(!iscarbon(target))
		//slightly heal target
		return
	chaos_effect = pick("toy sword", "toy revolver", "dosh", "cheese", "banana bread", "medkit", "heal", \
		"dwarf", "insulated gloves", "wand of doors", "golden bike horn", "ban hammer", "banana")
	target.visible_message("<span class='notice'>[target] hits by [chaos_effect]</span>")

	switch(chaos_effect)
		if("toy sword")
			item_to_summon = /obj/item/toy/sword
		if("toy revolver")
			item_to_summon = /obj/item/gun/projectile/revolver/capgun
		if("dosh")
			item_to_summon = /obj/item/stack/spacecash/c50
			explosion_amount = rand(5, 10)
		if("cheese")
			item_to_summon = /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
			explosion_amount = rand(5, 10)
		if("banana bread")
			item_to_summon = /obj/item/reagent_containers/food/snacks/sliceable/bananabread
			explosion_amount = rand(5, 10)
		if("medkit")
			item_to_summon = /obj/item/storage/firstaid/doctor
		if("heal")
			return
		if("dwarf")
			return
		if("insulated gloves")
			item_to_summon = pick(/obj/item/clothing/gloves/color/yellow, /obj/item/clothing/gloves/color/fyellow)
		if("wand of doors")
			item_to_summon = /obj/item/gun/magic/wand/door
		if("golden bike horn")
			item_to_summon = /obj/item/bikehorn/golden
		if("ban hammer")
			item_to_summon = /obj/item/banhammer
		if("banana")
			item_to_summon = /obj/item/reagent_containers/food/snacks/grown/banana

/obj/item/projectile/magic/chaos/proc/apply_great_gift_effect(mob/living/target)
	if(!iscarbon(target))
		//aheal target
		return
	chaos_effect = pick("esword", "emag", "chaos wand", "revolver", "aeg", "aheal", "meth mix", \
		"bluespace banana", "banana grenade", "hulk", "jump", "disco ball", "syndicate minibomb", "crystal ball")
	target.visible_message("<span class='notice'>[target] hits by [chaos_effect]</span>")
	switch(chaos_effect)
		if("esword")
			item_to_summon = /obj/item/melee/energy/sword/saber/blue
		if("emag")
			item_to_summon = /obj/item/card/emag
		if("chaos wand")
			return // TODO : Add chaos wand
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
			return
		if("syndicate minibomb")
			item_to_summon = /obj/item/grenade/syndieminibomb
		if("crystal ball")
			item_to_summon = /obj/item/scrying
