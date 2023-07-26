/obj/item/storage/pill_bottle/dice
	name = "bag of dice"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	can_hold = list(/obj/item/dice)
	allow_wrap = FALSE

/obj/item/storage/pill_bottle/dice/populate_contents()
	var/special_die = pick("1","2","fudge","00","100")
	if(special_die == "1")
		new /obj/item/dice/d1(src)
	if(special_die == "2")
		new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d6(src)
	if(special_die == "fudge")
		new /obj/item/dice/fudge(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	if(special_die == "00")
		new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
	if(special_die == "100")
		new /obj/item/dice/d100(src)

/obj/item/storage/pill_bottle/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is gambling with death! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/obj/item/dice //depreciated d6, use /obj/item/dice/d6 if you actually want a d6
	name = "die"
	desc = "A die with six sides. Basic and serviceable."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = WEIGHT_CLASS_TINY

	var/sides = 6
	var/result = null
	var/list/special_faces = list() //entries should match up to sides var if used

	var/rigged = DICE_NOT_RIGGED
	var/rigged_value

/obj/item/dice/Initialize(mapload)
	. = ..()
	if(!result)
		result = roll(sides)
	update_icon()

/obj/item/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is gambling with death! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/obj/item/dice/d1
	name = "d1"
	desc = "A die with one side. Deterministic!"
	icon_state = "d1"
	sides = 1

/obj/item/dice/d2
	name = "d2"
	desc = "A die with two sides. Coins are undignified!"
	icon_state = "d2"
	sides = 2

/obj/item/dice/d4
	name = "d4"
	desc = "A die with four sides. The nerd's caltrop."
	icon_state = "d4"
	sides = 4

/obj/item/dice/d4/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 1, 4) //1d4 damage

/obj/item/dice/d6
	name = "d6"

/obj/item/dice/fudge
	name = "fudge die"
	desc = "A die with six sides but only three results. Is this a plus or a minus? Your mind is drawing a blank..."
	sides = 3 //shhh
	icon_state = "fudge"
	special_faces = list("minus","blank","plus")

/obj/item/dice/d8
	name = "d8"
	desc = "A die with eight sides. It feels... lucky."
	icon_state = "d8"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "A die with ten sides. Useful for percentages."
	icon_state = "d10"
	sides = 10

/obj/item/dice/d00
	name = "d00"
	desc = "A die with ten sides. Works better for d100 rolls than a golf ball."
	icon_state = "d00"
	sides = 10

/obj/item/dice/d12
	name = "d12"
	desc = "A die with twelve sides. There's an air of neglect about it."
	icon_state = "d12"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."
	icon_state = "d20"
	sides = 20

// Die of Fate
/obj/item/dice/d20/fate
	name = "\improper Die of Fate"
	desc = "A die with twenty sides. You can feel unearthly energies radiating from it. Using this might be VERY risky."
	icon_state = "d20"
	var/reusable = TRUE
	var/used = FALSE

/obj/item/dice/d20/fate/stealth
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."

/obj/item/dice/d20/fate/one_use
	reusable = FALSE

/obj/item/dice/d20/fate/one_use/stealth
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."

/obj/item/dice/d20/fate/cursed
	name = "cursed Die of Fate"
	desc = "A die with twenty sides. You feel that rolling this is a REALLY bad idea."
	color = "#00BB00"

	rigged = DICE_TOTALLY_RIGGED
	rigged_value = 1

/obj/item/dice/d20/fate/diceroll(mob/user)
	. = ..()
	if(!used)
		if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
			to_chat(user, "<span class='warning'>You feel the magic of the dice is restricted to ordinary humans!</span>")
			return

		if(!reusable)
			used = TRUE

		var/turf/T = get_turf(src)
		T.visible_message("<span class='userdanger'>[src] flares briefly.</span>")

		addtimer(CALLBACK(src, PROC_REF(effect), user, .), 1 SECONDS)

/obj/item/dice/d20/fate/equipped(mob/user, slot)
	if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
		to_chat(user, "<span class='warning'>You feel the magic of the dice is restricted to ordinary humans! You should leave it alone.</span>")
		user.unEquip(src)

/obj/item/dice/d20/fate/proc/create_smoke(amount)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(amount, FALSE, drop_location())
	smoke.start()

