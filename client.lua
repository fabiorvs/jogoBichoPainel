local painelAberto = false
local npcCriado = false
local blipCriado = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Verificar a cada segundo

        if not blipCriado then
            TriggerServerEvent("jogoBichoPainel:verificarDonoBlip")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if not npcCriado then
            local npcModel = GetHashKey(Config.NPC.model)

            RequestModel(npcModel)
            while not HasModelLoaded(npcModel) do
                Citizen.Wait(10)
            end

            -- Criar o NPC
            local ped = CreatePed(4, npcModel, Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z - 1.0,
                Config.NPC.heading, false, true)

            SetEntityInvincible(ped, true) -- Torna o NPC invencível
            FreezeEntityPosition(ped, true) -- Impede que o NPC se mova
            SetBlockingOfNonTemporaryEvents(ped, true) -- Impede que o NPC reaja a eventos

            -- Dar o fuzil para o NPC
            local weaponHash = GetHashKey("WEAPON_PUMPSHOTGUN")
            GiveWeaponToPed(ped, weaponHash, 9999, true, true) -- Dar a arma ao NPC
            SetCurrentPedWeapon(ped, weaponHash, true) -- Garantir que a arma seja equipada
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

-- Abrir o painel
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
        -- TriggerEvent("jogoBichoPainel:mostrarMensagem", "erro", "Você não tem permissão para acessar o painel.")
    end
end)

-- Fechar o painel
RegisterNUICallback("fecharPainel", function(_, cb)
    painelAberto = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "fechar"
    })
    cb("ok")
end)

-- Callback para saque
RegisterNUICallback("sacarValor", function(data, cb)
    if data.valor then
        -- Converte o valor usando a função corrigida
        local valorConvertido = converterBRParaNumero(data.valor)
        if valorConvertido > 0 then
            -- Enviar valor para o servidor
            TriggerServerEvent("jogoBichoPainel:sacarValor", valorConvertido)
        else
            TriggerEvent("jogoBichoPainel:mostrarMensagem", "erro", "Por favor, insira um valor válido para saque.")
        end
    else
        TriggerEvent("jogoBichoPainel:mostrarMensagem", "erro", "Por favor, insira um valor.")
    end
    cb("ok")
end)

-- Atualizar os saldos no painel após saque
RegisterNetEvent("jogoBichoPainel:atualizarSaldos")
AddEventHandler("jogoBichoPainel:atualizarSaldos", function(novoSaldo, saldoDisponivel)
    -- Envia as atualizações para o NUI
    SendNUIMessage({
        action = "atualizarSaldos",
        saldoTotal = novoSaldo,
        saldoDisponivel = saldoDisponivel
    })
    -- Mensagem de sucesso
    TriggerEvent("jogoBichoPainel:mostrarMensagem", "sucesso", "Saque realizado com sucesso!")
end)

-- Notificar erro no saque
RegisterNetEvent("jogoBichoPainel:mostrarMensagem")
AddEventHandler("jogoBichoPainel:mostrarMensagem", function(tipo, mensagem)
    SendNUIMessage({
        action = "mostrarMensagem",
        tipo = tipo,
        mensagem = mensagem
    })
end)

-- Função para converter valor no formato BR para número
function converterBRParaNumero(valorBR)
    if type(valorBR) ~= "string" then
        valorBR = tostring(valorBR)
    end
    local valor = valorBR:gsub("%.", ""):gsub(",", ".")
    return tonumber(valor) or 0
end

-- Eventos para adicionar e remover blip
RegisterNetEvent("jogoBichoPainel:adicionarBlip")
AddEventHandler("jogoBichoPainel:adicionarBlip", function()
    if not blipCriado then
        local blip = AddBlipForCoord(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
        SetBlipSprite(blip, 474) -- Ícone do blip
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Painel Jogo do Bicho")
        EndTextCommandSetBlipName(blip)
        blipCriado = blip
    end
end)

RegisterNetEvent("jogoBichoPainel:removerBlip")
AddEventHandler("jogoBichoPainel:removerBlip", function()
    if blipCriado then
        RemoveBlip(blipCriado)
        blipCriado = false
    end
end)
