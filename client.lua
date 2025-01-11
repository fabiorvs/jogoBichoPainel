local painelAberto = false
local npcCriado = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if not npcCriado then
            local npcModel = GetHashKey(Config.NPC.model)

            RequestModel(npcModel)
            while not HasModelLoaded(npcModel) do
                Citizen.Wait(10)
            end

            local ped = CreatePed(4, npcModel, Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z - 1.0,
                Config.NPC.heading, false, true)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)

            npcCriado = true
        end

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distancia = #(playerCoords - Config.NPC.coords)

        if distancia <= 10.0 then
            DrawText3D(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z + 1.0,
                "Pressione [E] para abrir o painel do Jogo do Bicho")
            if distancia <= 1.5 and IsControlJustPressed(1, 51) then
                TriggerServerEvent("jogoBichoPainel:verificarDono")
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
    end
end

RegisterNetEvent("jogoBichoPainel:abrirPainel")
AddEventHandler("jogoBichoPainel:abrirPainel", function(permitido, data)
    if permitido then
        painelAberto = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "abrir",
            saldoTotal = data.saldoTotal,
            saldoDisponivel = data.saldoDisponivel,
            historicoApostas = data.historicoApostas,
            extratoTransacoes = data.extratoTransacoes
        })
    else
        TriggerEvent("Notify", "negado", "Você não tem permissão para acessar o painel.")
    end
end)

RegisterNUICallback("fecharPainel", function(_, cb)
    painelAberto = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "fechar"
    })
    cb("ok")
end)
