//an explosion reproducing a pretty "realist" impact with minimal load, very similar result to recursive, but without recursive function and also with only 1 pass on any tile (recursive would end up passing 2-3-4 times on most tiles covered by the explosion)
/client/proc/kaboom()
	var/power = input(src, "power?", "power?") as num
	var/turf/T = get_turf(src.mob)
	explosion_iter(T, power)

/atom/var/explosion_resistance = 0.01 //everything soaks a tiny bit of damage at least




proc/explosion_iter(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range)
	var/datum/line_explosion_controller/explosion = new()
	explosion.startExplosion(epicenter, devastation_range, heavy_impact_range, light_impact_range)




/obj/effect/debugging/marker/var/changedtimes = 0
/obj/effect/debugging/marker/var/powerexplosion = 0
/turf
	var/explosion_ratio = 1.0 //this affect the explosion spread, but by a % instead of direct value (should make walls a bit more meaningfull vs stronger bombs
	var/datum/side_explosion/side_explosion_data = 0

/turf/space
	explosion_resistance = 10

/turf/simulated/floor
	explosion_resistance = 1

/turf/simulated/mineral
	explosion_resistance = 2

/turf/simulated/shuttle/floor
	explosion_resistance = 1

/turf/simulated/shuttle/floor4
	explosion_resistance = 1

/turf/simulated/shuttle/plating
	explosion_resistance = 1

/turf/simulated/shuttle/wall
	explosion_resistance = 5
	explosion_ratio = 0.80
/turf/simulated/wall
	explosion_resistance = 5
	explosion_ratio = 0.80

/turf/simulated/wall/r_wall
	explosion_resistance = 15
	explosion_ratio = 0.60

//Code-wise, a safe value for power is something up to ~25 or ~30.. This does quite a bit of damage to the station.
//direction is the direction that the spread took to come to this tile. So it is pointing in the main blast direction - meaning where this tile should spread most of it's force.

/proc/dirtoangle(direction) //convert to angle starting from north
{
	if (direction == NORTH)
		return 0
	if (direction == SOUTH)
		return 180
	if (direction == EAST)
		return 90
	if (direction == WEST)
		return 270
}
/proc/highPrioritySleep(time, debugname) //just a placeholder until i reimplement my process tracking system
	sleep(time)

/obj/effect/fakefire
	anchored = 1
	mouse_opacity = 0
	unacidable = 1//So you can't melt fire with acid.
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = TURF_LAYER
	blend_mode = BLEND_ADD
	New()
		color = heat2color(25000)
		set_light(color)

