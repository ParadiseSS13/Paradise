/obj/item/gun/magic/staff
	slot_flags = SLOT_BACK
	ammo_type = /obj/item/ammo_casing/magic
	flags_2 = NO_MAT_REDEMPTION_2

/obj/item/gun/magic/staff/change
	name = "staff of change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself"
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	item_state = "staffofchange"
	fire_sound = 'sound/magic/Staff_Change.ogg'

/obj/item/gun/magic/staff/animate
	name = "staff of animation"
	desc = "An artefact that spits bolts of life-force which causes objects which are hit by it to animate and come to life! This magic doesn't affect machines."
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	item_state = "staffofanimation"
	fire_sound = 'sound/magic/staff_animation.ogg'

/obj/item/gun/magic/staff/healing
	name = "staff of healing"
	desc = "An artefact that spits bolts of restoring magic which can remove ailments of all kinds and even raise the dead."
	ammo_type = /obj/item/ammo_casing/magic/heal
	icon_state = "staffofhealing"
	item_state = "staffofhealing"
	fire_sound = 'sound/magic/staff_healing.ogg'

/obj/item/gun/magic/staff/healing/handle_suicide() //Stops people trying to commit suicide to heal themselves
	return

/obj/item/gun/magic/staff/chaos
	name = "staff of chaos"
	desc = "An artefact that spits bolts of chaotic magic that can potentially do anything."
	ammo_type = /obj/item/ammo_casing/magic/chaos
	icon_state = "staffofchaos"
	item_state = "staffofchaos"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1
	fire_sound = 'sound/magic/staff_chaos.ogg'

/obj/item/gun/magic/staff/door
	name = "staff of door creation"
	desc = "An artefact that spits bolts of transformative magic that can create doors in walls."
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1
	fire_sound = 'sound/magic/staff_door.ogg'

/obj/item/gun/magic/staff/slipping
	name = "staff of slipping"
	desc = "An artefact that spits... bananas?"
	ammo_type = /obj/item/ammo_casing/magic/slipping
	icon_state = "staffofslipping"
	item_state = "staffofslipping"
	fire_sound = 'sound/items/bikehorn.ogg'

/obj/item/gun/magic/staff/slipping/honkmother
	name = "staff of the honkmother"
	desc = "An ancient artefact, sought after by clowns everywhere."
	fire_sound = 'sound/items/airhorn.ogg'

/obj/item/gun/magic/staff/focus
	name = "mental focus"
	desc = "An artefact that channels the will of the user into destructive bolts of force. If you aren't careful with it, you might poke someone's brain out."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "focus"
	item_state = "focus"
	ammo_type = /obj/item/ammo_casing/magic/forcebolt


//todo move it out of the staff folder

/obj/item/melee/spellblade
	name = "spellblade"
	desc = "An enchanted blade with a series of a runes along the side."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "spellblade"
	item_state = "spellblade"
	hitsound = 'sound/weapons/rapierhit.ogg'
	force = 25
	armour_penetration = 50
	block_chance = 50
	///enchantment holder, gives it unique on hit effects.
	var/datum/enchantment/enchant = null
	///the cooldown and power of enchantments are multiplied by this var when its applied
	var/power = 1

/obj/item/melee/spellblade/Destroy()
	QDEL_NULL(enchant)
	return ..()

/obj/item/melee/spellblade/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if(enchant)
		enchant.on_hit(M, user)

/obj/item/melee/spellblade/attack_self(mob/user)
	if(enchant)
		return

	var/list/options = list("Lightning", /*= image(),
							*/"Fire", /*= image(),
							"Bluespace" = image(),*/
							"Forcewall" /*= image(),*/)
	var/list/options_to_type = list("Lightning" = /datum/enchantment/lightning,
									"Fire" = /datum/enchantment/fire,
									/*"Bluespace" = /datum/enchantment/bluespace,*/
									"Forcewall" = /datum/enchantment/forcewall,)

	var/choice = show_radial_menu(user, src, options)
	add_enchantment(options_to_type[choice], user)

