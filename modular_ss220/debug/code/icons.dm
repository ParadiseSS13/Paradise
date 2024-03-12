/atom/proc/download_flaticon()
	var/icon/I = getFlatIcon(src)
	usr << ftp(I, "[name].png")
