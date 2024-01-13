var/global/datum/controller/bans/ban_master
var/global/list/bancheckqueue[0]

/datum/controller/bans
		//List of all types of bans
	var/list/bantypes = list()
		//list of ckeys and bantypes they got.
	var/list/bancache = list()


/datum/controller/bans/proc/init()
	generatebantypes()
	for(var/datum/ban/shit in bantypes)
		world.log << "[shit] [shit.title]"
	world.log << json_encode(bantypes)

/datum/controller/bans/proc/processQueue()
	for(var/ckiki in bancheckqueue)
		bancheckqueue -= ckiki
		loadbanlist(ckiki)


/datum/controller/bans/proc/loadbanlist(ckey)
	var/list/check = list()
	if(ckey)
		ckey=ckey(ckey)
		check += "ckey"
		check["ckey"] = ckey
	check += "unbanned"

	if(!SSdbcore.Connect())
		world.log << "Database connection failed. Skipping ban loading"
		diary << "Database connection failed. Skipping ban loading"
		return
	var/list/everything = SelectFromDB(list("ckey","bantype","param"),"erro_ban",check)
	bancache += ckey
	bancache[ckey] = list()
	if(everything)
		for(var/list/banoccurance in everything)
			var/datum/ban/typeofban = findbantype(banoccurance["bantype"],banoccurance["param"])
			if(typeofban)
				bancache[ckey] += typeofban

/datum/controller/bans/proc/generatebantypes()
	var/list/all_bans = typesof(/datum/ban)
	if(!all_bans.len)
		to_chat(world,"<span class='danger'>Error setting up bans, no ban datums found</span>")
		return 0
	for(var/btype in all_bans)
		var/datum/ban/bantype = new btype()
		var/list/bantypelist = bantype.gen()
		if(bantypelist)
			for(var/datum/ban/BT in bantypelist)
				bantypes += BT
	return 1

/datum/controller/bans/proc/findbantype(bantype,param)
	for(var/datum/ban/iter in bantypes)
		if("[iter]" == "[bantype]" && "[iter.param]" == "[param]")
			return new iter
	for(var/datum/ban/iter in bantypes)
		if(iter.SQLname == bantype)
			var/datum/ban/typeofban = new iter
			typeofban.param = param
			return typeofban
	return FALSE

/datum/controller/bans/proc/getbanfrombancache(ckey,bantype,var/param=null)
	if(!ckey && !bantype)
		return FALSE
	if(!(ckey in bancache))
		return FALSE
	if(!islist(bancache[ckey]))
		return FALSE
	if(istype(bantype,/datum/ban))
		for(var/datum/ban/typeincache in bancache[ckey])
			if(param)
				if(istype(typeincache,bantype) && typeincache.param == param)
					return typeincache
			else if(istype(typeincache,bantype))
				return typeincache
	return FALSE