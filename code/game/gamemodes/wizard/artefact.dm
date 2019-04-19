/////////Apprentice Contract//////////

/obj/item/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = 0


/obj/item/contract/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat
	if(used)
		dat = "<B>You have already summoned your apprentice.</B><BR>"
	else
		dat = "<B>Contract of Apprenticeship:</B><BR>"
		dat += "<I>Using this contract, you may summon an apprentice to aid you on your mission.</I><BR>"
		dat += "<I>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</I><BR>"
		dat += "<B>Which school of magic is your apprentice studying?:</B><BR>"
		dat += "<A href='byond://?src=[UID()];school=destruction'>Destruction</A><BR>"
		dat += "<I>Your apprentice is skilled in offensive magic. They know Magic Missile and Fireball.</I><BR>"
		dat += "<A href='byond://?src=[UID()];school=bluespace'>Bluespace Manipulation</A><BR>"
		dat += "<I>Your apprentice is able to defy physics, melting through solid objects and travelling great distances in the blink of an eye. They know Teleport and Ethereal Jaunt.</I><BR>"
		dat += "<A href='byond://?src=[UID()];school=healing'>Healing</A><BR>"
		dat += "<I>Your apprentice is training to cast spells that will aid your survival. They know Forcewall and Charge and come with a Staff of Healing.</I><BR>"
		dat += "<A href='byond://?src=[UID()];school=robeless'>Robeless</A><BR>"
		dat += "<I>Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.</I><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return


/obj/item/contract/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr

	if(H.stat || H.restrained())
		return
	if(!istype(H, /mob/living/carbon/human))
		return 1

	if(loc == H || (in_range(src, H) && istype(loc, /turf)))
		H.set_machine(src)
		if(href_list["school"])
			if(used)
				to_chat(H, "You already used this contract!")
				return
			used = 1
			var/list/candidates = pollCandidates("Do you want to play as the wizard apprentice of [H.real_name]?", ROLE_WIZARD, 1)
			if(candidates.len)
				var/mob/C = pick(candidates)
				new /obj/effect/particle_effect/smoke(H.loc)
				var/mob/living/carbon/human/M = new/mob/living/carbon/human(H.loc)
				M.key = C.key
				to_chat(M, "<B>You are the [H.real_name]'s apprentice! You are bound by magic contract to follow [H.p_their()] orders and help [H.p_them()] in accomplishing their goals.")
				switch(href_list["school"])
					if("destruction")
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null))
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/fireball(null))
						to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball.")
					if("bluespace")
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))
						to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt.")
					if("healing")
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(null))
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall(null))
						M.equip_to_slot_or_del(new /obj/item/gun/magic/staff/healing(M), slot_r_hand)
						to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned livesaving survival spells. You are able to cast charge and forcewall.")
					if("robeless")
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
						M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mind_transfer(null))
						to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap.")

				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/storage/backpack(M), slot_back)
				M.equip_to_slot_or_del(new /obj/item/storage/box(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/teleportation_scroll/apprentice(M), slot_r_store)
				var/wizard_name_first = pick(GLOB.wizard_first)
				var/wizard_name_second = pick(GLOB.wizard_second)
				var/randomname = "[wizard_name_first] [wizard_name_second]"
				var/newname = sanitize(copytext(input(M, "You are the wizard's apprentice. Would you like to change your name to something else?", "Name change", randomname) as null|text,1,MAX_NAME_LEN))

				if(!newname)
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
				M.mind.special_role = SPECIAL_ROLE_WIZARD_APPRENTICE
				ticker.mode.update_wiz_icons_added(M.mind)
				M.faction = list("wizard")
			else
				used = 0
				to_chat(H, "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later.")
	return


///////////////////////////Veil Render//////////////////////

/obj/item/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/charged = 1
	var/spawn_type = /obj/singularity/narsie/wizard
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."

/obj/item/veilrender/attack_self(mob/user as mob)
	if(charged)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc)
		charged = 0
		user.visible_message("<span class='userdanger'>[src] hums with power as [user] deals a blow to [activate_descriptor] itself!</span>")
	else
		to_chat(user, "<span class='danger'>The unearthly energies that powered the blade are now dormant.</span>")


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
	if(istype(I, /obj/item/nullrod))
		user.visible_message("<span class='danger'>[user] seals \the [src] with \the [I].</span>")
		qdel(src)
		return
	..()

