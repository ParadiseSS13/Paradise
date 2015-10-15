/////////Apprentice Contract//////////

/obj/item/weapon/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/used = 0


/obj/item/weapon/contract/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat
	if(used)
		dat = "<B>You have already summoned your apprentice.</B><BR>"
	else
		dat = "<B>Contract of Apprenticeship:</B><BR>"
		dat += "<I>Using this contract, you may summon an apprentice to aid you on your mission.</I><BR>"
		dat += "<I>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</I><BR>"
		dat += "<B>Which school of magic is your apprentice studying?:</B><BR>"
		dat += "<A href='byond://?src=\ref[src];school=destruction'>Destruction</A><BR>"
		dat += "<I>Your apprentice is skilled in offensive magic. They know Magic Missile and Fireball.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=bluespace'>Bluespace Manipulation</A><BR>"
		dat += "<I>Your apprentice is able to defy physics, melting through solid objects and travelling great distances in the blink of an eye. They know Teleport and Ethereal Jaunt.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=healing'>Healing</A><BR>"
		dat += "<I>Your apprentice is training to cast spells that will aid your survival. They know Forcewall and Charge and come with a Staff of Healing.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=robeless'>Robeless</A><BR>"
		dat += "<I>Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.</I><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return


/obj/item/weapon/contract/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr

	if(H.stat || H.restrained())
		return
	if(!istype(H, /mob/living/carbon/human))
		return 1

	if(loc == H || (in_range(src, H) && istype(loc, /turf)))
		H.set_machine(src)
		if(href_list["school"])
			if (used)
				H << "You already used this contract!"
				return
			var/list/candidates = get_candidates(BE_WIZARD)
			if(candidates.len)
				src.used = 1
				var/client/C = pick(candidates)
				new /obj/effect/effect/harmless_smoke(H.loc)
				var/mob/living/carbon/human/M = new/mob/living/carbon/human(H.loc)
				M.key = C.key
				M << "<B>You are the [H.real_name]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals."
				switch(href_list["school"])
					if("destruction")
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(M))
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/dumbfire/fireball(M))
						M << "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball."
					if("bluespace")
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(M))
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(M))
						M << "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt."
					if("healing")
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(M))
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall(M))
						M.equip_to_slot_or_del(new /obj/item/weapon/gun/magic/staff/healing(M), slot_r_hand)
						M << "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned livesaving survival spells. You are able to cast charge and forcewall."
					if("robeless")
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(M))
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mind_transfer(M))
						M << "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap."

				M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
				M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll/apprentice(M), slot_r_store)
				var/wizard_name_first = pick(wizard_first)
				var/wizard_name_second = pick(wizard_second)
				var/randomname = "[wizard_name_first] [wizard_name_second]"
				var/newname = sanitize(copytext(input(M, "You are the wizard's apprentice. Would you like to change your name to something else?", "Name change", randomname) as null|text,1,MAX_NAME_LEN))

				if (!newname)
					newname = randomname
				M.mind.name = newname
				M.real_name = newname
				M.name = newname
				var/datum/objective/protect/new_objective = new /datum/objective/protect
				new_objective.owner = M:mind
				new_objective:target = H:mind
				new_objective.explanation_text = "Protect [H.real_name], the wizard."
				M.mind.objectives += new_objective
				ticker.mode.traitors += M.mind
				M.mind.special_role = "apprentice"
				M.faction = list("wizard")
			else
				H << "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later."
	return


///////////////////////////Veil Render//////////////////////

/obj/item/weapon/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 15
	throwforce = 10
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/charged = 1
	var/spawn_type = /obj/singularity/narsie/wizard
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."

/obj/item/weapon/veilrender/attack_self(mob/user as mob)
	if(charged)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc)
		charged = 0
		user.visible_message("<span class='userdanger'>[src] hums with power as [user] deals a blow to [activate_descriptor] itself!</span>")
	else
		user << "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>"


/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	unacidable = 1
	anchored = 1.0
	var/spawn_path = /mob/living/simple_animal/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20

