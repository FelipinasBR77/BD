-- ============================================================
-- CONSULTAS PRINCIPAIS — Sistema de Eventos UPE
-- ============================================================
SET search_path = upe_eventos;

-- ============================================================
-- CONSULTA 01: Listar todos os eventos ativos com detalhes
-- ============================================================
SELECT 
    e.id_evento,
    e.titulo,
    e.status,
    e.data_inicio,
    e.data_fim,
    e.horario_inicio,
    e.horario_fim,
    c.nome AS categoria,
    p.nome AS organizador,
    e.vagas_totais,
    fn_vagas_disponiveis(e.id_evento) AS vagas_disponveis,
    cam.nome AS campus,
    d.nome AS departamento
FROM evento e
JOIN categoria_evento c  ON e.id_categoria = c.id_categoria
JOIN pessoa p             ON e.id_organizador = p.id_pessoa
JOIN campus cam           ON e.id_campus = cam.id_campus
LEFT JOIN departamento d  ON e.id_departamento = d.id_departamento
WHERE e.status IN ('PUBLICADO', 'EM_ANDAMENTO')
ORDER BY e.data_inicio;

-- ============================================================
-- CONSULTA 02: Relatório de inscrições por evento
-- ============================================================
SELECT 
    e.titulo AS evento,
    e.vagas_totais,
    COUNT(i.id_inscricao) FILTER (WHERE i.status = 'CONFIRMADA')   AS confirmados,
    COUNT(i.id_inscricao) FILTER (WHERE i.status = 'LISTA_ESPERA') AS em_espera,
    COUNT(i.id_inscricao) FILTER (WHERE i.status = 'CANCELADA')    AS cancelados,
    COUNT(i.id_inscricao) FILTER (WHERE i.presente = TRUE)         AS presentes,
    ROUND(
        COUNT(i.id_inscricao) FILTER (WHERE i.presente = TRUE) * 100.0 /
        NULLIF(COUNT(i.id_inscricao) FILTER (WHERE i.status = 'CONFIRMADA'), 0), 2
    ) AS percentual_presenca
FROM evento e
LEFT JOIN inscricao i ON e.id_evento = i.id_evento
GROUP BY e.id_evento, e.titulo, e.vagas_totais
ORDER BY e.data_inicio DESC;

-- ============================================================
-- CONSULTA 03: Histórico completo de um participante
-- ============================================================
SELECT 
    p.nome AS participante,
    p.email,
    ev.titulo AS evento,
    ev.data_inicio,
    i.status AS status_inscricao,
    i.presente,
    CASE WHEN c.id_certificado IS NOT NULL 
         THEN 'Sim - ' || c.codigo_validacao 
         ELSE 'Não' END AS certificado,
    c.carga_horaria,
    av.nota AS avaliacao
FROM pessoa p
JOIN inscricao i         ON p.id_pessoa = i.id_pessoa
JOIN evento ev           ON i.id_evento = ev.id_evento
LEFT JOIN certificado c  ON i.id_inscricao = c.id_inscricao
LEFT JOIN avaliacao_evento av ON i.id_inscricao = av.id_inscricao
WHERE p.id_pessoa = 8  -- trocar pelo id desejado
ORDER BY ev.data_inicio DESC;

-- ============================================================
-- CONSULTA 04: Ranking de eventos por média de avaliação
-- ============================================================
SELECT 
    e.titulo,
    e.data_inicio,
    COUNT(av.id_avaliacao)           AS total_avaliacoes,
    ROUND(AVG(av.nota)::NUMERIC, 2)  AS media_nota,
    COUNT(i.id_inscricao) FILTER (WHERE i.status = 'CONFIRMADA') AS total_inscritos,
    COUNT(i.id_inscricao) FILTER (WHERE i.presente = TRUE)       AS total_presentes,
    -- Distribuição das notas
    COUNT(av.nota) FILTER (WHERE av.nota = 5) AS notas_5,
    COUNT(av.nota) FILTER (WHERE av.nota = 4) AS notas_4,
    COUNT(av.nota) FILTER (WHERE av.nota = 3) AS notas_3,
    COUNT(av.nota) FILTER (WHERE av.nota <= 2) AS notas_1_2
FROM evento e
JOIN inscricao i          ON e.id_evento = i.id_evento
LEFT JOIN avaliacao_evento av ON i.id_inscricao = av.id_inscricao
GROUP BY e.id_evento, e.titulo, e.data_inicio
HAVING COUNT(av.id_avaliacao) > 0
ORDER BY media_nota DESC, total_avaliacoes DESC;