/obj/item/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/simple_animal/cow
	spawn_amt = 20
	activate_descriptor = "hunger"
	rend_desc = "Reverberates with the sound of ten thousand moos."

/obj/item/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown
	spawn_amt = 10
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of endless laughter."
	icon_state = "clownrender"


/obj/item/veilrender/crabrender
	name = "crab render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast aquarium."
	spawn_type = /mob/living/simple_animal/crab
	spawn_amt = 10
	activate_descriptor = "sea life"
	rend_desc = "Gently wafting with the sounds of endless clacking."

/////////////////////////////////////////Scrying///////////////////

/obj/item/scrying
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

/obj/item/scrying/attack_self(mob/user as mob)
	to_chat(user, "<span class='notice'> You can see...everything!</span>")
	visible_message("<span class='danger'>[user] stares into [src], [user.p_their()] eyes glazing over.</span>")
	user.ghostize(1)

/////////////////////Multiverse Blade////////////////////
var/global/list/multiverse = list()

/obj/item/multisword
	name = "multiverse sword"
	desc = "A weapon capable of conquering the universe and beyond. Activate it to summon copies of yourself from others dimensions to fight by your side."
	icon_state = "energy_katana"
	item_state = "energy_katana"
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 20
	throwforce = 10
	sharp = 1
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/faction = list("unassigned")
	var/cooldown = 0
	var/cooldown_between_uses = 400 //time in deciseconds between uses--default of 40 seconds.
	var/assigned = "unassigned"
	var/evil = TRUE
	var/probability_evil = 30 //what's the probability this sword will be evil when activated?
	var/duplicate_self = 0 //Do we want the species randomized along with equipment should the user be duplicated in their entirety?
	var/sword_type = /obj/item/multisword //type of sword to equip.

/obj/item/multisword/New()
	..()
	multiverse |= src


/obj/item/multisword/Destroy()
	multiverse.Remove(src)
	return ..()

/obj/item/multisword/attack(mob/living/M as mob, mob/living/user as mob)  //to prevent accidental friendly fire or out and out grief.
	if(M.real_name == user.real_name)
		to_chat(user, "<span class='warning'>The [src] detects benevolent energies in your target and redirects your attack!</span>")
		return
	..()

/obj/item/multisword/attack_self(mob/user)
	if(user.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)
		to_chat(user, "<span class='warning'>You know better than to touch your teacher's stuff.</span>")
		return
	if(cooldown < world.time)
		var/faction_check = 0
		for(var/F in faction)
			if(F in user.faction)
				faction_check = 1
				break
		if(faction_check == 0)
			faction = list("[user.real_name]")
			assigned = "[user.real_name]"
			user.faction = list("[user.real_name]")
			to_chat(user, "You bind the sword to yourself. You can now use it to summon help.")
			if(!usr.mind.special_role)
				if(prob(probability_evil))
					to_chat(user, "<span class='warning'><B>With your new found power you could easily conquer the station!</B></span>")
					var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
					hijack_objective.owner = usr.mind
					usr.mind.objectives += hijack_objective
					hijack_objective.explanation_text = "Ensure only [usr.real_name] and [usr.p_their()] copies are on the shuttle!"
					to_chat(usr, "<B>Objective #[1]</B>: [hijack_objective.explanation_text]")
					ticker.mode.traitors += usr.mind
					usr.mind.special_role = "[usr.real_name] Prime"
					evil = TRUE
				else
					to_chat(user, "<span class='warning'><B>With your new found power you could easily defend the station!</B></span>")
					var/datum/objective/survive/new_objective = new /datum/objective/survive
					new_objective.owner = usr.mind
					new_objective.explanation_text = "Survive, and help defend the innocent from the mobs of multiverse clones."
					to_chat(usr, "<B>Objective #[1]</B>: [new_objective.explanation_text]")
					usr.mind.objectives += new_objective
					ticker.mode.traitors += usr.mind
					usr.mind.special_role = "[usr.real_name] Prime"
					evil = FALSE
		else
			cooldown = world.time + cooldown_between_uses
			for(var/obj/item/multisword/M in multiverse)
				if(M.assigned == assigned)
					M.cooldown = cooldown

			var/list/candidates = pollCandidates("Do you want to play as the wizard apprentice of [user.real_name]?", ROLE_WIZARD, 1, 100)
			if(candidates.len)
				var/mob/C = pick(candidates)
				spawn_copy(C.client, get_turf(user.loc), user)
				to_chat(user, "<span class='warning'><B>The sword flashes, and you find yourself face to face with...you!</B></span>")

			else
				to_chat(user, "You fail to summon any copies of yourself. Perhaps you should try again in a bit.")
	else
		to_chat(user, "<span class='warning'><B>[src] is recharging! Keep in mind it shares a cooldown with the swords wielded by your copies.</span>")


