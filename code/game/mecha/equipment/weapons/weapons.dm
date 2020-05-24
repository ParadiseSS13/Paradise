/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = MECHA_RANGED
	origin_tech = "materials=3;combat=3"
	var/projectile
	var/fire_sound
	var/size=0
	var/projectiles_per_shot = 1
	var/variance = 0
	var/randomspread = 0 //use random spread for machineguns, instead of shotgun scatter
	var/projectile_delay = 0
	var/projectiles
	var/projectile_energy_cost

/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(var/obj/mecha/combat/M as obj)
	if(..())
		if(istype(M))
			if(size > M.maxsize)
				return 0
			return 1
		else if(M.emagged == 1)
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/proc/get_shot_amount()
	return projectiles_per_shot

/obj/item/mecha_parts/mecha_equipment/weapon/action(target, params)
	if(!action_checks(target))
		return 0

	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)
	if(!targloc || !istype(targloc) || !curloc)
		return 0
	if(targloc == curloc)
		return 0

	set_ready_state(0)
	for(var/i=1 to get_shot_amount())
		var/obj/item/projectile/A = new projectile(curloc)
		A.firer = chassis.occupant
		A.original = target
		A.current = curloc

		var/spread = 0
		if(variance)
			if(randomspread)
				spread = round((rand() - 0.5) * variance)
			else
				spread = round((i / projectiles_per_shot - 0.5) * variance)
		A.preparePixelProjectile(target, targloc, chassis.occupant, params, spread)

		chassis.use_power(energy_drain)
		projectiles--
		A.fire()
		playsound(chassis, fire_sound, 50, 1)

		sleep(max(0, projectile_delay))
	set_ready_state(0)
	log_message("Fired from [name], targeting [target].")
	var/turf/T = get_turf(src)
	msg_admin_attack("[key_name_admin(chassis.occupant)] fired a [src] in ([T.x], [T.y], [T.z] - [ADMIN_JMP(T)])")
	log_game("[key_name(chassis.occupant)] fired a [src] in [T.x], [T.y], [T.z]")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "General Energy Weapon"
	size = 2

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	equip_cooldown = 8
	name = "CH-PS \"Firedart\" Laser"
	icon_state = "mecha_laser"
	origin_tech = "magnets=3;combat=3;engineering=3"
	energy_drain = 30
	projectile = /obj/item/projectile/beam
	fire_sound = 'sound/weapons/laser.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler
	name = "CH-PD Disabler"
	origin_tech = "combat=3"
	projectile = /obj/item/projectile/beam/disabler
	projectiles_per_shot = 2
	projectile_delay = 1
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	equip_cooldown = 10
	name = "CH-LC \"Solaris\" Laser Cannon"
	icon_state = "mecha_laser"
	origin_tech = "magnets=4;combat=4;engineering=3"
	energy_drain = 60
	projectile = /obj/item/projectile/beam/laser/heavylaser
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	equip_cooldown = 40
	name = "mkIV Ion Heavy Cannon"
	icon_state = "mecha_ion"
	origin_tech = "materials=4;combat=5;magnets=4"
	energy_drain = 120
	projectile = /obj/item/projectile/ion
	fire_sound = 'sound/weapons/laser.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	equip_cooldown = 35
	name = "P-X Tesla Cannon"
	desc = "A weapon for combat exosuits. Fires bolts of electricity similar to the experimental tesla engine"
	icon_state = "mecha_laser"
	origin_tech = "materials=4;engineering=4;combat=6;magnets=6"
	energy_drain = 500
	projectile = /obj/item/projectile/energy/shock_revolver
	fire_sound = 'sound/magic/lightningbolt.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray
	equip_cooldown = 35
	name = "S-1 X-Ray Projector"
	desc = "A weapon for combat exosuits. Fires beams of X-Rays that pass through solid matter."
	icon_state = "mecha_laser"
	origin_tech = "materials=3;combat=5;magnets=2;syndicate=2"
	energy_drain = 80
	projectile = /obj/item/projectile/beam/xray
	fire_sound = 'sound/weapons/laser3.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray/triple
	name = "X-XR Triple-barrel X-Ray Stream Projector"
	projectiles_per_shot = 3
	projectile_delay = 1

/obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator
	equip_cooldown = 35
	name = "ZFI Immolation Beam Gun"
	desc = "A weapon for combat exosuits. Fires beams of extreme heat that set targets on fire."
	icon_state = "mecha_laser"
	origin_tech = "materials=4;engineering=4;combat=6;magnets=6"
	energy_drain = 80
	projectile = /obj/item/projectile/beam/immolator
	fire_sound = 'sound/weapons/laser3.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	equip_cooldown = 30
	name = "eZ-13 mk2 Heavy pulse rifle"
	icon_state = "mecha_pulse"
	energy_drain = 120
	origin_tech = "materials=3;combat=6;powerstorage=4"
	projectile = /obj/item/projectile/beam/pulse/heavy
	fire_sound = 'sound/weapons/marauder.ogg'
	harmful = TRUE


