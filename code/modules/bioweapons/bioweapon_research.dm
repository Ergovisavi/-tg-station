//////////BIOWEAPONS///////////
// AKA GROW YOUR OWN MONSTER //

/obj/machinery/bioweapons_experimentor
	name = "P.A.R.A.S.O.L. DNA manipulator"
	desc = "a device designed to carefully and precisely smash together flesh and genes to create the perfect organism."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	use_power = 1
	anchored = 1
	density = 1
	occupant_type = /mob/living/simple_animal
	var/list/loaded_traits = list()
	var/obj/item/weapon/disk/bioweapons/loaded_disk
	var/obj/machinery/bioweapons_vat/connected_vat
	var/gene_mod_points = 10

/obj/machinery/bioweapons_experimentor/attack_hand(mob/user)
	if(..())
		return

/obj/machinery/bioweapons_experimentor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/disk/bioweapons) && !loaded_disk)
		if(!user.drop_item())
			return
		I.loc = null
		loaded_disk = I
		interact(user)
		return
	..()

/obj/machinery/bioweapons_experimentor/proc/toggle_open(mob/user)
	if(state_open)
		close_machine()
		return
	open_machine()

/obj/machinery/bioweapons_experimentor/open_machine()
	if(state_open)
		return 0
	..()
	return 1

/obj/machinery/bioweapons_experimentor/close_machine()
	if(!state_open)
		return 0
	..()
	return 1

/obj/machinery/bioweapons_experimentor/proc/ExtractTraits()
	if(!isanimal(occupant))
		return
	var/mob/living/simple_animal/A = occupant
	if(A.mob_traits.len)
		for(var/i in A.mob_traits)
			var/obj/item/weapon/disk/bioweapons/B = new /obj/item/weapon/disk/bioweapons(get_turf(src))
			var/datum/bioweapons_trait/N = new i
			B.trait = N
			B.name = "bioweapons data disk - '[N.perk_name]'"
	var/obj/item/weapon/disk/bioweapons/D = new /obj/item/weapon/disk/bioweapons(get_turf(src))
	D.name = "bioweapons appearance data disk - '[A.name]'"
	var/datum/bioweapons_trait/appearance/form = new /datum/bioweapons_trait/appearance
	D.trait = form
	form.CopyMob(A)
	qdel(A)
	open_machine()

/obj/machinery/bioweapons_experimentor/proc/CheckAgainstTraits(var/unique_string_check)
	for(var/datum/bioweapons_trait/T in loaded_traits)
		if(T.unique_data_string == unique_string_check)
			return 0
	return 1

