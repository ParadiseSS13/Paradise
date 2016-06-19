/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of Nar-Sie's followers."
	icon_state = "nullrod"
	item_state = "nullrod"
	force = 18
	throw_speed = 3
	throw_range = 4
	throwforce = 10
	w_class = 1
	var/reskinned = FALSE
	var/list/fluff_transformations = list() //does it have any special transformations only accessible to it? Should only be subtypes of /obj/item/weapon/nullrod

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is killing \himself with \the [src.name]! It looks like \he's trying to get closer to god!</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/nullrod/attack(mob/M, mob/living/carbon/user)
	..()
	if(M.mind)
		if(M.mind.vampire)
			if(ishuman(M))
				if(!M.mind.vampire.get_ability(/datum/vampire_passive/full))
					to_chat(M, "<span class='warning'>The nullrod's power interferes with your own!</span>")
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)

/obj/item/weapon/nullrod/attack_self(mob/user)
	if(reskinned)
		return
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		reskin_holy_weapon(user)

/obj/item/weapon/nullrod/proc/reskin_holy_weapon(mob/M)
	var/list/holy_weapons_list = typesof(/obj/item/weapon/nullrod) - typesof(/obj/item/weapon/nullrod/fluff)
	if(fluff_transformations.len)
		for(var/thing in fluff_transformations)
			holy_weapons_list += thing
	var/list/display_names = list()
	for(var/V in holy_weapons_list)
		var/atom/A = V
		display_names += initial(A.name)

	var/choice = input(M,"What theme would you like for your holy weapon?","Holy Weapon Theme") as null|anything in display_names
	if(!src || !choice || !in_range(M, src) || M.incapacitated() || reskinned)
		return

	var/index = display_names.Find(choice)
	var/A = holy_weapons_list[index]

	var/obj/item/weapon/nullrod/holy_weapon = new A

	feedback_set_details("chaplain_weapon","[choice]")

	if(holy_weapon)
		holy_weapon.reskinned = TRUE
		M.unEquip(src)
		M.put_in_active_hand(holy_weapon)
		qdel(src)

/obj/item/weapon/nullrod/godhand
	icon_state = "disintegrate"
	item_state = "disintegrate"
	name = "god hand"
	desc = "This hand of yours glows with an awesome power!"
	flags = ABSTRACT | NODROP
	w_class = 5
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	attack_verb = list("punched", "cross countered", "pummeled")

/obj/item/weapon/nullrod/staff
	icon_state = "godstaff-red"
	item_state = "godstaff-red"
	name = "red holy staff"
	desc = "It has a mysterious, protective aura."
	w_class = 5
	force = 5
	slot_flags = SLOT_BACK

/obj/item/weapon/nullrod/staff/IsShield()
	return 1

/obj/item/weapon/nullrod/staff/blue
	name = "blue holy staff"
	icon_state = "godstaff-blue"
	item_state = "godstaff-blue"

/obj/item/weapon/nullrod/claymore
	icon_state = "claymore"
	item_state = "claymore"
	name = "holy claymore"
	desc = "A weapon fit for a crusade!"
	w_class = 4
	slot_flags = SLOT_BACK|SLOT_BELT
	sharp = 1
	edge = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/nullrod/claymore/IsShield()
	if(prob(30))
		return 1
	else
		return 0

/obj/item/weapon/nullrod/claymore/darkblade
	icon_state = "cultblade"
	item_state = "cultblade"
	name = "dark blade"
	desc = "Spread the glory of the dark gods!"
	slot_flags = SLOT_BELT
	hitsound = 'sound/hallucinations/growl1.ogg'

/obj/item/weapon/nullrod/claymore/chainsaw_sword
	icon_state = "chainswordon"
	item_state = "chainswordon"
	name = "sacred chainsaw sword"
	desc = "Suffer not a heretic to live."
	slot_flags = SLOT_BELT
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsaw.ogg'

/obj/item/weapon/nullrod/claymore/glowing
	icon_state = "swordon"
	item_state = "swordon"
	name = "force weapon"
	desc = "The blade glows with the power of faith. Or possibly a battery."
	slot_flags = SLOT_BELT

/obj/item/weapon/nullrod/claymore/katana
	name = "hanzo steel"
	desc = "Capable of cutting clean through a holy claymore."
	icon_state = "katana"
	item_state = "katana"
	slot_flags = SLOT_BELT | SLOT_BACK

/obj/item/weapon/nullrod/claymore/multiverse
	name = "extradimensional blade"
	desc = "Once the harbringer of a interdimensional war, now a dormant souvenir. Still sharp though."
	icon_state = "multiverse"
	item_state = "multiverse"
	slot_flags = SLOT_BELT

/obj/item/weapon/nullrod/claymore/saber
	name = "light energy sword"
	hitsound = 'sound/weapons/blade1.ogg'
	icon_state = "swordblue"
	item_state = "swordblue"
	desc = "If you strike me down, I shall become more robust than you can possibly imagine."
	slot_flags = SLOT_BELT