/obj/item/multisword/proc/spawn_copy(var/client/C, var/turf/T, mob/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	if(duplicate_self)
		user.client.prefs.copy_to(M)
	else
		C.prefs.copy_to(M)
	M.key = C.key
	M.mind.name = user.real_name
	to_chat(M, "<B>You are an alternate version of [user.real_name] from another universe! Help [user.p_them()] accomplish [user.p_their()] goals at all costs.</B>")
	M.faction = list("[user.real_name]")
	if(duplicate_self)
		M.set_species(user.dna.species.type) //duplicate the sword user's species.
	else
		if(prob(50))
			var/list/list_all_species = list(/datum/species/human, /datum/species/unathi, /datum/species/skrell, /datum/species/tajaran, /datum/species/kidan, /datum/species/golem, /datum/species/diona, /datum/species/machine, /datum/species/slime, /datum/species/grey, /datum/species/vulpkanin)
			M.set_species(pick(list_all_species))
	M.real_name = user.real_name //this is clear down here in case the user happens to become a golem; that way they have the proper name.
	M.name = user.real_name
	if(duplicate_self)
		M.dna = user.dna.Clone()
		M.UpdateAppearance()
		domutcheck(M, null)
	M.update_body()
	M.update_hair()
	M.update_fhair()

	equip_copy(M)

	if(evil)
		var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
		hijack_objective.owner = M.mind
		M.mind.objectives += hijack_objective
		hijack_objective.explanation_text = "Ensure only [usr.real_name] and [usr.p_their()] copies are on the shuttle!"
		to_chat(M, "<B>Objective #[1]</B>: [hijack_objective.explanation_text]")
		M.mind.special_role = SPECIAL_ROLE_MULTIVERSE
		log_game("[M.key] was made a multiverse traveller with the objective to help [usr.real_name] hijack.")
	else
		var/datum/objective/protect/new_objective = new /datum/objective/protect
		new_objective.owner = M.mind
		new_objective.target = usr.mind
		new_objective.explanation_text = "Protect [usr.real_name], your copy, and help [usr.p_them()] defend the innocent from the mobs of multiverse clones."
		M.mind.objectives += new_objective
		to_chat(M, "<B>Objective #[1]</B>: [new_objective.explanation_text]")
		M.mind.special_role = SPECIAL_ROLE_MULTIVERSE
		log_game("[M.key] was made a multiverse traveller with the objective to help [usr.real_name] protect the station.")

/obj/item/multisword/proc/equip_copy(var/mob/living/carbon/human/M)

	var/obj/item/multisword/sword = new sword_type
	sword.assigned = assigned
	sword.faction = list("[assigned]")
	sword.evil = evil

	if(duplicate_self)
		//Duplicates the user's current equipent
		var/mob/living/carbon/human/H = usr

		var/obj/head = H.get_item_by_slot(slot_head)
		if(head)
			M.equip_to_slot_or_del(new head.type(M), slot_head)

		var/obj/mask = H.get_item_by_slot(slot_wear_mask)
		if(mask)
			M.equip_to_slot_or_del(new mask.type(M), slot_wear_mask)

		var/obj/glasses = H.get_item_by_slot(slot_glasses)
		if(glasses)
			M.equip_to_slot_or_del(new glasses.type(M), slot_glasses)

		var/obj/left_ear = H.get_item_by_slot(slot_l_ear)
		if(left_ear)
			M.equip_to_slot_or_del(new left_ear.type(M), slot_l_ear)

		var/obj/right_ear = H.get_item_by_slot(slot_r_ear)
		if(right_ear)
			M.equip_to_slot_or_del(new right_ear.type(M), slot_r_ear)

		var/obj/uniform = H.get_item_by_slot(slot_w_uniform)
		if(uniform)
			M.equip_to_slot_or_del(new uniform.type(M), slot_w_uniform)

		var/obj/suit = H.get_item_by_slot(slot_wear_suit)
		if(suit)
			M.equip_to_slot_or_del(new suit.type(M), slot_wear_suit)

		var/obj/gloves = H.get_item_by_slot(slot_gloves)
		if(gloves)
			M.equip_to_slot_or_del(new gloves.type(M), slot_gloves)

		var/obj/shoes = H.get_item_by_slot(slot_shoes)
		if(shoes)
			M.equip_to_slot_or_del(new shoes.type(M), slot_shoes)

		var/obj/belt = H.get_item_by_slot(slot_belt)
		if(belt)
			M.equip_to_slot_or_del(new belt.type(M), slot_belt)

		var/obj/pda = H.get_item_by_slot(slot_wear_pda)
		if(pda)
			M.equip_to_slot_or_del(new pda.type(M), slot_wear_pda)

		var/obj/back = H.get_item_by_slot(slot_back)
		if(back)
			M.equip_to_slot_or_del(new back.type(M), slot_back)

		var/obj/suit_storage = H.get_item_by_slot(slot_s_store)
		if(suit_storage)
			M.equip_to_slot_or_del(new suit_storage.type(M), slot_s_store)

		var/obj/left_pocket = H.get_item_by_slot(slot_l_store)
		if(left_pocket)
			M.equip_to_slot_or_del(new left_pocket.type(M), slot_l_store)

		var/obj/right_pocket = H.get_item_by_slot(slot_r_store)
		if(right_pocket)
			M.equip_to_slot_or_del(new right_pocket.type(M), slot_r_store)

		M.equip_to_slot_or_del(sword, slot_r_hand) //Don't duplicate what's equipped to hands, or else duplicate swords could be generated...or weird cases of factionless swords.
	else
		if(istajaran(M) || isunathi(M))
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)	//If they can't wear shoes, give them a pair of sandals.

		var/randomize = pick("mobster","roman","wizard","cyborg","syndicate","assistant", "animu", "cultist", "highlander", "clown", "killer", "pirate", "soviet", "officer", "gladiator")

		switch(randomize)
			if("mobster")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/fedora(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/really_black(M), slot_w_uniform)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("roman")
				var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
				M.equip_to_slot_or_del(new hat(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/roman(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/shield/riot/roman(M), slot_l_hand)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("wizard")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(M), slot_head)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("cyborg")
				if(!ismachine(M))
					for(var/obj/item/organ/O in M.bodyparts)
						O.robotize(make_tough = 1)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), slot_glasses)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("syndicate")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M),slot_wear_mask)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("assistant")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("animu")
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl(M), slot_w_uniform)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("cultist")
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("highlander")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/beret(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("clown")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), slot_wear_mask)
				M.equip_to_slot_or_del(new /obj/item/bikehorn(M), slot_l_store)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("killer")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/overalls(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/latex(M), slot_gloves)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), slot_wear_mask)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/welding(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/kitchen/knife(M), slot_l_store)
				M.equip_to_slot_or_del(new /obj/item/scalpel(M), slot_r_store)
				M.equip_to_slot_or_del(sword, slot_r_hand)
				for(var/obj/item/carried_item in M.contents)
					if(!istype(carried_item, /obj/item/implant))
						carried_item.add_mob_blood(M)

			if("pirate")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("soviet")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/hgpiratecap(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/hgpirate(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), slot_w_uniform)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("officer")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad/beret(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/havana(M), slot_wear_mask)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/jacket/miljacket(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)
				M.equip_to_slot_or_del(sword, slot_r_hand)

			if("gladiator")
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/gladiator(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/gladiator(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/radio/headset(M), slot_l_ear)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
				M.equip_to_slot_or_del(sword, slot_r_hand)


			else
				return

	var/obj/item/card/id/W = new /obj/item/card/id
	if(duplicate_self)
		var/duplicated_access = usr.get_item_by_slot(slot_wear_id)
		if(duplicated_access && istype(duplicated_access, /obj/item/card/id))
			var/obj/item/card/id/duplicated_id = duplicated_access
			W.access = duplicated_id.access
			W.icon_state = duplicated_id.icon_state
		else
			W.access += access_maint_tunnels
			W.icon_state = "centcom"
	else
		W.access += access_maint_tunnels
		W.icon_state = "centcom"
	W.assignment = "Multiverse Traveller"
	W.registered_name = M.real_name
	W.update_label(M.real_name)
	W.SetOwnerInfo(M)
	M.equip_to_slot_or_del(W, slot_wear_id)

	if(isvox(M))
		M.dna.species.after_equip_job(null, M) //Nitrogen tanks
	if(isplasmaman(M))
		M.dna.species.after_equip_job(null, M) //No fireballs from other dimensions.

	M.update_icons()

/obj/item/multisword/pure_evil
	probability_evil = 100

/obj/item/multisword/pike //If We are to be used and spent, let it be for a noble purpose.
	name = "phantom pike"
	desc = "A fishing pike that appears to be imbued with a peculiar energy."
	icon_state = "harpoon"
	item_state = "harpoon"
	cooldown_between_uses = 200 //Half the time
	probability_evil = 100
	duplicate_self = 1
	sword_type = /obj/item/multisword/pike


/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	item_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = WEIGHT_CLASS_TINY
	var/list/spooky_scaries = list()
	var/unlimited = 0
	var/heresy = 0

/obj/item/necromantic_stone/unlimited
	unlimited = 1

/obj/item/necromantic_stone/attack(mob/living/carbon/human/M as mob, mob/living/carbon/human/user as mob)

	if(!istype(M))
		return ..()

	if(!istype(user))
		return

	if(M.stat != DEAD)
		to_chat(user, "<span class='warning'>This artifact can only affect the dead!</span>")
		return

	if(!M.mind || !M.client)
		to_chat(user, "<span class='warning'>There is no soul connected to this body...</span>")
		return

	check_spooky()//clean out/refresh the list

	if(spooky_scaries.len >= 3 && !unlimited)
		to_chat(user, "<span class='warning'>This artifact can only affect three undead at a time!</span>")
		return
	if(heresy)
		spawnheresy(M)//oh god why
	else
		M.set_species(/datum/species/skeleton)
		M.visible_message("<span class = 'warning'> A massive amount of flesh sloughs off [M] and a skeleton rises up!</span>")
		M.revive()
		equip_skeleton(M)
	spooky_scaries |= M
	to_chat(M, "<span class='userdanger'>You have been revived by </span><B>[user.real_name]!</B>")
	to_chat(M, "<span class='userdanger'>[user.p_theyre(TRUE)] your master now, assist them even if it costs you your new life!</span>")
	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/necromantic_stone/proc/check_spooky()
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
/obj/item/necromantic_stone/proc/equip_skeleton(mob/living/carbon/human/H as mob)
	for(var/obj/item/I in H)
		H.unEquip(I)
	var/randomSpooky = "roman"//defualt
	randomSpooky = pick("roman","pirate","yand","clown")

	switch(randomSpooky)
		if("roman")
			var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
			H.equip_to_slot_or_del(new hat(H), slot_head)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/roman(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), slot_l_hand)
			H.equip_to_slot_or_del(new /obj/item/claymore(H), slot_r_hand)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), slot_back)
		if("pirate")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/pirate_brown(H),  slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(H), slot_head)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(H), slot_glasses)
			H.equip_to_slot_or_del(new /obj/item/claymore(H), slot_r_hand)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), slot_back)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), slot_l_hand)
		if("yand")//mine is an evil laugh
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(H), slot_head)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H),  slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/katana(H), slot_r_hand)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), slot_l_hand)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), slot_back)
		if("clown")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/stalhelm(H), slot_head)
			H.equip_to_slot_or_del(new /obj/item/bikehorn(H), slot_l_store)
			H.equip_to_slot_or_del(new /obj/item/claymore(H), slot_r_hand)
			H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), slot_l_hand)
			H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), slot_back)

