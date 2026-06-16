-- ============================================================
-- TESTES — Sistema de Gerenciamento de Eventos UPE
-- ============================================================
SET search_path = upe_eventos;

-- Bloco auxiliar para imprimir resultados dos testes
DO $$
BEGIN RAISE NOTICE '====================================================='; END $$;
DO $$
BEGIN RAISE NOTICE '  SUITE DE TESTES — UPE EVENTOS'; END $$;
DO $$
BEGIN RAISE NOTICE '====================================================='; END $$;

-- ============================================================
-- TEST SUITE 1: INTEGRIDADE DOS DADOS
-- ============================================================

-- TESTE 1.1: Verifica se todas as tabelas foram criadas
DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM information_schema.tables
    WHERE table_schema = 'upe_eventos'
      AND table_type = 'BASE TABLE';

    IF v_count >= 20 THEN
        RAISE NOTICE '[PASS] TESTE 1.1 — Tabelas criadas: % (mínimo 20)', v_count;
    ELSE
        RAISE WARNING '[FAIL] TESTE 1.1 — Apenas % tabelas criadas (mínimo 20)', v_count;
    END IF;
END $$;

-- TESTE 1.2: Verifica se views foram criadas
DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM information_schema.views
    WHERE table_schema = 'upe_eventos';

    IF v_count >= 6 THEN
        RAISE NOTICE '[PASS] TESTE 1.2 — Views criadas: %', v_count;
    ELSE
        RAISE WARNING '[FAIL] TESTE 1.2 — Apenas % views criadas', v_count;
    END IF;
END $$;

-- TESTE 1.3: Verifica se dados foram inseridos nos seeders
DO $$
DECLARE
    v_campus INT; v_pessoas INT; v_eventos INT;
BEGIN
    SELECT COUNT(*) INTO v_campus  FROM campus;
    SELECT COUNT(*) INTO v_pessoas FROM pessoa;
    SELECT COUNT(*) INTO v_eventos FROM evento;

    IF v_campus >= 5 AND v_pessoas >= 15 AND v_eventos >= 5 THEN
        RAISE NOTICE '[PASS] TESTE 1.3 — Seeders OK: % campus, % pessoas, % eventos', v_campus, v_pessoas, v_eventos;
    ELSE
        RAISE WARNING '[FAIL] TESTE 1.3 — Dados insuficientes nos seeders';
    END IF;
END $$;

-- TESTE 1.4: CPF único — tenta inserir CPF duplicado
DO $$
BEGIN
    BEGIN
        INSERT INTO pessoa(nome, cpf, email, telefone, tipo)
        VALUES ('Teste Duplicado', '111.222.333-01', 'duplicado@test.com', '', 'ALUNO');
        RAISE WARNING '[FAIL] TESTE 1.4 — CPF duplicado foi aceito (deveria falhar)';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE '[PASS] TESTE 1.4 — CPF duplicado corretamente rejeitado';
    END;
END $$;

-- TESTE 1.5: Data fim >= data início
DO $$
BEGIN
    BEGIN
        INSERT INTO evento(titulo, data_inicio, data_fim, horario_inicio, horario_fim,
                           vagas_totais, id_categoria, id_organizador, id_campus)
        VALUES ('Evento Inválido', '2025-05-10', '2025-05-01', '08:00', '12:00',
                100, 1, 1, 1);
        RAISE WARNING '[FAIL] TESTE 1.5 — Evento com data_fim < data_inicio foi aceito';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE '[PASS] TESTE 1.5 — Constraint de datas funcionando corretamente';
    END;
END $$;

-- TESTE 1.6: Nota da avaliação entre 1 e 5
DO $$
DECLARE
    v_inscricao_teste INT;
BEGIN
    -- pegar uma inscrição sem avaliação
    SELECT id_inscricao INTO v_inscricao_teste
    FROM inscricao i
    WHERE NOT EXISTS (SELECT 1 FROM avaliacao_evento a WHERE a.id_inscricao = i.id_inscricao)
    LIMIT 1;

    BEGIN
        INSERT INTO avaliacao_evento(nota, id_inscricao) VALUES (6, v_inscricao_teste);
        RAISE WARNING '[FAIL] TESTE 1.6 — Nota 6 foi aceita (deve ser entre 1 e 5)';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE '[PASS] TESTE 1.6 — Constraint de nota funcionando';
    END;
