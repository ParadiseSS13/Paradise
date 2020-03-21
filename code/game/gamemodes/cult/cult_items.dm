/obj/item/melee/cultblade
	name = "Cult Blade"
	desc = "An arcane weapon wielded by the followers of a cult."
	icon_state = "cultblade"
	item_state = "cultblade"
	w_class = WEIGHT_CLASS_BULKY
	force = 30
	throwforce = 10
	sharp = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")


/obj/item/melee/cultblade/attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
	if(!iscultist(user))
		user.Weaken(5)
		user.unEquip(src, 1)
		user.visible_message("<span class='warning'>A powerful force shoves [user] away from [target]!</span>", \
							 "<span class='cultlarge'>\"You shouldn't play with sharp things. You'll poke someone's eye out.\"</span>")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick("l_arm", "r_arm"))
		else
			user.adjustBruteLoss(rand(force/2,force))
		return
	..()

/obj/item/melee/cultblade/pickup(mob/living/user)
	. = ..()
	if(!iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
		to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
		user.Dizzy(120)

	if(HULK in user.mutations)
		to_chat(user, "<span class='danger'>You can't seem to hold the blade properly!</span>")
		return FALSE

/obj/item/melee/cultblade/dagger
	name = "sacrificial dagger"
	desc = "A strange dagger said to be used by sinister groups for \"preparing\" a corpse before sacrificing it to their dark gods."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	w_class = WEIGHT_CLASS_SMALL
	force = 15
	throwforce = 25
	embed_chance = 75

/obj/item/melee/cultblade/dagger/attack(atom/target, mob/living/carbon/human/user)
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if((H.stat != DEAD) && !(NO_BLOOD in H.dna.species.species_traits))
			H.bleed(50)

/obj/item/restraints/legcuffs/bola/cult
	name = "runed bola"
	desc = "A strong bola, bound with dark magic. Throw it to trip and slow your victim."
	icon = 'icons/obj/items.dmi'
	icon_state = "bola_cult"
	breakouttime = 45
	weaken = 1

/obj/item/clothing/head/hooded/culthood
	name = "cult hood"
	icon_state = "culthood"
	desc = "A hood worn by the followers of a cult."
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 10, acid = 10)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT


/obj/item/clothing/head/hooded/culthood/alt
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"


/obj/item/clothing/suit/hooded/cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of a cult."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/culthood
	allowed = list(/obj/item/tome,/obj/item/melee/cultblade)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/hooded/cultrobes/alt
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"
	hoodtype = /obj/item/clothing/head/hooded/culthood/alt

/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar-Sie."
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	armor = list("melee" = 50, "bullet" = 30, "laser" = 50, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie"
	icon_state = "magusred"
	item_state = "magusred"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/tome,/obj/item/melee/cultblade)
	armor = list("melee" = 50, "bullet" = 30, "laser" = 50, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/head/helmet/space/cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of a cult."
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list("melee" = 70, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 75)

/obj/item/clothing/suit/space/cult
	name = "cult armor"
	icon_state = "cult_armour"
	item_state = "cult_armour"
	desc = "A bulky suit of armor, bristling with spikes. It looks space proof."
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/tome,/obj/item/melee/cultblade,/obj/item/tank)
	slowdown = 1
	armor = list("melee" = 70, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 75)

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist robe"
	desc = "Empowered garb which creates a powerful shield around the user."
	icon_state = "cult_armour"
	item_state = "cult_armour"
	w_class = WEIGHT_CLASS_BULKY
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50, "energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 50, "acid" = 60)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/tome,/obj/item/melee/cultblade)
	var/current_charges = 3
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie

