//this and stop_pulling really ought to be /mob/living procs
/mob/proc/start_pulling(atom/movable/AM)
	if(src == AM) // Trying to pull yourself is a shortcut to stop pulling
		stop_pulling()
		return
	if(!AM || !isturf(AM.loc))	//if there's no object or the object being pulled is inside something: abort!
		return
	if(!(AM.anchored))
		AM.add_fingerprint(src)

		// If we're pulling something then drop what we're currently pulling and pull this instead.
		if(pulling)
			// Are we trying to pull something we are already pulling? Then just stop here, no need to continue.
			if(AM == pulling)
				return
			stop_pulling()

		if(AM.pulledby)
			visible_message("<span class='danger'>[src] has pulled [AM] from [AM.pulledby]'s grip.</span>")
			AM.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.

		pulling = AM
		AM.pulledby = src
		if(pullin)
			pullin.update_icon(src)
		if(ismob(AM))
			var/mob/M = AM
			if(!iscarbon(src))
				M.LAssailant = null
			else
				M.LAssailant = usr

/mob/verb/stop_pulling()
	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		pulling.pulledby = null
		pulling = null
		if(pullin)
			pullin.update_icon(src)

/mob/living/proc/check_pull()
	if(pulling && !(pulling in orange(1)))
		stop_pulling()
