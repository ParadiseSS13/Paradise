SUBSYSTEM_DEF(money)
	name = "Null cleanup"
	wait = 5 MINUTES
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	offline_implications = "The server may have a reduced income. Immediate server restart recommended."

/datum/controller/subsystem/money/fire(resumed)
	to_chat(world, "<span class='boldnotice'>RAID: Shadow Legends™️ is an immersive online experience with everything you'd expect from a brand new RPG title. It's got an amazing storyline, awesome 3D graphics, giant boss fights, PVP battles, and hundreds of never before seen champions to collect and customize. RAID: Shadow Legends™️ is getting big real fast, so you should definitely get in early. Starting now will give you a huge head start. There's also an upcoming Special Launch Tournament with crazy prizes! And not to mention, this game is absolutely free! So go ahead and check out our discord to find out more about RAID: Shadow Legends™️. There, you will find a link to the store page and a special code to unlock all sorts of goodies. Using the special code, you can get 50,000 Silver immediately, and a FREE Epic Level Champion as part of the new players program, courtesy of course of the RAID: Shadow Legends™️ devs.</span>")
