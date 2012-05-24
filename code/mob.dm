/mob/verb/listen_ooc()
	set name = "Un/Mute OOC"
	set category = "OOC"

	if (src.client)
		src.client.listen_ooc = !src.client.listen_ooc
		if (src.client.listen_ooc)
			src << "\blue You are now listening to messages on the OOC channel."
		else
			src << "\blue You are no longer listening to messages on the OOC channel."

/mob/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return
	else if (!src.client.listen_ooc)
		return
	else if (!ooc_allowed && !src.client.holder)
		return
	else if (!dooc_allowed && !src.client.holder && (src.client.deadchat != 0))
		usr << "OOC for dead mobs has been turned off."
		return
	else if (src.client && (src.client.muted || src.client.muted_complete))
		src << "You are muted."
		return
	else if (findtext(msg, "byond://") && !src.client.holder)
		src << "<B>Advertising other servers is not allowed.</B>"
		log_admin("[key_name(src)] has attempted to advertise in OOC.")
		message_admins("[key_name_admin(src)] has attempted to advertise in OOC.")
		return

	log_ooc("[src.name]/[src.key] : [msg]")

	for (var/client/C)
		if (src.client.holder && (!src.client.stealth || C.holder))
//			C << "<span class=\"adminooc\"><span class=\"prefix\">OOC:</span> <span class=\"name\">[src.key]:</span> <span class=\"message\">[msg]</span></span>"
			if (src.client.holder.rank == "Admin Observer")
				C << "<span class=\"gfartooc\"><span class=\"prefix\">OOC:</span> <span class=\"name\">[src.key][src.client.stealth ? "/([src.client.fakekey])" : ""]:</span> <span class=\"message\">[msg]</span></span>"
			else if (src.client.holder.rank == "Retired Admin")
				C << "<span class=\"ooc\"><span class=\"prefix\">OOC:</span> <span class=\"name\">[src.key][src.client.stealth ? "/([src.client.fakekey])" : ""]:</span> <span class=\"message\">[msg]</span></span>"
			else
				C << "<font color=[src.client.ooccolor]><b><span class=\"prefix\">OOC:</span> <span class=\"name\">[src.key][src.client.stealth ? "/([src.client.fakekey])" : ""]:</span> <span class=\"message\">[msg]</span></b></font>"

		else if (C.listen_ooc)
			C << "<span class=\"ooc\"><span class=\"prefix\">OOC:</span> <span class=\"name\">[src.client.stealth ? src.client.fakekey : src.key]:</span> <span class=\"message\">[msg]</span></span>"

/mob/proc/ghostize(var/transfer_mind = 0)
	if(key)
		if(client)
			client.screen.len = null//Clear the hud, just to be sure.
		var/mob/dead/observer/ghost = new(src,transfer_mind)//Transfer safety to observer spawning proc.
		if(transfer_mind)//When a body is destroyed.
			if(mind)
				mind.transfer_to(ghost)
			else//They may not have a mind and be gibbed/destroyed.
				ghost.key = key
		else//Else just modify their key and connect them.
			ghost.key = key

		verbs -= /mob/proc/ghost
		if (ghost.client)
			ghost.client.eye = ghost

	else if(transfer_mind)//Body getting destroyed but the person is not present inside.
		for(var/mob/dead/observer/O in world)
			if(O.corpse == src&&O.key)//If they have the same corpse and are keyed.
				if(mind)
					O.mind = mind//Transfer their mind if they have one.
				break
	return

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/proc/ghost()
	set category = "Ghost"
	set name = "Ghost"
	set desc = "You cannot be revived as a ghost."

	/*if(stat != 2) //this check causes nothing but troubles. Commented out for Nar-Sie's sake. --rastaf0
		src << "Only dead people and admins get to ghost, and admins don't use this verb to ghost while alive."
		return*/
	if(key)
		var/mob/dead/observer/ghost = new(src)
		ghost.key = key
		if(timeofdeath)
			ghost.timeofdeath = timeofdeath
		verbs -= /mob/proc/ghost
		if (ghost.client)
			ghost.client.eye = ghost
	return

