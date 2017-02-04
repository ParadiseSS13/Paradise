/obj/machinery/helperbuddy
  name =  "Helper Buddy 3.0"
  desc =  "A NanoTrasen-approved holographic Helper Buddy!"
  icon_state =  "holopad0"
  anchored = 1
  atom_say_verb = "beeps"
  var/talking

  layer = TURF_LAYER+0.1

/obj/machinery/helperbuddy/New()
  ..()
  component_parts = list()
  component_parts += new /obj/item/weapon/circuitboard/helperbuddy(null)
  component_parts += new /obj/item/weapon/stock_parts/capacitor(null)

/obj/machinery/helperbuddy/attackby(obj/item/A as obj, mob/user as mob, params)
  if(default_deconstruction_screwdriver(user, "holopad_open", "holopad0", A))
    return

  if(exchange_parts(user, A))
    return

  if(default_unfasten_wrench(user, A))
    return

  default_deconstruction_crowbar(A)

/obj/machinery/helperbuddy/attack_ai(mob/user as mob)
  return attack_hand(user)


/obj/machinery/helperbuddy/attack_hand(mob/user)

  if(stat & NOPOWER)
    return

  if(panel_open)
    to_chat(user, "<b>Close the maintenance panel first.</b>")
    return

  ui_interact(user)

/obj/machinery/helperbuddy/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
  var/data[0]

  data["medbay"] = "<B>Medbay Lessons</B>"
  data["basic"] = "On Basic Medicine"
  data["chemistry"] = "On Chemistry"
  data["morgue"] = "On the Morgue"
  data["surgery"] = "On Surgery"
  data["cloning"] = "On Cloning"
  data["ressuscitation"] = "On Ressuscitation"
  data["cryotubes"] = "On Cryotubes"

  ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
  ui = new(user, src, ui_key, "helperbuddy.tmpl", "Helper Buddy UI", 540, 450)
  ui.set_initial_data(data)
  ui.open()

