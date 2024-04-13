/datum/spell/projectile
	desc = "This spell summons projectiles which try to hit the targets."

	var/proj_icon = 'icons/obj/projectiles.dmi'
	var/proj_icon_state = "spell"
	var/proj_name = "a spell projectile"

	var/proj_trail = 0 //if it leaves a trail
	var/proj_trail_lifespan = 0 //deciseconds
	var/proj_trail_icon = 'icons/obj/wizard.dmi'
	var/proj_trail_icon_state = "trail"

	/// The projectile we spawn. Make sure to override this
	var/proj_type

	var/proj_lingering = 0 //if it lingers or disappears upon hitting an obstacle
	var/proj_homing = 1 //if it follows the target
	var/proj_insubstantial = FALSE //if it can pass through dense objects or not
	var/proj_trigger_range = 0 //the range from target at which the projectile triggers cast(target)

	var/proj_lifespan = 15 //in deciseconds * proj_step_delay
	var/proj_step_delay = 1 //lower = faster

/datum/spell/projectile/cast(list/targets, mob/user = usr)

	for(var/mob/living/target in targets)
		spawn(0)
			var/obj/item/projectile/projectile = new proj_type(get_turf(user))
			projectile.icon = proj_icon
			projectile.icon_state = proj_icon_state
			projectile.dir = get_dir(target, projectile)
			projectile.name = proj_name
			var/current_loc = get_turf(projectile)

			for(var/i in 1 to proj_lifespan)
				if(!projectile)
					break

				if(proj_homing)
					if(proj_insubstantial)
						projectile.dir = get_dir(projectile,target)
						projectile.forceMove(get_step_to(projectile, target))
					else
						step_to(projectile,target)
				else
					if(proj_insubstantial)
						projectile.forceMove(get_step(projectile, projectile.dir))
					else
						step(projectile, projectile.dir)

				if(!projectile) // step and step_to sleeps so we'll have to check again.
					break

				if(!proj_lingering && (get_turf(projectile) == current_loc)) //if it didn't move since last time
					qdel(projectile)
					break

				if(proj_trail && projectile)
					spawn(0)
						if(projectile)
							var/obj/effect/overlay/trail = new /obj/effect/overlay(get_turf(projectile))
							trail.icon = proj_trail_icon
							trail.icon_state = proj_trail_icon_state
							trail.density = FALSE
							spawn(proj_trail_lifespan)
								qdel(trail)

				current_loc = get_turf(projectile)

				sleep(proj_step_delay)

			if(projectile)
				qdel(projectile)