-- ============================================================
-- CONSULTA 05: Ocupação dos espaços — conflitos potenciais
-- ============================================================
SELECT 
    es.nome AS espaco,
    es.tipo,
    es.capacidade,
    re.data_uso,
    re.horario_inicio,
    re.horario_fim,
    re.status,
    ev.titulo AS evento_reservado,
    p.nome AS solicitante
FROM reserva_espaco re
JOIN espaco es  ON re.id_espaco = es.id_espaco
JOIN evento ev  ON re.id_evento = ev.id_evento
JOIN pessoa p   ON re.id_solicitante = p.id_pessoa
WHERE re.data_uso >= CURRENT_DATE
ORDER BY es.id_espaco, re.data_uso, re.horario_inicio;

-- ============================================================
-- CONSULTA 06: Programação detalhada de um evento
-- ============================================================
SELECT 
    prog.data,
    prog.horario_inicio,
    prog.horario_fim,
    prog.tipo,
    prog.titulo,
    prog.descricao,
    es.nome AS local,
    STRING_AGG(
        pal.nome || ' (' || pp.papel::TEXT || ')', 
        ', ' ORDER BY pp.papel
    ) AS palestrantes
FROM programacao prog
LEFT JOIN espaco es                   ON prog.id_espaco = es.id_espaco
LEFT JOIN programacao_palestrante pp  ON prog.id_programacao = pp.id_programacao
LEFT JOIN palestrante pal             ON pp.id_palestrante = pal.id_palestrante
WHERE prog.id_evento = 1  -- trocar pelo id do evento
GROUP BY prog.id_programacao, prog.data, prog.horario_inicio, prog.horario_fim,
         prog.tipo, prog.titulo, prog.descricao, es.nome
ORDER BY prog.data, prog.horario_inicio;

-- ============================================================
-- CONSULTA 07: Certificados emitidos por evento com total de horas
-- ============================================================
SELECT 
    ev.titulo AS evento,
    COUNT(c.id_certificado)          AS certificados_emitidos,
    MAX(c.carga_horaria)             AS carga_horaria,
    SUM(c.carga_horaria)             AS total_horas_distribuidas,
    MIN(c.data_emissao)              AS primeira_emissao,
    MAX(c.data_emissao)              AS ultima_emissao
FROM evento ev
JOIN inscricao i      ON ev.id_evento = i.id_evento
JOIN certificado c    ON i.id_inscricao = c.id_inscricao
GROUP BY ev.id_evento, ev.titulo
ORDER BY certificados_emitidos DESC;

-- ============================================================
-- CONSULTA 08: Participantes mais ativos (maior número de presenças)
-- ============================================================
SELECT 
    p.nome,
    p.email,
    p.tipo,
    COUNT(i.id_inscricao)                                              AS total_inscricoes,
    COUNT(i.id_inscricao) FILTER (WHERE i.presente = TRUE)            AS eventos_presentes,
    COUNT(c.id_certificado)                                            AS certificados_obtidos,
    COALESCE(SUM(c.carga_horaria), 0)                                 AS total_horas_certificadas,
    ROUND(AVG(av.nota)::NUMERIC, 2)                                   AS media_avaliacoes_dadas
FROM pessoa p
JOIN inscricao i          ON p.id_pessoa = i.id_pessoa
LEFT JOIN certificado c   ON i.id_inscricao = c.id_inscricao
LEFT JOIN avaliacao_evento av ON i.id_inscricao = av.id_inscricao
GROUP BY p.id_pessoa, p.nome, p.email, p.tipo
ORDER BY total_horas_certificadas DESC, eventos_presentes DESC
LIMIT 20;

-- ============================================================
-- CONSULTA 09: Patrocínios por evento e total arrecadado
-- ============================================================
SELECT 
    ev.titulo AS evento,
    ev.data_inicio,
    COUNT(pt.id_patrocinio)              AS num_patrocinadores,
    SUM(pt.valor) FILTER (WHERE pt.tipo = 'FINANCEIRO') AS total_financeiro,
    COUNT(*) FILTER (WHERE pt.tipo = 'MATERIAL')        AS patrocinios_material,
    COUNT(*) FILTER (WHERE pt.tipo = 'SERVICO')         AS patrocinios_servico,
    STRING_AGG(pats.nome, ', ')                          AS patrocinadores
FROM evento ev
JOIN patrocinio pt    ON ev.id_evento = pt.id_evento
JOIN patrocinador pats ON pt.id_patrocinador = pats.id_patrocinador
GROUP BY ev.id_evento, ev.titulo, ev.data_inicio
ORDER BY total_financeiro DESC NULLS LAST;

