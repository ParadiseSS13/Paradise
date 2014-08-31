/*
	The Big Bad NT Operating System
*/

/datum/file/program/NTOS
	name = "Nanotrasen Operating System"
	extension = "prog"
	active_state = "ntos"
	var/obj/item/part/computer/storage/current // the drive being viewed, null for desktop/computer
	var/fileop = "runfile"

/*
	Generate a basic list of files in the selected scope
*/

/datum/file/program/NTOS/proc/list_files()
	if(!computer || !current) return null
	return current.files


/datum/file/program/NTOS/proc/filegrid(var/list/filelist)
	var/dat = "<table border='0' align='left'>"
	var/i = 0
	for(var/datum/file/F in filelist)
		i++
		if(i==1)
			dat += "<tr>"
		if(i>= 7)
			i = 0
			dat += "</tr>"
			continue
		dat += {"
		<td>
			<a href='?src=\ref[src];[fileop]=\ref[F]'>
				<img src=\ref[F.image]><br>
				<span>[F.name]</span>
			</a>
		</td>"}

	dat += "</tr></table>"
	return dat

//
// I am separating this from filegrid so that I don't have to
// make metadata peripheral files
//
/datum/file/program/NTOS/proc/desktop(var/peripheralop = "viewperipheral")
	var/dat = "<table border='0' align='left'>"
	var/i = 0
	var/list/peripherals = list(computer.hdd,computer.floppy,computer.cardslot)
	for(var/obj/item/part/computer/C in peripherals)
		if(!istype(C)) continue
		i++
		if(i==1)
			dat += "<tr>"
		if(i>= 8)
			i = 0
			dat += "</tr>"
			continue
		dat += {"
		<td>
			<a href='?src=\ref[src];[peripheralop]=\ref[C]'>
				\icon[C]<br>
				<span>[C.name]</span>
			</a>
		</td>"}

	dat += "</tr></table>"
	return dat


/datum/file/program/NTOS/proc/window(var/title,var/buttonbar,var/content)
	return {"
	<div class='filewin'>
		<div class='titlebar'>[title] <a href='?src=\ref[src];winclose'><img src=\ref['icons/NTOS/tb_close.png']></a></div>
		<div class='buttonbar'>[buttonbar]</div>
		<div class='contentpane'>[content]</div>
	</div>"}

/datum/file/program/NTOS/proc/buttonbar(var/type = 0)
	switch(type)
		if(0) // FILE OPERATIONS
			return {""}

/datum/file/program/NTOS/interact()
	if(!interactable())
		return
	var/dat = {"
	<html>
	<head>
	<title>Nanotrasen Operating System</title>
	<style>
		div.filewin {
			position:absolute;
			left:80px;
			top:114px;
			width:480px;
			height:360px;
			border:2px inset black;
			background-color:#F0F0F0;
			overflow:auto
		}
		div.titlebar {
			position:fixed;
			left:80px;
			top:60px;
			width:480px;
			height:18px;
			padding:1px;
			padding-left:8px;
			border:none;
			background-color:#2020a0;
			color:#FFFFFF;
			z-index:5
		}
		.titlebar a {
			position:absolute;
			right:4px;
			display: block;
			width:16px;
			height:100%;
			background-color:#000000;
			color:#808080;
		}
		div.buttonbar {
			position:fixed;
			left:80px;
			top:78px;
			width:480px;
			height:36px;
			padding:2px;
			background-color:#f0d0d0;
		}
		div.contentpane {
			padding:4px;
			width:100%;
			height:100%
		}
		table a {
		    display: block;
		    height: 100%;
		    width: 100%;
		    text-decoration: none;
			color: black;
			text-align:center;
		}
		table span {
			background-color: #E0E0E0;
			font-family: verdana;
			font-size: 12px;
		}
		td {
			width: 64;
			height: 64;
			overflow: hidden;
			valign: "top";
		}
		a img {
			border: none;
		}

	</style>
	</head>

	<body><div style='width:640px;height:480px;	border:2px solid black;padding:8px;background-image:url(\ref['icons/NTOS/ntos.png'])'>"}

	var/list/files = list_files()
	if(current)
		dat +=window(current.name,buttonbar(),filegrid(files))
	else
		dat += desktop()

	dat += "</div></body></html>"

	usr << browse(dat, "window=\ref[computer];size=670x510")
	onclose(usr, "\ref[computer]")

/datum/file/program/NTOS/Topic(href, list/href_list)
	if(!interactable() || ..(href,href_list))
		return

	if("viewperipheral" in href_list) // open drive, show status of peripheral
		var/obj/item/part/computer/C = locate(href_list["viewperipheral"])
		if(istype(C,/obj/item/part/computer/storage))
			current = C
			interact()
			return
		// else ???
		interact()
		return

	// distinct from close, this is the file dialog window
	if("winclose" in href_list)
		current = null
		interact()
		return

#undef MAX_ROWS
#undef MAX_COLUMNS