/obj/machinery/helperbuddy/Topic(href, href_list)
  if(talking)
    return

  if(href_list["basic"])
    talking = 1
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    atom_say("<B>Thank you for initiating Helper Buddy 3.0! You have selected: BASIC MEDICINE!</B>")
    sleep(50)
    atom_say("<B>There are six main types of injury a person can sustain: Brute, Burn, Toxin, Oxygen, Brain and Cellular!</B>")
    sleep(50)
    atom_say("<B>Brute injuries are a result of blunt force trauma, physical assault or anything that could leave a physical mark. It can be easily fixed with Trauma Kits, Synthflesh, Styptic Powder or Cryotubes.</B>")
    sleep(50)
    atom_say("<B>Burn injuries are a result of either high or low temperatures, or, in extreme cases, exposure to laser damage. It can be easily fixed with Synthflesh, Silver Sulfadiazine or Cryotubes.</B>")
    sleep(50)
    atom_say("<B>Toxin damage is taken from poisons, exposure to plasma, or acute liver infections. It can be easily fixed with Charcoal, Pentetic Acid or Cryotubes.</B>")
    sleep(50)
    atom_say("<B>Oxygen loss can result from exposure to low-oxygen environments, strangulation or lung damage. It can be easily fixed with Salbutamol, or Perfluorodecalin. Make sure to identify the source of the oxygen loss, however!</B>")
    sleep(50)
    atom_say("<B>Brain damage can result from either blunt force trauma to the skull, or certain pathogens. It can be easily fixed with Mannitol, or Surgery.</B>")
    sleep(50)
    atom_say("<B>Cellular damage can result from either cloning, or attacks from Slimes (not the personnel kind). It can be easily fixed via the use of Cryotubes.</B>")
    sleep(50)
    atom_say("<B>Other types of medication may also help. Make sure to consult with your medical staff for more information.</B>")
    sleep(50)
    atom_say("<B>Remember, as well, that internal organ damage, broken bones or internal bleeding require the use of either advanced medication (for internal organ damage) or surgery (for all examples).</B>")
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    talking = 0

  if(href_list["chemistry"])
    talking = 1
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    atom_say("<B>Thank you for initiating Helper Buddy 3.0! You have selected: CHEMISTRY!</B>")
    sleep(50)
    atom_say("<B>Chemistry allows you to make powerful medication to help with nearly everything that Medbay can possibly deal with!</B>")
    sleep(50)
    atom_say("<B>The process of making medication is simple!</B>")
    sleep(50)
    atom_say("<B>Firstly, place a container in the Chemical Dispenser. This Dispenser has a large battery and can dispense any reagent you may require.</B>")
    sleep(50)
    atom_say("<B>To create medication, simply mix the reagents in the appropriate ratios. After you do, place the contained in the Chem-Master machine.</B>")
    sleep(50)
    atom_say("<B>This machine allows you to create patches, pills and bottles from any reagent you have in your container. Remember, different medication may require different administration!</B>")
    sleep(50)
    atom_say("<B>For example, Synthflesh, Styptic Powder and Silver Sulfadiazine should be available as Patches, while Charcoal should be available as a Pill.</B>")
    sleep(50)
    atom_say("<B>After you create Patches, Pills or Bottles, simply place them in the Medical Fridge below the main Chemistry area. This will allow every person in Medbay to have quick access to Medication!</B>")
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    talking = 0

  if(href_list["morgue"])
    talking = 1
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    atom_say("<B>Thank you for initiating Helper Buddy 3.0! You have selected: MORGUE!</B>")
    sleep(50)
    atom_say("<B>Using the Morgue is very simple. Simply place any bodies inside a body bag, use a pen on them to write on the tag and identify the body, then place the bag inside one of the trays!</B>")
    sleep(50)
    atom_say("<B>Remember, NanoTrasen-brand Morgue Trays (TM) can identify if a body is clonable!</B>")
    sleep(50)
    atom_say("<B>A Green Light on the Tray means the body is clonable.</B>")
    sleep(50)
    atom_say("<B>A Purple Light on the Tray means the body can be cloned, but will require some attempts at scanning the brain.</B>")
    sleep(50)
    atom_say("<B>A Red Light on the Tray means the body cannot be cloned.</B>")
    sleep(50)
    atom_say("<B>An Orange Light on the Tray means there is no body inside, but there are items present.</B>")
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    talking = 0

  if(href_list["surgery"])
    talking = 1
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    atom_say("<B>Thank you for initiating Helper Buddy 3.0! You have selected: SURGERY!</B>")
    sleep(50)
    atom_say("<B>Surgery is a rather complex procedure, so NanoTrasen offers plenty of tools for the aspiring surgeon to use!</B>")
    sleep(50)
    atom_say("<B>The first of these tools is the Body Scanner. Placing a person inside will allow you to see any damage present on their bodies. It even comes with a nifty Print option!</B>")
    sleep(50)
    atom_say("<B>The second of these tools is the Anesthetic, which allows your patients to drift into sleep harmlessly while you operate on them, preventing pain!</B>")
    sleep(50)
    atom_say("<B>Some patients may refuse Anesthetic. In those cases, offer alternatives, such as Morphine or Hydrocodone. However, should the patient refuse any form of sedative, you are to respect their request, so long as they do not sue.</B>")
    sleep(100)
    atom_say("<B>The third, and arguably most powerful, of these tools is the Operating Computer. If placed next to a Surgery Table, it will let you know which step to take on your patient's current surgery!</B>")
    sleep(50)
    atom_say("<B>You can initiate any surgery by using a sharp object, but please use scalpels when possible!</B>")
    sleep(50)
    atom_say("<B>Once the surgery is initiated, just look at the Operating Computer for the next step! Remember to clean your hands before operating on organs directly!</B>")
    sleep(50)
    atom_say("<B>Once the surgery is finished, remember to scan your patient for any damage, return their equipment and, if you used Anesthetics, wake them up properly!</B>")
    sleep(50)
    atom_say("<B>Thank you for using Helper Buddy 3.0!")
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    talking = 0

  if(href_list["cloning"])
    talking = 1
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    atom_say("<B>Thank you for initiating Helper Buddy 3.0! You have selected: CLONING!</B>")
    sleep(50)
    atom_say("<B>Cloning allows dead personnel to be brought back to life via the miracle of modern medical science!</B>")
    sleep(50)
    atom_say("<B>To clone a dead person, simply place their body inside a DNA Scanner next to a Clone Pod, then use the Computer nearby to analyze the body!</B>")
    sleep(50)
    atom_say("<B>After the body is analyzed, check if the Cloner has Biomass. If it does not, request some meat from Chemistry or the Kitchen.</B>")
    sleep(50)
    atom_say("<B>If the body is successfully analyzed, and the Cloner has Biomass, simply select the appropriate Record, then clone!</B>")
    sleep(50)
    atom_say("<B>Remember, however, that you need an active brain for cloning to be successful. If the brain is not active, cloning cannot be done!</B>")
    sleep(50)
    atom_say("<B>Some species are also unable to be cloned, such as Vox or Slime People. These should be Ressuscitated (see <I>Ressuscitation</I>).</B>")
    sleep(50)
    atom_say("<B>Once the Cloning process has begun, remove all the items from the scanned body, and place it in the Morgue.</B>")
    sleep(50)
    atom_say("<B>After the Cloning process is complete, and if the Cloner is not upgraded, the freshly cloned person will have Cellular Damage and Brain Damage. You can fix the first one via the use of Cryotubes (see <I>Cryotubes</I>), and the second one via the use of Mannitol (see <I>Chemistry</I>)!</B>")
    sleep(50)
    atom_say("<B>After everything is fixed, simply return the cloned individual's belongings. Remember: <I>do not tell people they were cloned. They may react badly.</I></B>")
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    talking = 0

  if(href_list["ressuscitation"])
    talking = 1
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    atom_say("<B>Thank you for initiating Helper Buddy 3.0! You have selected: RESSUSCITATION!</B>")
    sleep(50)
    atom_say("<B>There are two main ways of ressuscitating a dead person if Cloning is either not a viable method, or is simply not available!</B>")
    sleep(50)
    atom_say("<B>The easiest method is the use of the Defibrillator. Make sure to wear it on your back, unhook the paddles, and aim for the person's chest. If they died recently, the Defibbrilator will be able to restart their heart!</B>")
    sleep(50)
    atom_say("<B>Keep in mind, this will not work if the person's body is severely damaged. Make sure to treat injuries prior to using the Defibrillator</B>")
    sleep(50)
    atom_say("<B>The harder method is via the use of Strange Reagent. This complex chemical can, if used in very small doses, raise someone from the dead!</B>")
    sleep(50)
    atom_say("<B>If dosage is exceeded, however, the person receiving the Strange Reagent will explode. Use with caution.</B>")
    sleep(50)
    atom_say("<B>Regardless of the method used, make sure to treat injuries before and after their use.</B>")
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    talking = 0

  if(href_list["cryotubes"])
    talking = 1
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    atom_say("<B>Thank you for initiating Helper Buddy 3.0! You have selected: Cryotubes!</B>")
    sleep(50)
    atom_say("<B>Cryotubes can help you fix Brute, Burn, Toxin and Oxygen injuries quite efficiently, and with little input from the attending doctor. They cannot help with severe injuries, however, so always pay attention!</B>")
    sleep(50)
    atom_say("<B>Before they can be used, Cryotubes must have a container with Cryoxadone placed inside them. After that, turn on the freezer near them, and set it to the lowest possible temperature.</B>")
    sleep(50)
    atom_say("<B>To use a Cryotube, simply place someone inside and activate it. The graphics on the menu should tell you how the process is going.</B>")
    sleep(50)
    atom_say("<B>Remember that some forms of gear, such as hardsuits, will prevent the Cryotube from working properly. Make sure that temperature-resistant gear is removed from the patient before using a Cryotube.</B>")
    sleep(50)
    atom_say("<B>Pay close attention to Robotic Limbs and severe damage, such as organ damage or internal bleeding! Cryotubes cannot handle these sorts of injuries, which require surgical assistance!</B>")
    sleep(50)
    atom_say("<B>After the process is complete, and the patient ejected from the Cryotube, make sure to wake them up!</B>")
    playsound(loc, 'sound/machines/ping.ogg', 50, 0)
    talking = 0
