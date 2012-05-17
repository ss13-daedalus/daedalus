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
