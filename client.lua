local objectModels = {
    `prop_cs_amanda_shoe`,
    `prop_ld_shoe_01`,
    `prop_ld_shoe_02`
}

local isNetwork = true
local netMissionEntity = true
local doorFlag = false
local objects = {}
local topluyormu = false -- Toplama işlemi kontrolü için değişken

-- Load the models
for _, model in pairs(objectModels) do
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
end

-- Create an object at each of the defined coordinates
for _, coords in pairs(Config.ObjectCoords) do
    local model = objectModels[math.random(#objectModels)]
    local object = CreateObject(model, coords.x, coords.y, coords.z, isNetwork, netMissionEntity, doorFlag)
    SetEntityAsMissionEntity(object, true, true)
    table.insert(objects, {object = object, coords = coords, isTaken = false})
end

-- Load the ped model
RequestModel(Config.Ped.model)
while not HasModelLoaded(Config.Ped.model) do
    Wait(1)
end

-- Create the ped
local ped = CreatePed(4, Config.Ped.model, Config.Ped.coords.x, Config.Ped.coords.y, Config.Ped.coords.z, 0.0, true, true)
SetEntityAsMissionEntity(ped, true, true)
FreezeEntityPosition(ped, true)
SetBlockingOfNonTemporaryEvents(ped, true)

-- Listen for player key press (E key)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Check distance to objects
        for i = #objects, 1, -1 do
            local obj = objects[i]
            local distance = GetDistanceBetweenCoords(playerCoords, obj.coords, true)

            if distance < 2.0 then
                if not obj.isTaken then
                    DrawText3D(obj.coords.x, obj.coords.y, obj.coords.z, "[E] Ayakkabı Çal")

                    if IsControlJustReleased(0, 38) then -- 38 is the key code for 'E'
                        AyakkabiCal(obj)
                    end
                end
            end
        end

        -- Check distance to the ped
        local pedDistance = GetDistanceBetweenCoords(playerCoords, Config.Ped.coords, true)
        if pedDistance < 2.0 then
            DrawText3D(Config.Ped.coords.x, Config.Ped.coords.y, Config.Ped.coords.z, "[E] Ayakkabıları Para İle Değiştir")

            if IsControlJustReleased(0, 38) then -- 38 is the key code for 'E'
                TriggerServerEvent('exchangeItemsForMoney')
            end
        end
    end
end)

-- Function to initiate shoe stealing process
function AyakkabiCal(obj)
    if not topluyormu and not obj.isTaken then
        topluyormu = true
        obj.isTaken = true -- Ayakkabı artık alındı olarak işaretlendi

        exports['progressbar']:Progress({
            name = "ayakkabi_cal",
            duration = 4000, -- 4000 ms (4 seconds)
            label = 'Ayakkabı çalınıyor...',
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "mp_arresting",
                anim = "a_uncuff",
                flags = 49,
            },
        }, function(cancelled)
            if not cancelled then
                -- Progress bar tamamlandığında yapılacak işlemler
                DeleteObject(obj.object) -- Nesneyi sil
                TriggerServerEvent('addItemToInventory') -- Envantara ayakkabı ekle
            end
            topluyormu = false -- İşlem bittikten sonra kontrolü geri çevir
        end)
    end
end

-- Function to draw 3D text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
end