/obj/item/clothing/head/hooded/cult_hoodie
	name = "empowered cultist robe"
	desc = "Empowered garb which creates a powerful shield around the user."
	icon_state = "cult_hoodalt"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40,"energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	body_parts_covered = HEAD
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"I wouldn't advise that.\"</span>")
		to_chat(user, "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>")
		user.unEquip(src, 1)
		user.Dizzy(30)
		user.Weaken(5)

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(current_charges)
		owner.visible_message("<span class='danger'>\The [attack_text] is deflected in a burst of blood-red sparks!</span>")
		current_charges--
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		if(!current_charges)
			owner.visible_message("<span class='danger'>The runed shield around [owner] suddenly disappears!</span>")
			owner.update_inv_wear_suit()
		return 1
	return 0

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "hardsuit-berserker"
	item_state = "hardsuit-berserker"
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/tome,/obj/item/melee/cultblade)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list("melee" = -45, "bullet" = -45, "laser" = -45,"energy" = -45, "bomb" = -45, "bio" = -45, "rad" = -45, "fire" = 0, "acid" = 0)
	slowdown = -1
	hoodtype = /obj/item/clothing/head/hooded/berserkerhood


/obj/item/clothing/head/hooded/berserkerhood
	name = "flagellant's robes"
	desc = "Blood-soaked garb infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "culthood"
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/whetstone/cult
	name = "eldritch whetstone"
	desc = "A block, empowered by dark magic. Sharp weapons will be enhanced when used on the stone."
	icon_state = "cult_sharpener"
	used = 0
	increment = 5
	max = 40
	prefix = "darkened"
	claw_damage_increase = 4

/obj/item/whetstone/cult/update_icon()
	icon_state = "cult_sharpener[used ? "_used" : ""]"

/obj/item/reagent_containers/food/drinks/bottle/unholywater
	name = "flask of unholy water"
	desc = "Toxic to nonbelievers; this water renews and reinvigorates the faithful of a cult."
	icon_state = "holyflask"
	color = "#333333"
	list_reagents = list("unholywater" = 40)

/obj/item/clothing/glasses/night/cultblind
	desc = "May the master guide you through the darkness and shield you from the light."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	item_state = "blindfold"
	see_in_dark = 8
	flash_protect = 1

/obj/item/clothing/glasses/night/cultblind/equipped(mob/user, slot)
	..()
	if(!iscultist(user))
		to_chat(user, "<span class='cultlarge'>\"You want to be blind, do you?\"</span>")
		user.unEquip(src, 1)
		user.Dizzy(30)
		user.Weaken(5)
		user.EyeBlind(30)

/obj/item/shuttle_curse
	name = "cursed orb"
	desc = "You peer within this smokey orb and glimpse terrible fates befalling the escape shuttle."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	color = "#ff0000"
	var/global/curselimit = 0

/obj/item/shuttle_curse/attack_self(mob/user)
	if(!iscultist(user))
		user.unEquip(src, 1)
		user.Weaken(5)
		to_chat(user, "<span class='warning'>A powerful force shoves you away from [src]!</span>")
		return
	if(curselimit > 1)
		to_chat(user, "<span class='notice'>We have exhausted our ability to curse the shuttle.</span>")
		return
	if(locate(/obj/singularity/narsie) in GLOB.poi_list || locate(/mob/living/simple_animal/slaughter/cult) in GLOB.mob_list)
		to_chat(user, "<span class='warning'>Nar-Sie or his avatars are already on this plane, there is no delaying the end of all things.</span>")
		return

	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/cursetime = 1800
		var/timer = SSshuttle.emergency.timeLeft(1) + cursetime
		SSshuttle.emergency.setTimer(timer)
		to_chat(user,"<span class='danger'>You shatter the orb! A dark essence spirals into the air, then disappears.</span>")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 50, 1)
		curselimit++
		qdel(src)
		sleep(20)
		var/global/list/curses
		if(!curses)
			curses = list("A fuel technician just slit his own throat and begged for death. The shuttle will be delayed by two minutes.",
			"The shuttle's navigation programming was replaced by a file containing two words, IT COMES. The shuttle will be delayed by two minutes.",
			"The shuttle's custodian tore out his guts and began painting strange shapes on the floor. The shuttle will be delayed by two minutes.",
			"A shuttle engineer began screaming 'DEATH IS NOT THE END' and ripped out wires until an arc flash seared off her flesh. The shuttle will be delayed by two minutes.",
			"A shuttle inspector started laughing madly over the radio and then threw herself into an engine turbine. The shuttle will be delayed by two minutes.",
			"The shuttle dispatcher was found dead with bloody symbols carved into their flesh. The shuttle will be delayed by two minutes.",
			"Steve repeatedly touched a lightbulb until his hands fell off. The shuttle will be delayed by two minutes.")
		var/message = pick(curses)
		GLOB.command_announcement.Announce("[message]", "System Failure", 'sound/misc/notice1.ogg')

