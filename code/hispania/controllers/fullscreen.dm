/client/New()
	..()
	winset(src, "mainwindow", "can-resize=true;titlebar=true;menu=menu")
	winset(src, "mainwindow.mainvsplit", "splitter=75")

/client/verb/updatefullscreen()
	set name = "Fullscreen"
	set category = "Preferences"
	set desc = "Toggle Fullscreen"
	if (!fullscreen)
		winset(src, "mainwindow", "is-maximized=false;can-resize=false;titlebar=false;menu=")
		winset(src, "mainwindow.mainvsplit", "splitter=78")
		winset(src, "mainwindow", "is-maximized=true")
		fullscreen = TRUE
		return
	else
		winset(src, "mainwindow", "can-resize=true;titlebar=true;menu=menu")
		winset(src, "mainwindow.mainvsplit", "splitter=75")
		fullscreen = FALSE
		return
