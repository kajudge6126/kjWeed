local isActionStarted = false
QBCore = nil
Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
end)

local zone = PolyZone:Create({
    vector2(1875.5733642578127, 4766.80322265625),
    vector2(1831.662841796875, 4808.85205078125), 
    vector2(1868.8538818359375, 4846.1337890625), 
    vector2(1918.615234375, 4797.62939453125)
  }, {
    name= "weedzone",
    minZ = 1.0,
    maxZ = 800.0
})

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(vector3(1332.10009765625, -1642.4794921875, 52.1190299987793))
    SetBlipSprite(blip, 52)
    SetBlipColour(blip, 61)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.7)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Pinkman Market")
    EndTextCommandSetBlipName(blip) 
end)

local spatula_net = nil
RegisterNetEvent('kjWeed:client:start')
AddEventHandler('kjWeed:client:start', function()
    local time = math.random(11000, 16000)
    local playerCoords = GetEntityCoords(PlayerPedId())
    if zone:isPointInside(playerCoords) then
        local cSCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
        local spatulaspawn = CreateObject(`bkr_prop_coke_spatula_04`, cSCoords.x, cSCoords.y, cSCoords.z, 1, 1, 1)
        local netid = ObjToNet(spatulaspawn)
        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed) then
            QBCore.Functions.Notify("Araç İçinde İken Tohum Yetiştiremessin")
            return
        end
        if isActionStarted then
            QBCore.Functions.Notify("Şuan Zaten Tohum Yetiştiriyorsun Lütfen Önce Onu Bitir")
            return
        end
        FreezeEntityPosition(playerPed, false)
        TaskStartScenarioInPlace(PlayerPedId(), "world_human_gardener_plant", 0, false)
        AttachEntityToEntity(spatulaspawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),-0.005,0.0,0.0,190.0,190.0,-50.0,1,1,0,1,0,1)
        spatula_net = netid
        QBCore.Functions.Notify("Otu ekiyorsun...", "primary", time)
        Citizen.Wait(time)
        disable_actions = false
        isActionStarted = true
        DetachEntity(NetToObj(spatula_net), 1, 1)
        DeleteEntity(NetToObj(spatula_net))
        spatula_net = nil
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify("Başarıyla otu ektin, büyümesi için çıkan soruları cevaplamalısın!", "success")
        Citizen.Wait(2000)
        TriggerEvent('kjWeed:questions')
    else
        QBCore.Functions.Notify("Otu Bu Alanda veya Tarlada Yetiştiremessin.", "error")
    end
end)

