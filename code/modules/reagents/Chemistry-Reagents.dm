#define SOLID 1
#define LIQUID 2
#define GAS 3
#define FOOD_METABOLISM 0.4
#define REM REAGENTS_EFFECT_MULTIPLIER

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.

//Some on_mob_life() procs check for alien races.
#define IS_DIONA 1
#define IS_VOX 2
// ^ fuck this shit holy fuck - Iamgoofball
datum
	reagent
		var/name = "Reagent"
		var/id = "reagent"
		var/description = ""
		var/datum/reagents/holder = null
		var/reagent_state = SOLID
		var/list/data = null
		var/volume = 0
		var/nutriment_factor = 0
		var/metabolization_rate = REAGENTS_METABOLISM
		//var/list/viruses = list()
		var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)
		var/shock_reduction = 0
		var/penetrates_skin = 0 //Whether or not a reagent penetrates the skin
		proc
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume) //Some reagents transfer on touch, others don't; dependent on if they penetrate the skin or not.
				if(!istype(M, /mob/living))	return 0
				var/datum/reagent/self = src
				src = null

				if(self.holder)		//for catching rare runtimes
					if(method == TOUCH && self.penetrates_skin)
						var/block  = 0
						for(var/obj/item/clothing/C in M.get_equipped_items())
							if(istype(C, /obj/item/clothing/suit/bio_suit))
								block += 1
							if(istype(C, /obj/item/clothing/head/bio_hood))
								block += 1
						if(block < 2)
							if(M.reagents)
								M.reagents.add_reagent(self.id,self.volume)

/*
					if(method == INGEST && istype(M, /mob/living/carbon))
						if(prob(1 * self.addictiveness))
							if(prob(5 * volume))
								var/datum/disease/addiction/A = new /datum/disease/addiction
								A.addicted_to = self
								A.name = "[self.name] Addiction"
								A.addiction ="[self.name]"
								A.cure = self.id
								M.viruses += A
								A.affected_mob = M
								A.holder = M
*/
					return 1

			reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
				src = null						//if it can hold reagents. nope!
				//if(O.reagents)
				//	O.reagents.add_reagent(id,volume/3)
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				return

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(!istype(M, /mob/living)) // YOU'RE A FUCKING RETARD NEO WHY CAN'T YOU JUST FIX THE PROBLEM ON THE REAGENT - Iamgoofball
					return //Noticed runtime errors from facid trying to damage ghosts, this should fix. --NEO
							// Certain elements in too large amounts cause side-effects
				holder.remove_reagent(src.id, metabolization_rate) //By default it slowly disappears.
				current_cycle++
				return

			// Called when two reagents of the same are mixing.
			on_merge(var/data)
				return

			on_move(var/mob/M)
				return

			on_update(var/atom/A)
				return

		slimejelly
			name = "Slime Jelly"
			id = "slimejelly"
			description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
			reagent_state = LIQUID
			color = "#801E28" // rgb: 128, 30, 40
			on_mob_life(var/mob/living/M as mob)
				if(prob(10))
					M << "\red Your insides are burning!"
					M.adjustToxLoss(rand(20,60)*REM)
				else if(prob(40))
					M.heal_organ_damage(5*REM,0)
				..()
				return


		blood
			data = new/list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"blood_colour"= "#A10808","resistances"=null,"trace_chem"=null, "antibodies" = null)
			name = "Blood"
			id = "blood"
			reagent_state = LIQUID
			color = "#C80000" // rgb: 200, 0, 0

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				var/datum/reagent/blood/self = src
				src = null
				if(self.data && self.data["virus2"] && istype(M, /mob/living/carbon))//infecting...
					var/list/vlist = self.data["virus2"]
					if (vlist.len)
						for (var/ID in vlist)
							var/datum/disease2/disease/V = vlist[ID]

							if(method == TOUCH)
								infect_virus2(M,V.getcopy())
							else
								infect_virus2(M,V.getcopy(),1) //injected, force infection!
				if(self.data && self.data["antibodies"] && istype(M, /mob/living/carbon))//... and curing
					var/mob/living/carbon/C = M
					C.antibodies |= self.data["antibodies"]

			on_merge(var/data)
				if(data["blood_colour"])
					color = data["blood_colour"]
				return ..()

			on_update(var/atom/A)
				if(data["blood_colour"])
					color = data["blood_colour"]
				return ..()



			reaction_turf(var/turf/simulated/T, var/volume)//splash the blood all over the place
				if(!istype(T)) return
				var/datum/reagent/blood/self = src
				src = null
				if(!(volume >= 3)) return
				//var/datum/disease/D = self.data["virus"]
				if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
					var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
					if(!blood_prop) //first blood!
						blood_prop = new(T)
						blood_prop.blood_DNA[self.data["blood_DNA"]] = self.data["blood_type"]

					if(self.data["virus2"])
						blood_prop.virus2 = virus_copylist(self.data["virus2"])


				else if(istype(self.data["donor"], /mob/living/carbon/monkey))
					var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T
					if(!blood_prop)
						blood_prop = new(T)
						blood_prop.blood_DNA["Non-Human DNA"] = "A+"

				else if(istype(self.data["donor"], /mob/living/carbon/alien))
					var/obj/effect/decal/cleanable/blood/xeno/blood_prop = locate() in T
					if(!blood_prop)
						blood_prop = new(T)
						blood_prop.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"
				return

/* Must check the transfering of reagents and their data first. They all can point to one disease datum.

			Destroy()
				if(src.data["virus"])
					var/datum/disease/D = src.data["virus"]
					D.cure(0)
				..()
*/

/*
		vaccine
			//data must contain virus type
			name = "Vaccine"
			id = "vaccine"
			reagent_state = LIQUID
			color = "#C81040" // rgb: 200, 16, 64

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				var/datum/reagent/vaccine/self = src
				src = null
				if(self.data&&method == INGEST)
					for(var/datum/disease/D in M.viruses)
						if(istype(D, /datum/disease/advance))
							var/datum/disease/advance/A = D
							if(A.GetDiseaseID() == self.data)
								D.cure()
						else
							if(D.type == self.data)
								D.cure()

					M.resistances += self.data
				return
*/

		water
			name = "Water"
			id = "water"
			description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
			reagent_state = LIQUID
			color = "#0064C8" // rgb: 0, 100, 200
			var/cooling_temperature = 2

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(!istype(M, /mob/living))
					return

			// Put out fire
				if(method == TOUCH)
					M.adjust_fire_stacks(-(volume / 10))
					if(M.fire_stacks <= 0)
						M.ExtinguishMob()
					return

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 3)
					if(T.wet >= 1) return
					T.wet = 1
					if(T.wet_overlay)
						T.overlays -= T.wet_overlay
						T.wet_overlay = null
					T.wet_overlay = image('icons/effects/water.dmi',T,"wet_floor")
					T.overlays += T.wet_overlay

					spawn(800)
						if (!istype(T)) return
						if(T.wet >= 2) return
						T.wet = 0
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null

				for(var/mob/living/carbon/slime/M in T)
					M.apply_water()

				var/hotspot = (locate(/obj/effect/hotspot) in T)
				if(hotspot && !istype(T, /turf/space))
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					qdel(hotspot)
				return

			reaction_obj(var/obj/O, var/volume)
				src = null
				var/turf/T = get_turf(O)
				var/hotspot = (locate(/obj/effect/hotspot) in T)
				if(hotspot && !istype(T, /turf/space))
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					qdel(hotspot)
				if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
					var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
					if(!cube.wrapped)
						cube.Expand()
				// Dehydrated carp
				if(istype(O,/obj/item/toy/carpplushie/dehy_carp))
					var/obj/item/toy/carpplushie/dehy_carp/dehy = O
					dehy.Swell() // Makes a carp
				return

		hellwater
			name = "Hell Water"
			id = "hell_water"
			description = "YOUR FLESH! IT BURNS!"

			on_mob_life(var/mob/living/M as mob)
				M.fire_stacks = min(5,M.fire_stacks + 3)
				M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
				M.adjustToxLoss(1)
				M.adjustFireLoss(1)		//Hence the other damages... ain't I a bastard?
				M.adjustBrainLoss(5)
				holder.remove_reagent(src.id, 1)

		lube
			name = "Space Lube"
			id = "lube"
			description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
			reagent_state = LIQUID
			color = "#1BB1AB"

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 1)
					if(T.wet >= 2) return
					T.wet = 2
					spawn(800)
						if (!istype(T)) return
						T.wet = 0
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null
						return

		toxin
			name = "Toxin"
			id = "toxin"
			description = "A Toxic chemical."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(2)
				..()
				return

		spider_venom
			name = "Spider venom"
			id = "spidertoxin"
			description = "A toxic venom injected by spacefaring arachnids."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1.5)
				..()
				return

		plasticide
			name = "Plasticide"
			id = "plasticide"
			description = "Liquid plastic, do not eat."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1.5)
				..()
				return

		minttoxin
			name = "Mint Toxin"
			id = "minttoxin"
			description = "Useful for dealing with undesirable customers."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if (FAT in M.mutations)
					M.gib()
				..()
				return

		slimetoxin
			name = "Mutation Toxin"
			id = "mutationtoxin"
			description = "A corruptive toxin produced by slimes."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(ishuman(M))
					var/mob/living/carbon/human/human = M
					if(human.species.name != "Shadow")
						M << "\red Your flesh rapidly mutates!"
						M << "<b>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</b>"
						M << "\red Your body reacts violently to light. \green However, it naturally heals in darkness."
						M << "Aside from your new traits, you are mentally unchanged and retain your prior obligations."
						human.set_species("Shadow")
				..()
				return



		aslimetoxin
			name = "Advanced Mutation Toxin"
			id = "amutationtoxin"
			description = "An advanced corruptive toxin produced by slimes."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(istype(M, /mob/living/carbon) && M.stat != DEAD)
					M << "\red Your flesh rapidly mutates!"
					if(M.monkeyizing)	return
					M.monkeyizing = 1
					M.canmove = 0
					M.icon = null
					M.overlays.Cut()
					M.invisibility = 101
					for(var/obj/item/W in M)
						if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
							del(W)
							continue
						W.layer = initial(W.layer)
						W.loc = M.loc
						W.dropped(M)
					var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(M.loc)
					new_mob.a_intent = "harm"
					new_mob.universal_speak = 1
					if(M.mind)
						M.mind.transfer_to(new_mob)
					else
						new_mob.key = M.key
					del(M)
				..()
				return

		space_drugs
			name = "Space drugs"
			id = "space_drugs"
			description = "An illegal chemical compound used as drug."
			reagent_state = LIQUID
			color = "#9087A2"
			metabolization_rate = 0.2

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(isturf(M.loc) && !istype(M.loc, /turf/space))
					if(M.canmove && !M.restrained())
						if(prob(10)) step(M, pick(cardinal))
				if(prob(7)) M.emote(pick("twitch","drool","moan","giggle"))
				..()
				return

		holywater
			name = "Water"
			id = "holywater"
			description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
			reagent_state = LIQUID
			color = "#0064C8" // rgb: 0, 100, 200

			on_mob_life(var/mob/living/M as mob)
				if(ishuman(M))
					if((M.mind in ticker.mode.cult) && prob(10))
						M << "\blue A cooling sensation from inside you brings you an untold calmness."
						ticker.mode.remove_cultist(M.mind)
						ticker.mode.remove_all_cult_icons_from_client(M.client)  // fixes the deconverted's own client not removing their mob's cult icon
						for(var/mob/O in viewers(M, null))
							O.show_message(text("\blue []'s eyes blink and become clearer.", M), 1) // So observers know it worked.
					// Vampires who ingest holy water combust if it's in their system for long enough.
					if(((M.mind in ticker.mode.vampires) || M.mind.vampire) && (!(VAMP_FULL in M.mind.vampire.powers)) && prob(80))
						data++
						switch(data)
							if(1 to 3)
								M << "<span class = 'warning'>Something sizzles in your veins!</span>"
								M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
							if(4 to 10)
								M << "<span class = 'danger'>You feel an intense burning inside of you!</span>"
								M.adjustFireLoss(1)
								M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
							if(11 to INFINITY)
								M << "<span class = 'danger'>You suddenly ignite in a holy fire!</span>"
								for(var/mob/O in viewers(M, null))
									O.show_message(text("<span class = 'danger'>[] suddenly bursts into flames!<span>", M), 1)
								M.fire_stacks = min(5,M.fire_stacks + 3)
								M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
								M.adjustFireLoss(3)		//Hence the other damages... ain't I a bastard?
								M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
				holder.remove_reagent(src.id, 10 * REAGENTS_METABOLISM) //high metabolism to prevent extended uncult rolls.


			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				// Vampires have their powers weakened by holy water applied to the skin.
				if(ishuman(M))
					if((M.mind in ticker.mode.vampires) && !(VAMP_FULL in M.mind.vampire.powers))
						var/mob/living/carbon/human/H=M
						if(method == TOUCH)
							if(H.wear_mask)
								H << "\red Your mask protects you from the holy water!"
								return
							else if(H.head)
								H << "\red Your helmet protects you from the holy water!"
								return
							else
								M << "<span class='warning'>Something holy interferes with your powers!</span>"
								M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
				return

		serotrotium
			name = "Serotrotium"
			id = "serotrotium"
			description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
			reagent_state = LIQUID
			color = "#202040" // rgb: 20, 20, 40

			on_mob_life(var/mob/living/M as mob)
				if(ishuman(M))
					if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
					holder.remove_reagent(src.id, 0.25 * REAGENTS_METABOLISM)
				return