datum/line_explosion_controller //used to manage the explosion itself
	var/highestsidepower=0 //this is a value used to not have to iterate everytime through all the queued side. We only iterate to pick the next start point
	var/list/queue_explosion_lines = list() //list of lines that we are currently exploding
	var/list/queue_explosion_sides = list() //list of side explosions that we use to start new lines from. We find the highest power side explosion end start a line for each of the same power
	var/turf/epicenter = 0
	var/power = 0
	var/list/explosion_turfs //list containing our calculated explosion to apply
	var/delayBetweenWave = 1 //how long we sleep between each explosions wave
	var/iterationperWave = 7 //how many steps between sleeps
	var/destructionperWave = 15 //how many tiles do we apply the explosion on between sleeps
	var/calculating = 0
	var/devastation_boost_count = 0
	var/heavy_impact_boost_count = 0
	var/light_impact_boost_count = 0
	var/highpower = 0
	var/midpower = 0
	var/lowpower = 0
	proc/startExplosion(turf/m_epicenter, devastation_range, heavy_impact_range, light_impact_range)
	{
		devastation_boost_count = devastation_range * 3
		heavy_impact_boost_count = heavy_impact_range * 3
		light_impact_boost_count = light_impact_range * 3
		if (devastation_range < 0)
			devastation_range = 0
		if (heavy_impact_range < 0)
			heavy_impact_range = 0
		if (light_impact_range < 0)
			light_impact_range = 0
		power = devastation_range * 1.4 + heavy_impact_range * 1.2 + light_impact_range //convert to an explosion power
		message_admins("Explosion with power:[power] size:([devastation_range], [heavy_impact_range], [light_impact_range]) in area [m_epicenter.loc.name] ([m_epicenter.x],[m_epicenter.y],[m_epicenter.z])")
		log_game("Explosion with power:[power] size:([devastation_range], [heavy_impact_range], [light_impact_range]) in area [m_epicenter.loc.name] ([m_epicenter.x],[m_epicenter.y],[m_epicenter.z])")
		explosion_turfs = list()
		epicenter=m_epicenter

		calculateExplosionSpread() //first we need to build up a list of turf to damage and determine how much power
		applyExplosion() //then we apply the data we just generated
		message_admins("Explosion with power:[power] size:([devastation_range], [heavy_impact_range], [light_impact_range]) in area [m_epicenter.loc.name] ([m_epicenter.x],[m_epicenter.y],[m_epicenter.z]) is completed")
	}


	proc/applyExplosion()
	{
		var/count=0
		var/effectivepower = 0
		var/severity = 4
		var/doneiter = 0
		var/doneany = 0
		var/datum/effect/system/explosion/initialExplosioneffect = new/datum/effect/system/explosion()
		initialExplosioneffect.set_up(epicenter)
		if (power < 3)
			initialExplosioneffect.setsize(3)
			initialExplosioneffect.smoke = 1
			initialExplosioneffect.smokedur = 15
		else
			if (power < 10)
				initialExplosioneffect.setsize(2)
			else
				initialExplosioneffect.setsize(1)
			initialExplosioneffect.smoke = 3
			initialExplosioneffect.smokedur = 40

		initialExplosioneffect.particles = 10
		initialExplosioneffect.smokerng = 0
		initialExplosioneffect.start()
		highPrioritySleep(1) //give the explosion effect a chance to actually get rendered on people screen
		while (calculating == 1 && explosion_turfs.len == 0) //wait for the first explosion to be calculated
			if (power < 10) //this is a quick bomb
				highPrioritySleep(0)
			else
				highPrioritySleep(delayBetweenWave*3)

		while (doneiter < 2 || calculating >= 1)

			for(var/turf/T in explosion_turfs)
				if (count > destructionperWave)
					if (calculating >= 1)
						highPrioritySleep(delayBetweenWave*3)
					else
						highPrioritySleep(delayBetweenWave)
					count = 0

				effectivepower = explosion_turfs[T]
				explosion_turfs[T] = 0
				if(effectivepower <= 0) continue
				if(!T) continue

				//explode on the stuff
				for(var/atom/A in T)
					severity = 4
					effectivepower = (effectivepower-A.explosion_resistance)
					if(effectivepower <= 0) continue
					if (effectivepower >= highpower)
						severity = 1
					else if (effectivepower >= midpower)
						severity = 2
					else if (effectivepower >= lowpower)
						severity = 3
					else if (prob(75)) //lowest power, 75% chance to do nothing
						continue
					A.ex_act(severity)

				//explode on the turf
				if(effectivepower <= 0) continue
				doneany=1
				severity = 3 //severity is 1 to 3, 1 being highest
				if (effectivepower >= highpower)
					severity = 1
				else if (effectivepower >= midpower)
					severity = 2
				else if (effectivepower >= lowpower)
					severity = 3
				else if (prob(40)) //lowest power, 40% chance to do nothing
					continue
				if (prob(20))
					var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
					E.set_up(T)
					E.setsize(severity)
					E.start()
				T.ex_act(severity)

				count++
			doneiter++

			if (doneany == 1)
				doneiter = 0
				doneany = 0
			else
				if (power < 10) //this is a quick bomb
					highPrioritySleep(0)
				else
					highPrioritySleep(delayBetweenWave*2)
	}
	proc/calculateExplosionSpread()
	{
		//world << "calculateExplosionSpread  -  Start"
		var/totalresist = 0
		var/devastdist = devastation_boost_count
		var/heavydist = heavy_impact_boost_count
		var/lightdist = light_impact_boost_count
		highpower = power*2/3
		midpower = power*1/3
		lowpower = power*1/6
		if (power < 9)
			highpower = power+1 //no total destruction on a small/smallish bomb
			midpower = power/2
			lowpower = power*1/4
		if (power < 5)
			midpower = power+1 //no medium destruction on a very small bomb (c4)
			lowpower = power*1/2


		if (epicenter)
			for(var/obj/O in epicenter)
				if(O.explosion_resistance)
					totalresist+=O.explosion_resistance
		var/tilepower = (power - (totalresist + epicenter.explosion_resistance))*epicenter.explosion_ratio

		if (devastdist > 0)
			devastdist--
			if (tilepower < highpower)
				tilepower = highpower*1.3
		else if (heavydist > 0)
			heavydist--
			if (tilepower < midpower)
				tilepower = midpower+ (highpower-midpower)/3
		else if (lightdist > 0)
			lightdist--
			if (tilepower < lowpower)
				tilepower = lowpower+ (midpower-lowpower)*3/4
		var/epicenterpower = tilepower



		explosion_turfs[epicenter] = epicenterpower
		for(var/direction in cardinal)
			var/turf/T = get_step(epicenter, direction)
			totalresist = 0
			if (T)
				for(var/obj/O in T)
					if(O.explosion_resistance)
						totalresist+=O.explosion_resistance
			var/datum/line_explosion/linedef = new((power - (totalresist + T.explosion_resistance))*T.explosion_ratio, T, direction, src,0)
			queue_explosion_lines.Add(linedef)

		calculating = 1
		spawn(-1)
			executeCalculations() //can async that part
			calculating = 0
		//world << "calculateExplosionSpread  -  Done"
	}
	proc/executeCalculations()
	{
		var/iterationcount = 0
		var/totalcount = 0
		while (queue_explosion_lines.len > 0)
		{
			while (queue_explosion_lines.len > 0)
				for (var/datum/line_explosion/line in queue_explosion_lines)
				{
					//we process all explosion lines
					var/result = line.iterate()
					if (result == 1) //it return 1 once the line is done
						queue_explosion_lines -= line
					totalcount++
					if (totalcount >= 4*destructionperWave)
						calculating = 2
				}
				iterationcount++
				if (iterationcount > iterationperWave)
					highPrioritySleep(delayBetweenWave)
					iterationcount = 0

			//here we check the sides list and generate a new lines list
			highestsidepower = 0
			for (var/turf/T in queue_explosion_sides)
				if (T == 0)
					continue
				if (T.side_explosion_data == 0)
					continue
				if (T.side_explosion_data.power > highestsidepower)
					highestsidepower = T.side_explosion_data.power
			if (highestsidepower > 0)
				for (var/turf/T in queue_explosion_sides)
					if (T == 0)
						continue
					if (T.side_explosion_data == 0)
						continue
					if (T.side_explosion_data.power == highestsidepower)
						var/datum/line_explosion/linedef = new(T.side_explosion_data.power, T, T.side_explosion_data.direction, src, 0, devastation_boost_count, heavy_impact_boost_count, light_impact_boost_count)
						queue_explosion_lines.Add(linedef)
						queue_explosion_sides -= T
		}
	}
