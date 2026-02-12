/datum/action/cooldown/mob_cooldown/hostile_mech
	button_icon = 'icons/mecha/mecha_equipment.dmi'
	button_icon_state = "mecha_uac2"

/datum/action/cooldown/mob_cooldown/hostile_mech/launcher
	name = "launch"
	button_icon_state = "mecha_missilerack_six"
	desc = ABSTRACT_TYPE_DESC
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 6 SECONDS
	shared_cooldown = NONE
	var/obj/projectile/projectile

/datum/action/cooldown/mob_cooldown/hostile_mech/launcher/Activate(atom/target)
	. = ..()
	var/mob/living/basic/hostile_mech/mech = owner
	if(!istype(mech))
		return

	mech.shoot_projectile(target, projectile)
	playsound(get_turf(mech), 'sound/effects/bang.ogg', 100, TRUE)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/hostile_mech/bola_launcher
	name = "Bola Launcher"
	desc = "Fire a bola at the target."
	button_icon = "mecha_bola"
	cooldown_time = 20 SECONDS

/datum/action/cooldown/mob_cooldown/hostile_mech/bola_launcher/Activate(atom/target)
	. = ..()
	var/mob/living/basic/hostile_mech/mech = owner
	if(!istype(mech))
		return

	var/obj/item/restraints/legcuffs/bola/bola = new /obj/item/restraints/legcuffs/bola(mech.loc)
	bola.throw_at(target, 7, 1)
	playsound(get_turf(mech), 'sound/weapons/whip.ogg', 100, TRUE)
	StartCooldown()