END $$;

-- ============================================================
-- TEST SUITE 2: TRIGGERS
-- ============================================================

-- TESTE 2.1: Trigger — Certificado sem presença deve falhar
DO $$
DECLARE
    v_inscricao_sem_presenca INT;
BEGIN
    SELECT id_inscricao INTO v_inscricao_sem_presenca
    FROM inscricao
    WHERE presente = FALSE AND status = 'CONFIRMADA'
    LIMIT 1;

    IF v_inscricao_sem_presenca IS NULL THEN
        RAISE NOTICE '[SKIP] TESTE 2.1 — Nenhuma inscrição sem presença encontrada';
        RETURN;
    END IF;

    BEGIN
        INSERT INTO certificado(carga_horaria, id_inscricao)
        VALUES (8, v_inscricao_sem_presenca);
        RAISE WARNING '[FAIL] TESTE 2.1 — Certificado emitido sem presença';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '[PASS] TESTE 2.1 — Trigger bloqueou emissão de certificado sem presença';
    END;
END $$;

-- TESTE 2.2: Trigger — Conflito de reserva de espaço
DO $$
DECLARE
    v_id_evento_novo INT;
    v_pessoa_org INT;
BEGIN
    SELECT id_pessoa INTO v_pessoa_org FROM pessoa LIMIT 1;

    INSERT INTO evento(titulo, data_inicio, data_fim, horario_inicio, horario_fim,
                       vagas_totais, id_categoria, id_organizador, id_campus)
    VALUES ('Evento Teste Conflito', '2024-11-11', '2024-11-11', '08:00', '22:00',
            10, 1, v_pessoa_org, 1)
    RETURNING id_evento INTO v_id_evento_novo;

    BEGIN
        -- Tenta reservar espaço 1 no mesmo dia/horário já reservado
        INSERT INTO reserva_espaco(data_uso, horario_inicio, horario_fim, status, id_espaco, id_evento, id_solicitante)
        VALUES ('2024-11-11', '08:00', '22:00', 'APROVADA', 1, v_id_evento_novo, v_pessoa_org);
        RAISE WARNING '[FAIL] TESTE 2.2 — Conflito de reserva não foi detectado';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '[PASS] TESTE 2.2 — Trigger bloqueou conflito de reserva de espaço';
    END;

    DELETE FROM evento WHERE id_evento = v_id_evento_novo;
END $$;

-- TESTE 2.3: Trigger — Inscrição em evento lotado vai para lista de espera
DO $$
DECLARE
    v_id_evento_cheio INT;
    v_pessoa_nova INT;
    v_status_inscricao status_inscricao;
BEGIN
    -- Criar evento com 1 vaga
    INSERT INTO evento(titulo, data_inicio, data_fim, horario_inicio, horario_fim,
                       vagas_totais, status, id_categoria, id_organizador, id_campus)
    VALUES ('Evento Vaga Única', '2025-12-01', '2025-12-01', '09:00', '12:00',
            1, 'PUBLICADO', 1, 1, 1)
    RETURNING id_evento INTO v_id_evento_cheio;

    -- Inserir pessoa temporária
    INSERT INTO pessoa(nome, cpf, email, tipo)
    VALUES ('Temp A', '999.000.001-01', 'tempa@test.com', 'EXTERNO')
    RETURNING id_pessoa INTO v_pessoa_nova;

    -- Inscrição 1 — deve ser CONFIRMADA
    INSERT INTO inscricao(id_evento, id_pessoa) VALUES (v_id_evento_cheio, v_pessoa_nova);

    -- Inserir segunda pessoa
    INSERT INTO pessoa(nome, cpf, email, tipo)
    VALUES ('Temp B', '999.000.002-02', 'tempb@test.com', 'EXTERNO');

    -- Inscrição 2 — deve ir para LISTA_ESPERA
    INSERT INTO inscricao(id_evento, id_pessoa)
    SELECT v_id_evento_cheio, id_pessoa FROM pessoa WHERE email = 'tempb@test.com';

    SELECT status INTO v_status_inscricao
    FROM inscricao i
    JOIN pessoa p ON i.id_pessoa = p.id_pessoa
    WHERE p.email = 'tempb@test.com' AND i.id_evento = v_id_evento_cheio;

    IF v_status_inscricao = 'LISTA_ESPERA' THEN
        RAISE NOTICE '[PASS] TESTE 2.3 — Trigger moveu inscrição para lista de espera corretamente';
    ELSE
        RAISE WARNING '[FAIL] TESTE 2.3 — Status: %, deveria ser LISTA_ESPERA', v_status_inscricao;
    END IF;

    -- Limpeza
    DELETE FROM inscricao WHERE id_evento = v_id_evento_cheio;
    DELETE FROM evento WHERE id_evento = v_id_evento_cheio;
    DELETE FROM pessoa WHERE email IN ('tempa@test.com', 'tempb@test.com');
