/atom/movable/verb/pull()
	set name = "Pull"
	set category = null
	set src in oview(1)

	if(Adjacent(usr))
		usr.start_pulling(src)
	return