/obj/item/dice/d20/fate/proc/effect(mob/living/carbon/human/user, roll)
	var/turf/T = get_turf(src)
	switch(roll)
		if(1)
			//Dust
			T.visible_message("<span class='userdanger'>[user] turns to dust!</span>")
			user.dust()
		if(2)
			//Death
			T.visible_message("<span class='userdanger'>[user] suddenly dies!</span>")
			user.death()
		if(3)
			//Swarm of creatures
			T.visible_message("<span class='userdanger'>A swarm of creatures surround [user]!</span>")
			for(var/direction in GLOB.alldirs)
				new /mob/living/simple_animal/hostile/netherworld(get_step(get_turf(user), direction))
		if(4)
			//Destroy Equipment
			T.visible_message("<span class='userdanger'>Everything [user] is holding and wearing disappears!</span>")
			for(var/obj/item/I in user)
				if(istype(I, /obj/item/implant))
					continue
				qdel(I)
		if(5)
			//Monkeying
			T.visible_message("<span class='userdanger'>[user] transforms into a monkey!</span>")
			user.monkeyize()
		if(6)
			//Cut speed
			T.visible_message("<span class='userdanger'>[user] starts moving slower!</span>")
			var/datum/species/S = user.dna.species
			S.speed_mod += 1
		if(7)
			//Throw
			T.visible_message("<span class='userdanger'>Unseen forces throw [user]!</span>")
			user.Stun(12 SECONDS)
			user.adjustBruteLoss(50)
			var/throw_dir = GLOB.cardinal
			var/atom/throw_target = get_edge_target_turf(user, throw_dir)
			user.throw_at(throw_target, 200, 4)
		if(8)
			//Fueltank Explosion
			T.visible_message("<span class='userdanger'>An explosion bursts into existence around [user]!</span>")
			explosion(get_turf(user), -1, 0, 2, flame_range = 2)
		if(9)
			//Cold
			var/datum/disease/D = new /datum/disease/cold()
			T.visible_message("<span class='userdanger'>[user] looks a little under the weather!</span>")
			user.ForceContractDisease(D)
		if(10)
			//Nothing
			T.visible_message("<span class='userdanger'>Nothing seems to happen.</span>")
		if(11)
			//Cookie
			T.visible_message("<span class='userdanger'>A cookie appears out of thin air!</span>")
			var/obj/item/reagent_containers/food/snacks/cookie/C = new(drop_location())
			create_smoke(2)
			C.name = "Cookie of Fate"
		if(12)
			//Healing
			T.visible_message("<span class='userdanger'>[user] looks very healthy!</span>")
			user.revive()
		if(13)
			//Mad Dosh
			T.visible_message("<span class='userdanger'>Mad dosh shoots out of [src]!</span>")
			var/turf/Start = get_turf(src)
			for(var/direction in GLOB.alldirs)
				var/turf/dirturf = get_step(Start, direction)
				if(prob(50))
					new /obj/item/stack/spacecash/c1000(dirturf)
				else
					var/obj/item/storage/bag/money/M = new(dirturf)
					for(var/i in 1 to rand(5, 50))
						new /obj/item/coin/gold(M)
		if(14)
			//Tator Item
			var/list/traitor_items = list(/obj/item/chameleon,
				/obj/item/chameleon_counterfeiter,
				/obj/item/clothing/shoes/chameleon/noslip,
				/obj/item/pinpointer/advpinpointer,
				/obj/item/storage/box/syndie_kit/bonerepair,
				/obj/item/storage/backpack/duffel/syndie/med/surgery,
				/obj/item/storage/toolbox/syndicate,
				/obj/item/storage/backpack/clown/syndie,
				/obj/item/storage/backpack/satchel_flat,
				/obj/item/storage/box/syndie_kit/camera_bug,
				/obj/item/storage/belt/military/traitor,
				/obj/item/clothing/glasses/chameleon/thermal,
				/obj/item/borg/upgrade/modkit/indoors,
				/obj/item/storage/box/syndie_kit/chameleon,
				/obj/item/storage/box/syndie_kit/hardsuit,
				/obj/item/implanter/storage,
				/obj/item/toy/syndicateballoon)
			var/selected_item = pick(traitor_items)
			T.visible_message("<span class='userdanger'>A suspicious item appears!</span>")
			new selected_item(drop_location())
			create_smoke(2)
		if(15)
			//Random One-use spellbook
			var/list/oneuse_spellbook = list(/obj/item/spellbook/oneuse/smoke,
				/obj/item/spellbook/oneuse/blind,
				/obj/item/spellbook/oneuse/knock,
				/obj/item/spellbook/oneuse/summonitem)
			var/selected_spellbook = pick(oneuse_spellbook)
			T.visible_message("<span class='userdanger'>A magical looking book drops to the floor!</span>")
			create_smoke(2)
			new selected_spellbook(drop_location())
		if(16)
			//Servant & Servant Summon
			T.visible_message("<span class='userdanger'>A Dice Servant appears in a cloud of smoke!</span>")
			var/mob/living/carbon/human/H = new(drop_location())
			create_smoke(2)

			H.equipOutfit(/datum/outfit/butler)
			var/datum/mind/servant_mind = new /datum/mind()
			var/datum/objective/O = new
			O.owner = servant_mind
			O.target = user.mind
			O.explanation_text = "Serve [user.real_name]."
			servant_mind.objectives += O
			servant_mind.transfer_to(H)

			var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as the servant of [user.real_name]?", ROLE_WIZARD, poll_time = 30 SECONDS, source = H)
			if(length(candidates) && !QDELETED(H))
				var/mob/dead/observer/C = pick(candidates)
				message_admins("[ADMIN_LOOKUPFLW(C)] was spawned as Dice Servant")
				H.key = C.key
				to_chat(H, "<span class='notice'>You are a servant of [user.real_name]. You must do everything in your power to follow their orders.</span>")

			var/obj/effect/proc_holder/spell/summonmob/S = new
			S.target_mob = H
			user.mind.AddSpell(S)
		if(17)
			//Free Gun
			T.visible_message("<span class='userdanger'>An impressive gun appears!</span>")
			create_smoke(2)
			new /obj/item/gun/energy/kinetic_accelerator/experimental(drop_location())
		if(18)
			//Captain ID
			T.visible_message("<span class='userdanger'>A golden identification card appears!</span>")
			new /obj/item/card/id/captains_spare(drop_location())
			create_smoke(2)
		if(19)
			//Instrinct Resistance
			T.visible_message("<span class='userdanger'>[user] looks very robust!</span>")
			user.physiology.brute_mod *= 0.5
			user.physiology.burn_mod *= 0.5
		if(20)
			//Three free good dice rolls!
			T.visible_message("<span class='userdanger'>Critical number! [src] is rolling three times all by himself!</span>")
			addtimer(CALLBACK(src, PROC_REF(effect), user, rand(1, 9) + 10), 1 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(effect), user, rand(1, 9) + 10), 2 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(effect), user, rand(1, 9) + 10), 3 SECONDS)