/obj/item/melee/spellblade/proc/add_enchantment(new_enchant, mob/living/user)
	var/datum/enchantment/E = new new_enchant
	enchant = E
	E.on_gain(src, user)
	E.power *= power

/obj/item/melee/spellblade/examine(mob/user)
	. = ..()
	if(enchant && (iswizard(user) || iscultist(user)))
		. += "The runes along the side read; [enchant.desc]."


/obj/item/melee/spellblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0
	return ..()

/datum/enchantment
	var/name = "You shouldn't be seeing this, file an issue report."
	var/desc = "Someone messed up, file an issue report."
	var/power = 0
	var/cooldown = -1

/datum/enchantment/proc/on_hit(mob/living/target, mob/living/user)
	if(world.time < cooldown)
		return
	cooldown = world.time + initial(cooldown)

/datum/enchantment/proc/on_gain(obj/item/melee/spellblade, mob/living/user)
	SSblackbox.record_feedback("nested tally", "spellblade_enchants", 1, list("[name]"))

/datum/enchantment/lightning
	name = "lightning"
	desc = "this blade conducts arcane energy to arc between its victims"
	power = 20
	cooldown = 3 SECONDS

/datum/enchantment/lightning/on_hit(mob/living/target, mob/living/user)
	..()
	zap(target, user, list(user), power)


/datum/enchantment/lightning/proc/zap(mob/living/target, mob/living/source, protected_mobs, voltage)
	source.Beam(target, "lightning[rand(1,12)]", 'icons/effects/effects.dmi', time = 2 SECONDS, maxdistance = 7, beam_type = /obj/effect/ebeam/chain)
	if(!target.electrocute_act(voltage, flags = SHOCK_TESLA)) // if it fails to shock someone, break the chain
		return
	protected_mobs += target
	addtimer(CALLBACK(src, .proc/arc, target, voltage, protected_mobs), 2.5 SECONDS)

/datum/enchantment/lightning/proc/arc(mob/living/source, voltage, protected_mobs)
	voltage = voltage - 4
	if(voltage <= 0)
		return

	for(var/mob/living/L in oview(7, get_turf(source)))
		if(L in protected_mobs)
			continue
		zap(L, source, protected_mobs, voltage)
		break

/datum/enchantment/fire
	name = "fire"
	desc = "this blade will self immolate on hit, releasing a ball of fire. it also makes the weilder immune to fire"
	power = 20
	cooldown = 8 SECONDS

/datum/enchantment/fire/on_gain(obj/item/melee/spellblade/S, mob/living/user)
	..()
	RegisterSignal(S, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED), .proc/toggle_traits)
	toggle_traits(S, user)

/datum/enchantment/fire/proc/toggle_traits(obj/item/I, mob/living/user)
	if(HAS_TRAIT_FROM(user, TRAIT_NOFIRE, MAGIC_TRAIT))
		REMOVE_TRAIT(user, TRAIT_NOFIRE, MAGIC_TRAIT)
		REMOVE_TRAIT(user, TRAIT_RESISTHEAT, MAGIC_TRAIT)
	else
		ADD_TRAIT(user, TRAIT_RESISTHEAT, MAGIC_TRAIT)
		ADD_TRAIT(user, TRAIT_NOFIRE, MAGIC_TRAIT)

/datum/enchantment/fire/on_hit(mob/living/target, mob/living/user)
	..()
	fireflash_s(target, 4, 6000 * power, 250)

/datum/enchantment/forcewall
	name = "forcewall"
	desc = "this blade will provide you great shielding against attack for a short duration after you strike someone"
	power = 20
	cooldown = 4 SECONDS

/datum/enchantment/forcewall/on_hit(mob/living/target, mob/living/user)
	..()
	user.apply_status_effect(STATUS_EFFECT_FORCESHIELD)
