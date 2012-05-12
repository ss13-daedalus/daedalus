/obj/effect/proc_holder/spell
	name = "Spell"
	desc = "A wizard spell"
	density = 0
	opacity = 0

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?

	var/charge_type = "recharge" //can be recharge or charges, see charge_max and charge_counter descriptions; can also be based on the holder's vars now, use "holder_var" for that

	var/charge_max = 100 //recharge time in deciseconds if charge_type = "recharge" or starting charges if charge_type = "charges"
	var/charge_counter = 0 //can only cast spells if it equals recharge, ++ each decisecond if charge_type = "recharge" or -- each cast if charge_type = "charges"

	var/holder_var_type = "bruteloss" //only used if charge_type equals to "holder_var"
	var/holder_var_amount = 20 //same. The amount adjusted with the mob's var when the spell is used

	var/clothes_req = 1 //see if it requires clothes
	var/stat_allowed = 0 //see if it requires being conscious/alive, need to set to 1 for ghostpells
	var/invocation = "HURP DURP" //what is uttered when the wizard casts the spell
	var/invocation_type = "none" //can be none, whisper and shout
	var/range = 7 //the range of the spell; outer radius for aoe spells
	var/message = "" //whatever it says to the guy affected by it
	var/selection_type = "view" //can be "range" or "view"

	var/overlay = 0
	var/overlay_icon = 'icons/obj/wizard.dmi'
	var/overlay_icon_state = "spell"
	var/overlay_lifespan = 0

	var/sparks_spread = 0
	var/sparks_amt = 0 //cropped at 10
	var/smoke_spread = 0 //1 - harmless, 2 - harmful
	var/smoke_amt = 0 //cropped at 10

	var/critfailchance = 0