/*		silicate
			name = "Silicate"
			id = "silicate"
			description = "A compound that can be used to reinforce glass."
			reagent_state = LIQUID
			color = "#C7FFFF" // rgb: 199, 255, 255

			reaction_obj(var/obj/O, var/volume)
				src = null
				if(istype(O,/obj/structure/window))
					if(O:silicate <= 200)

						O:silicate += volume
						O:health += volume * 3

						if(!O:silicateIcon)
							var/icon/I = icon(O.icon,O.icon_state,O.dir)

							var/r = (volume / 100) + 1
							var/g = (volume / 70) + 1
							var/b = (volume / 50) + 1
							I.SetIntensity(r,g,b)
							O.icon = I
							O:silicateIcon = I
						else
							var/icon/I = O:silicateIcon

							var/r = (volume / 100) + 1
							var/g = (volume / 70) + 1
							var/b = (volume / 50) + 1
							I.SetIntensity(r,g,b)
							O.icon = I
							O:silicateIcon = I

				return*/

		oxygen
			name = "Oxygen"
			id = "oxygen"
			description = "A colorless, odorless gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2) return
				if(alien && alien == IS_VOX)
					M.adjustToxLoss(REAGENTS_METABOLISM)
					holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
					return
				..()

		copper
			name = "Copper"
			id = "copper"
			description = "A highly ductile metal."
			color = "#6E3B08" // rgb: 110, 59, 8


		nitrogen
			name = "Nitrogen"
			id = "nitrogen"
			description = "A colorless, odorless, tasteless gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128


			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2) return
				if(alien && alien == IS_VOX)
					M.adjustOxyLoss(-2*REM)
					holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
					return
				..()

		hydrogen
			name = "Hydrogen"
			id = "hydrogen"
			description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128


		potassium
			name = "Potassium"
			id = "potassium"
			description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
			reagent_state = SOLID
			color = "#A0A0A0" // rgb: 160, 160, 160


		mercury
			name = "Mercury"
			id = "mercury"
			description = "A chemical element."
			reagent_state = LIQUID
			color = "#484848" // rgb: 72, 72, 72
			metabolization_rate = 0.2
			penetrates_skin = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(prob(70))
					M.adjustBrainLoss(1)
				..()
				return

		sulfur
			name = "Sulfur"
			id = "sulfur"
			description = "A chemical element."
			reagent_state = SOLID
			color = "#BF8C00" // rgb: 191, 140, 0

		carbon
			name = "Carbon"
			id = "carbon"
			description = "A chemical element."
			reagent_state = SOLID
			color = "#1C1300" // rgb: 30, 20, 0


			reaction_turf(var/turf/T, var/volume)
				src = null
				// Only add one dirt per turf.  Was causing people to crash.
				if(!istype(T, /turf/space) && !(locate(/obj/effect/decal/cleanable/dirt) in T))
					new /obj/effect/decal/cleanable/dirt(T)

		chlorine
			name = "Chlorine"
			id = "chlorine"
			description = "A chemical element."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128
			penetrates_skin = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustFireLoss(1)
				..()
				return

		fluorine
			name = "Fluorine"
			id = "fluorine"
			description = "A highly-reactive chemical element."
			reagent_state = GAS
			color = "#6A6054"
			penetrates_skin = 1


			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustFireLoss(1)
				M.adjustToxLoss(1*REM)
				..()
				return

		sodium
			name = "Sodium"
			id = "sodium"
			description = "A chemical element."
			reagent_state = SOLID
			color = "#808080" // rgb: 128, 128, 128


		phosphorus
			name = "Phosphorus"
			id = "phosphorus"
			description = "A chemical element."
			reagent_state = SOLID
			color = "#832828" // rgb: 131, 40, 40


		lithium
			name = "Lithium"
			id = "lithium"
			description = "A chemical element."
			reagent_state = SOLID
			color = "#808080" // rgb: 128, 128, 128

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
					step(M, pick(cardinal))
				if(prob(5)) M.emote(pick("twitch","drool","moan"))
				..()
				return

		sugar
			name = "Sugar"
			id = "sugar"
			description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
			reagent_state = SOLID
			color = "#FFFFFF" // rgb: 255, 255, 255
			overdose_threshold = 200 // Hyperglycaemic shock

			on_mob_life(var/mob/living/M as mob)
				if(prob(4))
					M.reagents.add_reagent("epinephrine", 1.2)
				if(prob(50))
					M.AdjustParalysis(-1)
					M.AdjustStunned(-1)
					M.AdjustWeakened(-1)
				if(current_cycle >= 90)
					M.jitteriness += 10
				..()
				return

			overdose_process(var/mob/living/M as mob)
				if(volume > 200)
					M << "<span class = 'danger'>You pass out from hyperglycemic shock!</span>"
					M.Paralyse(1)
				..()
				return

		sacid
			name = "Sulphuric acid"
			id = "sacid"
			description = "A strong mineral acid with the molecular formula H2SO4."
			reagent_state = LIQUID
			color = "#00D72B"

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1*REM)
				M.adjustFireLoss(1)
				..()
				return
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M

						if(volume > 25)

							if(H.wear_mask)
								H << "\red Your mask protects you from the acid!"
								return

							if(H.head)
								H << "\red Your helmet protects you from the acid!"
								return

							if(!M.unacidable)
								if(prob(75))
									var/obj/item/organ/external/affecting = H.get_organ("head")
									if(affecting)
										affecting.take_damage(20, 0)
										H.UpdateDamageIcon()
										H.emote("scream")
								else
									M.take_organ_damage(15,0)
						else
							M.take_organ_damage(15,0)

				if(method == INGEST)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M

						if(volume < 10)
							M << "<span class = 'danger'>The greenish acidic substance stings you, but isn't concentrated enough to harm you!</span>"

						if(volume >=10 && volume <=25)
							if(!H.unacidable)
								M.take_organ_damage(min(max(volume-10,2)*2,20),0)
								M.emote("scream")


						if(volume > 25)
							if(!M.unacidable)
								if(prob(75))
									var/obj/item/organ/external/affecting = H.get_organ("head")
									if(affecting)
										affecting.take_damage(20, 0)
										H.UpdateDamageIcon()
										H.emote("scream")
								else
									M.take_organ_damage(15,0)

			reaction_obj(var/obj/O, var/volume)
				if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(40))
					if(!O.unacidable)
						var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
						I.desc = "Looks like this was \an [O] some time ago."
						for(var/mob/M in viewers(5, O))
							M << "\red \the [O] melts."
						del(O)

		glycerol
			name = "Glycerol"
			id = "glycerol"
			description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
			reagent_state = LIQUID
			color = "#808080" // rgb: 128, 128, 128


		nitroglycerin
			name = "Nitroglycerin"
			id = "nitroglycerin"
			description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
			reagent_state = LIQUID
			color = "#808080" // rgb: 128, 128, 128

		radium
			name = "Radium"
			id = "radium"
			description = "Radium is an alkaline earth metal. It is extremely radioactive."
			reagent_state = SOLID
			color = "#C7C7C7" // rgb: 199,199,199
			metabolization_rate = 0.4
			penetrates_skin = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.apply_effect(4*REM,IRRADIATE,0)
				// radium may increase your chances to cure a disease
				if(istype(M,/mob/living/carbon)) // make sure to only use it on carbon mobs
					var/mob/living/carbon/C = M
					if(C.virus2.len)
						for (var/ID in C.virus2)
							var/datum/disease2/disease/V = C.virus2[ID]
							if(prob(5))
								if(prob(50))
									M.apply_effect(50,IRRADIATE,0) // curing it that way may kill you instead
									M.adjustToxLoss(100)
								C.antibodies |= V.antigen
				..()
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(!istype(T, /turf/space))
						new /obj/effect/decal/cleanable/greenglow(T)
						return

		thermite
			name = "Thermite"
			id = "thermite"
			description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
			reagent_state = SOLID
			color = "#673910" // rgb: 103, 57, 16

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 5)
					if(istype(T, /turf/simulated/wall))
						T:thermite = 1
						T.overlays.Cut()
						T.overlays = image('icons/effects/effects.dmi',icon_state = "thermite")
				return

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustFireLoss(1)
				..()
				return

		mutagen
			name = "Unstable mutagen"
			id = "mutagen"
			description = "Might cause unpredictable mutations. Keep away from children."
			reagent_state = LIQUID
			color = "#04DF27"
			metabolization_rate = 0.3

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(!..())	return
				if(!M.dna) return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
				src = null
				if((method==TOUCH && prob(33)) || method==INGEST)
					if(prob(98))
						randmutb(M)
					else
						randmutg(M)
					domutcheck(M, null)
					M.UpdateAppearance()
				return
			on_mob_life(var/mob/living/M as mob)
				if(!M.dna) return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
				if(!M) M = holder.my_atom
				M.apply_effect(2*REM,IRRADIATE,0)
				if(prob(4))
					randmutb(M)
				..()
				return

		hydrocodone
			name = "Hydrocodone"
			id = "hydrocodone"
			description = "An extremely effective painkiller; may have long term abuse consequences."
			reagent_state = LIQUID
			color = "#C805DC"
			metabolization_rate = 0.3 // Lasts 1.5 minutes for 15 units
			shock_reduction = 200

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				..()
				return

		virus_food
			name = "Virus Food"
			id = "virusfood"
			description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			color = "#899613" // rgb: 137, 150, 19

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.nutrition += nutriment_factor*REM
				..()
				return

		sterilizine
			name = "Sterilizine"
			id = "sterilizine"
			description = "Sterilizes wounds in preparation for surgery."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			//makes you squeaky clean
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if (method == TOUCH)
					M.germ_level -= min(volume*20, M.germ_level)

			reaction_obj(var/obj/O, var/volume)
				O.germ_level -= min(volume*20, O.germ_level)

			reaction_turf(var/turf/T, var/volume)
				T.germ_level -= min(volume*20, T.germ_level)

		iron
			name = "Iron"
			id = "iron"
			description = "Pure iron is a metal."
			reagent_state = SOLID
			color = "#C8A5DC" // rgb: 200, 165, 220
