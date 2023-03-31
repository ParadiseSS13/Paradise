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
	protected = FALSE //No reason players shouldn't write in regular manuals
	name = "Book Manual"
	desc = "Please make a report on the github if you somehow get ahold of one of these in-game"
	summary = "This is a manual procured by Nanotrasen, it contains important information!"
	//Pages has to be a list of strings, it will break the book otherwise
	pages = list({"How did we get here? Anyway, if you are reading this please make a report on the Github as you should not
					be able to possess this object in the first place!"})

/obj/item/book/manual/detective
	name = "The Film Noir: Proper Procedures for Investigations"
	desc = "A gumshoe's guide to find out whodunnit, howdunnit, and wheredunnit."
	icon_state ="bookDetective"
	author = "Nanotrasen"
	title = "The Film Noir: Proper Procedures for Investigations"
	pages = list({"<html>
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
	icon_state ="bookParticleAccelerator"
	author = "Engineering Encyclopedia"
	title = "Particle Accelerator User's Guide"

	pages = list({"<html>
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
	name = "Supermatter Engine User's Guide"
	desc = "An engineer's best tool for dealing with their worst frenemy: The Supermatter."
	icon_state = "bookParticleAccelerator"
	author = "Waleed Asad"
	title = "Supermatter Engine User's Guide"

	pages = list({"Engineering notes on single-stage Supermatter engine,</br>
			-Waleed Asad</br>

			A word of caution, do not enter the engine room, for any reason, without radiation protection and mesons on. The status of the engine may be unpredictable even when you believe it is .off.. This is an important level of personal protection.</br></br>

			The engine has two basic modes of functionality. He has observed that it is capable of both a safe level of operation and a modified, high output mode.</br></br>

			<center><b>Notes on starting the basic function mode, dubbed .Heat-Primary Mode..</b></center></br></br>

			1. Prepare collector arrays. This is done standard to any text on their function by wrenching them down, filling six plasma tanks with a plasma canister, and inserting the tank into the collectors one by one. Finally, initialize each collector.</br></br>

			2. Prepare gas system. Before introducing any gas to the Supermatter engine room, it is important to remember the small but vital steps to preparing this section. First, set the input gas pump and output gas flow pump to 4500, or maximum flow. Second, switch the digital switching valve into the .up. position, in order to circulate the gas back toward the coolers and collectors.</br></br>

			3. Apply N2 gas. Retrieve the two N2 canisters from storage and bring them to the engine room. Attach one of them to the input section of the engine gas system located next to the collectors. Keep it attached until the N2 pressure is low enough to turn the canister light red. Replace it with the second canister to keep N2 pressure at optimal levels.</br></br>

			4. Begin primary emitter burst series. This means firing a single emitter for its first four shots. It is important to move to this step quickly. The onboard SMES units may not have enough power to run the emitters if left alone too long on-station. This engine can produce enough power on its own to run the entire station, ignoring the SMES units completely, and is wired to do so.</br></br>

			5. Switch SMES units to primary settings. Maximize input and set the devices to automatically charge, additionally turn their outputs on if they are off unless power is to be saved (Which can be useful in case of later failures.)</br></br>

			6. Begin secondary emitter burst series. Before firing the emitter again, check the power in the line with a multimeter (Do not forget electrical gloves.) The engine is running at high efficiency when the value exceeds 200,000 power units.</br></br>

			7. Maintain engine power. When power in the lines gets low, add an additional emitter burst series to bring power to normal levels.</br></br></br>



			<center>The second mode for running the engine uses a gas mix to produce a reaction within the Supermatter. This mode requires CE or Atmospheric help to setup. <b>This has been dubbed the .O2-Reaction Mode..</b></center></br></br>

			<b><u>THIS MODE CAN CAUSE A RUNAWAY REACTION, LEADING TO CATASTROPHIC FAILURE IF NOT MAINTAINED. NEVER FORGET ABOUT THE ENGINE IN THIS MODE.</u></b></br></br>

			Additionally, this mode can be used for what is called a .Cold Start.. If the station has no power in the SMES to run the emitters, using this mode will allow enough power output to run them, and quickly reach an acceptable level of power output.</br></br>

			1. Prepare collector arrays. This is done standard to any text on their function by wrenching them down, filling six plasma tanks with a plasma canister, and inserting the tank into the collectors one by one. Finally, initialize each collector.</br></br>

			2. Prepare gas system. Before introducing any gas to the Supermatter engine room, it is important to remember the small but vital steps to preparing this section. First, set the input gas pump and output gas flow pump to 4500, or maximum flow. Second, switch the digital switching valve into the .up. position, in order to circulate the gas back toward the coolers and collectors.</br></br>

			3. Modify the engine room filters. Unlike the Heat-Primary Mode, it is important to change the filters attached to the gas system to stop filtering O2, and start filtering Carbon Molecules. O2-Reaction Mode produces far more plasma than Heat-Primary, therefor filtering it off is essential.</br></br>

			4. Switch SMES units to primary settings. Maximize input and set the devices to automatically charge, additionally turn their outputs on if they are off unless power is to be saved (Which can be useful in case of later failures.) If you check the power in the system lines at this point you will find that it is constantly going up. Indeed, with just the addition of O2 to the Supermatter, it will begin outputting power.</br></br>

			5. Begin primary emitter burst series. Fire a single emitter for a series of four pulses, or a single series, and turn it off. Do not over power the Supermatter. The reaction is self sustaining and propagating. As long as O2 is in the chamber, it will continue outputting MORE power.</br></br>

			6. Maintain follow up operations. Remember to check the temp of the core gas and switch to the Heat-Primary function, or vent the core room when problems begin if required.</br></br>

			Notes on Supermatter Reaction Function and Drawbacks-</br></br>

			After several hours of observation an interesting phenomenon was witnessed. The Supermatter undergoes a constant self-sustaining reaction when given an extremely high O2 concentration. Anything about 80% or higher typically will cause this reaction. The Supermatter will continue to react whenever this gas mix is in the same room as the Supermatter.</br></br>

			To understand why O2-Reaction mode is dangerous, the core principle of the Supermatter must be understood. The Supermatter emits three things when .not safe,. that is any time it is giving off power. These things are:</br></br>

			*Radiation (which is converted into power by the collectors,)</br>
			*Heat (which is removed via the gas exchange system and coolers,)</br>
			*External gas (in the form of plasma and O2.)</br>

			When in Heat-Primary mode, far more heat and plasma are produced than radiation. In O2-Reaction mode, very little heat and only moderate amounts of plasma are produced, however HUGE amounts of energy leaving the Supermatter is in the form of radiation.</br></br>

			The O2-Reaction engine mode has a single drawback which has been eluded to more than once so far and that is very simple. The engine room will continue to grow hotter as the constant reaction continues. Eventually, there will be what he calls the .critical gas mix.. This is the point at which the constant adding of plasma to the mix of air around the Supermatter changes the gas concentration to below the tolerance. When this happens, two things occur. First, the Supermatter switches to its primary mode of operation where in huge amounts of heat are produced by the engine rather than low amounts with high power output. Second, an uncontrollable increase in heat within the Supermatter chamber will occur. This will lead to a spark-up, igniting the plasma in the Supermatter chamber, wildly increasing both pressure and temperature.</br></br>

			While the O2-Reaction mode is dangerous, it does produce heavy amounts of energy. Consider using this mode only in short amounts to fill the SMES, and switch back later in the shift to keep things flowing normally.</br></br>


			Notes on Supermatter Containment and Emergency Procedures-</br></br>

			While a constant vigil on the Supermatter is not required, regular checkups are important. Verify the temp of gas leaving the Supermatter chamber for unsafe levels, and ensure that the plasma in the chamber is at a safe concentration. Of course, also make sure the chamber is not on fire. A fire in the core chamber is very difficult to put out. As any Toxin scientist can tell you, even low amounts of plasma can burn at very high temperatures. This burning creates a huge increase in pressure and more importantly, temperature of the crystal itself.</br></br>

			The Supermatter is strong, but not invincible. When the Supermatter is heated too much, its crystal structure will attempt to liquify. The change in atomic structure of the Supermatter leads to a single reaction, a massive explosion. The computer chip attached to the Supermatter core will warn the station when stability is threatened. It will then offer a second warning, when things have become dangerously close to total destruction of the core.</br></br>

			Located both within the supermatter monitoring room and engine room is the vent control button. This button allows the Core Vent Controls to be accessed, venting the room to space. Remember however, that this process takes time. If a fire is raging, and the pressure is higher than fathomable, it will take a great deal of time to vent the room. Also located in the supermatter monitoring room is the emergency core eject button. A new core can be ordered from cargo. It is often not worth the lives of the crew to hold on to it, not to mention the structural damage. However, if by some mistake the Supermatter is pushed off or removed from the mass ejector it sits on, manual reposition will be required. Which is very dangerous and often leads to death.</br></br>

			The Supermatter is extremely dangerous. More dangerous than people give it credit for. It can destroy you in an instant, without hesitation, reducing you to a pile of dust. When working closely with Supermatter it is.. suggested to get a genetic backup and do not wear any items of value to you. The Supermatter core can be pulled if grabbed properly by the base, but <b>pushing is not possible.</b></br></br></br>


			In Closing-</br></br>

			Remember that the Supermatter is dangerous, and the core is dangerous still. Venting the core room is always an option if you are even remotely worried, utilizing Atmospherics to properly ready the room once more for core function. It is always a good idea to check up regularly on the temperature of gas leaving the chamber, as well as the power in the system lines. Lastly, once again remember, never touch the Supermatter with anything. Ever.</br></br>

			-Waleed Asad, Senior Engine Technician."})

/obj/item/book/manual/atmospipes
	name = "Pipes and You: Getting To Know Your Scary Tools"
	desc = "A plumber's guide on how to efficiently plumb and clean out old drone shells."
	icon_state = "pipingbook"
	author = "Maria Crash, Senior Atmospherics Technician"
	title = "Pipes and You: Getting To Know Your Scary Tools"
	pages = list({"<html>
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
				<br><BR>
				<h1><a name="Forward"><U><B>HOW TO NOT SUCK QUITE SO HARD AT ATMOSPHERICS</B></U></a></h1><BR>
				<I>Or: What the fuck does a "passive gate" do?</I><BR><BR>
				Alright. It has come to my attention that a variety of people are unsure of what a "pipe" is and what it does.
				Apparently there is an unnatural fear of these arcane devices and their "gases". Spooky, spooky. So,
				this will tell you what every device constructable by an ordinary pipe dispenser within atmospherics actually does.
				You are not going to learn what to do with them to be the super best person ever, or how to play guitar with passive gates,
				or something like that. Just what stuff does.<BR><BR>
				<h1><a name="Basic"><B>Basic Pipes</B></a></h1><BR>
				<I>The boring ones.</I><BR>
				TMost ordinary pipes are pretty straightforward. They hold gas. If gas is moving in a direction for some reason, gas will flow in that direction.
				That's about it. Even so, here's all of your wonderful pipe options.<BR>
				<li><I>Straight pipes:</I> They're pipes. One-meter sections. Straight line. Pretty simple. Just about every pipe and device is based around this
				standard one-meter size, so most things will take up as much space as one of these.</li>
				<li><I>Bent pipes:</I> Pipes with a 90 degree bend at the half-meter mark. My goodness.</li>
				<li><I>Pipe manifolds:</I> Pipes that are essentially a "T" shape, allowing you to connect three things at one point.</li>
				<li><I>4-way manifold:</I> A four-way junction.</li>
				<li><I>Pipe cap:</I> Caps off the end of a pipe. Open ends don't actually vent air, because of the way the pipes are assembled, so, uh. Use them to decorate your house or something.</li>
				<li><I>Manual Valve:</I> A valve that will block off airflow when turned. Can't be used by the AI or cyborgs, because they don't have hands.</li>
				<li><I>Manual T-Valve:</I> Like a manual valve, but at the center of a manifold instead of a straight pipe.</li><BR><BR>
				<h1><a name="Insulated"><B>Insulated Pipes</B></a></h1><BR>
				<I>Special Public Service Announcement.</I><BR>
				Our regular pipes are already insulated. These are completely worthless. Punch anyone who uses them.<BR><BR>
				<h1><a name="Devices"><B>Devices: </B></a></h1><BR>
				<I>They actually do something.</I><BR>
				This is usually where people get frightened, </font><font face="Verdana" color=black>afraid, and start calling on their gods and/or cowering in fear. Yes, I can see you doing that right now.
				Stop it. It's unbecoming. Most of these are fairly straightforward.<BR>
				<li><I>Gas Pump:</I> Take a wild guess. It moves gas in the direction it's pointing (marked by the red line on one end). It moves it based on pressure, the maximum output being 4500 kPa (kilopascals).
				Ordinary atmospheric pressure, for comparison, is 101.3 kPa, and the minimum pressure of room-temperature pure oxygen needed to not suffocate in a matter of minutes is 16 kPa
				(though 18 is preferred using internals, for various reasons).</li>
				<li><I>Volume pump:</I> This pump goes based on volume, instead of pressure, and the possible maximum pressure it can create in the pipe on the receiving end is double the gas pump because of this,
				clocking in at an incredible 9000 kPa. If a pipe with this is destroyed or damaged, and this pressure of gas escapes, it can be incredibly dangerous depending on the size of the pipe filled.
				Don't hook this to the distribution loop, or you will make babies cry and the Chief Engineer brutally beat you.</li>
				<li><I>Passive gate:</I> This is essentially a cap on the pressure of gas allowed to flow in a specific direction.
				When turned on, instead of actively pumping gas, it measures the pressure flowing through it, and whatever pressure you set is the maximum: it'll cap after that.
				In addition, it only lets gas flow one way. The direction the gas flows is opposite the red handle on it, which is confusing to people used to the red stripe on pumps pointing the way.</li>
				<li><I>Unary vent:</I> The basic vent used in rooms. It pumps gas into the room, but can't suck it back out. Controlled by the room's air alarm system.</li>
				<li><I>Scrubber:</I> The other half of room equipment. Filters air, and can suck it in entirely in what's called a "panic siphon". Actvating a panic siphon without very good reason will kill someone. Don't do it.</li>
				<li><I>Meter:</I> A little box with some gagues and numbers. Fasten it to any pipe or manifold, and it'll read you the pressure in it. Very useful.</li>
				<li><I>Gas mixer:</I> Two sides are input, one side is output. Mixes the gases pumped into it at the ratio defined. The side perpendicular to the other two is "node 2", for reference.
				Can output this gas at pressures from 0-4500 kPa.</li>
				<li><I>Gas filter:</I> Essentially the opposite of a gas mixer. One side is input. The other two sides are output. One gas type will be filtered into the perpendicular output pipe,
				the rest will continue out the other side. Can also output from 0-4500 kPa.</li>
				<h1><a name="HES"><B>Heat Exchange Systems</B></a></h1><BR>
				<I>Will not set you on fire.</I><BR>
				These systems are used to transfer heat only between two pipes. They will not move gases or any other element, but will equalize the temperature (eventually). Note that because of how gases work (remember: pv=nRt),
				a higher temperature will raise pressure, and a lower one will lower temperature.<BR>
				<li><I>Pipe:</I> This is a pipe that will exchange heat with the surrounding atmosphere. Place in fire for superheating. Place in space for supercooling.</li>
				<li><I>Bent Pipe:</I> Take a wild guess.</li>
				<li><I>Junction:</I><I>Junction:</I>The point where you connect your normal pipes to heat exchange pipes. Not necessary for heat exchangers, but necessary for H/E pipes/bent pipes.</li>
				<li><I>Heat Exchanger:</I> These funky-looking bits attach to an open pipe end. Put another heat exchanger directly across from it, and you can transfer heat across two pipes without having to have the gases touch.
				This normally shouldn't exchange with the ambient air, despite being totally exposed. Just don't ask questions...</li><BR>
				That's about it for pipes. Go forth, armed with this knowledge, and try not to break, burn down, or kill anything. Please.</font>
				</body>
				</html>
			"})

/obj/item/book/manual/evaguide
	name = "EVA Gear and You: Not Spending All Day Inside"
	desc = "An enterprising explorer's expedition explainer. Helmet not included!"
	icon_state = "evabook"
	author = "Maria Crash, Senior Atmospherics Technician"
	title = "EVA Gear and You: Not Spending All Day Inside"
	pages = list({"<html>
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
	icon_state ="bookEngineeringSingularitySafety"
	author = "Engineering Encyclopedia"
	title = "Singularity Safety in Special Circumstances"

	pages = list({"<html>
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
	name = "Cloning techniques of the 26th century"
	desc = "A clinical explanation on how to resurrect your patients."
	icon_state ="bookCloning"
	author = "Medical Journal, volume 3"
	title = "Cloning techniques of the 26th century"

	pages = list({"<html>
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

				<H3>How to Clone People</H3>
				So theres 50 dead people lying on the floor, chairs are spinning like no tomorrow and you havent the foggiest idea of what to do? Not to worry! This guide is intended to teach you how to clone people and how to do it right, in a simple step-by-step process! If at any point of the guide you have a mental meltdown, genetics probably isnt for you and you should get a job-change as soon as possible before youre sued for malpractice.

				<ol>
					<li><a href='#1'>Acquire body</a></li>
					<li><a href='#2'>Strip body</a></li>
					<li><a href='#3'>Put body in cloning machine</a></li>
					<li><a href='#4'>Scan body</a></li>
					<li><a href='#5'>Clone body</a></li>
					<li><a href='#6'>Get clean Structurel Enzymes for the body</a></li>
					<li><a href='#7'>Put body in morgue</a></li>
					<li><a href='#8'>Await cloned body</a></li>
					<li><a href='#9'>Use the clean SW injector</a></li>
					<li><a href='#10'>Give person clothes back</a></li>
					<li><a href='#11'>Send person on their way</a></li>
				</ol>

				<a name='1'><H4>Step 1: Acquire body</H4>
				This is pretty much vital for the process because without a body, you cannot clone it. Usually, bodies will be brought to you, so you do not need to worry so much about this step. If you already have a body, great! Move on to the next step.

				<a name='2'><H4>Step 2: Strip body</H4>
				The cloning machine does not like abiotic items. What this means is you cant clone anyone if theyre wearing clothes, so take all of it off. If its just one person, its courteous to put their possessions in the closet. If you have about seven people awaiting cloning, just leave the piles where they are, but dont mix them around and for Gods sake dont let people in to steal them.

				<a name='3'><H4>Step 3: Put body in cloning machine</H4>
				Grab the body and then put it inside the DNA modifier. If you cannot do this, then you messed up at Step 2. Go back and check you took EVERYTHING off - a commonly missed item is their headset.

				<a name='4'><H4>Step 4: Scan body</H4>
				Go onto the computer and scan the body by pressing Scan - <Subject Name Here>. If youre successful, they will be added to the records (note that this can be done at any time, even with living people, so that they can be cloned without a body in the event that they are lying dead on port solars and didnt turn on their suit sensors)! If not, and it says Error: Mental interface failure., then they have left their bodily confines and are one with the spirits. If this happens, just shout at them to get back in their body, click Refresh and try scanning them again. If theres no success, threaten them with gibbing. Still no success? Skip over to Step 7 and dont continue after it, as you have an unresponsive body and it cannot be cloned. If you got Error: Unable to locate valid genetic data., you are trying to clone a monkey - start over.

				<a name='5'><H4>Step 5: Clone body</H4>
				Now that the body has a record, click View Records, click the subjects name, and then click Clone to start the cloning process. Congratulations! Youre halfway there. Remember not to Eject the cloning pod as this will kill the developing clone and youll have to start the process again.

				<a name='6'><H4>Step 6: Get clean SEs for body</H4>
				Cloning is a finicky and unreliable process. Whilst it will most certainly bring someone back from the dead, they can have any number of nasty disabilities given to them during the cloning process! For this reason, you need to prepare a clean, defect-free Structural Enzyme (SE) injection for when theyre done. If youre a competent Geneticist, you will already have one ready on your working computer. If, for any reason, you do not, then eject the body from the DNA modifier (NOT THE CLONING POD) and take it next door to the Genetics research room. Put the body in one of those DNA modifiers and then go onto the console. Go into View/Edit/Transfer Buffer, find an open slot and click SE to save it. Then click Injector to get the SEs in syringe form. Put this in your pocket or something for when the body is done.

				<a name='7'><H4>Step 7: Put body in morgue</H4>
				Now that the cloning process has been initiated and you have some clean Structural Enzymes, you no longer need the body! Drag it to the morgue and tell the Chef over the radio that they have some fresh meat waiting for them in there. To put a body in a morgue bed, simply open the tray, grab the body, put it on the open tray, then close the tray again. Use one of the nearby pens to label the bed CHEF MEAT in order to avoid confusion.

				<a name='8'><H4>Step 8: Await cloned body</H4>
				Now go back to the lab and wait for your patient to be cloned. It wont be long now, I promise.

				<a name='9'><H4>Step 9: Use the clean SE injector on person</H4>
				Has your body been cloned yet? Great! As soon as the guy pops out, grab your injector and jab it in them. Once youve injected them, they now have clean Structural Enzymes and their defects, if any, will disappear in a short while.

				<a name='10'><H4>Step 10: Give person clothes back</H4>
				Obviously the person will be naked after they have been cloned. Provided you werent an irresponsible little shit, you should have protected their possessions from thieves and should be able to give them back to the patient. No matter how cruel you are, its simply against protocol to force your patients to walk outside naked.

				<a name='11'><H4>Step 11: Send person on their way</H4>
				Give the patient one last check-over - make sure they dont still have any defects and that they have all their possessions. Ask them how they died, if they know, so that you can report any foul play over the radio. Once youre done, your patient is ready to go back to work! Chances are they do not have Medbay access, so you should let them out of Genetics and the Medbay main entrance.

				<p>If youve gotten this far, congratulations! You have mastered the art of cloning. Now, the real problem is how to resurrect yourself after that traitor had his way with you for cloning his target.



				</body>
				</html>
				"})

/obj/item/book/manual/ripley_build_and_repair
	name = "APLU \"Ripley\" Construction and Operation Manual"
	desc = "A guide from a little-known corporation on how to operate a heavy lifter mech. It's filled with disclaimers and pre-signed waivers."
	icon_state ="book"
	author = "Weyland-Yutani Corp"
	title = "APLU \"Ripley\" Construction and Operation Manual"

	pages = list({"<html>
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
				<b style='font-size: 12px;'>Weyland-Yutani - Building Better Worlds</b>
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
	icon_state = "rdbook"
	author = "Dr. L. Ight"
	title = "Research and Development 101"
	pages = list({"
	<html>
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
					<li> 1) Deconstruct items in the Destructive Analyzer to advance technology or improve the design.</li>
					<li> 2) Build unlocked designs in the Protolathe and Circuit Imprinter</li>
					<li> 3) Repeat!</li>
				</ol>

				Those are the basic steps to furthing science. What do you do science with, however? Well, you have four major tools: R&D Console, the Destructive Analyzer, the Protolathe, and the Circuit Imprinter.

				<h2>The R&D Console</h2>
				The R&D console is the cornerstone of any research lab. It is the central system from which the Destructive Analyzer, Protolathe, and Circuit Imprinter (your R&D systems) are controled. More on those systems in their own sections. On its own, the R&D console acts as a database for all your technological gains and new devices you discover. So long as the R&D console remains intact, you'll retain all that SCIENCE you've discovered. Protect it though, because if it gets damaged, you'll lose your data! In addition to this important purpose, the R&D console has a disk menu that lets you transfer data from the database onto disk or from the disk into the database. It also has a settings menu that lets you re-sync with nearby R&D devices (if they've become disconnected), lock the console from the unworthy, upload the data to all other R&D consoles in the network (all R&D consoles are networked by default), connect/disconnect from the network, and purge all data from the database.
				<b>NOTE:</b> The technology list screen, circuit imprinter, and protolathe menus are accessible by non-scientists. This is intended to allow 'public' systems for the plebians to utilize some new devices.

				<h2>Destructive Analyzer</h2>
				This is the source of all technology. Whenever you put a handheld object in it, it analyzes it and determines what sort of technological advancements you can discover from it. If the technology of the object is equal or higher then your current knowledge, you can destroy the object to further those sciences. Some devices (notably, some devices made from the protolathe and circuit imprinter) aren't 100% reliable when you first discover them. If these devices break down, you can put them into the Destructive Analyzer and improve their reliability rather then futher science. If their reliability is high enough ,it'll also advance their related technologies.

				<h2>Circuit Imprinter</h2>
				This machine, along with the Protolathe, is used to actually produce new devices. The Circuit Imprinter takes glass and various chemicals (depends on the design) to produce new circuit boards to build new machines or computers. It can even be used to print AI modules.

				<h2>Protolathe</h2>
				This machine is an advanced form of the Autolathe that produce non-circuit designs. Unlike the Autolathe, it can use processed metal, glass, solid plasma, silver, gold, and diamonds along with a variety of chemicals to produce devices. The downside is that, again, not all devices you make are 100% reliable when you first discover them.

				<h1>Reliability and You</h1>
				As it has been stated, many devices when they're first discovered do not have a 100% reliablity when you first discover them. Instead, the reliablity of the device is dependent upon a base reliability value, whatever improvements to the design you've discovered through the Destructive Analyzer, and any advancements you've made with the device's source technologies. To be able to improve the reliability of a device, you have to use the device until it breaks beyond repair. Once that happens, you can analyze it in a Destructive Analyzer. Once the device reachs a certain minimum reliability, you'll gain tech advancements from it.

				<h1>Building a Better Machine</h1>
				Many machines produces from circuit boards and inserted into a machine frame require a variety of parts to construct. These are parts like capacitors, batteries, matter bins, and so forth. As your knowledge of science improves, more advanced versions are unlocked. If you use these parts when constructing something, its attributes may be improved. For example, if you use an advanced matter bin when constructing an autolathe (rather then a regular one), it'll hold more materials. Experiment around with stock parts of various qualities to see how they affect the end results! Be warned, however: Tier 3 and higher stock parts don't have 100% reliability and their low reliability may affect the reliability of the end machine.
				</body>
				</html>
			"})

/obj/item/book/manual/barman_recipes
	name = "Barman Recipes"
	desc = "A coffee-stained guide to mixing drinks."
	icon_state = "barbook"
	author = "Sir John Rose"
	title = "Barman Recipes"
	pages = list({"<html>
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
	icon_state ="bookNuclear"
	author = "Syndicate"
	protected = TRUE
	title = "Fission Mailed: Nuclear Sabotage 101"
	pages = list({"<html>
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
			Good luck!
			</html>"})

/obj/item/book/manual/hydroponics_pod_people
	name = "The Human Harvest - From seed to market"
	desc = "Blurry pictures of people coming out of pods are taped to the cover."
	icon_state ="bookHydroponicsPodPeople"
	author = "Farmer John"
	title = "The Human Harvest - From seed to market"
	pages = list({"<html>
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
	desc = "This REALLY shouldn't exist in-game, please contact a coder"
	copyright = TRUE
	protected = TRUE //We absolutely do not want players editing these books, it might fuck up the iframes in them :)
	pages = null //we don't want people opening this book until it fully initializes
	//Wiki Iframes need a decent bit of room, this will be enough to make the readable without having to expand the window immediately
	book_height = 800
	book_width = 800
	///The Article title of the wiki page being opened in the <iframe>, must use underscores '_' and not whitespace for spaces in title
	var/wiki_article_title = "Space_Law"

/obj/item/book/manual/wiki/Initialize()
	. = ..()
	pages = list({"
		<html><head></head><body bgcolor='[book_bgcolor]'>
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
	icon_state = "borgbook"
	author = "XISC"
	title = "Cyborgs for Dummies"
	wiki_article_title = "Guide_to_Robotics"

/obj/item/book/manual/wiki/experimentor
	name = "Mentoring your Experiments"
	desc = "A madman's ramblings on how to experiment with the E.X.P.E.R.I-MENTOR."
	icon_state = "rdbook"
	author = "Dr. H.P. Kritz"
	title = "Mentoring your Experiments"
	wiki_article_title = "Guide_to_the_E.X.P.E.R.I-MENTOR"

/obj/item/book/manual/wiki/chef_recipes
	name = "Chef Recipes"
	desc = "Knives, Ovens, and You: A guide to cooking."
	icon_state = "cook_book"
	author = "NanoTrasen"
	title = "Chef Recipes"
	wiki_article_title = "Guide_to_Food_and_Drinks#Food"

/obj/item/book/manual/wiki/engineering_construction
	name = "Station Repairs and Construction"
	desc = "A guide on how to fix things without duct tape."
	icon_state ="bookEngineering"
	author = "Engineering Encyclopedia"
	title = "Station Repairs and Construction"
	wiki_article_title = "Guide_to_Construction"

/obj/item/book/manual/wiki/faxes
	name = "Guide to Faxes"
	desc = "NanoTrasen's own manual on how to write faxes."
	icon_state ="bookEngineering"
	author = "Nanotrasen"
	title = "Faxes and You!"
	wiki_article_title = "Guide_to_Faxes"

 //* STANDARD OPERATING PROCEDURE MANUALS *// (and space Law)

/obj/item/book/manual/wiki/security_space_law
	name = "Space Law"
	desc = "A set of Nanotrasen guidelines for keeping law and order on their space stations."
	icon_state = "bookSpaceLaw"
	force = 4 //advanced magistrate tactics
	author = "Nanotrasen"
	title = "Space Law"
	wiki_article_title = "Space_law"

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

 //* MANUAL SPAWNERS *// (and space Law)

/obj/item/book/manual/random
	icon_state = "random_book"
	var/static/list/banned_books = list(/obj/item/book/manual/random, /obj/item/book/manual/nuclear, /obj/item/book/manual/wiki)

/obj/item/book/manual/random/Initialize()
	..()
	var/newtype = pick(subtypesof(/obj/item/book/manual) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL
