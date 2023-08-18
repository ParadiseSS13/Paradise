/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 4 SECONDS
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	reflectability = REFLECTABILITY_ENERGY
	light_range = 2
	light_color = LIGHT_COLOR_DARKRED
	ricochets_max = 50	//Honk!
	ricochet_chance = 80

/obj/item/projectile/beam/laser


/obj/item/projectile/beam/laser/ik

/obj/item/projectile/beam/laser/ik/emp_act(severity)
	if(prob(40 / severity))
		range = 0

/obj/item/projectile/beam/laser/ik/on_range() //Should spark out of the gun. Theoretically, one could emp projectiles out of the air. However, its more practical to EMP the guns, rather than projectiles in flight
	do_sparks(1, 1, src)
	..()

/obj/item/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40

/obj/item/projectile/beam/practice
	name = "practice laser"
	damage = 0
	nodamage = 1
	log_override = TRUE

/obj/item/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 15
	tile_dropoff = 0.75
	irradiate = 30
	forcedodge = -1
	range = 15
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN

/obj/item/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 30
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_CYAN

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARKBLUE

/obj/item/projectile/beam/pulse/on_hit(atom/target, blocked = 0)
	if(isturf(target) || isstructure(target) || ismachinery(target))
		target.ex_act(2)
	..()

/obj/item/projectile/beam/pulse/shot
	damage = 40

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN

/obj/item/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/item/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = 'sound/weapons/tap.ogg'
	nodamage = 1
	damage = 0
	damage_type = STAMINA
	flag = "laser"
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	log_override = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARKBLUE

/obj/item/projectile/beam/lasertag/on_hit(atom/target, blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.adjustStaminaLoss(34)
	return 1

/obj/item/projectile/beam/lasertag/omni
	name = "laser tag beam"
	icon_state = "omnilaser"

/obj/item/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_DARKRED

/obj/item/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	light_color = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/immolator
	name = "immolation beam"

/obj/item/projectile/beam/immolator/strong
	name = "heavy immolation beam"
	damage = 45
	icon_state = "heavylaser"

/obj/item/projectile/beam/immolator/weak
	name = "light immolation beam"
	damage = 8
	icon_state = "scatterlaser"

/obj/item/projectile/beam/immolator/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()

/obj/item/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	armour_penetration_percentage = 100
	damage_type = BURN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PURPLE

/obj/item/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_DARKBLUE

/obj/item/projectile/beam/instakill/red
	icon_state = "red_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_DARKRED

/obj/item/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.visible_message("<span class='danger'>[L] explodes!</span>")
		L.gib()

/obj/item/projectile/beam/laser/detective
	name = "energy revolver shot"
	icon_state = "omnilaser"
	light_color = LIGHT_COLOR_CYAN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	damage = 5
	stamina = 25
	eyeblur = 2 SECONDS

/obj/item/projectile/beam/laser/detective/overcharged
	name = "overcharged shot"
	icon_state = "spark"
	light_color = LIGHT_COLOR_DARKRED
	color = LIGHT_COLOR_DARKRED
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	damage = 45
	stamina = 15
	eyeblur = 4 SECONDS

/obj/item/projectile/beam/laser/detective/tracker_warrant_shot
	name = "tracker shot"
	icon_state = "yellow_laser"
	light_color = LIGHT_COLOR_YELLOW
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser
	stamina = 0
	reflectability = REFLECTABILITY_PHYSICAL //No mr cult juggernaught, please don't set me to search!

/obj/item/projectile/beam/laser/detective/tracker_warrant_shot/on_hit(atom/target)
	. = ..()
	if(!ishuman(target))
		no_worky(target)
		return
	start_tracking(target)
	set_warrant(target)

/obj/item/projectile/beam/laser/detective/tracker_warrant_shot/proc/start_tracking(atom/target)
	var/obj/item/gun/energy/detective/D = firer_source_atom
	if(!D)
		no_worky(target)
		return
	if(D.tracking_target_UID)
		no_worky(tracking_already = TRUE)
		return
	D.start_pointing(target.UID())

/obj/item/projectile/beam/laser/detective/tracker_warrant_shot/proc/set_warrant(atom/target)
	var/mob/living/carbon/human/target_to_mark = target
	var/perpname = target_to_mark.get_visible_name(TRUE)
	if(!perpname || perpname == "Unknown")
		no_worky(target, warrant_fail = TRUE)
		return
	var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
	if(!R || (R.fields["criminal"] in list(SEC_RECORD_STATUS_EXECUTE, SEC_RECORD_STATUS_ARREST)))
		no_worky(target, warrant_fail = TRUE)
		return
	set_criminal_status(firer, R, SEC_RECORD_STATUS_SEARCH, "Target tagged by Detective Revolver", "Detective Revolver")

/obj/item/projectile/beam/laser/detective/tracker_warrant_shot/proc/no_worky(atom/target, tracking_already, warrant_fail)
	if(tracking_already)
		to_chat(firer, "<span class='danger'>Weapon Alert: You are already tracking a target!</span>")
		return
	if(warrant_fail)
		to_chat(firer, "<span class='danger'>Weapon Alert: unable to generate warrant on [target]!</span>")
		return
	to_chat(firer, "<span class='danger'>Weapon Alert: unable to track [target]!</span>")

/obj/item/projectile/beam/silencer
	name = "energy beam" //Keep it vague? It's not a laser, but it's silenced, does a person know what it is?
	icon_state = "omnilaser"
	stamina = 30
	damage = 15
	damage_type = OXY
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_CYAN
