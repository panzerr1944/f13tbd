//Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/hooded
	actions_types = list(/datum/action/item_action/toggle_hood)
	var/obj/item/clothing/head/hooded/hood
	var/hoodtype = /obj/item/clothing/head/hooded/winterhood //so the chaplain hoodie or other hoodies can override this

/obj/item/clothing/suit/hooded/Initialize(mapload)
	. = ..()
	hood = MakeHelmet()

/obj/item/clothing/suit/hooded/Destroy()
	. = ..()
	qdel(hood)
	hood = null

/obj/item/clothing/suit/proc/MakeHelmet(obj/item/clothing/head/H)
	SEND_SIGNAL(src, COMSIG_SUIT_MADE_HELMET, H)
	return H

/obj/item/clothing/suit/hooded/MakeHelmet(obj/item/clothing/head/hooded/H)
	if(!hood)
		H = new hoodtype(src)
		H.suit = src
		return ..()

/obj/item/clothing/suit/hooded/ui_action_click()
	ToggleHood()

/obj/item/clothing/suit/hooded/item_action_slot_check(slot, mob/user, datum/action/A)
	if(slot == SLOT_WEAR_SUIT || slot == SLOT_NECK)
		return 1

/obj/item/clothing/suit/hooded/equipped(mob/user, slot)
	if(slot != SLOT_WEAR_SUIT && slot != SLOT_NECK)
		RemoveHood()
	..()

/obj/item/clothing/suit/hooded/proc/RemoveHood()
	suittoggled = FALSE
	if(ishuman(hood.loc))
		var/mob/living/carbon/H = hood.loc
		H.transferItemToLoc(hood, src, TRUE)
		H.update_inv_wear_suit()
	else
		hood.forceMove(src)
	update_icon()

/obj/item/clothing/suit/hooded/update_icon_state()
	icon_state = "[initial(icon_state)]"
	if(ishuman(hood?.loc))
		var/mob/living/carbon/human/H = hood.loc
		if(H.head == hood)
			icon_state += "_t"

/obj/item/clothing/suit/hooded/dropped(mob/user)
	..()
	RemoveHood()

/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(!hood)
		to_chat(loc, "<span class='warning'>[src] seems to be missing its hood..</span>")
		return
	if(atom_colours)
		hood.atom_colours = atom_colours.Copy()
		hood.update_atom_colour()
	if(!suittoggled)
		if(ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if(H.wear_suit != src)
				to_chat(H, "<span class='warning'>You must be wearing [src] to put up the hood!</span>")
				return
			if(H.head)
				to_chat(H, "<span class='warning'>You're already wearing something on your head!</span>")
				return
			else if(H.equip_to_slot_if_possible(hood,SLOT_HEAD,0,0,1))
				suittoggled = TRUE
				update_icon()
				H.update_inv_wear_suit()
	else
		RemoveHood()

/obj/item/clothing/head/hooded
	name = "hood"
	var/obj/item/clothing/suit/hooded/suit
	dynamic_hair_suffix = ""

/obj/item/clothing/head/hooded/Destroy()
	suit = null
	return ..()

/obj/item/clothing/head/hooded/dropped(mob/user)
	..()
	if(suit)
		suit.RemoveHood()

/obj/item/clothing/head/hooded/equipped(mob/user, slot)
	..()
	if(slot != SLOT_HEAD)
		if(suit)
			suit.RemoveHood()
		else
			qdel(src)

//Toggle exosuits for different aesthetic styles (hoodies, suit jacket buttons, etc)

/obj/item/clothing/suit/toggle/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	suit_toggle(user)
	return TRUE

/obj/item/clothing/suit/toggle/ui_action_click()
	suit_toggle()

/obj/item/clothing/suit/toggle/proc/suit_toggle()
	set src in usr

	if(!can_use(usr))
		return 0

	to_chat(usr, "<span class='notice'>You toggle [src]'s [togglename].</span>")
	if(src.suittoggled)
		src.icon_state = "[initial(icon_state)]"
		src.suittoggled = FALSE
	else if(!src.suittoggled)
		src.icon_state = "[initial(icon_state)]_t"
		src.suittoggled = TRUE
	usr.update_inv_wear_suit()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/toggle/examine(mob/user)
	. = ..()
	. += "Alt-click on [src] to toggle the [togglename]."

//Hardsuit toggle code
/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	. = ..()
	helmet = MakeHelmet()

/obj/item/clothing/suit/space/hardsuit/Destroy()
	if(!QDELETED(helmet))
		helmet.suit = null
		qdel(helmet)
		helmet = null
	QDEL_NULL(jetpack)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	if(suit)
		suit.helmet = null
	return ..()

/obj/item/clothing/suit/space/hardsuit/MakeHelmet(obj/item/clothing/head/helmet/space/hardsuit/H)
	if(!helmettype)
		return
	if(!helmet)
		H = new helmettype(src)
		H.suit = src
		return ..()

/obj/item/clothing/suit/space/hardsuit/ui_action_click()
	..()
	ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	if(!helmettype)
		return
	if(slot != SLOT_WEAR_SUIT)
		RemoveHelmet()
	..()

/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet(message = TRUE)
	if(!helmet)
		return
	suittoggled = FALSE
	if(ishuman(helmet.loc))
		var/mob/living/carbon/H = helmet.loc
		if(helmet.on)
			helmet.attack_self(H)
		H.transferItemToLoc(helmet, src, TRUE)
		H.update_inv_wear_suit()
		if(message)
			to_chat(H, "<span class='notice'>The helmet on the hardsuit disengages.</span>")
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	else
		helmet.forceMove(src)
	return TRUE

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	RemoveHelmet()

/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet(message = TRUE)
	var/mob/living/carbon/human/H = loc
	if(!helmettype)
		return
	if(!helmet)
		to_chat(H, "<span class='warning'>[src] seems to be missing its helmet..</span>")
		return
	if(atom_colours)
		helmet.atom_colours = atom_colours.Copy()
		helmet.update_atom_colour()
	if(!suittoggled)
		if(ishuman(src.loc))
			if(H.wear_suit != src)
				if(message)
					to_chat(H, "<span class='warning'>You must be wearing [src] to engage the helmet!</span>")
				return
			if(H.head)
				if(message)
					to_chat(H, "<span class='warning'>You're already wearing something on your head!</span>")
				return
			else if(H.equip_to_slot_if_possible(helmet,SLOT_HEAD,0,0,1))
				if(message)
					to_chat(H, "<span class='notice'>You engage the helmet on the hardsuit.</span>")
				suittoggled = TRUE
				H.update_inv_wear_suit()
				playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
			return TRUE
	else
		return RemoveHelmet(message)