/*
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if((M.virus) && (prob(8) && (M.virus.name=="Magnitis")))
					if(M.virus.spread == "Airborne")
						M.virus.spread = "Remissive"
					M.virus.stage--
					if(M.virus.stage <= 0)
						M.resistances += M.virus.type
						M.virus = null
				holder.remove_reagent(src.id, 0.2)
				return
*/

		gold
			name = "Gold"
			id = "gold"
			description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
			reagent_state = SOLID
			color = "#F7C430" // rgb: 247, 196, 48

		silver
			name = "Silver"
			id = "silver"
			description = "A lustrous metallic element regarded as one of the precious metals."
			reagent_state = SOLID
			color = "#D0D0D0" // rgb: 208, 208, 208

		uranium
			name ="Uranium"
			id = "uranium"
			description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
			reagent_state = SOLID
			color = "#B8B8C0" // rgb: 184, 184, 192

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.apply_effect(2,IRRADIATE,0)
				..()
				return


			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(!istype(T, /turf/space))
						new /obj/effect/decal/cleanable/greenglow(T)

		aluminum
			name = "Aluminum"
			id = "aluminum"
			description = "A silvery white and ductile member of the boron group of chemical elements."
			reagent_state = SOLID
			color = "#A8A8A8" // rgb: 168, 168, 168

		silicon
			name = "Silicon"
			id = "silicon"
			description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
			reagent_state = SOLID
			color = "#A8A8A8" // rgb: 168, 168, 168

		fuel
			name = "Welding fuel"
			id = "fuel"
			description = "A highly flammable blend of basic hydrocarbons, mostly Acetylene. Useful for both welding and organic chemistry, and can be fortified into a heavier oil."
			reagent_state = LIQUID
			color = "#060606"

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with welding fuel to make them easy to ignite!
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					M.adjust_fire_stacks(volume / 10)
				return
			/*
			reaction_obj(var/obj/O, var/volume)
				var/turf/the_turf = get_turf(O)
				if(!the_turf)
					return //No sense trying to start a fire if you don't have a turf to set on fire. --NEO
				new /obj/effect/decal/cleanable/liquid_fuel(the_turf, volume)
			reaction_turf(var/turf/T, var/volume)
				new /obj/effect/decal/cleanable/liquid_fuel(T, volume)
				return
			*/
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1)
				..()
				return


		incendiary_fuel //copy-pasta of welding fuel; allow incendiary grenades to function better without the headache of people spraying fuel everywhere with regular welding fuel.
			name = "Incendiary fuel"
			id = "incendiaryfuel"
			description = "A highly flammable compound used in incendiary grenades."
			reagent_state = LIQUID
			color = "#660000" // rgb: 102, 0, 0

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with welding fuel to make them easy to ignite!
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					M.adjust_fire_stacks(volume / 10)
				return

			reaction_obj(var/obj/O, var/volume)
				var/turf/the_turf = get_turf(O)
				if(!the_turf)
					return //No sense trying to start a fire if you don't have a turf to set on fire. --NEO
				new /obj/effect/decal/cleanable/liquid_fuel(the_turf, volume)
			reaction_turf(var/turf/T, var/volume)
				new /obj/effect/decal/cleanable/liquid_fuel(T, volume)
				return

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1)
				..()
				return

		space_cleaner
			name = "Space cleaner"
			id = "cleaner"
			description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
			reagent_state = LIQUID
			color = "#61C2C2"

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/effect/decal/cleanable))
					del(O)
				else
					if(O)
						O.clean_blood()
			reaction_turf(var/turf/T, var/volume)
				if(volume >= 1)
					T.overlays.Cut()
					T.clean_blood()
					for(var/obj/effect/decal/cleanable/C in src)
						del(C)

					for(var/mob/living/carbon/slime/M in T)
						M.adjustToxLoss(rand(5,10))
			reaction_turf(var/turf/simulated/S, var/volume)
				if(volume >= 1)
					S.dirt = 0
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					if(istype(M,/mob/living/carbon/human))
						var/mob/living/carbon/human/H = M
						if(H.lip_style)
							H.lip_style = null
							H.update_body()
					if(C.r_hand)
						C.r_hand.clean_blood()
					if(C.l_hand)
						C.l_hand.clean_blood()
					if(C.wear_mask)
						if(C.wear_mask.clean_blood())
							C.update_inv_wear_mask(0)
					if(ishuman(M))
						var/mob/living/carbon/human/H = C
						if(H.head)
							if(H.head.clean_blood())
								H.update_inv_head(0,0)
						if(H.wear_suit)
							if(H.wear_suit.clean_blood())
								H.update_inv_wear_suit(0,0)
						else if(H.w_uniform)
							if(H.w_uniform.clean_blood())
								H.update_inv_w_uniform(0,0)
						if(H.shoes)
							if(H.shoes.clean_blood())
								H.update_inv_shoes(0,0)
					M.clean_blood()
					..()
					return

		plasma
			name = "Plasma"
			id = "plasma"
			description = "The liquid phase of an unusual extraterrestrial compound."
			reagent_state = LIQUID
			color = "#7A2B94"

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(3*REM)
				..()
				return

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with plasma is stronger than fuel!
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					M.adjust_fire_stacks(volume / 5)
					..()
					return
		lexorin
			name = "Lexorin"
			id = "lexorin"
			description = "Lexorin temporarily stops respiration. Causes tissue damage."
			reagent_state = LIQUID
			color = "#52685D"
			metabolization_rate = 0.2

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1)
				..()
				return

		adminordrazine //An OP chemical for admins
			name = "Adminordrazine"
			id = "adminordrazine"
			description = "It's magic. We don't have to explain it."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/carbon/M as mob)
				if(!M) M = holder.my_atom ///This can even heal dead people.
				for(var/datum/reagent/R in M.reagents.reagent_list)
					if(R != src)
						M.reagents.remove_reagent(R.id,5)
				M.setCloneLoss(0)
				M.setOxyLoss(0)
				M.radiation = 0
				M.heal_organ_damage(5,5)
				M.adjustToxLoss(-5)
				M.hallucination = 0
				M.setBrainLoss(0)
				M.disabilities = 0
				M.sdisabilities = 0
				M.eye_blurry = 0
				M.eye_blind = 0
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					var/obj/item/organ/eyes/E = H.internal_organs_by_name["eyes"]
					if(istype(E))
						E.damage = max(E.damage-5 , 0)
				M.SetWeakened(0)
				M.SetStunned(0)
				M.SetParalysis(0)
				M.silent = 0
				M.dizziness = 0
				M.drowsyness = 0
				M.stuttering = 0
				M.slurring = 0
				M.confused = 0
				M.sleeping = 0
				M.jitteriness = 0
				if(istype(M,/mob/living/carbon)) // make sure to only use it on carbon mobs
					var/mob/living/carbon/C = M
					if(C.virus2.len)
						for (var/ID in C.virus2)
							var/datum/disease2/disease/V = C.virus2[ID]
							C.antibodies |= V.antigen
				..()
				return

			nanites
				name = "Nanites"
				id = "nanites"
				description = "Nanomachines that aid in rapid cellular regeneration."


		synaptizine
			name = "Synaptizine"
			id = "synaptizine"
			description = "Synaptizine is used to treat neuroleptic shock. Can be used to help remove disabling symptoms such as paralysis."
			reagent_state = LIQUID
			color = "#FA46FA"

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.AdjustParalysis(-1)
				M.AdjustStunned(-1)
				M.AdjustWeakened(-1)
				..()
				return

		audioline
			name = "Audioline"
			id = "audioline"
			description = "Heals ear damage."
			reagent_state = LIQUID
			color = "#6600FF" // rgb: 100, 165, 255

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.ear_damage = 0
				M.ear_deaf = 0
				..()
				return

		mitocholide
			name = "Mitocholide"
			id = "mitocholide"
			description = "A specialized drug that stimulates the mitochondria of cells to encourage healing of internal organs."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(ishuman(M))
					var/mob/living/carbon/human/H = M

					//Mitocholide is hard enough to get, it's probably fair to make this all internal organs
					for(var/name in H.internal_organs_by_name)
						var/obj/item/organ/I = H.internal_organs_by_name[name]
						if(I.damage > 0)
							I.damage -= 0.20
				..()
				return

		cryoxadone
			name = "Cryoxadone"
			id = "cryoxadone"
			description = "A plasma mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 265K for it to metabolise correctly."
			reagent_state = LIQUID
			color = "#0000C8" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					M.adjustCloneLoss(-1)
					M.adjustOxyLoss(-10)
					M.heal_organ_damage(12,12)
					M.adjustToxLoss(-3)
				..()
				return

		clonexadone
			name = "Clonexadone"
			id = "clonexadone"
			description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' clones that get ejected early when used in conjunction with a cryo tube."
			reagent_state = LIQUID
			color = "#0000C8" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					M.adjustCloneLoss(-3)
					M.status_flags &= ~DISFIGURED
				..()
				return

		rezadone
			name = "Rezadone"
			id = "rezadone"
			description = "A powder derived from fish toxin, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
			reagent_state = SOLID
			color = "#669900" // rgb: 102, 153, 0

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				data++
				switch(data)
					if(1 to 15)
						M.adjustCloneLoss(-1)
						M.heal_organ_damage(1,1)
					if(15 to 35)
						M.adjustCloneLoss(-2)
						M.heal_organ_damage(2,1)
						M.status_flags &= ~DISFIGURED
					if(35 to INFINITY)
						M.adjustToxLoss(1)
						M.Dizzy(5)
						M.Jitter(5)

				..()
				return

		spaceacillin
			name = "Spaceacillin"
			id = "spaceacillin"
			description = "An all-purpose antibiotic agent extracted from space fungus."
			reagent_state = LIQUID
			color = "#0AB478"

			on_mob_life(var/mob/living/M as mob)
				..()
				return

		carpotoxin
			name = "Carpotoxin"
			id = "carpotoxin"
			description = "A deadly neurotoxin produced by the dreaded spess carp."
			reagent_state = LIQUID
			color = "#003333" // rgb: 0, 51, 51

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(2*REM)
				..()
				return

		staminatoxin
			name = "Tirizene"
			id = "tirizene"
			description = "A toxin that affects the stamina of a person when injected into the bloodstream."
			reagent_state = LIQUID
			color = "#6E2828"
			data = 13

			on_mob_life(var/mob/living/M)
				M.adjustStaminaLoss(REM * data)
				data = max(data - 1, 3)
				..()

		lsd
			name = "Lysergic acid diethylamide"
			id = "lsd"
			description = "A highly potent hallucinogenic substance. Far out, maaaan."
			reagent_state = LIQUID
			color = "#0000D8"

			on_mob_life(var/mob/living/M)
				if(!M) M = holder.my_atom
				M.hallucination += 10
				..()
				return


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
		nanites
			name = "Nanomachines"
			id = "nanites"
			description = "Microscopic construction robots."
			reagent_state = LIQUID
			color = "#535E66" // rgb: 83, 94, 102

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					M.contract_disease(new /datum/disease/robotic_transformation(0),1)

		xenomicrobes
			name = "Xenomicrobes"
			id = "xenomicrobes"
			description = "Microbes with an entirely alien cellular structure."
			reagent_state = LIQUID
			color = "#535E66" // rgb: 83, 94, 102

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					M.contract_disease(new /datum/disease/xeno_transformation(0),1)
*/

		spore
			name = "Blob Spores"
			id = "spore"
			description = "Spores of some blob creature thingy."
			reagent_state = LIQUID
			color = "#CE760A" // rgb: 206, 118, 10
			var/client/blob_client = null
			var/blob_point_rate = 3

			on_mob_life(var/mob/living/M)
				if(!M) M = holder.my_atom
				if (holder.has_reagent("atrazine",45))
					holder.del_reagent("spore")
				if (prob(1))
					M << "\red Your mouth tastes funny."
				if (prob(1) && prob(25))
					if(iscarbon(M))
						var/mob/living/carbon/C = M
						if(directory[ckey(C.key)])
							blob_client = directory[ckey(C.key)]
							C.gib()
							if(blob_client)
								var/obj/effect/blob/core/core = new(get_turf(C), 200, blob_client, blob_point_rate)
								if(core.overmind && core.overmind.mind)
									core.overmind.mind.name = C.name

				return

