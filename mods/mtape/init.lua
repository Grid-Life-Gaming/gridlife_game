-- CyClop, 6.12.2014
mtape = {}

-- list for storing reference points
mtape.refs = {}

-- set reference point 
mtape.set_reference_point = function(player, pos, id)
	if mtape.refs[player:get_player_name()] == nil then
		mtape.refs[player:get_player_name()] = {}
	end
	mtape.refs[player:get_player_name()][id] = pos
	minetest.chat_send_player(player:get_player_name(), "Measuring reference point set!")
end

-- get distance from reference point
mtape.get_distance = function(player, pos, id, allowmulti)
	local refpos = mtape.refs[player:get_player_name()]
	if refpos == nil then
		return "No reference point set. To measure distance, first set a reference point by right-clicking on a node."
	end
	
	refpos = refpos[id]
	if refpos == nil then
		return "No reference point set. To measure distance, first set a reference point by right-clicking on a node."
	end
	
	local result = {}
	
	for axis, val in pairs(refpos) do
		if pos[axis] ~= val then
			table.insert(result, {axis=string.upper(axis), value=(math.abs(pos[axis]-val)+1)})
		end
	end
	
	if #result == 0 then
		return "No point in measuring distance to reference point."
	elseif #result == 1 then
		return ("Measured distance on "..result[1].axis.." axis is "..result[1].value.."m.")
	else
		if allowmulti == false then 
			return "You can only measure distance on single axis."
		end
		local str = ("Measured distance: %fm\n"):format(vector.distance(refpos, pos))
		for _, res in pairs(result) do
			str = str.."                               "..res.value.."m on "..res.axis.." axis\n"
		end
		
		return str
	end
end

-- mese measuring tape, can measure on up to 3(!) axis (id=M)
minetest.register_craftitem("mtape:mtape", {
	description = "Measuring Tape",
	inventory_image = "mtape.png",
	stack_max = 1,
	liquids_pointable = true,
	on_use = function(itemstack, user, pointed_thing)
		-- Must be pointing to node to make measurements
		if pointed_thing.type ~= "node" then
			return
		end
		minetest.chat_send_player(user:get_player_name(), mtape.get_distance(user, pointed_thing.under, "M", true))
	end,
	on_place = function(itemstack, user, pointed_thing)
		mtape.set_reference_point(user, pointed_thing.under, "M")
		return itemstack
	end
})

-- crafting recepies
minetest.register_craft({output = 'mtape:mtape 1',
	recipe = {
		{'dye:black', '', 'dye:black'},
		{'homedecor:plastic_sheeting', 'homedecor:plastic_sheeting', 'homedecor:plastic_sheeting'},
	}
})
