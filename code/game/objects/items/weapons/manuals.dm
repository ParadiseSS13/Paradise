/*********************MANUALS (BOOKS)***********************/

//Oh god what the fuck I am not good at computer
/obj/item/book/manual
	icon = 'icons/obj/library.dmi'
	due_date = 0 // Game time in 1/10th seconds
	unique = 1   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified


/obj/item/book/manual/engineering_construction
	name = "Station Repairs and Construction"
	icon_state ="bookEngineering"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Station Repairs and Construction"
	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="https://www.paradisestation.org/wiki/index.php?title=Guide_to_Construction&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}

/obj/item/book/manual/engineering_particle_accelerator
	name = "Particle Accelerator User's Guide"
	icon_state ="bookParticleAccelerator"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Particle Accelerator User's Guide"
//big pile of shit below.

	dat = {"<html>
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
				</html>"}


/obj/item/book/manual/supermatter_engine
	name = "Supermatter Engine User's Guide"
	icon_state = "bookParticleAccelerator"   //TEMP FIXME
	author = "Waleed Asad"
	title = "Supermatter Engine User's Guide"

	dat = {"Engineering notes on single-stage Supermatter engine,</br>
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

			-Waleed Asad, Senior Engine Technician."}

/obj/item/book/manual/engineering_hacking
	name = "Hacking"
	icon_state ="bookHacking"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Hacking"
//big pile of shit below.

	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="https://www.paradisestation.org/wiki/index.php?title=Hacking&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}

/obj/item/book/manual/engineering_singularity_safety
	name = "Singularity Safety in Special Circumstances"
	icon_state ="bookEngineeringSingularitySafety"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Singularity Safety in Special Circumstances"
//big pile of shit below.

	dat = {"<html>
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
				"}

/obj/item/book/manual/hydroponics_pod_people
	name = "The Human Harvest - From seed to market"
	icon_state ="bookHydroponicsPodPeople"
	author = "Farmer John"
	title = "The Human Harvest - From seed to market"
	dat = {"<html>
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
				"}

/obj/item/book/manual/medical_cloning
	name = "Cloning techniques of the 26th century"
	icon_state ="bookCloning"
	author = "Medical Journal, volume 3"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Cloning techniques of the 26th century"
//big pile of shit below.

	dat = {"<html>
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
				"}


/obj/item/book/manual/ripley_build_and_repair
	name = "APLU \"Ripley\" Construction and Operation Manual"
	icon_state ="book"
	author = "Weyland-Yutani Corp"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "APLU \"Ripley\" Construction and Operation Manual"
//big pile of shit below.

	dat = {"<html>
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
			"}

/obj/item/book/manual/experimentor
	name = "Mentoring your Experiments"
	icon_state = "rdbook"
	author = "Dr. H.P. Kritz"
	title = "Mentoring your Experiments"
	dat = {"<html>
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
		<h1>THE E.X.P.E.R.I-MENTOR</h1>
		The Enhanced Xenobiological Period Extraction (and) Restoration Instructor is a machine designed to discover the secrets behind every item in existence.
		With advanced technology, it can process 99.95% of items, and discover their uses and secrets.
		The E.X.P.E.R.I-MENTOR is a Research apparatus that takes items, and through a process of elimination, it allows you to deduce new technological designs from them.
		Due to the volatile nature of the E.X.P.E.R.I-MENTOR, there is a slight chance for malfunction, potentially causing irreparable damage to you or your environment.
		However, upgrading the apparatus has proven to decrease the chances of undesirable, potentially life-threatening outcomes.
		Please note that the E.X.P.E.R.I-MENTOR uses a state-of-the-art random generator, which has a larger entropy than the observable universe,
		therefore it can generate wildly different results each day, therefore it is highly suggested to re-scan objects of interests frequently (e.g. each shift).

		<h2>BASIC PROCESS</h2>
		The usage of the E.X.P.E.R.I-MENTOR is quite simple:
		<ol>
			<li>Find an item with a technological background</li>
			<li>Insert the item into the E.X.P.E.R.I-MENTOR</li>
			<li>Cycle through each processing method of the device.</li>
			<li>Stand back, even in case of a successful experiment, as the machine might produce undesired behaviour.</li>
		</ol>

		<h2>ADVANCED USAGE</h2>
		The E.X.P.E.R.I-MENTOR has a variety of uses, beyond menial research work. The different results can be used to combat localised events, or even to get special items.

		The E.X.P.E.R.I-MENTOR's OBLITERATE function has the added use of transferring the destroyed item's material into a linked lathe.

		The IRRADIATE function can be used to transform items into other items, resulting in potential upgrades (or downgrades).

		Users should remember to always wear appropriate protection when using the machine, because malfunction can occur at any moment!

		<h1>EVENTS</h1>
		<h2>GLOBAL (happens at any time):</h2>
			<ol>
			<li>DETECTION MALFUNCTION - The machine's onboard sensors have malfunctioned, causing it to redefine the item's experiment type.
			Produces the message: The E.X.P.E.R.I-MENTOR's onboard detection system has malfunctioned!</li>

			<li>IANIZATION - The machine's onboard corgi-filter has malfunctioned, causing it to produce a corgi from.. somewhere.
			Produces the message: The E.X.P.E.R.I-MENTOR melts the banana, ian-izing the air around it!</li>

			<li>RUNTIME ERROR - The machine's onboard C4T-P processor has encountered a critical error, causing it to produce a cat from.. somewhere.
			Produces the message: The E.X.P.E.R.I-MENTOR encounters a run-time error!</li>

			<li>B100DG0D.EXE - The machine has encountered an unknown subroutine, which has been injected into it's runtime. It upgrades the held item!
			Produces the message: The E.X.P.E.R.I-MENTOR improves the banana, drawing the life essence of those nearby!</li>

			<li>POWERSINK - The machine's PSU has tripped the charging mechanism! It consumes massive amounts of power!
			Produces the message: The E.X.P.E.R.I-MENTOR begins to smoke and hiss, shaking violently!</li>
			</ol>
		<h2>FAIL:</h2>
			This event is produced when the item mismatches the selected experiment.
			Produces a random message similar to: "the Banana rumbles, and shakes, the experiment was a failure!"

		<h2>POKE:</h2>
			<ol>
			<li>WILD ARMS - The machine's gryoscopic processors malfunction, causing it to lash out at nearby people with it's arms.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions and destroys the banana, lashing it's arms out at nearby people!</li>

			<li>MISTYPE - The machine's interface has been garbled, and it switches to OBLITERATE.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions!</li>

			<li>THROW - The machine's spatial recognition device has shifted several meters across the room, causing it to try and repostion the item there.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, throwing the banana!</li>
			</ol>
		<h2>IRRADIATE:</h2>
			<ol>
			<li>RADIATION LEAK - The machine's shield has failed, resulting in a toxic radiation leak.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, melting the banana and leaking radiation!</li>

			<li>RADIATION DUMP - The machine's recycling and containment functions have failed, resulting in a dump of toxic waste around it
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, spewing toxic waste!</li>

			<li>MUTATION - The machine's radio-isotope level meter has malfunctioned, causing it over-irradiate the item, making it transform.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, transforming the banana!</li>
			</ol>
		<h2>GAS:</h2>
			<ol>
			<li>TOXIN LEAK - The machine's filtering and vent systems have failed, resulting in a cloud of toxic gas being expelled.
			Produces the message: The E.X.P.E.R.I-MENTOR destroys the banana, leaking dangerous gas!</li>

			<li>GAS LEAK - The machine's vent systems have failed, resulting in a cloud of harmless, but obscuring gas.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, spewing harmless gas!</li>

			<li>ELECTROMAGNETIC IONS - The machine's electrolytic scanners have failed, causing a dangerous Electromagnetic reaction.
			Produces the message: The E.X.P.E.R.I-MENTOR melts the banana, ionizing the air around it!</li>
			</ol>
		<h2>HEAT:</h2>
			<ol>
			<li>TOASTER - The machine's heating coils have come into contact with the machine's gas storage, causing a large, sudden blast of flame.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, melting the banana and releasing a burst of flame!</li>

			<li>SAUNA - The machine's vent loop has sprung a leak, resulting in a large amount of superheated air being dumped around it.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, melting the banana and leaking hot air!</li>

			<li>EMERGENCY VENT - The machine's temperature gauge has malfunctioned, resulting in it attempting to cool the area around it, but instead, dumping a cloud of steam.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, activating it's emergency coolant systems!</li>
			</ol>
		<h2>COLD:</h2>
			<ol>
			<li>FREEZER - The machine's cooling loop has sprung a leak, resulting in a cloud of super-cooled liquid being blasted into the air.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, shattering the banana and releasing a dangerous cloud of coolant!</li>

			<li>FRIDGE - The machine's cooling loop has been exposed to the outside air, resulting in a large decrease in temperature.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, shattering the banana and leaking cold air!</li>

			<li>SNOWSTORM - The machine's cooling loop has come into contact with the heating coils, resulting in a sudden blast of cool air.
			Produces the message: The E.X.P.E.R.I-MENTOR malfunctions, releasing a flurry of chilly air as the banana pops out!</li>
			</ol>
		<h2>OBLITERATE:</h2>
			<ol>
			<li>IMPLOSION - The machine's pressure leveller has malfunctioned, causing it to pierce the space-time momentarily, making everything in the area fly towards it.
			Produces the message: The E.X.P.E.R.I-MENTOR's crusher goes way too many levels too high, crushing right through space-time!</li>

			<li>DISTORTION - The machine's pressure leveller has completely disabled, resulting in a momentary space-time distortion, causing everything to fly around.
			Produces the message: The E.X.P.E.R.I-MENTOR's crusher goes one level too high, crushing right into space-time!</li>
			</ol>
		</body>
	</html>
	"}

/obj/item/book/manual/research_and_development
	name = "Research and Development 101"
	icon_state = "rdbook"
	author = "Dr. L. Ight"
	title = "Research and Development 101"
	dat = {"
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
			"}


/obj/item/book/manual/robotics_cyborgs
	name = "Cyborgs for Dummies"
	icon_state = "borgbook"
	author = "XISC"
	title = "Cyborgs for Dummies"
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 21px; margin: 15px 0px 5px;}
				h2 {font-size: 18px; margin: 15px 0px 5px;}
        h3 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Cyborgs for Dummies</h1>

				<h2>Chapters</h2>

				<ol>
					<li><a href="#Equipment">Cyborg Related Equipment</a></li>
					<li><a href="#Modules">Cyborg Modules</a></li>
					<li><a href="#Construction">Cyborg Construction</a></li>
					<li><a href="#Maintenance">Cyborg Maintenance</a></li>
					<li><a href="#Repairs">Cyborg Repairs</a></li>
					<li><a href="#Emergency">In Case of Emergency</a></li>
				</ol>


				<h2><a name="Equipment">Cyborg Related Equipment</h2>

				<h3>Exosuit Fabricator</h3>
				The Exosuit Fabricator is the most important piece of equipment related to cyborgs. It allows the construction of the core cyborg parts. Without these machines, cyborgs can not be built. It seems that they may also benefit from advanced research techniques.

				<h3>Cyborg Recharging Station</h3>
				This useful piece of equipment will suck power out of the power systems to charge a cyborg's power cell back up to full charge.

				<h3>Robotics Control Console</h3>
				This useful piece of equipment can be used to immobolize or destroy a cyborg. A word of warning: Cyborgs are expensive pieces of equipment, do not destroy them without good reason, or Nanotrasen may see to it that it never happens again.


				<h2><a name="Modules">Cyborg Modules</h2>
				When a cyborg is created it picks out of an array of modules to designate its purpose. There are 6 different cyborg modules.

				<h3>Standard Cyborg</h3>
				The standard cyborg module is a multi-purpose cyborg. It is equipped with various modules, allowing it to do basic tasks.<br>A Standard Cyborg comes with:
				<ul>
				  <li>Crowbar</li>
				  <li>Stun Baton</li>
				  <li>Health Analyzer</li>
				  <li>Fire Extinguisher</li>
				</ul>

				<h3>Engineering Cyborg</h3>
				The Engineering cyborg module comes equipped with various engineering-related tools to help with engineering-related tasks.<br>An Engineering Cyborg comes with:
				<ul>
				  <li>A basic set of engineering tools</li>
				  <li>Metal Synthesizer</li>
				  <li>Reinforced Glass Synthesizer</li>
				  <li>An RCD</li>
				  <li>Wire Synthesizer</li>
				  <li>Fire Extinguisher</li>
				  <li>Built-in Optical Meson Scanners</li>
				</ul>

				<h3>Mining Cyborg</h3>
				The Mining Cyborg module comes equipped with the latest in mining equipment. They are efficient at mining due to no need for oxygen, but their power cells limit their time in the mines.<br>A Mining Cyborg comes with:
				<ul>
				  <li>Jackhammer</li>
				  <li>Shovel</li>
				  <li>Mining Satchel</li>
				  <li>Built-in Optical Meson Scanners</li>
				</ul>

				<h3>Security Cyborg</h3>
				The Security Cyborg module is equipped with effective security measures used to apprehend and arrest criminals without harming them a bit.<br>A Security Cyborg comes with:
				<ul>
				  <li>Stun Baton</li>
				  <li>Handcuffs</li>
				  <li>Taser</li>
				</ul>

				<h3>Janitor Cyborg</h3>
				The Janitor Cyborg module is equipped with various cleaning-facilitating devices.<br>A Janitor Cyborg comes with:
				<ul>
				  <li>Mop</li>
				  <li>Hand Bucket</li>
				  <li>Cleaning Spray Synthesizer and Spray Nozzle</li>
				</ul>

				<h3>Service Cyborg</h3>
				The service cyborg module comes ready to serve your human needs. It includes various entertainment and refreshment devices. Occasionally some service cyborgs may have been referred to as "Bros"<br>A Service Cyborg comes with:
				<ul>
				  <li>Shaker</li>
				  <li>Industrail Dropper</li>
				  <li>Platter</li>
				  <li>Beer Synthesizer</li>
				  <li>Zippo Lighter</li>
				  <li>Rapid-Service-Fabricator (Produces various entertainment and refreshment objects)</li>
				  <li>Pen</li>
				</ul>

				<h2><a name="Construction">Cyborg Construction</h2>
				Cyborg construction is a rather easy process, requiring a decent amount of metal and a few other supplies.<br>The required materials to make a cyborg are:
				<ul>
				  <li>Metal</li>
				  <li>Two Flashes</li>
				  <li>One Power Cell (Preferrably rated to 15000w)</li>
				  <li>Some electrical wires</li>
				  <li>One Human Brain</li>
				  <li>One Man-Machine Interface</li>
				</ul>
				Once you have acquired the materials, you can start on construction of your cyborg.<br>To construct a cyborg, follow the steps below:
				<ol>
				  <li>Start the Exosuit Fabricators constructing all of the cyborg parts</li>
				  <li>While the parts are being constructed, take your human brain, and place it inside the Man-Machine Interface</li>
				  <li>Once you have a Robot Head, place your two flashes inside the eye sockets</li>
				  <li>Once you have your Robot Chest, wire the Robot chest, then insert the power cell</li>
				  <li>Attach all of the Robot parts to the Robot frame</li>
				  <li>Insert the Man-Machine Interface (With the Brain inside) Into the Robot Body</li>
				  <li>Congratulations! You have a new cyborg!</li>
				</ol>

				<h2><a name="Maintenance">Cyborg Maintenance</h2>
				Occasionally Cyborgs may require maintenance of a couple types, this could include replacing a power cell with a charged one, or possibly maintaining the cyborg's internal wiring.

				<h3>Replacing a Power Cell</h3>
				Replacing a Power cell is a common type of maintenance for cyborgs. It usually involves replacing the cell with a fully charged one, or upgrading the cell with a larger capacity cell.<br>The steps to replace a cell are follows:
				<ol>
				  <li>Unlock the Cyborg's Interface by swiping your ID on it</li>
				  <li>Open the Cyborg's outer panel using a crowbar</li>
				  <li>Remove the old power cell</li>
				  <li>Insert the new power cell</li>
				  <li>Close the Cyborg's outer panel using a crowbar</li>
				  <li>Lock the Cyborg's Interface by swiping your ID on it, this will prevent non-qualified personnel from attempting to remove the power cell</li>
				</ol>

				<h3>Exposing the Internal Wiring</h3>
				Exposing the internal wiring of a cyborg is fairly easy to do, and is mainly used for cyborg repairs.<br>You can easily expose the internal wiring by following the steps below:
				<ol>
				  <li>Follow Steps 1 - 3 of "Replacing a Cyborg's Power Cell"</li>
				  <li>Open the cyborg's internal wiring panel by using a screwdriver to unsecure the panel</li>
			  </ol>
			  To re-seal the cyborg's internal wiring:
			  <ol>
			    <li>Use a screwdriver to secure the cyborg's internal panel</li>
			    <li>Follow steps 4 - 6 of "Replacing a Cyborg's Power Cell" to close up the cyborg</li>
			  </ol>

			  <h2><a name="Repairs">Cyborg Repairs</h2>
			  Occasionally a Cyborg may become damaged. This could be in the form of impact damage from a heavy or fast-travelling object, or it could be heat damage from high temperatures, or even lasers or Electromagnetic Pulses (EMPs).

			  <h3>Dents</h3>
			  If a cyborg becomes damaged due to impact from heavy or fast-moving objects, it will become dented. Sure, a dent may not seem like much, but it can compromise the structural integrity of the cyborg, possibly causing a critical failure.
			  Dents in a cyborg's frame are rather easy to repair, all you need is to apply a welding tool to the dented area, and the high-tech cyborg frame will repair the dent under the heat of the welder.

        <h3>Excessive Heat Damage</h3>
        If a cyborg becomes damaged due to excessive heat, it is likely that the internal wires will have been damaged. You must replace those wires to ensure that the cyborg remains functioning properly.<br>To replace the internal wiring follow the steps below:
        <ol>
          <li>Unlock the Cyborg's Interface by swiping your ID</li>
          <li>Open the Cyborg's External Panel using a crowbar</li>
          <li>Remove the Cyborg's Power Cell</li>
          <li>Using a screwdriver, expose the internal wiring or the Cyborg</li>
          <li>Replace the damaged wires inside the cyborg</li>
          <li>Secure the internal wiring cover using a screwdriver</li>
          <li>Insert the Cyborg's Power Cell</li>
          <li>Close the Cyborg's External Panel using a crowbar</li>
          <li>Lock the Cyborg's Interface by swiping your ID</li>
        </ol>
        These repair tasks may seem difficult, but are essential to keep your cyborgs running at peak efficiency.

        <h2><a name="Emergency">In Case of Emergency</h2>
        In case of emergency, there are a few steps you can take.

        <h3>"Rogue" Cyborgs</h3>
        If the cyborgs seem to become "rogue", they may have non-standard laws. In this case, use extreme caution.
        To repair the situation, follow these steps:
        <ol>
          <li>Locate the nearest robotics console</li>
          <li>Determine which cyborgs are "Rogue"</li>
          <li>Press the lockdown button to immobolize the cyborg</li>
          <li>Locate the cyborg</li>
          <li>Expose the cyborg's internal wiring</li>
          <li>Check to make sure the LawSync and AI Sync lights are lit</li>
          <li>If they are not lit, pulse the LawSync wire using a multitool to enable the cyborg's Law Sync</li>
          <li>Proceed to a cyborg upload console. Nanotrasen usually places these in the same location as AI uplaod consoles.</li>
          <li>Use a "Reset" upload moduleto reset the cyborg's laws</li>
          <li>Proceed to a Robotics Control console</li>
          <li>Remove the lockdown on the cyborg</li>
        </ol>

        <h3>As a last resort</h3>
        If all else fails in a case of cyborg-related emergency. There may be only one option. Using a Robotics Control console, you may have to remotely detonate the cyborg.
        <h3>WARNING:</h3> Do not detonate a borg without an explicit reason for doing so. Cyborgs are expensive pieces of Nanotrasen equipment, and you may be punished for detonating them without reason.

        </body>
		</html>
		"}

/obj/item/book/manual/security_space_law
	name = "Space Law"
	desc = "A set of Nanotrasen guidelines for keeping law and order on their space stations."
	icon_state = "bookSpaceLaw"
	force = 4 //advanced magistrate tactics
	author = "Nanotrasen"
	title = "Space Law"
	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="https://www.paradisestation.org/wiki/index.php?title=Space_law&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>		</body>

		</html>

		"}

/obj/item/book/manual/security_space_law/black
	name = "Space Law - Limited Edition"
	desc = "A leather-bound, immaculately-written copy of JUSTICE."
	icon_state = "bookSpaceLawblack"
	title = "Space Law - Limited Edition"

/obj/item/book/manual/engineering_guide
	name = "Engineering Textbook"
	icon_state ="bookEngineering2"
	author = "Engineering Encyclopedia"
	title = "Engineering Textbook"
	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="https://www.paradisestation.org/wiki/index.php?title=Guide_to_Engineering&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>		</body>

		</html>

		"}


/obj/item/book/manual/chef_recipes
	name = "Chef Recipes"
	icon_state = "cooked_book"
	author = "Victoria Ponsonby"
	title = "Chef Recipes"
	dat = {"<html>
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

				<h1>Food for Dummies</h1>
				Here is a guide on basic food recipes and also how to not poison your customers accidentally.

				<h2>Basics:<h2>
				Knead an egg and some flour to make dough. Bake that to make a bun or flatten and cut it.

				<h2>Burger:<h2>
				Put a bun and some meat into the microwave and turn it on. Then wait.

				<h2>Bread:<h2>
				Put some dough and an egg into the microwave and then wait.

				<h2>Waffles:<h2>
				Add two lumps of dough and 10u of sugar to the microwave and then wait.

				<h2>Popcorn:<h2>
				Add 1 corn to the microwave and wait.

				<h2>Meat Steak:<h2>
				Put a slice of meat, 1 unit of salt and 1 unit of pepper into the microwave and wait.

				<h2>Meat Pie:<h2>
				Put a flattened piece of dough and some meat into the microwave and wait.

				<h2>Boiled Spaghetti:<h2>
				Put the spaghetti (processed flour) and 5 units of water into the microwave and wait.

				<h2>Donuts:<h2>
				Add some dough and 5 units of sugar to the microwave and wait.

				<h2>Fries:<h2>
				Add one potato to the processor, then bake them in the microwave.


				</body>
				</html>
			"}

/obj/item/book/manual/barman_recipes
	name = "Barman Recipes"
	icon_state = "barbook"
	author = "Sir John Rose"
	title = "Barman Recipes"
	dat = {"<html>
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
			"}


/obj/item/book/manual/detective
	name = "The Film Noir: Proper Procedures for Investigations"
	icon_state ="bookDetective"
	author = "Nanotrasen"
	title = "The Film Noir: Proper Procedures for Investigations"
	dat = {"<html>
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
			</html>"}

/obj/item/book/manual/nuclear
	name = "Fission Mailed: Nuclear Sabotage 101"
	icon_state ="bookNuclear"
	author = "Syndicate"
	title = "Fission Mailed: Nuclear Sabotage 101"
	dat = {"<html>
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
			</html>"}

/obj/item/book/manual/atmospipes
	name = "Pipes and You: Getting To Know Your Scary Tools"
	icon_state = "pipingbook"
	author = "Maria Crash, Senior Atmospherics Technician"
	title = "Pipes and You: Getting To Know Your Scary Tools"
	dat = {"<html>
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
				<li><I>Volume pump:</I> This pump goes based on volume, instead of pressure, and the possible maximum pressure it can create in the pipe on the recieving end is double the gas pump because of this,
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
			"}

/obj/item/book/manual/evaguide
	name = "EVA Gear and You: Not Spending All Day Inside"
	icon_state = "evabook"
	author = "Maria Crash, Senior Atmospherics Technician"
	title = "EVA Gear and You: Not Spending All Day Inside"
	dat = {"<html>
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
			"}

/obj/item/book/manual/faxes
	name = "A Guide to Faxes"
	desc = "A Nanotrasen-approved guide to writing faxes"
	icon_state = "book6"
	author = "Nanotrasen"
	title = "A Guide to Faxes"
	dat = {"

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
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#what">What's a Fax?</a></li>
					<li><a href="#when">When to Fax?</a></li>
					<li><a href="#how">How to Fax?</a></li>
				</ol>
				<br><BR>

				<h1><a name="what"><U><B>What's a Fax?</B></U></a></h1><BR>
				<li>Faxes are your main method of communicating with the NAS Trurl, better known as Central Command.</li>
				<li>Faxes allow personnel on the station to maintain open lines of communication with the NAS Trurl, allowing for vital information to flow both ways.</li>
				<li>Being written communications, proper grammar, syntax and typography is required, in addition to a signature and, if applicable, a stamp. Failure to sign faxes will lead to an automatic rejection.</li>
				<li>We at Nanotrasen provide Fax Machines to every Head of Staff, in addition to the Magistrate, Nanotrasen Representative, and Internal Affairs Agents.</li>
				<li>This means that we trust the recipients of these fax machines to only use them in the proper circumstances (see <B>When to Fax?</B>).</li>

				<h1><a name="when"><B>When to Fax?</B></a></h1><BR>
				<li>While it is up to the discretion of each individual person to decide when to fax Central Command, there are some simple guidelines on when to do this.</li>
				<li>Firstly, any situation that can reasonably be solved on-site, <I>should</I> be handled on-site. Knowledge of Standard Operating Procedure is <B>mandatory</B> for everyone with access to a fax machine.</li>
				<li>Resolving issues on-site not only leads to more expedient problem-solving, it also frees up company resources and provides valuable work experience for all parties involved.</li>
				<li>This means that you should work with the Heads of Staff concerning personnel and workplace issues, and attempt to resolve situations with them. If, for whatever reason, the relevent Head of Staff is not available or receptive, consider speaking with the Captain and/or Nanotrasen Representative.</li>
				<li>If, for whatever reason, these issues cannot be solved on-site, either due to incompetence or just plain refusal to cooperate, faxing Central Command becomes a viable option.</li>
				<li>Secondly, station status reports should be sent occasionally, but never at the start of the shift. Remember, we assign personnel to the station. We do not need a repeat of what we just signed off on.</li>
				<li>Thirdly, staff/departmental evaluations are always welcome, especially in cases of noticeable (in)competence. Just as a brilliant coworker can be rewarded, an incompetent one can be punished.</li>
				<li>Fourthly, do not issue faxes asking for sentences. You have an entire Security department and an associated Detective, not to mention on-site Space Law manuals.</li>
				<li>Lastly, please pay attention to context. If the station is facing a massive emergency, such as a Class 7-10 Blob Organism, most, if not all, non-relevant faxes will be duly ignored.</li>

				<h1><a name="how"><B>How to Fax?</B></a></h1><BR>
				<li>Sending a fax is simple. Simply insert your ID into the fax machine, then log in.</li>
				<li>Once logged in, insert a piece of paper and select the destination from the provided list. Remember, you can rename your fax from within the fax machine's menu.</li>
				<li>You can send faxes to any other fax machine on the station, which can be a very useful tool when you need to issue broad communications to all of the Heads of Staff.</li>
				<li>To send a fax to Central Command, simply select the correct destination, and send the fax. Keep in mind, the communication arrays need to recharge after sending a fax to Central Command, so make sure you sent everything you need.</li>
				<li>Lastly, paper bundles can also be faxed as a single item, so feel free to bundle up all relevant documentation and send it in at once.</li>

				</ol><BR>
				</body>
				</html>

		"}

/obj/item/book/manual/sop_science
	name = "Science Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all scientific activities."
	icon_state = "book6"
	author = "Nanotrasen"
	title = "Science Standard Operating Procedures"
	dat = {"

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
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#foreword">Foreword</a></li>
					<li><a href="#rd">Research Director</a></li>
					<li><a href="#robo">Roboticist</a></li>
					<li><a href="#sci">Scientist</a></li>
					<li><a href="#gen">Geneticist</a></li>
                    <li><a href="#exo">Exotic Implants</a></li>
				</ol>
				<br><BR>

				<h1><a name="foreword"><U><B>FOREWORD</B></U></a></h1><BR>
				Job SOP should not be a considered a checklist of conditions to fire someone over, and should not be rigidly followed to the letter in detriment of circumstances and context.
				As always, SOP can be malleable if the situation so requires, and the decision to punish a crewmember for breaching it ultimately falls onto the relevant Head of Staff,
				for Department Members, or Captain, for the Head of Staff.<BR><BR>

				<h1><a name="rd"><B>Research Director</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>The Research Director must make sure Research is being done. Research must be completed by the end of the shift, assuming Science is provided the materials for it by Supply;</li>
					<li>The Research Director is permitted to carry a telescopic baton;</li>
					<li>The Research Director is permitted to carry their Reactive Teleport Armour on their person. However, it is highly recommended they keep it inactive unless necessary, for personal safety;</li>
					<li>The Research Director is not permitted to authorize the construction of AI Units without the Captain's approval. An exception is made if the station was not provided with an AI Unit, or a previous AI Unit had to be destroyed.</li>
					<li>The Research Director is not permitted to authorize Anomalous Artifacts to be brought onto the station prior to full testing and cataloguing;</li>
					<li>The Research Director must keep the Communications Decryption Key on their person at all times, or at least somewhere safe and out of reach;</li>
					<li>The Research Director is permitted to add beneficial scripts to Telecommunications;</li>
					<li>The Research Director is permitted to change the AI Unit's lawset, provided they receive general approval from the Captain and another Head of Staff. If there are no other Heads of Staff available, Captain approval will suffice;</li>
					<li>The Research Director must work with Robotics to make sure all Cyborgs remain slaved to the station's AI Unit, except in such a situation where the AI Unit has been subverted or is malfunctioning.</li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>All Guidelines carry over from Code Green</li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>Guidelines 1, 3, 4, 6, 7, 8 and 9 carry over from Code Green;</li>
					<li>In addition to the a telescopic baton, the Research Director is permitted to carry a single weapon created in the Protolathe, provided they receive authorization from the Head of Security. Exception is made during extreme emergencies, such as Nuclear Operatives or Blob Organisms.</li>
				</ol><BR>
                <br><br>

                <h1><a name="robo"><B>Roboticist</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>The Roboticist is not permitted to construct Combat Mechs without express permission from the Captain and/or Head of Security. This refers to the Durand, Gygax and Phazon. If permitted, the Mechs is to be delivered to the Armory for storage. The Research Director is placed under the same restrictions;</li>
					<li>The Roboticist is freely permitted to construct Utility Mechs, along with any assorted Utility Equipment. This refers to Ripleys (to be handed to Mining), Firefighting Ripleys (to be handed to Atmospherics) and the Odysseus Medical Mech (to be handed to Medical). The HONK Mech is not to be constructed without <b>full approval by the Research Director and Captain</b>;</li>
					<li>The Roboticist is freely permitted to construct Cyborgs and all assorted equipment; </li>
					<li>The Roboticist is not permitted to transfer personnel MMIs into Cyborgs without express written consent from the person in question. The consent form should be kept safe;</li>
					<li>The Roboticist is not permitted to construct AI Units without express consent from the Captain;</li>
					<li>The Roboticist must place a Tracking Beacon on all constructed Mechs; </li>
					<li>The Roboticist must work together with the Research Director to make sure all Cyborgs remain slaved to the station's AI Unit, except in such a situation where the AI Unit has been subverted or is malfunctioning;</li>
					<li>The Roboticist must DNA-Lock all parked Mechs prior to delivery. DNA-Lock must be removed when the Mech is delivered to its final destination </li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>Guidelines 2, 3, 4, 5, 6, 7 and 8 carry over from Code Green;</li>
                    <li>The Roboticist is permitted to construct Combat Mechs without prior consent, but must deliver them to the Armory for storage. Failure to comply will result in the Combat Mech being destroyed. Exception is made for extreme emergencies, such as a Blob Organism or Nuclear Operatives, where the Roboticist may pilot the Mech themselves. However, even in these circumstances, the Mech must be delivered to the Armory after the emergency is over. The Research Director is placed under the same restrictions;</li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>Guidelines 3, 4, 5, 6, 7, 8 and 9 carry over from Code Green;</li>
					<li>All Guidelines carry over from Code Blue.</li>
				</ol><BR>
                <br><br>

                <h1><a name="sci"><B>Scientist</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>Scientists are not permitted to bring Grenades outside of Science;</li>
					<li>Scientists are not permitted to bring Toxins Bombs outside of Science. Exception is made if the Toxins Bomb is handed to Mining, as it can be useful for mining operations;</li>
					<li>While not mandatory, it is highly recommended that Scientists give a prior warning before a Toxins Test. This must be done via the Common Communication Channel, with at least ten (10) seconds between the warning and detonation;</li>
					<li>Scientists are not permitted to use Telescience equipment to acquire objects, items or personnel they do not have access to;</li>
					<li>Scientists are, however, permitted to use Telescience equipment to recover dead personnel, provided Medical cannot reach them;</li>
					<li>Scientists must, at all times, keep live slimes and Golden Extract-based lifeforms inside Xenobiology pens, except when transporting them to new cells. Peaceful Golden Extract lifeforms may be released with the express permission of the Research Director. In addition, injecting plasma into Golden Extract is strictly forbidden;</li>
					<li>Scientists are not permitted to bring Anomalous Artifacts aboard the station without express verbal consent from the Research Director. Regular Xenoarchaeological artifacts are permitted;</li>
					<li>Scientists are not permitted to construct the Portable Wormhole Generator without express permission from the Research Director. In addition, Scientists are not to hand out Weapon Lockboxes to any non-Security or non-Command personnel without express permission from the Head of Security;</li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>Guidelines 3, 4, 5, 6, 7 and 9 carry over from Code Green;</li>
                    <li>Scientists are permitted to bring Grenades outside of Science, but only for delivery to the Armory;</li>
                    <li>Scientists are permitted to bring Toxins Bombs outside of Science, but only for delivery to the Armory. In addition, the Mining exception still applies</li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>Guidelines, 3, 4, 5, 6, 7 and 9 carry over from Code Green; </li>
					<li>All Guidelines carry over from Code Blue.</li>
				</ol><BR>
                <br><br>

                <h1><a name="gen"><B>Geneticist</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>The Geneticist is not permitted to ignore Cloning, and must provide Clean SE Injectors when required, as well as humanized animals if required for Surgery. In addition, the Geneticist must make sure that Cloning is stocked with Biomass; </li>
					<li>The Geneticist is permitted to test Genetic Powers on themselves. However, they are not to utilize these powers on any crewmembers, nor abuse them to obtain items/personnel outside their access;</li>
					<li>The Geneticist is permitted to grant Genetic Powers to Command Staff at their discretion, provided prior permission is requested and granted. All staff must be warned of the full effects of the SE Injector. The Geneticist is not, however, obligated to grant powers, unless the Research Director issues a direct order;</li>
					<li>The Geneticist is not permitted to grant Powers to non-Command Staff without express verbal consent from the Research Director. Both the Chief Medical Officer and the Research Director maintain full authority to forcefully remove these Powers if they are abused;</li>
					<li>The Geneticist must place all discarded humanized animals in the Morgue. It is recommended that said discarded humanized animals be directed to the Crematorium;</li>
					<li>The Geneticist is not permitted to provide body doubles, unless the Research Director approves it. In addition, Security is to be notified of all doubles;</li>
					<li>The Geneticist is not permitted to alter personnel's UI Status, unless it has been previously tampered with by hostile elements, or permission is given;</li>
					<li>The Geneticist is not permitted to use sentient humanoids as test subjects unless the sentient humanoid has granted their permission, on paper.</li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>All Guidelines carry over from Code Green </li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>All Guidelines carry over from Code Green. In regards to Guideline 4, the Geneticist is now permitted to grant Powers to Security personnel, under the same conditions as detailed in Guideline 3.</li>
				</ol><BR>
                <br><br>

	            <h1><a name="exo"><B>Exotic Implants</B></a></h1><BR>
				<i>Exotic Implants refer to Xeno Organs, Cybernetic Implants or any such exotic materials.</i><br>
				<ol>
					<li>General utility implants (such as Welding Shield, Nutriment or Reviver) are unregulated, and may be handed out freely;</li>
					<li>X-Ray Vision and Thermal Vision implants may be handed out freely, but may have their implantation vetoed by the Chief Medical Officer and/or Research Director (see below); </li>
                    <li>Medical HUDs must be approved by the Chief Medical Officer before implantation, and Security HUDs require express permission from the Head of Security or Warden;</li>
                    <li>Combat-capable Implants (such as the CNS Rebooter or Anti-Drop) are not be handed out without express permission from the Head of Security; </li>
                    <li>Cybernetic Implantation should be performed in Surgery or any such sterilized environment, to reduce the risk of internal infection. If no Surgeons or Doctors are available, the Roboticist can fill in;</li>
                    <li>The Chief Medical Officer and Research Director have the power to veto any Cybernetic Implantation or Xeno Organ Implantation if they believe it threatens the stability of the station or crew. Only the Captain may override this veto;</li>
                    <li>Xeno Organs may be harvested at will, but may not be implanted without express permission from the Chief Medical Officer. Egg-Laying Organs from Xenomorph Lifeforms are strictly forbidden;</li>
                    <li>Failure to follow these Guidelines makes the offending party liable to having their Exotic Implants forcefully removed.</li>
				</ol><BR>
				</body>
				</html>

		"}

/obj/item/book/manual/sop_medical
	name = "Medical Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all medical activities."
	icon_state = "book7"
	author = "Nanotrasen"
	title = "Medical Standard Operating Procedures"
	dat = {"

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
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#foreword">Foreword</a></li>
					<li><a href="#cmo">Chief Medical Officer</a></li>
					<li><a href="#doc">Medical Doctor</a></li>
					<li><a href="#chem">Chemist</a></li>
					<li><a href="#gen">Geneticist</a></li>
                    <li><a href="#viro">Virologist</a></li>
                    <li><a href="#para">Paramedic</a></li>
                    <li><a href="#psy">Psychologist</a></li>
                    <li><a href="#surg">Surgery</a></li>
                    <li><a href="#viral">Viral Outbreak Procedures</a></li>
                    <li><a href="#cor">Coroner Procedures</a></li>
                    <li><a href="#exo">Exotic Implants</a></li>
				</ol>
				<br><BR>

				<h1><a name="foreword"><U><B>FOREWORD</B></U></a></h1><BR>
				Job SOP should not be a considered a checklist of conditions to fire someone over, and should not be rigidly followed to the letter in detriment of circumstances and context.
				As always, SOP can be malleable if the situation so requires, and the decision to punish a crewmember for breaching it ultimately falls onto the relevant Head of Staff,
				for Department Members, or Captain, for the Head of Staff.<BR><BR>

				<h1><a name="cmo"><B>Chief Medical Officer</B></a></h1><BR>
				<ol>
					<li>The Chief Medical Officer is permitted to carry a regular Defibrillator or a Compact Defibrillator on their person at all times;</li>
                    <li>The Chief Medical Officer is permitted to carry a telescopic baton. In case Genetic Powers need to be forcefully removed, they are cleared to carry a Syringe Gun;</li>
                    <li>The Chief Medical Officer is not permitted to allow the creation of poisonous or explosive mixtures in Chemistry without express consent from the Captain or, failing that, the presence of a clear and urgent danger to the integrity of the station, except of course in situations where Chemical Implants are required;</li>
                    <li>The Chief Medical Officer is not permitted to allow the release of any virus without a full list of its symptoms, as well as the creation of a vial of antibodies, to be kept in a secure location. The virus may not have any harmful symptoms whatsoever, though neutral/harmless symptoms are permitted;</li>
                    <li>The Chief Medical Officer must make sure that any cloneable corpses are, in fact, cloned.</li>
				</ol>
                <br><br>

                <h1><a name="doc"><B>Medical Doctor</B></a></h1><BR>
				<ol>
					<li>Though not mandatory, it is recommended that Doctors wear Sterile Masks and Latex/Nitrile gloves when handling patients. This Guideline becomes <b>mandatory</b> during Viral Outbreaks;</li>
                    <li>Nurses should focus on helping Medical Doctors and Surgeons in whatever they require, and tending to patients that require light care. If necessary, they can stand in for regular Medical Doctor duties;</li>
                    <li>Surgeons are expected to fulfill the duties of regular Medical Doctors if there are no active Surgical Procedures undergoing; </li>
                    <li>Medical Doctors must ensure there is at least one (1) Defibrillator available for use, at all times, next to or near the Cryotubes;</li>
                    <li>Medical Doctors must maintain the entirety of Medbay in an hygienic state. This includes, but is not limited to, cleaning organic residue, fluids and corpses;</li>
                    <li>Medical Doctors must place all corpses inside body bags. If there is an assigned Coroner, the Morgue Trays must be correctly tagged;</li>
                    <li>Medical Doctors must, together with Geneticists and Chemists, make sure that Cloning is stocked with Biomass. In addition, Medical Doctors must make sure that the Morgue does not contain cloneable corpses;</li>
                    <li>Medical Doctors must certify that all cloned personnel are put in the Cryotubes after Cloning, and receive either a dose of Mutadone or a Clean SE Injector, in addition to Mannitol. An exception is made if the Cloning Pod was fully upgraded by Science;</li>
                    <li>Medical Doctors are not permitted to leave Medbay to perform recreational activities if there are unattended patients requiring treatment;</li>
                    <li>Medical Doctors must stabilize patients before delivering them to Surgery. If the patient presents Internal Bleeding, they are to be rushed to Surgery <b>post haste.</b></li>

				</ol>
                <br><br>

                <h1><a name="chem"><B>Chemist</B></a></h1><BR>
				<ol>
					<li>The Chemist is not permitted to experiment with explosive mixtures;</li>
                    <li>The Chemist is not permitted to experiment with poisonous mixtures and/or narcotics;</li>
                    <li>The Chemist is not permitted to experiment with Life or other Omnizine-derived mixtures apart from Omnizine or Strange Reagent;</li>
                    <li>The Chemist is not permitted to produce alcoholic beverages;</li>
                    <li>Chemists must, together with Geneticists and Medical Doctors, make sure that Cloning is stocked with Biomass;</li>
                    <li>The Chemist must ensure that the Medical Fridge is stocked with at least enough medication to handle Brute, Burn, Respiratory, Toxic and Brain damage. Failure to follow this Guideline within thirty (30) minutes is to be considered a breach of Standard Operating Procedure</li>
                    <li>The Chemist is not allowed to leave Chemistry unattended if the Medical Fridge is devoid of Medication, except in such a case as Chemistry is unusable or if Fungus needs to be collected</li>
                </ol>
                <br><br>

                <h1><a name="gen"><B>Geneticist</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>The Geneticist is not permitted to ignore Cloning, and must provide Clean SE Injectors when required, as well as humanized animals if required for Surgery. In addition, the Geneticist must make sure that Cloning is stocked with Biomass; </li>
					<li>The Geneticist is permitted to test Genetic Powers on themselves. However, they are not to utilize these powers on any crewmembers, nor abuse them to obtain items/personnel outside their access;</li>
					<li>The Geneticist is permitted to grant Genetic Powers to Command Staff at their discretion, provided prior permission is requested and granted. All staff must be warned of the full effects of the SE Injector. The Geneticist is not, however, obligated to grant powers, unless the Research Director issues a direct order;</li>
					<li>The Geneticist is not permitted to grant Powers to non-Command Staff without express verbal consent from the Research Director. Both the Chief Medical Officer and the Research Director maintain full authority to forcefully remove these Powers if they are abused;</li>
					<li>The Geneticist must place all discarded humanized animals in the Morgue. It is recommended that said discarded humanized animals be directed to the Crematorium;</li>
					<li>The Geneticist is not permitted to provide body doubles, unless the Research Director approves it. In addition, Security is to be notified of all doubles;</li>
					<li>The Geneticist is not permitted to alter personnel's UI Status, unless it has been previously tampered with by hostile elements, or permission is given;</li>
					<li>The Geneticist is not permitted to use sentient humanoids as test subjects unless the sentient humanoid has granted their permission, on paper.</li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>All Guidelines carry over from Code Green </li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>All Guidelines carry over from Code Green. In regards to Guideline 4, the Geneticist is now permitted to grant Powers to Security personnel, under the same conditions as detailed in Guideline 3.</li>
				</ol><BR>
                <br><br>

                <h1><a name="viro"><B>Virologist</B></a></h1><BR>
				<ol>
					<li>The Virologist must always wear adequate protection (such as a Biosuit and Internals for Airborne Viruses) when handling infected personnel and Test Animals. Exception is made for IPC Virologists, for obvious reasons;</li>
                    <li>The Virologist must only test viral samples on the provided Test Animals. Said Test Animals are to be maintained inside their pen, and disposed of via Virology's Disposals Chutes if dead, to prevent possible contamination. In addition, the Virologist may not, <b>under any circumstances whatsoever</b>, leave Virology while infected by a Viral Pathogen that spreads by Contact or Airborne means, unless permitted by the Chief Medical Officer;</li>
                    <li>The Virologist may not, <b>under any circumstance whatsoever</b>, release an active virus without prior consent from Chief Medical Officer. Contact and/or Airborne viruses may only be released with consent from the Chief Medical officer <b>and</b> Captain. In the event a Contact and/or Airborne virus is released, the crew <b>must be informed</b>, and Vaccines should be ready for any personnel that choose to opt out of being infected;</li>
                    <li>The Virologist must ensure that all Viral Samples are kept on their person at all times, or at the very least in a secure location (such as the Virology Fridge);</li>
                    <li>The Virologist must work together with Medical Staff, especially Chemistry, if there is a cure that requires manufacturing;</li>
                    <li>In the event of a lethal Viral Outbreak, the Virologist must work together with the Chief Medical Officer and/or Chemists and/or Bartender to produce a cure. Failure to keep casualties down to, at most, 25% of the station's crew is to be considered a breach of Standard Operating Procedure for everyone involved.</li>
                </ol>
                <br><br>

                <h1><a name="para"><B>Paramedic</B></a></h1><BR>
				<ol>
					<li>The Paramedic is not permitted to perform Field Surgery unless there are no available Medical Doctors or the Operating Rooms are unusable; </li>
                    <li>The Paramedic is permitted to perform Surgical Procedures inside an Operating Room. However, Doctors/Surgeons should take precedence;</li>
                    <li>The Paramedic is fully permitted to carry a Defibrillator on their person at all times, provided they leave at least one (1) Defibrillator for use in Medbay;</li>
                    <li>The Paramedic must stabilize all patients before bringing them to the Medical Bay. If the patient presents with Internal Bleeding, they are to be rushed to Surgery post haste;</li>
                    <li>In such a case as a patient is found dead, and cannot be brought back via Defibrillation, the Paramedic must ensure that said patient is brought to Cloning, and Medbay is notified;</li>
                    <li>The Paramedic must carry, at all times, enough materials to provide for adequate first aid of all Major Injury Types (Brute, Burn, Toxic, Respiratory and Brain)</li>
                </ol>
                <br><br>

                <h1><a name="psy"><B>Psychologist</B></a></h1><BR>
				<ol>
					<li>The Psychologist may perform a full psychological evaluation on anyone, along with any potential treatment, provided the person in question seeks them out;</li>
                    <li>The Psychologist may not force someone to receive therapy if the person does not want it. Exception is made for violent criminals, if the Head of Security or Magistrate orders it;</li>
                    <li>The Psychologist is not permitted to administer any medication without consent from their patient;</li>
                    <li>The Psychologist is not permitted to muzzle or straightjacket anyone without express permission from the Chief Medical Officer or Head of Security. An exception is made for violent and/or out of control patients;</li>
                    <li>The Psychologist may recommend a patient's demotion if they find their psychological condition to be unfit;</li>
                    <li>The Psychologist may request to consult prisoners in Permanent Imprisonment. This must happen inside the Brig, preferably inside the Permabrig, and only with Warden and/or Head of Security authorization. This should be done under the supervision of a member of Security with Permabrig access</li>
                </ol>
                <br><br>

                <h1><a name="surg"><B>Surgery</B></a></h1><BR>
				<ol>
					<li>Attending Surgeon must use Latex/Nitrile gloves in order to prevent infection. Though not mandatory, a Sterile Mask is recommended;</li>
                    <li>Attending Surgeon is to keep the Operating Room in an hygienic condition at all times, <b>again</b>, to prevent infection;</li>
                    <li>Attending Surgeon is to wash his/her hands between different patients, again, to prevent infection;</li>
                    <li>Attending Surgeon is to use either Anesthetics or Sedatives (for species that cannot breathe Anesthetics) during Surgical Procedures. Exception is made if the patient requests otherwise;</li>
                    <li>Attending Surgeon is not to remove any legal Implants (such as Mindshield or Tracking Implants) from the patient, unless requested by Security;</li>
                    <li>If a patient requests that a lost limb be replaced with an organic, rather than mechanical, substitute, said limb must be harvested from a compatible humanized Test Animal (such as Monkeys for Humans, or Farwas for Tajarans). Exception is made if the patient deliberately requests otherwise;</li>
                    <li>Attending Surgeon is not to bring any of the Surgical Tools outside of their respective Operating Room, and must in fact ensure the Operating Room maintains its proper inventory. This includes ensuring that the Anesthetics Equipment be kept inside the OR</li>
                </ol>
                <br><br>

                <h1><a name="viral"><b>Viral Outbreak Procedures</b></a></h1><BR>
                <i><b>Definition: </b>A Viral Outbreak is defined as a situation where a Viral Pathogen has infected a significant portion of the crew (>10%)</i>
				<ol>
					<li>All Medbay personnel are to contribute in fighting the outbreak if there are no other critical patients requiring assistance. Eliminating the Viral Threat becomes <b>number one priority;</b></li>
                    <li>Personnel are to be informed of known symptoms, and directed to Medbay immediately if they are suffering from them;</li>
                    <li>All infected personnel are to be confined to either an Isolated Room, or Virology;</li>
                    <li>A blood sample is to be taken from an infected person, for study;</li>
                    <li>If any infected personnel attempt to leave containment, Medbay Quarantine is to be <b>initiated immediately</b>, and only lifted when more patients need to be admitted, or the Viral Outbreak is over;</li>
                    <li>A single infected person may volunteer to receive a dose of Radium in order to develop Antibodies. Radium must not be administered without consent. Otherwise, animal testing is to be conducted in order to obtain Antibodies;</li>
                    <li>Once Antibodies are produced, they are to be diluted, then handed out to all infected personnel. Injecting infected personnel with Radium after Antibodies have been extracted is <b>forbidden</b>. In the event of a large enough crisis, directly injecting blood with the relevant Antibodies is permissible;</li>
                    <li>Viral Pathogen should be cataloged and analyzed, in case any stray cases remained untreated;</li>
                    <li>Cured personnel should have a sample of their blood removed for the purpose of creating antibodies, until there are no infected personnel left;</li>
                    <li>In case the Viral Pathogen leads to fluid leakage, cleaning these fluids is to be considered top priority;</li>
                    <li>Once the Viral Outbreak is over, all personnel are to return to regular duties.</li>
                </ol>
                <br><br>

                <h1><a name="cor"><B>Coroner Procedures</B></a></h1><BR>
                <ol>
					<li>For the sake of hygiene, the Coroner should wear a Sterile Mask when handling corpses;</b></li>
                    <li>The Coroner must inject/apply Formaldehyde to all corpses, and place them in body bags;</li>
                    <li>The Coroner must perform a full autopsy on all corpses, and keep a record of it, in written format. If foul play is suspected, Security must be contacted;</li>
                    <li>The Coroner must correctly tag the Morgue Trays in order to identify the corpse within, as well as Cause of Death;</li>
                    <li>The Coroner must ensure Security-based DNR Notices (such as executed personnel, for instance) are respected;</li>
                    <li>The Coroner must ensure that every ID from unclonable bodies is delivered to either the relevant Head of Staff, or the Head of Personnel. This applies to any Medbay personnel placing a body in the Morgue</li>
                </ol>
                <br><br>

	            <h1><a name="exo"><B>Exotic Implants</B></a></h1><BR>
				<i>Exotic Implants refer to Xeno Organs, Cybernetic Implants or any such exotic materials.</i><br>
				<ol>
					<li>General utility implants (such as Welding Shield, Nutriment or Reviver) are unregulated, and may be handed out freely;</li>
					<li>X-Ray Vision and Thermal Vision implants may be handed out freely, but may have their implantation vetoed by the Chief Medical Officer and/or Research Director (see below); </li>
                    <li>Medical HUDs must be approved by the Chief Medical Officer before implantation, and Security HUDs require express permission from the Head of Security or Warden;</li>
                    <li>Combat-capable Implants (such as the CNS Rebooter or Anti-Drop) are not be handed out without express permission from the Head of Security; </li>
                    <li>Cybernetic Implantation should be performed in Surgery or any such sterilized environment, to reduce the risk of internal infection. If no Surgeons or Doctors are available, the Roboticist can fill in;</li>
                    <li>The Chief Medical Officer and Research Director have the power to veto any Cybernetic Implantation or Xeno Organ Implantation if they believe it threatens the stability of the station or crew. Only the Captain may override this veto;</li>
                    <li>Xeno Organs may be harvested at will, but may not be implanted without express permission from the Chief Medical Officer. Egg-Laying Organs from Xenomorph Lifeforms are strictly forbidden;</li>
                    <li>Failure to follow these Guidelines makes the offending party liable to having their Exotic Implants forcefully removed.</li>
				</ol><BR>
 				</body>
				</html>

		"}

/obj/item/book/manual/sop_engineering
	name = "Engineering Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all engineering activities."
	icon_state = "book3"
	author = "Nanotrasen"
	title = "Engineering Standard Operating Procedures"
	dat = {"

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
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#foreword">Foreword</a></li>
					<li><a href="#ce">Chief Engineer</a></li>
					<li><a href="#eng">Station Engineer</a></li>
					<li><a href="#atmos">Atmospherics Technician</a></li>
					<li><a href="#mech">Mechanic</a></li>
				</ol>
				<br><BR>

				<h1><a name="foreword"><U><B>FOREWORD</B></U></a></h1><BR>
				Job SOP should not be a considered a checklist of conditions to fire someone over, and should not be rigidly followed to the letter in detriment of circumstances and context.
				As always, SOP can be malleable if the situation so requires, and the decision to punish a crewmember for breaching it ultimately falls onto the relevant Head of Staff,
				for Department Members, or Captain, for the Head of Staff.<BR><BR>

				<h1><a name="ce"><B>Chief Engineer</B></a></h1><BR>
				<ol>
					<li>The Chief Engineer must make sure that the Gravitational Singularity Engine and/or Tesla Engine and/or Solar Panels are fully set up and wired before any further action is taken by themselves or their team; </li>
                    <li>The Chief Engineer, along with the Research Director, is responsible for maintaining the integrity of Telecommunications. The Chief Engineer may not upload malicious scripts or in any way hinder the proper functionality of Telecommunications, and must diagnose and repair any issues that arise;</li>
                    <li>The Chief Engineer is not to authorize the ordering of a Supermatter Shard before any power source is fully set up;</li>
                    <li>The Chief Engineer is bound to the same rules regarding the axe as Atmospheric Technicians;</li>
                    <li>The Chief Engineer is permitted to carry a telescopic baton and a flash; </li>
                    <li>The Chief Engineer is responsible for maintaining the integrity of the Gravitational Singularity Engine and/or the Supermatter Engine and/or the Tesla Engine. Neglecting this duty is grounds for termination should the Engine malfunction;</li>
                    <li>The Chief Engineer is responsible for maintaining the integrity of the station's Atmospherics System. Failure to maintain this integrity is grounds for termination;</li>
                    <li>The Chief Engineer may declare an area "Condemned", if it is damaged to the point where repairs cannot reasonably be completed within an acceptable frame of time;</li>
                    <li>The Chief Engineer is permitted to grant Building Permits to crewmembers, but must keep the Station Blueprints in a safe location at all times.</li>
				</ol>
                <br><br>

                <h1><a name="eng"><B>Station Engineer</B></a></h1><BR>
				<ol>
					<li>Engineers must properly activate and wire the Gravitational Singularity Engine and/or Tesla Engine and/or the Solar Panels at the start of the shift, before any other actions are undertaken;</li>
                    <li>Engineers are responsible for maintaining the integrity of the Gravitational Singularity Engine and/or the Supermatter Engine and/or the Tesla Engine. Neglecting this duty is grounds for termination should the Engine malfunction;</li>
                    <li>Engineers are not permitted to construct additional power sources (Supermatter Engines, additional Tesla Engines, additional Gravitational Singularity Engines or additional Solar Panels) until at least one (1) power source is correctly wired and set up;</li>
                    <li>Engineers are permitted to carry out solo reconstruction/rebuilding/personal projects if there is no damage to the station that requires fixing;</li>
                    <li>Engineers must periodically check on the Gravitational Singularity Engine, if it is the chosen method of power generation, in intervals of, at most, thirty (30) minutes. While the Tesla Engine is not as prone to malfunction, this action should still be undertaken for it;</li>
                    <li>Engineers must constantly monitor the Supermatter Engine, if it is the chosen method of power generation, if it is currently active (ie, under Emitter Fire). This is not negotiable;</li>
                    <li>Engineers must respond promptly to breaches, regardless of size. Failure to report within fifteen (15) minutes will be considered a breach of Standard Operating Procedure, unless there are no spare Engineers to report or an Atmospheric Technician has arrived on scene first. All Hazard Zones must be cordoned off with Engineering Tape, for the sake of everyone else;</li>
                    <li>Engineers are permitted to hack doors to gain unauthorized access to locations if said locations happen to require urgent repairs;</li>
                    <li>Engineers are to maintain the integrity of the station's Power Network. In addition, hotwiring the Gravitational Singularity Engine, Supermatter Engine or Tesla Engine is strictly forbidden;</li>
                    <li>Engineers must ensure there is at least one (1) engineering hardsuit available on the station at all times, unless there is an emergency that requires the use of all suits.</li>
				</ol>
                <br><br>

                <h1><a name="atmos"><B>Atmospherics Technician</B></a></h1><BR>
				<ol>
					<li>Atmospheric Technicians are permitted to completely repipe the Atmospherics Piping Setup, provided they do not pump harmful gases into anywhere except the Turbine;</li>
                    <li>Atmospheric Technicians are not permitted to create volatile mixes using Plasma and Oxygen, nor are they permitted to create any potentially harmful mixes with Carbon Dioxide and/or Nitrous Oxide. An exception is made when working with the Turbine;</li>
                    <li>Atmospheric Technicians are permitted to cool Plasma and store it for later use in Radiation Collectors. Likewise, they are permitted to cool Nitrogen or Carbon Dioxide and store it for use as coolant for the Supermatter Engine;</li>
                    <li>Atmospheric Technicians are not permitted to take the axe out of its case unless there is an immediate and urgent threat to their life or urgent access to crisis locations is necessary. The axe must be returned to the case afterwards, and the case locked;</li>
                    <li>Atmospheric Technicians are not permitted to tamper with the default values on Air Alarms. They are, however, permitted to create small, acclimatized rooms for species that require special atmospheric conditions (such as Plasmamen and Vox), provided they receive express permission from the Chief Engineer;</li>
                    <li>Atmospheric Technicians must periodically check on the Central Alarms Computer, in periods of, at most, thirty (30) minutes;</li>
                    <li>Atmospheric Technicians must respond promptly to piping and station breaches. Failure to report within fifteen (15) minutes will be considered a breach of Standard Operating Procedure, unless there are no spare Atmospheric Technicians to report, or an Engineer has arrived on scene first. All Hazard Zones must be cordoned off with Engineering Tape, for the sake of everyone else</li>
				</ol>
                <br><br>

                <h1><a name="mech"><B>Mechanic</B></a></h1><BR>
				<ol>
					<li>The Mechanic is not permitted to fit any weaponry onto constructed Space Pods without express permission by the Head of Security;</li>
                    <li>The Mechanic is permitted to construct Space Pods for any crewmember that requests one, provided the Pods do not have any weaponry. Anyone possessing a Pod is to follow Mechanic SOP, Civilians included;</li>
                    <li>The Mechanic is not permitted to enter the Security Pod Bay, unless the Security Pod Pilot or Head of Security permit it;</li>
                    <li>The Mechanic is not permitted to bring any Space Pod into the actual station</li>
				</ol>
                <br><br>
				</body>
				</html>

		"}

/obj/item/book/manual/sop_service
	name = "Service Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all service activities."
	icon_state = "book4"
	author = "Nanotrasen"
	title = "Service Standard Operating Procedures"
	dat = {"

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
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#foreword">Foreword</a></li>
					<li><a href="#chef">Chef</a></li>
					<li><a href="#bar">Bartender</a></li>
					<li><a href="#bot">Botanist</a></li>
					<li><a href="#honk">Clown</a></li>
                    <li><a href="#mime">Mime</a></li>
                    <li><a href="#chap">Chaplain</a></li>
                    <li><a href="#jani">Janitor</a></li>
                    <li><a href="#barb">Barber</a></li>
                    <li><a href="#lib">Librarian</a></li>
				</ol>
				<br><BR>

				<h1><a name="foreword"><U><B>FOREWORD</B></U></a></h1><BR>
				Job SOP should not be a considered a checklist of conditions to fire someone over, and should not be rigidly followed to the letter in detriment of circumstances and context.
				As always, SOP can be malleable if the situation so requires, and the decision to punish a crewmember for breaching it ultimately falls onto the relevant Head of Staff,
				for Department Members, or Captain, for the Head of Staff.<BR><BR>

				<h1><a name="chef"><B>Chef</B></a></h1><BR>
				<ol>
					<li>The Chef is not permitted to use the corpses of deceased personnel for meat unless given specific permission from the Chief Medical Officer. Exception is made for changelings and any other executed personnel not slated for Borgifications;</li>
                    <li>The Chef is permitted to use Ambrosia and other such light narcotics in the production of food;</li>
                    <li>The Chef must produce at least three (3) dishes of any food within twenty (20) minutes. Failure to do so is to be considered a breach of Standard Operating Procedure;</li>
                    <li>The Chef is not permitted to leave the kitchen unattended for longer than fifteen (15) minutes if there is no food available for consumption. Exception is made if there are no ingredients, or if the Kitchen is unusable/a hazard zone</li>
                </ol>
                <br><br>

                <h1><a name="bar"><B>Bartender</B></a></h1><BR>
				<ol>
					<li>The Bartender is not permitted to carry their shotgun outside the bar. However, they may obtain permission from the Head of Security to shorten the barrel for easier transportation. Shortening the barrel without authorization is grounds for confiscation of the Bartender's shotgun;</li>
                    <li>The Bartender is permitted to use their shotgun on unruly bar patrons in order to throw them out if they are being disruptive. They are not, however, permitted to apply lethal, or near-lethal force;</li>
                    <li>The Bartender is exempt from legal ramifications when dutifully removing unruly (ie, overtly hostile) patrons from the Bar, provided, of course, they followed Guideline 2;</li>
                    <li>The Bartender is not permitted to possess regular (ie, lethal) shotgun ammunition. Only beanbag slugs are permitted. Exception is made during major emergencies, such as Nuclear Operatives or Blob Organisms;</li>
                    <li>The Bartender has full permission to forcefully throw out anyone who climbs over the bar counter without permission, up to and including personnel who may have access to the side windoor. They are not, however, permitted to do so if the person in question uses the door, or is on an active investigation;</li>
                    <li>The Bartender is permitted to ask for monetary payment in exchange for drinks</li>
				</ol>
                <br><br>

                <h1><a name="bot"><B>Botanist</B></a></h1><BR>
				<ol>
					<li>Botanists are permitted to grow narcotics, presuming they do not distribute it; </li>
                    <li>Botanists must provide the Chef with adequate Botanical Supplies, per the Chef's request;</li>
                    <li>Botanists are not permitted to cause unregulated plantlife to spread outside of Hydroponics or other such designated locations;</li>
                    <li>Botanists are not permitted to hand out (spatially) unstable Botanical Supplies to non-Hydroponics personnel;</li>
                    <li>Botanists are not permitted to harvest Amanitin or other such plant/fungi-derived poisons, unless specifically requested by the Head of Security and/or Captain.</li>
				</ol>
                <br><br>

                <div style="font-family: Comic Sans MS"><h1><a name="honk"><B>Clown</B></a></h1><BR>
				<ol>
					<li>The Clown is permitted to, and freely exempt from any consequences of, slipping literally anyone, assuming it does not interfere with active Security duty, or in any way endangers other personnel (such as slipping a Paramedic who's dragging a wounded person to Medbay);</li>
                    <li>The Clown is not permitted to remove their Clown Shoes or Clown Mask. Exception is made if removing them is truly necessary for the sake of their clowning performance (such as being a satire of bad clowns);</li>
                    <li>The Clown is not permitted to hold anything but water in their Sunflower;</li>
                    <li>The Clown is not permitted to use Space Lube on anything. Exception is made during major emergencies involving hostile humanoids, whereby use of Space Lube may be condoned to help the crew;</li>
                    <li>The Clown must legitimately attempt to be funny and/or entertaining at least once every fifteen (15) minutes. A simple pun will suffice. Continuously slipping people for no reason does not constitute humour. The joke is supposed to be funny for everyone;</li>
                    <li>The Clown is permitted to, and freely exempt from any consequences of, performing any harmless prank that does not directly conflict with the above Guidelines</li>
				</ol>
                </div>
                <br><br>

                <h1><a name="mime"><B>Mime</B></a></h1><BR>
				<ol>
					<li>The Mime is not permitted to talk, under any circumstance whatsoever. A Mime who breaks the Vow of Silence is to be stripped of their rank post haste;</li>
                    <li>The Mime is permitted to use written words to communicate, either via paper or PDA, but are discouraged from automatically resorting to it when miming will suffice;</li>
                    <li>The Mime must actually mime something at least once every thirty (30) minutes. Standing against an invisible wall will suffice.</li>
                </ol>
                <br><br>

                <h1><a name="chap"><B>Chaplain</B></a></h1><BR>
				<ol>
					<li>The Chaplain is not permitted to execute Bible Healing without consent, unless the person in question is in Critical Condition and there are no doctors, as doing so incurs the risk of causing brain damage;</li>
                    <li>The Chaplain may not draw the Null Rod or Holy Sword on any personnel. Using these items on any personnel is grounds to have these items confiscated, unless there is a clear and present danger to their life;</li>
                    <li>The Chaplain may not actively discriminate against any personnel on the grounds that it is a religious tenet of their particular faith;</li>
                    <li>The Chaplain may not perform funerals for any personnel that have since been cloned;</li>
                    <li>The Chaplain may, however, freely conduct funerals for non-cloneable personnel. All funerals must be concluded with the use of the Mass Driver or Crematorium.</li>
				</ol>
                <br><br>

                <h1><a name="jani"><B>Janitor</B></a></h1><BR>
				<ol>
					<li>The Janitor must promptly respond to any call from the crew for them to clean. Failure to respond within fifteen (15) minutes is to be considered a breach of Standard Operating Procedure;</li>
                    <li>If the Janitor's work leaves any surface slippery, they are to place wet floor signs, either physical or holographic. During major crises, such as Nuclear Operatives or Blob Organisms, the Janitor is to refrain from creating any slippery surfaces whatsoever;</li>
                    <li>The Janitor is not to use Cleaning Foam Grenades as pranking implements. Cleaning Foam Grenades are to be used to clean large surfaces at once, only;</li>
                    <li>During Viral Outbreaks, the Janitors must don their Biosuit, and focus on cleaning any biological waste, until such a point as the Viral Pathogen is deemed eliminated;</li>
                    <li>The Janitor may not deploy bear traps anywhere, unless there are actually large wild animals on the station.</li>
				</ol>
                <br><br>

                <h1><a name="barb"><B>Barber</B></a></h1><BR>
				<ol>
					<li>The Barber may not give unsolicited haircuts/dye jobs to any personnel;</li>
                    <li>The Barber must perform haircuts/dye jobs as per the request of personnel, and not from personal taste</li>
				</ol>
                <br><br>

                <h1><a name="lib"><B>Librarian</B></a></h1><BR>
				<ol>
					<li>The Librarian is to keep at least one (1) shelf stocked with books for the station's personnel;</li>
                    <li>The Librarian is permitted to conduct journalism on any part of the station. However, they are not entitled to participation in trials, and must receive authorization from the Head of Security or Magistrate.</li>
				</ol>
                <br><br>
				</body>
				</html>

		"}

/obj/item/book/manual/sop_supply
	name = "Supply Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all supply activities."
	icon_state = "book1"
	author = "Nanotrasen"
	title = "Supply Standard Operating Procedures"
	dat = {"

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
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#foreword">Foreword</a></li>
					<li><a href="#qm">Quarter Master</a></li>
					<li><a href="#ct">Cargo Technician</a></li>
					<li><a href="#sf">Shaft Miner</a></li>
				</ol>
				<br><BR>

				<h1><a name="foreword"><U><B>FOREWORD</B></U></a></h1><BR>
				Job SOP should not be a considered a checklist of conditions to fire someone over, and should not be rigidly followed to the letter in detriment of circumstances and context.
				As always, SOP can be malleable if the situation so requires, and the decision to punish a crewmember for breaching it ultimately falls onto the relevant Head of Staff,
				for Department Members, or Captain, for the Head of Staff.<BR><BR>

				<h1><a name="qm"><B>Quarter Master</B></a></h1><BR>
				<ol>
					<li>The Quartermaster must ensure that every approved order is delivered within 15 minutes of having been placed and approved;</li>
                    <li>In the event of a major crisis, such as Nuclear Operatives or a Blob Organism, expediency is to be favored over paperwork, as excessive bureaucracy may be detrimental to the well-being of the station;</li>
                    <li>The Quartermaster is permitted to hack the Autolathe, or to have a Cargo Tech do so, assuming they do not produce illegal materials;</li>
                    <li>The Quartermaster is not permitted to authorize the ordering of Security equipment and/or gear without express permission from the Head of Security and/or Captain. An exception is made during extreme emergencies, such as Nuclear Operatives or a Blob Organism, where said equipment is to be delivered to Security, post haste;</li>
                    <li>The Quartermaster must ensure at least one copy of every Order Form (ie, the forms produced by the Requests Console) is kept inside Cargo. The same applies for Cargo Technicians;</li>
                    <li>The Quartermaster is not permitted to produce .357 speedloaders for the Detective without express permission from the Head of Security;</li>
                    <li>The Quartermaster is not to keep any illegal items that are flushed down Disposals, and must deliver them to Security. The same applies for Cargo Technicians and Shaft Miners;</li>
                    <li>The Quartermaster is not permitted to hack the MULE Delivery Bots so that they may ride them, or that they may go faster. The same applies for Cargo Technicians and Shaft Miners;</li>
                    <li>The Quartermaster is permitted to authorize non-departmental orders (such as a Medical Doctor asking for Insulated Gloves) without express permission from the respective Head of Staff (in this example, the Chief Engineer), utilizing their best judgement, although they may still request a stamped form. However, any breach of Standard Operating Procedure and/or Space Law that results from said order will also implicate the Quartermaster;</li>
                    <li>The Quartermaster is not permitted to authorize a Supermatter Crate without express permission from the Chief Engineer.</li>
				</ol>
                <br><br>

                <h1><a name="ct"><B>Cargo Technician</B></a></h1><BR>
				<ol>
					<li>Cargo Technicians are bound to the same rules as the Quartermaster regarding restricted crates (see above); </li>
                    <li>Cargo Technicians are not permitted to order items for sole personal use without express consent from the Quartermaster. Exception is made if there are more than 500 Supply Requisition Points available and no outstanding orders. Cargo Technicians may not deplete the entire stock of Requisition Points with this;</li>
                    <li>Cargo Technicians are not permitted to order non-essential items (such as cats, or clothing) without express consent from the Quartermaster;</li>
                    <li>Cargo Technicians are not permitted to force and/or break open locked crates. The same applies to the Quartermaster. Exception is made for Abandoned Crates found by Mining;</li>
                    <li>Cargo Technicians are not permitted to authorize non-departmental orders (such as a Medical Doctor asking for Insulated Gloves) without express permission from the Quartermaster;</li>
                    <li>Cargo Technicians must ensure that every approved order is delivered within 15 minutes of having been placed and approved;</li>
                    <li>Cargo Technicians must send back all crates that have been ordered, with accompanying stamped manifest inside the crate;</li>
                    <li>Cargo Technicians should ensure that a single Department does not fully drain the Ore Redemption Machine, as it can be utilized by multiple Departments;</li>
                    <li>Cargo Technicians are not permitted to ask for money in exchange for legal orders. The same applies to the Quartermaster;</li>
                    <li>Cargo Technicians are not permitted to trade items and/or favors in exchange for items with regular personnel without express consent from the Quartermaster.</li>
				</ol>
                <br><br>

                <h1><a name="sf"><B>Shaft Miner</B></a></h1><BR>
				<ol>
					<li>Shaft Miners are not permitted to bring Gibtonite aboard the station;</li>
                    <li>Shaft Miners must deliver at least 1000 Points of mined material to the Ore Redemption Machine within one (1) hour;</li>
                    <li>Shaft Miners are not permitted to hoard materials. All mined materials are to be left in the Ore Redemption Machine;</li>
                    <li>Shaft Miners are not permitted to throw people into manufactured wormholes, nor are they permitted to trick people into using Bluespace Crystals, or throwing Bluespace Crystals at anyone;</li>
                    <li>Shaft Miners are not permitted to mine their way into the Labor Camp;</li>
                    <li>Should Shaft Miners encounter Xenomorph lifeforms, they are to report to Medbay immediately</li>
				</ol>
                <br><br>
				</body>
				</html>

		"}

/obj/item/book/manual/sop_security
	name = "Security Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all security activities."
	icon_state = "book2"
	author = "Nanotrasen"
	title = "Security Standard Operating Procedures"
	dat = {"

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
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#foreword">Foreword</a></li>
					<li><a href="#hos">Head of Security</a></li>
					<li><a href="#officer">Security Officer</a></li>
					<li><a href="#ward">Warden</a></li>
					<li><a href="#det">Detective</a></li>
                    <li><a href="#pilot">Security Pod Pilot</a></li>
                    <li><a href="#phys">Brig Physician</a></li>
				</ol>
				<br><BR>

				<h1><a name="foreword"><U><B>FOREWORD</B></U></a></h1><BR>
				Job SOP should not be a considered a checklist of conditions to fire someone over, and should not be rigidly followed to the letter in detriment of circumstances and context.
				As always, SOP can be malleable if the situation so requires, and the decision to punish a crewmember for breaching it ultimately falls onto the relevant Head of Staff,
				for Department Members, or Captain, for the Head of Staff.<BR><BR>

				<h1><a name="hos"><B>Head of Security</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>The Head of Security is permitted to carry out arrests under the same conditions as their Security Officers; </li>
					<li>The Head of Security is permitted to carry a taser, a flash, a flashbang, a stunbaton and a can of pepperspray. While permitted to carry their unique Energy Gun, they are discouraged from doing so for safety concerns, and should keep it on Stun/Disable;</li>
					<li>The Head of Security is not obligated to provide a trial, but is encouraged to allow legal representation should the suspect request it. This only applies to Capital Crimes;</li>
					<li>The Head of Security may not, under any circumstance, overrule a Magistrate, unless their decisions are blatantly breaking Standard Operating Procedure and/or Space Law, in which case Central Command is to be contacted as well;</li>
					<li>The Head of Security must follow the same guidelines as the Warden for Armory equipment, portable flashers and deployable barriers;</li>
					<li>The Head of Security is not permitted to collect equipment from the Armory to carry on their person;</li>
					<li>The Head of Security is permitted to either use their regular coat, or armored trenchcoat;</li>
					<li>The Head of Security is permitted to wear their unique gas mask;</li>
					<li>The Head of Security may not overrule established sentences, unless further evidence is brought to light or the prisoner in question attempts to escape</li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>All Guidelines carry over from Code Green. In regards to Guideline 2, the Head of Security is now encouraged to carry their unique Energy Gun</li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>Guidelines 1, 3, 4, 5, 7, 8 and 9 are carried over from Code Green;</li>
					<li>The Head of Security is permitted to take whatever equipment they require from the Armory, provided they leave enough equipment for the rest of the Security force;</li>
                    <li>The Head of Security is required to produce a Station Announcement regarding the nature of the confirmed threat that caused Code Red;</li>
                    <li>Lethal Force is permitted if the target is confirmed to be guilty of Capital Crimes and actively, and aggressively, resists arrest</li>
				</ol><BR>
                <br><br>

                <h1><a name="officer"><B>Security Officer</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>Security Officers are required to state the reasons behind an arrest before any further action is taken. Exception is made if the suspect refuses to stop;</li>
					<li>Security Officers must attempt to bring all suspects or witnesses to the Brig without handcuffing or incapacitating them. Should the suspect not cooperate, the officer may proceed as usual;</li>
					<li>No weapons are to be unholstered until the suspect attempts to run away or becomes actively hostile;</li>
					<li>Security Officers are permitted to carry a taser, a flash, a flashbang, a stunbaton and a can of pepperspray;</li>
					<li>Security Officers may not demand access to the interior of other Departments during regular patrols. However, asking for access from the Head of Personnel is still acceptable;</li>
					<li>Security officers are not permitted to have weapons drawn during regular patrols;</li>
					<li>Security officers are permitted to conduct searches, provided there is reasonable evidence/suspicion that the person in question has committed a crime. Any further searches require a warrant from the Head of Security, Captain or Magistrate;</li>
					<li>Lethal Force is not authorized unless there is a clear and immediate threat to the station's integrity or the Officer's life</li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>Guidelines 1, 2, 4 and 8 are carried over from Code Green;</li>
                    <li>Security Officers are permitted to carry around any weapons or equipment available in the Armory, at the Warden's discretion, but never more than one at a time. Exception is made for severe emergencies, such as Blob Organisms or Nuclear Operatives; </li>
                    <li>Security Officers are permitted to carry weapons in hand during regular patrols, although this is not advised;</li>
                    <li>Security Officers are permitted to present weapons during arrests;</li>
                    <li>Security Officers may demand entry to specific Departments during regular patrols;</li>
                    <li>Security Officers may randomly search crewmembers, but are not allowed to apply any degree of force unless said crewmember acts overtly hostile. Crew who refuse to be searched may be stunned and cuffed for the search;</li>
                    <li>Security Officers are permitted to leave prisoners bucklecuffed should they act hostile.</li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>Guidelines 2, 3, 4, 5, 6 and 7 are carried over from Code Blue;</li>
					<li>Security Officers may arrest crewmembers with no stated reason if there is evidence they are involved in criminal activities;</li>
                    <li>Security Officers may forcefully relocate crewmembers to their respective Departments if necessary;</li>
                    <li>Lethal Force is permitted if the target is confirmed to be guilty of Capital Crimes and actively, and aggressively, resists arrest.</li>
				</ol><BR>
                <br><br>

                <h1><a name="ward"><B>Warden</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>The Warden may not perform arrests if there are Security Officers active;</li>
					<li>The Warden must conduct a thorough search of every prisoner's belongings, including pockets, PDA slots, any coat pockets and suit storage slots;</li>
					<li>The Warden is not obligated to provide a trial, but is encouraged to allow legal representation should the suspect request it. This only applies to Capital Crimes;</li>
					<li>The Warden may not hand out any weapons or armour from the Armory, except for extra tasers. Hardsuits may be issued if emergency E.V.A action is required. Exception is made if there is an immediate threat that requires attention, such as Nuclear Operatives, or rioters;</li>
					<li>The Warden is permitted to carry a taser, a flash, a stunbaton, a flashbang and a can of pepperspray;</li>
					<li>The Warden may not place the portable flashers within the Brig;</li>
					<li>The Warden may not place the deployable barriers within the Brig;</li>
					<li>The Warden must read to every prisoner the crimes they are sentenced to;</li>
                    <li>The Warden is not permitted to leave prisoners bucklecuffed to their beds. An exception is made if the prisoners acts overtly hostile or attempts to breach the cell in order to escape.</li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>Guidelines 1, 2, 3, 5 and 8 are carried over from Code Green;</li>
                    <li>The Warden is permitted to hand out all equipment from the Armory. Energy and Laser guns are only to be handed out with Head of Security or Captain's approval, as they present a lethal risk, or if there is an immediate threat, such as Blob Organisms or Nuclear Operatives;</li>
                    <li>The Warden is permitted to place the portable flashers inside the Brig;</li>
                    <li>The Warden is permitted to place the deployable barriers inside the Brig</li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>Guidelines 2, 3, 5 and 8 are carried over from Code Green;</li>
					<li>Guidelines 3 and 4 are carried over from Code Blue. In addition, the Warden may also carry any weapon from the Armory, but never more than one at a time;</li>
                    <li>The Warden is permitted to distribute any weapon or piece of equipment in the Armory. This includes whatever Research has provided;</li>
                    <li>The Warden is permitted to carry out arrests freely;</li>
                    <li>Lethal Force is permitted if the target is confirmed to be guilty of Capital Crimes and actively, and aggressively, resists arrest.</li>
				</ol><BR>
                <br><br>

                <h1><a name="det"><B>Detective</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>The Detective may not perform arrests or searches unless given specific permission by the Head of Security or Warden. Exception is made if there are no active Officers or Warden;</li>
					<li>The Detective may not intentionally go around Security officers to perform arrests. If Officers are available, arrests may only be performed if there is an immediate violent threat to the Detective or anyone around them;</li>
					<li>The Detective may not unholster their revolver unless a clear and present danger to their life is present;</li>
					<li>The Detective may carry their revolver, along with spare ammunition;</li>
					<li>The Detective may carry their telescopic baton;</li>
					<li>Should the Detective be assaulted by a crewmember, they must use the issued Telescopic Baton to apprehend them. Using the revolver is permitted only if the crewmember attempts to escape and there are no Officers available for backup;</li>
					<li>The Detective may not search anyone in the Brig without permission from the Warden or Head of Security;</li>
					<li>The Detective is not permitted to modify their revolver to chamber lethal rounds, under any circumstance;</li>
                    <li>The Detective must compile all evidence gathered into organized dossiers, and have at least one copy available at all times.</li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>Guidelines 4, 5, and 9 are carried over from Code Green;</li>
                    <li>If sufficient forensic evidence is collected, and there are no Security Officers available at the time, the Detective is permitted to carry out arrests if a prior warning is given via Security Comms;</li>
                    <li>The Detective is obligated to inform the suspect of the crimes they are accused;</li>
                    <li>The Detective may search any suspect in the Brig;</li>
                    <li>The Detective may pull aside any suspect for an interrogation, provided they receive authorization from the Head of Security or the Warden;</li>
                    <li>The Detective may unholster their revolver whenever they deem it necessary, though it is recommended they do so sparsely</li>
                    <li>Lethal Force is not permitted, unless there is a clear and immediate danger to the Detective's life </li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>Guidelines 4, 5 and 9 carry over from Code Green;</li>
                    <li>Guidelines 2, 3, 4, 5, 6 and 7 carry over from Code Blue;</li>
                    <li>The Detective may freely discharge his revolver when handling confirmed threats;</li>
                    <li>Lethal Force is permitted if the target is confirmed to be guilty of Capital Crimes and actively, and aggressively, resists arrest.</li>
				</ol><BR>
                <br><br>

                <h1><a name="pilot"><B>Security Pod Pilot</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>The Security Pod Pilot is permitted to carry out arrests under the same conditions as a Security Officer;</li>
					<li>The Security Pod Pilot is permitted to carry a taser, a flash, a stunbaton, a flashbang and a can of pepperspray;</li>
					<li>The Security Pod Pilot is not permitted to bring the Security Pod inside the station, except for designated Pod Bays;</li>
					<li>The Security Pod Pilot is not permitted to swap the Security Pod's weapon systems to the Laser Module unless a lethal threat, such as Space Carp or Attack Drones, is present;</li>
					<li>The Security Pod Pilot is not permitted to use the Laser Module during arrests, and must switch to the Disabler Module;</li>
					<li>The Security Pod Pilot must carry around a spare set of tools and energy cell, for their own sake;</li>
					<li>The Security Pod Pilot may immediately, and without warning, conduct arrests on individuals attempting to perform E.V.A actions near the AI Satellite. Exception is made if the AI Unit is malfunctioning;</li>
					<li>The Security Pod Pilot is not permitted to explore the area surrounding the station, and must therefore be confined to the immediate orbital area of the station, the NXS Klapaucius (the Telecomms Satellite) and the Mining/Research Asteroid. Exception is made if the Head of Security permits otherwise.</li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>Guidelines 1, 2, 7 and 8 are carried over from Code Green. In regards to Guideline 2, Pod Pilots are now also permitted to carry around Bulletproof Armour or Riot Gear; </li>
                    <li>Pod Pilots are permitted to carry weapons in hand during regular patrols;</li>
                    <li>Pod Pilots are permitted to present weapons during arrests;</li>
                    <li>Pod Pilots may demand entry to specific Departments during regular patrols;</li>
                    <li>Pod Pilots may randomly search crewmembers, but are not allowed to apply any degree of force unless said crewmember acts overtly hostile;;</li>
                    <li>Pod Pilots are permitted to leave prisoners bucklecuffed should they act hostile.</li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>Guidelines 1, 2, 7 and 8 carry over from Code Green; </li>
                    <li>All Guidelines carry over from Code Blue;</li>
                    <li>The Security Pod Pilot is permitted to carry any weapon from the Armory, but never more than one at a time. Exception is made for severe emergencies, such as Blob Organisms or Nuclear Operatives;</li>
                    <li>The Security Pod Pilot is permitted to bring the Security Pod inside the station in extreme emergencies;</li>
                    <li>The Security Pod Pilot is permitted to permanently install the Laser Module onto the Security Pod;</li>
                    <li>Lethal Force is permitted if the target is confirmed to be guilty of Capital Crimes and actively, and aggressively, resists arrest.</li>
				</ol><BR>
                <br><br>

                <h1><a name="phys"><B>Brig Physician</B></a></h1><BR>
				<h style='color: darkgreen'>Code Green</h>
				<ol>
					<li>The Brig Physician may not, under any circumstance, arrest anyone;</li>
					<li>The Brig Physician may not, under any circumstance, interfere with Security's duties;</li>
					<li>The Brig Physician may not, under any circumstance, directly alter a sentence, or attempt to contest one with Security personnel. Contacting a Magistrate/IAA/NT Representative is still acceptable;</li>
					<li>The Brig Physician must wait until someone is brigged and their timer starts before bringing them to the Brig Medbay. Exception is made if the Head of Security or Warden allows it, or there is a problem that requires immediate medical aid to prevent death;</li>
					<li>The Brig Physician may not stop a timer if a prisoner is brought into the Brig Medbay for treatment. The timer is to continue while they are treated. If the timer runs out during medical treatment, the prisoner is to be released;</li>
					<li>The Brig Physician may not restrain a prisoner unless they are actively hostile;</li>
					<li>The Brig Physician is permitted to carry a flash and a can of pepperspray;</li>
					<li>The Brig Physician must maintain the Brig Medbay, himself and all treated prisoners in a hygienic condition. Should the need arise, this extends to the rest of the Brig as well;</li>
                    <li>The Brig Physician must escort all prisoners requiring surgery to Medbay personally, and make sure that they are returned to the Brig before being released. The Brig Physician may also choose to construct a smaller surgery room inside the Brig Medbay.</li>
				</ol><BR>

				<h style='color: darkblue'>Code Blue</h>
				<ol>
					<li>All Guidelines carry over from Code Green;</li>
                    <li>Additional equipment may be provided by the Warden for self-defense;</li>
				</ol><BR>

				<h style='color: darkred'>Code Red</h>
				<ol>
					<li>All guidelines carry over from Code Green;</li>
                    <li>All guidelines carry over from Code Blue.</li>
				</ol><BR>
                <br><br>

				</body>
				</html>

		"}

/obj/item/book/manual/sop_legal
	name = "Legal Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all legal activities."
	icon_state = "book1"
	author = "Nanotrasen"
	title = "Legal Standard Operating Procedures"
	dat = {"

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
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#pun">Punishments</a></li>
					<li><a href="#brig">Brigging</a></li>
					<li><a href="#perma">Permabrigging</a></li>
					<li><a href="#exe">Execution: General</a></li>
                    <li><a href="#elec">Execution: Electric Chair</a></li>
                    <li><a href="#inject">Execution: Lethal Injection</a></li>
                    <li><a href="#squad">Execution:Firing Squad</a></li>
				</ol>
				<br><BR>

				<h1><a name="pun"><U><B>Punishments</B></U></a></h1><BR>
				These are the procedures for standard punishments, and should be followed unless an emergency makes them unable to be followed.<BR><BR>

				<h1><a name="brig"><B>Brigging</B></a></h1><BR>
				<ol>
					<li>No prisoner is to be held for longer than ten (10) minutes in Processing if no evidence against them is readily available. Should the ten (10) minutes expire without any evidence of any crimes coming to light, the prisoner is to be released. Otherwise, proceed with the following guidelines:</li>
                    <li>The prisoner is to be cuffed, and brought to their cell.</li>
                    <li>The prisoner is to be stripped of all belongings, save for their uniform, headset, ID, PDA and shoes. Vox are to retain their internals, plasmamen are to retain internals and their suit.</li>
                    <li>The prisoner is then to be uncuffed. If they are a violent risk, they may be bucklecuffed, flashed, then have their cuffs removed.</li>
                    <li>The timer for the cell is to be set, and the charges declared.</li>
                    <li>Prisoners attempting to break the windows of the cell are to be flashed and their timers reset.</li>
                    <li>Removal of the prisoner's headset may ONLY occur if the prisoner is using the headset to encourage further crimes or co-ordinate an escape attempt.</li>
				</ol>
                <br><br>

                <h1><a name="perma"><B>Permabrigging</B></a></h1><BR>
				<ol>
					<li>Prisoner must be cuffed, and their ID must be terminated.</li>
                    <li>Prisoner must be stripped of all belongings, except for his/her headset and ID Card. Said belongings must be placed in one of the lockers next to the Interrogation Room.</li>
                    <li>Prisoner must be clothed in a Prison Uniform and Orange Shoes.</li>
                    <li>Prisoner must be brought to the Permabrig area, and the doors behind closed properly.</li>
                    <li>Prisoner must be bucklecuffed to one of the beds.</li>
                    <li>Prisoner must have his cuffs removed, then be flashed or stunned, and the cuffs recovered.</li>
                    <li>All Security agents must then leave the Permabrig.</li>
                    <li>In the case of an attempted escape or riot, the Nitrous Oxide control is to be used.</li>
				</ol>
                <br><br>

                <h1><a name="exec"><B>Execution: General</B></a></h1><BR>
				<ol>
					<li>Prisoner must be cuffed, and their ID must be terminated.</li>
                    <li>Prisoner must be stripped of all belongings, except for his/her headset and ID Card. Said belongings must be placed in one of the lockers next to the Interrogation Room.</li>
                    <li>Prisoner must be clothed in a Prison Uniform and Orange Shoes.</li>
                    <li>Prisoner must be brought to the Prisoner Transfer room.</li>
                    <li>A Chaplain may be present if requested, and allowed by the HoS.</li>
                    <li>It is advised, but not required, to have a Brig Physician or other medical personell in attendance to verify death.</li>
                    <li>Authorization must be given by the Captain and/or Magistrate. Without authorization, executions are murder.</li>
                    <li>Though not obligatory, it is recommended that all executed prisoners be considered for borgification post-execution.</li>
				</ol>
                <br><br>

                <h1><a name="elec"><B>Execution: Electric Chair</B></a></h1><BR>
				<ol>
					<li>Prisoner must be bucklecuffed to the electric chair.</li>
                    <li>Prisoner must be allowed his/her final words, after which the chair will be activated.</li>
                    <li>Prisoner's pulse is to be checked to confirm death.</li>
                    <li>Prisoner must then be borged, fired into space via mass driver, cremated, or placed in the morgue with a DNR Notice, at the discretion of the Magistrate, Captain or Head of Security.</li>
				</ol>
                <br><br>

                <h1><a name="elec"><B>Execution: Lethal Injection</B></a></h1><BR>
				<ol>
					<li>Prisoner must be bucklecuffed to the electric chair or bed.</li>
                    <li>Prisoner must be allowed his/her final words, after which the injection will be applied.</li>
                    <li>Prisoner's pulse is to be checked to confirm death.</li>
                    <li>Prisoner must then be borged, fired into space via mass driver, cremated, or placed in the morgue with a DNR Notice, at the discretion of the Magistrate, Captain or Head of Security.</li>
				</ol>
                <br><br>

                 <h1><a name="elec"><B>Execution: Firing Squad</B></a></h1><BR>
				<ol>
					<li>Prisoner must be brought to the Firing Range.</li>
                    <li>Prisoner must be bucklecuffed to a chair.</li>
                    <li>Prisoner must be allowed his/her final words, after which authorised security personell are to open fire with any of the following: Energy Gun, Advanced Energy Gun, Laser Gun, Revolver, Shotgun, or any ranged weapon manufactured by Research.</li>
                    <li>Prisoner's pulse is to be checked to confirm death.</li>
                    <li>Prisoner must then be borged, fired into space via mass driver, cremated, or placed in the morgue with a DNR Notice, at the discretion of the Magistrate, Captain or Head of Security.</li>
				</ol>
                <br><br>
				</body>
				</html>

		"}

/obj/item/book/manual/sop_general
	name = "Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all station activities."
	icon_state = "book1"
	author = "Nanotrasen"
	title = "Standard Operating Procedures"
	dat = {"

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
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#foreword">FOREWORD</a></li>
					<li><a href="#green">Code Green</a></li>
					<li><a href="#blue">Code Blue</a></li>
					<li><a href="#red">Code Red</a></li>
                    <li><a href="#gamma">Code Gamma</a></li>
                    <li><a href="#hiring">Hiring Policies</a></li>
                    <li><a href="#firing">Firing Policies</a></li>
                    <li><a href="#causes">Causes for Demotion and Dismissal</a></li>
                    <li><a href="#sit">Situational SoP</a></li>
                    <li><a href="#evac">Evacuation</a></li>
                    <li><a href="#viral">Viral Outbreak Procedures</a></li>
                    <li><a href="#fire">Fire and Environmental Hazards</a></li>
                    <li><a href="#meteor">Meteor Storm</a></li>
                    <li><a href="#sing">Singularity Containment Failure</a></li>
				</ol>
				<br><BR>

				<h1><a name="foreword"><U><B>FOREWORD</B></U></a></h1><BR>
				Job SOP should not be a considered a checklist of conditions to fire someone over, and should not be rigidly followed to the letter in detriment of circumstances and context.
				As always, SOP can be malleable if the situation so requires, and the decision to punish a crewmember for breaching it ultimately falls onto the relevant Head of Staff,
				for Department Members, or Captain, for the Head of Staff.<BR><BR>


				<h1><a name="green"><B>Code Green</B></a></h1><BR>
                <i>All clear.</i><br>
                Default operating level. No immediate or clear threat to the station. All departments may carry out work as normal.
                This alert level can be set at the Communications Console with a Captain level ID.<br>
                <i>All threats to the station have passed. All weapons need to be holstered and privacy laws are once again fully enforced.</i><br>
                <br>
                Security:<br>
                <ul>
                    <li>Weapons worn by security/headstaff are to be holstered, except in emergencies.</li>
                    <li>Security must respect the privacy of crew members and no unauthorized searches are allowed. Searches of any kind may only be done with a signed warrant by the Head of Security or higher, or if there's evidence of criminal activity.</li>
                </ul>
                <br>
                Locations:<br>
                <ul>
                    <li>Secure areas are recommended to be left unbolted. This includes EVA, Teleporter, AI Upload, Engineering Secure Storage, and Tech Storage.</li>
                </ul>
                <br>
                Crew:<br>
                <ul>
                    <li>Crew members may freely walk in the hallways</li>
                    <li>Suit sensors are not mandatory.</li>
                </ul>
                <br><br>

                <h1><a name="blue"><B>Code Blue</B></a></h1><BR>
                <i>There is a suspected threat.</i><br>
                Raised alert level. Suspected threat to the station. Issued by Central Command, the Captain, or a Head of Staff vote. This alert level can be set at the Communications Console with a Captain level ID.<br>
                <i>Security staff may have weapons visible, random searches are permitted.</i><br>
                <br>
                Security:<br>
                <ul>
                    <li>Security may have weapons visible, but not drawn unless needed.</li>
                    <li>Energy guns, laser guns and riot gear are allowed to be given out to security personnel with clearance from the Warden or HoS.</li>
                    <li>Body Armour and helmets are recommended but not mandatory.</li>
                    <li> Random body and workplace searches are allowed without warrant.</li>
                </ul>
                <br>
                Locations:<br>
                <ul>
                    <li>Secure areas may be bolted down. This includes EVA, Teleporter, AI Upload, Engineering Secure Storage, and Tech Storage.</li>
                </ul>
                <br>
                Crew:<br>
                <ul>
                    <li>Employees are recommended to comply with all security requests.</li>
                    <li>Suit sensors are mandatory, but coordinate positions are not required.</li>
                </ul>
                <br><br>

                <h1><a name="red"><B>Code Red</B></a></h1><BR>
                <i>There is a confirmed threat.</i><br>
                Maximum alert level. Confirmed threat to the station or severe damage. Issued by Central Command, the Captain, or a Head of Staff vote. This alert level can only be set via the Keycard Authentication Devices in each Heads of Staff office and by swiping two Heads of Staff ID cards simultaneously.<br>
                <i>Security staff to be on high alert, random searches are permitted and recommended.</i><br>
                <br>
                Security:<br>
                <ul>
                    <li>Security may have weapons drawn at all times.</li>
                    <li>Body Armour and helmets are mandatory. Riot gear is also recommended for appropriate situations.</li>
                    <li>Random body and workplace searches are allowed and recommended.</li>
                </ul>
                <br>
                Locations:<br>
                <ul>
                    <li>Secure areas are recommended to be bolted.</li>
                </ul>
                <br>
                Crew:<br>
                <ul>
                    <li>Suit sensors and coordinate positions are mandatory.</li>
                    <li>All crew members must remain in their departments.</li>
                    <li>Employees are required to comply with all security requests.</li>
                    <li>Emergency Response Team may be authorised. All crew are to comply with their direction.</li>
                </ul>
                <br><br>

                <h1><a name="gamma"><B>Code Gamma</B></a></h1><BR>
                <i>Extremely hostile threat onboard the station.</i><br>
                GAMMA Security level has been set by Centcom.<br>
                <b>Security is to have weapons at hand at all time, random searches are permitted and Martial Law is declared.</b><br>
                <br>
                Security:<br>
                <ul>
                    <li>Security may have weapons drawn at all times.</li>
                    <li>Body Armour and helmets are mandatory. Riot gear is also recommended for appropriate situations.</li>
                    <li>Random body and workplace searches are allowed and recommended.</li>
                    <li>GAMMA Armory unlocked for security personnel.</li>
                </ul>
                <br>
                Locations:<br>
                <ul>
                    <li>Secure areas are to be bolted.</li>
                </ul>
                <br>
                Crew:<br>
                <ul>
                    <li>Employees are required to comply with all security requests.</li>
                    <li>All civilians are to seek their nearest head for transportation to a safe location.</li>
                    <li>All personnel are required to defend the station and help security with dealing with the threat. All crew must follow direct orders from Security Personell or Head of Staff.</li>
                </ul>
                <br><br>

                <h1><a name="hiring"><B>Hiring Policies</B></a></h1><BR>
                <ul>
                    <li>Authorisation from the relevant Department Head is required to be hired into a Department. If none exists, the HoP or Captain's authorisation is required.</li>
                    <li>Promotion to a Department Head requires authorisation from the Captain or Acting Captain.</li>
                    <li>CentComm Authorisation is required for hiring the following: Blueshield, Security Pod Pilot, Magistrate, Brig Physician, Nanotrasen Representative, Mechanic.</li>
                    <li>If no Department Head has yet been sent, any promotion to said position is on a temporary basis until one arrives. </li>
                    <li>All Security personnel are to be mindshield implanted.</li>
                </ul>
                <br><br>

                <h1><a name="firing"><B>Firing Policies</B></a></h1><BR>
                <ul>
                    <li>If a crew is to be dismissed, their ID is to be terminated.</li>
                    <li>Demotion may be to any rank lower than their current. Assistant or Janitor are recommended for punishments.</li>
                    <li>Demotion or Dismissal must be authorised by the relevant department head, or Captain.</li>
                    <li>Demotion or Dismissal must have due cause.</li>
                </ul>
                <br><br>

                <h1><a name="causes"><B>Causes for Demotion and Dismissal</B></a></h1><BR>
                <ul>
                    <li>A medium or higher crime may be grounds for dismissal, at the department head's discretion.</li>
                    <li>A Capital Crime requires dismissal.</li>
                    <li>Any crew shown not to have the skills or knowledge necessary for the position should be dismissed.</li>
                    <li>Failure to follow SoP may be grounds for dismissal, at the Department Head's discretion.</li>
                    <li>Failure to follow SoP causing harm to crew requires dismissal, and brig time.</li>
                    <li> Refusal to follow reasonable and legal orders from relevant department head is grounds for dismissal. Their status as reasonable and legal is to be judged by the HoP or Captain.</li>
                    <li>A crew member creating an abusive and hostile work environment may be dismissed or demoted. This is to be judged by the Department Head and HoP.</li>
                    <li>Demotion or dismissal may be in person, or declared on a radio channel. If demoted or dismissed, an employee is required to attend the HoP office to hand in their ID, and to leave all items as part of their job at their workplace.</li>
                    <li> Reasonable time is to be allowed for the fired persons to obtain a new set of clothing from the locker room.</li>
                    <li>Failure or refusal to hand in any items, ID, etc, of their previous job, is to be considered theft.</li>
                </ul>
                <br><br>

                <h1><a name="sit"><B>Situational SoP</B></a></h1><BR>
                The following situations have specific SoP. Failure to follow these may result in demotion/dismissal, or detaining by security if failure to follow them presents a significant risk.
                <br><br>

                <h1><a name="causes"><B>Evacuation</B></a></h1><BR>
                <ul>
                    <li>All personnel are required to assist with evacuation. All crew must be evacuated, regardless of conscious state.</li>
                    <li>A Capital Crime requires dismissal.</li>
                    <li>All prisoners are to be brought to the secure area of the escape shuttle, unless doing so would cause unnecessary risk for crew.</li>
                    <li>Bodies are to be brought back to Central Command for processing.</li>
                    <li> AI units may be brought to Central Command on portable card devices (Intelicards) if structural failure is likely.</li>
                    <li>Shortening time to shuttle launch may be authorised if a clear threat to life, limb, or shuttle integrity is present.</li>
                </ul>
                <br><br>

                <h1><a name="viral"><b>Viral Outbreak Procedures</b></a></h1><BR>
                <i><b>Definition: </b>A Viral Outbreak is defined as a situation where a Viral Pathogen has infected a significant portion of the crew (>10%)</i>
				<ol>
					<li>All Medbay personnel are to contribute in fighting the outbreak if there are no other critical patients requiring assistance. Eliminating the Viral Threat becomes <b>number one priority;</b></li>
                    <li>Personnel are to be informed of known symptoms, and directed to Medbay immediately if they are suffering from them;</li>
                    <li>All infected personnel are to be confined to either an Isolated Room, or Virology;</li>
                    <li>A blood sample is to be taken from an infected person, for study;</li>
                    <li>If any infected personnel attempt to leave containment, Medbay Quarantine is to be <b>initiated immediately</b>, and only lifted when more patients need to be admitted, or the Viral Outbreak is over;</li>
                    <li>A single infected person may volunteer to receive a dose of Radium in order to develop Antibodies. Radium must not be administered without consent. Otherwise, animal testing is to be conducted in order to obtain Antibodies;</li>
                    <li>Once Antibodies are produced, they are to be diluted, then handed out to all infected personnel. Injecting infected personnel with Radium after Antibodies have been extracted is <b>forbidden</b>. In the event of a large enough crisis, directly injecting blood with the relevant Antibodies is permissible;</li>
                    <li>Viral Pathogen should be cataloged and analyzed, in case any stray cases remained untreated;</li>
                    <li>Cured personnel should have a sample of their blood removed for the purpose of creating antibodies, until there are no infected personnel left;</li>
                    <li>In case the Viral Pathogen leads to fluid leakage, cleaning these fluids is to be considered top priority;</li>
                    <li>Once the Viral Outbreak is over, all personnel are to return to regular duties.</li>
                </ol>
                <br><br>

                <h1><a name="evac"><B>Evacuation</B></a></h1><BR>
                <ul>
                    <li>Immediate evacuation of all untrained personnel.</li>
                    <li>Fire alarms to be used to control hazard.</li>
                    <li>Atmospheric Technicians are to remove hazard.</li>
                </ul>
                <br><br>

                <h1><a name="meteor"><B>Meteor Storm</B></a></h1><BR>
                <ul>
                    <li>All crew to move to central parts of the station.</li>
                    <li>Damage is to be repaired by engineering personnel after the threat has passed.</li>
                    <li>Personel that are doing EVA maintenance should seek shelter immediately.</li>
                </ul>
                <br><br>

                <h1><a name="sing"><B>Singularity Containment Failure</B></a></h1><BR>
                <ul>
                    <li>Observation of Singularity movement.</li>
                    <li>Evacuation to be called if deemed a major threat to station integrity.</li>
                    <li>Demotion of Chief Engineer and reparation of Engine if no threat manifests.</li>
                </ul>
                <br><br>

				</body>
				</html>

		"}

/obj/item/book/manual/sop_command
	name = "Command Standard Operating Procedures"
	desc = "A set of guidelines aiming at the safe conduct of all Command activities."
	icon_state = "book4"
	author = "Nanotrasen"
	title = "Command Standard Operating Procedures"
	dat = {"

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
				<font face="Verdana" color=black>

				<h1><a name="Contents">Contents</a></h1>
				<ol>
					<li><a href="#foreword">Foreword</a></li>
					<li><a href="#cap">Captain</a></li>
					<li><a href="#hop">Head of Personnel</a></li>
					<li><a href="#ntrep">Nanotrasen Representative</a></li>
					<li><a href="#bs">Blueshield Officer</a></li>
                    <li><a href="#ai">AI</a></li>
				</ol>
				<br><BR>

				<h1><a name="foreword"><U><B>FOREWORD</B></U></a></h1><BR>
				Job SOP should not be a considered a checklist of conditions to fire someone over, and should not be rigidly followed to the letter in detriment of circumstances and context.
				As always, SOP can be malleable if the situation so requires, and the decision to punish a crewmember for breaching it ultimately falls onto the relevant Head of Staff,
				for Department Members, or Captain, for the Head of Staff.<BR><BR>

				<h1><a name="cap"><B>Captain</B></a></h1><BR>
				<ol>
					<li>The Captain is not permitted to perform regular Security Duty. However, they may still assist Security if they are understaffed, or if they see a crime being committed. However, the Captain is not permitted to take items from the Armory under normal circumstances, unless authorized by the Head of Security. In addition, the Captain may not requisition weaponry for themselves from Cargo and/or Science, unless there's an immediate threat to station and/or crew;</li>
					<li>If a Department lacks a Head of Staff, the Captain should make reasonable efforts to appoint an Acting Head of Staff, if there are available personnel to fill the position;</li>
					<li>The Captain is to ensure that Space Law is being correctly applied. This should be done in cooperation with the Head of Security;</li>
					<li>The Captain is not to leave the station unless given specific permission by Central Command, or it happens to be the end of the shift. This includes via space or via the Gateway. To do so is to be considered abandoning their posts and is grounds for termination;</li>
					<li>The Captain must keep the Nuclear Authentication Disk on their person at all times or, failing that, in the possession of the Head of Security or Blueshield;</li>
					<li>The Captain is to attempt to resolve every issue that arises in Command locally before contacting Central Command;</li>
					<li>The Captain is not permitted to carry their Antique Laser Gun or Space Armor unless there's an immediate emergency that requires attending to;</li>
					<li>The Captain, despite being in charge of the station, is not independent from Nanotrasen. Any attempts to disregard general company policy are to be considered an instant condition for contract termination;</li>
					<li>The Captain may only promote personnel to a Acting Head of Staff position if there is no assigned Head of Staff associated with the Department. Said Acting Head of Staff must be a member of the Department they are to lead. See below for more information on Chain of Command;</li>
                    <li>The Captain may not fire any Head of Staff without reasonable justification (ie, incompetency, criminal activity, or otherwise any action that endangers/compromises the station and/or crew). The Captain may not fire any Central Command VIPs (ie, Blueshield, Magistrate, Nanotrasen Representative) without permission from Central Command, unless they are blatantly acting against the well-being and safety of the crew and station.</li>
				</ol><BR>

                <h1><a name="hop"><B>Head of Personnel</B></a></h1><BR>
				<ol>
					<li>The Head of Personnel may not transfer any personnel to another Department without authorization from the relevant Head of Staff. If no Head of Staff is available, the Head of Personnel may make a judgement call. This does not apply to Security, which always requires authorization from the Head of Security, or Genetics, which requires both Chief Medical Officer and Research Director approval. If there is no Head of Security active, no transfers are allowed to Security without authorization from the Captain;</li>
					<li>The Head of Personnel may not give any personnel increased access without authorization from the relevant Head of Staff. This includes the Head of Personnel. In addition, the Head of Personnel may only give Captain-Level access to someone if they are the Acting Captain. This access is to be removed when a proper Captain arrives on the station;</li>
					<li>The Head of Personnel may not increase any Job Openings unless the relevant Head of Staff approves;</li>
					<li>The Head of Personnel may not fire any personnel without authorization from the relevant Head of Staff, unless other conditions apply (see Space Law and General Standard Operating Procedure);</li>
					<li>The Head of Personnel may not promote any personnel to the following Jobs without authorization from Central Command: Barber, Brig Physician, Nanotrasen Representative, Blueshield, Security Pod Pilot, Mechanic and Magistrate; (This is due to them being karma locked. Do not promote people to these positions without approval from the Administrators);</li>
					<li>The Head of Personnel is free to utilize paperwork at their discretion. However, during major station emergencies, expediency should take precedence over bureaucracy;</li>
					<li>The Head of Personnel may not leave their office unmanned if there are personnel waiting in line. Failure to respond to personnel with a legitimate request within ten (10) minutes, either via radio or in person, is to be considered a breach of Standard Operating Procedure;</li>
					<li>Despite nominally being in charge of Supply, the Head of Personnel should allow the Quartermaster to run the Department, unless they prove themselves to be incompetent/dangerous;</li>
                    <li>The Head of Personnel is bound to the same rules regarding ordering Cargo Crates as the Quartermaster and Cargo Technicians. In addition, the Head of Personnel may not order unneeded, non-essential items against the wishes of Cargo;</li>
                    <li>The Head of Personnel is not permitted to perform Security duty. The Head of Personnel is permitted to carry an Energy Gun, for self-defence only.</li>
				</ol><BR>

				<h1><a name="ntrep"><B>Nanotrasen Representative</B></a></h1><BR>
				<ol>
					<li>The Nanotrasen Representative is to ensure that every Department is following Standard Operating Procedure, up to and including the respective Head of Staff. If a Head of Staff is not available for a Department, the Nanotrasen Representative must ensure that the Captain appoints an Acting Head of Staff for said Department;</li>
					<li>The Nanotrasen Representative must attempt to resolve any breach of Standard Operating Procedure locally before contacting Central Command. This is an imperative: Standard Operating Procedure should always be followed unless there is a very good reason not to;</li>
					<li>The Nanotrasen Representative must, together with the Magistrate and Head of Security, ensure that Space Law is being followed and correctly applied;</li>
					<li>The Nanotrasen Representative may not threaten the use of a fax in order to gain leverage over any personnel, up to and including Command. In addition they may not threaten to fire, or have Central Command, fire anyone, unless they actually possess a demotion note;</li>
					<li>The Nanotrasen Representative is permitted to carry their Stun-Cane, or a Telescopic Baton if the Stun-Cane is lost.</li>
				</ol><BR>

                <h1><a name="bs"><B>Blueshield Officer</B></a></h1><BR>
				<ol>
					<li>The Blueshield may not conduct arrests under the same conditions as Security. However, they may apprehend any personnel that trespass on a Head of Staff Office or Command Area, any personnel that steal from those locations, or any personnel that steal from and/or injure any Head of Staff or Central Command VIP. However, all apprehended personnel are to be processed by Security personnel;</li>
					<li>The Blueshield is to put the lives of Command over those of any other personnel, the Blueshield included. Their continued well-being is the Blueshield's top priority. This includes applying basic first aid and making sure they are revived if killed;</li>
					<li>The Blueshield is to protect the lives of Command personnel, not follow their orders to a fault. The Blueshield is not to interfere with legal demotions or arrests. To do so is to place themselves under the Special Modifier Aiding and Abetting;</li>
					<li>The Blueshield is not to apply Lethal Force unless there is a clear and present danger to their life, or to the life of a member of Command, and the assailant cannot be non-lethally detained.</li>
				</ol><BR>

	            <h1><a name="ai"><B>AI</B></a></h1><BR>
				<b><i>The following are procedures for AI Maintenance:</i></b><br>
				<ol>
					<li>Only the Captain or Research Director may enter the AI Upload to perform Law Changes (see below), and only the Captain, Research Director or Chief Engineer may enter the AI Core to perform a Carding (see below);</li>
					<li> No Law Changes are to be performed without approval from the Captain and Research Director. The only Lawsets to be used are those provided by Nanotrasen. Failure to legally perform a Law Change is to be considered Sabotage. Command must be informed prior to the Law Change, and all objections must be taken into consideration. If the number of Command personnel opposing the Law Change is greater than the number of Command personnel in favour, the Law Change is not to be done. If the Law Change is performed, the crew is to be immediately informed of the new Law(s);</li>
                    <li>The AI may not be Carded unless it it clearly malfunctioning or subverted. However, any member of Command may card it if the AI agrees to it, either at the end of the shift, or due to external circumstances (such as massive damage to the AI Satellite);</li>
                    <li>The AI Upload and Minisat Antechamber Turrets are to be kept on Non-Lethal in Code Green and Code Blue. The AI Core Turrets are to be kept on Lethal at all times. If a legal Law Change or Carding is occurring, the Turrets are to be disabled;</li>
                    <li>If the AI Unit is not malfunctioning or subverted, any attempt at performing an illegal Carding or Law Change is to be responded to with non-lethal force. If the illegal attempts persist, and the perpetrator is demonstrably hostile, lethal force from Command/Security is permitted;</li>
                    <li>Freeform Laws are only to be added if absolutely necessary due to external circumstances (such as major station emergencies). Adding unnecessary Freeform Laws is not permitted. Exception is made if the AI Unit and majority of Command agree to the Freeform Law that is proposed;</li>
                    <li>Any use of the "Purge" Module is to be followed by the upload of a Nanotrasen-approved Lawset immediately. AI Units must be bound to a Lawset at all times.</li>
				</ol><BR>
				</body>
				</html>

		"}