/obj/item/weapon/nullrod/claymore/saber/red
	name = "dark energy sword"
	icon_state = "swordred"
	item_state = "swordred"
	desc = "Woefully ineffective when used on steep terrain."

/obj/item/weapon/nullrod/claymore/saber/pirate
	name = "nautical energy sword"
	icon_state = "cutlass1"
	item_state = "cutlass1"
	desc = "Convincing HR that your religion involved piracy was no mean feat."

/obj/item/weapon/nullrod/sord
	name = "\improper UNREAL SORD"
	desc = "This thing is so unspeakably HOLY you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	slot_flags = SLOT_BELT
	force = 4.13
	throwforce = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/nullrod/scythe
	icon_state = "scythe0"
	item_state = "scythe0"
	name = "reaper scythe"
	desc = "Ask not for whom the bell tolls..."
	w_class = 4
	armour_penetration = 35
	slot_flags = SLOT_BACK
	sharp = 1
	edge = 1
	attack_verb = list("chopped", "sliced", "cut", "reaped")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/nullrod/scythe/vibro
	icon_state = "hfrequency0"
	item_state = "hfrequency1"
	name = "high frequency blade"
	desc = "Bad references are the DNA of the soul."
	attack_verb = list("chopped", "sliced", "cut", "zandatsu'd")

