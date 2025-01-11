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
