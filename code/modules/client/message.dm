GLOBAL_LIST_EMPTY(clientmessages)

proc/addclientmessage(var/ckey, var/message)
	ckey = ckey(ckey)
	if(!ckey || !message)
		return
	var/list/L = GLOB.clientmessages[ckey]
	if(!L)
		GLOB.clientmessages[ckey] = L = list()
	L += message