/obj/item/cult_shift
	name = "veil shifter"
	desc = "This relic teleports you forward a medium distance."
	icon = 'icons/obj/cult.dmi'
	icon_state ="shifter"
	var/uses = 4

/obj/item/cult_shift/examine(mob/user)
	. = ..()
	if(uses)
		. += "<span class='cult'>It has [uses] uses remaining.</span>"
	else
		. += "<span class='cult'>It seems drained.</span>"

/obj/item/cult_shift/proc/handle_teleport_grab(turf/T, mob/user)
	var/mob/living/carbon/C = user
	if(C.pulling)
		var/atom/movable/pulled = C.pulling
		pulled.forceMove(T)
		. = pulled

/obj/item/cult_shift/attack_self(mob/user)
	if(!uses || !iscarbon(user))
		to_chat(user, "<span class='warning'>\The [src] is dull and unmoving in your hands.</span>")
		return
	if(!iscultist(user))
		user.unEquip(src, 1)
		step(src, pick(GLOB.alldirs))
		to_chat(user, "<span class='warning'>\The [src] flickers out of your hands, too eager to move!</span>")
		return

	var/outer_tele_radius = 9

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/list/turfs = new/list()
	for(var/turf/T in range(user, outer_tele_radius))
		if(!is_teleport_allowed(T.z))
			continue
		if(get_dir(C, T) != C.dir)
			continue
		if(T == mobloc)
			continue
		if(istype(T, /turf/space))
			continue
		if(T.x > world.maxx-outer_tele_radius || T.x < outer_tele_radius)
			continue	//putting them at the edge is dumb
		if(T.y > world.maxy-outer_tele_radius || T.y < outer_tele_radius)
			continue

		turfs += T

	if(turfs)
		uses--
		var/turf/destination = pick(turfs)
		if(uses <= 0)
			icon_state ="shifter_drained"
		playsound(mobloc, "sparks", 50, 1)
		new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, C.dir)

		var/atom/movable/pulled = handle_teleport_grab(destination, C)
		C.forceMove(destination)
		if(pulled)
			C.start_pulling(pulled) //forcemove resets pulls, so we need to re-pull

		new /obj/effect/temp_visual/dir_setting/cult/phase(destination, C.dir)
		playsound(destination, 'sound/effects/phasein.ogg', 25, 1)
		playsound(destination, "sparks", 50, 1)

	else
		to_chat(C, "<span class='danger'>The veil cannot be torn here!</span>")

/obj/item/melee/cultblade/ghost
	name = "eldritch sword"
	force = 15
	flags = NODROP | DROPDEL

/obj/item/clothing/head/hooded/culthood/alt/ghost
	flags = NODROP | DROPDEL

/obj/item/clothing/suit/cultrobesghost
	name = "ghostly cult robes"
	desc = "A set of ethreal armored robes worn by the undead followers of a cult."
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/tome,/obj/item/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50, energy = 20, bomb = 25, bio = 10, rad = 0, fire = 10, acid = 10)
	flags_inv = HIDEJUMPSUIT

	flags = NODROP | DROPDEL


/obj/item/clothing/shoes/cult/ghost
	flags = NODROP | DROPDEL

/datum/outfit/ghost_cultist
	name = "Cultist Ghost"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/cultrobesghost
	shoes = /obj/item/clothing/shoes/cult/ghost
	head = /obj/item/clothing/head/hooded/culthood/alt/ghost
	r_hand = /obj/item/melee/cultblade/ghost