/obj/machinery/bioweapons_experimentor/interact(mob/user)
	user.set_machine(src)
	if(!user)
		return

	var/datum/browser/popup = new(user, "bioweapons", "P.A.R.A.S.O.L. DNA Manipulator", 450, 600)
	if(!(in_range(src, user) || istype(user, /mob/living/silicon)))
		popup.close()
		return

	var/dat = ""
	dat += "<a href='?src=\ref[src];open=1'>Open</a><a href='?src=\ref[src];close=1'>Close</a>"
	if(connected_vat)
		dat += "<a href='?src=\ref[src];desync_vat=1'>Vat is synced</a>"
	else
		dat += "<a href='?src=\ref[src];sync_vat=1'>Sync vat</a>"
	dat += "<h3>Data</h3>"
	dat += "<div class='statusDisplay'><center>"
	if(loaded_disk)
		if(loaded_disk.trait)
			dat += "<b>[loaded_disk.trait.perk_name]</b><br>Genetic mod value: [loaded_disk.trait.mod_cost]<br>"
			dat += "<font color=#32CD32>[loaded_disk.trait.perk_desc]</font><br>"
			if(CheckAgainstTraits(loaded_disk.trait.unique_data_string) && loaded_disk.trait.mod_cost <= gene_mod_points)
				dat += "<a href='?src=\ref[src];add_trait_to_storage=1'>Add to local storage</a><br>"
			else
				dat += "<b>This genetic trait already exists in local storage, or is outside available resources</b><br>"
		else
			dat += "Disk is empty<br>"
		dat += "<a href='?src=\ref[src];eject_disk=1'>Eject disk</a><br>"
	else
		dat += "No disk found<br>"
	dat += "</center></div>"
	if(occupant)
		dat += "<h3>Analyze organic</h3>"
		dat += "<div class='statusDisplay'>Begin processing of genetic data?<br><a href='?src=\ref[src];process=1'>Extract</a></div>"
	dat += "<h3>Loaded genetic traits - Remaining resources: [gene_mod_points]</h3>"
	if(loaded_traits.len)
		dat += "<div class='statusDisplay'><table>"
		var/genetic_mod_total = 0
		for(var/datum/bioweapons_trait/T in loaded_traits)
			dat +="<tr><td width='260px'>[T.perk_name]</td><td>[T.mod_cost]</td><td width='150px'><a href='?src=\ref[src];delete_specific_trait=1;delete_specific_trait_ref=\ref[T]'>Delete</a></td></tr>"
			genetic_mod_total += T.mod_cost
		dat += "<td>Total genetic modification value:</td><td><b>[genetic_mod_total]</b></td>"
		dat += "<td><a href='?src=\ref[src];wipe_local_storage=1'>Delete local storage</a></td></tr></table></div>"
	if(connected_vat)
		dat += "<h3>Modification Analysis</h3>"
		dat += "<div class='statusDisplay'><table>"
		if(connected_vat.contained_bioweapon)
			dat += "<tr><td>Intelligence</td><td>[connected_vat.contained_bioweapon.intellect]</td></tr>"
			dat += "<tr><td>Health</td><td>[connected_vat.contained_bioweapon.maxHealth]</td></tr>"
			dat += "<tr><td>Minimum muscule force output</td><td>[connected_vat.contained_bioweapon.melee_damage_lower]</td></tr>"
			dat += "<tr><td>Maximum muscule force output</td><td>[connected_vat.contained_bioweapon.melee_damage_upper]</td></tr>"
			dat += "<tr><td>Armor penetration</td><td>[connected_vat.contained_bioweapon.armour_penetration]</td></tr>"
			dat += "<tr><td>Mobility rate</td><td>[connected_vat.contained_bioweapon.speed]</td></tr>"
			dat += "<tr><td>Containment circumvention hazard level</td><td>[connected_vat.contained_bioweapon.environment_smash]</td></tr>"
		dat +="</table></div>"
		if(loaded_traits.len)
			dat +="<a href='?src=\ref[src];apply_traits_to_bioweapon=1'>Apply gene mods to bioweapon</a>"
		if(connected_vat.contained_bioweapon)
			dat +="<a href='?src=\ref[src];generate_bioweapon=1'>Generate bioweapon</a>"
		else
			dat += "Vat does not contain a bioweapon prototype"
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/bioweapons_experimentor/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)
	if(href_list["process"] && occupant)
		ExtractTraits()
	else if(href_list["open"])
		open_machine()
	else if(href_list["close"])
		close_machine()
	else if(href_list["eject_disk"] && loaded_disk)
		loaded_disk.forceMove(get_turf(src))
		loaded_disk = null
	else if(href_list["add_trait_to_storage"] && loaded_disk)
		if(loaded_disk.trait)
			if(CheckAgainstTraits(loaded_disk.trait) && loaded_disk.trait.mod_cost <= gene_mod_points)
				var/datum/bioweapons_trait/T = loaded_disk.trait.CopyTrait()
				loaded_traits += T
				gene_mod_points -= loaded_disk.trait.mod_cost
	else if(href_list["wipe_local_storage"])
		loaded_traits.Cut()
		gene_mod_points = 10
	else if(href_list["delete_specific_trait"])
		var/datum/bioweapons_trait/B = locate(href_list["delete_specific_trait_ref"])
		loaded_traits -= B
		gene_mod_points += B.mod_cost
	else if(href_list["sync_vat"] && !connected_vat)
		for(var/i in view(1,src))
			if(istype(i, /obj/machinery/bioweapons_vat))
				connected_vat = i
				break
	else if(href_list["desync_vat"] && connected_vat)
		connected_vat = null
	else if(href_list["apply_traits_to_bioweapon"] && connected_vat)
		if(connected_vat.contained_bioweapon)
			var/list/multipliers = list()
			for(var/datum/bioweapons_trait/W in loaded_traits)
				if(W.multiplier)//Multipliers are applied after static bonuses
					multipliers += W
					continue
				W.ApplyTrait(connected_vat.contained_bioweapon)
			if(multipliers.len)
				for(var/datum/bioweapons_trait/T in multipliers)
					T.ApplyTrait(connected_vat.contained_bioweapon)
	else if(href_list["generate_bioweapon"] && connected_vat.contained_bioweapon)
		connected_vat.ProduceLocalBioweapon()
	interact(usr)

/obj/machinery/bioweapons_vat
	name = "synthetic organism vat"
	desc = "This pod contains a primordial soup of various synthetic organic materials, ready to produce new forms of life."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	use_power = 1
	anchored = 1
	density = 1
	var/mob/living/simple_animal/hostile/bioweapon/contained_bioweapon

/obj/machinery/bioweapons_vat/New()
	..()
	GenerateNewBioweapon()

/obj/machinery/bioweapons_vat/proc/ProduceLocalBioweapon()
	if(contained_bioweapon)
		contained_bioweapon.forceMove(loc)
		addtimer(src, "GenerateNewBioweapon", 600)

/obj/machinery/bioweapons_vat/proc/GenerateNewBioweapon()
	var/mob/living/simple_animal/hostile/bioweapon/B = new /mob/living/simple_animal/hostile/bioweapon(src)
	contained_bioweapon = B


////BIOWEAPONS SIMULATION////
/obj/machinery/computer/camera_advanced/bioweapons
	name = "bioweapon control station"
	desc = "BIOWEAPONS CAMERA"
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	networks = list()
	jump_action = new /datum/action/innate/sync_bioweapon_view
	var/mob/living/simple_animal/hostile/bioweapon/synced_bioweapon
	var/datum/action/innate/direct_bioweapon/direct_action = new

/mob/camera/aiEye/remote/bioweapons
	visible_icon = 1
	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera_target"
	ignore_cameranet = TRUE
	acceleration = 0
	var/mob/living/simple_animal/hostile/bioweapon/linked_bioweapon

/mob/camera/aiEye/remote/bioweapons/setLoc(T)
	if(linked_bioweapon)
		if(T in range(7,linked_bioweapon))
			return ..()

/mob/camera/aiEye/remote/bioweapons/ClickOn( atom/A, params )
	setLoc(A)
	for(var/i in eye_user.actions)
		if(istype(i, /datum/action/innate/direct_bioweapon))
			var/datum/action/innate/direct_bioweapon/D = i
			D.Activate(A)
			break

