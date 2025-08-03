/**
  * # MANUALS (BOOKS)
  *
  * These are "programmatic books," that is books that are hard-coded into the game. Just for the sake of maintainability, keep
  * information subject to change (as in likely to change SOON) out of the non-wiki manuals as they require PRs to change
  * and it is not an author's responsbility to update manuals if they change a mechanic/recipe/feature referenced in one of them
  * Don't worry about adding them to the library, as long as they're one of these types it is automatically added.
  *
  * Longer Guides should really be a '/obj/item/book/manual/wiki' type book and be tethered to a wiki page, this is because wiki pages
  * outside of SOP & Space Law can be very easily changed and do not require going through the Pull Request process. The benefits of
  * these are that they can be illustrated, filled with tables, and changed without affecting the codebase.
  *
  * However, contributors should avoid making every book/page tethered to a wiki page for a few reasons:
  * 1. many players who are likely just starting out would benefit from only getting a little bit of info to get started (think 5-10 bar recipes)
  * 2. Wiki pages are purposefully dry and to the point, manuals benefit from having flavor/personality to them to make them interesting to read ICly
  * 3. One can just open the damn wiki instead of reading a crusty-ass manual
  * -Sirryan2002
  */

/obj/item/book/manual
	//While piracy is a heinious deed, we don't want people uploading programmatic books into the player book DB for obvious reasons
	copyright = TRUE
	name = "Book Manual"
	desc = "Please make a report on the github if you somehow get ahold of one of these in-game."
	summary = "This is a manual procured by Nanotrasen, it contains important information!"
	//Pages has to be a list of strings, it will break the book otherwise
	pages = list({"How did we get here? Anyway, if you are reading this please make a report on the Github as you should not
					be able to possess this object in the first place!"})

/obj/item/book/manual/detective
	name = "The Film Noir: Proper Procedures for Investigations"
	desc = "A gumshoe's guide to find out whodunnit, howdunnit, and wheredunnit."
	summary = "A how-to manual for basic forensic procedures and detective work."
	icon_state ="bookDetective"
	author = "Nanotrasen"
	title = "The Film Noir: Proper Procedures for Investigations"
	pages = list({"<html><meta charset='utf-8'>
			<head>
			<style>
			h1 {font-size: 18px; margin: 15px 0px 5px;}
			h2 {font-size: 15px; margin: 15px 0px 5px;}
			li {margin: 2px 0px 2px 15px;}
			ul {list-style: none; margin: 5px; padding: 0px;}
			ol {margin: 5px; padding: 0px 15px;}
			</style>
			</head>
			<body>
			<h3>Detective Work</h3>
			Between your bouts of self-narration, and drinking whiskey on the rocks, you might get a case or two to solve.<br>
			To have the best chance to solve your case, follow these directions:
			<p>
			<ol>
			<li>Go to the crime scene. </li>
			<li>Take your scanner and scan EVERYTHING (Yes, the doors, the tables, even the dog.) </li>
			<li>Once you are reasonably certain you have every scrap of evidence you can use, find all possible entry points and scan them, too. </li>
			<li>Return to your office. </li>
			<li>Using your forensic scanning computer, scan your Scanner to upload all of your evidence into the database.</li>
			<li>Browse through the resulting dossiers, looking for the one that either has the most complete set of prints, or the most suspicious items handled. </li>
			<li>If you have 80% or more of the print (The print is displayed) go to step 10, otherwise continue to step 8.</li>
			<li>Look for clues from the suit fibres you found on your perp, and go about looking for more evidence with this new information, scanning as you go. </li>
			<li>Try to get a fingerprint card of your perp, as if used in the computer, the prints will be completed on their dossier.</li>
			<li>Assuming you have enough of a print to see it, grab the biggest complete piece of the print and search the security records for it. </li>
			<li>Since you now have both your dossier and the name of the person, print both out as evidence, and get security to nab your baddie.</li>
			<li>Give yourself a pat on the back and a bottle of the ships finest vodka, you did it!. </li>
			</ol>
			<p>
			It really is that easy! Good luck!
			</body>
			</html>"})

/obj/item/book/manual/engineering_particle_accelerator
	name = "Particle Accelerator User's Guide"
	desc = "An engineer's guide to shooting relativistic particles out of a big gun."
	summary = "A quick-assembly manual for the setup of high-intensity particle accelerator systems."
	icon_state ="bookParticleAccelerator"
	author = "Engineering Encyclopedia"
	title = "Particle Accelerator User's Guide"

	pages = list({"<html><meta charset='utf-8'>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h3>Experienced user's guide</h3>

				<h4>Setting up</h4>

				<ol>
					<li><b>Wrench</b> all pieces to the floor</li>
					<li>Add <b>wires</b> to all the pieces</li>
					<li>Close all the panels with your <b>screwdriver</b></li>
				</ol>

				<h4>Use</h4>

				<ol>
					<li>Open the control panel</li>
					<li>Set the speed to 2</li>
					<li>Start firing at the singularity generator</li>
					<li><font color='red'><b>When the singularity reaches a large enough size so it starts moving on it's own set the speed down to 0, but don't shut it off</b></font></li>
					<li>Remember to wear a radiation suit when working with this machine... we did tell you that at the start, right?</li>
				</ol>

				</body>
				</html>"})



/obj/item/book/manual/supermatter_engine
	name = "Supermatter Engine Anomaly Reference"
	desc = "An engineer's best tool for dealing with their worst frenemy: The Supermatter and its anomalous behavior."
	summary = "A quick-reference booklet on Supermatter anomalies and their effects."
	icon_state = "bookParticleAccelerator"
	author = "Vroo-Looum-Kloo"
	title = "Supermatter Engine Anomaly Reference"

	pages = list({"Engineering notes on single-stage Supermatter engine,</br>
			Vroo-Looum-Kloo</br>

			The supermatter engine is a very powerful, yet strange method of power generation. This guide will serve as a pocket reference for the myriad of anomalous behaviors it may exhibit throughout your shift. Below is a table of events and their effects.</br></br></br>

			D Class: Events that only affect certain types of NON-STANDARD setups, minimial operator intervention required. These events occur instantly and engineering will be alerted on telecomms.</br></br>

			D-1: About 200 moles of nitrous oxide are released by the crystal.</br>
			D-2: About 200 moles of nitrogen are released by the crystal</br>
			D-3: About 250 moles of CO2 are released by the crystal</br></br></br>

			C Class: Events with mild effects to standard setups. Operator intervention MAY be required. Engineering will be alerted on telecomms.</br></br>
			C-1: 250 moles of oxygen are released by the crystal</br>
			C-2: 250 moles of plasma are released by the crystal</br>
			C-3: The temperature at which the engine starts to lose integrity is lowered for a few minutes.</br></br></br>

			B Class: Events with significant effects to standard setups. Action may need to be taken to prevent a delamination event.</br></br>
			B-1: The amount of plasma and O2 released by the engine is doubled for a few minutes.</br>
			B-2: The amount of heat released by the engine is increased for a few minutes.</br>
			B-3: The engine's EER is raised slightly above critically for several minutes, regardless of outside factors.</br></br></br>

			A Class: Events with SEVERE effects to standard setups. Action will need to be taken to prevent a delamination event.</br></br>
			A-1: The engine's APC is shorted due to a power spike, requiring its wires to be mended.</br>
			A-2: The engine's air alarm resets its self as an effect of radiological interference.</br>
			A-3: The amount of plasma and O2 released by the engine is quadrupled for a few minutes.</br></br>

			S Class events: Events that require immediate intervention and a specialized response to prevent a delamination event. Coordination with other departments is HIGHLY recommended. A warning will be broadcasted on engineering communications before these events.</br></br>
			Arc Type: The engine's EER is raised massively several minutes, resulting it a supercritical state.</br>
			Heat Type: The amount of heat released by the engine is massively increased for several minutes.</br></br>

			In the event that an anomaly NOT on this list presents itself, contact your local Nanotrasen Engineering Officer as soon as possible.</br>
			-Vroo-Looum-Kloo, Senior Engine Technician."})

/obj/item/book/manual/atmospipes
	name = "Pipes and You: Getting To Know Your Scary Tools"
	desc = "A plumber's guide on how to properly identify a pipe."
	summary = "A handy encyclopedia on the many different flavors of pipe and device available to Atomspherics."
	icon_state = "pipingbook"
	author = "Maria Crash, Senior Atmospherics Technician"
	title = "Pipes and You: Getting To Know Your Scary Tools"
	pages = list({"<html><meta charset='utf-8'>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h1 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<font face="Verdana" color=black>
				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#Forward">Author's Forward</a></li>
					<li><a href="#Basic">Basic Piping</a></li>
					<li><a href="#Insulated">Insulated Pipes</a></li>
					<li><a href="#Devices">Atmospherics Devices</a></li>
					<li><a href="#HES">Heat Exchange Systems</a></li>
					<li><a href="#Final">Final Checks</a></li>
				</ol>
				<br><br>
				<h1><a name="Forward"><u><b>HOW TO NOT SUCK QUITE SO HARD AT ATMOSPHERICS</b></u></a></h1><br>
				<i>Or: What the fuck does a "passive gate" do?</i><br><br>
				Alright. It has come to my attention that a variety of people are unsure of what a "pipe" is and what it does.
				Apparently there is an unnatural fear of these arcane devices and their "gases". Spooky, spooky. So,
				this will tell you what every device constructable by an ordinary pipe dispenser within atmospherics actually does.
				You are not going to learn what to do with them to be the super best person ever, or how to play guitar with passive gates,
				or something like that. Just what stuff does.<br><br>
				<h1><a name="Basic"><b>Basic Pipes</b></a></h1><br>
				<i>The boring ones.</i><br>
				Most ordinary pipes are pretty straightforward. They hold gas. If gas is moving in a direction for some reason, gas will flow in that direction.
				That's about it. Even so, here's all of your wonderful pipe options.<br>
				<li><i>Straight pipes:</i> They're pipes. One-meter sections. Straight line. Pretty simple. Just about every pipe and device is based around this
				standard one-meter size, so most things will take up as much space as one of these.</li>
				<li><i>Bent pipes:</i> Pipes with a 90 degree bend at the half-meter mark. My goodness.</li>
				<li><i>Pipe manifolds:</i> Pipes that are essentially a "T" shape, allowing you to connect three things at one point.</li>
				<li><i>4-way manifold:</i> A four-way junction.</li>
				<li><i>Pipe cap:</i> Caps off the end of a pipe. Open ends don't actually vent gas, because of the way the pipes are assembled, so, uh. Use them to decorate your house or something.</li>
				<li><i>Manual/Digital Valves:</i> A valve that will block off gas flow when turned. Manual valves can't be used by the AI or cyborgs because they don't have hands, but they can access digital valves.</li>
				<li><i>Manual/Digital T-Valves:</i> Like a straight valve, but at the center of a manifold instead of a straight pipe, allowing you to swap between two different pipe networks.</li><BR><BR>
				<h1><a name="Insulated"><b>Insulated Pipes</b></a></h1><br>
				<i>Special Public Service Announcement.</i><br>
				Our regular pipes are already insulated. These are completely worthless. Punch anyone who uses them.<br><br>
				<h1><a name="Devices"><b>Devices: </b></a></h1><br>
				<i>They actually do something.</i><br>
				This is usually where people get frightened, </font><font face="Verdana" color=black>afraid, and start calling on their gods and/or cowering in fear. Yes, I can see you doing that right now.
				Stop it. It's unbecoming. Most of these are fairly straightforward.<br>
				<li><i>Gas Pump:</i> Take a wild guess. It moves gas in the direction it's pointing (marked by the red line on one end). It moves it based on pressure, the maximum output being 4500 kPa (kilopascals).
				Ordinary atmospheric pressure, for comparison, is 101.3 kPa, and the minimum pressure of room-temperature pure oxygen needed to not suffocate in a matter of minutes is 16 kPa
				(though 18 is preferred using internals, for various reasons).</li>
				<li><i>Volume pump:</i> This pump goes based on volume, instead of pressure, and the possible maximum pressure it can create in the pipe on the receiving end is double the gas pump because of this,
				clocking in at an incredible 9000 kPa. If a pipe with this is destroyed or damaged, and this pressure of gas escapes, it can be incredibly dangerous depending on the size of the pipe filled.
				Don't hook this to the distribution loop, or you will make babies cry and the Chief Engineer brutally beat you.</li>
				<li><i>Passive gate:</i> This is essentially a cap on the pressure of gas allowed to flow in a specific direction.
				When turned on, instead of actively pumping gas, it measures the pressure flowing through it, and whatever pressure you set is the maximum: it'll cap after that.
				In addition, it only lets gas flow one way. As with pumps, the red handle on a passive gate indicates the direction the passive gate will output its gas when active.</li>
				<li><i>Unary vent:</i> The basic vent used in rooms. It pumps or siphons gas in or out of a room depending on the setting. Controlled by the room's air alarm system.</li>
				<li><i>Scrubber:</i> The other half of room equipment. Filters air and can suck it in entirely in what's called a "panic siphon". Activating a panic siphon without very good reason will kill someone. Don't do it.
				Scrubbers also have an extended mode that can be enabled to expand the range and increase the amount of gas being filtered.</li>
				<li><i>Passive Vent:</i> Passive vents are the lesser known cousin to Unary vents. Passive vents will exchange gas between the surrounding atmosphere and its connected pipe until the pressure between the two has reached an equilibrium.</li>
				<li><i>Meter:</i> A little box with some gauges and numbers. Fasten it to any pipe or manifold, and it'll read you the pressure in it. Very useful.</li>
				<li><i>Gas mixer:</i> Two sides are input, one side is output. Mixes the gases pumped into it at the ratio defined. The side perpendicular to the other two is "node 2", for reference.
				Can output this gas at pressures from 0-4500 kPa.</li>
				<li><i>Gas filter:</i> Essentially the opposite of a gas mixer. One side is input. The other two sides are output. The selected gas type will be filtered into the perpendicular output pipe,
				the rest will continue out the other side. Can also output from 0-4500 kPa.</li>
				<h1><a name="HES"><b>Heat Exchange Systems</b></a></h1><br>
				<i>Will not set you on fire.</i><br>
				These systems are used to transfer heat only between two pipes. They will not move gases or any other element, but will equalize the temperature (eventually). Note that because of how gases work (remember: pv=nRt),
				a higher temperature will raise pressure, and a lower one will lower temperature.<br>
				<li><i>Pipe:</i> This is a pipe that will exchange heat with the surrounding atmosphere. Place in a fire for superheating. Place in space for supercooling.</li>
				<li><i>Bent Pipe:</i> Take a wild guess.</li>
				<li><i>Junction:</i><i>Junction:</i>The point where you connect your normal pipes to heat exchange pipes. Not necessary for heat exchangers, but necessary for H/E pipes/bent pipes.</li>
				<li><i>Heat Exchanger:</i> These funky-looking bits attach to an open pipe end. Put another heat exchanger directly across from it, and you can transfer heat across two pipes without having to have the gases mix.
				This normally shouldn't exchange with the ambient air, despite being totally exposed. Just don't ask questions...</li><BR>
				<h1><a name="HES"><b>Final Checks</b></a></h1><br>
				That's about it for pipes. Remember to turn your magboots on and keep a fire extinguisher near. Go forth, armed with this knowledge, and try not to break, burn down, or kill anything. Please.</font>
				</body>
				</html>
			"})

/obj/item/book/manual/evaguide
	name = "EVA Gear and You: Not Spending All Day Inside"
	desc = "An outdated guidebook outlining the ups and downs of various pieces of EVA gear. Considering it references hardsuits, it must be a decade old at the least."
	summary = "A beginner's guide to the pros and cons of various suit classes."
	icon_state = "evabook"
	author = "Maria Crash, Senior Atmospherics Technician"
	title = "EVA Gear and You: Not Spending All Day Inside"
	pages = list({"<html><meta charset='utf-8'>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h1 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<font face="Verdana" color=black>
				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#Forward">A forward on using EVA gear</a></li>
					<li><a href="#Civilian">Donning a Civilian Suits</a></li>
					<li><a href="#Hardsuit">Putting on a Hardsuit</a></li>
					<li><a href="#Final">Final Checks</a></li>
				</ol>
				<br><BR>
				<h1><a name="Forward">EVA Gear and You: Not Spending All Day Inside</a></h1><BR>
				<I>Or: How not to suffocate because there's a hole in your shoes</I><BR><BR>
				EVA gear. Wonderful to use. It's useful for mining, engineering, and occasionally just surviving, if things are that bad. Most people have EVA training,
				but apparently there are some on a space station who don't. This guide should give you a basic idea of how to use this gear, safely. It's split into two sections:
				Civilian suits and hardsuits.<BR><BR>
				<h1><a name="Civilian">Civilian Suits</a></h1><BR>
				<I>The bulkiest things this side of Alpha Centauri</I><BR>
				These suits are the grey ones that are stored in EVA. They're the more simple to get on, but are also a lot bulkier, and provide less protection from environmental hazards such as radiaion or physical impact.
				As Medical, Engineering, Security, and Mining all have hardsuits of their own, these don't see much use, but knowing how to put them on is quite useful anyways.<BR><BR>
				First, take the suit. It should be in three pieces: A top, a bottom, </font><font face="Verdana" color=black>and a helmet. Put the bottom on first, shoes and the like will fit in it. If you have magnetic boots, however,
				put them on on top of the suit's feet. Next, get the top on, as you would a shirt. It can be somewhat awkward putting these pieces on, due to the makeup of the suit,
				but to an extent they will adjust to you. You can then find the snaps and seals around the waist, where the two pieces meet. Fasten these, and double-check their tightness.
				The red indicators around the waist of the lower half will turn green when this is done correctly. Next, put on whatever breathing apparatus you're using, be it a gas mask or a breath mask. Make sure the oxygen tube is fastened into it.
				Put on the helmet now, straight forward, and make sure the tube goes into the small opening specifically for internals. Again, fasten seals around the neck, a small indicator light in the inside of the helmet should go from red to off when all is fastened.
				There is a small slot on the side of the suit where an emergency oxygen tank or</font><font face="Verdana" color=black> extended emergency oxygen tank will fit,
				but it is reccomended to have a full-sized tank on your back for EVA.<BR><BR>
				<h1><a name="Hardsuit">Hardsuits</a></h1><BR>
				<I>Heavy, uncomfortable, still the best option.</I><BR>
				These suits come in Engineering, Mining, and the Armory. There's also a couple Medical Hardsuits in EVA. These provide a lot more protection than the standard suits.<BR><BR>
				Similarly to the other suits, these are split into three parts. Fastening the pant and top are mostly the same as the other spacesuits, with the exception that these are a bit heavier,
				though not as bulky. The helmet goes on differently, with the air tube feeing into the suit and out a hole near the left shoulder, while the helmet goes on turned ninety degrees counter-clockwise,
				and then is screwed in for one and a quarter full rotations clockwise, leaving the faceplate directly in front of you. There is a small button on the right side of the helmet that activates the helmet light.
				The tanks that fasten onto the side slot are emergency tanks, as</font><font face="Verdana" color=black> well as full-sized oxygen tanks, leaving your back free for a backpack or satchel.<BR><BR>
				<h1><a name="Final">FINAL CHECKS:</a></h1><BR>
				<li>Are all seals fastened correctly?</li>
				<li>Do you either have shoes on under the suit, or magnetic boots on over it?</li>
				<li>Do you have a mask on and internals on the suit or your back?</li>
				<li>Do you have a way to communicate with the station in case something goes wrong?</li>
				<li>Do you have a second person watching if this is a training session?</li><BR>
				If you don't have any further issues, go out and do whatever is necessary.</font>
				</body>
				</html>
			"})

/obj/item/book/manual/engineering_singularity_safety
	name = "Singularity Safety in Special Circumstances"
	desc = "A sufficiently succinct suppliment to securing singularities."
	summary = "An easily digestable field guide for singularity-related emergencies."
	icon_state ="bookEngineeringSingularitySafety"
	author = "Engineering Encyclopedia"
	title = "Singularity Safety in Special Circumstances"

	pages = list({"<html><meta charset='utf-8'>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Singularity Safety in Special Circumstances</h3>

				<h4>Power outage</h4>

				A power problem has made the entire station loose power? Could be station-wide wiring problems or syndicate power sinks. In any case follow these steps:
				<p>
				<b>Step one:</b> <b><font color='red'>PANIC!</font></b><br>
				<b>Step two:</b> Get your ass over to engineering! <b>QUICKLY!!!</b><br>
				<b>Step three:</b> Get to the <b>Area Power Controller</b> which controls the power to the emitters.<br>
				<b>Step four:</b> Swipe it with your <b>ID card</b> - if it doesn't unlock, continue with step 15.<br>
				<b>Step five:</b> Open the console and disengage the cover lock.<br>
				<b>Step six:</b> Pry open the APC with a <b>Crowbar.</b><br>
				<b>Step seven:</b> Take out the empty <b>power cell.</b><br>
				<b>Step eight:</b> Put in the new, <b>full power cell</b> - if you don't have one, continue with step 15.<br>
				<b>Step nine:</b> Quickly put on a <b>Radiation suit.</b><br>
				<b>Step ten:</b> Check if the <b>singularity field generators</b> withstood the down-time - if they didn't, continue with step 15.<br>
				<b>Step eleven:</b> Since disaster was averted you now have to ensure it doesn't repeat. If it was a powersink which caused it and if the engineering apc is wired to the same powernet, which the powersink is on, you have to remove the piece of wire which links the apc to the powernet. If it wasn't a powersink which caused it, then skip to step 14.<br>
				<b>Step twelve:</b> Grab your crowbar and pry away the tile closest to the APC.<br>
				<b>Step thirteen:</b> Use the wirecutters to cut the wire which is conecting the grid to the terminal. <br>
				<b>Step fourteen:</b> Go to the bar and tell the guys how you saved them all. Stop reading this guide here.<br>
				<b>Step fifteen:</b> <b>GET THE FUCK OUT OF THERE!!!</b><br>
				</p>

				<h4>Shields get damaged</h4>

				Step one: <b>GET THE FUCK OUT OF THERE!!! FORGET THE WOMEN AND CHILDREN, SAVE YOURSELF!!!</b><br>
				</body>
				</html>
				"})

/obj/item/book/manual/medical_cloning
	name = "Introduction to Cloning"
	desc = "A guide covering the basics of cloning."
	summary = "A step-by-step guide to each part of the cloning process."
	icon_state = "bookCloning"
	author = "Bioarchitect for the Pillars of Creation" //this is a valid nian name, right?
	title = "Introduction to Cloning"

	pages = list({"<html><meta charset='utf-8'>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h3>How to Clone People</h3>
				Picture the scene: there's five corpses surrounding you, the Chief Medical Officer is yelling something \
				about terror spiders into their radio, and you only graduated medical school last week. What are you supposed to do? <br> \
				Well, Thinktronics Corporation is proud to present you the new and improved TTC-5601 cloning device - capable of \
				economically resuscitating even the most damaged of bodies. What follows is a guide on how to use this newer model \
				of cloning machine and where it differs from previous models.

				<ol>
					<li><a href='#1'>Preparation</a></li>
					<li><a href='#2'>Load into Cloning Scanner</a></li>
					<li><a href='#3'>Scan Patient</a></li>
					<li><a href='#4'>Configure Device</a></li>
					<li><a href='#5'>Clone</a></li>
					<li><a href='#6'>Finish Procedure</a></li>
				</ol>

				<a name='1'><h4>Step 1: Preparation</h4>
				Your patient must be dead to clone them (as of the Cloning Regulatory Act of 2533). Therefore, make sure that \
				they are deceased before proceeding, and ideally try to revive them via defibrillation! If that fails, however, \
				you should strip them of their equipment and check to make sure the cloning pod is loaded with, at least, 250 \
				biomass. <br>
				If your patient has a lot of damage, it'll take a lot of biomass to clone them! If you do not have ample biomass \
				or simply want to conserve it, try to tend to the cadaver's wounds before proceeding. In addition, fixing broken \
				bones and internal bleeds via cloning will consume Osseous Reagent and Sanguine Reagent respectively - these are \
				both much harder to replenish than biomass, so consider being polite to your chemists and fixing these via \
				surgery instead.

				<a name='2'><h4>Step 2: Load into Cloning Scanner</h4>
				After stripping your patient, load them into the cloning device's scanning machine, as you would with any other \
				device.

				<a name='3'><h4>Step 3: Scan Patient</h4>
				Access the cloning device's terminal, then navigate to the Damage Configuration menu and click 'scan.' If you see \
				'Scan Successful' - great! Move on to the next step. If not, the device will inform you about what went wrong with \
				the process. If it says it failed to sequence the patient's brain, try to scan them again in a few seconds. \

				<a name='4'><h4>Step 4: Configure Device</h4>
				This step is where the TTC-5601 cloning device diverges from its earlier models. Its advanced systems allow you to \
				conserve resources and elect to <i>not</i> fix certain damages, or elect to fix all damages - all on the fly! Keep \
				in mind that if you're short on resources, you'll <i>have</i> to leave some damages on the patient in order to clone \
				them. Once you're done tweaking settings, proceed to the next step.

				<a name='5'><h4>Step 5: Clone</h4>
				This is the simplest, but most important step. Simply press 'Clone' in the Damage Configuration menu, and the machine \
				will begin the process of cloning. The process is fully automatic, so feel free to take care of other chores in the \
				meanwhile - like moving the scanned cadaver to the morgue.

				<a name='6'><h4>Step 6: Finish Procedure</h4>
				After cloning, the patient may be disoriented - help them to get their bearings and put on the gear you stripped from \
				their previous body. In addition, make sure to fix any wounds you may have left to save resources before sending them off.

				<p>Congratulations! You now know how to use the TTC-5601 model cloning device. Please direct any further questions you have \
				to your Chief Medical Officer. <i>Warranty void if used on living people, changeling organisms, or cluwnes.</i>
				</body>
				</html>
				"})

/obj/item/book/manual/zombie_manual
	name = "Plague and You: Curing the Apocalypse"
	desc = "A guide covering the basics of curing zombies."
	summary = "A step-by-step guide to combatting each phase of the zombie virus."
	icon_state = "bookCloning"
	author = "Cleanses-The-Plague"
	title = "Plague and You: Curing the Apocalypse"

	pages = list({"<html><meta charset='utf-8'>
				<head>
				<style>
				</style>
				</head>
				<body>

				For years, we've seen "zombies" on the news and in movies, but have you ever thought how would would be cured?
				Each strain of the "Advanced Resurection Virus" or simply "Necrotizing Plague" has its own unique bio-signature.
				Therefore, each strain has a unique step of anti-virals, that each have progressively stronger effects on the plague.

				<ol>
					<li><a href='#1'>Preparation</a></li>
					<li><a href='#2'>Containing a test subject</a></li>
					<li><a href='#3'>Creating Cures</a></li>
					<li><a href='#4'>Cure Effects</a></li>
					<li><a href='#5'>Known Recipes</a></li>
				</ol>

				<a name='1' /><h4>Step 1: Preparation</h4>
				First step is knowledge. The necrotizing plague can only be spread through direct fluid contact with an infected individual. \
				Therefore, you should do your best to stay away from the claws and or teeth of zombies. Their claws are covered in a slimy fluid \
				that has a chance of transmitting the disease. Their bites are much more dangerous however, guaranteeing an infection of the plague. \
				Biohazard suits, riot gear, or other thick material are well suited for blocking these infectious attacks, but do not guaratee \
				complete immunity. <br>

				To begin, we will need to gather a blood sample from a zombifed individual. To do this, first make sure the \
				zombie is dead and severely damaged. Damaged zombies will slowly heal, and re-awaken once they are healed. \
				Then use a syringe to extract a blood sample, and return to your virology lab. <br>

				<a name='2' /><h4>Step 2: Containing a test subject</h4>
				With your new blood sample of the plague, place a monkey in a solitary pen, and infect it with the virus. This test subject \
				will provide us with a steady source of plague blood to experiment with. Lower-sapience creatures are normally not advanced enough to \
				actively seek out the flesh of living creatures, and are safe in captivity. Containing an active zombie is much harder and will require \
				a cell of pure walls or doors. Otherwise, the zombie will be able to break out of it's cell using its claws.

				<a name='3' /><h4>Step 3: Creating Cures</h4>
				Now that a steady source of infected blood is available, we can begin making cures. There are 4 tiers of "cures" for the plague, \
				these are referred to as "Anti-Plague Sequences". By combining chemicals with the plague and viral symptoms, more advanced sequences \
				can be created. These sequences are M-RNA that alters protein synthesis of plague-infected individuals and alter B-lymphocytes to induce\
				specific anti-bodies, countering the effects of the virus. \
				There sequences are classified into 4 categories: Alpha, Beta, Gamma, and Omega. Alpha is the simplest, but weakest. \
				Omega is the most difficult to make as it requires all previous sequences and advanced chemicals. <br>
				Since each of zombie strains are unique, there is no known recipe for these, and will require experimentation. \
				However, several researchers have compiled chemicals that are commonly found in these cures in the "Known Recipes" section below.

				<a name='4' /><h4>Step 5: Cure Effects</h4>
				Anti-Plague Sequence Alpha is the simplest anti-viral, but it still is the first step against the plague. \
				This cure prevents infection from scratches while in system of the user, and can cure stage 1 infections. <br>

				Anti-Plague Sequence Beta is the second anti-viral, and is more complex to make. This sequence has been shown to cure \
				infections that are stage 3 or below. This sequence is sometimes able to cure bites from infected individuals. <br>

				Anti-Plague Sequence Gamma is the third anti-viral. This sequence is difficult to manufacture, but is rewarding. \
				It cures all infections that are stage 5 and below, and stops the effects of stage 6 infections, but will not cure \
				stage 6 infections. This helps prevent the rotting of living people into the rotting and shambling corpses of zombies. <br>

				Anti-Plague Sequence Omega is the full cure for the zombie plague. This advanced mix of viral symptoms and chemicals is \
				the final cure for any Advanced Resurection Virus. This cure prevents zombies from reviving when in their system, and will \
				slowly return their body to normal, non-infected state. <br>

				<a name='5' /><h4>Step 6: Known Recipes</h4>
				<b>Anti-Plague Sequence Alpha</b>
				<ul>
					<li>1 unit of blood containing any zombie plague</li>
					<li>1 unit of Diphenhydramine</a></li>
				</ul>

				<b>Anti-Plague Sequence Beta</b>
				<ul>
					<li>1 unit of blood containing zombie plague cured by Anti-Plague Sequence Alpha</li>
					<li>3 random chemicals from the list below, 1 unit of each (Unknown Random Recipe)
						<ul>
							<li>Saline-Glucose Solution</li>
							<li>Toxin</li>
							<li>Atropine</li>
							<li>Lye</li>
							<li>Soda Water</li>
							<li>Happiness</li>
							<li>Morphine</li>
							<li>Teporone</li>
						</ul>
					</li>
				</ul>

				<b>Anti-Plague Sequence Gamma</b>
				<ul>
					<li>1 unit of blood containing zombie plague cured by Anti-Plague Sequence Beta</li>
					<li>1 unit of blood containing an advanced virus with the <b>"Necrotizing Fasciitis"</b> symptom</li>
					<li>3 random chemicals from the list below, 1 unit of each (Unknown Random Recipe)
						<ul>
							<li>Yellow Vomit</li>
							<li>Jenkem</li>
							<li>Charcoal</li>
							<li>Egg</li>
							<li>Sulphuric acid</li>
							<li>Fluorosulfuric Acid</li>
							<li>Surge</li>
							<li>Ultra-Lube</li>
							<li>Mitocholide</li>
						</ul>
					</li>
				</ul>

				<b>Anti-Plague Sequence Omega</b>
				<ul>
					<li>1 unit of blood containing zombie plague cured by Anti-Plague Sequence Gamma</li>
					<li>1 unit of blood containing an advanced virus with the <b>"Anti-Bodies Metabolism"</b> symptom</li>
					<li>2 of the chemicals from the list below, 1 unit of each (Unknown Random Recipe)
						<ul>
							<li>Colorful Reagent</li>
							<li>Bacchus' Blessing</li>
							<li>Pentetic Acid</li>
							<li>Glyphosate</li>
							<li>Lazarus Reagent</li>
							<li>Omnizine</li>
							<li>Sarin</li>
							<li>Ants</li>
							<li>Chlorine Trifluoride</li>
							<li>Sorium</li>
							<li>"????" Reagent</li>
							<li>Aranesp</li>
						</ul>
					</li>
				</ul>

				<b>Anti-Plague Sequence Duplication</b>
				<ul>
					<li>1 unit of any Anti-Plague Sequence</li>
					<li>1 unit of Sulfonal</li>
					<li>1 unit of Sugar</li>
				</ul>


				<p>Congratulations! You are now qualitifed in creating Anti-Plague Sequences for combatting Class-C resurrecting un-dead beings. \
				Please direct any further questions you have to your Chief Medical Officer.</p>
				</body>
				</html>"})

/obj/item/book/manual/ripley_build_and_repair
	name = "APLU \"Ripley\" Construction and Operation Manual"
	desc = "A small guidebook on how to operate a Ripley powerloader exosuit. It's filled with disclaimers and pre-signed waivers."
	summary = "Standard operational practices and construction requirements for operation of the Ripley mk. 3 powerloader system."
	author = "Hephaestus Industries"
	title = "APLU \"Ripley\" Construction and Operation Manual"

	pages = list({"<html><meta charset='utf-8'>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<center>
				<b style='font-size: 12px;'>Hephaestus Industries - Forging the Tools of Tomorrow</b>
				<h1>Autonomous Power Loader Unit \"Ripley\"</h1>
				</center>
				<h2>Specifications:</h2>
				<ul>
				<li><b>Class:</b> Autonomous Power Loader</li>
				<li><b>Scope:</b> Logistics and Construction</li>
				<li><b>Weight:</b> 820kg (without operator and with empty cargo compartment)</li>
				<li><b>Height:</b> 2.5m</li>
				<li><b>Width:</b> 1.8m</li>
				<li><b>Top speed:</b> 5km/hour</li>
				<li><b>Operation in vacuum/hostile environment:</b> Possible</b>
				<li><b>Airtank Volume:</b> 500liters</li>
				<li><b>Devices:</b>
					<ul>
					<li>Hydraulic Clamp</li>
					<li>High-speed Drill</li>
					</ul>
				</li>
				<li><b>Propulsion Device:</b> Powercell-powered electro-hydraulic system.</li>
				<li><b>Powercell capacity:</b> Varies.</li>
				</ul>

				<h2>Construction:</h2>
				<ol>
				<li>Connect all exosuit parts to the chassis frame</li>
				<li>Connect all hydraulic fittings and tighten them up with a wrench</li>
				<li>Adjust the servohydraulics with a screwdriver</li>
				<li>Wire the chassis. (Cable is not included.)</li>
				<li>Use the wirecutters to remove the excess cable if needed.</li>
				<li>Install the central control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the mainboard with a screwdriver.</li>
				<li>Install the peripherals control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the peripherals control module with a screwdriver</li>
				<li>Install the internal armor plating (Not included due to Nanotrasen regulations. Can be made using 5 metal sheets.)</li>
				<li>Secure the internal armor plating with a wrench</li>
				<li>Weld the internal armor plating to the chassis</li>
				<li>Install the external reinforced armor plating (Not included due to Nanotrasen regulations. Can be made using 5 reinforced metal sheets.)</li>
				<li>Secure the external reinforced armor plating with a wrench</li>
				<li>Weld the external reinforced armor plating to the chassis</li>
				<li></li>
				<li>Additional Information:</li>
				<li>The firefighting variation is made in a similar fashion.</li>
				<li>A firesuit must be connected to the Firefighter chassis for heat shielding.</li>
				<li>Internal armor is plasteel for additional strength.</li>
				<li>External armor must be installed in 2 parts, totaling 10 sheets.</li>
				<li>Completed mech is more resiliant against fire, and is a bit more durable overall</li>
				<li>Nanotrasen is determined to the safety of its <s>investments</s> employees.</li>
				</ol>
				</body>
				</html>

				<h2>Operation</h2>
				Coming soon...
			"})

/obj/item/book/manual/research_and_development
	name = "Research and Development 101"
	desc = "The mad scientist's second best friend, after coffee."
	summary = "Construction & operational instructions for all standard Nanotrasen research machinery."
	icon_state = "rdbook"
	author = "Dr. L. Ight"
	title = "Research and Development 101"
	pages = list({"
	<html><meta charset='utf-8'>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Science For Dummies</h1>
				So you want to further SCIENCE? Good man/woman/thing! However, SCIENCE is a complicated process even though it's quite easy. For the most part, it's a three step process:
				<ol>
					<li> 1) Deconstruct items in the Scientific Analyzer to advance technology or improve the design.</li>
					<li> 2) Build unlocked designs in the Protolathe and Circuit Imprinter</li>
					<li> 3) Repeat!</li>
				</ol>

				Those are the basic steps to furthing science. What do you do science with, however? Well, you have four major tools: R&D Console, the Scientific Analyzer, the Protolathe, and the Circuit Imprinter.

				<h2>The R&D Console</h2>
				The R&D console is the cornerstone of any research lab. It is the central system from which the Scientific Analyzer, Protolathe, and Circuit Imprinter (your R&D systems) are controled. More on those systems in their own sections. On its own, the R&D console acts as a database for all your technological gains and new devices you discover. So long as the R&D console remains intact, you'll retain all that SCIENCE you've discovered. Protect it though, because if it gets damaged, you'll lose your data! In addition to this important purpose, the R&D console has a disk menu that lets you transfer data from the database onto disk or from the disk into the database. It also has a settings menu that lets you re-sync with nearby R&D devices (if they've become disconnected), lock the console from the unworthy, upload the data to all other R&D consoles in the network (all R&D consoles are networked by default), connect/disconnect from the network, and purge all data from the database.
				<b>NOTE:</b> The technology list screen, circuit imprinter, and protolathe menus are accessible by non-scientists. This is intended to allow 'public' systems for the plebians to utilize some new devices.

				<h2>Scientific Analyzer</h2>
				This is the source of all technology. Whenever you put a handheld object in it, it analyzes it and determines what sort of technological advancements you can discover from it. If the technology of the object is equal or higher then your current knowledge, you can destroy the object to further those sciences. Some devices (notably, some devices made from the protolathe and circuit imprinter) aren't 100% reliable when you first discover them. If these devices break down, you can put them into the Scientific Analyzer and improve their reliability rather then futher science. If their reliability is high enough ,it'll also advance their related technologies.

				<h2>Circuit Imprinter</h2>
				This machine, along with the Protolathe, is used to actually produce new devices. The Circuit Imprinter takes glass and various chemicals (depends on the design) to produce new circuit boards to build new machines or computers. It can even be used to print AI modules.

				<h2>Protolathe</h2>
				This machine is an advanced form of the Autolathe that produce non-circuit designs. Unlike the Autolathe, it can use processed metal, glass, solid plasma, silver, gold, and diamonds along with a variety of chemicals to produce devices. The downside is that, again, not all devices you make are 100% reliable when you first discover them.

				<h1>Reliability and You</h1>
				As it has been stated, many devices when they're first discovered do not have a 100% reliablity when you first discover them. Instead, the reliablity of the device is dependent upon a base reliability value, whatever improvements to the design you've discovered through the Scientific Analyzer, and any advancements you've made with the device's source technologies. To be able to improve the reliability of a device, you have to use the device until it breaks beyond repair. Once that happens, you can analyze it in a Scientific Analyzer. Once the device reachs a certain minimum reliability, you'll gain tech advancements from it.

				<h1>Building a Better Machine</h1>
				Many machines produces from circuit boards and inserted into a machine frame require a variety of parts to construct. These are parts like capacitors, batteries, matter bins, and so forth. As your knowledge of science improves, more advanced versions are unlocked. If you use these parts when constructing something, its attributes may be improved. For example, if you use an advanced matter bin when constructing an autolathe (rather then a regular one), it'll hold more materials. Experiment around with stock parts of various qualities to see how they affect the end results! Be warned, however: Tier 3 and higher stock parts don't have 100% reliability and their low reliability may affect the reliability of the end machine.
				</body>
				</html>
			"})

/obj/item/book/manual/barman_recipes
	name = "Barman Recipes"
	desc = "A coffee-stained guide to mixing drinks."
	summary = "A quick-access reference to several common alcoholic beverages."
	icon_state = "barbook"
	author = "Sir John Rose"
	title = "Barman Recipes"
	pages = list({"<html><meta charset='utf-8'>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h1>Drinks for dummies</h1>
				Heres a guide for some basic drinks.
				<h2>Manly Dorf:</h2>
				Mix ale and beer into a glass.
				<h2>Grog:</h2>
				Mix rum and water into a glass.
				<h2>Black Russian:</h2>
				Mix vodka and kahlua into a glass.
				<h2>Irish Cream:</h2>
				Mix cream and whiskey into a glass.
				<h2>Screwdriver:</h2>
				Mix vodka and orange juice into a glass.
				<h2>Cafe Latte:</h2>
				Mix milk and coffee into a glass.
				<h2>Mead:</h2>
				Mix Enzyme, water and sugar into a glass.
				<h2>Gin Tonic:</h2>
				Mix gin and tonic into a glass.
				<h2>Classic Martini:</h2>
				Mix vermouth and gin into a glass.
				</body>
				</html>
			"})

//*    NON-STATION Manuals    *//
//These are manuals that should not be available on-station through spawners or the library AT ALL
/obj/item/book/manual/nuclear
	name = "Fission Mailed: Nuclear Sabotage 101"
	desc = "A blood-spattered book filled with block text, educating the reader on how to detonate nuclear bombs."
	summary = "Reference material for the activation and detonation of nuclear devices. All material classified Level-1 PYTHON."
	icon_state ="bookNuclear"
	author = "Syndicate"
	protected = TRUE
	title = "Fission Mailed: Nuclear Sabotage 101"
	pages = list({"<html><meta charset='utf-8'>
			Nuclear Explosives 101:<br>
			Hello and thank you for choosing the Syndicate for your nuclear information needs.<br>
			Today's crash course will deal with the operation of a Fusion Class Nanotrasen made Nuclear Device.<br>
			First and foremost, DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.<br>
			Pressing any button on the compacted bomb will cause it to extend and bolt itself into place.<br>
			If this is done to unbolt it one must completely log in which at this time may not be possible.<br>
			To make the nuclear device functional:<br>
			<li>Place the nuclear device in the designated detonation zone.</li>
			<li>Extend and anchor the nuclear device from its interface.</li>
			<li>Insert the nuclear authorisation disk into slot.</li>
			<li>Type numeric authorisation code into the keypad. This should have been provided. Note: If you make a mistake press R to reset the device.
			<li>Press the E button to log onto the device.</li>
			You now have activated the device. To deactivate the buttons at anytime for example when you've already prepped the bomb for detonation	remove the auth disk OR press the R on the keypad.<br>
			Now the bomb CAN ONLY be detonated using the timer. Manual detonation is not an option.<br>
			Note: Nanotrasen is a pain in the neck.<br>
			Toggle off the SAFETY.<br>
			Note: You wouldn't believe how many Syndicate Operatives with doctorates have forgotten this step.<br>
			So use the - - and + + to set a det time between 5 seconds and 10 minutes.<br>
			Then press the timer toggle button to start the countdown.<br>
			Now remove the auth. disk so that the buttons deactivate.<br>
			Note: THE BOMB IS STILL SET AND WILL DETONATE<br>
			Now before you remove the disk if you need to move the bomb you can:<br>
			Toggle off the anchor, move it, and re-anchor.<br><br>
			Good luck. Remember the order:<br>
			<b>Disk, Code, Safety, Timer, Disk, RUN!</b><br>
			Intelligence Analysts believe that normal Nanotrasen procedure is for the Captain to secure the nuclear authorisation disk.<br>
			Speed and strength, operative.
			</html>"})

/obj/item/book/manual/hydroponics_pod_people
	name = "The Human Harvest - From seed to market"
	desc = "Blurry pictures of people coming out of pods are taped to the cover."
	summary = "A handy-dandy guide to growing plant-people for fun and profit!"
	icon_state ="bookHydroponicsPodPeople"
	author = "Farmer John"
	title = "The Human Harvest - From seed to market"
	pages = list({"<html><meta charset='utf-8'>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Growing Humans</h3>

				Why would you want to grow humans? Well I'm expecting most readers to be in the slave trade, but a few might actually
				want to revive fallen comrades. Growing pod people is easy, but prone to disaster.
				<p>
				<ol>
				<li>Find a dead person who is in need of cloning. </li>
				<li>Take a blood sample with a syringe. </li>
				<li>Inject a seed pack with the blood sample. </li>
				<li>Plant the seeds. </li>
				<li>Tend to the plants water and nutrition levels until it is time to harvest the cloned human.</li>
				</ol>
				<p>
				It really is that easy! Good luck!

				</body>
				</html>
				"})

/**
  * # Wiki Page Based Book Manuals
  *
  * These are programmatic books that source its pages / "content" straight from the wiki
  * That means that this content can **ONLY** be changed by editing the wiki
  * Space Law and SOP Manuals can only be edited by Wiki Admins
  *
  * These are automated well enough that as long as the link to the wiki is set correctly in the config and the article name is correct
  * these will display (mostly) CSS stripped wiki pages in them.
  */

/obj/item/book/manual/wiki
	name = "Wiki Book Manual"
	desc = "This REALLY shouldn't exist in-game, please contact a coder."
	protected = TRUE //We absolutely do not want players editing these books, it might fuck up the iframes in them :)
	pages = null //we don't want people opening this book until it fully initializes
	//Wiki Iframes need a decent bit of room, this will be enough to make the readable without having to expand the window immediately
	book_height = 800
	book_width = 800
	///The Article title of the wiki page being opened in the <iframe>, must use underscores '_' and not whitespace for spaces in title
	var/wiki_article_title = "Space_Law"

/obj/item/book/manual/wiki/Initialize(mapload)
	. = ..()
	pages = list({"
		<html><meta charset='utf-8'><head></head><body bgcolor='[book_bgcolor]'>
		<iframe width='100%' height='97%' src="[GLOB.configuration.url.wiki_url]/index.php/[wiki_article_title]?action=render" frameborder="0" id="main_frame"></iframe>
		</body></html>"})

//*    MISCELANIOUS WIKI PAGE MANUALS    *//
/obj/item/book/manual/wiki/hacking
	name = "Hacking"
	desc = "H4ck3r's H3lp3r: How to rewire almost anything."
	icon_state ="bookHacking"
	author = "Greytider Supreme"
	title = "Hacking"
	wiki_article_title = "Hacking"

/obj/item/book/manual/wiki/engineering_guide
	name = "Engineering Textbook"
	desc = "A wrenches' guide to build simple structures."
	icon_state ="bookEngineering2"
	author = "Engineering Encyclopedia"
	title = "Engineering Textbook"
	wiki_article_title = "Guide_to_Engineering"

//This robotics manual used to take up 400+ lines of code, never again.
/obj/item/book/manual/wiki/robotics_cyborgs
	name = "Cyborgs for Dummies"
	desc = "Precise instructions on how to construct your very own robotic friend."
	summary = "Standard construction and maintenance procedures for Nanotrasen silicon units."
	icon_state = "borgbook"
	author = "XISC"
	title = "Cyborgs for Dummies"
	wiki_article_title = "Guide_to_Robotics"

/obj/item/book/manual/wiki/engineering_construction
	name = "Station Repairs and Construction"
	desc = "A guide on how to fix things without duct tape."
	summary = "A comprehensive reference for the construction and maintenance of most on-station equipment."
	icon_state ="bookEngineering"
	author = "Engineering Encyclopedia"
	title = "Station Repairs and Construction"
	wiki_article_title = "Guide_to_Construction"

/obj/item/book/manual/wiki/faxes
	name = "Guide to Faxes"
	desc = "Nanotrasen's own manual on how to write faxes."
	summary = "A comprehensive reference on protocol for the writing and sending of faxes."
	icon_state ="bookEngineering"
	author = "Nanotrasen"
	title = "Faxes and You!"
	wiki_article_title = "Guide_to_Faxes"

/obj/item/book/manual/wiki/hydroponics
	name = "General Hydroponics"
	desc = "A guide outlining the principles of hydroponics."
	summary = "A comprehensive reference on the identification and growth of various usable plants."
	icon_state ="bookHydroponicsGeneral"
	author = "Nanotrasen"
	title = "General Hydroponics"
	wiki_article_title = "Guide_to_Hydroponics"

/obj/item/book/manual/wiki/botanist
	name = "The Station Botanist Handbook"
	desc = "A handbook with instructions and tips for station botanists."
	summary = "A quick reference guide to the responsibilities and tasks of the station's Botany contingent."
	icon_state ="bookHydroponicsBotanist"
	author = "Nanotrasen"
	title = "The Station Botanist Handbook"
	wiki_article_title = "Botanist"

 //* STANDARD OPERATING PROCEDURE MANUALS *// (and space Law)

/obj/item/book/manual/wiki/security_space_law
	name = "Space Law"
	desc = "A set of Nanotrasen guidelines for keeping law and order on their space stations."
	icon_state = "bookSpaceLaw"
	force = 4 //advanced magistrate tactics
	author = "Nanotrasen"
	title = "Space Law"
	wiki_article_title = "Space_law"

/obj/item/book/manual/wiki/security_space_law/imaginary
	name = "Imaginary Space Law Manual"
	desc = "A set of memorized Nanotrasen guidelines for keeping law and order on their space stations."
	flags = DROPDEL | ABSTRACT | NOBLUDGEON
	imaginary = TRUE

/obj/item/book/manual/wiki/security_space_law/imaginary/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SKIP_EXAMINE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_STRIP, INNATE_TRAIT)

/obj/item/book/manual/wiki/security_space_law/black
	name = "Space Law - Limited Edition"
	desc = "A leather-bound, immaculately-written copy of JUSTICE."
	icon_state = "bookSpaceLawblack"
	title = "Space Law - Limited Edition"

/obj/item/book/manual/wiki/sop_command
	name = "Command Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all Command activities."
	icon_state = "sop_command"
	author = "Nanotrasen"
	title = "Command Standard Operating Procedures"
	wiki_article_title = "Standard_Operating_Procedure_(Command)"

/obj/item/book/manual/wiki/sop_general
	name = "Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all station activities."
	icon_state = "sop"
	author = "Nanotrasen"
	title = "Standard Operating Procedures"
	wiki_article_title = "Standard_Operating_Procedure"

/obj/item/book/manual/wiki/sop_legal
	name = "Legal Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all legal activities."
	icon_state = "sop_legal"
	author = "Nanotrasen"
	title = "Legal Standard Operating Procedures"
	wiki_article_title = "Legal_Standard_Operating_Procedure"

/obj/item/book/manual/wiki/sop_legal/imaginary
	name = "Imaginary Legal SOP Manual"
	desc = "A set of memorized Nanotrasen guidelines aiming at the safe conduct of all legal activities."
	flags = DROPDEL | ABSTRACT | NOBLUDGEON
	imaginary = TRUE

/obj/item/book/manual/wiki/sop_legal/imaginary/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SKIP_EXAMINE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_STRIP, INNATE_TRAIT)

/obj/item/book/manual/wiki/sop_supply
	name = "Supply Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all supply activities."
	icon_state = "sop_cargo"
	author = "Nanotrasen"
	title = "Supply Standard Operating Procedures"
	wiki_article_title = "Standard_Operating_Procedure_(Supply)"

/obj/item/book/manual/wiki/sop_security
	name = "Security Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all security activities."
	icon_state = "sop_security"
	author = "Nanotrasen"
	title = "Security Standard Operating Procedures"
	wiki_article_title = "Standard_Operating_Procedure_(Security)"

/obj/item/book/manual/wiki/sop_service
	name = "Service Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all service activities."
	icon_state = "sop_service"
	author = "Nanotrasen"
	title = "Service Standard Operating Procedures"
	wiki_article_title = "Standard_Operating_Procedure_(Service)"

/obj/item/book/manual/wiki/sop_engineering
	name = "Engineering Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all engineering activities."
	icon_state = "sop_engineering"
	author = "Nanotrasen"
	title = "Engineering Standard Operating Procedures"
	wiki_article_title = "Standard_Operating_Procedure_(Engineering)"

/obj/item/book/manual/wiki/sop_medical
	name = "Medical Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all medical activities."
	icon_state = "sop_medical"
	author = "Nanotrasen"
	title = "Medical Standard Operating Procedures"
	wiki_article_title = "Standard_Operating_Procedure_(Medical)"

/obj/item/book/manual/wiki/sop_science
	name = "Science Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all scientific activities."
	icon_state = "sop_science"
	author = "Nanotrasen"
	title = "Science Standard Operating Procedures"
	wiki_article_title = "Standard_Operating_Procedure_(Science)"

/obj/item/book/manual/sop_ntinstructor
	name = "Career Trainer SOP"
	desc = "A set of guidelines for Instructors."
	icon_state = "sop_legal"
	author = "Nanotrasen"
	title = "Instructor SOP"
	pages = list({"
		<html>
				<head>
				<style>
				h1 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}


				</style>
				</head>
				<body>
				<h1><U><B>Instructor SOP</B></U></h1><BR>
				<p>
				<ol>
				<li>NT Career Trainers are to wear their company-provided uniform and <b>jacket OR their issued beret/hat</b> at all times while on duty. They are free to choose a beret that best matches their primary field of knowledge if they so desire. Additionally, Identifying equipment SHOULD not be distributed to crew members. </li>
				<li>NT Career Trainers are to be available to all Crewmembers, regardless of Department. You may not only assist a singular Department. </li>
				<li>NT Career Trainers are not to do a Trainee's work for them. </li>
				<li>NT Career Trainers are to use NCT Data Chips only to acquire the access necessary for providing training. They are not to use said access for other purposes. </li>
				<li>In the event of a lost or stolen NCT Data Chip, the NT Career Trainer is to report the incident to their local Nanotrasen Representative or Station Captain. </li>
				<li>NT Career Trainers are permitted to carry a flash for self-defense.</li>
				</ol>
				</body>
				</html>
		"})

 //* MANUAL SPAWNERS *// (and space Law)

/obj/item/book/manual/random
	icon_state = "random_book"
	var/static/list/banned_books = list(/obj/item/book/manual/random, /obj/item/book/manual/nuclear, /obj/item/book/manual/wiki)

/obj/item/book/manual/random/Initialize(mapload)
	..()
	var/newtype = pick(subtypesof(/obj/item/book/manual) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL
