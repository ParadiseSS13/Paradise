//Academy Areas

/area/awaymission/academy
	name = "\improper Academy Asteroids"
	icon_state = "away"
	report_alerts = FALSE

/area/awaymission/academy/headmaster
	name = "\improper Academy Fore Block"
	icon_state = "away1"

/area/awaymission/academy/classrooms
	name = "\improper Academy Classroom Block"
	icon_state = "away2"

/area/awaymission/academy/academyaft
	name = "\improper Academy Ship Aft Block"
	icon_state = "away3"

/area/awaymission/academy/academygate
	name = "\improper Academy Gateway"
	icon_state = "away4"

//Academy Items

/obj/singularity/academy
	dissipate = 0
	move_self = 0
	grav_pull = 1

/obj/singularity/academy/admin_investigate_setup()
	return

/obj/singularity/academy/process()
	eat()
	if(prob(1))
		mezzer()

/obj/item/clothing/glasses/meson/truesight
	name = "The Lens of Truesight"
	desc = "I can see forever!"
	icon_state = "monocle"
	item_state = "headset"

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

		addtimer(CALLBACK(src, .proc/effect, user, .), 1 SECONDS)

/obj/item/dice/d20/fate/equipped(mob/user, slot)
	if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
		to_chat(user, "<span class='warning'>You feel the magic of the dice is restricted to ordinary humans! You should leave it alone.</span>")
		user.unEquip(src)

/obj/item/dice/d20/fate/proc/create_smoke(amount)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(amount, 0, drop_location())
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
				new /mob/living/simple_animal/hostile/netherworld(get_step(get_turf(user),direction))
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
			user.Stun(6)
			user.adjustBruteLoss(50)
			var/throw_dir = GLOB.cardinal
			var/atom/throw_target = get_edge_target_turf(user, throw_dir)
			user.throw_at(throw_target, 200, 4)
		if(8)
			//Fueltank Explosion
			T.visible_message("<span class='userdanger'>An explosion bursts into existence around [user]!</span>")
			explosion(get_turf(user),-1,0,2, flame_range = 2)
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
				var/turf/dirturf = get_step(Start,direction)
				if(rand(0,1))
					new /obj/item/stack/spacecash/c1000(dirturf)
				else
					var/obj/item/storage/bag/money/M = new(dirturf)
					for(var/i in 1 to rand(5,50))
						new /obj/item/coin/gold(M)
		if(14)
			//Free Gun
			T.visible_message("<span class='userdanger'>An impressive gun appears!</span>")
			create_smoke(2)
			new /obj/item/gun/projectile/revolver/mateba(drop_location())
		if(15)
			//Random One-use spellbook
			T.visible_message("<span class='userdanger'>A magical looking book drops to the floor!</span>")
			create_smoke(2)
			new /obj/item/spellbook/oneuse/random(drop_location())
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
			if(LAZYLEN(candidates))
				var/mob/dead/observer/C = pick(candidates)
				message_admins("[ADMIN_LOOKUPFLW(C)] was spawned as Dice Servant")
				H.key = C.key
				to_chat(H, "<span class='notice'>You are a servant of [user.real_name]. You must do everything in your power to follow their orders.</span>")

			var/obj/effect/proc_holder/spell/targeted/summonmob/S = new
			S.target_mob = H
			user.mind.AddSpell(S)

		if(17)
			//Tator Kit
			T.visible_message("<span class='userdanger'>A suspicious box appears!</span>")
			new /obj/item/storage/box/syndicate(drop_location())
			create_smoke(2)
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
			//Free wizard!
			T.visible_message("<span class='userdanger'>Magic flows out of [src] and into [user]!</span>")
			user.mind.make_Wizard()

// Butler outfit
/datum/outfit/butler
	name = "Butler"
	uniform = /obj/item/clothing/under/suit_jacket/really_black
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/bowlerhat
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/white

/obj/effect/proc_holder/spell/targeted/summonmob
	name = "Summon Servant"
	desc = "This spell can be used to call your servant, whenever you need it."
	charge_max = 100
	clothes_req = 0
	invocation = "JE VES"
	invocation_type = "whisper"
	range = -1
	level_max = 0 //cannot be improved
	cooldown_min = 100
	include_user = 1

	var/mob/living/target_mob

	action_icon_state = "summons"

/obj/effect/proc_holder/spell/targeted/summonmob/cast(list/targets, mob/user = usr)
	if(!target_mob)
		return
	var/turf/Start = get_turf(user)
	for(var/direction in GLOB.alldirs)
		var/turf/T = get_step(Start,direction)
		if(!T.density)
			target_mob.Move(T)
