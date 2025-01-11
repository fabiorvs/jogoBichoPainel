local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

-- Dados simulados para teste
local saldoTotal = 2000000
local historicoApostas = {
    { data = "2025-01-09", valor = 5000, bicho = "Avestruz", premio = "R$ 15.000" },
    { data = "2025-01-08", valor = 3000, bicho = "Cachorro", premio = "Perdeu" }
}
local extratoTransacoes = {
    { data = "2025-01-09", tipo = "Aposta", valor = "-5000" },
    { data = "2025-01-08", tipo = "Saque", valor = "-10000" }
}

-- Calcular saldo disponível
local function calcularSaldoDisponivel()
    return saldoTotal - Config.MinBalance
end

-- Eventos para enviar dados ao cliente
RegisterNetEvent("painelbicho:getDados")
AddEventHandler("painelbicho:getDados", function()
    local source = source
    local user_id = vRP.getUserId(source)

    -- Verifica se o jogador é o dono
    if vRP.hasPermission(user_id, "dono.jogobicho") then
        local saldoDisponivel = calcularSaldoDisponivel()
        TriggerClientEvent("painelbicho:receiveDados", source, saldoTotal, saldoDisponivel, historicoApostas, extratoTransacoes)
    else
        TriggerClientEvent("Notify", source, "negado", "Você não tem acesso a este painel.")
    end
end)