END $$;

-- TESTE 2.4: Trigger — Promoção da lista de espera ao cancelar inscrição
DO $$
DECLARE
    v_id_evento INT;
    v_pessoa1 INT; v_pessoa2 INT;
    v_status_depois status_inscricao;
BEGIN
    INSERT INTO evento(titulo, data_inicio, data_fim, horario_inicio, horario_fim,
                       vagas_totais, status, id_categoria, id_organizador, id_campus)
    VALUES ('Evento Promoção Espera', '2025-12-10', '2025-12-10', '09:00', '11:00',
            1, 'PUBLICADO', 1, 1, 1)
    RETURNING id_evento INTO v_id_evento;

    INSERT INTO pessoa(nome, cpf, email, tipo) VALUES ('Temp C', '999.000.003-03', 'tempc@t.com', 'EXTERNO') RETURNING id_pessoa INTO v_pessoa1;
    INSERT INTO pessoa(nome, cpf, email, tipo) VALUES ('Temp D', '999.000.004-04', 'tempd@t.com', 'EXTERNO') RETURNING id_pessoa INTO v_pessoa2;

    INSERT INTO inscricao(id_evento, id_pessoa) VALUES (v_id_evento, v_pessoa1); -- CONFIRMADA
    INSERT INTO inscricao(id_evento, id_pessoa) VALUES (v_id_evento, v_pessoa2); -- LISTA_ESPERA

    -- Cancelar a primeira
    UPDATE inscricao SET status = 'CANCELADA' WHERE id_evento = v_id_evento AND id_pessoa = v_pessoa1;

    -- Verificar se a segunda foi promovida
    SELECT status INTO v_status_depois FROM inscricao WHERE id_evento = v_id_evento AND id_pessoa = v_pessoa2;

    IF v_status_depois = 'CONFIRMADA' THEN
        RAISE NOTICE '[PASS] TESTE 2.4 — Trigger promoveu da lista de espera com sucesso';
    ELSE
        RAISE WARNING '[FAIL] TESTE 2.4 — Status: %, deveria ser CONFIRMADA', v_status_depois;
    END IF;

    DELETE FROM notificacao WHERE id_evento = v_id_evento;
    DELETE FROM inscricao WHERE id_evento = v_id_evento;
    DELETE FROM evento WHERE id_evento = v_id_evento;
    DELETE FROM pessoa WHERE id_pessoa IN (v_pessoa1, v_pessoa2);
END $$;

-- TESTE 2.5: Trigger — Log de auditoria registra UPDATE no evento
DO $$
DECLARE
    v_logs_antes INT;
    v_logs_depois INT;
BEGIN
    SELECT COUNT(*) INTO v_logs_antes FROM log_auditoria WHERE tabela = 'evento' AND operacao = 'UPDATE';

    UPDATE evento SET descricao = descricao WHERE id_evento = 1;

    SELECT COUNT(*) INTO v_logs_depois FROM log_auditoria WHERE tabela = 'evento' AND operacao = 'UPDATE';

    IF v_logs_depois > v_logs_antes THEN
        RAISE NOTICE '[PASS] TESTE 2.5 — Trigger de auditoria registrou UPDATE no evento';
    ELSE
        RAISE WARNING '[FAIL] TESTE 2.5 — Trigger de auditoria não funcionou';
    END IF;
END $$;

-- ============================================================
-- TEST SUITE 3: STORED PROCEDURES E FUNCTIONS
-- ============================================================

-- TESTE 3.1: sp_inscrever_pessoa — inscrição válida
DO $$
DECLARE
    v_pessoa_temp INT;
    v_id_evento_publicado INT;
    v_count INT;