//foam

		fluorosurfactant
			name = "Fluorosurfactant"
			id = "fluorosurfactant"
			description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
			reagent_state = LIQUID
			color = "#9E6B38" // rgb: 158, 107, 56

// metal foaming agent
// this is lithium hydride. Add other recipies (e.g. LiH + H2O -> LiOH + H2) eventually

		ammonia
			name = "Ammonia"
			id = "ammonia"
			description = "A caustic substance commonly used in fertilizer or household cleaners."
			reagent_state = GAS
			color = "#404030" // rgb: 64, 64, 48


		diethylamine
			name = "Diethylamine"
			id = "diethylamine"
			description = "A secondary amine, useful as a plant nutrient and as building block for other compounds."
			reagent_state = LIQUID
			color = "#322D00"

		beer2	//disguised as normal beer for use by emagged brobots
			name = "Beer"
			id = "beer2"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
			color = "#664300" // rgb: 102, 67, 0

			on_mob_life(var/mob/living/M as mob)
				if(!data)
					data = 1
				switch(data)
					if(1 to 50)
						M.sleeping += 1
					if(51 to INFINITY)
						M.sleeping += 1
						M.adjustToxLoss((data - 50)*REM)
				data++
				holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
				..()
				return

/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.
		nutriment
			name = "Nutriment"
			id = "nutriment"
			description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
			reagent_state = SOLID
			nutriment_factor = 15 * REAGENTS_METABOLISM
			color = "#664330" // rgb: 102, 67, 48

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!(M.mind in ticker.mode.vampires))
					M.nutrition += nutriment_factor	// For hunger and fatness
					if(prob(50)) M.heal_organ_damage(1,0)
				..()
				return

		soysauce
			name = "Soysauce"
			id = "soysauce"
			description = "A salty sauce made from the soy plant."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			color = "#792300" // rgb: 121, 35, 0

		ketchup
			name = "Ketchup"
			id = "ketchup"
			description = "Ketchup, catsup, whatever. It's tomato paste."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#731008" // rgb: 115, 16, 8


		capsaicin
			name = "Capsaicin Oil"
			id = "capsaicin"
			description = "This is what makes chilis hot."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 179, 16, 8

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1 to 15)
						M.bodytemperature += 5 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(holder.has_reagent("frostoil"))
							holder.remove_reagent("frostoil", 5)
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature += rand(5,20)
					if(15 to 25)
						M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature += rand(10,20)
					if(25 to INFINITY)
						M.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature += rand(15,20)
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				data++
				..()
				return

		condensedcapsaicin
			name = "Condensed Capsaicin"
			id = "condensedcapsaicin"
			description = "This shit goes in pepperspray."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 179, 16, 8

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					if(istype(M, /mob/living/carbon/human))
						var/mob/living/carbon/human/victim = M
						var/mouth_covered = 0
						var/eyes_covered = 0
						var/obj/item/safe_thing = null
						if( victim.wear_mask )
							if ( victim.wear_mask.flags & MASKCOVERSEYES )
								eyes_covered = 1
								safe_thing = victim.wear_mask
							if ( victim.wear_mask.flags & MASKCOVERSMOUTH )
								mouth_covered = 1
								safe_thing = victim.wear_mask
						if( victim.head )
							if ( victim.head.flags & MASKCOVERSEYES )
								eyes_covered = 1
								safe_thing = victim.head
							if ( victim.head.flags & MASKCOVERSMOUTH )
								mouth_covered = 1
								safe_thing = victim.head
						if(victim.glasses)
							eyes_covered = 1
							if ( !safe_thing )
								safe_thing = victim.glasses
						if ( eyes_covered && mouth_covered )
							victim << "\red Your [safe_thing] protects you from the pepperspray!"
							return
						else if ( mouth_covered )	// Reduced effects if partially protected
							victim << "\red Your [safe_thing] protect you from most of the pepperspray!"
							if(prob(5))
								victim.emote("scream")
							victim.eye_blurry = max(M.eye_blurry, 3)
							victim.eye_blind = max(M.eye_blind, 1)
							victim.confused = max(M.confused, 3)
							victim.damageoverlaytemp = 60
							victim.Weaken(3)
							victim.drop_item()
							return
						else if ( eyes_covered ) // Eye cover is better than mouth cover
							victim << "\red Your [safe_thing] protects your eyes from the pepperspray!"
							victim.eye_blurry = max(M.eye_blurry, 3)
							victim.damageoverlaytemp = 30
							return
						else // Oh dear :D
							if(prob(5))
								victim.emote("scream")
							victim << "\red You're sprayed directly in the eyes with pepperspray!"
							victim.eye_blurry = max(M.eye_blurry, 5)
							victim.eye_blind = max(M.eye_blind, 2)
							victim.confused = max(M.confused, 6)
							victim.damageoverlaytemp = 75
							victim.Weaken(5)
							victim.drop_item()

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(prob(5))
					M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
				..()
				return

		frostoil
			name = "Frost Oil"
			id = "frostoil"
			description = "A special oil that noticably chills the body. Extraced from Icepeppers."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 139, 166, 233

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1 to 15)
						M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(holder.has_reagent("capsaicin"))
							holder.remove_reagent("capsaicin", 5)
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature -= rand(5,20)
					if(15 to 25)
						M.bodytemperature -= 15 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature -= rand(10,20)
					if(25 to INFINITY)
						M.bodytemperature -= 20 * TEMPERATURE_DAMAGE_COEFFICIENT
						if(prob(1))
							M.emote("shiver")
						if(istype(M, /mob/living/carbon/slime))
							M.bodytemperature -= rand(15,20)
				data++
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				..()
				return

			reaction_turf(var/turf/simulated/T, var/volume)
				for(var/mob/living/carbon/slime/M in T)
					M.adjustToxLoss(rand(15,30))

		sodiumchloride
			name = "Salt"
			id = "sodiumchloride"
			description = "Sodium chloride, common table salt."
			reagent_state = SOLID
			color = "#B1B0B0"

		blackpepper
			name = "Black Pepper"
			id = "blackpepper"
			description = "A powder ground from peppercorns. *AAAACHOOO*"
			reagent_state = SOLID
			// no color (ie, black)

		coco
			name = "Coco Powder"
			id = "coco"
			description = "A fatty, bitter paste made from coco beans."
			reagent_state = SOLID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

		hot_coco
			name = "Hot Chocolate"
			id = "hot_coco"
			description = "Made with love! And coco beans."
			reagent_state = LIQUID
			nutriment_factor = 2 * REAGENTS_METABOLISM
			color = "#403010" // rgb: 64, 48, 16

			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
				M.nutrition += nutriment_factor
				..()
				return

		psilocybin
			name = "Psilocybin"
			id = "psilocybin"
			description = "A strong psycotropic derived from certain species of mushroom."
			color = "#E700E7" // rgb: 231, 0, 231

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 30)
				if(!data) data = 1
				switch(data)
					if(1 to 5)
						if (!M.stuttering) M.stuttering = 1
						M.Dizzy(5)
						if(prob(10)) M.emote(pick("twitch","giggle"))
					if(5 to 10)
						if (!M.stuttering) M.stuttering = 1
						M.Jitter(10)
						M.Dizzy(10)
						M.druggy = max(M.druggy, 35)
						if(prob(20)) M.emote(pick("twitch","giggle"))
					if (10 to INFINITY)
						if (!M.stuttering) M.stuttering = 1
						M.Jitter(20)
						M.Dizzy(20)
						M.druggy = max(M.druggy, 40)
						if(prob(30)) M.emote(pick("twitch","giggle"))
				data++
				..()
				return

		sprinkles
			name = "Sprinkles"
			id = "sprinkles"
			description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FF00FF" // rgb: 255, 0, 255

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
					if(!M) M = holder.my_atom
					M.heal_organ_damage(1,1)
					M.nutrition += nutriment_factor
					..()
					return
				..()

		cornoil
			name = "Corn Oil"
			id = "cornoil"
			description = "An oil derived from various types of corn."
			reagent_state = LIQUID
			nutriment_factor = 20 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return
			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 3)
					if(T.wet >= 1) return
					T.wet = 1
					if(T.wet_overlay)
						T.overlays -= T.wet_overlay
						T.wet_overlay = null
					T.wet_overlay = image('icons/effects/water.dmi',T,"wet_floor")
					T.overlays += T.wet_overlay

					spawn(800)
						if (!istype(T)) return
						if(T.wet >= 2) return
						T.wet = 0
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null
				var/hotspot = (locate(/obj/effect/hotspot) in T)
				if(hotspot)
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					qdel(hotspot)

		enzyme
			name = "Denatured Enzyme"
			id = "enzyme"
			description = "Heated beyond usefulness, this enzyme is now worthless."
			reagent_state = LIQUID
			color = "#282314" // rgb: 54, 94, 48

		dry_ramen
			name = "Dry Ramen"
			id = "dry_ramen"
			description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

		hot_ramen
			name = "Hot Ramen"
			id = "hot_ramen"
			description = "The noodles are boiled, the flavors are artificial, just like being back in school."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))
				..()
				return

		hell_ramen
			name = "Hell Ramen"
			id = "hell_ramen"
			description = "The noodles are boiled, the flavors are artificial, just like being back in school."
			reagent_state = LIQUID
			nutriment_factor = 5 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
				..()
				return


		flour
			name = "flour"
			id = "flour"
			description = "This is what you rub all over yourself to pretend to be a ghost."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FFFFFF" // rgb: 0, 0, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					new /obj/effect/decal/cleanable/flour(T)

		rice
			name = "Rice"
			id = "rice"
			description = "Enjoy the great taste of nothing."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FFFFFF" // rgb: 0, 0, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

		cherryjelly
			name = "Cherry Jelly"
			id = "cherryjelly"
			description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#801E28" // rgb: 128, 30, 40

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

		toxin/coffeepowder
			name = "Coffee Grounds"
			id = "coffeepowder"
			description = "Finely ground Coffee beans, used to make coffee."
			reagent_state = SOLID
			color = "#5B2E0D" // rgb: 91, 46, 13

		toxin/teapowder
			name = "Ground Tea Leaves"
			id = "teapowder"
			description = "Finely shredded Tea leaves, used for making tea."
			reagent_state = SOLID
			color = "#7F8400" // rgb: 127, 132, 0

		//Reagents used for plant fertilizers.
		toxin/fertilizer
			name = "fertilizer"
			id = "fertilizer"
			description = "A chemical mix good for growing plants with."
			reagent_state = LIQUID
