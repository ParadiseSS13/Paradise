/obj/item/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon_state = "tome"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tome/New()
	if(!SSticker.mode)
		icon_state = "tome"
	else
		icon_state = SSticker.cultdat.tome_icon
	..()

/obj/item/melee/cultblade
	name = "cult blade"
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
		user.Dizzy(30)

	if(HULK in user.mutations)
		to_chat(user, "<span class='danger'>You can't seem to hold the blade properly!</span>")
		return FALSE

/obj/item/restraints/legcuffs/bola/cult
	name = "runed bola"
	desc = "A strong bola, bound with dark magic. Throw it to trip and slow your victim. Phases through fellow cultists."
	icon = 'icons/obj/items.dmi'
	icon_state = "bola_cult"
	breakouttime = 45
	weaken = 1

/obj/item/restraints/legcuffs/bola/cult/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(iscultist(hit_atom))
		hit_atom.visible_message("<span class='warning'>[src] bounces off of [hit_atom], as if repelled by an unseen force!</span>")
		return
	. = ..()

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
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/hooded/cultrobes/alt
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"
	hoodtype = /obj/item/clothing/head/hooded/culthood/alt

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
	allowed = list(/obj/item/tome,/obj/item/melee/cultblade, /obj/item/tank)
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
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie
	var/current_charges = 3
	var/shield_state = "shield-cult"
	var/shield_on = "shield-cult"

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
			shield_state = "broken"
			owner.update_inv_wear_suit()
		return TRUE
	return FALSE

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/special_overlays()
	return mutable_appearance('icons/effects/effects.dmi', shield_state, MOB_LAYER + 0.01)

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

/obj/item/clothing/glasses/hud/health/night/cultblind
	desc = "May the master guide you through the darkness and shield you from the light."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	item_state = "blindfold"
	see_in_dark = 8
	flash_protect = 1
	prescription = TRUE
	origin_tech = null

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
	icon = 'icons/obj/cult.dmi'
	icon_state ="shuttlecurse"
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
		command_announcement.Announce("[message]", "System Failure", 'sound/misc/notice1.ogg')

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
		step(src, pick(alldirs))
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

/obj/item/clothing/under/color/black/ghost
	flags = NODROP | DROPDEL

/datum/outfit/ghost_cultist
	name = "Cultist Ghost"

	uniform = /obj/item/clothing/under/color/black/ghost
	suit = /obj/item/clothing/suit/cultrobesghost
	shoes = /obj/item/clothing/shoes/cult/ghost
	head = /obj/item/clothing/head/hooded/culthood/alt/ghost
	r_hand = /obj/item/melee/cultblade/ghost

/obj/item/shield/mirror
	name = "mirror shield"
	desc = "An infamous shield used by eldritch sects to confuse and disorient their enemies. Its edges are weighted for use as a throwing weapon - capable of disabling multiple foes with preternatural accuracy."
	icon = 'icons/obj/cult.dmi'
	icon_state = "mirror_shield"
	item_state = "mirror_shield"
	force = 5
	throwforce = 15
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bumped", "prodded")
	hitsound = 'sound/weapons/smash.ogg'
	var/illusions = 2

/obj/item/shield/mirror/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(iscultist(owner))
		if(istype(hitby, /obj/item/projectile))
			var/obj/item/projectile/P = hitby
			if(P.damage_type == BRUTE || P.damage_type == BURN)
				if(P.damage >= 30)
					var/turf/T = get_turf(owner)
					T.visible_message("<span class='warning'>The sheer force from [P] shatters the mirror shield!</span>")
					new /obj/effect/temp_visual/cult/sparks(T)
					playsound(T, 'sound/effects/glassbr3.ogg', 100)
					owner.Weaken(2)
					qdel(src)
					return FALSE
			if(P.is_reflectable)
				return FALSE //To avoid reflection chance double-dipping with block chance
		. = ..()
		if(.)
			playsound(src, 'sound/weapons/parry.ogg', 100, TRUE)
			if(illusions > 0)
				illusions--
				addtimer(CALLBACK(src, /obj/item/shield/mirror.proc/readd), 450)
				if(prob(60))
					var/mob/living/simple_animal/hostile/illusion/M = new(owner.loc)
					M.faction = list("cult")
					M.Copy_Parent(owner, 70, 10, 5)
					//M.move_to_delay = owner.cached_multiplicative_slowdown
				else
					var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
					E.Copy_Parent(owner, 70, 10)
					E.GiveTarget(owner)
					E.Goto(owner, E.move_to_delay, E.minimum_distance)
			return TRUE
	else
		if(prob(50))
			var/mob/living/simple_animal/hostile/illusion/H = new(owner.loc)
			H.Copy_Parent(owner, 100, 20, 5)
			H.faction = list("cult")
			H.GiveTarget(owner)
		//	H.move_to_delay = owner.cached_multiplicative_slowdown
			to_chat(owner, "<span class='danger'><b>[src] betrays you!</b></span>")
		return FALSE