/obj/item/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20

/obj/item/projectile/beam/pulse/heavy/Bump(atom/A)
	A.bullet_act(src, def_zone)
	life -= 10
	if(ismob(A))
		var/mob/M = A
		if(istype(firer, /mob))
			add_attack_logs(firer, M, "Mecha-shot with <b>[src]</b>")
			if(!iscarbon(firer))
				M.LAssailant = null
			else
				M.LAssailant = firer
		else
			add_attack_logs(null, M, "Mecha-shot with <b>[src]</b>")
	if(life <= 0)
		qdel(src)
	return


/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	name = "PBT \"Pacifier\" Mounted Taser"
	icon_state = "mecha_taser"
	origin_tech = "combat=3"
	energy_drain = 20
	equip_cooldown = 8
	projectile = /obj/item/projectile/energy/electrode
	fire_sound = 'sound/weapons/taser.ogg'
	size = 1

/obj/item/mecha_parts/mecha_equipment/weapon/honker
	name = "HoNkER BlAsT 5000"
	icon_state = "mecha_honker"
	energy_drain = 200
	equip_cooldown = 150
	range = MECHA_MELEE | MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/weapon/honker/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/honker/action(target, params)
	if(!chassis)
		return 0
	if(energy_drain && chassis.get_charge() < energy_drain)
		return 0
	if(!equip_ready)
		return 0

	playsound(chassis, 'sound/items/airhorn.ogg', 100, 1)
	chassis.occupant_message("<font color='red' size='5'>HONK</font>")
	for(var/mob/living/carbon/M in ohearers(6, chassis))
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
				continue
		to_chat(M, "<font color='red' size='7'>HONK</font>")
		M.SetSleeping(0)
		M.Stuttering(20)
		M.MinimumDeafTicks(30)
		M.Weaken(3)
		if(prob(30))
			M.Stun(10)
			M.Paralyse(4)
		else
			M.Jitter(500)
		///else the mousetraps are useless
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(isobj(H.shoes))
				var/thingy = H.shoes
				H.unEquip(H.shoes)
				walk_away(thingy,chassis,15,2)
				spawn(20)
					if(thingy)
						walk(thingy,0)
	for(var/obj/mecha/combat/reticence/R in oview(6, chassis))
		R.occupant_message("\The [R] has protected you from [chassis]'s HONK at the cost of some power.")
		R.use_power(R.get_charge() / 4)

	chassis.use_power(energy_drain)
	log_message("Honked from [name]. HONK!")
	var/turf/T = get_turf(src)
	msg_admin_attack("[key_name_admin(chassis.occupant)] used a Mecha Honker in ([T.x], [T.y], [T.z] - [ADMIN_JMP(T)])")
	log_game("[key_name(chassis.occupant)] used a Mecha Honker in [T.x], [T.y], [T.z]")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "General Ballisic Weapon"
	size = 2
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(atom/target)
	if(..())
		if(projectiles > 0)
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_equip_info()
	return "[..()]\[[projectiles]\][(projectiles < initial(projectiles))?" - <a href='?src=[UID()];rearm=1'>Rearm</a>":null]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/rearm()
	if(projectiles < initial(projectiles))
		var/projectiles_to_add = initial(projectiles) - projectiles
		while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
			projectiles++
			projectiles_to_add--
			chassis.use_power(projectile_energy_cost)
	send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
	log_message("Rearmed [name].")
	playsound(src, 'sound/weapons/gun_interactions/rearm.ogg', 50, 1)
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/Topic(href, href_list)
	..()
	if(href_list["rearm"])
		rearm()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	name = "FNX-66 Carbine"
	icon_state = "mecha_carbine"
	origin_tech = "materials=4;combat=4"
	equip_cooldown = 5
	projectile = /obj/item/projectile/bullet/incendiary/shell/dragonsbreath
	fire_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	projectiles = 24
	projectile_energy_cost = 15
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced
	name = "\improper S.H.H. \"Quietus\" Carbine"
	fire_sound = 'sound/weapons/gunshots/gunshot_silenced.ogg'
	icon_state = "mecha_mime"
	equip_cooldown = 15
	projectile = /obj/item/projectile/bullet/mime
	projectiles = 20
	projectile_energy_cost = 50

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced/can_attach(obj/mecha/combat/reticence/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "LBX AC 10 \"Scattershot\""
	icon_state = "mecha_scatter"
	origin_tech = "combat=4"
	equip_cooldown = 20
	projectile = /obj/item/projectile/bullet/midbullet
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	projectiles = 40
	projectile_energy_cost = 25
	projectiles_per_shot = 4
	variance = 25
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	name = "Ultra AC 2"
	icon_state = "mecha_uac2"
	origin_tech = "combat=4"
	equip_cooldown = 10
	projectile = /obj/item/projectile/bullet/weakbullet3
	fire_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	projectiles = 300
	projectile_energy_cost = 20
	projectiles_per_shot = 3
	variance = 6
	projectile_delay = 2
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/dual
	name = "XMG-9 Autocannon"
	projectiles_per_shot = 6

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	name = "SRM-8 Light Missile Rack"
	icon_state = "mecha_missilerack"
	origin_tech = "combat=5;materials=4;engineering=4"
	projectile = /obj/item/missile
	fire_sound = 'sound/effects/bang.ogg'
	projectiles = 8
	projectile_energy_cost = 1000
	equip_cooldown = 60
	var/missile_speed = 2
	var/missile_range = 30
	var/heavy_missile = 0
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/action(target, params)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/missile/M = new projectile(chassis.loc)
	M.primed = 1
	if(heavy_missile)
		M.heavy_missile = 1
	playsound(chassis, fire_sound, 50, 1)
	M.throw_at(target, missile_range, missile_speed, spin = FALSE)
	projectiles--
	log_message("Fired from [name], targeting [target].")
	var/turf/T = get_turf(src)
	msg_admin_attack("[key_name_admin(chassis.occupant)] fired a [src] in ([T.x], [T.y], [T.z] - [ADMIN_JMP(T)])")
	log_game("[key_name(chassis.occupant)] fired a [src] in [T.x], [T.y], [T.z]")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/heavy
	name = "SRX-13 Heavy Missile Launcher"
	heavy_missile = 1

/obj/item/missile
	icon = 'icons/obj/grenade.dmi'
	icon_state = "missile"
	var/primed = null
	var/heavy_missile = 0
	throwforce = 15

/obj/item/missile/throw_impact(atom/hit_atom)
	if(primed)
		if(heavy_missile)
			explosion(hit_atom, 2, 3, 4, 6, 0)
		else
			explosion(hit_atom, 0, 0, 2, 4, 0)
		qdel(src)
	else
		..()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	name = "SGL-6 Grenade Launcher"
	icon_state = "mecha_grenadelnchr"
	origin_tech = "combat=4;engineering=4"
	projectile = /obj/item/grenade/flashbang
	fire_sound = 'sound/effects/bang.ogg'
	projectiles = 6
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 60
	var/det_time = 20
	size=1
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/action(target, params)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/grenade/flashbang/F = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	F.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [name], targeting [target].")
	spawn(det_time)
		F.prime()
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang//Because I am a heartless bastard -Sieve
	name = "SOB-3 Grenade Launcher"
	desc = "A weapon for combat exosuits. Launches primed clusterbangs. You monster."
	origin_tech = "combat=4;materials=4"
	projectiles = 3
	projectile = /obj/item/grenade/clusterbuster
	projectile_energy_cost = 1600 //getting off cheap seeing as this is 3 times the flashbangs held in the grenade launcher.
	equip_cooldown = 90
	size=1

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited/get_equip_info()//Limited version of the clusterbang launcher that can't reload
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[chassis.selected==src?"<b>":"<a href='?src=[chassis.UID()];select_equip=\ref[src]'>"][name][chassis.selected==src?"</b>":"</a>"]\[[projectiles]\]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited/rearm()
	return//Extra bit of security

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	name = "Banana Mortar"
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/grown/bananapeel
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 20
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar/action(target, params)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/grown/bananapeel/B = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 60, 1)
	B.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Bananed from [name], targeting [target]. HONK!")
	do_after_cooldown()
	return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	name = "Mousetrap Mortar"
	icon_state = "mecha_mousetrapmrtr"
	projectile = /obj/item/assembly/mousetrap
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 10
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar/action(target, params)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/assembly/mousetrap/M = new projectile(chassis.loc)
	M.secured = 1
	playsound(chassis, fire_sound, 60, 1)
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Launched a mouse-trap from [name], targeting [target]. HONK!")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola
	name = "PCMK-6 Bola Launcher"
	icon_state = "mecha_bola"
	origin_tech = "combat=4;engineering=4"
	projectile = /obj/item/restraints/legcuffs/bola
	fire_sound = 'sound/weapons/whip.ogg'
	projectiles = 10
	missile_speed = 1
	missile_range = 30
	projectile_energy_cost = 50
	equip_cooldown = 10
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola/can_attach(obj/mecha/combat/gygax/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola/action(target, params)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/restraints/legcuffs/bola/M = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [name], targeting [target].")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	equip_cooldown = 10
	name = "217-D Heavy Plasma Cutter"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demloishing solid obstacles."
	icon_state = "mecha_plasmacutter"
	item_state = "plasmacutter"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	energy_drain = 30
	origin_tech = "materials=3;plasmatech=4;engineering=3"
	projectile = /obj/item/projectile/plasma/adv/mech
	fire_sound = 'sound/weapons/laser.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/can_attach(obj/mecha/M)
	if(istype(M, /obj/mecha/working))
		if(M.equipment.len<M.max_equip)
			return TRUE
	return FALSE
