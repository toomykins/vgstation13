/obj/item/weapon/garbagegun
	name = "Discount Dan Brand Decimator"
	desc = "A flimsy plastic toy turned into a semi-dangerous weapon. The original brand has been scratched out, with a Discount Dan sticker placed over it.<br><i>Compatible with all of Discount Dan's vending machines</i>"
	icon = 'icons/obj/gun.dmi'
	icon_state = "blunderbuss"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	item_state = null
	w_class = W_CLASS_MEDIUM
	force = 10
	flags = FPRINT
	siemens_coefficient = 1
	attack_verb = list("strikes", "hits", "bashes")
	var/list/projectiles = list(/obj/item/trash/discountchocolate,/obj/item/trash/danitos,/obj/item/weapon/reagent_containers/food/drinks/groans,/obj/item/weapon/reagent_containers/food/drinks/discount_ramen,/obj/item/weapon/reagent_containers/food/drinks/discount_sauce,/obj/item/trash/plate,/obj/item/weapon/reagent_containers/food/snacks/pie/discount,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo,/obj/item/trash/pietin,/obj/item/trash/soda_cans)
	var/damage_multiplier = 3	//To allow easy modifications to the damage this weapon deals. At a value of 1, a metal rod fired with 10u of fuel deals 16 damage.
	var/shots = 15
	var/max_shots = 15

/obj/item/weapon/garbagegun/examine(mob/user)
	..()
	if(shots)
		to_chat(user, "<span class='info'>It's got [shots]/[max_shots] shots left in it.</span>")

/obj/item/weapon/garbagegun/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	if (istype(target, /obj/item/weapon/storage/backpack ))
		return

	if(istype(target,/obj/machinery/vending/discount) || istype(target,/obj/machinery/vending/groans))
		return

	else if (target.loc == user.loc)
		return

	else if (target.loc == user)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(!shots)
		user.visible_message("*click click*", "<span class='danger'>*click*</span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		return 0
	else
		Fire(target,user,params)

/obj/item/weapon/garbagegun/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)
	if (!shots)
		to_chat(user, "It's all out!")
		return 0

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	var/obj/item/P = pick(projectiles)
	P = new P
	var/speed = rand(20,30)
	speed = speed * damage_multiplier
	var/distance = 6

	user.visible_message("<span class='danger'>[user] fires \the [src] at [target]!</span>","<span class='danger'>You fire the [src] at [target]!</span>")
	log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[P.name]) at [target] [ismob(target) ? "([target:ckey])" : ""] ([target.x],[target.y],[target.z])" )

	P.forceMove(user.loc)
	P.throw_at(target,distance,speed,1,3)
	playsound(user, 'sound/weapons/shotgun.ogg', 50, 1)
	shots--
	user.apply_inertia(get_dir(target, user))