//			toxpwr = 0.2 //It's not THAT poisonous.
			color = "#664330" // rgb: 102, 67, 48


		toxin/fertilizer/eznutrient
			name = "EZ Nutrient"
			id = "eznutrient"

		toxin/fertilizer/left4zed
			name = "Left-4-Zed"
			id = "left4zed"

		toxin/fertilizer/robustharvest
			name = "Robust Harvest"
			id = "robustharvest"


/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

		drink
			name = "Drink"
			id = "drink"
			description = "Uh, some kind of drink."
			reagent_state = LIQUID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#E78108" // rgb: 231, 129, 8
			var/adj_dizzy = 0
			var/adj_drowsy = 0
			var/adj_sleepy = 0
			var/adj_temp = 0

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.nutrition += nutriment_factor
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				if (adj_dizzy) M.dizziness = max(0,M.dizziness + adj_dizzy)
				if (adj_drowsy)	M.drowsyness = max(0,M.drowsyness + adj_drowsy)
				if (adj_sleepy) M.sleeping = max(0,M.sleeping + adj_sleepy)
				if (adj_temp)
					if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
						M.bodytemperature = min(310, M.bodytemperature + (25 * TEMPERATURE_DAMAGE_COEFFICIENT))
				// Drinks should be used up faster than other reagents.
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				..()
				return

			orangejuice
				name = "Orange juice"
				id = "orangejuice"
				description = "Both delicious AND rich in Vitamin C, what more do you need?"
				color = "#E78108" // rgb: 231, 129, 8

				on_mob_life(var/mob/living/M as mob)
					..()
					if(M.getOxyLoss() && prob(30)) M.adjustOxyLoss(-1*REM)
					return

			tomatojuice
				name = "Tomato Juice"
				id = "tomatojuice"
				description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
				color = "#731008" // rgb: 115, 16, 8

				on_mob_life(var/mob/living/M as mob)
					..()
					if(M.getFireLoss() && prob(20)) M.heal_organ_damage(0,1)
					return

			limejuice
				name = "Lime Juice"
				id = "limejuice"
				description = "The sweet-sour juice of limes."
				color = "#365E30" // rgb: 54, 94, 48
				on_mob_life(var/mob/living/M as mob)
					..()
					if(M.getToxLoss() && prob(20)) M.adjustToxLoss(-1)
					return


			carrotjuice
				name = "Carrot juice"
				id = "carrotjuice"
				description = "It is just like a carrot but without crunching."
				color = "#973800" // rgb: 151, 56, 0

				on_mob_life(var/mob/living/M as mob)
					..()
					M.eye_blurry = max(M.eye_blurry-1 , 0)
					M.eye_blind = max(M.eye_blind-1 , 0)
					if(!data) data = 1
					switch(data)
						if(1 to 20)
							//nothing
						if(21 to INFINITY)
							if (prob(data-10))
								M.disabilities &= ~NEARSIGHTED
					data++
					return

			doctor_delight
				name = "The Doctor's Delight"
				id = "doctorsdelight"
				description = "A gulp a day keeps the MediBot away. That's probably for the best."
				reagent_state = LIQUID
				color = "#FF8CFF" // rgb: 255, 140, 255

				on_mob_life(var/mob/living/M as mob)
					if(!M) M = holder.my_atom
					if(M.getToxLoss() && prob(20)) M.adjustToxLoss(-1)
					..()
					return

			berryjuice
				name = "Berry Juice"
				id = "berryjuice"
				description = "A delicious blend of several different kinds of berries."
				color = "#863333" // rgb: 134, 51, 51

			poisonberryjuice
				name = "Poison Berry Juice"
				id = "poisonberryjuice"
				description = "A tasty juice blended from various kinds of very deadly and toxic berries."
				color = "#863353" // rgb: 134, 51, 83

				on_mob_life(var/mob/living/M as mob)
					..()
					M.adjustToxLoss(1)
					return

			watermelonjuice
				name = "Watermelon Juice"
				id = "watermelonjuice"
				description = "Delicious juice made from watermelon."
				color = "#863333" // rgb: 134, 51, 51

			lemonjuice
				name = "Lemon Juice"
				id = "lemonjuice"
				description = "This juice is VERY sour."
				color = "#863333" // rgb: 175, 175, 0

			grapejuice
				name = "Grape Juice"
				id = "grapejuice"
				description = "This juice is known to stain shirts."
				color = "#993399" // rgb: 153, 51, 153

			banana
				name = "Banana Juice"
				id = "banana"
				description = "The raw essence of a banana."
				color = "#863333" // rgb: 175, 175, 0

				on_mob_life(var/mob/living/M as mob)
					M.nutrition += nutriment_factor
					if(istype(M, /mob/living/carbon/human) && M.job in list("Clown"))
						if(!M) M = holder.my_atom
						M.heal_organ_damage(1,1)
						M.nutrition += nutriment_factor
						..()
						return
					..()

			nothing
				name = "Nothing"
				id = "nothing"
				description = "Absolutely nothing."

				on_mob_life(var/mob/living/M as mob)
					M.nutrition += nutriment_factor
					if(istype(M, /mob/living/carbon/human) && M.job in list("Mime"))
						if(!M) M = holder.my_atom
						M.heal_organ_damage(1,1)
						M.nutrition += nutriment_factor
						..()
						return
					..()

			potato_juice
				name = "Potato Juice"
				id = "potato"
				description = "Juice of the potato. Bleh."
				nutriment_factor = 2 * FOOD_METABOLISM
				color = "#302000" // rgb: 48, 32, 0

			milk
				name = "Milk"
				id = "milk"
				description = "An opaque white liquid produced by the mammary glands of mammals."
				color = "#DFDFDF" // rgb: 223, 223, 223

				on_mob_life(var/mob/living/M as mob)
					if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
					if(holder.has_reagent("capsaicin"))
						holder.remove_reagent("capsaicin", 10*REAGENTS_METABOLISM)
					..()
					return

				soymilk
					name = "Soy Milk"
					id = "soymilk"
					description = "An opaque white liquid made from soybeans."
					color = "#DFDFC7" // rgb: 223, 223, 199

				cream
					name = "Cream"
					id = "cream"
					description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
					color = "#DFD7AF" // rgb: 223, 215, 175

				chocolate_milk
					name = "Chocolate milk"
					id ="chocolate_milk"
					description = "Chocolate-flavored milk, tastes like being a kid again."
					color = "#85432C"

			hot_coco
				name = "Hot Chocolate"
				id = "hot_coco"
				description = "Made with love! And coco beans."
				nutriment_factor = 2 * FOOD_METABOLISM
				color = "#403010" // rgb: 64, 48, 16
				adj_temp = 5

			coffee
				name = "Coffee"
				id = "coffee"
				description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
				color = "#482000" // rgb: 72, 32, 0
				adj_dizzy = -5
				adj_drowsy = -3
				adj_sleepy = -2
				adj_temp = 25

				on_mob_life(var/mob/living/M as mob)
					M.Jitter(5)
					if(adj_temp > 0 && holder.has_reagent("frostoil"))
						holder.remove_reagent("frostoil", 10*REAGENTS_METABOLISM)
					if(prob(50))
						M.AdjustParalysis(-1)
						M.AdjustStunned(-1)
						M.AdjustWeakened(-1)
					..()
					return

				icecoffee
					name = "Iced Coffee"
					id = "icecoffee"
					description = "Coffee and ice, refreshing and cool."
					color = "#102838" // rgb: 16, 40, 56
					adj_temp = -5

				soy_latte
					name = "Soy Latte"
					id = "soy_latte"
					description = "A nice and tasty beverage while you are reading your hippie books."
					color = "#664300" // rgb: 102, 67, 0
					adj_sleepy = 0
					adj_temp = 5

					on_mob_life(var/mob/living/M as mob)
						..()
						M.sleeping = 0
						if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
						return

				cafe_latte
					name = "Cafe Latte"
					id = "cafe_latte"
					description = "A nice, strong and tasty beverage while you are reading."
					color = "#664300" // rgb: 102, 67, 0
					adj_sleepy = 0
					adj_temp = 5

					on_mob_life(var/mob/living/M as mob)
						..()
						M.sleeping = 0
						if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
						return

			tea
				name = "Tea"
				id = "tea"
				description = "Tasty black tea: It has antioxidants. It's good for you!"
				color = "#101000" // rgb: 16, 16, 0
				adj_dizzy = -2
				adj_drowsy = -1
				adj_sleepy = -3
				adj_temp = 20

				on_mob_life(var/mob/living/M as mob)
					..()
					if(M.getToxLoss() && prob(20))
						M.adjustToxLoss(-1)
					return

				icetea
					name = "Iced Tea"
					id = "icetea"
					description = "No relation to a certain rap artist/ actor."
					color = "#104038" // rgb: 16, 64, 56
					adj_temp = -5

			kahlua
				name = "Kahlua"
				id = "kahlua"
				description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
				color = "#664300" // rgb: 102, 67, 0
				adj_dizzy = -5
				adj_drowsy = -3
				adj_sleepy = -2

				on_mob_life(var/mob/living/M as mob)
					..()
					M.Jitter(5)
					return

			cold
				name = "Cold drink"
				adj_temp = -5

				tonic
					name = "Tonic Water"
					id = "tonic"
					description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
					color = "#664300" // rgb: 102, 67, 0
					adj_dizzy = -5
					adj_drowsy = -3
					adj_sleepy = -2

				sodawater
					name = "Soda Water"
					id = "sodawater"
					description = "A can of club soda. Why not make a scotch and soda?"
					color = "#619494" // rgb: 97, 148, 148
					adj_dizzy = -5
					adj_drowsy = -3

				ice
					name = "Ice"
					id = "ice"
					description = "Frozen water, your dentist wouldn't like you chewing this."
					reagent_state = SOLID
					color = "#619494" // rgb: 97, 148, 148

				space_cola
					name = "Cola"
					id = "cola"
					description = "A refreshing beverage."
					reagent_state = LIQUID
					color = "#100800" // rgb: 16, 8, 0
					adj_drowsy 	= 	-3

				nuka_cola
					name = "Nuka Cola"
					id = "nuka_cola"
					description = "Cola, cola never changes."
					color = "#100800" // rgb: 16, 8, 0
					adj_sleepy = -2

					on_mob_life(var/mob/living/M as mob)
						M.Jitter(20)
						M.druggy = max(M.druggy, 30)
						M.dizziness +=5
						M.drowsyness = 0
						M.status_flags |= GOTTAGOFAST
						..()
						return

				spacemountainwind
					name = "Space Mountain Wind"
					id = "spacemountainwind"
					description = "Blows right through you like a space wind."
					color = "#102000" // rgb: 16, 32, 0
					adj_drowsy = -7
					adj_sleepy = -1

				dr_gibb
					name = "Dr. Gibb"
					id = "dr_gibb"
					description = "A delicious blend of 42 different flavours"
					color = "#102000" // rgb: 16, 32, 0
					adj_drowsy = -6

				space_up
					name = "Space-Up"
					id = "space_up"
					description = "Tastes like a hull breach in your mouth."
					color = "#202800" // rgb: 32, 40, 0
					adj_temp = -8

				lemon_lime
					name = "Lemon Lime"
					description = "A tangy substance made of 0.5% natural citrus!"
					id = "lemon_lime"
					color = "#878F00" // rgb: 135, 40, 0
					adj_temp = -8

				lemonade
					name = "Lemonade"
					description = "Oh the nostalgia..."
					id = "lemonade"
					color = "#FFFF00" // rgb: 255, 255, 0

				kiraspecial
					name = "Kira Special"
					description = "Long live the guy who everyone had mistaken for a girl. Baka!"
					id = "kiraspecial"
					color = "#CCCC99" // rgb: 204, 204, 153

				brownstar
					name = "Brown Star"
					description = "Its not what it sounds like..."
					id = "brownstar"
					color = "#9F3400" // rgb: 159, 052, 000
					adj_temp = - 2

				milkshake
					name = "Milkshake"
					description = "Glorious brainfreezing mixture."
					id = "milkshake"
					color = "#AEE5E4" // rgb" 174, 229, 228
					adj_temp = -9

					on_mob_life(var/mob/living/M as mob)
						if(!M) M = holder.my_atom
						if(!data) data = 1
						switch(data)
							if(1 to 15)
								M.bodytemperature -= 5 * TEMPERATURE_DAMAGE_COEFFICIENT
								if(holder.has_reagent("capsaicin"))
									holder.remove_reagent("capsaicin", 5)
								if(istype(M, /mob/living/carbon/slime))
									M.bodytemperature -= rand(5,20)
							if(15 to 25)
								M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
								if(istype(M, /mob/living/carbon/slime))
									M.bodytemperature -= rand(10,20)
							if(25 to INFINITY)
								M.bodytemperature -= 15 * TEMPERATURE_DAMAGE_COEFFICIENT
								if(prob(1)) M.emote("shiver")
								if(istype(M, /mob/living/carbon/slime))
									M.bodytemperature -= rand(15,20)
						data++
						holder.remove_reagent(src.id, FOOD_METABOLISM)
						..()
						return

				rewriter
					name = "Rewriter"
					description = "The secert of the sanctuary of the Libarian..."
					id = "rewriter"
					color = "#485000" // rgb:72, 080, 0

					on_mob_life(var/mob/living/M as mob)
						..()
						M.Jitter(5)
						return

		hippies_delight
			name = "Hippie's Delight"
			id = "hippiesdelight"
			description = "You just don't get it maaaan."
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 50)
				if(!data) data = 1
				switch(data)
					if(1 to 5)
						if (!M.stuttering) M.stuttering = 1
						M.Dizzy(10)
						if(prob(10)) M.emote(pick("twitch","giggle"))
					if(5 to 10)
						if (!M.stuttering) M.stuttering = 1
						M.Jitter(20)
						M.Dizzy(20)
						M.druggy = max(M.druggy, 45)
						if(prob(20)) M.emote(pick("twitch","giggle"))
					if (10 to INFINITY)
						if (!M.stuttering) M.stuttering = 1
						M.Jitter(40)
						M.Dizzy(40)
						M.druggy = max(M.druggy, 60)
						if(prob(30)) M.emote(pick("twitch","giggle"))
				holder.remove_reagent(src.id, 0.2)
				data++
				..()
				return

