/datum/role/ddanrep
	name = DDANREP
	id = DDANREP
	required_pref = DDANREP
	special_role = DDANREP
	logo_state = "discount-logo"
	disallow_job = TRUE
	/var/datum/objective/stealcash/s = null
// check AssignToRole in role.dm later for parent- relationship

/datum/role/ddanrep/Greet()
	to_chat(antag.current, "<B><span class='warning'>You are a representative of the Discount Dan company!</span></B>")
	to_chat(antag.current, "The authorities of this specific station have not yet paid the required licensing fee.")
	to_chat(antag.current, "Discount Dan is not pleased, he needs you to improve the profit margin in this region.")


/datum/role/ddanrep/OnPostSetup()
	var/mob/living/carbon/human/H = antag.current
	H.dna.ResetUI()
	H.regenerate_icons()
	equip_ddanrep(H)
	//var/datum/money_account/M = create_account("Discount Dan",0,FALSE,0,1,TRUE)

/datum/role/ddanrep/ForgeObjectives()
	AppendObjective(/datum/objective/stealcash)

/datum/role/ddanrep/proc/equip_ddanrep(var/mob/living/carbon/human/H)
	var/datum/objective_holder/objust = objectives
	var/list/objustives = objust.objectives
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset(src), slot_ears)
	var/list/shirts = list(/obj/item/clothing/under/lawyer/red,/obj/item/clothing/under/lawyer/blue)
	var/chosen_shirt = pick(shirts)
	H.equip_to_slot_or_del(new chosen_shirt, slot_w_uniform)
	disable_suit_sensors(H)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(src), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/messenger(src), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(src), slot_in_backpack)
	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Discount Dan Representative"
	W.registered_name = H.real_name
	W.name = "[H.real_name]'s ID Card ([W.assignment])"
	W.access = list(access_maint_tunnels)
	W.icon_state = "discount"	//placeholder until revamp
	H.equip_to_slot_or_del(W, slot_wear_id)

	spawn(1)
	for(var/datum/objective/O in objustives)
		if(istype(O,/datum/objective/stealcash))
			s = O
	if(s)
		var/obj/item/weapon/card/debit/dansdebit = new
		dansdebit.name = "Discount Dan Debit Card"
		dansdebit.desc = "A flimsy piece of plastic with cheap near field circuitry backed by digits representing funds in a bank account.<br>On the back is a handwritten message:<br><i>Lose this and you're dead. -DD</i>"
		dansdebit.authorized_name = "Discount Dan INC."
		dansdebit.associated_account_number = s.discdanacc.account_number
		H.equip_to_slot_or_del(dansdebit, slot_in_backpack)
	AnnounceArrival(H,W.assignment)


/datum/role/ddanop
	name = DDANOP
	id = DDANOP
	faction = DDANOP
	required_pref = DDANOP
	special_role = DDANOP
	logo_state = "discount-logo"
	disallow_job = TRUE

/datum/role/ddanop/OnPostSetup()
	var/mob/living/carbon/human/H = antag.current
	H.dna.ResetUI()
	H.regenerate_icons()
	equip_ddanop(H)
	//var/datum/money_account/M = create_account("Discount Dan",0,FALSE,0,1,TRUE)

/datum/role/ddanop/proc/equip_ddanop(var/mob/living/carbon/human/H)
	var/datum/objective_holder/objust = objectives
	var/list/objustives = objust.objectives
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset(src), slot_ears)
	var/list/shirts = list(/obj/item/clothing/under/color/red,/obj/item/clothing/under/color/blue,/obj/item/clothing/under/color/green)
	var/chosen_shirt = pick(shirts)
	H.equip_to_slot_or_del(new chosen_shirt, slot_w_uniform)
	disable_suit_sensors(H)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/red(src), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/messenger(src), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(src), slot_in_backpack)
	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Discount Dan Operative"
	W.registered_name = H.real_name
	W.name = "[H.real_name]'s ID Card ([W.assignment])"
	W.access = list(access_maint_tunnels)
	W.icon_state = "discount"
	W.desc = "A flimsy Nanotrasen ID Card. It's clearly a forgery."
	H.equip_to_slot_or_del(W, slot_wear_id)

	spawn(1)

	for(var/datum/objective/O in objustives)
		if(istype(O,/datum/objective/stealcash))
			s = O
	if(s)
		var/obj/item/weapon/card/debit/dansdebit = new
		dansdebit.name = "Discount Dan Debit Card"
		dansdebit.desc = "A flimsy piece of plastic with cheap near field circuitry backed by digits representing funds in a bank account.<br>On the back is a handwritten message:<br><i>Lose this and you're dead. -DD</i>"
		dansdebit.authorized_name = "Discount Dan INC."
		dansdebit.associated_account_number = s.discdanacc.account_number
		H.equip_to_slot_or_del(dansdebit, slot_in_backpack)
	AnnounceArrival(H,W.assignment)