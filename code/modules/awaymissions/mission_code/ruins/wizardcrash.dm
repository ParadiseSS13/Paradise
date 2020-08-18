//stuff for the crashed wizard shuttle space ruin (wizardcrash.dmm)

/obj/item/paper/fluff/ruins/wizardcrash
	name = "Mission Briefing"
	info = "To the Magnificent Z.A.P.<BR>A small mining base has been created within our territory by wandless scum. Send them a message from the wizard federation they will not forget. I know your kind is rather fragile, but a group of lightly armed miners should not pose any threat to you at all. Just be warned they have a security cyborg for self defence, you might want to tune your spells to that threat. I look forward to hearing of your success.<BR>Grand Magus Abra the Wonderous"


/obj/effect/spawner/lootdrop/wizardcrash
	loot = list(
				/obj/item/guardiancreator = 1,   //jackpot. 
				/obj/item/spellbook/oneuse/knock = 1,    //tresspassing charges incoming
				/obj/item/gun/magic/wand/resurrection = 1,   //medbay's best friend
				/obj/item/spellbook/oneuse/charge = 20,  //and now for less useful stuff to dilute the good loot chances
				/obj/item/spellbook/oneuse/summonitem = 20,
				/obj/item/spellbook/oneuse/forcewall = 10,
				/obj/item/soulstone = 15      //spooky wizard stuff
				)