datum/side_explosion
	var/direction=0 //direction were headed
	var/power=0
	New(startpower, startDirection)
	{
		power = startpower
		direction = startDirection
	}

datum/line_explosion
	var/direction=0 //direction were headed
	var/power=0
	var/turf/nextTurf=0 //turf on which we explode next
	var/datum/line_explosion_controller/controller = 0 //our controller
	New(startpower, turf/startTurf, startDirection, datum/line_explosion_controller/ourController, newIsSide)
	{
		power = startpower
		nextTurf = startTurf
		direction = startDirection
		controller = ourController

//		world.log << "Created a line"
	}
	proc/iterate() //explode the next tile
	{
//		world.log << "Iterate a line"
		if (nextTurf == null)
			return 1
		return nextTurf.explosion_line(power, direction, controller, src)
	}



/turf/proc/explosion_line(power, direction, datum/line_explosion_controller/controller, datum/line_explosion/currentLine) //explode in a line until our power is lower than the highest side explosion
	var/tilepower = power
	if (controller.devastation_boost_count > 0)
		controller.devastation_boost_count--
		if (tilepower < controller.highpower)
			tilepower = controller.highpower*1.3
	else if (controller.heavy_impact_boost_count > 0)
		controller.heavy_impact_boost_count--
		if (tilepower < controller.midpower)
			tilepower = controller.midpower+ (controller.highpower-controller.midpower)/3
	else if (controller.light_impact_boost_count > 0)
		controller.light_impact_boost_count--
		if (tilepower < controller.lowpower)
			tilepower = controller.lowpower+ (controller.midpower-controller.lowpower)*3/4
	if(tilepower <= 0)
		return 1
	if (src == null)
		return 1
	if(controller.explosion_turfs[src] > 0)
		return 1 //Since the explosions happen sorted by power, if there is any kind of power on the tile, its accurate enough (about 90% acurate, not worth the extra iterations)


	if (power < controller.highestsidepower) //were done for now, so lets readd ourself to the side list to be continued later
		src.side_explosion_data = new(power,direction)
		controller.queue_explosion_sides |= src
		return 1

	controller.explosion_turfs[src] = tilepower

	var/turf/T1 = get_step(src, direction)
	var/totalresist = 0
	var/spread_power = power
	if (T1)
		for(var/obj/O in T1)
			if(O.explosion_resistance)
				totalresist+=O.explosion_resistance

		spread_power = (power - (T1.explosion_resistance + totalresist))*T1.explosion_ratio



	var/turf/T2 = get_step(src, turn(direction,90))
	var/turf/T3 = get_step(src, turn(direction,-90))
	currentLine.nextTurf = T1
	currentLine.power = spread_power

	totalresist = 0
	var/side_spread_power = power
	if (T2)
		for(var/obj/O in T2)
			if(O.explosion_resistance)
				totalresist+=O.explosion_resistance
		side_spread_power = power - (2 * (T2.explosion_resistance+totalresist))*T2.explosion_ratio*T2.explosion_ratio //This is the amount of power that will be spread to the side tiles
		T2.explosion_side(side_spread_power, turn(direction,90), controller)
	totalresist = 0
	if (T3)
		for(var/obj/O in T3)
			if(O.explosion_resistance)
				totalresist+=O.explosion_resistance
		side_spread_power = power - (2 * (T3.explosion_resistance+totalresist))*T3.explosion_ratio*T3.explosion_ratio //This is the amount of power that will be spread to the side tiles
		T3.explosion_side(side_spread_power, turn(direction,-90),controller)
	return 0



/turf/proc/explosion_side(power, direction, datum/line_explosion_controller/controller) //calculate the power on the tile, and add it to a queue to start line explosions from
	if(power <= 0)
		return
	if(controller.explosion_turfs[src] > 0)
		return //Since the explosions happen sorted by power, if there is any kind of power on the tile, its accurate enough (about 90% acurate, not worth the extra iterations)


	controller.explosion_turfs[src] = power
	if (power > controller.highestsidepower)
		controller.highestsidepower = power

	//store the data to figure where to continue the explosion later
	var/turf/T1 = get_step(src, direction)
	var/totalresist = 0
	for(var/obj/O in T1)
		if(O.explosion_resistance)
			totalresist+=O.explosion_resistance

	var/side_spread_power = power - (2 * (T1.explosion_resistance+totalresist))*T1.explosion_ratio*T1.explosion_ratio //This is the amount of power that will be spread to the side tiles
	if (side_spread_power < controller.highestsidepower) //lets add our next step to the list so that it become considered //This is the amount of power that will be spread to the tile in the direction of the blast
		T1.side_explosion_data = new(side_spread_power,direction)
		controller.queue_explosion_sides |= T1