BEGIN
    SELECT id_evento INTO v_id_evento_publicado FROM evento WHERE status = 'PUBLICADO' LIMIT 1;

    INSERT INTO pessoa(nome, cpf, email, tipo)
    VALUES ('Temp Proc', '888.000.001-01', 'temp.proc@test.com', 'EXTERNO')
    RETURNING id_pessoa INTO v_pessoa_temp;

    CALL sp_inscrever_pessoa(v_id_evento_publicado, v_pessoa_temp);

    SELECT COUNT(*) INTO v_count FROM inscricao WHERE id_evento = v_id_evento_publicado AND id_pessoa = v_pessoa_temp;

    IF v_count = 1 THEN
        RAISE NOTICE '[PASS] TESTE 3.1 — sp_inscrever_pessoa funcionou corretamente';
    ELSE
        RAISE WARNING '[FAIL] TESTE 3.1 — Inscrição não foi criada';
    END IF;

    -- Limpeza
    DELETE FROM notificacao WHERE id_pessoa = v_pessoa_temp;
    DELETE FROM inscricao WHERE id_pessoa = v_pessoa_temp;
    DELETE FROM pessoa WHERE id_pessoa = v_pessoa_temp;
END $$;

-- TESTE 3.2: sp_inscrever_pessoa — inscrição em evento cancelado deve falhar
DO $$
DECLARE
    v_id_evento_cancelado INT;
    v_pessoa_temp INT;
BEGIN
    -- criar evento cancelado
    INSERT INTO evento(titulo, data_inicio, data_fim, horario_inicio, horario_fim,
                       vagas_totais, status, id_categoria, id_organizador, id_campus)
    VALUES ('Evento Cancelado Teste', '2025-01-01', '2025-01-01', '09:00', '11:00',
            10, 'CANCELADO', 1, 1, 1)
    RETURNING id_evento INTO v_id_evento_cancelado;

    INSERT INTO pessoa(nome, cpf, email, tipo)
    VALUES ('Temp Canc', '777.000.001-01', 'temp.canc@test.com', 'EXTERNO')
    RETURNING id_pessoa INTO v_pessoa_temp;

    BEGIN
        CALL sp_inscrever_pessoa(v_id_evento_cancelado, v_pessoa_temp);
        RAISE WARNING '[FAIL] TESTE 3.2 — Inscrição em evento cancelado foi aceita';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '[PASS] TESTE 3.2 — sp_inscrever_pessoa rejeitou evento cancelado';
    END;

    DELETE FROM pessoa WHERE id_pessoa = v_pessoa_temp;
    DELETE FROM log_auditoria WHERE id_registro = v_id_evento_cancelado;
    DELETE FROM evento WHERE id_evento = v_id_evento_cancelado;
END $$;

-- TESTE 3.3: fn_vagas_disponiveis — retorna valor correto
DO $$
DECLARE
    v_vagas INT;
    v_esperado INT;
    v_id_evento INT := 1;
BEGIN
    SELECT vagas_totais - COUNT(i.id_inscricao) FILTER (WHERE i.status = 'CONFIRMADA')
    INTO v_esperado
    FROM evento e
    LEFT JOIN inscricao i ON e.id_evento = i.id_evento
    WHERE e.id_evento = v_id_evento
    GROUP BY e.vagas_totais;

    v_vagas := fn_vagas_disponiveis(v_id_evento);

    IF v_vagas = v_esperado THEN
        RAISE NOTICE '[PASS] TESTE 3.3 — fn_vagas_disponiveis retornou % (correto)', v_vagas;
    ELSE
        RAISE WARNING '[FAIL] TESTE 3.3 — Esperado %, obtido %', v_esperado, v_vagas;
    END IF;
END $$;

-- TESTE 3.4: fn_validar_certificado — código válido retorna dados
DO $$
DECLARE
    v_codigo VARCHAR;
    v_result RECORD;
BEGIN
    SELECT codigo_validacao INTO v_codigo FROM certificado LIMIT 1;

    SELECT * INTO v_result FROM fn_validar_certificado(v_codigo);

    IF v_result IS NOT NULL THEN
        RAISE NOTICE '[PASS] TESTE 3.4 — fn_validar_certificado retornou: participante=%, evento=%',
            v_result.participante, v_result.evento;
    ELSE
        RAISE WARNING '[FAIL] TESTE 3.4 — fn_validar_certificado retornou vazio';
    END IF;
