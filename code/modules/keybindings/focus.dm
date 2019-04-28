    
/datum
	var/list/focusers //Only initialized when needed. Contains a list of mobs focusing on this.

/mob
	var/datum/focus //What receives our keyboard inputs. src by default

/mob/proc/set_focus(datum/new_focus)
	if(focus == new_focus)
		return
	focus = new_focus
	reset_perspective(focus) //Maybe this should be done manually? You figure it out, reader