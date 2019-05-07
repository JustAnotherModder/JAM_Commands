JAM.Commands = {}
local JCMD = JAM.Commands

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
	ESX.TriggerServerCallback('JAM:GetAceGroup', function(group) if group ~= "admin" and group ~= "superadmin" then canContinue = 1; else canContinue = 2; end; end)
	while not canContinue do Citizen.Wait(0); end
	if canContinue == 1 then return; end

	local num = tonumber(args[1])
	num = num + 0.001

	local plyPed = GetPlayerPed()
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

RegisterCommand('getpos', function(...) JCMD:PrintPlayerPosition(...); end)
RegisterCommand('setpower', function(source, args) JCMD:SetPower(args); end)
