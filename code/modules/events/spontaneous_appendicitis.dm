/datum/event/spontaneous_appendicitis/can_start(var/list/active_with_role)
	if(active_with_role["Medical"] > 1)
		return 50
	return 0

/datum/event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in shuffle(living_mob_list)) if(H.client && H.stat != DEAD)
		if(H.stat == 2 || H.appendicitis_stage > 0)
			continue
		if(H.z == map.zCentcomm) //Don't infect people on the centcomm z-level
			continue
		if(!H.internal_organs_by_name["appendix"])
			continue

		H.give_appendicitis()
		break