/obj/item/dice/d100
	name = "d100"
	desc = "A die with one hundred sides! Probably not fairly weighted..."
	icon_state = "d100"
	sides = 100

/obj/item/dice/d100/update_overlays()
	return list()

/obj/item/dice/d20/e20
	var/triggered = FALSE

/obj/item/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/dice/throw_impact(atom/target)
	diceroll(locateUID(thrownby))
	. = ..()

/obj/item/dice/proc/diceroll(mob/user)
	result = roll(sides)
	if(rigged != DICE_NOT_RIGGED && result != rigged_value)
		if(rigged == DICE_BASICALLY_RIGGED && prob(clamp(1 / (sides - 1) * 100, 25, 80)))
			result = rigged_value
		else if(rigged == DICE_TOTALLY_RIGGED)
			result = rigged_value

	. = result

	var/fake_result = roll(sides)//Daredevil isn't as good as he used to be
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "NAT 20!"
	else if(sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	update_icon(UPDATE_OVERLAYS)
	if(initial(icon_state) == "d00")
		result = (result - 1) * 10
	if(length(special_faces) == sides)
		result = special_faces[result]
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message("[user] has thrown [src]. It lands on [result]. [comment]",
							"<span class='notice'>You throw [src]. It lands on [result]. [comment]</span>",
							"<span class='italics'>You hear [src] rolling, it sounds like a [fake_result].</span>")
	else if(!throwing) //Dice was thrown and is coming to rest
		visible_message("<span class='notice'>[src] rolls to a stop, landing on [result]. [comment]</span>")

/obj/item/dice/d20/e20/diceroll(mob/user, thrown)
	if(triggered)
		return

	. = ..()

	if(result == 1)
		to_chat(user, "<span class='danger'>Rocks fall, you die.</span>")
		user.gib()
		add_attack_logs(src, user, "detonated with a roll of [result], gibbing them!", ATKLOG_FEW)
	else
		triggered = TRUE
		visible_message("<span class='notice'>You hear a quiet click.</span>")
		addtimer(CALLBACK(src, PROC_REF(boom), user, result), 4 SECONDS)

/obj/item/dice/d20/e20/proc/boom(mob/user, result)
	var/capped = TRUE
	var/actual_result = result
	// Rolled a nat 20, screw the bombcap
	if(result == 20)
		capped = FALSE
		result = 24

	var/turf/epicenter = get_turf(src)
	var/area/A = get_area(epicenter)
	explosion(epicenter, round(result * 0.25), round(result * 0.5), round(result), round(result * 1.5), TRUE, capped)
	investigate_log("E20 detonated at [A.name] ([epicenter.x],[epicenter.y],[epicenter.z]) with a roll of [actual_result]. Triggered by: [key_name(user)]", INVESTIGATE_BOMB)
	log_game("E20 detonated at [A.name] ([epicenter.x],[epicenter.y],[epicenter.z]) with a roll of [actual_result]. Triggered by: [key_name(user)]")
	add_attack_logs(user, src, "detonated with a roll of [actual_result]", ATKLOG_FEW)

/obj/item/dice/update_overlays()
	. = ..()
	. += "[icon_state][result]"

/obj/item/storage/box/dice
	name = "Box of dice"
	desc = "ANOTHER ONE!? FUCK!"
	icon_state = "box"

/obj/item/storage/box/dice/populate_contents()
	new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
