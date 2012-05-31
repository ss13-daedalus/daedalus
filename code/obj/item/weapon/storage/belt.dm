/obj/item/weapon/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	flags = FPRINT | TABLEPASS | ONBELT
	max_w_class = 3
	max_combined_w_class = 21

	proc/can_use()
		if(!ismob(loc)) return 0
		var/mob/M = loc
		if(src in M.get_equipped_items())
			return 1
		else
			return 0


	MouseDrop(obj/over_object as obj, src_location, over_location)
		var/mob/M = usr
		if(!istype(over_object, /obj/screen))
			return ..()
		playsound(src.loc, "rustle", 50, 1, -5)
		if (!M.restrained() && !M.stat && can_use())
			if (over_object.name == "r_hand")
				if (!( M.r_hand ))
					M.u_equip(src)
					M.r_hand = src
			else
				if (over_object.name == "l_hand")
					if (!( M.l_hand ))
						M.u_equip(src)
						M.l_hand = src
			M.update_clothing()
			src.add_fingerprint(usr)
			return


	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		if(src.loc == user)
			playsound(src.loc, "rustle", 50, 1, -5)
			if (user.s_active)
				user.s_active.close(user)
			src.show_to(user)
		else
			return ..()



/obj/item/weapon/storage/belt/utility
	name = "tool-belt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Can hold various tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/welding_tool",
		"/obj/item/weapon/wire_cutters",
		"/obj/item/weapon/wrench",
		"/obj/item/device/multitool",
		"/obj/item/device/flashlight",
		"/obj/item/weapon/cable_coil",
		"/obj/item/device/t_scanner",
		"/obj/item/device/analyzer",
		"/obj/item/device/pda")


/obj/item/weapon/storage/belt/utility/full/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/welding_tool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wire_cutters(src)
	new /obj/item/weapon/cable_coil(src,30,pick("red","yellow"))


/obj/item/weapon/storage/belt/utility/atmostech/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/welding_tool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wire_cutters(src)
	new /obj/item/device/analyzer(src)

/obj/item/weapon/storage/belt/security/full/New()
	..()
	new /obj/item/weapon/melee/baton(src)
	new /obj/item/weapon/pepper_spray(src)
	new /obj/item/weapon/flashbang(src)
	new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/handcuffs(src)


/obj/item/weapon/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	can_hold = list(
		"/obj/item/device/healthanalyzer",
		"/obj/item/weapon/dnainjector",
		"/obj/item/weapon/reagent_containers/dropper",
		"/obj/item/weapon/reagent_containers/glass/beaker",
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/reagent_containers/glass/dispenser",
		"/obj/item/weapon/reagent_containers/hypospray",
		"/obj/item/weapon/lighter/zippo",
		"/obj/item/weapon/cigarette_pack",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight/pen",
		"/obj/item/device/pda"
	)


/obj/item/weapon/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	//storage_slots = 6
	can_hold = list(
		"/obj/item/weapon/flashbang",
		"/obj/item/weapon/pepper_spray",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_casing/shotgun",
		"/obj/item/ammo_magazine",
		"/obj/item/weapon/reagent_containers/food/snacks/donut",
		"/obj/item/weapon/reagent_containers/food/snacks/jellydonut",
		"/obj/item/device/radio",
		"/obj/item/device/detective_scanner",
		"/obj/item/device/pda",
		"/obj/item/weapon/gun/projectile/revolver",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/weapon/gun/energy/stunrevolver",
		"/obj/item/weapon/gun/energy/laser",
		"/obj/item/weapon/gun/energy",
		"/obj/item/weapon/gun/projectile",
		"/obj/item/weapon/melee/baton",
		"/obj/item/weapon/melee/classic_baton",
		"/obj/item/weapon/camera_test",
		"/obj/item/weapon/cigarette_pack",
		"/obj/item/weapon/zippo",
		"/obj/item/device/taperecorder",
		"/obj/item/weapon/evidencebag",
		"/obj/item/barricade_tape_roll/police"
		)

/obj/item/weapon/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away"
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_hold = list(
		"/obj/item/device/soulstone"
		)

/obj/item/weapon/storage/belt/soulstone/full/New()
	..()
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