//ALCOHOL WOO
		ethanol
			name = "Ethanol" //Parent class for all alcoholic reagents.
			id = "ethanol"
			description = "A well-known alcohol with a variety of applications."
			reagent_state = LIQUID
			nutriment_factor = 0 //So alcohol can fill you up! If they want to.
			color = "#404030" // rgb: 64, 64, 48
			var/datum/martial_art/drunk_brawling/F = new
			var/dizzy_adj = 3
			var/slurr_adj = 3
			var/confused_adj = 2
			var/slur_start = 65			//amount absorbed after which mob starts slurring
			var/brawl_start = 75		//amount absorbed after which mob switches to drunken brawling as a fighting style
			var/confused_start = 130	//amount absorbed after which mob starts confusing directions
			var/vomit_start = 180	//amount absorbed after which mob starts vomitting
			var/blur_start = 260	//amount absorbed after which mob starts getting blurred vision
			var/pass_out = 325	//amount absorbed after which mob starts passing out

			on_mob_life(var/mob/living/M as mob, var/alien)
				// Sobering multiplier.
				// Sober block makes it more difficult to get drunk
				var/sober_str=!(SOBER in M.mutations)?1:2
				M:nutrition += nutriment_factor
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				if(!src.data) data = 1
				src.data++

				var/d = data

				// make all the beverages work together
				for(var/datum/reagent/ethanol/A in holder.reagent_list)
					if(isnum(A.data)) d += A.data

				d/=sober_str

				if(alien && alien == IS_SKRELL) //Skrell get very drunk very quickly.
					d*=5

				M.dizziness += dizzy_adj.
				if(d >= slur_start && d < pass_out)
					if (!M:slurring) M:slurring = 1
					M:slurring += slurr_adj/sober_str
				if(d >= brawl_start && ishuman(M))
					var/mob/living/carbon/human/H = M
					F.teach(H,1)
					if(src.volume < 3)
						if(H.martial_art == F)
							F.remove(H)
				if(d >= confused_start && prob(33))
					if (!M:confused) M:confused = 1
					M.confused = max(M:confused+(confused_adj/sober_str),0)
				if(d >= blur_start)
					M.eye_blurry = max(M.eye_blurry, 10/sober_str)
					M:drowsyness  = max(M:drowsyness, 0)
				if(d >= vomit_start)
					if(prob(8))
						M.fakevomit()
				if(d >= pass_out)
					M:paralysis = max(M:paralysis, 20/sober_str)
					M:drowsyness  = max(M:drowsyness, 30/sober_str)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						var/obj/item/organ/liver/L = H.internal_organs_by_name["liver"]
						if (istype(L))
							L.take_damage(0.1, 1)
						H.adjustToxLoss(0.1)
				holder.remove_reagent(src.id, 0.4)
				..()
				return

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item/weapon/paper))
					var/obj/item/weapon/paper/paperaffected = O
					paperaffected.clearpaper()
					usr << "The solution melts away the ink on the paper."
				if(istype(O,/obj/item/weapon/book))
					if(volume >= 5)
						var/obj/item/weapon/book/affectedbook = O
						affectedbook.dat = null
						usr << "The solution melts away the ink on the book."
					else
						usr << "It wasn't enough..."
				return

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with ethanol isn't quite as good as fuel.
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					M.adjust_fire_stacks(volume / 15)
					return

			beer	//It's really much more stronger than other drinks.
				name = "Beer"
				id = "beer"
				description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
				nutriment_factor = 2 * FOOD_METABOLISM
				color = "#664300" // rgb: 102, 67, 0
				on_mob_life(var/mob/living/M as mob)
					..()
					M:jitteriness = max(M:jitteriness-3,0)
					return

			cider
				name = "Cider"
				id = "cider"
				description = "An alcoholic beverage derived from apples."
				color = "#174116"

			whiskey
				name = "Whiskey"
				id = "whiskey"
				description = "A superb and well-aged single-malt whiskey. Damn."
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 4

			specialwhiskey
				name = "Special Blend Whiskey"
				id = "specialwhiskey"
				description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
				color = "#664300" // rgb: 102, 67, 0
				slur_start = 30		//amount absorbed after which mob starts slurring
				brawl_start = 40

			gin
				name = "Gin"
				id = "gin"
				description = "It's gin. In space. I say, good sir."
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 3

			absinthe
				name = "Absinthe"
				id = "absinthe"
				description = "Watch out that the Green Fairy doesn't come for you!"
				color = "#33EE00" // rgb: lots, ??, ??
				overdose_threshold = 30
				dizzy_adj = 5
				slur_start = 25
				brawl_start = 40
				confused_start = 100

				//copy paste from LSD... shoot me
				on_mob_life(var/mob/M)
					if(!M) M = holder.my_atom
					if(!data) data = 1
					data++
					M:hallucination += 5
					if(volume > overdose_threshold)
						M:adjustToxLoss(1)
					..()
					return

			rum
				name = "Rum"
				id = "rum"
				description = "Popular with the sailors. Not very popular with everyone else."
				color = "#664300" // rgb: 102, 67, 0
				overdose_threshold = 30

				on_mob_life(var/mob/living/M as mob)
					..()
					M.dizziness +=5
					if(volume > overdose_threshold)
						M:adjustToxLoss(1)
					return

			vodka
				name = "Vodka"
				id = "vodka"
				description = "Number one drink AND fueling choice for Russians worldwide."
				color = "#664300" // rgb: 102, 67, 0

			sake
				name = "Sake"
				id = "sake"
				description = "Anime's favorite drink."
				color = "#664300" // rgb: 102, 67, 0

			tequilla
				name = "Tequila"
				id = "tequilla"
				description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
				color = "#A8B0B7" // rgb: 168, 176, 183

			vermouth
				name = "Vermouth"
				id = "vermouth"
				description = "You suddenly feel a craving for a martini..."
				color = "#664300" // rgb: 102, 67, 0

			wine
				name = "Wine"
				id = "wine"
				description = "An premium alchoholic beverage made from distilled grape juice."
				color = "#7E4043" // rgb: 126, 64, 67
				dizzy_adj = 2
				slur_start = 65			//amount absorbed after which mob starts slurring
				confused_start = 145	//amount absorbed after which mob starts confusing directions

			cognac
				name = "Cognac"
				id = "cognac"
				description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 4
				confused_start = 115	//amount absorbed after which mob starts confusing directions

			suicider //otherwise known as "I want to get so smashed my liver gives out and I die from alcohol poisoning".
				name = "Suicider"
				id = "suicider"
				description = "An unbelievably strong and potent variety of Cider."
				color = "#CF3811"
				dizzy_adj = 20
				slurr_adj = 20
				confused_adj = 3
				slur_start = 15
				brawl_start = 25
				confused_start = 40
				blur_start = 60
				pass_out = 80

			ale
				name = "Ale"
				id = "ale"
				description = "A dark alchoholic beverage made by malted barley and yeast."
				color = "#664300" // rgb: 102, 67, 0

			thirteenloko
				name = "Thirteen Loko"
				id = "thirteenloko"
				description = "A potent mixture of caffeine and alcohol."
				reagent_state = LIQUID
				color = "#102000" // rgb: 16, 32, 0

				on_mob_life(var/mob/living/M as mob)
					..()
					M:nutrition += nutriment_factor
					holder.remove_reagent(src.id, FOOD_METABOLISM)
					M:drowsyness = max(0,M:drowsyness-7)
					//if(!M:sleeping_willingly)
					//	M:sleeping = max(0,M.sleeping-2)
					if (M.bodytemperature > 310)
						M.bodytemperature = max(310, M.bodytemperature-5)
					M.Jitter(1)
					return