/mob/camera/aiEye/remote/bioweapons/CtrlClickOn(A)
	setLoc(A)
	if(linked_bioweapon)
		linked_bioweapon.LoseTarget()
		linked_bioweapon.AIStatus = AI_OFF
		walk_to(linked_bioweapon,loc,0,linked_bioweapon.move_to_delay)
		PoolOrNew(/obj/effect/overlay/temp/revenant, get_turf(A))


/obj/machinery/computer/camera_advanced/bioweapons/attack_hand(mob/user)
	if(current_user)
		user << "The console is already in use!"
		return
	if(!ishuman(user))
		return
	if(..())
		return
	var/mob/living/carbon/L = user
	if(!eyeobj)
		CreateEye()
	var/mob/camera/aiEye/remote/bioweapons/B = eyeobj
	if(!synced_bioweapon)
		var/list/available_bioweapons = list()
		for(var/i in living_mob_list)
			if(istype(i, /mob/living/simple_animal/hostile/bioweapon))
				var/mob/living/simple_animal/hostile/bioweapon/H = i
				if(!H.ckey && !H.eye_synced_to)
					available_bioweapons += H
		if(!available_bioweapons.len)
			user << "No units available to sync with, or all available units have been terminated"
			return
		var/choice = pick(available_bioweapons)
		if(choice)
			synced_bioweapon = choice
	B.setLoc(synced_bioweapon.loc)
	B.linked_bioweapon = synced_bioweapon
	synced_bioweapon.eye_synced_to = B
	synced_bioweapon.wander = 0
	give_eye_control(L)


/obj/machinery/computer/camera_advanced/bioweapons/CreateEye()
	eyeobj = new /mob/camera/aiEye/remote/bioweapons(loc)
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/bioweapons/give_eye_control(mob/user)
	..()
	user.reset_perspective(synced_bioweapon)

/obj/machinery/computer/camera_advanced/bioweapons/GrantActions(mob/living/carbon/user)
	..()
	if(synced_bioweapon)
		direct_action.target = user
		direct_action.Grant(user)
		for(var/i in synced_bioweapon.actions)
			if(istype(i, /datum/action/innate/bioweapon))
				var/datum/action/innate/bioweapon/B = i
				B.Grant(user)

/obj/machinery/computer/camera_advanced/bioweapons/on_unset_machine(mob/M)
	..()
	direct_action.Remove(M)
	if(synced_bioweapon)
		synced_bioweapon.eye_synced_to = null
		synced_bioweapon.wander = 1
		synced_bioweapon.AIStatus = AI_ON
		walk(synced_bioweapon,0)
		for(var/i in M.actions)
			if(istype(i, /datum/action/innate/bioweapon))
				var/datum/action/innate/bioweapon/B = i
				B.Grant(synced_bioweapon)
		if(synced_bioweapon.target_image && M.client)
			M.client.images -= synced_bioweapon.target_image

/datum/action/innate/sync_bioweapon_view
	name = "Sync to Bioweapon"
	button_icon_state = "camera_jump"