-- ============================================================
-- CONSULTA 10: Calendário de eventos — próximos 90 dias
-- ============================================================
SELECT 
    ev.data_inicio,
    ev.data_fim,
    ev.horario_inicio || ' - ' || ev.horario_fim AS horario,
    ev.titulo,
    c.nome AS categoria,
    ev.status,
    fn_vagas_disponiveis(ev.id_evento) AS vagas_restantes,
    cam.nome AS campus,
    STRING_AGG(DISTINCT es.nome, '; ') AS espacos_reservados
FROM evento ev
JOIN categoria_evento c   ON ev.id_categoria = c.id_categoria
JOIN campus cam            ON ev.id_campus = cam.id_campus
LEFT JOIN reserva_espaco re ON ev.id_evento = re.id_evento AND re.status = 'APROVADA'
LEFT JOIN espaco es         ON re.id_espaco = es.id_espaco
WHERE ev.data_inicio BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 days'
  AND ev.status != 'CANCELADO'
GROUP BY ev.id_evento, ev.titulo, ev.data_inicio, ev.data_fim,
         ev.horario_inicio, ev.horario_fim, ev.status, c.nome, cam.nome
ORDER BY ev.data_inicio;

-- ============================================================
-- CONSULTA 11: Dashboard geral do sistema
-- ============================================================
SELECT
    (SELECT COUNT(*) FROM evento)                                       AS total_eventos,
    (SELECT COUNT(*) FROM evento WHERE status IN ('PUBLICADO','EM_ANDAMENTO')) AS eventos_ativos,
    (SELECT COUNT(*) FROM inscricao WHERE status = 'CONFIRMADA')       AS inscricoes_ativas,
    (SELECT COUNT(*) FROM certificado)                                  AS certificados_emitidos,
    (SELECT COUNT(*) FROM pessoa WHERE ativo = TRUE)                   AS usuarios_cadastrados,
    (SELECT COUNT(*) FROM pessoa WHERE tipo = 'ALUNO')                 AS alunos,
    (SELECT COUNT(*) FROM pessoa WHERE tipo = 'PROFESSOR')             AS professores,
    (SELECT COALESCE(SUM(carga_horaria), 0) FROM certificado)          AS total_horas_certificadas,
    (SELECT COALESCE(SUM(valor), 0) FROM patrocinio WHERE tipo = 'FINANCEIRO') AS total_patrocinios_financeiros,
    (SELECT ROUND(AVG(nota)::NUMERIC, 2) FROM avaliacao_evento)        AS media_geral_avaliacoes;

-- ============================================================
-- CONSULTA 12: Espaços mais utilizados
-- ============================================================
SELECT 
    es.nome AS espaco,
    es.tipo,
    es.capacidade,
    COUNT(re.id_reserva) FILTER (WHERE re.status = 'APROVADA') AS total_reservas,
    COUNT(DISTINCT re.id_evento)                                AS eventos_diferentes,
    MIN(re.data_uso)                                            AS primeira_reserva,
    MAX(re.data_uso)                                            AS ultima_reserva,
    cam.nome AS campus
FROM espaco es
JOIN campus cam              ON es.id_campus = cam.id_campus
LEFT JOIN reserva_espaco re  ON es.id_espaco = re.id_espaco
GROUP BY es.id_espaco, es.nome, es.tipo, es.capacidade, cam.nome
ORDER BY total_reservas DESC;

-- ============================================================
-- CONSULTA 13: Notificações não lidas por pessoa
-- ============================================================
SELECT 
    p.nome AS destinatario,
    p.email,
    COUNT(n.id_notificacao) FILTER (WHERE NOT n.lida) AS nao_lidas,
    COUNT(n.id_notificacao)                            AS total_notificacoes,
    MAX(n.data_envio)                                  AS ultima_notificacao
FROM pessoa p
JOIN notificacao n ON p.id_pessoa = n.id_pessoa
GROUP BY p.id_pessoa, p.nome, p.email
HAVING COUNT(n.id_notificacao) FILTER (WHERE NOT n.lida) > 0
ORDER BY nao_lidas DESC;

-- ============================================================
-- CONSULTA 14: Eventos por categoria com estatísticas
-- ============================================================
SELECT 
    c.nome AS categoria,
    COUNT(DISTINCT e.id_evento)                                         AS total_eventos,
    COUNT(DISTINCT i.id_inscricao) FILTER (WHERE i.status = 'CONFIRMADA') AS total_inscritos,
    ROUND(AVG(av.nota)::NUMERIC, 2)                                     AS media_avaliacao,
    COUNT(DISTINCT cert.id_certificado)                                 AS certificados_emitidos
