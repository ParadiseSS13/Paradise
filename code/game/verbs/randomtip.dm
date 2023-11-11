/client/verb/randomtip()
	set category = "OOC"
	set name = "Give Random Tip"
	set desc = "Shows you a random tip"

	var/tip
	var/list/randomtips = file2list("strings/tips.txt")
	var/list/memetips = file2list("strings/sillytips.txt")
	if(length(randomtips) && prob(95))
		tip = pick(randomtips)
	else if(length(memetips))
		tip = pick(memetips)

	if(tip)
		to_chat(src, "<span class='purple'><b>Tip: </b>[html_encode(tip)]</span>")