/datum/action/innate/sync_bioweapon_view/Activate()
	if(!target || !ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/mob/camera/aiEye/remote/bioweapons/remote_eye = H.remote_control
	var/list/available_bioweapons = list()
	for(var/i in living_mob_list)
		if(istype(i, /mob/living/simple_animal/hostile/bioweapon))
			available_bioweapons += i
	var/choice = input("Sync with which bioweapon?", "Bioweapons") as null|anything in available_bioweapons
	if(choice)
		var/obj/machinery/computer/camera_advanced/bioweapons/B = remote_eye.origin
		for(var/i in H.actions)
			if(istype(i, /datum/action/innate/bioweapon))
				var/datum/action/innate/bioweapon/A = i
				A.Grant(B.synced_bioweapon)
		if(B.synced_bioweapon.target_image && H.client)
			H.client.images -= B.synced_bioweapon.target_image
		B.synced_bioweapon = choice
		remote_eye.linked_bioweapon = choice
		remote_eye.linked_bioweapon.eye_synced_to = remote_eye
		for(var/i in B.synced_bioweapon.actions)
			if(istype(i, /datum/action/innate/bioweapon))
				var/datum/action/innate/bioweapon/A = i
				A.Grant(H)
		var/T = get_turf(choice)
		remote_eye.forceMove(T)
		remote_eye.setLoc(T)
		H.reset_perspective(choice)

/datum/action/innate/direct_bioweapon
	name = "Direct Bioweapon"
	var/env_smash_cooldown = 0

/datum/action/innate/direct_bioweapon/Activate(var/atom/A)
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/mob/camera/aiEye/remote/bioweapons/remote_eye = C.remote_control
	if(remote_eye.linked_bioweapon)
		var/mob/living/simple_animal/hostile/bioweapon/B = remote_eye.linked_bioweapon
		B.AIStatus = AI_IDLE
		if(isliving(A) && B != A)
			B.GiveTarget(A)
			PoolOrNew(/obj/effect/overlay/temp/revenant, get_turf(A))
			walk_to(B,A,0,B.move_to_delay)
			return
		if((B.Adjacent(remote_eye) || B == A) && world.time > env_smash_cooldown)
			env_smash_cooldown = world.time + 15
			B.DestroySurroundings()
			B.Move(remote_eye.loc)
			return
		walk_to(B,remote_eye.loc,0,B.move_to_delay)

////END BIOWEAPONS SIMULATION////

/obj/item/weapon/disk/bioweapons
	name = "bioweapons disk"
	desc = "A disk for storing non-human biological data."
	icon_state = "datadisk2"
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/datum/bioweapons_trait/trait

/datum/bioweapons_trait
	var/perk_name = "This is a debug name! Honk!"
	var/perk_desc = "This is a debug string! PANIC!"
	var/mod_cost = 2
	var/activation = ""
	var/unique_data_string = "basic" // No two traits with the same string can be applied
	var/mob/living/simple_animal/hostile/bioweapon/our_mob
	var/multiplier = FALSE //Multipliers are applied AFTER static bonuses
/*	var/trait_status_flags = CANPUSH
	var/list/trait_speak = list()
	var/trait_response_help   = "pokes"
	var/trait_response_disarm = "shoves"
	var/trait_response_harm   = "hits"
	var/trait_harm_intent_damage = 3
	var/trait_force_threshold = 0
	var/trait_minbodytemp = 250
	var/trait_maxbodytemp = 350
	var/list/trait_atmos_requirements = list()
	var/trait_unsuitable_atmos_damage
	var/trait_obj_damage = 0
	var/trait_attacktext = "attacks"
	var/trait_attack_sound = null
	var/trait_friendly = "nuzzles"
	var/trait_environment_smash = 0
	var/trait_speed = 1
	var/trait_flying = 0
	var/trait_sentience_type = SENTIENCE_ORGANIC
	var/trait_deathmessage = ""
	var/trait_death_sound = null*/

/datum/bioweapons_trait/proc/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(target.stat)
		return 0
	var/datum/bioweapons_trait/T = CopyTrait()
	target.added_traits += T
	T.our_mob = target
	return 1

/datum/bioweapons_trait/proc/ActivateTrait(var/atom/target, var/method = "passive")
	if(method == activation)
		return 1

/datum/bioweapons_trait/proc/CopyTrait()
	var/datum/bioweapons_trait/T = new type
	return T

////MISC BIOWEAPON TRAITS////
/datum/bioweapons_trait/appearance
	perk_name = "appearance"
	unique_data_string = "appearance"
	mod_cost = 5 //Expensive so you don't turn what appears to be a corgi into a murder machine
	var/trait_name
	var/trait_icon
	var/trait_icon_living
	var/trait_icon_dead
	var/trait_mob_size
	var/trait_del_on_death

/datum/bioweapons_trait/appearance/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(..(target))
		target.name = trait_name
		target.icon = trait_icon
		target.icon_living = trait_icon_living
		target.icon_dead = trait_icon_dead
		target.mob_size = trait_mob_size

/datum/bioweapons_trait/appearance/proc/CopyMob(var/mob/living/simple_animal/target)
	trait_name = target.name
	trait_icon = target.icon
	trait_icon_living = target.icon_living
	trait_icon_dead = target.icon_dead
	trait_mob_size = target.mob_size
	trait_del_on_death = target.del_on_death

/datum/bioweapons_trait/appearance/CopyTrait()
	var/datum/bioweapons_trait/appearance/T = new type
	T.trait_name = trait_name
	T.trait_icon = trait_icon
	T.trait_icon_living = trait_name
	T.trait_icon_dead = trait_name
	T.trait_mob_size = trait_name
	T.trait_del_on_death = trait_name
	return T

/datum/bioweapons_trait/wall_smash
	perk_name = "Bludgeoning carapace"
	perk_desc = "Allows the body to smash through its environment without damaging its body by significantly hardening appendages."
	unique_data_string = "wall_smash"
	var/trait_environment_smash = 2

/datum/bioweapons_trait/wall_smash/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(..(target))
		target.environment_smash = trait_environment_smash

/datum/bioweapons_trait/intelligence
	perk_name = "Sapience"
	perk_desc = "Grants the mind an intellect capable of self actualization when subjected to a bioweapon activation frequency"
	activation = "bioweapon_device"
	unique_data_string = "intelligence"
	var/trait_intellect = "sapient"

/datum/bioweapons_trait/intelligence/ActivateTrait(atom/target, method)
	if(..())
		our_mob.intellect = trait_intellect
		notify_ghosts("A bioweapon has been made sapient in [get_area(src)]!", enter_link = "<a href=?src=\ref[src];ghostjoin=1>(Click to enter)</a>", source = our_mob, action = NOTIFY_ATTACK)

/datum/bioweapons_trait/speed
	perk_name = "Celerity"
	perk_desc = "Grants the mind an intellect capable of self actualization when subjected to a bioweapon activation frequency"
	unique_data_string = "speed"
	var/trait_speed = 1

/datum/bioweapons_trait/speed/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(..())
		target.move_to_delay -= trait_speed
		target.speed -= trait_speed

/datum/bioweapons_trait/electricity_protection
	perk_name = "Grounding"
	perk_desc = "Prevents electricity from harming the bioweapon by grounding the body"
	unique_data_string = "electric_defense"

////OFFENSIVE BIOWEAPON TRAITS////
/datum/bioweapons_trait/damage
	perk_name = "Musculature sculpting"
	perk_desc = "Refines the placement of muscles to increase minimum and maximum levels of force generated"
	unique_data_string = "melee_damage_minor"
	var/trait_melee_damage_lower_add = 5
	var/trait_melee_damage_upper_add = 5

/datum/bioweapons_trait/damage/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(..(target))
		target.melee_damage_lower += trait_melee_damage_lower_add
		target.melee_damage_upper += trait_melee_damage_upper_add

/datum/bioweapons_trait/damage/major
	perk_name = "Musculature fortification"
	perk_desc = "Greatly enhances the minimum and maximum levels of force generated by muscles in the body by making the muscle mass more dense"
	unique_data_string = "melee_damage_major"
	mod_cost = 4
	trait_melee_damage_lower_add = 10
	trait_melee_damage_upper_add = 10

/datum/bioweapons_trait/damage/damage_type
	perk_name = "Caustic skin"
	perk_desc = "Trickle's the body's skin in a sheet of acid, allowing the body to use it as a caustic weapon when striking opponents and slightly randomizing the amount of damage dealt"
	unique_data_string = "damage_type"
	var/trait_damage_type = BURN
	trait_melee_damage_lower_add = -5
	trait_melee_damage_upper_add = 5

/datum/bioweapons_trait/damage/damage_type/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	..()
	target.melee_damage_type = trait_damage_type

/datum/bioweapons_trait/damage/damage_type/stamina
	perk_name = "Bio-electric pincers"
	perk_desc = "Causes blows to nonharmfully subdue victims with electric shocks, created via a series of organs placed in the limbs. Powerful, but restricts lethality"
	trait_damage_type = STAMINA
	trait_melee_damage_lower_add = 10
	trait_melee_damage_upper_add = 10

/datum/bioweapons_trait/damage/damage_type/toxin
	perk_name = "Venomous stingers"
	perk_desc = "Causes blows to inject a deadly toxin into the body. Toxicity is hard to treat, but these stingers are overall weaker in terms of physical trauma than standard blows."
	trait_damage_type = TOX
	trait_melee_damage_lower_add = -5
	trait_melee_damage_upper_add = -5

/datum/bioweapons_trait/venom_glands
	perk_name = "Venom glands"
	perk_desc = "Adds venomous glands to the body that inject into the victim with every strike"
	unique_data_string = "reagent_blows"
	activation = "attack"
	var/trait_reagent = "toxin"
	var/trait_reagent_amount = 5
	var/trait_reagent_cap = 10

/datum/bioweapons_trait/venom_glands/ActivateTrait(atom/target, method)
	if(..())
		if(isliving(target))
			var/mob/living/L = target
			if(L.reagents)
				var/current_reagent_amount = L.reagents.get_reagent_amount(trait_reagent)
				if(current_reagent_amount >= trait_reagent_cap)
					return
				else
					L.reagents.add_reagent(trait_reagent, min((trait_reagent_cap - current_reagent_amount),trait_reagent_amount))//Clamp this value so we don't have infinite reagents being injected

/datum/bioweapons_trait/venom_glands/carpotoxin
	perk_name = "Carpotoxin glands"
	perk_desc = "Adds several glands that produce carpotoxin, injecting into the victim with every strike"
	trait_reagent = "carpotoxin"

/datum/bioweapons_trait/disarming_strikes
	perk_name = "Disarming behavior"
	perk_desc = "Ingrains a behavior into the mind that teaches the body to disarm opponents before moving in for the kill."
	unique_data_string = "disarming"
	activation = "attack"

/datum/bioweapons_trait/disarming_strikes/ActivateTrait(atom/target, method)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.get_active_held_item() && C.drop_item())
			playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/datum/bioweapons_trait/projectile
	perk_name = "Sinewy wire"
	perk_desc = "Grants the ability to throw a net of sinew to slow down victims"
	unique_data_string = "projectile"
	var/trait_projectiletype = /obj/item/projectile/sinew