/mob/proc/adminghostize()
	if(client)
		client.mob = new/mob/dead/observer(src)
	return

/mob/proc/become_ai()
	if(client)
		client.screen.len = null
	var/mob/living/silicon/ai/O = new (loc, /datum/ai_laws/nanotrasen,,1)//No MMI but safety is in effect.
	O.invisibility = 0
	O.aiRestorePowerRoutine = 0
	O.lastKnownIP = client.address

	if(mind)
		mind.transfer_to(O)
		O.mind.original = O
	else
		O.mind = new
		O.mind.current = O
		O.mind.original = O
		O.mind.assigned_role = "AI"
		O.key = key

	if(!(O.mind in ticker.minds))
		ticker.minds += O.mind//Adds them to regular mind list.

	var/obj/loc_landmark
	for(var/obj/effect/landmark/start/sloc in world)
		if (sloc.name != "AI")
			continue
		if (locate(/mob/living) in sloc.loc)
			continue
		loc_landmark = sloc
	if (!loc_landmark)
		for(var/obj/effect/landmark/tripai in world)
			if (tripai.name == "tripai")
				if(locate(/mob/living) in tripai.loc)
					continue
				loc_landmark = tripai
	if (!loc_landmark)
		O << "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone."
		for(var/obj/effect/landmark/start/sloc in world)
			if (sloc.name == "AI")
				loc_landmark = sloc

	O.loc = loc_landmark.loc
	for (var/obj/item/device/radio/intercom/comm in O.loc)
		comm.ai += O

	O << "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>"
	O << "<B>To look at other parts of the station, double-click yourself to get a camera menu, use the freelook command, or use the Show Camera List command..</B>"
	O << "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>"
	O << "To use something, simply click or double-click it."
	O << "Currently right-click functions will not work for the AI (except examine), and will either be replaced with dialogs or won't be usable by the AI."
	if (!(ticker && ticker.mode && (O.mind in ticker.mode.malf_ai)))
		O.show_laws()
		O << "<b>These laws may be changed by other players, or by you being the traitor.</b>"
		O << "<br><b><font color=red>IMPORTANT GAMEPLAY ASPECTS:</font></b>"
		O << "1.) Act like an AI.  If someone is breaking into your upload, say something like \"Alert.  Unauthorised Access Detected: AI Upload.\" not \"Help! Urist is trying to subvert me!\""
		O << "2.) Do not watch the traitor like a hawk alerting the station to his/her every move.  This relates to 1."
		O << "3.) You are theoretically omniscient, but you should not be Beepsky 5000, laying down the law left and right.  That is security's job.  Instead, try to keep the station productive and effective.  (Feel free to report the location of major violence and crimes and all that, just do not be the evil thing looking over peoples shoulders)"
		O << "4.) Your laws are not in preference, laws do not take preference over one another unless specifically stated in the law."
		O << "<br>We want everyone to have a good time, so we, the admins, will try to correct you if you stray from these rules.  Just try to keep it sensible."

	O.verbs += AI_VERB_LIST

	O.job = "AI"

	spawn(0)
		ainame(O)
		world << text("<b>[O.real_name] is the AI!</b>")

		spawn(50)
			world << sound('sound/announcer/newAI.ogg')

		del(src)

	return O
/mob/proc/make_lesser_changeling()
	if(!changeling) changeling = new
	changeling.host = src

	src.verbs += /datum/changeling/proc/EvolutionMenu

	for(var/obj/effect/proc_holder/power/P in changeling.purchasedpowers)
		if(P.isVerb)
			if(P.allowduringlesserform)
				if(!(P in src.verbs))
					src.verbs += P.verbpath

