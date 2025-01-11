document.addEventListener("DOMContentLoaded", function () {
  // Listener para mensagens enviadas pelo servidor
  window.addEventListener("message", function (event) {
    const data = event.data;
  
    if (data.action === "abrir") {
      abrirPainel(
        data.saldoTotal,
        data.saldoDisponivel,
        data.historicoApostas,
        data.extratoTransacoes
      );
    } else if (data.action === "fechar") {
      fecharPainel();
    }
  });

  // Fechar painel ao clicar no botão
  document
    .getElementById("fecharPainel")
    .addEventListener("click", function () {
      fetch(`https://${GetParentResourceName()}/fecharPainel`, {
        method: "POST",
      }).then(() => {
        fecharPainel();
      });
    });

  // Função para fechar o painel
  function fecharPainel() {
    const painel = document.getElementById("painelContainer");
    if (painel) painel.style.display = "none";
  }

  // Função para abrir o painel e preencher os dados
  function abrirPainel(
    saldoTotal,
    saldoDisponivel,
    historicoApostas,
    extratoTransacoes
  ) {
    const painel = document.getElementById("painelContainer");
    if (painel) painel.style.display = "block";

    // Preencher saldos
    document.getElementById("saldoTotal").innerText =
      formatCurrency(saldoTotal);
    document.getElementById("saldoDisponivel").innerText =
      formatCurrency(saldoDisponivel);

    // Preencher tabelas
    preencherHistoricoApostas(historicoApostas || []);
    preencherExtratoTransacoes(extratoTransacoes || []);
  }

  // Função para preencher o histórico de apostas
  function preencherHistoricoApostas(dados) {
    const tabela = document
      .getElementById("historicoApostas")
      .querySelector("tbody");
    tabela.innerHTML = "";

    if (Array.isArray(dados) && dados.length) {
      dados.forEach((item) => {
        const row = document.createElement("tr");

        row.innerHTML = `
            <td>${formatarData(item.data_aposta)}</td>
            <td>${getBichoNome(item.bicho_escolhido) || "Desconhecido"}</td>
            <td>${formatCurrency(item.valor_aposta)}</td>
            <td>${getBichoNome(item.premio_1)}, ${getBichoNome(item.premio_2)}, ${getBichoNome(item.premio_3)}</td>
            <td>${item.resultado || "Nenhum"}</td>
            <td>${formatCurrency(item.valor_ganho)}</td>
          `;

        tabela.appendChild(row);
      });
    } else {
      tabela.innerHTML = `<tr><td colspan="6" style="text-align: center;">Nenhum dado disponível.</td></tr>`;
    }
  }

  // Função para preencher o extrato de transações
  function preencherExtratoTransacoes(dados) {
    const tabela = document
      .getElementById("extratoTransacoes")
      .querySelector("tbody");
    tabela.innerHTML = "";

    if (Array.isArray(dados) && dados.length) {
      dados.forEach((item) => {
        const row = document.createElement("tr");

        row.innerHTML = `
            <td>${formatarData(item.data_transacao)}</td>
            <td>${item.tipo_transacao || "Desconhecido"}</td>
            <td>${formatCurrency(item.valor)}</td>
            <td>${item.descricao || "Sem descrição"}</td>
          `;

        tabela.appendChild(row);
      });
    } else {
      tabela.innerHTML = `<tr><td colspan="4" style="text-align: center;">Nenhum dado disponível.</td></tr>`;
    }
  }

  // Função para formatar valores monetários
  function formatCurrency(value) {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    }).format(value);
  }

  // Função para formatar data
  function formatarData(data) {
    const date = new Date(data);
    return date.toLocaleString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  function getBichoNome(id) {
    const bichosMap = {
        1: "Avestruz",
        2: "Águia",
        3: "Burro",
        4: "Cachorro",
        5: "Borboleta",
        6: "Cabra",
        7: "Carneiro",
        8: "Camelo",
        9: "Cobra",
        10: "Coelho",
        11: "Cavalo",
        12: "Elefante",
        13: "Galo",
        14: "Gato",
        15: "Jacaré",
        16: "Leão",
        17: "Macaco",
        18: "Porco",
        19: "Pavão",
        20: "Peru",
        21: "Touro",
        22: "Tigre",
        23: "Urso",
        24: "Veado",
        25: "Vaca",
      }; 
    return bichosMap[id] || "Desconhecido";
  }
});
