D3bot.Handlers = {}

-- TODO: Make search path relative
for i, filename in pairs(file.Find("d3bot/sv_zs_bot_handler/handlers/*.lua", "LUA")) do
	include("handlers/"..filename)
end

local handlerLookup = {}

function findHandler(zombieClass, team)
	if handlerLookup[team] and handlerLookup[team][zombieClass] then -- TODO: Put cached handler into bot object
		return handlerLookup[team][zombieClass]
	end
	
	for _, fallback in ipairs({false, true}) do
		for _, handler in pairs(D3bot.Handlers) do
			if handler.Fallback == fallback and handler.SelectorFunction(GAMEMODE.ZombieClasses[zombieClass].Name, team) then
				handlerLookup[team] = {}
				handlerLookup[team][zombieClass] = handler
				return handler
			end
		end
	end
end
local findHandler = findHandler

hook.Add("StartCommand", D3bot.BotHooksId, function(pl, cmd)
	if D3bot.IsEnabled and pl:IsBot() then
		
		local handler = findHandler(pl:GetZombieClass(), pl:Team())
		handler.UpdateBotCmdFunction(pl, cmd)
		
	end
end)

local NextBot🤔 = CurTime()
local NextSupervisor🤔 = CurTime()
local NextStorePos = CurTime()
hook.Add("Think", D3bot.BotHooksId.."🤔", function()
	if not D3bot.IsEnabled then return end
	
	-- General bot handler think function
	if NextBot🤔 < CurTime() then
		NextBot🤔 = CurTime() + 0.1
		
		for _, bot in ipairs(player.GetBots()) do
			local handler = findHandler(bot:GetZombieClass(), bot:Team())
			handler.ThinkFunction(bot)
		end
		
	end
	
	-- Supervisor think function
	if NextSupervisor🤔 < CurTime() then
		NextSupervisor🤔 = CurTime() + 0.1
		D3bot.SupervisorThinkFunction()
	end
	
	-- Store history of all players (For behaviour classification, stuck checking)
	if NextStorePos < CurTime() then
		NextStorePos = CurTime() + 1
		for _, ply in ipairs(player.GetAll()) do
			ply:D3bot_StorePos()
		end
	end
end)

hook.Add("EntityTakeDamage", D3bot.BotHooksId.."TakeDamage", function(ent, dmg)
	if D3bot.IsEnabled then
		if ent:IsPlayer() and ent:IsBot() then
			-- Bot got damaged or damaged itself
			local handler = findHandler(ent:GetZombieClass(), ent:Team())
			handler.OnTakeDamageFunction(ent, dmg)
		end
		local attacker = dmg:GetAttacker()
		if attacker ~= ent and attacker:IsPlayer() and attacker:IsBot() then
			-- A Bot did damage something
			local handler = findHandler(attacker:GetZombieClass(), attacker:Team())
			handler.OnDoDamageFunction(attacker, dmg)
			attacker.D3bot_LastDamage = CurTime()
		end
	end
end)

hook.Add("PlayerDeath", D3bot.BotHooksId.."PlayerDeath", function(pl)
	if D3bot.IsEnabled and pl:IsBot() then
		local handler = findHandler(pl:GetZombieClass(), pl:Team())
		handler.OnDeathFunction(pl)
		-- Add death cost to the current link
		local mem = pl.D3bot_Mem
		local nodeOrNil = mem.NodeOrNil
		local nextNodeOrNil = mem.NextNodeOrNil
		if nodeOrNil and nextNodeOrNil then
			local link = nodeOrNil.LinkByLinkedNode[nextNodeOrNil]
			if link then D3bot.LinkMetadata_ZombieDeath(link, D3bot.LinkDeathCostRaise) end
		end
	end
end)

hook.Add("PlayerInitialSpawn", D3bot.BotHooksId, function(pl)
	if D3bot.IsEnabled and pl:IsBot() then
		pl:D3bot_Initialize()
	end
end)

local hadBonusByPl = {}
hook.Add("PlayerSpawn", D3bot.BotHooksId, function(pl)
	if not D3bot.IsEnabled then return end
	if pl:IsBot() then pl:D3bot_SetUp() end
	if D3bot.IsEnabled and D3bot.StartBonus and D3bot.StartBonus > 0 and pl:Team() == TEAM_SURVIVOR then
		local hadBonus = hadBonusByPl[pl]
		hadBonusByPl[pl] = true
		pl:SetPoints(hadBonus and 0 or D3bot.StartBonus)
	end
end)
hook.Add("PreRestartRound", D3bot.BotHooksId.."PreRestartRound", function() hadBonusByPl = {} end)