/obj/effect/proc_holder/spell/proc/cast_check(skipcharge = 0,mob/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell

	if(!(src in usr.spell_list))
		usr << "\red You shouldn't have this spell! Something's wrong."
		return 0

	if(!skipcharge)
		switch(charge_type)
			if("recharge")
				if(charge_counter < charge_max)
					usr << "[name] is still recharging."
					return 0
			if("charges")
				if(!charge_counter)
					usr << "[name] has no charges left."
					return 0

	if(usr.stat && !stat_allowed)
		usr << "Not when you're incapacitated."
		return 0

	if(clothes_req) //clothes check
		if(!istype(usr, /mob/living/carbon/human))
			usr << "You aren't a human, Why are you trying to cast a human spell, silly non-human? Casting human spells is for humans."
			return 0
		if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
			usr << "I don't feel strong enough without my robe."
			return 0
		if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
			usr << "I don't feel strong enough without my sandals."
			return 0
		if(!istype(usr:head, /obj/item/clothing/head/wizard))
			usr << "I don't feel strong enough without my hat."
			return 0

	if(!skipcharge)
		switch(charge_type)
			if("recharge")
				charge_counter = 0 //doesn't start recharging until the targets selecting ends
			if("charges")
				charge_counter-- //returns the charge if the targets selecting fails
			if("holdervar")
				adjust_var(user, holder_var_type, holder_var_amount)

	return 1

/obj/effect/proc_holder/spell/proc/invocation(mob/user = usr) //spelling the spell out and setting it on recharge/reducing charges amount

	switch(invocation_type)
		if("shout")
			usr.say(invocation)
			if(usr.gender=="male")
				playsound(usr.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
			else
				playsound(usr.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
		if("whisper")
			usr.whisper(invocation)

/obj/effect/proc_holder/spell/New()
	..()

	charge_counter = charge_max

/obj/effect/proc_holder/spell/Click()
	..()

	if(!cast_check())
		return

	choose_targets()

/obj/effect/proc_holder/spell/proc/choose_targets(mob/user = usr) //depends on subtype - /targeted or /aoe_turf
	return

/obj/effect/proc_holder/spell/proc/start_recharge()
	while(charge_counter < charge_max)
		sleep(1)
		charge_counter++

/obj/effect/proc_holder/spell/proc/perform(list/targets, recharge = 1) //if recharge is started is important for the trigger spells
	before_cast(targets)
	invocation()
	spawn(0)
		if(charge_type == "recharge" && recharge)
			start_recharge()
	if(prob(critfailchance))
		critfail(targets)
	else
		cast(targets)
	after_cast(targets)

/obj/effect/proc_holder/spell/proc/before_cast(list/targets)
	if(overlay)
		for(var/atom/target in targets)
			var/location
			if(istype(target,/mob))
				location = target.loc
			else if(istype(target,/turf))
				location = target
			var/obj/effect/overlay/spell = new /obj/effect/overlay(location)
			spell.icon = overlay_icon
			spell.icon_state = overlay_icon_state
			spell.anchored = 1
			spell.density = 0
			spawn(overlay_lifespan)
				del(spell)

/obj/effect/proc_holder/spell/proc/after_cast(list/targets)
	for(var/atom/target in targets)
		var/location
		if(istype(target,/mob))
			location = target.loc
		else if(istype(target,/turf))
			location = target
		if(istype(target,/mob) && message)
			target << text("[message]")
		if(sparks_spread)
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(sparks_amt, 0, location) //no idea what the 0 is
			sparks.start()
		if(smoke_spread)
			if(smoke_spread == 1)
				var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()
			else if(smoke_spread == 2)
				var/datum/effect/effect/system/bad_smoke_spread/smoke = new /datum/effect/effect/system/bad_smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()

/obj/effect/proc_holder/spell/proc/cast(list/targets)
	return

/obj/effect/proc_holder/spell/proc/critfail(list/targets)
	return

/obj/effect/proc_holder/spell/proc/revert_cast(mob/user = usr) //resets recharge or readds a charge
	switch(charge_type)
		if("recharge")
			charge_counter = charge_max
		if("charges")
			charge_counter++
		if("holdervar")
			adjust_var(user, holder_var_type, -holder_var_amount)

	return

/obj/effect/proc_holder/spell/proc/adjust_var(mob/target = usr, type, amount) //handles the adjustment of the var when the spell is used. has some hardcoded types
	switch(type)
		if("bruteloss")
			target.adjustBruteLoss(amount)
		if("fireloss")
			target.adjustFireLoss(amount)
		if("toxloss")
			target.adjustToxLoss(amount)
		if("oxyloss")
			target.adjustOxyLoss(amount)
		if("stunned")
			target.AdjustStunned(amount)
		if("weakened")
			target.AdjustWeakened(amount)
		if("paralysis")
			target.AdjustParalysis(amount)
		else
			target.vars[type] += amount //I bear no responsibility for the runtimes that'll happen if you try to adjust non-numeric or even non-existant vars
	return

/obj/effect/proc_holder/spell/targeted //can mean aoe for mobs (limited/unlimited number) or one target mob
	var/max_targets = 1 //leave 0 for unlimited targets in range, 1 for one selectable target in range, more for limited number of casts (can all target one guy, depends on target_ignore_prev) in range
	var/target_ignore_prev = 1 //only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast
	var/include_user = 0 //if it includes usr in the target list

/obj/effect/proc_holder/spell/aoe_turf //affects all turfs in view or range (depends)
	var/inner_radius = -1 //for all your ring spell needs

/obj/effect/proc_holder/spell/targeted/choose_targets(mob/user = usr)
	var/list/targets = list()

	switch(max_targets)
		if(0) //unlimited
			for(var/mob/target in view_or_range(range, user, selection_type))
				targets += target
		if(1) //single target can be picked
			if(range < 0)
				targets += user
			else
				var/possible_targets = view_or_range(range, user, selection_type)
				if(!include_user && user in possible_targets)
					possible_targets -= user
				targets += input("Choose the target for the spell.", "Targeting") as mob in possible_targets
		else
			var/list/possible_targets = list()
			for(var/mob/target in view_or_range(range, user, selection_type))
				possible_targets += target
			for(var/i=1,i<=max_targets,i++)
				if(!possible_targets.len)
					break
				if(target_ignore_prev)
					var/target = pick(possible_targets)
					possible_targets -= target
					targets += target
				else
					targets += pick(possible_targets)

	if(!include_user && (user in targets))
		targets -= user

	if(!targets.len) //doesn't waste the spell
		revert_cast(user)
		return

	perform(targets)

	return

/obj/effect/proc_holder/spell/aoe_turf/choose_targets(mob/user = usr)
	var/list/targets = list()

	for(var/turf/target in view_or_range(range,user,selection_type))
		if(!(target in view_or_range(inner_radius,user,selection_type)))
			targets += target

	if(!targets.len) //doesn't waste the spell
		revert_cast()
		return

	perform(targets)

	return

/obj/effect/proc_holder/spell/targeted/area_teleport
	name = "Area teleport"
	desc = "This spell teleports you to a type of area of your selection."

	var/randomise_selection = 0 //if it lets the usr choose the teleport loc or picks it from the list
	var/invocation_area = 1 //if the invocation appends the selected area

/obj/effect/proc_holder/spell/targeted/area_teleport/perform(list/targets, recharge = 1)
	var/thearea = before_cast(targets)
	if(!thearea || !cast_check(1))
		revert_cast()
		return
	invocation(thearea)
	spawn(0)
		if(charge_type == "recharge" && recharge)
			start_recharge()
	cast(targets,thearea)
	after_cast(targets)

/obj/effect/proc_holder/spell/targeted/area_teleport/before_cast(list/targets)
	var/A = null

	if(!randomise_selection)
		A = input("Area to teleport to", "Teleport", A) in teleportlocs
	else
		A = pick(teleportlocs)

	var/area/thearea = teleportlocs[A]

	return thearea

/obj/effect/proc_holder/spell/targeted/area_teleport/cast(list/targets,area/thearea)
	for(var/mob/target in targets)
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

		target.loc = pick(L)

	return

/obj/effect/proc_holder/spell/targeted/area_teleport/invocation(area/chosenarea = null)
	if(!invocation_area || !chosenarea)
		..()
	else
		switch(invocation_type)
			if("shout")
				usr.say("[invocation] [uppertext(chosenarea.name)]")
				if(usr.gender=="male")
					playsound(usr.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
				else
					playsound(usr.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
			if("whisper")
				usr.whisper("[invocation] [uppertext(chosenarea.name)]")

	return


/obj/effect/proc_holder/spell/aoe_turf/conjure
	name = "Conjure"
	desc = "This spell conjures objs of the specified types in range."

	var/list/summon_type = list() //determines what exactly will be summoned
	//should be text, like list("/obj/machinery/bot/ed209")

	var/summon_lifespan = 0 // 0=permanent, any other time in deciseconds
	var/summon_amt = 1 //amount of objects summoned
	var/summon_ignore_density = 0 //if set to 1, adds dense tiles to possible spawn places
	var/summon_ignore_prev_spawn_points = 0 //if set to 1, each new object is summoned on a new spawn point

	var/list/newVars = list() //vars of the summoned objects will be replaced with those where they meet
	//should have format of list("emagged" = 1,"name" = "Wizard's Justicebot"), for example

/obj/effect/proc_holder/spell/aoe_turf/conjure/cast(list/targets)

	for(var/turf/T in targets)
		if(T.density && !summon_ignore_density)
			targets -= T

	for(var/i=0,i<summon_amt,i++)
		if(!targets.len)
			break
		var/summoned_object_type = text2path(pick(summon_type))
		var/spawn_place = pick(targets)
		if(summon_ignore_prev_spawn_points)
			targets -= spawn_place
		var/atom/summoned_object = new summoned_object_type(spawn_place)

		for(var/varName in newVars)
			if(varName in summoned_object.vars)
				summoned_object.vars[varName] = newVars[varName]

		if(summon_lifespan)
			spawn(summon_lifespan)
				if(summoned_object)
					del(summoned_object)

	return

/obj/effect/proc_holder/spell/aoe_turf/conjure/summonEdSwarm //test purposes
	name = "Dispense Wizard Justice"
	desc = "This spell dispenses wizard justice."

	summon_type = list("/obj/machinery/bot/ed209")
	summon_amt = 10
	range = 3
	newVars = list("emagged" = 1,"name" = "Wizard's Justicebot")


/obj/effect/proc_holder/spell/targeted/emplosion
	name = "Emplosion"
	desc = "This spell emplodes an area."

	var/emp_heavy = 2
	var/emp_light = 3

/obj/effect/proc_holder/spell/targeted/emplosion/cast(list/targets)

	for(var/mob/target in targets)
		empulse(target.loc, emp_heavy, emp_light)

	return


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."

	school = "transmutation"
	charge_max = 300
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1

	var/jaunt_duration = 50 //in deciseconds

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/cast(list/targets) //magnets, so mostly hardcoded
	for(var/mob/target in targets)
		spawn(0)
			var/mobloc = get_turf(target.loc)
			var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			animation.name = "water"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/mob/mob.dmi'
			animation.icon_state = "liquify"
			animation.layer = 5
			animation.master = holder
			flick("liquify",animation)
			target.loc = holder
			target.client.eye = holder
			var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
			steam.set_up(10, 0, mobloc)
			steam.start()
			sleep(jaunt_duration)
			mobloc = get_turf(target.loc)
			animation.loc = mobloc
			steam.location = mobloc
			steam.start()
			target.canmove = 0
			sleep(20)
			flick("reappear",animation)
			sleep(5)
			target.loc = mobloc
			target.canmove = 1
			target.client.eye = target
			del(animation)
			del(holder)

/obj/effect/proc_holder/spell/targeted/explosion
	name = "Explosion"
	desc = "This spell explodes an area."

	var/ex_severe = 1
	var/ex_heavy = 2
	var/ex_light = 3
	var/ex_flash = 4

/obj/effect/proc_holder/spell/targeted/explosion/cast(list/targets)

	for(var/mob/target in targets)
		explosion(target.loc,ex_severe,ex_heavy,ex_light,ex_flash)

	return

/obj/effect/proc_holder/spell/targeted/genetic
	name = "Genetic"
	desc = "This spell inflicts a set of mutations and disabilities upon the target."

	var/disabilities = 0 //bits
	var/mutations = 0 //bits
	var/duration = 100 //deciseconds
	/*
		Disabilities
			1st bit - ?
			2nd bit - ?
			3rd bit - ?
			4th bit - ?
			5th bit - ?
			6th bit - ?
		Mutations
			1st bit - portals
			2nd bit - cold resist
			3rd bit - xray
			4th bit - hulk
			5th bit - clown
			6th bit - fat
	*/

/obj/effect/proc_holder/spell/targeted/genetic/cast(list/targets)

	for(var/mob/target in targets)
		target.mutations |= mutations
		target.disabilities |= disabilities
		spawn(duration)
			target.mutations &= ~mutations
			target.disabilities &= ~disabilities

	return

/obj/effect/proc_holder/spell/targeted/inflict_handler
	name = "Inflict Handler"
	desc = "This spell blinds and/or destroys/damages/heals and/or weakens/stuns the target."

	var/amt_weakened = 0
	var/amt_paralysis = 0
	var/amt_stunned = 0

	//set to negatives for healing
	var/amt_dam_fire = 0
	var/amt_dam_brute = 0
	var/amt_dam_oxy = 0
	var/amt_dam_tox = 0

	var/amt_eye_blind = 0
	var/amt_eye_blurry = 0

	var/destroys = "none" //can be "none", "gib" or "disintegrate"

/obj/effect/proc_holder/spell/targeted/inflict_handler/cast(list/targets)

	for(var/mob/living/target in targets)
		switch(destroys)
			if("gib")
				target.gib()
			if("disintegrate")
				target.dust()

		if(!target)
			continue
		//damage
		if(amt_dam_brute > 0)
			if(amt_dam_fire >= 0)
				target.take_overall_damage(amt_dam_brute,amt_dam_fire)
			else if (amt_dam_fire < 0)
				target.take_overall_damage(amt_dam_brute,0)
				target.heal_overall_damage(0,amt_dam_fire)
		else if(amt_dam_brute < 0)
			if(amt_dam_fire > 0)
				target.take_overall_damage(0,amt_dam_fire)
				target.heal_overall_damage(amt_dam_brute,0)
			else if (amt_dam_fire <= 0)
				target.heal_overall_damage(amt_dam_brute,amt_dam_fire)
		target.adjustToxLoss(amt_dam_tox)
		target.oxyloss += amt_dam_oxy
		//disabling
		target.Weaken(amt_weakened)
		target.Paralyse(amt_paralysis)
		target.Stun(amt_stunned)

		target.eye_blind += amt_eye_blind
		target.eye_blurry += amt_eye_blurry

/obj/effect/proc_holder/spell/aoe_turf/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."

	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "AULIE OXIN FIERA"
	invocation_type = "whisper"
	range = 3

/obj/effect/proc_holder/spell/aoe_turf/knock/cast(list/targets)
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			spawn(1)
				if(istype(door,/obj/machinery/door/airlock))
					door:locked = 0
				door.open()
	return

/obj/effect/proc_holder/spell/targeted/mind_transfer
	name = "Mind Transfer"
	desc = "This spell allows the user to switch bodies with a target."

	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = "GIN'YU CAPAN"
	invocation_type = "whisper"
	range = 1
	var/list/protected_roles = list("Wizard","Changeling","Cultist") //which roles are immune to the spell
	var/list/compatible_mobs = list(/mob/living/carbon/human,/mob/living/carbon/monkey) //which types of mobs are affected by the spell. NOTE: change at your own risk
	var/base_spell_loss_chance = 20 //base probability of the wizard losing a spell in the process
	var/spell_loss_chance_modifier = 7 //amount of probability of losing a spell added per spell (mind_transfer included)
	var/spell_loss_amount = 1 //the maximum amount of spells possible to lose during a single transfer
	var/msg_wait = 500 //how long in deciseconds it waits before telling that body doesn't feel right or mind swap robbed of a spell
	var/paralysis_amount_caster = 20 //how much the caster is paralysed for after the spell
	var/paralysis_amount_victim = 20 //how much the victim is paralysed for after the spell

/*
Urist: I don't feel like figuring out how you store object spells so I'm leaving this for you to do.
Make sure spells that are removed from spell_list are actually removed and deleted when mind transfering.
Also, you never added distance checking after target is selected. I've went ahead and did that.
*/
/obj/effect/proc_holder/spell/targeted/mind_transfer/cast(list/targets,mob/user = usr)
	if(!targets.len)
		user << "No mind found."
		return

	if(targets.len > 1)
		user << "Too many minds! You're not a hive damnit!"//Whaa...aat?
		return

	var/mob/target = targets[1]

	if(!(target in oview(range)))//If they are not in overview after selection. Do note that !() is necessary for in to work because ! takes precedence over it.
		user << "They are too far away!"
		return

	if(!(target.type in compatible_mobs))
		user << "Their mind isn't compatible with yours."
		return

	if(target.stat == 2)
		user << "You didn't study necromancy back at the Space Wizard Federation academy."
		return

	if(!target.client || !target.mind)
	//if(!target.mind)//Good for testing.
		user << "They appear to be brain-dead."
		return

	if(target.mind.special_role in protected_roles)
		user << "Their mind is resisting your spell."
		return

	var/mob/victim = target//The target of the spell whos body will be transferred to.
	var/mob/caster = user//The wizard/whomever doing the body transferring.
	//To properly transfer clients so no-one gets kicked off the game, we need a host mob.
	var/mob/dead/observer/temp_ghost = new(victim)

	//SPELL LOSS BEGIN
	//NOTE: The caster must ALWAYS keep mind transfer, even when other spells are lost.
	var/obj/effect/proc_holder/spell/targeted/mind_transfer/m_transfer = locate() in user.spell_list//Find mind transfer directly.
	var/list/checked_spells = user.spell_list
	checked_spells -= m_transfer //Remove Mind Transfer from the list.

	if(caster.spell_list.len)//If they have any spells left over after mind transfer is taken out. If they don't, we don't need this.
		for(var/i=spell_loss_amount,(i>0&&checked_spells.len),i--)//While spell loss amount is greater than zero and checked_spells has spells in it, run this proc.
			for(var/j=checked_spells.len,(j>0&&checked_spells.len),j--)//While the spell list to check is greater than zero and has spells in it, run this proc.
				if(prob(base_spell_loss_chance))
					checked_spells -= pick(checked_spells)//Pick a random spell to remove.
					spawn(msg_wait)
						victim << "The mind transfer has robbed you of a spell."
					break//Spell lost. Break loop, going back to the previous for() statement.
				else//Or keep checking, adding spell chance modifier to increase chance of losing a spell.
					base_spell_loss_chance += spell_loss_chance_modifier

	checked_spells += m_transfer//Add back Mind Transfer.
	user.spell_list = checked_spells//Set user spell list to whatever the new list is.
	//SPELL LOSS END

	//MIND TRANSFER BEGIN
	if(caster.mind.special_verbs.len)//If the caster had any special verbs, remove them from the mob verb list.
		for(var/V in caster.mind.special_verbs)//Since the caster is using an object spell system, this is mostly moot.
			caster.verbs -= V//But a safety nontheless.

	if(victim.mind.special_verbs.len)//Now remove all of the victim's verbs.
		for(var/V in victim.mind.special_verbs)
			victim.verbs -= V

	temp_ghost.key = victim.key//Throw the victim into the ghost temporarily.
	temp_ghost.mind = victim.mind//Tranfer the victim's mind into the ghost.
	temp_ghost.spell_list = victim.spell_list//If they have spells, transfer them. Now we basically have a backup mob.

	victim.key = caster.key//Now we throw the caste into the victim's body.
	victim.mind = caster.mind//Do the same for their mind and spell list.
	victim.spell_list = caster.spell_list//Now they are inside the victim's body.

	if(victim.mind.special_verbs.len)//To add all the special verbs for the original caster.
		for(var/V in caster.mind.special_verbs)//Not too important but could come into play.
			caster.verbs += V

	caster.key = temp_ghost.key//Tranfer the original victim, now in a ghost, into the caster's body.
	caster.mind = temp_ghost.mind//Along with their mind and spell list.
	caster.spell_list = temp_ghost.spell_list

	if(caster.mind.special_verbs.len)//If they had any special verbs, we add them here.
		for(var/V in caster.mind.special_verbs)
			caster.verbs += V
	//MIND TRANSFER END

	//Now we update mind current mob so we know what body they are in for end round reporting.
	caster.mind.current = caster
	victim.mind.current = victim

	//Here we paralyze both mobs and knock them out for a time.
	caster.Paralyse(paralysis_amount_caster)
	victim.Paralyse(paralysis_amount_victim)

	//After a certain amount of time the victim gets a message about being in a different body.
	spawn(msg_wait)
		caster << "\red You feel woozy and lightheaded. <b>Your body doesn't seem like your own.</b>"

	del(temp_ghost)

/obj/effect/proc_holder/spell/targeted/projectile
	name = "Projectile"
	desc = "This spell summons projectiles which try to hit the targets."

	var/proj_icon = 'icons/obj/projectiles.dmi'
	var/proj_icon_state = "spell"
	var/proj_name = "a spell projectile"

	var/proj_trail = 0 //if it leaves a trail
	var/proj_trail_lifespan = 0 //deciseconds
	var/proj_trail_icon = 'icons/obj/wizard.dmi'
	var/proj_trail_icon_state = "trail"

	var/proj_type = "/obj/effect/proc_holder/spell/targeted" //IMPORTANT use only subtypes of this

	var/proj_lingering = 0 //if it lingers or disappears upon hitting an obstacle
	var/proj_homing = 1 //if it follows the target
	var/proj_insubstantial = 0 //if it can pass through dense objects or not
	var/proj_trigger_range = 0 //the range from target at which the projectile triggers cast(target)

	var/proj_lifespan = 15 //in deciseconds * proj_step_delay
	var/proj_step_delay = 1 //lower = faster

/obj/effect/proc_holder/spell/targeted/projectile/cast(list/targets, mob/user = usr)

	for(var/mob/target in targets)
		spawn(0)
			var/obj/effect/proc_holder/spell/targeted/projectile
			if(istext(proj_type))
				var/projectile_type = text2path(proj_type)
				projectile = new projectile_type(user)
			if(istype(proj_type,/obj/effect/proc_holder/spell))
				projectile = new /obj/effect/proc_holder/spell/targeted/trigger(user)
				projectile:linked_spells += proj_type
			projectile.icon = proj_icon
			projectile.icon_state = proj_icon_state
			projectile.dir = get_dir(target,projectile)
			projectile.name = proj_name

			var/current_loc = usr.loc

			projectile.loc = current_loc

			for(var/i = 0,i < proj_lifespan,i++)
				if(!projectile)
					break

				if(proj_homing)
					if(proj_insubstantial)
						projectile.dir = get_dir(projectile,target)
						projectile.loc = get_step_to(projectile,target)
					else
						step_to(projectile,target)
				else
					if(proj_insubstantial)
						projectile.loc = get_step(projectile,dir)
					else
						step(projectile,dir)

				if(!proj_lingering && projectile.loc == current_loc) //if it didn't move since last time
					del(projectile)
					break

				if(proj_trail && projectile)
					spawn(0)
						if(projectile)
							var/obj/effect/overlay/trail = new /obj/effect/overlay(projectile.loc)
							trail.icon = proj_trail_icon
							trail.icon_state = proj_trail_icon_state
							trail.density = 0
							spawn(proj_trail_lifespan)
								del(trail)

				if(projectile.loc in range(target.loc,proj_trigger_range))
					projectile.perform(list(target))
					break

				current_loc = projectile.loc

				sleep(proj_step_delay)

			if(projectile)
				del(projectile)

/obj/effect/proc_holder/spell/targeted/trigger
	name = "Trigger"
	desc = "This spell triggers another spell or a few."

	var/list/linked_spells = list() //those are just referenced by the trigger spell and are unaffected by it directly
	var/list/starting_spells = list() //those are added on New() to contents from default spells and are deleted when the trigger spell is deleted to prevent memory leaks

/obj/effect/proc_holder/spell/targeted/trigger/New()
	..()

	for(var/spell in starting_spells)
		var/spell_to_add = text2path(spell)
		new spell_to_add(src) //should result in adding to contents, needs testing

/obj/effect/proc_holder/spell/targeted/trigger/Del()
	for(var/spell in contents)
		del(spell)

	..()

/obj/effect/proc_holder/spell/targeted/trigger/cast(list/targets)
	for(var/mob/target in targets)
		for(var/obj/effect/proc_holder/spell/spell in contents)
			spell.perform(list(target),0)
		for(var/obj/effect/proc_holder/spell/spell in linked_spells)
			spell.perform(list(target),0)

	return

/obj/effect/proc_holder/spell/targeted/turf_teleport
	name = "Turf Teleport"
	desc = "This spell teleports the target to the turf in range."

	var/inner_tele_radius = 1
	var/outer_tele_radius = 2

	var/include_space = 0 //whether it includes space tiles in possible teleport locations
	var/include_dense = 0 //whether it includes dense tiles in possible teleport locations

/obj/effect/proc_holder/spell/targeted/turf_teleport/cast(list/targets)
	for(var/mob/target in targets)
		var/list/turfs = new/list()
		for(var/turf/T in range(target,outer_tele_radius))
			if(T in range(target,inner_tele_radius)) continue
			if(istype(T,/turf/space) && !include_space) continue
			if(T.density && !include_dense) continue
			if(T.x>world.maxx-outer_tele_radius || T.x<outer_tele_radius)	continue	//putting them at the edge is dumb
			if(T.y>world.maxy-outer_tele_radius || T.y<outer_tele_radius)	continue
			turfs += T

		if(!turfs.len)
			var/list/turfs_to_pick_from = list()
			for(var/turf/T in orange(target,outer_tele_radius))
				if(!(T in orange(target,inner_tele_radius)))
					turfs_to_pick_from += T
			turfs += pick(/turf in turfs_to_pick_from)

		var/turf/picked = pick(turfs)

		if(!picked || !isturf(picked))
			return

		target.loc = picked

/obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 150
	clothes_req = 1
	invocation = "FORTI GY AMA"
	invocation_type = "shout"
	range = 7

	max_targets = 0

	proj_icon_state = "magicm"
	proj_name = "a magic missile"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/targeted/inflict_handler/magic_missile"

	proj_lifespan = 20
	proj_step_delay = 5

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"

/obj/effect/proc_holder/spell/targeted/inflict_handler/magic_missile
	amt_weakened = 5
	amt_dam_fire = 10

/obj/effect/proc_holder/spell/targeted/genetic/mutate
	name = "Mutate"
	desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."

	school = "transmutation"
	charge_max = 400
	clothes_req = 1
	invocation = "BIRUZ BENNAR"
	invocation_type = "shout"
	message = "\blue You feel strong! You feel a pressure building behind your eyes!"
	range = -1
	include_user = 1

	mutations = LASER | HULK
	duration = 300

/obj/effect/proc_holder/spell/targeted/inflict_handler/disintegrate
	name = "Disintegrate"
	desc = "This spell instantly kills somebody adjacent to you with the vilest of magick."

	school = "evocation"
	charge_max = 600
	clothes_req = 1
	invocation = "EI NATH"
	invocation_type = "shout"
	range = 1

	destroys = "gib"

	sparks_spread = 1
	sparks_amt = 4

/obj/effect/proc_holder/spell/targeted/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."

	school = "conjuration"
	charge_max = 120
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1

	smoke_spread = 2
	smoke_amt = 10

/obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	charge_max = 400
	clothes_req = 1
	invocation = "NEC CANTIO"
	invocation_type = "shout"
	range = -1
	include_user = 1

	emp_heavy = 5
	emp_light = 7

/obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."

	school = "abjuration"
	charge_max = 20
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1

	smoke_spread = 1
	smoke_amt = 10

	inner_tele_radius = 0
	outer_tele_radius = 6

/obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	name = "Teleport"
	desc = "This spell teleports you to a type of area of your selection."

	school = "abjuration"
	charge_max = 600
	clothes_req = 1
	invocation = "SCYAR NILA"
	invocation_type = "shout"
	range = -1
	include_user = 1

	smoke_spread = 1
	smoke_amt = 5

/obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall
	name = "Forcewall"
	desc = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."

	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "whisper"
	range = 0

	summon_type = list("/obj/effect/forcefield")
	summon_lifespan = 300


/obj/effect/proc_holder/spell/aoe_turf/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades"

	school = "conjuration"
	charge_max = 600
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list("/obj/structure/constructshell")


/obj/effect/proc_holder/spell/aoe_turf/conjure/creature
	name = "Summon Creature Swarm"
	desc = "This spell tears the fabric of reality, allowing horrific daemons to spill forth"

	school = "conjuration"
	charge_max = 1200
	clothes_req = 0
	invocation = "IA IA"
	invocation_type = "shout"
	summon_amt = 10
	range = 3

	summon_type = list("/obj/effect/critter/creature")

/obj/effect/proc_holder/spell/targeted/trigger/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single person and does not require wizard garb."

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "\blue Your eyes cry out in pain!"

	starting_spells = list("/obj/effect/proc_holder/spell/targeted/inflict_handler/blind","/obj/effect/proc_holder/spell/targeted/genetic/blind")

/obj/effect/proc_holder/spell/targeted/inflict_handler/blind
	amt_eye_blind = 10
	amt_eye_blurry = 20

/obj/effect/proc_holder/spell/targeted/genetic/blind
	disabilities = 1
	duration = 300

/obj/effect/proc_holder/spell/targeted/projectile/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."

	school = "evocation"
	charge_max = 200
	clothes_req = 0
	invocation = "ONI SOMA"
	invocation_type = "shout"

	proj_icon_state = "fireball"
	proj_name = "a fireball"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/targeted/trigger/fireball"

	proj_lifespan = 200
	proj_step_delay = 1

/obj/effect/proc_holder/spell/targeted/trigger/fireball
	starting_spells = list("/obj/effect/proc_holder/spell/targeted/inflict_handler/fireball","/obj/effect/proc_holder/spell/targeted/explosion/fireball")

/obj/effect/proc_holder/spell/targeted/inflict_handler/fireball
	amt_dam_brute = 20
	amt_dam_fire = 25

/obj/effect/proc_holder/spell/targeted/explosion/fireball
	ex_severe = -1
	ex_heavy = -1
	ex_light = 2
	ex_flash = 5

//////////////////////////////Construct Spells/////////////////////////

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser
	charge_max = 1800

/obj/effect/proc_holder/spell/aoe_turf/conjure/floor
	name = "Floor Construction"
	desc = "This spell constructs a cult floor"

	school = "conjuration"
	charge_max = 20
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list("/turf/simulated/floor/engine/cult")

/obj/effect/proc_holder/spell/aoe_turf/conjure/wall
	name = "Leser Construction"
	desc = "This spell constructs a cult wall"

	school = "conjuration"
	charge_max = 100
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list("/turf/simulated/wall/cult")

/obj/effect/proc_holder/spell/aoe_turf/conjure/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall"

	school = "conjuration"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list("/turf/simulated/wall/r_wall")

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Nar-Sie's realm, summoning one of the legendary fragments across time and space"

	school = "conjuration"
	charge_max = 3000
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list("/obj/item/device/soulstone")


/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall
	name = "Shield"
	desc = "This spell creates a temporary forcefield to shield yourself and allies from incoming fire"

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list("/obj/effect/forcefield")
	summon_lifespan = 50


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "This spell allows you to pass through walls"

	school = "transmutation"
	charge_max = 200
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1

	jaunt_duration = 50 //in deciseconds
