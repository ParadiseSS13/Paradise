/mob/living/silicon/pai/say(var/msg)
	if(silence_time)
		src << "<font color=green>Communication circuits remain uninitialized.</font>"
	else
		..(msg)