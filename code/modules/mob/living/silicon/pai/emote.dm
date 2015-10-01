/mob/living/silicon/pai/emote(var/act, var/m_type=1, var/message = null)
	if(stat)
		return
	
	switch(act)
		if ("help")
			src << "ping, beep, buzz."

	..(act, m_type, message)