/*	src.verbs += /client/proc/changeling_fakedeath
	src.verbs += /client/proc/changeling_lesser_transform
	src.verbs += /client/proc/changeling_blind_sting
	src.verbs += /client/proc/changeling_deaf_sting
	src.verbs += /client/proc/changeling_silence_sting
	src.verbs += /client/proc/changeling_unfat_sting
*/
	changeling.changeling_level = 1
	return

/mob/proc/make_changeling()
	if(!changeling) changeling = new
	changeling.host = src

	src.verbs += /datum/changeling/proc/EvolutionMenu

	for(var/obj/effect/proc_holder/power/P in changeling.purchasedpowers)
		if(P.isVerb)
			if(!(P in src.verbs))
				src.verbs += P.verbpath

/*
	src.verbs += /client/proc/changeling_absorb_dna
	src.verbs += /client/proc/changeling_transform
	src.verbs += /client/proc/changeling_lesser_form
	src.verbs += /client/proc/changeling_fakedeath

	src.verbs += /client/proc/changeling_deaf_sting
	src.verbs += /client/proc/changeling_blind_sting
	src.verbs += /client/proc/changeling_paralysis_sting
	src.verbs += /client/proc/changeling_silence_sting
	src.verbs += /client/proc/changeling_transformation_sting
	src.verbs += /client/proc/changeling_unfat_sting
	src.verbs += /client/proc/changeling_boost_range

*/
	changeling.changeling_level = 2
	if (!changeling.absorbed_dna)
		changeling.absorbed_dna = list()
	if (changeling.absorbed_dna.len == 0)
		changeling.absorbed_dna[src.real_name] = src.dna
	return

/mob/proc/make_greater_changeling()
	src.make_changeling()
	//This is a test function for the new changeling powers.  Grants all of them.
	return

/mob/proc/remove_changeling_powers()

	for(var/obj/effect/proc_holder/power/P in changeling.purchasedpowers)
		if(P.isVerb)
			src.verbs -= P.verbpath

/*
	src.verbs -= /client/proc/changeling_absorb_dna
	src.verbs -= /client/proc/changeling_transform
	src.verbs -= /client/proc/changeling_lesser_form
	src.verbs -= /client/proc/changeling_lesser_transform
	src.verbs -= /client/proc/changeling_fakedeath
	src.verbs -= /client/proc/changeling_deaf_sting
	src.verbs -= /client/proc/changeling_blind_sting
	src.verbs -= /client/proc/changeling_paralysis_sting
	src.verbs -= /client/proc/changeling_silence_sting
	src.verbs -= /client/proc/changeling_boost_range
	src.verbs -= /client/proc/changeling_transformation_sting
	src.verbs -= /client/proc/changeling_unfat_sting
*/
mob
	var
		datum/hSB/sandbox = null
	proc
		CanBuild()
			if(master_mode == "sandbox")
				sandbox = new/datum/hSB
				sandbox.owner = src.ckey
				if(src.client.holder)
					sandbox.admin = 1
				verbs += new/mob/proc/sandbox_panel
		sandbox_panel()
			if(sandbox)
				sandbox.update()

/mob/proc/tech()
	set category = "Spells"
	set name = "Disable Technology"
	set desc = "This spell disables all weapons, cameras and most other technology in range."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	usr.verbs -= /mob/proc/tech
	spawn(400)
		usr.verbs += /mob/proc/tech

	usr.say("NEC CANTIO")
	usr.spellvoice()
	empulse(src, 6, 10)
	return

//BLINK

/mob/proc/teleport()
	set category = "Spells"
	set name = "Teleport"
	set desc = "This spell teleports you to a type of area of your selection."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	var/A
	usr.verbs -= /mob/proc/teleport