/datum/bioweapons_trait/projectile/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(..())
		target.ranged = 1
		target.projectiletype = trait_projectiletype

/obj/item/projectile/sinew
	name = "sinew"
	damage = 0
	nodamage = 1
	range = 7

/obj/item/projectile/sinew/on_hit(atom/target, blocked = 0)
	if(isliving(target))
		var/mob/living/L = target
		L.apply_status_effect(/datum/status_effect/sinew_slowdown)

/datum/status_effect/sinew_slowdown
	id = "sinew_slowdown"
	duration = 5
	var/speed_slowdown = 2
	var/speed_saved = 0
	var/move_to_delay_saved = 0
	var/mobtype = "human"

/datum/status_effect/sinew_slowdown/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.dna.species)
			speed_saved = H.dna.species.speedmod
			H.dna.species.speedmod += speed_slowdown
			return
	if(isanimal(owner))
		var/mob/living/simple_animal/A = owner
		mobtype = "animal"
		speed_saved = A.speed
		A.speed += speed_slowdown
		if(ishostile(owner))
			var/mob/living/simple_animal/hostile/S = owner
			mobtype = "hostile"
			move_to_delay_saved = S.move_to_delay
			S.move_to_delay += speed_slowdown
			return
	if(isrobot(owner))
		var/mob/living/silicon/robot/R = owner
		mobtype = "robot"
		speed_saved = R.speed
		R.speed += speed_slowdown
		return

/datum/status_effect/sinew_slowdown/on_remove()
	switch(mobtype)
		if("human")
			var/mob/living/carbon/human/H = owner
			if(H.dna.species)
				H.dna.species.speedmod = speed_saved
				return
		if("animal")
			var/mob/living/simple_animal/A = owner
			A.speed = speed_saved
		if("hostile")
			var/mob/living/simple_animal/hostile/H = owner
			H.move_to_delay = move_to_delay_saved
			H.speed = speed_saved
		if("robot")
			var/mob/living/silicon/robot/R = owner
			R.speed = speed_saved

/datum/bioweapons_trait/projectile/tongue_lash
	perk_name = "Tongue paramusculature"
	perk_desc = "Elongates and strengthens the tongue, making it an effective means of pulling in victims"
	unique_data_string = "projectile"
	trait_projectiletype = /obj/item/projectile/hook/tongue