END $$;

-- TESTE 3.5: sp_emitir_certificados — emite certificados em lote
DO $$
DECLARE
    v_id_evento INT;
    v_antes INT;
    v_depois INT;
BEGIN
    -- Criar evento concluído com inscritos presentes sem certificado
    INSERT INTO evento(titulo, data_inicio, data_fim, horario_inicio, horario_fim,
                       vagas_totais, status, id_categoria, id_organizador, id_campus)
    VALUES ('Evento Cert Lote', '2024-06-01', '2024-06-01', '09:00', '12:00',
            10, 'CONCLUIDO', 1, 1, 1)
    RETURNING id_evento INTO v_id_evento;

    -- inscrição com presença
    INSERT INTO inscricao(id_evento, id_pessoa, status, presente) VALUES (v_id_evento, 16, 'CONFIRMADA', TRUE);
    INSERT INTO inscricao(id_evento, id_pessoa, status, presente) VALUES (v_id_evento, 17, 'CONFIRMADA', TRUE);

    SELECT COUNT(*) INTO v_antes FROM certificado;
    CALL sp_emitir_certificados(v_id_evento, 3.0);
    SELECT COUNT(*) INTO v_depois FROM certificado;

    IF v_depois = v_antes + 2 THEN
        RAISE NOTICE '[PASS] TESTE 3.5 — sp_emitir_certificados emitiu % certificados', v_depois - v_antes;
    ELSE
        RAISE WARNING '[FAIL] TESTE 3.5 — Esperado +2, obteve +%', v_depois - v_antes;
    END IF;

    -- Limpeza
    DELETE FROM certificado WHERE id_inscricao IN (SELECT id_inscricao FROM inscricao WHERE id_evento = v_id_evento);
    DELETE FROM inscricao WHERE id_evento = v_id_evento;
    DELETE FROM log_auditoria WHERE id_registro = v_id_evento;
    DELETE FROM evento WHERE id_evento = v_id_evento;
END $$;

-- ============================================================
-- TEST SUITE 4: VIEWS
-- ============================================================

-- TESTE 4.1: vw_eventos_ativos retorna apenas publicados/em andamento
DO $$
DECLARE
    v_invalidos INT;
BEGIN
    SELECT COUNT(*) INTO v_invalidos
    FROM vw_eventos_ativos
    WHERE status NOT IN ('PUBLICADO', 'EM_ANDAMENTO');

    IF v_invalidos = 0 THEN
        RAISE NOTICE '[PASS] TESTE 4.1 — vw_eventos_ativos retorna apenas eventos corretos';
    ELSE
        RAISE WARNING '[FAIL] TESTE 4.1 — View retornou % eventos com status inválido', v_invalidos;
    END IF;
END $$;

-- TESTE 4.2: vw_resumo_eventos calcula vagas_disponiveis corretamente
DO $$
DECLARE
    v_incorretos INT;
BEGIN
    SELECT COUNT(*) INTO v_incorretos
    FROM vw_resumo_eventos
    WHERE vagas_disponiveis < 0;

    IF v_incorretos = 0 THEN
        RAISE NOTICE '[PASS] TESTE 4.2 — vw_resumo_eventos não tem vagas negativas';
    ELSE
        RAISE WARNING '[FAIL] TESTE 4.2 — % eventos com vagas negativas na view', v_incorretos;
    END IF;
END $$;

-- TESTE 4.3: vw_certificados_emitidos retorna todos os certificados
DO $$
DECLARE
    v_view_count INT;
    v_table_count INT;
BEGIN
    SELECT COUNT(*) INTO v_view_count  FROM vw_certificados_emitidos;
    SELECT COUNT(*) INTO v_table_count FROM certificado;

    IF v_view_count = v_table_count THEN
        RAISE NOTICE '[PASS] TESTE 4.3 — vw_certificados_emitidos conta correta: %', v_view_count;
    ELSE
        RAISE WARNING '[FAIL] TESTE 4.3 — View: %, Tabela: %', v_view_count, v_table_count;
    END IF;
END $$;
DO $$
BEGIN
    RAISE NOTICE '=====================================================';
    RAISE NOTICE '  TESTES CONCLUÍDOS — Verifique mensagens PASS/FAIL';
    RAISE NOTICE '=====================================================';
END $$;