/*
	var/list/theareas = new/list()
	for(var/area/AR in world)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station)) continue
		if(theareas.Find(AR.name)) continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == src.z)
			theareas += AR.name
			theareas[AR.name] = AR
*/

	A = input("Area to jump to", "BOOYEA", A) in teleport_locs

	spawn(600)
		usr.verbs += /mob/proc/teleport

	var/area/thearea = teleport_locs[A]

	usr.say("SCYAR NILA [uppertext(A)]")
	usr.spellvoice()

	var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
	smoke.set_up(5, 0, usr.loc)
	smoke.attach(usr)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(L.len)
		usr.loc = pick(L)
	else
		usr <<"The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry."

	smoke.start()

/mob/proc/teleportscroll()
	if(usr.stat)
		usr << "Not when you are incapacitated."
		return
	var/A

	A = input("Area to jump to", "BOOYEA", A) in teleport_locs
	var/area/thearea = teleport_locs[A]

	var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
	smoke.set_up(5, 0, usr.loc)
	smoke.attach(usr)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L.len)
		usr <<"Invalid teleport destination."
		return

	else
		usr.loc = pick(L)
		smoke.start()

//JAUNT

/mob/proc/swap(mob/living/M as mob in oview())
	set category = "Spells"
	set name = "Mind Transfer"
	set desc = "This spell allows the user to switch bodies with a target."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return

	if(M.client && M.mind)
		if(M.mind.special_role != "Wizard" || "Fake Wizard" || "Changeling" || "Cultist" || "Space Ninja")//Wizards, changelings, ninjas, and cultists are protected.
			if( (istype(M, /mob/living/carbon/human)) || (istype(M, /mob/living/carbon/monkey)) && M.stat != 2)
				var/mob/living/carbon/human/H = M //so it does not freak out when looking at the variables.
				var/mob/living/carbon/human/U = src

				U.whisper("GIN'YU CAPAN")
				U.verbs -= /mob/proc/swap
				if(U.mind.special_verbs.len)
					for(var/V in U.mind.special_verbs)
						U.verbs -= V

				var/mob/dead/observer/G = new /mob/dead/observer(H) //To properly transfer clients so no-one gets kicked off the game.

				H.client.mob = G
				if(H.mind.special_verbs.len)
					for(var/V in H.mind.special_verbs)
						H.verbs -= V
				G.mind = H.mind

				U.client.mob = H
				H.mind = U.mind
				if(H.mind.special_verbs.len)
					var/spell_loss = 1//Can lose only one spell during transfer.
					var/probability = 95 //To determine the chance of wizard losing their spell.
					for(var/V in H.mind.special_verbs)
						if(spell_loss == 0)
							H.verbs += V
						else
							if(prob(probability))
								H.verbs += V
								probability -= 7//Chance of of keeping spells goes down each time a spell is added. Less spells means less chance of losing them.
							else
								spell_loss = 0
								H.mind.special_verbs -= V
								spawn(500)
									H << "The mind transfer has robbed you of a spell."

			/*	//This code SHOULD work to prevent Mind Swap spam since the spell transfer code above instantly resets it.
				//I can't test this code because I can't test mind stuff on my own :x -- Darem.
				if(hascall(H, /mob/proc/swap))
					H.verbs -= /mob/proc/swap
				*/
				G.client.mob = U
				U.mind = G.mind
				if(U.mind.special_verbs.len)//Basic fix to swap verbs for any mob if needed.
					for(var/V in U.mind.special_verbs)
						U.verbs += V

				U.mind.current = U
				H.mind.current = H
				spawn(500)
					U << "Something about your body doesn't seem quite right..."

				U.Paralyse(20)
				H.Paralyse(20)

				spawn(600)
					H.verbs += /mob/proc/swap

				del(G)
			else
				src << "Their mind is not compatible."
				return
		else
			src << "Their mind is resisting your spell."
			return

	else
		src << "They appear to be brain-dead."
	return

//To batch-remove wizard spells. Linked to mind.dm.
/mob/proc/spellremove(var/mob/M as mob, var/spell_type = "verb")
//	..()
	if(spell_type == "verb")
		if(M.verbs.len)
			M.verbs -= /client/proc/jaunt
			M.verbs -= /client/proc/magicmissile
			M.verbs -= /client/proc/fireball