/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////

			bilk
				name = "Bilk"
				id = "bilk"
				description = "This appears to be beer mixed with milk. Disgusting."
				reagent_state = LIQUID
				color = "#895C4C" // rgb: 137, 92, 76

			atomicbomb
				name = "Atomic Bomb"
				id = "atomicbomb"
				description = "Nuclear proliferation never tasted so good."
				reagent_state = LIQUID
				color = "#666300" // rgb: 102, 99, 0

			threemileisland
				name = "THree Mile Island Iced Tea"
				id = "threemileisland"
				description = "Made for a woman, strong enough for a man."
				reagent_state = LIQUID
				color = "#666340" // rgb: 102, 99, 64

			goldschlager
				name = "Goldschlager"
				id = "goldschlager"
				description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			patron
				name = "Patron"
				id = "patron"
				description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
				reagent_state = LIQUID
				color = "#585840" // rgb: 88, 88, 64

			gintonic
				name = "Gin and Tonic"
				id = "gintonic"
				description = "An all time classic, mild cocktail."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			cuba_libre
				name = "Cuba Libre"
				id = "cubalibre"
				description = "Rum, mixed with cola. Viva la revolution."
				reagent_state = LIQUID
				color = "#3E1B00" // rgb: 62, 27, 0

			whiskey_cola
				name = "Whiskey Cola"
				id = "whiskeycola"
				description = "Whiskey, mixed with cola. Surprisingly refreshing."
				reagent_state = LIQUID
				color = "#3E1B00" // rgb: 62, 27, 0

			martini
				name = "Classic Martini"
				id = "martini"
				description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			vodkamartini
				name = "Vodka Martini"
				id = "vodkamartini"
				description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			white_russian
				name = "White Russian"
				id = "whiterussian"
				description = "That's just, like, your opinion, man..."
				reagent_state = LIQUID
				color = "#A68340" // rgb: 166, 131, 64

			screwdrivercocktail
				name = "Screwdriver"
				id = "screwdrivercocktail"
				description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
				reagent_state = LIQUID
				color = "#A68310" // rgb: 166, 131, 16

			booger
				name = "Booger"
				id = "booger"
				description = "Ewww..."
				reagent_state = LIQUID
				color = "#A68310" // rgb: 166, 131, 16

			bloody_mary
				name = "Bloody Mary"
				id = "bloodymary"
				description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			gargle_blaster
				name = "Pan-Galactic Gargle Blaster"
				id = "gargleblaster"
				description = "Whoah, this stuff looks volatile!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			brave_bull
				name = "Brave Bull"
				id = "bravebull"
				description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			tequilla_sunrise
				name = "Tequila Sunrise"
				id = "tequillasunrise"
				description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			toxins_special
				name = "Toxins Special"
				id = "toxinsspecial"
				description = "This thing is FLAMING!. CALL THE DAMN SHUTTLE!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			beepsky_smash
				name = "Beepsky Smash"
				id = "beepskysmash"
				description = "Deny drinking this and prepare for THE LAW."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			changelingsting
				name = "Changeling Sting"
				id = "changelingsting"
				description = "You take a tiny sip and feel a burning sensation..."
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

			irish_cream
				name = "Irish Cream"
				id = "irishcream"
				description = "Whiskey-imbued cream, what else would you expect from the Irish."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			manly_dorf
				name = "The Manly Dorf"
				id = "manlydorf"
				description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			longislandicedtea
				name = "Long Island Iced Tea"
				id = "longislandicedtea"
				description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			moonshine
				name = "Moonshine"
				id = "moonshine"
				description = "You've really hit rock bottom now... your liver packed its bags and left last night."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			b52
				name = "B-52"
				id = "b52"
				description = "Coffee, Irish Cream, and congac. You will get bombed."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			irishcoffee
				name = "Irish Coffee"
				id = "irishcoffee"
				description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			margarita
				name = "Margarita"
				id = "margarita"
				description = "On the rocks with salt on the rim. Arriba~!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			black_russian
				name = "Black Russian"
				id = "blackrussian"
				description = "For the lactose-intolerant. Still as classy as a White Russian."
				reagent_state = LIQUID
				color = "#360000" // rgb: 54, 0, 0

			manhattan
				name = "Manhattan"
				id = "manhattan"
				description = "The Detective's undercover drink of choice. He never could stomach gin..."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			manhattan_proj
				name = "Manhattan Project"
				id = "manhattan_proj"
				description = "A scienitst's drink of choice, for pondering ways to blow up the station."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			whiskeysoda
				name = "Whiskey Soda"
				id = "whiskeysoda"
				description = "Ultimate refreshment."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			antifreeze
				name = "Anti-freeze"
				id = "antifreeze"
				description = "Ultimate refreshment."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			barefoot
				name = "Barefoot"
				id = "barefoot"
				description = "Barefoot and pregnant"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			snowwhite
				name = "Snow White"
				id = "snowwhite"
				description = "A cold refreshment"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			demonsblood
				name = "Demons Blood"
				id = "demonsblood"
				description = "AHHHH!!!!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 10
				slurr_adj = 10

			vodkatonic
				name = "Vodka and Tonic"
				id = "vodkatonic"
				description = "For when a gin and tonic isn't russian enough."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 4
				slurr_adj = 3

			ginfizz
				name = "Gin Fizz"
				id = "ginfizz"
				description = "Refreshingly lemony, deliciously dry."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0
				dizzy_adj = 4
				slurr_adj = 3

			bahama_mama
				name = "Bahama mama"
				id = "bahama_mama"
				description = "Tropic cocktail."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			singulo
				name = "Singulo"
				id = "singulo"
				description = "A blue-space beverage!"
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113
				dizzy_adj = 15
				slurr_adj = 15

			sbiten
				name = "Sbiten"
				id = "sbiten"
				description = "A spicy Vodka! Might be a little hot for the little guys!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

				on_mob_life(var/mob/living/M as mob)
					..()
					if (M.bodytemperature < 360)
						M.bodytemperature = min(360, M.bodytemperature+50) //310 is the normal bodytemp. 310.055
					return

			devilskiss
				name = "Devils Kiss"
				id = "devilskiss"
				description = "Creepy time!"
				reagent_state = LIQUID
				color = "#A68310" // rgb: 166, 131, 16

			red_mead
				name = "Red Mead"
				id = "red_mead"
				description = "The true Viking drink! Even though it has a strange red color."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			mead
				name = "Mead"
				id = "mead"
				description = "A Vikings drink, though a cheap one."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			iced_beer
				name = "Iced Beer"
				id = "iced_beer"
				description = "A beer which is so cold the air around it freezes."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

				on_mob_life(var/mob/living/M as mob)
					..()
					if (M.bodytemperature < 270)
						M.bodytemperature = min(270, M.bodytemperature-40) //310 is the normal bodytemp. 310.055
					return

			grog
				name = "Grog"
				id = "grog"
				description = "Watered down rum, Nanotrasen approves!"
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			aloe
				name = "Aloe"
				id = "aloe"
				description = "So very, very, very good."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			andalusia
				name = "Andalusia"
				id = "andalusia"
				description = "A nice, strange named drink."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			alliescocktail
				name = "Allies Cocktail"
				id = "alliescocktail"
				description = "A drink made from your allies."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0

			acid_spit
				name = "Acid Spit"
				id = "acidspit"
				description = "A drink by Nanotrasen. Made from live aliens."
				reagent_state = LIQUID
				color = "#365000" // rgb: 54, 80, 0

			amasec
				name = "Amasec"
				id = "amasec"
				description = "Official drink of the Imperium."
				reagent_state = LIQUID
				color = "#664300" // rgb: 102, 67, 0


			neurotoxin
				name = "Neurotoxin"
				id = "neurotoxin"
				description = "A strong neurotoxin that puts the subject into a death-like state."
				reagent_state = LIQUID
				color = "#2E2E61" // rgb: 46, 46, 97

				on_mob_life(var/mob/living/M as mob)
					M.weakened = max(M.weakened, 3)
					if(!data)
						data = 1
					data++
					M.dizziness +=6
					if(data >= 15 && data <45)
						if (!M.slurring)
							M.slurring = 1
						M.slurring += 3
					else if(data >= 45 && prob(50) && data <55)
						M.confused = max(M.confused+3,0)
					else if(data >=55)
						M.druggy = max(M.druggy, 55)
					else if(data >=200)
						M.adjustToxLoss(2)
					..()
					return

			bananahonk
				name = "Banana Mama"
				id = "bananahonk"
				description = "A drink from Clown Heaven."
				nutriment_factor = 1 * FOOD_METABOLISM
				color = "#664300" // rgb: 102, 67, 0

				on_mob_life(var/mob/living/M as mob)
					M.nutrition += nutriment_factor
					if(istype(M, /mob/living/carbon/human) && M.job in list("Clown"))
						if(!M) M = holder.my_atom
						M.heal_organ_damage(1,1)
						M.nutrition += nutriment_factor
						..()
						return
					..()

			silencer
				name = "Silencer"
				id = "silencer"
				description = "A drink from Mime Heaven."
				nutriment_factor = 1 * FOOD_METABOLISM
				color = "#664300" // rgb: 102, 67, 0

				on_mob_life(var/mob/living/M as mob)
					M.nutrition += nutriment_factor
					if(istype(M, /mob/living/carbon/human) && M.job in list("Mime"))
						if(!M) M = holder.my_atom
						M.heal_organ_damage(1,1)
						M.nutrition += nutriment_factor
						..()
						return
					..()

			changelingsting
				name = "Changeling Sting"
				id = "changelingsting"
				description = "A stingy drink."
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

				on_mob_life(var/mob/living/M as mob)
					..()
					M.dizziness +=5
					return

			erikasurprise
				name = "Erika Surprise"
				id = "erikasurprise"
				description = "The surprise is, it's green!"
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

			irishcarbomb
				name = "Irish Car Bomb"
				id = "irishcarbomb"
				description = "Mmm, tastes like chocolate cake..."
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

				on_mob_life(var/mob/living/M as mob)
					..()
					M.dizziness +=5
					return

			syndicatebomb
				name = "Syndicate Bomb"
				id = "syndicatebomb"
				description = "A Syndicate bomb"
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

			erikasurprise
				name = "Erika Surprise"
				id = "erikasurprise"
				description = "The surprise is, it's green!"
				reagent_state = LIQUID
				color = "#2E6671" // rgb: 46, 102, 113

			driestmartini
				name = "Driest Martini"
				id = "driestmartini"
				description = "Only for the experienced. You think you see sand floating in the glass."
				nutriment_factor = 1 * FOOD_METABOLISM
				color = "#2E6671" // rgb: 46, 102, 113

				on_mob_life(var/mob/living/M as mob)
					if(!data) data = 1
					data++
					M.dizziness +=10
					if(data >= 55 && data <115)
						if (!M.stuttering) M.stuttering = 1
						M.stuttering += 10
					else if(data >= 115 && prob(33))
						M.confused = max(M.confused+15,15)
					..()

					return

// Undefine the alias for REAGENTS_EFFECT_MULTIPLER
#undef REM


/datum/reagent/Destroy()
	if(holder)
		holder.reagent_list -= src
		holder = null
