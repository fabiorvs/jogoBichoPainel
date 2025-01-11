local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vRP._prepare("jogoBicho/get_dono_atual", [[
    SELECT user_id FROM jogobicho_donos WHERE atual = 1
]])

vRP._prepare("jogoBicho/get_historico_apostas", [[
    SELECT * FROM jogobicho_historico_apostas WHERE user_id = @user_id ORDER BY data_aposta DESC
]])

vRP._prepare("jogoBicho/get_historico_transacoes", [[
    SELECT * FROM jogobicho_historico_transacoes ORDER BY data_transacao DESC
]])


RegisterNetEvent("jogoBichoPainel:verificarDono")
AddEventHandler("jogoBichoPainel:verificarDono", function()
    local src = source
    local user_id = vRP.getUserId(src)

    if user_id then
        local donoAtual = vRP.query("jogoBicho/get_dono_atual", {})[1]
        if donoAtual and tonumber(donoAtual.user_id) == user_id then
            local saldoTotal = vRP.query("jogoBicho/get_saldo_atual", {})[1].saldo or 0
            local saldoDisponivel = saldoTotal - Config.MinBalance

            local historicoApostas = vRP.query("jogoBicho/get_historico_apostas", { user_id = user_id }) or {}
            local extratoTransacoes = vRP.query("jogoBicho/get_historico_transacoes", {}) or {}

            TriggerClientEvent("jogoBichoPainel:abrirPainel", src, true, {
                saldoTotal = saldoTotal,
                saldoDisponivel = saldoDisponivel > 0 and saldoDisponivel or 0,
                historicoApostas = historicoApostas,
                extratoTransacoes = extratoTransacoes
            })
        else
            TriggerClientEvent("jogoBichoPainel:abrirPainel", src, false)
        end
    else
        TriggerClientEvent("jogoBichoPainel:abrirPainel", src, false)
    end
end)


RegisterNetEvent("jogoBichoPainel:sacarValor")
AddEventHandler("jogoBichoPainel:sacarValor", function(valor)
    local src = source
    local user_id = vRP.getUserId(src)

    if user_id then
        valor = tonumber(valor)

        if valor and valor > 0 then
            -- Obter o saldo atual
            local saldoAtual = vRP.query("jogoBicho/get_saldo_atual", {})[1].saldo

            -- Calcular o saldo disponível
            local saldoDisponivel = saldoAtual - Config.MinBalance

            if saldoDisponivel >= valor then
                -- Atualizar o saldo no banco de dados
                local novoSaldo = saldoAtual - valor
                vRP._execute("jogoBicho/update_saldo", { saldo = novoSaldo })

                -- Registrar a transação no histórico
                vRP._execute("jogoBicho/insert_transacao", {
                    tipo_transacao = "Saque",
                    valor = -valor,
                    descricao = string.format("Saque realizado pelo dono %d", user_id),
                    saldo_apos = novoSaldo
                })

                -- Adicionar o item ou dinheiro ao usuário
                if Config.SaqueItem and Config.SaqueItem ~= "" then
                    vRP.giveInventoryItem(user_id, Config.SaqueItem, valor, true)
                else
                    vRP.giveMoney(user_id, valor)
                end

                -- Enviar atualização ao cliente
                TriggerClientEvent("jogoBichoPainel:atualizarSaldos", src, novoSaldo, saldoDisponivel - valor)
                TriggerClientEvent("jogoBichoPainel:mostrarMensagem", src, "sucesso", "Saque realizado com sucesso!!!")
            else
                TriggerClientEvent("jogoBichoPainel:mostrarMensagem", src, "erro", "Saldo disponível insuficiente para o saque.")
            end
        else
            TriggerClientEvent("jogoBichoPainel:mostrarMensagem", src, "erro", "Valor inválido para saque.")
        end
    else
        TriggerClientEvent("jogoBichoPainel:mostrarMensagem", src, "erro", "Usuário não identificado.")
    end
end)
