sample_quest = { } 
sample_quest.quests = {
	[1] = { "simple_walk", "Walk 200 nodes", 200, "Walking is hard, but you have to learn it."},
	[2] = { "start_digging", "Dig 10 nodes", 10, "As long as you can not dig, you are not a real miner."}, 
	[3] = { "first_wood", "Craft 8 wood planks", 8, "Once upon a time, everything was wood."},
	[4] = { "first_tool", "Craft a wooden pickaxe", 1, "It might be useful to use a tool instead of your bare hand."}
}
sample_quest.current_quest = {}

function sample_quest.next_quest(playername, questname) 
	sample_quest.current_quest[playername] = sample_quest.current_quest[playername] + 1
	if (sample_quest.quests[sample_quest.current_quest[playername]] == nil) then
		return
	end
	print(sample_quest.quests[sample_quest.current_quest[playername]][1])
	quests.register_quest(playername, "sample_quest:" .. sample_quest.quests[sample_quest.current_quest[playername]][1], 
			{ title = sample_quest.quests[sample_quest.current_quest[playername]][2],
			  description = sample_quest.quests[sample_quest.current_quest[playername]][4],
			  max = sample_quest.quests[sample_quest.current_quest[playername]][3],
			  autoaccept = true,
			  callback = sample_quest.next_quest })
end

local oldpos = {}
minetest.register_on_joinplayer(function (player)
	sample_quest.current_quest[player:get_player_name()] = 0
	sample_quest.next_quest(player:get_player_name(), "")
	quests.show_hud(player:get_player_name())
	oldpos[player:get_player_name()] = player:getpos()
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
	quests.update_quest(digger:get_player_name(), "sample_quest:start_digging", 1)
	if (oldnode.name == "default:stone") then
		quests.update_quest(digger:get_player_name(), "sample_quest:stone", 1)
		minetest.after(5, quests.accept_quest, digger:get_player_name(), "sample_quest:stone")
	end
end)

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if (timer >= 1) then
		local players = minetest.get_connected_players()
		for _,player in ipairs(players) do
			if (oldpos[player:get_player_name()] ~= nil) then
				local playername = player:get_player_name()
				local pos = player:getpos()
				quests.update_quest(player:get_player_name(), "sample_quest:simple_walk", math.sqrt(math.pow(oldpos[playername].x - pos.x, 2) + math.pow(oldpos[playername].y - pos.y, 2) + math.pow(oldpos[playername].z - pos.z,2)))
			end
			oldpos[player:get_player_name()] = player:getpos()
		end
		timer = 0
	end
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	local playername = player:get_player_name()
	if (itemstack:get_name() == "default:wood") then
		quests.update_quest(playername, "sample_quest:first_wood", itemstack:get_count())
	elseif (itemstack:get_name() == "default:pick_wood") then
		quests.update_quest(playername, "sample_quest:first_tool", itemstack:get_count())
		quests.register_quest(playername, "sample_quest:stone", 
				{ title = "Dig one stone",
				  description = "Welcome to the stoneage.",
				  max = 1,
				  autoaccept = false,
				  callback = nil })
	end
	return nil
end)
