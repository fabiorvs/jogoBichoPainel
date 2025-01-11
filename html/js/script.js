window.addEventListener("message", (event) => {
    if (event.data.action === "abrirPainel") {
        document.querySelector("#saldoTotal").textContent = `R$ ${event.data.saldoTotal.toLocaleString("pt-BR")}`;
        document.querySelector("#saldoDisponivel").textContent = `R$ ${event.data.saldoDisponivel.toLocaleString("pt-BR")}`;

        const apostasTable = document.querySelector("#historicoApostas tbody");
        apostasTable.innerHTML = "";
        event.data.historicoApostas.forEach((aposta) => {
            const row = `<tr>
                <td>${aposta.data}</td>
                <td>${aposta.valor}</td>
                <td>${aposta.bicho}</td>
                <td>${aposta.premio}</td>
            </tr>`;
            apostasTable.innerHTML += row;
        });

        const transacoesTable = document.querySelector("#extratoTransacoes tbody");
        transacoesTable.innerHTML = "";
        event.data.extratoTransacoes.forEach((transacao) => {
            const row = `<tr>
                <td>${transacao.data}</td>
                <td>${transacao.tipo}</td>
                <td>${transacao.valor}</td>
            </tr>`;
            transacoesTable.innerHTML += row;
        });

        document.querySelector("#painel").style.display = "block";
    }
});

document.querySelector("#fecharPainel").addEventListener("click", () => {
    fetch(`https://${GetParentResourceName()}/fecharPainel`, { method: "POST" });
    document.querySelector("#painel").style.display = "none";
});