/obj/item/weapon/nullrod/scythe/talking
	icon_state = "talking_sword"
	item_state = "talking_sword"
	name = "possessed blade"
	desc = "When the station falls into chaos, it's nice to have a friend by your side."
	attack_verb = list("chopped", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/possessed = FALSE

/obj/item/weapon/nullrod/scythe/talking/attack_self(mob/living/user)
	if(possessed)
		return

	to_chat(user, "You attempt to wake the spirit of the blade...")

	possessed = TRUE

	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as the spirit of [user.real_name]'s blade?", ROLE_PAI, 0, 100)
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		theghost = pick(candidates)
		var/mob/living/simple_animal/shade/S = new(src)
		S.real_name = name
		S.name = name
		S.ckey = theghost.ckey
		var/input = stripped_input(S,"What are you named?", ,"", MAX_NAME_LEN)

		if(src && input)
			name = input
			S.real_name = input
			S.name = input
	else
		to_chat(user, "The blade is dormant. Maybe you can try again later.")
		possessed = FALSE

/obj/item/weapon/nullrod/scythe/talking/Destroy()
	for(var/mob/living/simple_animal/shade/S in contents)
		to_chat(S, "You were destroyed!")
		S.ghostize()
		qdel(S)
	return ..()

/obj/item/weapon/nullrod/hammmer
	icon_state = "hammeron"
	item_state = "hammeron"
	name = "relic war hammer"
	desc = "This war hammer cost the chaplain fourty thousand space dollars."
	slot_flags = SLOT_BELT
	w_class = 5
	attack_verb = list("smashed", "bashed", "hammered", "crunched")

/obj/item/weapon/nullrod/chainsaw
	name = "chainsaw hand"
	desc = "Good? Bad? You're the guy with the chainsaw hand."
	icon_state = "chainsaw1"
	item_state = "mounted_chainsaw"
	w_class = 5
	flags = NODROP | ABSTRACT
	sharp = 1
	edge = 1
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsaw.ogg'

/obj/item/weapon/nullrod/clown
	icon = 'icons/obj/wizard.dmi'
	icon_state = "clownrender"
	item_state = "gold_horn"
	name = "clown dagger"
	desc = "Used for absolutely hilarious sacrifices."
	hitsound = 'sound/items/bikehorn.ogg'
	sharp = 1
	edge = 1
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut", "honked")

/obj/item/weapon/nullrod/whip
	name = "holy whip"
	desc = "What a terrible night to be on Space Station 13."
	icon_state = "chain"
	item_state = "chain"
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed")
	hitsound = 'sound/weapons/slash.ogg'

/obj/item/weapon/nullrod/whip/afterattack(atom/movable/AM, mob/user, proximity)
	if(!proximity)
		return
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(is_shadow(H))
			var/phrase = pick("Die monster! You don't belong in this world!!!", "You steal men's souls and make them your slaves!!!", "Your words are as empty as your soul!!!", "Mankind ill needs a savior such as you!!!")
			user.say("[phrase]")
			H.adjustBruteLoss(8) //Bonus damage

/obj/item/weapon/nullrod/fedora
	name = "athiest's fedora"
	desc = "The brim of the hat is as sharp as your wit. Throwing it at someone would hurt almost as much as disproving the existence of God."
	icon_state = "fedora"
	item_state = "fedora"
	slot_flags = SLOT_HEAD
	icon = 'icons/obj/clothing/hats.dmi'
	force = 0
	throw_speed = 4
	throw_range = 7
	throwforce = 20

/obj/item/weapon/nullrod/armblade
	name = "dark blessing"
	desc = "Particularly twisted deities grant gifts of dubious value."
	icon_state = "arm_blade"
	item_state = "arm_blade"
	flags = ABSTRACT | NODROP
	w_class = 5
	sharp = 1
	edge = 1

/obj/item/weapon/nullrod/carp
	name = "carp-sie plushie"
	desc = "An adorable stuffed toy that resembles the god of all carp. The teeth look pretty sharp. Activate it to recieve the blessing of Carp-Sie."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"
	item_state = "carp_plushie"
	force = 15
	attack_verb = list("bitten", "eaten", "fin slapped")
	hitsound = 'sound/weapons/bite.ogg'
	var/used_blessing = FALSE

/obj/item/weapon/nullrod/carp/attack_self(mob/living/user)
	if(used_blessing)
		return
	if(user.mind && (user.mind.assigned_role != "Chaplain"))
		return
	to_chat(user, "You are blessed by Carp-Sie. Wild space carp will no longer attack you.")
	user.faction |= "carp"
	used_blessing = TRUE

/obj/item/weapon/nullrod/claymore/bostaff //May as well make it a "claymore" and inherit the blocking
	name = "monk's staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts, now used to harass the clown."
	w_class = 4
	force = 15
	slot_flags = SLOT_BACK
	sharp = 0
	edge = 0
	hitsound = "swing_hit"
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bostaff0"
	item_state = "bostaff0"

/obj/item/weapon/nullrod/claymore/bostaff/IsShield()
	if(prob(40))
		return 1
	else
		return 0

/obj/item/weapon/nullrod/tribal_knife
	icon_state = "crysknife"
	item_state = "crysknife"
	name = "arrhythmic knife"
	w_class = 5
	desc = "They say fear is the true mind killer, but stabbing them in the head works too. Honour compels you to not sheathe it once drawn."
	sharp = 1
	edge = 1
	slot_flags = null
	flags = HANDSLOW
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/nullrod/tribal_knife/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/nullrod/tribal_knife/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/weapon/nullrod/tribal_knife/process()
	slowdown = rand(-2, 2)

/obj/item/weapon/nullrod/pitchfork
	icon_state = "pitchfork0"
	item_state = "pitchfork0"
	name = "unholy pitchfork"
	w_class = 3
	desc = "Holding this makes you look absolutely devilish."
	attack_verb = list("poked", "impaled", "pierced", "jabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	edge = 1

/obj/item/weapon/nullrod/rosary
	icon_state = "rosary"
	item_state = null
	name = "prayer beads"
	desc = "A set of prayer beads used by many of the more traditional religions in space.<br>Vampires and other unholy abominations have learned to fear these."
	force = 0
	throwforce = 0
	var/praying = 0

/obj/item/weapon/nullrod/rosary/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/nullrod/rosary/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(!user.mind || user.mind.assigned_role != "Chaplain")
		to_chat(user, "<span class='notice'>You are not close enough with [ticker.Bible_deity_name] to use [src].</span>")
		return

	if(praying)
		to_chat(user, "<span class='notice'>You are already using [src].</span>")

	user.visible_message("<span class='info'>[user] kneels[M == user ? null : " next to [M]"] and begins to utter a prayer to [ticker.Bible_deity_name].</span>", \
		"<span class='info'>You kneel[M == user ? null : " next to [M]"] and begin a prayer to [ticker.Bible_deity_name].</span>")

	praying = 1
	if(do_after(user, 150, target = M))
		if(istype(M, /mob/living/carbon/human)) // This probably should not work on vulps. They're unholy abominations.
			var/mob/living/carbon/human/target = M

			if(target.mind)
				if(iscultist(target))
					ticker.mode.remove_cultist(target.mind) // This proc will handle message generation.
					praying = 0
					return

				if(target.mind.vampire && !target.mind.vampire.get_ability(/datum/vampire_passive/full)) // Getting a full prayer off on a vampire will interrupt their powers for a large duration.
					target.mind.vampire.nullified = max(120, target.mind.vampire.nullified + 120)
					to_chat(target, "<span class='userdanger'>[user]'s prayer to [ticker.Bible_deity_name] has interfered with your power!</span>")
					praying = 0
					return

			if(prob(25))
				to_chat(target, "<span class='notice'>[user]'s prayer to [ticker.Bible_deity_name] has eased your pain!</span>")
				target.adjustToxLoss(-5)
				target.adjustOxyLoss(-5)
				target.adjustBruteLoss(-5)
				target.adjustFireLoss(-5)

			praying = 0

	else
		to_chat(user, "<span class='notice'>Your prayer to [ticker.Bible_deity_name] was interrupted.</span>")
		praying = 0

/obj/item/weapon/nullrod/rosary/process()
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/holder = loc

		if(src == holder.l_hand || src == holder.r_hand) // Holding this in your hand will
			for(var/mob/living/carbon/human/M in range(5))
				if(M.mind.vampire && !M.mind.vampire.get_ability(/datum/vampire_passive/full))
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
					if(prob(10))
						to_chat(M, "<span class='userdanger'>Being in the presence of [holder]'s [src] is interfering with your powers!</span>")



