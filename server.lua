QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('addItemToInventory')
AddEventHandler('addItemToInventory', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Determine which item to add based on the chance
    local totalChance = 0
    for _, item in pairs(Config.Items) do
        totalChance = totalChance + item.chance
    end

    local randomChance = math.random(0, totalChance)
    local cumulativeChance = 0

    for _, item in pairs(Config.Items) do
        cumulativeChance = cumulativeChance + item.chance
        if randomChance <= cumulativeChance then
            Player.Functions.AddItem(item.item, 1)
            TriggerClientEvent('QBCore:Notify', src, "You have picked up a " .. item.item, "success")
            break
        end
    end
end)

RegisterNetEvent('exchangeItemsForMoney')
AddEventHandler('exchangeItemsForMoney', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local totalMoney = 0

    for itemName, exchangeRate in pairs(Config.ExchangeRates) do
        local itemCount = Player.Functions.GetItemByName(itemName)
        if itemCount then
            totalMoney = totalMoney + (itemCount.amount * exchangeRate)
            Player.Functions.RemoveItem(itemName, itemCount.amount)
        end
    end

    if totalMoney > 0 then
        Player.Functions.AddMoney('bank', totalMoney)
        TriggerClientEvent('QBCore:Notify', src, "You have exchanged your items for $" .. totalMoney, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "You don't have any items to exchange", "error")
    end
end)
