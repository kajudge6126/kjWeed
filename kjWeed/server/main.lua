QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

RegisterServerEvent('kjWeed:server:check-item')
AddEventHandler('kjWeed:server:check-item', function(source)
    local src = source
	local Player = QBCore.Functions.GetPlayer(source)
	
	if Player.Functions.GetItemByName("water").amount >= 1 and Player.Functions.GetItemByName("lowgradefert").amount >= 2 then
        TriggerClientEvent('kjWeed:client:start', source)
        Player.Functions.RemoveItem('lowgradefert', 1)
        Player.Functions.RemoveItem('water', 1)
	else
        TriggerClientEvent('QBCore:Notify', source, 'Ot ekmek için gereken malzemelere sahip değilsin!', "error")
	end
end)

RegisterNetEvent("kjWeed:server:giveWeed")
AddEventHandler("kjWeed:server:giveWeed", function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    xPlayer.Functions.AddItem("packaged_weed", 1)
end)

RegisterNetEvent("kjWeed:server:giveKhorium")
AddEventHandler("kjWeed:server:giveKhorium", function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    xPlayer.Functions.AddItem("khorium", 1)
end)

RegisterServerEvent("kjWeed:server:RemoveItem")
AddEventHandler("kjWeed:server:RemoveItem", function(item_name)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    xPlayer.Functions.RemoveItem(item_name, 1, xPlayer.Functions.GetItemByName(item_name).slot)
end)

RegisterNetEvent('kjWeed:weed-ver-davut')
AddEventHandler('kjWeed:weed-ver-davut', function(item, key)
    if QBCore.Functions.kickHacKer(source, key) then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local count = math.random(1,3)
        if xPlayer then
            if item == "weed" then
                xPlayer.Functions.AddItem(item, count, xPlayer.Functions.GetItemByName(item).slot)
            end
        end
    end
end)

QBCore.Functions.CreateUseableItem("lowgrademaleseed", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    TriggerEvent('kjWeed:server:check-item', source)
    Player.Functions.RemoveItem('lowgrademaleseed', 1)
end)