/obj/effect/rend/New(loc, var/spawn_type, var/spawn_amt, var/desc)
	..()
	src.spawn_path = spawn_type
	src.spawn_amt_left = spawn_amt
	src.desc = desc

	processing_objects.Add(src)
	//return

/obj/effect/rend/process()
	for(var/mob/M in loc)
		return
	new spawn_path(loc)
	spawn_amt_left--
	if(spawn_amt_left <= 0)
		qdel(src)

/obj/effect/rend/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/nullrod))
		user.visible_message("<span class='danger'>[user] seals \the [src] with \the [I].</span>")
		qdel(src)
		return
	..()

/obj/item/weapon/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/simple_animal/cow
	spawn_amt = 20
	activate_descriptor = "hunger"
	rend_desc = "Reverberates with the sound of ten thousand moos."

/obj/item/weapon/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown
	spawn_amt = 10
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of endless laughter."
	icon_state = "clownrender"


/obj/item/weapon/veilrender/crabrender
	name = "crab render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast aquarium."
	spawn_type = /mob/living/simple_animal/crab
	spawn_amt = 10
	activate_descriptor = "sea life"
	rend_desc = "Gently wafting with the sounds of endless clacking."

/////////////////////////////////////////Scrying///////////////////

/obj/item/weapon/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 7
	throw_range = 15
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

/obj/item/weapon/scrying/attack_self(mob/user as mob)
	user << "<span class='notice'> You can see...everything!</span>"
	visible_message("<span class='danger'>[user] stares into [src], their eyes glazing over.</span>")
	user.ghostize(1)

/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/device/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	item_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = 1
	var/list/spooky_scaries = list()
	var/unlimited = 0

/obj/item/device/necromantic_stone/unlimited
	unlimited = 1

/obj/item/device/necromantic_stone/attack(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)

	if(!istype(M))
		return ..()

	if(!istype(user))
		return

	if(M.stat != DEAD)
		user << "<span class='warning'>This artifact can only affect the dead!</span>"
		return

	if(!M.mind || !M.client)
		user << "<span class='warning'>There is no soul connected to this body...</span>"
		return

	check_spooky()//clean out/refresh the list

	if(spooky_scaries.len >= 3 && !unlimited)
		user << "<span class='warning'>This artifact can only affect three undead at a time!</span>"
		return
	M.MakeSkeleton()
	M.revive()
	spooky_scaries |= M
	M << "<span class='userdanger'>You have been revived by </span><B>[user.real_name]!</B>"
	M << "<span class='userdanger'>They are your master now, assist them even if it costs you your new life!</span>"
	equip_skeleton(M)
	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/device/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return
	for(var/X in spooky_scaries)
		if(!istype(X, /mob/living/carbon/human))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat == DEAD)
			spooky_scaries.Remove(X)
			continue
	listclearnulls(spooky_scaries)

//Funny gimmick, skeletons always seem to wear roman/ancient armour
//Voodoo Zombie Pirates added for paradise
/obj/item/device/necromantic_stone/proc/equip_skeleton(mob/living/carbon/human/H as mob)
	for(var/obj/item/I in H)
		H.unEquip(I)
	var/randomSpooky = pick("roman","pirate","yand","clown")
	switch(randomSpooky)
		if("roman")
			var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
			H.equip_to_slot_or_del(new hat(H), slot_head)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/roman(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/roman(H), slot_l_hand)
			H.equip_to_slot_or_del(new /obj/item/weapon/claymore(H), slot_r_hand)
			H.equip_to_slot_or_del(new /obj/item/weapon/twohanded/spear(H), slot_back)
		if("pirate")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/pirate_brown(H),  slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(H), slot_head)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(H), slot_glasses)
		if("yand")//mine is an evil laugh
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(H), slot_head)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl(H), slot_w_uniform)
		if("clown")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
			H.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(H), slot_l_store)


/////////////////////////////////////////Voodoo///////////////////


