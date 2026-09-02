/datum/asset/simple/namespaced/claw_game
	legacy = TRUE
	assets = list(
		"backgroundsprite.png" = 'icons/obj/arcade_images/backgroundsprite.png',
		"clawpieces.png" =	'icons/obj/arcade_images/clawpieces.png',
		"crane_bot.png" = 'icons/obj/arcade_images/crane_bot.png',
		"crane_top.png" = 'icons/obj/arcade_images/crane_top.png',
		"prize_inside.png" = 'icons/obj/arcade_images/prize_inside.png',
		"prizeorbs.png" = 'icons/obj/arcade_images/prizeorbs.png'
	)
	parents = list(
		"page.css" = 'code/modules/arcade/page.css'
	)

/datum/asset/group/claw_game
	children = list(
		/datum/asset/simple/namespaced/claw_game,
		/datum/asset/simple/jquery
	)
