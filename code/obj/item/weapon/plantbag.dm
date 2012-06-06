/**********************Plant Bag**************************/

/obj/item/weapon/plantbag
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "plantbag"
	name = "Plant Bag"
	var/mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 50; //the number of plant pieces it can carry.
	flags = FPRINT | TABLEPASS | ONBELT
	w_class = 1

/obj/item/weapon/plantbag/attack_self(mob/user as mob)
	for (var/obj/item/weapon/reagent_containers/food/snacks/grown/O in contents)
		contents -= O
		O.loc = user.loc
	user << "\blue You empty the plant bag."
	return

/obj/item/weapon/plantbag/verb/toggle_mode()
	set name = "Switch Bagging Method"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			usr << "The bag now picks up all plants in a tile at once."
		if(0)
			usr << "The bag now picks up one plant at a time."