/obj/item/projectile/hook/tongue
	name = "tongue"
	damage = 0
	damage_type = BRUTE
	hitsound = 'sound/effects/splat.ogg'
	weaken = 0
	nodamage = 1
	range = 7

/obj/item/projectile/hook/tongue/on_hit(atom/target)
	..()
	if(isliving(target))
		var/mob/living/L = target
		L.apply_status_effect(/datum/status_effect/sinew_slowdown)


////DEFENSIVE BIOWEAPON TRAITS/////
/datum/bioweapons_trait/health_mod
	perk_name = "Redundant physiology"
	perk_desc = "Adds redundant biological systems to make the body more resilient to catastrophic failure from physical trauma"
	unique_data_string = "health_bonus_minor"
	var/trait_health_add = 25

/datum/bioweapons_trait/health_mod/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(..(target))
		target.health += trait_health_add
		target.maxHealth += trait_health_add

/datum/bioweapons_trait/health_mod/major
	perk_name = "Heterosis"
	perk_desc = "Hybridizes several genomes to grant greater resilience to catastrophic failure from physical trauma"
	mod_cost = 3
	trait_health_add = 50

/datum/bioweapons_trait/defense_specialization
	perk_name = "Defense specialization"
	perk_desc = "Fortifies the body with significantly denser dermal armor but the changes make physical strikes harder to perform, weakening them"
	unique_data_string = "defense_specialization"
	multiplier = TRUE
	var/defense_multiplier = 0.5
	var/offense_multiplier = 0.5

/datum/bioweapons_trait/defense_specialization/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(..(target))
		for(var/i in target.damage_coeff)
			target.damage_coeff[i] *= defense_multiplier
		target.melee_damage_lower *= offense_multiplier
		target.melee_damage_upper *= offense_multiplier

/datum/bioweapons_trait/defense_tradeoff
	perk_name = "Bone reinforcement"
	perk_desc = "Reduces the effectiveness of brute force trauma on the body by developing stronger bones, but makes it more vulnerable to burns"
	unique_data_string = "brute_armor_tradeoff"
	multiplier = TRUE
	var/brute_mod = 0.75
	var/burn_mod = 1.33

/datum/bioweapons_trait/defense_tradeoff/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(..(target))
		for(var/i in target.damage_coeff)
			if(i == BRUTE)
				target.damage_coeff[BRUTE] *= brute_mod
				continue
			if(i == BURN)
				target.damage_coeff[BURN] *= burn_mod
				continue

/datum/bioweapons_trait/defense_tradeoff/burn
	perk_name = "Ablative dermis"
	perk_desc = "Reduces the effectiveness of heat and burns on the body with a coating of ablative skin, but makes it more vulnerable to brute force trauma"
	unique_data_string = "burn_armor_tradeoff"
	brute_mod = 1.33
	burn_mod = 0.75

/datum/bioweapons_trait/passive_regeneration
	perk_name = "regenerative flesh"
	perk_desc = "Allows for the body's flesh to repair itself automatically by distributing new organs throughout the body, but this is an imperfect function and cannot restore the body all at once."
	unique_data_string = "passive_regeneration"
	activation = "passive"
	var/cooldown = 50
	var/heal_strength = 1

/datum/bioweapons_trait/passive_regeneration/ActivateTrait(target, method)
	if(..() && !our_mob.stat && our_mob.health < our_mob.maxHealth)
		if(world.time < our_mob.last_damage_event + cooldown)// No in combat regeneration
			return
		our_mob.health = round(our_mob.health)
		var/quadrant_one = round(our_mob.maxHealth * 0.25)
		if(our_mob.health < quadrant_one)
			HealMob(heal_strength)
			return
		if(our_mob.health == quadrant_one)
			return
		var/quadrant_two = round(our_mob.maxHealth * 0.50)
		if(our_mob.health < quadrant_two)
			HealMob(heal_strength)
			return
		if(our_mob.health == quadrant_two)
			return
		var/quadrant_three = round(our_mob.maxHealth * 0.75)
		if(our_mob.health < quadrant_three)
			HealMob(heal_strength)
			return
		if(our_mob.health == quadrant_three)
			return
		HealMob(heal_strength)

/datum/bioweapons_trait/passive_regeneration/proc/HealMob(var/amount = 1)
	our_mob.heal_overall_damage(amount)
	PoolOrNew(/obj/effect/overlay/temp/heal, list(get_turf(our_mob), "#80F5FF"))

/datum/bioweapons_trait/environment_adaptation
	perk_name = "Poly-environment adaptation"
	perk_desc = "Allows the body to adapt to any environmental conditions through a mix of ingrained mental behaviors and physical changes."
	unique_data_string = "environment_adaptation"
	var/trait_minbodytemp = 0
	var/trait_maxbodytemp = 5000
	var/trait_atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

/datum/bioweapons_trait/environment_adaptation/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(..())
		target.minbodytemp = trait_minbodytemp
		target.maxbodytemp = trait_maxbodytemp
		target.atmos_requirements = trait_atmos_requirements


////ABILITY BIOWEAPON TRAITS/////

/datum/bioweapons_trait/ability
	activation = "ability"
	var/action_type = null

/datum/bioweapons_trait/ability/ActivateTrait()
	if(..())
		for(var/i in our_mob.actions)
			if(istype(i, action_type))
				var/datum/action/innate/A = i
				A.Activate()

