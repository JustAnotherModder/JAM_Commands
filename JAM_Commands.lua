JAM.Commands = {}
local JCMD = JAM.Commands

function JCMD:PrintDist(p2)
	if not p2 then return; end
	local pedA = GetPlayerPed(PlayerId())
	local pedB = GetPlayerPed(p2)
	if not pedA or not pedB then return; end
	local posA = GetEntityCoords(pedA)
	local posB = GetEntityCoords(pedB)
	if not posA or not posB then return; end
	local dist = JUtils:GetVecDist(pedA,pedB)
	TriggerEvent("chatMessage", "", {0, 255, 0}, "-----" )
	TriggerEvent("chatMessage", "GETDIST", {0, 255, 0}, "Dist = " .. math.floor(dist * 100)/100 )
	TriggerEvent("chatMessage", "", {0, 255, 0}, "-----" )
end

function JCMD:PrintPlayerPosition()
	if not self then return; end

	local plyPed = PlayerPedId()
	if not plyPed then return; end

	local plyPos = GetEntityCoords(plyPed)
	local plyHead = GetEntityHeading(plyPed)
	local plyRot = GetEntityRotation(plyPed, 2)
	if not plyPos or not plyHead or not plyRot then return; end

	TriggerEvent("chatMessage", "", {0, 255, 0}, "-----" )
	TriggerEvent("chatMessage", "POSITION", {0, 255, 0}, "X = " .. math.floor(plyPos.x * 100)/100 .. " : Y = " .. math.floor(plyPos.y * 100)/100 .. " : Z = " .. math.floor(plyPos.z * 100)/100 )
	TriggerEvent("chatMessage", "ROTATION", {0, 255, 0}, "X = " .. math.floor(plyRot.x * 100)/100 .. " : Y = " .. math.floor(plyRot.y * 100)/100 .. " : Z = " .. math.floor(plyRot.z * 100)/100 )
	TriggerEvent("chatMessage", "HEADING", {0, 255, 0}, "H = " .. math.floor(plyHead * 100)/100 )
	TriggerEvent("chatMessage", "", {0, 255, 0}, "-----" )
end

function JCMD:SetPower(args)
	if not args or not args[1] or self.IsLooping then return; end

	local canContinue = false
	ESX.TriggerServerCallback('JAM:GetAceGroup', function(group) 
	if group ~= "admin" and group ~= "superadmin" then canContinue = 1; else canContinue = 2; end; end)
	while not canContinue do Citizen.Wait(0); end
	if canContinue == 1 then return; end

	local num = tonumber(args[1])
	num = num + 0.001

	local plyPed = GetPlayerPed(PlayerId())
	local plyVeh = GetLastDrivenVehicle(plyPed, true)

	if plyVeh then
		Citizen.CreateThread(function(...)
			local vehProps = ESX.Game.GetVehicleProperties(plyVeh)
			self.IsLooping = true

			SetVehicleDirtLevel(veh, false)
			SetVehicleFixed(plyVeh)	


			SetEntityCanBeDamaged(plyVeh, false)
			SetVehicleCanBeVisiblyDamaged(plyVeh, false)
			SetEntityProofs(plyVeh, true, true, true, true, true, true, true, true)
			SetVehicleEngineTorqueMultiplier(plyVeh, 1.8)
			SetEntityMaxSpeed(plyVeh, 1000000.0)
			SetEntityMaxSpeed(plyPed, 1000000.0)

			local tick = 0			
			while IsPedInVehicle(plyPed, plyVeh, true) do
				tick = tick + 1
				if tick % 10 == 1 then
					local allVehs = ESX.Game.GetVehiclesInArea(GetEntityCoords(PlayerPedId()), 50)
					for k,v in pairs(allVehs) do
						SetEntityNoCollisionEntity(v, plyVeh, false)
						--SetEntityNoCollisionEntity(plyVeh, v, false)
					end
				end

				if tick % 100 then 
					RemoveDecalsFromVehicle(plyVeh)
				end
				
				SetVehicleEnginePowerMultiplier(plyVeh, num)
				Citizen.Wait(0)
			end
			SetEntityCanBeDamaged(plyVeh, true)
			SetVehicleCanBeVisiblyDamaged(plyVeh, true)
			SetEntityProofs(plyVeh, false, false, false, false, false, false, false, false)
			SetVehicleEnginePowerMultiplier(plyVeh, 1.0)
			SetVehicleEngineTorqueMultiplier(plyVeh, 1.0)
			SetEntityMaxSpeed(plyVeh, 540.0)
			SetEntityMaxSpeed(plyPed, 540.0)
			self.IsLooping = false
		end)
	end
end

function JCMD:SetInvincible(jug)
	self.IsInvincible = not self.IsInvincible
	local plyPed = PlayerPedId(-1)
	SetEntityInvincible(plyPed, self.IsInvincible)
	if not jug then
		local str = "Invincible : "
		if self.IsInvincible then str = str .. "~g~Enabled"
		else str = str .. "~r~Disabled"
		end
		ESX.ShowNotification(str)
	else
		local str = "Juggernaught : "
		if self.IsInvincible then str = str .. "~g~Enabled"
		else str = str .. "~r~Disabled"
		end
		ESX.ShowNotification(str)
	end
end

function JCMD:SetNoReload(jug)
	self.NoReload = not self.NoReload
	local plyPed = PlayerPedId(-1)
	SetPedInfiniteAmmoClip(plyPed, self.NoReload)
	if not jug then	
		local str = "No Reload : "
		if self.NoReload then str = str .. "~g~Enabled"
		else str = str .. "~r~Disabled"
		end
	end
	ESX.ShowNotification(str)
	Citizen.CreateThread(function(...)
		while self.NoReload do 
			Citizen.Wait(0)
			SetFireAmmoThisFrame(plyPed)
		end
	end)
end

function JCMD:Repair()
	local plyPed = GetPlayerPed(-1)
	local plyVeh = GetLastDrivenVehicle(plyPed, true)
	SetVehicleFixed(plyVeh)
	SetVehicleDirtLevel(plyVeh, false)
end

RegisterCommand('jug', function(...) JCMD:SetNoReload(...); JCMD:SetInvincible(...); end)
RegisterCommand('norel', function(...) JCMD:SetNoReload(...); end)
RegisterCommand('invin', function(...) JCMD:SetInvincible(...); end)
RegisterCommand('getpos', function(...) JCMD:PrintPlayerPosition(...); end)
RegisterCommand('getdist', function(source, args) JCMD:PrintDist(args); end)
RegisterCommand('setpower', function(source, args) JCMD:SetPower(args); end)
RegisterCommand('repair', function(source, args) JCMD:Repair(args); end)
