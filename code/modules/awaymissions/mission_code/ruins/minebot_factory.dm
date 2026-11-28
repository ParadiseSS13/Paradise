/obj/machinery/computer/loreconsole/althland_factory/laboratory
	name = "laboratory work station"
	entries = list(
		new/datum/lore_console_entry(
			"Minebot V3.0 Field Test Results",
			{"Improvements to the kinetic acelerator armament and the addition of thicker plating has made the new minebot prototypes far better suited to operations here. \
			They can put up a good fight against the local fanua, and a swarm of them is basically untouchable by the common goliaths or watchers, however there's no way they'll be taking on \
			the local megafauna any time soon, so avoidance is still paramount."}),

		new/datum/lore_console_entry(
			"Further upgrades",
			{"In response to further field testing, we've developed some modular upgrades for the minebot's kinetic acelerator that allows it to shoot more often. \
			It makes them better at fighting fauna and mining ore, and it's even compatable with existing models without any modifications needed.<br><br>\
			\
			At this rate we'll finally be able to cut down to a bare minimum number of miners, the cost savings will be immense."}),

		new/datum/lore_console_entry(
			"Improved minebot control unit",
			{"It's taken god knows how much coffee and sleepless nights, but we've managed to develop a robust and cheap control unit for the minebot. \
			We've managed to avoid using positronic components (we all know positronic computing is an expensive dead-end technology that will never leave the lab), \
			instead relying on an analog circuit based on a virtual neural network that was relentlessly trained on our computer network.<br><br>\
			\
			It has a limited capacity to learn new skills, but it's an expert miner, it can understand complex commands, and it's even capable of simulating social interaction with organics. \
			It's just what we need. We can finally fully automate extraction operations. Day in, day out, profit. And no one else has to die on this forsaken rock."}),)

/obj/machinery/computer/loreconsole/althland_factory/mining
	name = "ancient communications console"
	entries = list(
		new/datum/lore_console_entry(
			"!!!MASSIVE!!! Production Increase!",
			{"Well done, the minebot program is a complete success! Production figures from your site have risen by over 1000%. We've had to start diverting shuttles from other sites \
			just to keep up with all the shipments you're making.<br><br>\
			\
			Now, I'm aware that there's talk that we're going to start letting people go among the miners. Rest assured, we have other areas on the planet that aren't suitable for minebot operations yet, \
			we would be happy to relocate people there. If anyone *was* to be made redundant, rest assured, they would be leaving with a big fat cash bonus, \
			we're talking a full 6 month's salary kind of bonus.
			- Management."}),

		new/datum/lore_console_entry(
			"What the fuck is going on down there?",
			{"We've not gotten a shipment in 6 hours. We've made an allowance just in case there was like, an empty patch or something, or maybe your smelter broke down? \
			Whatever it is, FIX IT! You've got an army of the most advanced mining robots in the whole galaxy and you're telling me you can't even send us a crate of iron?<br><br>\
			\
			We expect a full report, and constant status updates. And we expect that ore to start flowing again.
			- Management."}),

		new/datum/lore_console_entry(
			"Mike 8, Please Respond!",
			{"Respond immeditely to verify you are still alive. We've had a string of omega-level alerts from multiple sites. We are standing by to send an emergency recovery shuttle to your location.
			- Farragus Operations Control"})
			)

/obj/machinery/computer/loreconsole/althland_factory
	name = "production line terminal"
	entries = list(
		new/datum/lore_console_entry(
			"Mass Production: GO",
			{"Farragus has relayed orders from The Company, we're to gear up for full mass production as soon as possible. We need to provide our own materials, but that's not an issue. \
			Ore is so plentiful that we're fully self-sufficient for raw material. The main issue will just be handling the production lines.<br><br>\
			\
			After we've got legions of these things stip-mining the planet, those Nanotrasen bastards will probably go bankrupt from all the plasma we'll be throwing onto the market."}),

		new/datum/lore_console_entry(
			"Odd Quirks",
			{"Some of the minebots have been developing odd behavoural quirks. We've had reports of some units driving in erratic patterns, \
			saying nonsensical strings of words, and one of the workers woke up to find a minebot in their quarters, staring at them. Freaked them the hell out. \
			Internal logs show it wasn't just a prank either.<br><br>\
			\
			For now we're just resetting the affected units, but we may need to recall them and revise the neural network, it's not as stable as initial trials showed."}))

/area/ruin/unpowered/althland_factory
	name = "Site M8 Minebot Production Line"
	icon_state = "mining_production"

/area/ruin/unpowered/althland_factory/dorms
	name = "Site M8 Dorms"
	icon_state = "mining_living"

/area/ruin/unpowered/althland_factory/mining_and_processing
	name = "Site M8 Mining and Processing Operations"
	icon_state = "mining_eva"

/area/ruin/unpowered/althland_factory/lab
	name = "Site M8 Laboratories"
	icon_state = "mechbay"
