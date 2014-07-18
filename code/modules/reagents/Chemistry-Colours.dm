/proc/mix_color_from_reagents(var/list/reagent_list)
	if(!reagent_list || !reagent_list.len) return 0

	var/list/rgbcolor = list(0,0,0,0)
	var/finalcolor = 0
	for(var/datum/reagent/re in reagent_list) // natural color mixing bullshit/algorithm
		if(!finalcolor)
			rgbcolor = ReadRGB(re.color)
			finalcolor = re.color
		else
			var/newcolor[4]
			var/prergbcolor[4]
			prergbcolor = rgbcolor
			newcolor = ReadRGB(re.color)

			rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
			rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
			rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2
			rgbcolor[4] = (prergbcolor[4]+newcolor[4])/2

			finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3], rgbcolor[4])
	return finalcolor

/proc/mixOneColor(var/list/weight, var/list/color)
	if (!weight || !color || length(weight)!=length(color))
		return 0

	var/contents = length(weight)
	var/i

	//normalize weights
	var/listsum = 0
	for(i=1; i<=contents; i++)
		listsum += weight[i]
	for(i=1; i<=contents; i++)
		weight[i] /= listsum

	//mix them
	var/mixedcolor = 0
	for(i=1; i<=contents; i++)
		mixedcolor += weight[i]*color[i]
	mixedcolor = round(mixedcolor)

	//until someone writes a formal proof for this algorithm, let's keep this in
//	if(mixedcolor<0x00 || mixedcolor>0xFF)
//		return 0
	//that's not the kind of operation we are running here, nerd
	mixedcolor=min(max(mixedcolor,0),255)

	return mixedcolor
