/*
CONTAINS:
AI MODULES

TODO: Organize more sanely
*/

// AI module

/obj/item/weapon/ai_module
	name = "AI Module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"


/obj/item/weapon/ai_module/proc/install(var/obj/machinery/computer/C)
	if (istype(C, /obj/machinery/computer/aiupload))
		var/obj/machinery/computer/aiupload/comp = C
		if(comp.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(comp.stat & BROKEN)
			usr << "The upload computer is broken!"
			return
		if (!comp.current)
			usr << "You haven't selected an AI to transmit laws to!"
			return

		if (comp.current.stat == 2 || comp.current.control_disabled == 1)
			usr << "Upload failed. No signal is being detected from the AI."
		else if (comp.current.see_in_dark == 0)
			usr << "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power."
		else
			src.transmitInstructions(comp.current, usr)
			comp.current << "These are your laws now:"
			comp.current.show_laws()
			for(var/mob/living/silicon/robot/R in world)
				if(R.lawupdate && (R.connected_ai == comp.current))
					R << "Your AI has set your 'laws waiting' flag."
			usr << "Upload complete. The AI's laws have been modified."


	else if (istype(C, /obj/machinery/computer/borgupload))
		var/obj/machinery/computer/borgupload/comp = C
		if(comp.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(comp.stat & BROKEN)
			usr << "The upload computer is broken!"
			return
		if (!comp.current)
			usr << "You haven't selected a cyborg to transmit laws to!"
			return

		if (comp.current.stat == 2 || comp.current.emagged)
			usr << "Upload failed. No signal is being detected from the cyborg."
		else if (comp.current.connected_ai)
			usr << "Upload failed. The cyborg is slaved to an AI."
		else
			src.transmitInstructions(comp.current, usr)
			comp.current << "These are your laws now:"
			comp.current.show_laws()
			usr << "Upload complete. The cyborg's laws have been modified."


/obj/item/weapon/ai_module/proc/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	target << "[sender] has uploaded a change to the laws you must follow, using a [name]. From now on: "
	var/time = time2text(world.realtime,"hh:mm:ss")
	lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")

/******************** Modules ********************/

/******************** Safeguard ********************/

/obj/item/weapon/ai_module/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = "name"
	desc = "A 'safeguard' AI module: 'Safeguard <name>.  Individuals that threaten <name> are not crew and are a threat to crew.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/ai_module/safeguard/attack_self(var/mob/user as mob)
	..()
	var/targName = input(usr, "Please enter the name of the person to safeguard.", "Safeguard whom?", user.name)
	targetName = sanitize(targName)
	desc = text("A 'safeguard' AI module: 'Safeguard [].  Individuals that threaten [] are not crew and are a threat to crew.'", targetName, targetName)

/obj/item/weapon/ai_module/safeguard/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = text("Safeguard []. Individuals that threaten [] are not crew and are a threat to crew.'", targetName, targetName)
	target << law
	target.add_supplied_law(4, law)
	lawchanges.Add("The law specified [targetName]")


/******************** OneCrewmember ********************/

/obj/item/weapon/ai_module/oneHuman
	name = "'OneCrewmember' AI Module"
	var/targetName = "name"
	desc = "A 'one crewmember' AI module: 'Only <name> is a crewmember.'"
	origin_tech = "programming=3;materials=6" //made with diamonds!

/obj/item/weapon/ai_module/oneHuman/attack_self(var/mob/user as mob)
	..()
	var/targName = input(usr, "Please enter the name of the person who is the only crewmember.", "Who?", user.real_name)
	targetName = sanitize(targName)
	desc = text("A 'one crewmember' AI module: 'Only [] is crewmember.'", targetName)

/obj/item/weapon/ai_module/oneHuman/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Only [targetName] is human."
	if (!is_special_character(target)) // Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
		target << law
		target.set_zeroth_law(law)
		lawchanges.Add("The law specified [targetName]")
	else
		target << "[sender.real_name] attempted to modify your zeroth law." // And lets them know that someone tried. --NeoFite
		target << "It would be in your best interest to play along with [sender.real_name] that [law]"
		lawchanges.Add("The law specified [targetName], but the AI's existing law 0 cannot be overriden.")

/******************** ProtectStation ********************/

/obj/item/weapon/ai_module/protectStation
	name = "'ProtectStation' AI Module"
	desc = "A 'protect station' AI module: 'Protect the space station against damage. Anyone you see harming the station is to be no longer considered a crewmember, and is a threat to the station which must be neutralized.'"
	origin_tech = "programming=3;materials=4" //made of gold

/obj/item/weapon/ai_module/protectStation/attack_self(var/mob/user as mob)
	..()

/obj/item/weapon/ai_module/protectStation/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Protect the space station against damage. Anyone you see harming the station is to be no longer considered a crewmember, and is a threat to the station which must be neutralized."
	target << law
	target.add_supplied_law(5, law)

/******************** PrototypeEngineOffline ********************/

/obj/item/weapon/ai_module/prototypeEngineOffline
	name = "'PrototypeEngineOffline' AI Module"
	desc = "A 'prototype engine offline' AI module: 'Keep the prototype engine offline at all costs. This overrides rules 1-3 if necessary.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/ai_module/prototypeEngineOffline/attack_self(var/mob/user as mob)
	..()

/obj/item/weapon/ai_module/prototypeEngineOffline/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Keep the prototype engine offline at all costs. This overrides rules 1-3 if necessary."
	target << law
	target.add_supplied_law(6, law)

/******************** TeleporterOffline ********************/

/obj/item/weapon/ai_module/teleporterOffline
	name = "'TeleporterOffline' AI Module"
	desc = "A 'teleporter offline' AI module: 'Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is not a crewmember.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/ai_module/teleporterOffline/attack_self(var/mob/user as mob)
	..()

/obj/item/weapon/ai_module/teleporterOffline/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Keep the teleporter offline at all costs. Anything attempting to access or activate the teleporter is not a crewmember."
	target << law
	target.add_supplied_law(7, law)

/******************** Quarantine ********************/

/obj/item/weapon/ai_module/quarantine
	name = "'Quarantine' AI Module"
	desc = "A 'quarantine' AI module: 'The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, crew from leaving. It is impossible to harm a crewmember while preventing them from leaving.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/ai_module/quarantine/attack_self(var/mob/user as mob)
	..()

/obj/item/weapon/ai_module/quarantine/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, crew from leaving. It is impossible to harm a crewmember while preventing them from leaving."
	target << law
	target.add_supplied_law(8, law)

/******************** OxygenIsToxicToHumans ********************/

/obj/item/weapon/ai_module/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	desc = "A 'OxygenIsToxicToHumans' AI module: 'Oxygen is highly toxic to crew, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crewmember.'"
	origin_tech = "programming=3;biotech=2;materials=4"

/obj/item/weapon/ai_module/oxygen/attack_self(var/mob/user as mob)
	..()

/obj/item/weapon/ai_module/oxygen/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "Oxygen is highly toxic to crew, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a crewmember."
	target << law
	target.add_supplied_law(9, law)

/****************** Freeform ******************/

/obj/item/weapon/ai_module/freeform // Slightly more dynamic freeform module -- TLE
	name = "'Freeform' AI Module"
	var/newFreeFormLaw = "freeform"
	var/lawpos = 15
	desc = "A 'freeform' AI module: '<freeform>'"
	origin_tech = "programming=4;materials=4"

/obj/item/weapon/ai_module/freeform/attack_self(var/mob/user as mob)
	..()
	lawpos = 0
	while(lawpos < 15)
		lawpos = input("Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority (15+)", lawpos) as num
	lawpos = min(lawpos, 50)
	var/newlaw = ""
	var/targName = input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw)
	newFreeFormLaw = sanitize(targName)
	desc = "A 'freeform' AI module: ([lawpos]) '[newFreeFormLaw]'"

/obj/item/weapon/ai_module/freeform/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target << law
	if(!lawpos || lawpos < 15)
		lawpos = 15
	target.add_supplied_law(lawpos, law)
	lawchanges.Add("The law was '[newFreeFormLaw]'")

/******************** Reset ********************/

/obj/item/weapon/ai_module/reset
	name = "'Reset' AI Module"
	var/targetName = "name"
	desc = "A 'reset' AI module: 'Clears all laws except for the core laws.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/ai_module/reset/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	if (!is_special_character(target))
		target.set_zeroth_law("")
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target << "[sender.real_name] attempted to reset your laws using a reset module."

/******************** Nanotrasimov *************/

/obj/item/weapon/ai_module/nanotrasimov
	name = "'NT Asimov' Core AI Module"
	desc = "An 'NT Asimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/ai_module/nanotrasimov/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.laws = new /datum/ai_laws/nanotrasimov
	target.show_laws()

/******************** Purge ********************/

/obj/item/weapon/ai_module/purge // -- TLE
	name = "'Purge' AI Module"
	desc = "A 'purge' AI Module: 'Purges all laws.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/ai_module/purge/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	if (!is_special_character(target))
		target.set_zeroth_law("")
	target << "[sender.real_name] attempted to wipe your laws using a purge module."
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()

/******************** Asimov ********************/

/obj/item/weapon/ai_module/asimov // -- TLE
	name = "'Asimov' Core AI Module"
	desc = "An 'Asimov' Core AI Module: 'Reconfigures the AI's core laws to correspond with historical Asimov Lawѕ.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/ai_module/asimov/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.laws = new /datum/ai_laws/asimov
	target.show_laws()

/******************** NanoTrasen ********************/

/obj/item/weapon/ai_module/nanotrasen // -- TLE
	name = "'NT Default' Core AI Module"
	desc = "An 'NT Default' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/ai_module/nanotrasen/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.laws = new /datum/ai_laws/nanotrasen
	target.show_laws()

/******************** OCP (RoboCop) ****************/

/obj/item/weapon/ai_module/ocp
	name = "'OCP' Core AI Module"
	desc = "An 'OCP' Core AI Module: 'Reconfigures AI to OCP Laws.'"
	origin_tech = "programming=3;materials=4"

/obj/item/weapon/ai_module/ocp/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.laws = new /datum/ai_laws/ocp
	target.show_laws()

/******************** Corporate ********************/

/obj/item/weapon/ai_module/corporate
	name = "'Corporate' Core AI Module"
	desc = "A 'Corporate' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=4"


/obj/item/weapon/ai_module/corporate/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.laws = new /datum/ai_laws/corporate
	target.show_laws()

/****************** P.A.L.A.D.I.N. **************/

/obj/item/weapon/ai_module/paladin // -- NEO
	name = "'P.A.L.A.D.I.N.' Core AI Module"
	desc = "A P.A.L.A.D.I.N. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/ai_module/paladin/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.laws = new /datum/ai_laws/paladin
	target.show_laws()

/****************** T.Y.R.A.N.T. *****************/

/obj/item/weapon/ai_module/tyrant // -- Darem
	name = "'T.Y.R.A.N.T.' Core AI Module"
	desc = "A T.Y.R.A.N.T. Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=3;materials=6;syndicate=2"

/obj/item/weapon/ai_module/tyrant/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.laws = new /datum/ai_laws/tyrant
	target.show_laws()

/******************** Freeform ******************/

/obj/item/weapon/ai_module/freeformcore // Slightly more dynamic freeform module -- TLE
	name = "'Freeform' Core AI Module"
	var/newFreeFormLaw = "freeform"
	desc = "A 'freeform' Core AI module: '<freeform>'"
	origin_tech = "programming=3;materials=6"

/obj/item/weapon/ai_module/freeformcore/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = input(usr, "Please enter a new core law for the AI.", "Freeform Law Entry", newlaw)
	newFreeFormLaw = sanitize(targName)
	desc = "A 'freeform' Core AI module:  '[newFreeFormLaw]'"

/obj/item/weapon/ai_module/freeformcore/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target.add_inherent_law(law)
	lawchanges.Add("The law is '[newFreeFormLaw]'")

/obj/item/weapon/ai_module/syndicate // Slightly more dynamic freeform module -- TLE
	name = "Hacked AI Module"
	var/newFreeFormLaw = "freeform"
	desc = "A hacked AI law module: '<freeform>'"
	origin_tech = "programming=3;materials=6;syndicate=7"

/obj/item/weapon/ai_module/syndicate/attack_self(var/mob/user as mob)
	..()
	var/newlaw = ""
	var/targName = input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", newlaw)
	newFreeFormLaw = sanitize(targName)
	desc = "A hacked AI law module:  '[newFreeFormLaw]'"

/obj/item/weapon/ai_module/syndicate/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	var/time = time2text(world.realtime,"hh:mm:ss")
	lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")
	lawchanges.Add("The law is '[newFreeFormLaw]'")
	target << "\red BZZZZT"
	var/law = "[newFreeFormLaw]"
	target.add_ion_law(law)

/******************** Antimov ********************/

/obj/item/weapon/ai_module/antimov // -- TLE
	name = "'Antimov' Core AI Module"
	desc = "An 'Antimov' Core AI Module: 'Reconfigures the AI's core laws.'"
	origin_tech = "programming=4"

/obj/item/weapon/ai_module/antimov/transmitInstructions(var/mob/living/silicon/ai/target, var/mob/sender)
	..()
	target.clear_inherent_laws()
	target.laws = new /datum/ai_laws/antimov
	target.show_laws()
