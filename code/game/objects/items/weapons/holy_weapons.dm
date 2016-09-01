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
	var/reskin_selectable = TRUE			//set to FALSE if a subtype is meant to not normally be available as a reskin option (fluff ones will get re-added through their list)
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
	var/list/holy_weapons_list = typesof(/obj/item/weapon/nullrod)
	for(var/entry in holy_weapons_list)
		var/obj/item/weapon/nullrod/variant = entry
		if(!initial(variant.reskin_selectable))
			holy_weapons_list -= variant
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

/obj/item/weapon/nullrod/fluff		//fluff subtype to be used for all donator nullrods
	reskin_selectable = FALSE

/obj/item/weapon/nullrod/godhand
	name = "god hand"
	icon_state = "disintegrate"
	item_state = "disintegrate"
	desc = "This hand of yours glows with an awesome power!"
	flags = ABSTRACT | NODROP
	w_class = 5
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	attack_verb = list("punched", "cross countered", "pummeled")

/obj/item/weapon/nullrod/staff
	name = "red holy staff"
	icon_state = "godstaff-red"
	item_state = "godstaff-red"
	desc = "It has a mysterious, protective aura."
	w_class = 5
	force = 5
	slot_flags = SLOT_BACK
	block_chance = 50

/obj/item/weapon/nullrod/staff/blue
	name = "blue holy staff"
	icon_state = "godstaff-blue"
	item_state = "godstaff-blue"

/obj/item/weapon/nullrod/claymore
	name = "holy claymore"
	icon_state = "claymore"
	item_state = "claymore"
	desc = "A weapon fit for a crusade!"
	w_class = 4
	slot_flags = SLOT_BACK|SLOT_BELT
	block_chance = 30
	sharp = 1
	edge = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/nullrod/claymore/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/weapon/nullrod/claymore/darkblade
	name = "dark blade"
	icon_state = "cultblade"
	item_state = "cultblade"
	desc = "Spread the glory of the dark gods!"
	slot_flags = SLOT_BELT
	hitsound = 'sound/hallucinations/growl1.ogg'

/obj/item/weapon/nullrod/claymore/chainsaw_sword
	name = "sacred chainsaw sword"
	icon_state = "chainswordon"
	item_state = "chainswordon"
	desc = "Suffer not a heretic to live."
	slot_flags = SLOT_BELT
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsaw.ogg'

/obj/item/weapon/nullrod/claymore/glowing
	name = "force weapon"
	icon_state = "swordon"
	item_state = "swordon"
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
	name = "reaper scythe"
	icon_state = "scythe0"
	item_state = "scythe0"
	desc = "Ask not for whom the bell tolls..."
	w_class = 4
	armour_penetration = 35
	slot_flags = SLOT_BACK
	sharp = 1
	edge = 1
	attack_verb = list("chopped", "sliced", "cut", "reaped")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/nullrod/scythe/vibro
	name = "high frequency blade"
	icon_state = "hfrequency0"
	item_state = "hfrequency1"
	desc = "Bad references are the DNA of the soul."
	attack_verb = list("chopped", "sliced", "cut", "zandatsu'd")

/obj/item/weapon/nullrod/scythe/talking
	name = "possessed blade"
	icon_state = "talking_sword"
	item_state = "talking_sword"
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
		var/mob/living/simple_animal/shade/sword/S = new(src)
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
	for(var/mob/living/simple_animal/shade/sword/S in contents)
		to_chat(S, "You were destroyed!")
		S.ghostize()
		qdel(S)
	return ..()

/obj/item/weapon/nullrod/hammmer
	name = "relic war hammer"
	icon_state = "hammeron"
	item_state = "hammeron"
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
	name = "clown dagger"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "clownrender"
	item_state = "gold_horn"
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
	block_chance = 40
	slot_flags = SLOT_BACK
	sharp = 0
	edge = 0
	hitsound = "swing_hit"
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bostaff0"
	item_state = "bostaff0"

