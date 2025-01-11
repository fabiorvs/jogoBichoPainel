local isNearNPC = false

-- Thread para verificar proximidade do NPC
CreateThread(function()
    local npcCoords = Config.NPC.coords
    local npcHeading = Config.NPC.heading
    local npcModel = Config.NPC.model

    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Wait(10)
    end

    local npc = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z - 1, npcHeading, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - npcCoords)

        isNearNPC = dist < 3.0
        if isNearNPC then
            DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.2, "[E] Acessar Painel do Dono")
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent("painelbicho:getDados")
            end
        end

        Wait(0)
    end
end)

-- Função para desenhar texto 3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local scale = 0.35
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Receber dados do painel
RegisterNetEvent("painelbicho:receiveDados")
AddEventHandler("painelbicho:receiveDados", function(saldoTotal, saldoDisponivel, historicoApostas, extratoTransacoes)
    SendNUIMessage({
        action = "abrirPainel",
        saldoTotal = saldoTotal,
        saldoDisponivel = saldoDisponivel,
        historicoApostas = historicoApostas,
        extratoTransacoes = extratoTransacoes
    })
    SetNuiFocus(true, true)
end)

-- Fechar o painel
RegisterNUICallback("fecharPainel", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)