/obj/item/necromantic_stone/proc/spawnheresy(mob/living/carbon/human/H as mob)
	H.set_species(/datum/species/human)
	if(H.gender == MALE)
		H.change_gender(FEMALE)

	var/list/anime_hair =list("Odango", "Kusanagi Hair", "Pigtails", "Hime Cut", "Floorlength Braid", "Ombre", "Twincurls", "Twincurls 2")
	H.change_hair(pick(anime_hair))

	var/list/anime_hair_colours = list(list(216, 192, 120),
	list(140,170,74),list(0,0,0))

	var/list/chosen_colour = pick(anime_hair_colours)
	H.change_hair_color(chosen_colour[1], chosen_colour[2], chosen_colour[3])

	H.update_dna()
	H.update_body()

	H.revive()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/kitty(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/schoolgirl(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H),  slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/katana(H), slot_r_hand)
	H.equip_to_slot_or_del(new /obj/item/shield/riot/roman(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/twohanded/spear(H), slot_back)
	if(!H.real_name || H.real_name == "unknown")
		H.real_name = "Neko-chan"
	else
		H.real_name = "[H.name]-chan"
	H.say("NYA!~")

/obj/item/necromantic_stone/nya
	name = "nya-cromantic stone"
	desc = "A shard capable of resurrecting humans as creatures of Vile Heresy. Even the Wizard Federation fears it.."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "nyacrostone"
	item_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = WEIGHT_CLASS_TINY
	heresy = 1
	unlimited = 1

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
	burntime = 0
	burn_state = FLAMMABLE

/obj/item/voodoo/attackby(obj/item/I as obj, mob/user as mob, params)
	if(target && cooldown < world.time)
		if(is_hot(I))
			to_chat(target, "<span class='userdanger'>You suddenly feel very hot</span>")
			target.bodytemperature += 50
			GiveHint(target)
		else if(is_pointed(I))
			to_chat(target, "<span class='userdanger'>You feel a stabbing pain in [parse_zone(user.zone_sel.selecting)]!</span>")
			target.Weaken(2)
			GiveHint(target)
		else if(istype(I,/obj/item/bikehorn))
			to_chat(target, "<span class='userdanger'>HONK</span>")
			target << 'sound/items/airhorn.ogg'
			target.MinimumDeafTicks(3)
			GiveHint(target)
		cooldown = world.time +cooldown_time
		return

	if(!link)
		if(I.loc == user && istype(I) && I.w_class <= WEIGHT_CLASS_SMALL)
			user.drop_item()
			I.loc = src
			link = I
			to_chat(user, "You attach [I] to the doll.")
			update_targets()
	..()

/obj/item/voodoo/check_eye(mob/user as mob)
	if(loc != user)
		user.reset_perspective(null)
		user.unset_machine()

/obj/item/voodoo/attack_self(mob/user as mob)
	if(!target && possible.len)
		target = input(user, "Select your victim!", "Voodoo") as null|anything in possible
		return

	if(user.zone_sel.selecting == "chest")
		if(link)
			target = null
			link.loc = get_turf(src)
			to_chat(user, "<span class='notice'>You remove the [link] from the doll.</span>")
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
				user.reset_perspective(target)
				spawn(100)
					user.reset_perspective(null)
					user.unset_machine()
			if("r_leg","l_leg")
				to_chat(user, "<span class='notice'>You move the doll's legs around.</span>")
				var/turf/T = get_step(target,pick(cardinal))
				target.Move(T)
			if("r_arm","l_arm")
				//use active hand on random nearby mob
				var/list/nearby_mobs = list()
				for(var/mob/living/L in range(1,target))
					if(L!=target)
						nearby_mobs |= L
				if(nearby_mobs.len)
					var/mob/living/T = pick(nearby_mobs)
					log_game("[user][user.key] made [target][target.key] click on [T] with a voodoo doll.")
					target.ClickOn(T)
					GiveHint(target)
			if("head")
				to_chat(user, "<span class='notice'>You smack the doll's head with your hand.</span>")
				target.Dizzy(10)
				to_chat(target, "<span class='warning'>You suddenly feel as if your head was hit with a hammer!</span>")
				GiveHint(target,user)
		cooldown = world.time + cooldown_time

/obj/item/voodoo/proc/update_targets()
	possible = list()
	if(!link)
		return
	for(var/mob/living/carbon/human/H in GLOB.living_mob_list)
		if(md5(H.dna.uni_identity) in link.fingerprints)
			possible |= H

/obj/item/voodoo/proc/GiveHint(mob/victim,force=0)
	if(prob(50) || force)
		var/way = dir2text(get_dir(victim,get_turf(src)))
		to_chat(victim, "<span class='notice'>You feel a dark presence from [way]</span>")
	if(prob(20) || force)
		var/area/A = get_area(src)
		to_chat(victim, "<span class='notice'>You feel a dark presence from [A.name]</span>")

/obj/item/voodoo/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(target)
		target.adjust_fire_stacks(20)
		target.IgniteMob()
		GiveHint(target,1)
	return ..()

/obj/item/organ/internal/heart/cursed/wizard
	pump_delay = 60
	heal_brute = 25
	heal_burn = 25
	heal_oxy = 25