/obj/item/voodoo
	name = "wicker doll"
	desc = "Something creepy about it."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "voodoo"
	item_state = "electronic"
	var/mob/living/carbon/human/target = null
	var/list/mob/living/carbon/human/possible = list()
	var/obj/item/link = null
	var/cooldown_time = 30 //3s
	var/cooldown = 0



/obj/item/voodoo/attackby(obj/item/I as obj, mob/user as mob, params)
	if(target && cooldown < world.time)
		if(is_hot(I))
			target << "<span class='userdanger'>You suddenly feel very hot</span>"
			target.bodytemperature += 50
			GiveHint(target)
		else if(can_puncture(I))
			target << "<span class='userdanger'>You feel a stabbing pain in [parse_zone(user.zone_sel.selecting)]!</span>"
			target.Weaken(2)
			GiveHint(target)
		else if(istype(I,/obj/item/weapon/bikehorn))
			target << "<span class='userdanger'>HONK</span>"
			target << 'sound/items/AirHorn.ogg'
			target.ear_damage += rand(0,3)
			GiveHint(target)
		cooldown = world.time +cooldown_time
		return
	if(!link)
		if(I.loc == user && istype(I) && I.w_class <= 2)
			user.drop_item()
			I.loc = src
			link = I
			user << "You attach [I] to the doll."
			update_targets()
	..()
/obj/item/voodoo/check_eye(mob/user as mob)
	return src.loc == user

/obj/item/voodoo/attack_self(mob/user as mob)
	if(!target && possible.len)
		target = input(user, "Select your victim!", "Voodoo") as null|anything in possible
		return
	if(user.zone_sel.selecting == "chest")
		if(link)
			target = null
			link.loc = get_turf(src)
			user << "<span class='notice'>You remove the [link] from the doll.</span>"
			link = null
			update_targets()
			return
	if(target && cooldown < world.time)
		switch(user.zone_sel.selecting)
			if("mouth")
				var/wgw =  sanitize(input(user, "What would you like the victim to say", "Voodoo", null)  as text)
				target.say(wgw)
				log_game("[user][user.key] made [target][target.key] say [wgw] with a voodoo doll.")
			if("eyes")
				user.set_machine(src)
				if(user.client)
					user.client.eye = target
					user.client.perspective = EYE_PERSPECTIVE
				spawn(100)
					user.reset_view()
					user.unset_machine()
			if("r_leg","l_leg")
				user << "<span class='notice'>You move the doll's legs around.</span>"
				var/turf/T = get_step(target,pick(cardinal))
				target.Move(T)
			if("r_arm","l_arm")
				//use active hand on random nearby mob
				var/list/nearby_mobs = list()
				for(var/mob/living/L in range(target,1))
					if(L!=target)
						nearby_mobs |= L
				if(nearby_mobs.len)
					var/mob/living/T = pick(nearby_mobs)
					log_game("[user][user.key] made [target][target.key] click on [T] with a voodoo doll.")
					target.ClickOn(T)
					GiveHint(target)
			if("head")
				user << "<span class='notice'>You smack the doll's head with your hand.</span>"
				target.Dizzy(10)
				target << "<span class='warning'>You suddenly feel as if your head was hit with a hammer!</span>"
				GiveHint(target,user)
		cooldown = world.time + cooldown_time

/obj/item/voodoo/proc/update_targets()
	possible = list()
	if(!link)
		return
	for(var/mob/living/carbon/human/H in living_mob_list)
		if(md5(H.dna.uni_identity) in link.fingerprints)
			possible |= H

/obj/item/voodoo/proc/GiveHint(mob/victim,force=0)
	if(prob(50) || force)
		var/way = dir2text(get_dir(victim,get_turf(src)))
		victim << "<span class='notice'>You feel a dark presence from [way]</span>"
	if(prob(20) || force)
		var/area/A = get_area(src)
		victim << "<span class='notice'>You feel a dark presence from [A.name]</span>"

/obj/item/voodoo/fire_act()
	if(target)
		target.adjust_fire_stacks(20)
		target.IgniteMob()
		GiveHint(target,1)
	return ..()