/datum/bioweapons_trait/ability/ApplyTrait(var/mob/living/simple_animal/hostile/bioweapon/target)
	if(..())
		var/datum/action/A = new action_type()
		A.target = target
		A.Grant(target)

/datum/bioweapons_trait/ability/shockwave
	perk_name = "Kinetic shockwave"
	perk_desc = "Gives the body the ability to generate a nearby burst of energy, hurling away nearby objects and foes"
	unique_data_string = "shockwave"
	action_type = /datum/action/innate/bioweapon/bioweapon_shockwave

/datum/action/innate/bioweapon/bioweapon_shockwave
	name = "Shockwave"

/datum/action/innate/bioweapon/bioweapon_shockwave/Activate()
	if(isliving(target))
		var/mob/living/L = target
		if(!L.stat && isturf(L.loc))
			var/obj/effect/overlay/temp/decoy/D = PoolOrNew(/obj/effect/overlay/temp/decoy, list(target.loc,target))
			animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 5)
			for(var/atom/movable/A in view(L, 2))
				if(A == target || A.anchored)
					continue
				if(isliving(A))
					var/mob/living/M = A
					M.Weaken(1)
				var/throwtarget = get_edge_target_turf(target, get_dir(target, get_step_away(A, target)))
				A.throw_at_fast(throwtarget,6,1)

/datum/bioweapons_trait/ability/cocoon
	perk_name = "Sinewy cocoon"
	perk_desc = "Grants the ability to quickly wrap victims in a cocoon that hardens after creation, entrapping the target but also preventing harm to them"
	unique_data_string = "cocoon"
	action_type = /datum/action/innate/bioweapon/cocoon

/datum/action/innate/bioweapon/cocoon
	name = "Cocoon"

/datum/action/innate/bioweapon/cocoon/Activate()
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/H = target
		if(!H.stat && isturf(H.loc))
			var/obj/effect/overlay/temp/decoy/D = PoolOrNew(/obj/effect/overlay/temp/decoy, list(H.loc,H))
			animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 5)
			var/mob/living/chosen_target = null
			var/dist_check = 8
			for(var/atom/A in view(H, 7))
				if(A == target)
					continue
				if(isliving(A))
					var/mob/living/L = A
					if(L == H.target)
						chosen_target = L
						break
					var/distance = get_dist(L,H)
					if(distance < dist_check)//Just pick whatever's closest if we don't have an actual target
						dist_check = distance
						chosen_target = L
			if(chosen_target)
				chosen_target.apply_status_effect(/datum/status_effect/cocoon)

/datum/status_effect/cocoon
	id = "cocooned"
	duration = 4

/datum/status_effect/cocoon/on_apply()
	var/obj/structure/closet/sinew_cocoon/S = new /obj/structure/closet/sinew_cocoon(get_turf(owner))
	owner.forceMove(S)
	if(ishostile(owner))
		var/mob/living/simple_animal/hostile/H = owner
		H.AIStatus = AI_OFF
	owner.notransform = 1
	owner.status_flags |= GODMODE

/datum/status_effect/cocoon/on_remove()
	owner.notransform = 0
	owner.status_flags &= ~GODMODE
	if(ishostile(owner))
		var/mob/living/simple_animal/hostile/H = owner
		H.AIStatus = AI_ON
	if(istype(owner.loc, /obj/structure/closet/sinew_cocoon))
		var/obj/structure/closet/sinew_cocoon/S = owner.loc
		S.dump_contents()
		S.Destroy()

/obj/structure/closet/sinew_cocoon
	health = 5
	welded = TRUE

/obj/structure/closet/sinew_cocoon/Destroy()
	for(var/mob/living/L in src)
		L.remove_status_effect("cocooned")
	..()

/datum/bioweapons_trait/ability/grapple
	perk_name = "Grappling"
	perk_desc = "Grants the ability to temporarily immobilize victims by grappling them with intense force. Very effective against foes without much intelligence."
	unique_data_string = "grapple"
	action_type = /datum/action/innate/bioweapon/grapple

/datum/action/innate/bioweapon/grapple
	name = "Grapple"

/datum/action/innate/bioweapon/grapple/Activate()
	if(istype(target, /mob/living/simple_animal/hostile/bioweapon))
		var/mob/living/simple_animal/hostile/bioweapon/H = target
		if(!H.stat && isturf(H.loc) && isliving(H.target) && H.Adjacent(H.target))
			var/mob/living/L = H.target
			H.face_atom(L)
			H.pulling = L
			H.grab_state = 0 //Can never go more than aggressive
			L.grabbedby(H,1)
			H.speed += 2
			var/obj/effect/overlay/temp/decoy/D = PoolOrNew(/obj/effect/overlay/temp/decoy, list(H.loc,H))
			animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 5)
			H.grab_timer = world.time
			if(ishostile(L))
				var/mob/living/simple_animal/hostile/grapple_hostile = L
				grapple_hostile.AIStatus = AI_OFF
			return




////The bioweapon mob itself////
/mob/living/simple_animal/hostile/bioweapon
	name = "bioweapons organism"
	unique_name = 1
	desc = "A being of flesh and bone custom designed by the finest in nanotrasen medical technology."
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	icon_state = "bubblegum"
	icon_living = "bubblegum"
	icon_dead = "carp_dead"
	icon_gib = "carp_gib"
	pixel_x = -32
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list()
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speed = 2
	maxHealth = 100
	health = 100
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	stat_attack = 1
	attacktext = "claws"
	attack_sound = 'sound/weapons/bite.ogg'
	a_intent = "grab"
	speak_emote = list("gnashes")
	faction = list("hostile")
	gold_core_spawnable = 0
	AIStatus = AI_OFF
	var/list/added_traits = list()
	var/last_damage_event = 0
	var/intellect = "feral"
	var/mob/camera/aiEye/remote/bioweapons/eye_synced_to
	var/image/target_image
	var/grab_timer = 0

