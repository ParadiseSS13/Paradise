/proc/there_can_be_only_one_mask(var/mob/spirit/mask/target)
	if(!istype(target))
		return
	for(var/mob/spirit/mask/currentSpirit in spirits)
		if(currentSpirit)
			if(currentSpirit!=target)
				// create the ghost
				var/mob/dead/observer/ghost = currentSpirit.ghostize(TRUE)
				// let the deposed mask respawn immediately, the poor dear
				ghost.timeofdeath = world.time - 20000
				ghost.newPlayerType = /mob/new_player/cultist
				// remove old mask body
				del(currentSpirit)

	
/mob/new_player/cultist/AttemptLateSpawn(rank)
	var/mob/newCharacter = ..(rank)
	if(ticker.mode)
		if(is_convertable_to_cult(newCharacter.mind))
			ticker.mode.add_cultist(newCharacter.mind)