FROM categoria_evento c
LEFT JOIN evento e            ON c.id_categoria = e.id_categoria
LEFT JOIN inscricao i         ON e.id_evento = i.id_evento
LEFT JOIN avaliacao_evento av ON i.id_inscricao = av.id_inscricao
LEFT JOIN certificado cert    ON i.id_inscricao = cert.id_inscricao
GROUP BY c.id_categoria, c.nome
ORDER BY total_eventos DESC;

-- ============================================================
-- CONSULTA 15: Validar certificado pelo código
-- ============================================================
SELECT * FROM fn_validar_certificado('CODIGO_AQUI');

-- Exemplo com código existente (usando subquery):
SELECT * FROM fn_validar_certificado(
    (SELECT codigo_validacao FROM certificado LIMIT 1)
);

-- ============================================================
-- CONSULTA 16: Equipe de organização de um evento
-- ============================================================
SELECT 
    ev.titulo AS evento,
    p.nome AS membro,
    p.email,
    p.tipo AS tipo_usuario,
    eo.funcao
FROM equipe_organizacao eo
JOIN pessoa p  ON eo.id_pessoa = p.id_pessoa
JOIN evento ev ON eo.id_evento = ev.id_evento
WHERE eo.id_evento = 1  -- trocar pelo id
ORDER BY eo.funcao, p.nome;

-- ============================================================
-- CONSULTA 17: Log de auditoria dos últimos eventos alterados
-- ============================================================
SELECT 
    la.executado_em,
    la.operacao,
    la.usuario,
    la.dado_novo ->> 'titulo'  AS evento_titulo,
    la.dado_antigo ->> 'status' AS status_anterior,
    la.dado_novo ->> 'status'   AS status_novo
FROM log_auditoria la
WHERE la.tabela = 'evento'
ORDER BY la.executado_em DESC
LIMIT 30;

-- ============================================================
-- CONSULTA 18: Palestrantes com mais participações
-- ============================================================
SELECT 
    pal.nome AS palestrante,
    pal.instituicao,
    pal.email,
    COUNT(pp.id_prog_palestrante)                                     AS total_participacoes,
    COUNT(DISTINCT prog.id_evento)                                    AS eventos_distintos,
    STRING_AGG(DISTINCT pp.papel::TEXT, ', ')                        AS papeis,
    STRING_AGG(DISTINCT ev.titulo, '; ' ORDER BY ev.titulo)          AS eventos
FROM palestrante pal
JOIN programacao_palestrante pp ON pal.id_palestrante = pp.id_palestrante
JOIN programacao prog            ON pp.id_programacao = prog.id_programacao
JOIN evento ev                  ON prog.id_evento = ev.id_evento
GROUP BY pal.id_palestrante, pal.nome, pal.instituicao, pal.email
ORDER BY total_participacoes DESC;

-- ============================================================
-- CONSULTA 19: Alunos que nunca se inscreveram em nenhum evento
-- ============================================================
SELECT 
    p.nome, p.email, p.tipo,
    a.matricula, a.curso, a.periodo,
    d.nome AS departamento
FROM pessoa p
JOIN aluno a         ON p.id_pessoa = a.id_pessoa
LEFT JOIN departamento d ON a.id_departamento = d.id_departamento
WHERE NOT EXISTS (
    SELECT 1 FROM inscricao i WHERE i.id_pessoa = p.id_pessoa
)
ORDER BY a.curso, p.nome;

-- ============================================================
-- CONSULTA 20: Recursos mais solicitados e disponibilidade
-- ============================================================
SELECT 
    r.nome AS recurso,
    r.tipo,
    r.quantidade_disponivel,
    COUNT(sr.id_solicitacao)                                            AS total_solicitacoes,
    SUM(sr.quantidade_solicitada) FILTER (WHERE sr.status = 'APROVADA') AS qtd_em_uso,
    r.quantidade_disponivel - 
        COALESCE(SUM(sr.quantidade_solicitada) FILTER (WHERE sr.status = 'APROVADA'), 0) AS disponivel_agora
FROM recurso r
LEFT JOIN solicitacao_recurso sr ON r.id_recurso = sr.id_recurso
GROUP BY r.id_recurso, r.nome, r.tipo, r.quantidade_disponivel
ORDER BY total_solicitacoes DESC;