/mob/living/simple_animal/hostile/bioweapon/New()
	..()
	verbs -= /mob/living/verb/pulled

/mob/living/simple_animal/hostile/bioweapon/CtrlClickOn(atom/A)
	if(isliving(A))
		for(var/i in actions)
			if(istype(i, /datum/action/innate/bioweapon/grapple))
				var/datum/action/innate/bioweapon/grapple/G = i
				target = A
				G.Activate()
			break

/mob/living/simple_animal/hostile/bioweapon/GiveTarget()
	..()
	if(target && eye_synced_to)
		if(eye_synced_to.eye_user.client)
			eye_synced_to.eye_user.client.images -= target_image
			target_image = image('icons/effects/progessbar.dmi', target, "prog_bar_0")
			eye_synced_to.eye_user.client.images += target_image

/mob/living/simple_animal/hostile/bioweapon/attack_ghost(mob/dead/observer/user)
	..()
	if(intellect == "sapient" && !ckey)
		var/be_helper = alert("Become a Bioweapon? (Warning, You can no longer be cloned!)",,"Yes","No")
		if(be_helper == "No")
			return
		ckey = user.key

/mob/living/simple_animal/hostile/bioweapon/Topic(href, href_list)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/mob/living/simple_animal/hostile/bioweapon/Life()
	..()
	for(var/datum/bioweapons_trait/T in added_traits)
		T.ActivateTrait(src,"passive")
	if(!eye_synced_to && target && !ckey)
		for(var/datum/bioweapons_trait/T in added_traits)
			T.ActivateTrait(src,"ability")
	if(world.time > (grab_timer + 50) && pulling)//No infinite grabs
		if(ishostile(pulling))
			var/mob/living/simple_animal/hostile/H = pulling
			H.AIStatus = AI_ON
		stop_pulling()

/mob/living/simple_animal/hostile/bioweapon/adjustHealth()
	..()
	last_damage_event = world.time
/*	for(var/datum/bioweapons_trait/T in added_traits)
		T.ActivateTrait(src,"damage")*/

/mob/living/simple_animal/hostile/bioweapon/AttackingTarget()
	..()
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/H = target
		if(prob(40) && !H.retreat_distance)
			H.apply_status_effect(/datum/status_effect/bioweapon_fear)
	for(var/datum/bioweapons_trait/T in added_traits)
		T.ActivateTrait(target,"attack")

/mob/living/simple_animal/hostile/bioweapon/stop_pulling()
	if(ishostile(pulling))
		var/mob/living/simple_animal/hostile/H = pulling
		H.AIStatus = AI_ON
		speed -= 2
	..()

/mob/living/simple_animal/hostile/bioweapon/electrocute_act()
	for(var/i in added_traits)
		if(istype(i, /datum/bioweapons_trait/electricity_protection))
			return
	..()

/mob/living/simple_animal/pet/dog/corgi/bioweapon_debug //debug mob for getting lots of traits on disk
	mob_traits = list(/datum/bioweapons_trait/defense_specialization, /datum/bioweapons_trait/damage, /datum/bioweapons_trait/ability/shockwave,
					/datum/bioweapons_trait/environment_adaptation, /datum/bioweapons_trait/passive_regeneration, /datum/bioweapons_trait/defense_tradeoff/burn,
					 /datum/bioweapons_trait/defense_tradeoff, /datum/bioweapons_trait/health_mod/major, /datum/bioweapons_trait/health_mod, /datum/bioweapons_trait/disarming_strikes,
					 /datum/bioweapons_trait/venom_glands/carpotoxin, /datum/bioweapons_trait/venom_glands, /datum/bioweapons_trait/damage/damage_type/toxin,
					 /datum/bioweapons_trait/damage/damage_type/stamina, /datum/bioweapons_trait/damage/damage_type, /datum/bioweapons_trait/damage/major, /datum/bioweapons_trait/projectile,
					 /datum/bioweapons_trait/projectile/tongue_lash, /datum/bioweapons_trait/ability/cocoon, /datum/bioweapons_trait/ability/grapple)

/datum/status_effect/bioweapon_fear //This exists to make bioweapon vs other simple mob fights a bit more visually dynamic
	id = "fear"
	duration = 4
	var/mob_retreat_distance = 0
	var/mob_minimum_distance = 0

/datum/status_effect/bioweapon_fear/on_apply()
	if(ishostile(owner))
		var/mob/living/simple_animal/hostile/H = owner
		mob_retreat_distance = H.retreat_distance
		mob_minimum_distance = H.minimum_distance
		H.retreat_distance = 5
		H.minimum_distance = 5

/datum/status_effect/bioweapon_fear/on_remove()
	if(ishostile(owner))
		var/mob/living/simple_animal/hostile/H = owner
		H.retreat_distance = mob_retreat_distance
		H.minimum_distance = mob_minimum_distance


//////bioweapon combat simulation mobs //////
/mob/living/simple_animal/hostile/bioweapons_simulation
	faction = list("bioweapon_simulation")
	check_friendly_fire = 1
	unsuitable_atmos_damage = 0

/mob/living/simple_animal/hostile/bioweapons_simulation/civilian

