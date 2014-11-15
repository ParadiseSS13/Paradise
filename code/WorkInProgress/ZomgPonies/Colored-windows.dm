var/global/wcBrig
var/global/wcBar
var/global/wcCommon

//for all window/New and door/window/New
/proc/color_windows(area = "common")
	var/list/common = list("#379963", "#0d8395", "#58b5c3", "#49e46e", "#8fcf44", "#ffffff")
	if(!wcCommon)
		wcCommon = pick(common)
	return wcCommon

//This func called in master-controller, replaces color in some area
/proc/color_windows_init()
	var/list/brig = list("#aa0808", "#7f0606", "#ff0000")
	var/list/bar = list("#0d8395", "#58b5c3", "#58c366", "#90d79a", "#ffffff")

	wcBrig = pick(brig)
	wcBar = pick(bar)

	//BRIG
	var/wsBrigList = list(
		/area/security/brig,
		/area/security/detectives_office,
		/area/security/hos,
		/area/security/lobby,
		/area/security/main,
		/area/security/prison,
		/area/security/warden,
		/area/security/range,
		/area/prison/cell_block/A,
		/area/prison/cell_block/B,
		/area/prison/cell_block/C,
		/area/security/prison/cell_block/A,
		/area/security/prison/cell_block/B,
		/area/security/prison/cell_block/C,
		/area/security/processing,
		/area/security/armoury,
		/area/security/securearmoury,
		/area/security/podbay,
		/area/security/securehallway,
		/area/security/medbay
		)

	for(var/A in wsBrigList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcBrig
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcBrig

	//BAR
	for(var/obj/structure/window/W in locate(/area/crew_quarters/bar))
		W.color = wcBar
	for(var/obj/machinery/door/window/D in locate(/area/crew_quarters/bar))
		D.color = wcBar