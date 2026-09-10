SELECT
    a.nome AS nome_associado,
    a.sobrenome AS sobrenome_associado,
    CAST(a.idade AS STRING) AS idade_associado,
    CAST(m.vlr_transacao AS STRING) AS vlr_transacao_movimento,
    m.des_transacao AS des_transacao_movimento,
    date_format(m.data_movimento, 'yyyy-MM-dd HH:mm:ss') AS data_movimento,
    c.num_cartao AS numero_cartao,
    c.nom_impresso AS nome_impresso_cartao,
    date_format(c.data_criacao, 'yyyy-MM-dd HH:mm:ss') AS data_criacao_cartao,
    t.tipo AS tipo_conta,
    date_format(t.data_criacao, 'yyyy-MM-dd HH:mm:ss') AS data_criacao_conta
FROM movimento m
JOIN cartao c ON m.id_cartao = c.id
JOIN conta t ON c.id_conta = t.id
JOIN associado a ON c.id_associado = a.id
ORDER BY m.id
