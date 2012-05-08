

/* There were two duplicate filing cabinet code sets.  I commented one out at
	semirandom to test.

	TODO:  If the test works, move this commented out code to unused/

/obj/structure/filing_cabinet
	name = "Filing Cabinet"
	desc = "A large cabinet with drawers."
	icon = 'bureaucracy.dmi'
	icon_state = "filing_cabinet"
	density = 1
	anchored = 1

/obj/structure/filing_cabinet/attackby(obj/item/weapon/paper/P,mob/M)
	if(istype(P))
		M << "You put the [P] in the [src]."
		M.drop_item()
		P.loc = src
	else
		M << "You can't put a [P] in the [src]!"

/obj/structure/filing_cabinet/attack_hand(mob/user)
	if(src.contents.len <= 0)
		user << "The [src] is empty."
		return
	var/obj/item/weapon/paper/P = input(user,"Choose a sheet to take out.","[src]", "Cancel") as null|obj in src.contents
	if(!isnull(P) && in_range(src,user))
		P.loc = user.loc
 */
