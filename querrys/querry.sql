-- Clientes que Assistiram Filmes
SELECT P.nome
FROM Pessoa P
WHERE P.cpf IN (
    SELECT A.cpf_cliente 
    FROM Assiste A
    WHERE A.id_sessao IN (
        SELECT S.id_sessao 
        FROM Sessao S
        JOIN Filme F ON S.id_filme = F.id_filme
    )
);
-- ou
select p.nome, f.titulo as titulo_filme
from pessoa as p 
join assiste as a on p.cpf = a.cpf_cliente
join sessao as s on a.id_sessao = s.id_sessao
join filme as f on s.id_filme = f.id_filme;



-- Relatório de Limpezas Noturnas por Sala
SELECT 
    L.numero_sala,
    COUNT(*) AS qtd_limpezas
FROM 
    Limpa L
WHERE 
    L.hora_limpeza >= '18:00:00'
GROUP BY 
    L.numero_sala
HAVING 
    COUNT(*) >= 1;



-- Relatório de Desempenho dos Vendedores
SELECT 
    P.nome,
    COUNT(V.id_produto) AS qtd_vendas,
    CASE 
        WHEN COUNT(V.id_produto) >= 1 THEN 'Vendeu Algo'
        ELSE 'Nenhuma Venda'
    END AS status_desempenho
FROM 
    Pessoa P
    JOIN Funcionario F ON P.cpf = F.cpf_funcionario
    JOIN Vendedor Ven ON F.cpf_funcionario = Ven.cpf_vendedor
    LEFT JOIN Vende V ON Ven.cpf_vendedor = V.cpf_vendedor
GROUP BY 
    P.nome, P.cpf
ORDER BY 
    qtd_vendas DESC;


-- Produtos Não Vendidos
SELECT 
    Pr.id_produto,
    COALESCE(C.nome_comida, I.nome_ingresso) AS nome_produto,
    CASE 
        WHEN C.id_produto IS NOT NULL THEN 'Comida' 
        ELSE 'Ingresso' 
    END AS tipo_produto
FROM 
    Produto Pr
    LEFT JOIN Vende V ON Pr.id_produto = V.id_produto
    LEFT JOIN Comida C ON Pr.id_produto = C.id_produto
    LEFT JOIN Ingresso I ON Pr.id_produto = I.id_produto
WHERE 
    V.cpf_vendedor IS NULL;



-- Faturamento por Sessão
WITH FaturamentoSessao AS (
    SELECT 
        S.id_sessao,
        F.titulo,
        SUM(I.preco_ingresso) AS total_arrecadado
    FROM 
        Sessao S
        JOIN Filme F ON S.id_filme = F.id_filme
        JOIN Ingresso I ON S.id_sessao = I.id_sessao
    GROUP BY 
        S.id_sessao, F.titulo
)
SELECT 
    titulo,
    total_arrecadado
FROM 
    FaturamentoSessao
WHERE 
    total_arrecadado > 0;
-- ou
select f.titulo, sum(i.preco_ingresso) as total_arrecadado
from filme as f 
join sessao as s on s.id_filme = f.id_filme
join ingresso as i on i.id_sessao = s.id_sessao
group by f.titulo
order by total_arrecadado desc;