RegisterNetEvent("kjWeed:questions")
AddEventHandler("kjWeed:questions", function()
    local pPed = PlayerPedId()
    local pCoord = GetEntityCoords(pPed)
    local forward = GetEntityForwardVector(pPed)
    x, y, z   = table.unpack(pCoord + forward * 1.0)
    local grow = {2.24, 1.95, 1.65, 1.45, 1.20, 1.00}
    local GTime = math.random(9000, 12000)
    local HTime = math.random(12000, 16000)

    local playerCoords = GetEntityCoords(PlayerPedId())
    local miktar = math.random(100,200)
    local chance = nil
    if miktar >=100 and miktar <= 150 then
        chance = 1
    elseif miktar >=150 and miktar <= 200 then
        chance = 2
    end
    QBCore.UI.Menu.Open( 'default', GetCurrentResourceName(), 'fosforquest', 
    {
    title    = (Config.questions.title),
    align = 'center', 
    elements = { 
      {label = (Config.questions.steps[1].label),     value = Config.questions.steps[1].value},
      {label = (Config.questions.steps[2].label),     value = Config.questions.steps[2].value},
    }
    },  function(data, menu) 
    if data.current.value == chance then
        menu.close()
        QBCore.Functions.Notify("Soruya doğru cevap verdin, diğer aşamaya geçiyoruz!", "success")

            QBCore.Functions.Progressbar("bitki_yerlestir", "Bitkiyi Gübreliyorsun..", GTime, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "amb@prop_human_bum_bin@base",
                anim = "base",
                flags = 33,
            }, {}, {}, function() -- Done
                TriggerServerEvent("kjWeed:server:RemoveItem","lowgradefert")
                    RequestModel('prop_weed_01')
                    while not HasModelLoaded('prop_weed_01') do
                        Citizen.Wait(1)
                    end
                    obj = CreateObject(GetHashKey('prop_weed_01'), x, y, z - 1.95, 0, 0, 0)
                    QBCore.Functions.Progressbar("bitki_ver", "Bitkiyi Hasat Ediyorsun..", HTime, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = "amb@world_human_gardener_plant@male@idle_a",
                        anim = "idle_b",
                        flags = 33,
                    }, {}, {}, function() -- Done
                        TriggerServerEvent("kjWeed:weed-ver-davut", 'weed', QBCore.Key)
                        QBCore.Functions.Notify("Bitki başarılı bir şekilde hasat edildi.", "success")
                        isActionStarted = false
                        DeleteEntity(obj)
                    end, function() -- Cancel
                        QBCore.Functions.Notify("Bitki hasat etmeyi iptal ettin, bitkinin hasat edilmesi durduruldu!", "error")
                        isActionStarted = false
                        DeleteEntity(obj)
                    end)
                
                isActionStarted = true
            end, function() -- Cancel
                QBCore.Functions.Notify("Bitki hasat etmeyi iptal ettin, bitkinin hasat edilmesi durduruldu!", "error")
                isActionStarted = false
                DeleteEntity(obj)
            end)

        isActionStarted = true
    else
        menu.close() 
        QBCore.Functions.Notify("Soruya doğru cevap veremedin! Ot ekme işlemi iptal edildi.", "error")
        isActionStarted = false
        DeleteEntity(obj)
    end   
  end,
    function(data, menu) 
      menu.close() 
    end)
end)

Citizen.CreateThread(function() -- OT ISLEME
    while true do
    local RTime = math.random(15000, 18000)
	local ped = PlayerPedId()
        Citizen.Wait(1)
        for i=1, 1 do
            if GetDistanceBetweenCoords(GetEntityCoords(ped), 1330.4600830078125, -1649.7122802734375, 44.25246810913086, true) < 4 then
                DrawMarker(25, 1330.4600830078125, -1649.7122802734375, 44.25246810913086-0.9, 0, 0, 0, 0, 0, 25.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                QBCore.Functions.DrawText3D(1330.4600830078125, -1649.7122802734375, 44.25246810913086, "E - Ot Paketleme")
                if IsControlJustReleased(1, 51) then
                    QBCore.Functions.TriggerCallback("kaju-base:check-item", function(output)
                        if output > 0 then
                            QBCore.Functions.TriggerCallback("kaju-base:removeItem", function(result)
                                if result then
                                    QBCore.Functions.Progressbar("bitki_ver", "Otu Paketliyorsun..", RTime, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {
                                        animDict = "missheistfbisetup1",
                                        anim = "unlock_loop_janitor",
                                        flags = 49,
                                    }, {}, {}, function() -- Done
                                        local miktar = math.random(1,100)
                                        local chance = nil
                                        if miktar >=1 and miktar <= 99 then -- 100 , 198
                                            TriggerServerEvent('kjWeed:server:giveWeed') -- BASIC ITEM
                                            QBCore.Functions.Notify("Otu başarıyla paketledin! Paket Kalitesi: Normal", "success")
                                        elseif miktar >=100 and miktar <= 100 then -- 200
                                            TriggerServerEvent('kjWeed:server:giveKhorium') -- NADIR ITEM
                                            QBCore.Functions.Notify("Otu başarıyla paketledin! Paket Kalitesi: Yüksek", "success")
                                        end
                                    end, function() -- Cancel
                                        QBCore.Functions.Notify("Ot paketleme işlemi iptal edildi!", "error")
                                    end)
                                else
                                    QBCore.Functions.Notify("İşleme yapmak için üzerinde yeterli ot yok!", 'error')
                                end
                            end, "weed", 1)
                        else
                            QBCore.Functions.Notify("İşleme yapmak için üzerinde yeterli ot yok!", 'error')
                        end
                    end, "weed")
                end
            end
        end
    end
end)