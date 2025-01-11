$(document).ready(function () {
  $("#valorSaque").mask("000.000.000,00", { reverse: true });
});

// Listener  enviadas pelo servidor
window.addEventListener("message", function (event) {
  const data = event.data;

  switch (data.action) {
    case "abrir":
      abrirPainel(
        data.saldoTotal,
        data.saldoDisponivel,
        data.historicoApostas,
        data.extratoTransacoes
      );
      break;
    case "fechar":
      fecharPainel();
      break;
    case "mensagemErro":
      Swal.fire({
        icon: "error",
        title: data.title,
        text: data.text,
      });
      break;
    case "mensagemSucesso":
      Swal.fire({
        icon: "success",
        title: data.title,
        text: data.text,
      });
      break;

    case "atualizarSaldos":
      atualizarSaldos(data.saldoTotal, data.saldoDisponivel);
      break;

    case "mostrarMensagem":
      if (data.tipo === "sucesso") {
        Swal.fire({
          icon: "success",
          title: "Sucesso",
          text: data.mensagem,
        });
      } else if (data.tipo === "erro") {
        Swal.fire({
          icon: "error",
          title: "Erro",
          text: data.mensagem,
        });
      }
      break;

    case "abrir":
      abrirPainel(
        data.saldoTotal,
        data.saldoDisponivel,
        data.historicoApostas,
        data.extratoTransacoes
      );
      break;

    case "fechar":
      fecharPainel();
      break;
  }
});

// Fechar painel ao clicar no botão fechar
document.getElementById("fecharPainel").addEventListener("click", function () {
  fetch(`https://${GetParentResourceName()}/fecharPainel`, {
    method: "POST",
  }).then(() => {
    fecharPainel();
  });
});

// Fechar painel ao clicar no botão sacar
document.getElementById("sacarValor").addEventListener("click", function () {
  const valor = document.getElementById("valorSaque").value;
  console.log(valor);

  // Envia o valor para o servidor
  fetch(`https://${GetParentResourceName()}/sacarValor`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ valor }),
  })
    .then((response) => response.json())
    .then((data) => {
      if (data === "ok") {
        document.getElementById("valorSaque").value = ""; // Limpa o campo
      } else {
        console.log(data.message || "Erro ao realizar o saque.");
      }
    })
    .catch((error) => {
      console.error("Erro ao comunicar com o servidor:", error);
      console.log("Erro ao processar o saque.");
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
  document.getElementById("saldoTotal").innerText = formatCurrency(saldoTotal);
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
            <td>${getBichoNome(item.premio_1)}, ${getBichoNome(
        item.premio_2
      )}, ${getBichoNome(item.premio_3)}</td>
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

//Função para retornar Bicho
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

// Função para atualizar os saldos
function atualizarSaldos(saldoTotal, saldoDisponivel) {
  document.getElementById("saldoTotal").innerText = formatCurrency(saldoTotal);
  document.getElementById("saldoDisponivel").innerText =
    formatCurrency(saldoDisponivel);
}

function formatCurrency(value) {
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
  }).format(value);
}