//			M.verbs -= /mob/proc/kill
			M.verbs -= /mob/proc/tech
			M.verbs -= /client/proc/smokecloud
			M.verbs -= /client/proc/blind
			M.verbs -= /client/proc/forcewall
			M.verbs -= /mob/proc/teleport
			M.verbs -= /client/proc/mutate
			M.verbs -= /client/proc/knock
			M.verbs -= /mob/proc/swap
			M.verbs -= /client/proc/blink
		if(M.mind && M.mind.special_verbs.len)
			M.mind.special_verbs -= /client/proc/jaunt
			M.mind.special_verbs -= /client/proc/magicmissile
			M.mind.special_verbs -= /client/proc/fireball
//			M.mind.special_verbs -= /mob/proc/kill
			M.mind.special_verbs -= /mob/proc/tech
			M.mind.special_verbs -= /client/proc/smokecloud
			M.mind.special_verbs -= /client/proc/blind
			M.mind.special_verbs -= /client/proc/forcewall
			M.mind.special_verbs -= /mob/proc/teleport
			M.mind.special_verbs -= /client/proc/mutate
			M.mind.special_verbs -= /client/proc/knock
			M.mind.special_verbs -= /mob/proc/swap
			M.mind.special_verbs -= /client/proc/blink
	else if(spell_type == "object")
		for(var/obj/effect/proc_holder/spell/spell_to_remove in src.spell_list)
			del(spell_to_remove)

/*Checks if the wizard can cast spells.
Made a proc so this is not repeated 14 (or more) times.*/
/mob/proc/casting()
//Removed the stat check because not all spells require clothing now.
	if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
		usr << "I don't feel strong enough without my robe."
		return 0
	if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
		usr << "I don't feel strong enough without my sandals."
		return 0
	if(!istype(usr:head, /obj/item/clothing/head/wizard))
		usr << "I don't feel strong enough without my hat."
		return 0
	else
		return 1

/*Checks if the wizard is a mime and male/female.
Outputs the appropriate voice if the user is not a mime.
Made a proc here so it's not repeated several times.*/
/mob/proc/spellvoice()
//	if(!usr.miming)No longer necessary.
//	if(usr.gender=="male")
//		playsound(usr.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
//	else
//		playsound(usr.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)

//Allows the mob to grab a stealth icon.
/mob/proc/NinjaStealthActive(atom/A)//A is the atom which we are using as the overlay.
	invisibility = 2//Set ninja invis to 2.
	var/icon/opacity_icon = new(A.icon, A.icon_state)
	var/icon/alpha_mask = getIconMask(src)
	var/icon/alpha_mask_2 = new('icons/effects/effects.dmi', "at_shield1")
	alpha_mask.AddAlphaMask(alpha_mask_2)
	opacity_icon.AddAlphaMask(alpha_mask)
	for(var/i=0,i<5,i++)//And now we add it as overlays. It's faster than creating an icon and then merging it.
		var/image/I = image("icon" = opacity_icon, "icon_state" = A.icon_state, "layer" = layer+0.8)//So it's above other stuff but below weapons and the like.
		switch(i)//Now to determine offset so the result is somewhat blurred.
			if(1)
				I.pixel_x -= 1
			if(2)
				I.pixel_x += 1
			if(3)
				I.pixel_y -= 1
			if(4)
				I.pixel_y += 1

		overlays += I//And finally add the overlay.
	overlays += image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = layer+0.9)

//When ninja steal malfunctions.
/mob/proc/NinjaStealthMalf()
	invisibility = 0//Set ninja invis to 0.
	overlays += image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = layer+0.9)
	playsound(loc, 'sound/effects/stealthoff.ogg', 75, 1)

//=======//GENERIC VERB MODIFIERS//=======//


mob/proc/flash_weak_pain()
	flick("weak_pain",pain)