/obj/item/shield/mirror/proc/readd()
	illusions++
	if(illusions == initial(illusions) && isliving(loc))
		var/mob/living/holder = loc
		to_chat(holder, "<span class='cult italic'>The shield's illusions are back at full strength!</span>")

/obj/item/shield/mirror/IsReflect()
	if(prob(block_chance))
		return TRUE
	return FALSE

/obj/item/shield/mirror/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	var/datum/thrownthing/D = throwingdatum
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(iscultist(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(!L.restrained() && L.put_in_active_hand(src))
				L.visible_message("<span class='warning'>[L] catches [src] out of the air!</span>")
			else
				L.visible_message("<span class='warning'>[src] bounces off of [L], as if repelled by an unseen force!</span>")
		else if(!..())
			if(!L.null_rod_check())
				L.Weaken(1)
				if(D?.thrower)
					for(var/mob/living/Next in orange(2, T))
						if(!Next.density || iscultist(Next))
							continue
						throw_at(Next, 3, 1, D.thrower)
						return
					throw_at(D.thrower, 7, 1, null)
	else
		..()


/obj/item/twohanded/cult_spear
	name = "blood halberd"
	desc = "A sickening spear composed entirely of crystallized blood."
	icon = 'icons/obj/cult.dmi'
	icon_state = "bloodspear0"
	slot_flags = 0
	force = 17
	force_unwielded = 17
	force_wielded = 24
	throwforce = 40
	throw_speed = 2
	armour_penetration = 30
	block_chance = 30
	attack_verb = list("attacked", "impaled", "stabbed", "torn", "gored")
	sharp = TRUE
	no_spin_thrown = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/datum/action/innate/cult/spear/spear_act

/obj/item/twohanded/cult_spear/Destroy()
	if(spear_act)
		qdel(spear_act)
	..()

/obj/item/twohanded/cult_spear/update_icon()
	icon_state = "bloodspear[wielded]"

/obj/item/twohanded/cult_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(iscultist(L))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			if(!L.restrained() && L.put_in_active_hand(src))
				L.visible_message("<span class='warning'>[L] catches [src] out of the air!</span>")
			else
				L.visible_message("<span class='warning'>[src] bounces off of [L], as if repelled by an unseen force!</span>")
		else if(!..())
			if(!L.null_rod_check())
				L.Weaken(3)
			break_spear(T)
	else
		..()

/obj/item/twohanded/cult_spear/proc/break_spear(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T)
			T.visible_message("<span class='warning'>[src] shatters and melts back into blood!</span>")
			new /obj/effect/temp_visual/cult/sparks(T)
			new /obj/effect/decal/cleanable/blood/splatter(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
	qdel(src)

/obj/item/twohanded/cult_spear/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		final_block_chance *= 2
	if(prob(final_block_chance))
		if(attack_type == PROJECTILE_ATTACK)
			owner.visible_message("<span class='danger'>[owner] deflects [attack_text] with [src]!</span>")
			playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, TRUE)
			return TRUE
		else
			playsound(src, 'sound/weapons/parry.ogg', 100, TRUE)
			owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
			return TRUE
	return FALSE

/datum/action/innate/cult/spear
	name = "Bloody Bond"
	desc = "Call the blood spear back to your hand!"
	background_icon_state = "bg_cult"
	button_icon_state = "bloodspear"
	var/obj/item/twohanded/cult_spear/spear
	var/cooldown = 0

/datum/action/innate/cult/spear/Grant(mob/user, obj/blood_spear)
	. = ..()
	spear = blood_spear

/datum/action/innate/cult/spear/Activate()
	if(owner == spear.loc || cooldown > world.time)
		return
	var/ST = get_turf(spear)
	var/OT = get_turf(owner)
	if(get_dist(OT, ST) > 10)
		to_chat(owner,"<span class='cult'>The spear is too far away!</span>")
	else
		cooldown = world.time + 20
		if(isliving(spear.loc))
			var/mob/living/L = spear.loc
			L.unEquip(spear)
			L.visible_message("<span class='warning'>An unseen force pulls the blood spear from [L]'s hands!</span>")
		spear.throw_at(owner, 10, 2, null)

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/blood
	name = "blood bolt barrage"
	desc = "Blood for blood."
	color = "#ff0000"
	guns_left = 24
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	fire_sound = 'sound/magic/wand_teleport.ogg'
	flags = NOBLUDGEON | DROPDEL

/obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage/blood
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/blood

/obj/item/ammo_casing/magic/arcane_barrage/blood
	projectile_type = /obj/item/projectile/magic/arcane_barrage/blood

/obj/item/projectile/magic/arcane_barrage/blood
	name = "blood bolt"
	icon_state = "blood_bolt"
	damage_type = BRUTE
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter
	hitsound = 'sound/effects/splat.ogg'