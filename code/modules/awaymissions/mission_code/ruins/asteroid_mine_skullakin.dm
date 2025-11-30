/area/ruin/skullakin_mine/arrivals
	name = "Skullakin Asteroid Mine Arrivals"
	icon_state = "entry"

/area/ruin/skullakin_mine/cafeteria
	name = "Skullakin Asteroid Mine Cafeteria"
	icon_state = "bar"

/area/ruin/skullakin_mine/overseer
	name = "Skullakin Asteroid Mine Overseer's Office"
	icon_state = "bridge"

/area/ruin/skullakin_mine/mission_control
	name = "Skullakin Asteroid Mine Mission Control"
	icon_state = "hall_space"

/area/ruin/skullakin_mine/temple
	name = "Skullakin Asteroid Mine Temple"
	icon_state = "chapel"

/area/ruin/skullakin_mine/mining
	name = "Skullakin Asteroid Mine Mining Foyer"
	icon_state = "mining"

/area/ruin/skullakin_mine/solars
	name = "Skullakin Asteroid Mine Solars"
	icon_state = "general_solars"
	requires_power = FALSE
	valid_territory = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE

/obj/machinery/computer/loreconsole/skullakin_mine/security_checkpoint
	name = "Security Checkpoint Console"
	entries = list(
		new/datum/lore_console_entry(
			"Recent Arrivals",
			{"## INCOMING PERSONNEL

**Alkkus-Vittari** - Crucible Excavation-Acolyte, Temporary Stay.
**Viltaskk-Akka** - Crucible Excavation-Acolyte, Temporary Stay.
**Tikka-Muttal** - Crucible Excavation-Neophyte, Temporary Stay, Apprentice To Viltaskk.

**Altus-Paskko** - Clergy Medical-Acolyte

**Makkath-Gurtask** - Crucible Lord-Foreman, Temporary Stay

**Askkith-Mortaa** - Low-Inquisitor, Temporary Stay
**Baskka-Tillk** - Low-Inquisitor, Temporary Stay (Me!!!)

## OUTGOING PERSONNEL

**Eskka-Mortiss** - High-Inquisitor
**Tavvikk-Ckall** - Crucible Grand-Foreman"}),
		new/datum/lore_console_entry(
			"Security Notes",
			{"Alkkus got into a fight with Tikka again. We aren't sure what provoked them, but Alkkus calmed down \
after temporary admonition. Askkith is upset it didn't escalate, but I'm just glad no weapons were drawn. \
Tikka had to report to Altus for a checkup, suffering a few bruises to the side of their head. Even still, \
Tikka chose to forgive Alkkus. I can't stand him, Alkkus has been nothing but trouble from the moment they got here."}))

/obj/machinery/computer/loreconsole/skullakin_mine/monitoring_station
	name = "Sensor Monitoring Station"
	entries = list(
		new/datum/lore_console_entry(
			"Scanning Station",
			{"## LOGGED OBJECTS

**Demonic Vessel** - A haphazardly repaired space vessel passed by, nearby naval vessels were notified but the abominations didn't seem to notice us.

**Collective Vessel** - Crucible combat vessel stopped to refuel, they were supposedly looking for the reported demonic vessel, but they seem long gone by now.

**Large Asteroid** - Missed us by a wide margin, was thoroughly scanned and had no materials worth excavating.

**Resonance Spike** - Makkath stated they felt a strange psionic energy reading. We assume a group of souls passed by, but the scanners aren't picking \
it up anymore. I decided to log it anyways in case anything comes of it.

**Unmarked Vessel** - A black vessel passed by, we aren't sure who it belongs to but it looks to be a stealth vessel of some kind, we planned to hail it, \
but Lord Makkath told us to keep quiet.

**Unknown Debris** - Plasteel debris was seen floating off, we aren't sure where it came from, but it seemed logical to put here."}),
		new/datum/lore_console_entry(
			"Operator's Notes",
			{"This feels strange. We're in Nanotrasen space, but we haven't seen a single corporate vessel in weeks. It's lonely, it doesn't feel right being so far away \
from the Accoriums. The Lord has been doing well to keep morale up though, he's not the best at preaching, but I can tell everyone appreciates the gesture. \
Though, I spent time talking with Tikka - poor kid doesn't feel like she belongs. They wouldn't stop crying when I tended to her bruises the other day, Skkula forbid we all get along."}))

/obj/machinery/computer/loreconsole/skullakin_mine/overseer_console
	name = "Overseer's Console"
	entries = list(
		new/datum/lore_console_entry(
			"Overseer Console",
			{"## LORD-FOREMAN MAKKATH'S NOTES

We dug into a divot recently, my hopes weren't high but the scanner is showing a potential deposit of ichor! Praise be and Skkula, we were due some good news. \
Hopefully once I tell the disciples I'll finally see some smiles around here, I can't stand seeing everyone so upset.

I'll tell Tavvikk when deep-drilling operations are underway, we still need to make sure the ground is stable enough so we don't depressurize anything. Despite \
the presence of ichor, much of the asteroid is disappointingly hollow, but we take what Skkula bestows us.

In other news, Viltaskk has talked to me about promoting Tikka to an Acolyte. I personally believe it is much too soon, they can barely hold a pickaxe, and I \
watched them get sent flying after firing a kinetic accelerator. But, it may help with their outlook on things, I still think it was cruel to make them leave Ossya.

Askkith and Baskka pulled Alkkus aside again, for a 'routine checkup' they said, one that conveniently did not include Altus. I feared the worst, but Alkkus left, \
unscathed. Nobody wanted to tell me what happen, but Alkkus apologized to Tikka and offered to show her how to fire a kinetic accelerator without ending up on the \
other side of the room, I never saw the Neophyte so happy.

I think things are finally looking up."}))

/obj/machinery/computer/loreconsole/skullakin_mine/mission_control
	name = "Mission Control"
	entries = list(
		new/datum/lore_console_entry(
			"Mission Control",
			{"## RECENT CONVERSATIONS

**Grand-Foreman**: Status report, immediately.

**Lord-Foreman**: Forgive me, Tavvikk, madame. I was meaning to contact you after deep-drilling procedures.

**Grand-Foreman**: So you found something? Ichor I hope, for your sake that is.

**Lord-Foreman**: We are detecting an ichoric presence, yes madame. We know our efforts have been mostly fruitless until now.

**Grand-Foreman**: You are the only excavation outpost that has yet to come up with anything meaningful, but this comes as a pleasant surprise. Do you require further assistance?

**Lord-Foreman**: We shouldn't, I trust my team. We're about to start the deep-drill, we'll keep you updated.

**Grand-Foreman**: Then Skkula guide you, kindred. I expect a message soon.

**Grand-Foreman**: Kkatisk! Attention! How are the operations, you have been silent for much too long.

**Grand-Foreman**: Makkath, you are ordered to report. Failure to do so will result in punishment.

**Grand-Foreman**: Lord-Foreman Makkath-Gurtask? Please come in.

**Grand-Foreman**: Corporate vessels are in the vicinity, we are unable to send a team to investigate, forgive us kindred. May Skkula guide your path."}))

/obj/machinery/computer/loreconsole/skullakin_mine/hidden_survivor
	name = "Tikka's Computer"
	entries = list(
		new/datum/lore_console_entry(
			"Log 1",
			{"I'm so scared, my vision is blurry and I won't stop shaking. Lord Makkath let me start up the drill, and it was working for a moment, \
but it fell through the ground and these things came crawling out. I couldn't move, I woke up something angry and impure, Viltaskk \
grabbed me and ran. We all tried to slow them down by spinning traps, but there were just too many. Sir Viltaskk threw me in here \
and told me he'd come back, that felt like hours ago.

I heard Alkkus screaming and cursing, the Lord-Foreman shouted after him before he ran off. I keep hearing heavy footsteps all \
around me, I want to go home. Askkith and Baskka were screaming down the hall, the Cycler rounds were deafening, but now I miss \
them. I don't know where Altus went, maybe he's still alive?

Hopefully Makkath called for help, I know he'll get us out of this."}),

		new/datum/lore_console_entry(
			"Log 2",
			{"I thought about walking outside and accepting fate today, everything is dead quiet, but I still hear growling and stomping. I can't \
stop crying. Hakk-eh, why me? Did I do something wrong? I'm starving and have nothing to eat, but I'm too scared to leave. I want Altus, \
I want Viltaskk, I wasn't made for this. Please, anybody, demons or constructs, I don't want to die here."}),

		new/datum/lore_console_entry(
			"Log 3",
			{"Everythingg is fadingc. It's getbting hardd to bbreathe. I haardly havve the strength ttyo cry anymotrre. Skkula, pleaase help p, I'm sccared. \
I just want tto gop hoome, pplease. Is thhis a cruuel jjoke, oor wass this ffate? Please gguide me, I ddon't want to makke this jjourney alone. \
Aare they waiting for me, did they rreach you? Skkula? It's so ccold. Helpp."}))