/obj/item/weapon/nullrod/tribal_knife
	name = "arrhythmic knife"
	icon_state = "crysknife"
	item_state = "crysknife"
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
	name = "unholy pitchfork"
	icon_state = "pitchfork0"
	item_state = "pitchfork0"
	w_class = 3
	desc = "Holding this makes you look absolutely devilish."
	attack_verb = list("poked", "impaled", "pierced", "jabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	edge = 1

/obj/item/weapon/nullrod/rosary
	name = "prayer beads"
	icon_state = "rosary"
	item_state = null
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

/obj/item/weapon/nullrod/missionary_staff
	name = "holy staff"
	desc = "It has a mysterious, protective aura."
	description_antag = "This seemingly standard holy staff is actually a disguised neurotransmitter capable of inducing blind zealotry in its victims. It must be allowed to recharge in the presence of a linked set of missionary robes. Activate the staff while wearing robes to link, then aim the staff at your victim to try and convert them."
	reskinned = TRUE
	reskin_selectable = FALSE
	icon_state = "godstaff-red"
	item_state = "godstaff-red"
	w_class = 5
	force = 5
	slot_flags = SLOT_BACK
	block_chance = 50

	var/team_color = "red"
	var/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe/robes = null		//the robes linked with this staff
	var/faith = 99	//a conversion requires 100 faith to attempt. faith recharges over time while you are wearing missionary robes that have been linked to the staff.

/obj/item/weapon/nullrod/missionary_staff/New()
	team_color = pick("red", "blue")
	icon_state = "godstaff-[team_color]"
	item_state = "godstaff-[team_color]"
	name = "[team_color] holy staff"

/obj/item/weapon/nullrod/missionary_staff/Destroy()
	if(robes)		//delink on destruction
		robes.linked_staff = null
		robes = null
	return ..()

/obj/item/weapon/nullrod/missionary_staff/attack_self(mob/user)
	if(robes)	//as long as it is linked, sec can't try to meta by stealing your staff and seeing if they get the link error message
		return 0
	if(!ishuman(user))		//prevents the horror (runtimes) of missionary xenos and other non-human mobs that might be able to activate the item
		return 0
	var/mob/living/carbon/human/missionary = user
	if(missionary.wear_suit && istype(missionary.wear_suit, /obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe))
		var/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe/robe_to_link = missionary.wear_suit
		if(robe_to_link.linked_staff)
			to_chat(missionary, "<span class='warning'>These robes are already linked with a staff and cannot support another. Connection refused.</span>")
			return 0
		robes = robe_to_link
		robes.linked_staff = src
		to_chat(missionary, "<span class='notice'>Link established. Faith generators initialized. Go spread the word.</span>")
		faith = 100		//full charge when a fresh link is made (can't be delinked without destroying the robes so this shouldn't be an exploitable thing)
		return 1
	else
		to_chat(missionary, "<span class='warning'>You must be wearing the missionary robes you wish to link with this staff.</span>")
		return 0

/obj/item/weapon/nullrod/missionary_staff/afterattack(mob/living/carbon/human/target, mob/living/carbon/human/missionary, flag, params)
	if(!istype(target) || !istype(missionary))		//ishuman checks effectively
		return
	if(target == missionary)	//you can't convert yourself, that would raise too many questions about your own dedication to the cause
		return
	if(!robes)		//staff must be linked to convert
		to_chat(missionary, "<span class='warning'>You must link your staff to a set of missionary robes before attempting conversions.</span>")
		return
	if(!missionary.wear_suit || missionary.wear_suit != robes)	//must be wearing the robes to convert
		return
	if(faith < 100)
		to_chat(missionary, "<span class='warning'>You don't have enough faith to attempt a conversion right now.</span>")
		return
	to_chat(missionary, "<span class='notice'>You concentrate on [target] and begin the conversion ritual...</span>")
	if(!target.mind)	//no mind means no conversion, but also means no faith lost.
		to_chat(missionary, "<span class='warning'>You halt the conversion as you realize [target] is mindless! Best to save your faith for someone more worthwhile.</span>")
		return
	if(do_after(missionary, 40))	//4 seconds to temporarily convert, roughly 1 second faster than a vampire's enthrall ability
		if(faith < 100)		//to stop people from trying to exploit the do_after system to multi-convert, we check again if you have enough faith when it completes
			to_chat(missionary, "<span class='warning'>You don't have enough faith to complete the conversion on [target]!</span>")
			return
		if(missionary in viewers(target))	//missionary must maintain line of sight to target, but the target doesn't necessary need to be able to see the missionary
			do_convert(target, missionary)
		else
			to_chat(missionary, "<span class='warning'>You lost sight of the target before they could be converted!</span>")
			faith -= 25		//they escaped, so you only lost a little faith (to prevent spamming)
	else	//the do_after failed, probably because you moved or dropped the staff
		to_chat(missionary, "<span class='warning'>Your concentration was broken!</span>")

/obj/item/weapon/nullrod/missionary_staff/proc/do_convert(mob/living/carbon/human/target, mob/living/carbon/human/missionary)
	var/convert_duration = 6000		//10 min
	if(!target || !istype(target) || !missionary || !istype(missionary))
		return
	if(ismindslave(target) || target.mind.zealot_master)	//mindslaves and zealots override the staff because the staff is just a temporary mindslave
		to_chat(missionary, "<span class='warning'>Your faith is strong, but their mind is already slaved to someone else's ideals. Perhaps an inquisition would reveal more...</span>")
		faith -= 25		//same faith cost as losing sight of them mid-conversion, but did you just find someone who can lead you to a fellow traitor?
		return
	if(isloyal(target))
		if(prob(20))	//loyalty implants typically overpower this, but you CAN get lucky and convert still (20% chance of success)
			faith -= 125	//yes, this puts it negative. it's gonna take longer to recharge if you manage to convert a one of these people to balance the new power you gained through them
			to_chat(missionary, "<span class='notice'>Through sheer willpower, you overcome their closed mind and rally [target] to your cause! You may need a bit longer than usual before your faith is fully recharged, and they won't remain loyal to you for long ...</span>")
			convert_duration = 3000		//5 min, because the loyalty implant will attempt to counteract the subversion
		else	//80% chance to fail
			faith -= 75
			to_chat(missionary, "<span class='warning'>Your faith is strong, but their mind remains closed to your ideals. Your resolve helps you retain a bit of faith though.</span>")
			return
	else if(target.mind.assigned_role == "Psychiatrist" || target.mind.assigned_role == "Librarian")		//fancy book lernin helps counter religion (day 0 job love, what madness!)
		if(prob(35))	//35% chance to fail
			to_chat(missionary, "<span class='warning'>This one is well trained in matters of the mind... They will not be swayed as easily as you thought...</span>")
			faith -=50		//lose half your faith to the book-readers
			return
		else
			to_chat(missionary, "<span class='notice'>You successfully convert [target] to your cause. The following grows because of your faith!</span>")
			faith -= 100
	else if(target.mind.assigned_role == "Civilian")
		if(prob(55))	//55% chance to take LESS faith than normal, because civies are stupid and easily manipulated
			to_chat(missionary, "<span class='notice'>Your message seems to resound well with [target]; converting them was much easier than expected.</span>")
			faith -= 50
		else		//45% chance to take the normal 100 faith cost
			to_chat(missionary, "<span class='notice'>You successfully convert [target] to your cause. The following grows because of your faith!</span>")
			faith -= 100
	else		//everyone else takes 100 faith cost because they are normal
		to_chat(missionary, "<span class='notice'>You successfully convert [target] to your cause. The following grows because of your faith!</span>")
		faith -= 100
	//if you made it this far: congratulations! you are now a religious zealot!
	target.mind.make_zealot(missionary, convert_duration, team_color)

	target << sound('sound/misc/wololo.ogg', 0, 1, 25)
	missionary.say("WOLOLO!")
	missionary << sound('sound/misc/wololo.ogg', 0, 1, 25)
