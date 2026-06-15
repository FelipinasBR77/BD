-- ============================================================
-- SISTEMA DE GERENCIAMENTO DE EVENTOS - UPE
-- ============================================================

-- Limpar esquema se necessário
DROP SCHEMA IF EXISTS upe_eventos CASCADE;
CREATE SCHEMA upe_eventos;
SET search_path = upe_eventos;

-- ============================================================
-- EXTENSÕES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- ============================================================
-- TIPOS ENUMERADOS
-- ============================================================
CREATE TYPE tipo_pessoa       AS ENUM ('ALUNO','PROFESSOR','SERVIDOR','EXTERNO');
CREATE TYPE tipo_espaco       AS ENUM ('AUDITORIO','SALA','LABORATORIO','QUADRA','AREA_EXTERNA');
CREATE TYPE status_evento     AS ENUM ('RASCUNHO','PUBLICADO','EM_ANDAMENTO','CONCLUIDO','CANCELADO');
CREATE TYPE status_reserva    AS ENUM ('PENDENTE','APROVADA','RECUSADA','CANCELADA');
CREATE TYPE status_inscricao  AS ENUM ('CONFIRMADA','LISTA_ESPERA','CANCELADA');
CREATE TYPE tipo_programacao  AS ENUM ('PALESTRA','WORKSHOP','MESA_REDONDA','APRESENTACAO','INTERVALO');
CREATE TYPE papel_palestrante AS ENUM ('PALESTRANTE','MEDIADOR','DEBATEDOR');
CREATE TYPE tipo_patrocinio   AS ENUM ('FINANCEIRO','MATERIAL','SERVICO');
CREATE TYPE tipo_recurso      AS ENUM ('EQUIPAMENTO','MATERIAL','SERVICO');
CREATE TYPE status_solicitacao AS ENUM ('PENDENTE','APROVADA','RECUSADA');
CREATE TYPE tipo_notificacao  AS ENUM ('EMAIL','SMS','SISTEMA');
CREATE TYPE funcao_equipe     AS ENUM ('COORDENADOR','VOLUNTARIO','APOIO','SECRETARIA');
CREATE TYPE titulacao_prof    AS ENUM ('GRADUACAO','ESPECIALIZACAO','MESTRADO','DOUTORADO','POS_DOUTORADO');

-- ============================================================
-- TABELA 01: CAMPUS
-- ============================================================
CREATE TABLE campus (
    id_campus           SERIAL PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    endereco            VARCHAR(200) NOT NULL,
    cidade              VARCHAR(100) NOT NULL DEFAULT 'Recife',
    telefone            VARCHAR(20),
    email_institucional VARCHAR(100) UNIQUE,
    criado_em           TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABELA 02: DEPARTAMENTO
-- ============================================================
CREATE TABLE departamento (
    id_departamento SERIAL PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL,
    sigla           VARCHAR(20)  NOT NULL,
    id_campus       INT NOT NULL REFERENCES campus(id_campus) ON DELETE RESTRICT,
    criado_em       TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- TABELA 03: PESSOA
-- ============================================================
CREATE TABLE pessoa (
    id_pessoa      SERIAL PRIMARY KEY,
    nome           VARCHAR(150) NOT NULL,
    cpf            VARCHAR(14)  NOT NULL UNIQUE,
    email          VARCHAR(100) NOT NULL UNIQUE,
    telefone       VARCHAR(20),
    tipo           tipo_pessoa  NOT NULL,
    ativo          BOOLEAN      DEFAULT TRUE,
    data_cadastro  TIMESTAMP    DEFAULT NOW()
);

-- ============================================================
-- TABELA 04: ALUNO
-- ============================================================
CREATE TABLE aluno (
    id_aluno        SERIAL PRIMARY KEY,
    id_pessoa       INT NOT NULL UNIQUE REFERENCES pessoa(id_pessoa) ON DELETE CASCADE,
    matricula       VARCHAR(20) NOT NULL UNIQUE,
    curso           VARCHAR(100) NOT NULL,
    periodo         SMALLINT CHECK (periodo BETWEEN 1 AND 12),
    id_departamento INT REFERENCES departamento(id_departamento)
);

-- ============================================================
-- TABELA 05: PROFESSOR
-- ============================================================
CREATE TABLE professor (
    id_professor    SERIAL PRIMARY KEY,
    id_pessoa       INT NOT NULL UNIQUE REFERENCES pessoa(id_pessoa) ON DELETE CASCADE,
    siape           VARCHAR(20) NOT NULL UNIQUE,
    titulacao       titulacao_prof NOT NULL,
    id_departamento INT REFERENCES departamento(id_departamento)
);

-- ============================================================
-- TABELA 06: SERVIDOR
-- ============================================================
CREATE TABLE servidor (
    id_servidor     SERIAL PRIMARY KEY,
    id_pessoa       INT NOT NULL UNIQUE REFERENCES pessoa(id_pessoa) ON DELETE CASCADE,
    matricula_siape VARCHAR(20) NOT NULL UNIQUE,
    cargo           VARCHAR(100) NOT NULL,
    id_departamento INT REFERENCES departamento(id_departamento)
);

-- ============================================================
-- TABELA 07: ESPACO
-- ============================================================
CREATE TABLE espaco (
    id_espaco            SERIAL PRIMARY KEY,
    nome                 VARCHAR(100) NOT NULL,
    tipo                 tipo_espaco  NOT NULL,
    capacidade           INT NOT NULL CHECK (capacidade > 0),
    localizacao          VARCHAR(200),
    recursos_disponiveis TEXT,
    ativo                BOOLEAN DEFAULT TRUE,
    id_campus            INT NOT NULL REFERENCES campus(id_campus)
);

-- ============================================================
-- TABELA 08: CATEGORIA_EVENTO
-- ============================================================
CREATE TABLE categoria_evento (
    id_categoria SERIAL PRIMARY KEY,
    nome         VARCHAR(100) NOT NULL UNIQUE,
    descricao    TEXT
);

-- ============================================================
-- TABELA 09: EVENTO
-- ============================================================
CREATE TABLE evento (
    id_evento       SERIAL PRIMARY KEY,
    titulo          VARCHAR(200) NOT NULL,
    descricao       TEXT,
    data_inicio     DATE NOT NULL,
    data_fim        DATE NOT NULL,
    horario_inicio  TIME NOT NULL,
    horario_fim     TIME NOT NULL,
    status          status_evento NOT NULL DEFAULT 'RASCUNHO',
    publico_alvo    VARCHAR(200),
    vagas_totais    INT  NOT NULL CHECK (vagas_totais > 0),
    id_categoria    INT  NOT NULL REFERENCES categoria_evento(id_categoria),
    id_organizador  INT  NOT NULL REFERENCES pessoa(id_pessoa),
    id_departamento INT  REFERENCES departamento(id_departamento),
    id_campus       INT  NOT NULL REFERENCES campus(id_campus),
    data_criacao    TIMESTAMP DEFAULT NOW(),
    data_atualizacao TIMESTAMP DEFAULT NOW(),
    CONSTRAINT ck_datas_evento CHECK (data_fim >= data_inicio)
);

-- ============================================================
-- TABELA 10: EDICAO_EVENTO
-- ============================================================
CREATE TABLE edicao_evento (
    id_edicao       SERIAL PRIMARY KEY,
    numero_edicao   INT NOT NULL,
    ano             INT NOT NULL CHECK (ano >= 2000),
    id_evento       INT NOT NULL REFERENCES evento(id_evento) ON DELETE CASCADE,
    UNIQUE (numero_edicao, id_evento)
);

-- ============================================================
-- TABELA 11: RESERVA_ESPACO
-- ============================================================
CREATE TABLE reserva_espaco (
    id_reserva      SERIAL PRIMARY KEY,
    data_reserva    TIMESTAMP DEFAULT NOW(),
    data_uso        DATE NOT NULL,
    horario_inicio  TIME NOT NULL,
    horario_fim     TIME NOT NULL,
    status          status_reserva NOT NULL DEFAULT 'PENDENTE',
    justificativa   TEXT,
    id_espaco       INT NOT NULL REFERENCES espaco(id_espaco),
    id_evento       INT NOT NULL REFERENCES evento(id_evento) ON DELETE CASCADE,
    id_solicitante  INT NOT NULL REFERENCES pessoa(id_pessoa),
    CONSTRAINT ck_horarios_reserva CHECK (horario_fim > horario_inicio)
);

-- ============================================================
-- TABELA 12: INSCRICAO
-- ============================================================
CREATE TABLE inscricao (
    id_inscricao    SERIAL PRIMARY KEY,
    data_inscricao  TIMESTAMP DEFAULT NOW(),
    status          status_inscricao NOT NULL DEFAULT 'CONFIRMADA',
    presente        BOOLEAN DEFAULT FALSE,
    id_evento       INT NOT NULL REFERENCES evento(id_evento) ON DELETE CASCADE,
    id_pessoa       INT NOT NULL REFERENCES pessoa(id_pessoa),
    UNIQUE (id_evento, id_pessoa)
);

-- ============================================================
-- TABELA 13: CERTIFICADO
-- ============================================================
CREATE TABLE certificado (
    id_certificado    SERIAL PRIMARY KEY,
    codigo_validacao  VARCHAR(50) NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(16), 'hex'),
    data_emissao      TIMESTAMP DEFAULT NOW(),
    carga_horaria     DECIMAL(5,2) NOT NULL CHECK (carga_horaria > 0),
    url_pdf           VARCHAR(300),
    id_inscricao      INT NOT NULL UNIQUE REFERENCES inscricao(id_inscricao)
);

-- ============================================================
-- TABELA 14: PALESTRANTE
-- ============================================================
CREATE TABLE palestrante (
    id_palestrante  SERIAL PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL,
    instituicao     VARCHAR(150),
    mini_bio        TEXT,
    email           VARCHAR(100) UNIQUE,
    linkedin        VARCHAR(200),
    foto_url        VARCHAR(300)
);

-- ============================================================
-- TABELA 15: PROGRAMACAO
-- ============================================================
CREATE TABLE programacao (
    id_programacao  SERIAL PRIMARY KEY,
    titulo          VARCHAR(200) NOT NULL,
    descricao       TEXT,
    data            DATE NOT NULL,
    horario_inicio  TIME NOT NULL,
    horario_fim     TIME NOT NULL,
    tipo            tipo_programacao NOT NULL,
    id_evento       INT NOT NULL REFERENCES evento(id_evento) ON DELETE CASCADE,
    id_espaco       INT REFERENCES espaco(id_espaco),
    CONSTRAINT ck_horarios_prog CHECK (horario_fim > horario_inicio)
);

-- ============================================================
-- TABELA 16: PROGRAMACAO_PALESTRANTE
-- ============================================================
CREATE TABLE programacao_palestrante (
    id_prog_palestrante SERIAL PRIMARY KEY,
    papel               papel_palestrante DEFAULT 'PALESTRANTE',
    id_programacao      INT NOT NULL REFERENCES programacao(id_programacao) ON DELETE CASCADE,
    id_palestrante      INT NOT NULL REFERENCES palestrante(id_palestrante),
    UNIQUE (id_programacao, id_palestrante)
);

-- ============================================================
-- TABELA 17: PATROCINADOR
-- ============================================================
CREATE TABLE patrocinador (
    id_patrocinador SERIAL PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL,
    cnpj            VARCHAR(18)  UNIQUE,
    logo_url        VARCHAR(300),
    website         VARCHAR(200),
    contato_nome    VARCHAR(150),
    contato_email   VARCHAR(100)
);

-- ============================================================
-- TABELA 18: PATROCINIO
-- ============================================================
CREATE TABLE patrocinio (
    id_patrocinio   SERIAL PRIMARY KEY,
    valor           DECIMAL(12,2) CHECK (valor >= 0),
    tipo            tipo_patrocinio NOT NULL,
    descricao       TEXT,
    id_evento       INT NOT NULL REFERENCES evento(id_evento) ON DELETE CASCADE,
    id_patrocinador INT NOT NULL REFERENCES patrocinador(id_patrocinador)
);

-- ============================================================
-- TABELA 19: RECURSO
-- ============================================================
CREATE TABLE recurso (
    id_recurso             SERIAL PRIMARY KEY,
    nome                   VARCHAR(100) NOT NULL,
    tipo                   tipo_recurso NOT NULL,
    descricao              TEXT,
    quantidade_disponivel  INT DEFAULT 1 CHECK (quantidade_disponivel >= 0)
);

-- ============================================================
-- TABELA 20: SOLICITACAO_RECURSO
-- ============================================================
CREATE TABLE solicitacao_recurso (
    id_solicitacao       SERIAL PRIMARY KEY,
    quantidade_solicitada INT NOT NULL DEFAULT 1 CHECK (quantidade_solicitada > 0),
    data_solicitacao      TIMESTAMP DEFAULT NOW(),
    status                status_solicitacao NOT NULL DEFAULT 'PENDENTE',
    id_recurso            INT NOT NULL REFERENCES recurso(id_recurso),
    id_evento             INT NOT NULL REFERENCES evento(id_evento) ON DELETE CASCADE,
    id_solicitante        INT NOT NULL REFERENCES pessoa(id_pessoa)
);

-- ============================================================
-- TABELA 21: NOTIFICACAO
-- ============================================================
CREATE TABLE notificacao (
    id_notificacao  SERIAL PRIMARY KEY,
    mensagem        TEXT NOT NULL,
    tipo            tipo_notificacao NOT NULL,
    data_envio      TIMESTAMP DEFAULT NOW(),
    lida            BOOLEAN DEFAULT FALSE,
    id_pessoa       INT NOT NULL REFERENCES pessoa(id_pessoa) ON DELETE CASCADE,
    id_evento       INT REFERENCES evento(id_evento) ON DELETE SET NULL
);

-- ============================================================
-- TABELA 22: AVALIACAO_EVENTO
-- ============================================================
CREATE TABLE avaliacao_evento (
    id_avaliacao    SERIAL PRIMARY KEY,
    nota            SMALLINT NOT NULL CHECK (nota BETWEEN 1 AND 5),
    comentario      TEXT,
    data_avaliacao  TIMESTAMP DEFAULT NOW(),
    id_inscricao    INT NOT NULL UNIQUE REFERENCES inscricao(id_inscricao)
);

-- ============================================================
-- TABELA 23: EQUIPE_ORGANIZACAO
-- ============================================================
CREATE TABLE equipe_organizacao (
    id_equipe   SERIAL PRIMARY KEY,
    funcao      funcao_equipe NOT NULL,
    id_evento   INT NOT NULL REFERENCES evento(id_evento) ON DELETE CASCADE,
    id_pessoa   INT NOT NULL REFERENCES pessoa(id_pessoa),
    UNIQUE (id_evento, id_pessoa)
);

-- ============================================================
-- TABELA 24: LOG_AUDITORIA (extra - rastreamento de alterações)
-- ============================================================
CREATE TABLE log_auditoria (
    id_log      SERIAL PRIMARY KEY,
    tabela      VARCHAR(100) NOT NULL,
    operacao    VARCHAR(10)  NOT NULL,
    id_registro INT,
    dado_antigo JSONB,
    dado_novo   JSONB,
    usuario     VARCHAR(100) DEFAULT current_user,
    executado_em TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_evento_status     ON evento(status);
CREATE INDEX idx_evento_campus     ON evento(id_campus);
CREATE INDEX idx_evento_datas      ON evento(data_inicio, data_fim);
CREATE INDEX idx_inscricao_evento  ON inscricao(id_evento);
CREATE INDEX idx_inscricao_pessoa  ON inscricao(id_pessoa);
CREATE INDEX idx_reserva_espaco    ON reserva_espaco(id_espaco, data_uso);
CREATE INDEX idx_notificacao_pessoa ON notificacao(id_pessoa, lida);
CREATE INDEX idx_programacao_evento ON programacao(id_evento, data);

-- ============================================================
-- VIEWS
-- ============================================================

-- View 1: Eventos ativos (publicados ou em andamento)
CREATE OR REPLACE VIEW vw_eventos_ativos AS
SELECT 
    e.id_evento, e.titulo, e.descricao, e.data_inicio, e.data_fim,
    e.horario_inicio, e.horario_fim, e.status, e.vagas_totais,
    c.nome AS categoria, p.nome AS organizador,
    d.nome AS departamento, cam.nome AS campus
FROM evento e
JOIN categoria_evento c  ON e.id_categoria = c.id_categoria
JOIN pessoa p             ON e.id_organizador = p.id_pessoa
LEFT JOIN departamento d  ON e.id_departamento = d.id_departamento
JOIN campus cam           ON e.id_campus = cam.id_campus
WHERE e.status IN ('PUBLICADO','EM_ANDAMENTO');

-- View 2: Resumo de eventos com contagens
CREATE OR REPLACE VIEW vw_resumo_eventos AS
SELECT 
    e.id_evento, e.titulo, e.status, e.data_inicio, e.data_fim,
    e.vagas_totais,
    COUNT(i.id_inscricao) FILTER (WHERE i.status = 'CONFIRMADA') AS inscritos,
    e.vagas_totais - COUNT(i.id_inscricao) FILTER (WHERE i.status = 'CONFIRMADA') AS vagas_disponiveis,
    ROUND(AVG(av.nota)::NUMERIC, 2) AS media_avaliacao,
    COUNT(av.id_avaliacao) AS total_avaliacoes,
    COUNT(i.id_inscricao) FILTER (WHERE i.presente = TRUE) AS presentes
FROM evento e
LEFT JOIN inscricao i       ON e.id_evento = i.id_evento
LEFT JOIN avaliacao_evento av ON i.id_inscricao = av.id_inscricao
GROUP BY e.id_evento, e.titulo, e.status, e.data_inicio, e.data_fim, e.vagas_totais;

-- View 3: Ocupação de espaços
CREATE OR REPLACE VIEW vw_ocupacao_espacos AS
SELECT 
    es.id_espaco, es.nome AS espaco, es.tipo, es.capacidade,
    re.data_uso, re.horario_inicio, re.horario_fim,
    ev.titulo AS evento, re.status,
    cam.nome AS campus
FROM reserva_espaco re
JOIN espaco es   ON re.id_espaco = es.id_espaco
JOIN evento ev   ON re.id_evento = ev.id_evento
JOIN campus cam  ON es.id_campus = cam.id_campus
WHERE re.status = 'APROVADA';

-- View 4: Certificados emitidos
CREATE OR REPLACE VIEW vw_certificados_emitidos AS
SELECT 
    cert.id_certificado, cert.codigo_validacao, cert.data_emissao,
    cert.carga_horaria, p.nome AS participante, p.email,
    ev.titulo AS evento, ev.data_inicio, ev.data_fim
FROM certificado cert
JOIN inscricao i  ON cert.id_inscricao = i.id_inscricao
JOIN pessoa p     ON i.id_pessoa = p.id_pessoa
JOIN evento ev    ON i.id_evento = ev.id_evento;

-- View 5: Ranking de eventos por avaliação
CREATE OR REPLACE VIEW vw_ranking_eventos AS
SELECT 
    e.id_evento, e.titulo,
    ROUND(AVG(av.nota)::NUMERIC, 2) AS media_avaliacao,
    COUNT(av.id_avaliacao) AS total_avaliacoes,
    COUNT(i.id_inscricao) FILTER (WHERE i.status = 'CONFIRMADA') AS total_inscritos,
    e.data_inicio
FROM evento e
JOIN inscricao i          ON e.id_evento = i.id_evento
JOIN avaliacao_evento av  ON i.id_inscricao = av.id_inscricao
GROUP BY e.id_evento, e.titulo, e.data_inicio
HAVING COUNT(av.id_avaliacao) >= 1
ORDER BY media_avaliacao DESC;

-- View 6: Inscrições confirmadas com dados completos
CREATE OR REPLACE VIEW vw_inscricoes_confirmadas AS
SELECT 
    i.id_inscricao, i.data_inscricao, i.presente,
    p.nome AS participante, p.email, p.tipo AS tipo_participante,
    ev.titulo AS evento, ev.data_inicio, ev.data_fim,
    cam.nome AS campus
FROM inscricao i
JOIN pessoa p  ON i.id_pessoa = p.id_pessoa
JOIN evento ev ON i.id_evento = ev.id_evento
JOIN campus cam ON ev.id_campus = cam.id_campus
WHERE i.status = 'CONFIRMADA';

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Trigger 1: Atualiza data_atualizacao do evento
CREATE OR REPLACE FUNCTION fn_atualiza_evento()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.data_atualizacao = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_atualiza_evento
BEFORE UPDATE ON evento
FOR EACH ROW EXECUTE FUNCTION fn_atualiza_evento();

-- Trigger 2: Bloqueia inscrição quando evento está lotado
CREATE OR REPLACE FUNCTION fn_verifica_vagas()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_vagas_totais INT;
    v_inscritos    INT;
BEGIN
    IF NEW.status = 'CANCELADA' THEN
        RETURN NEW;
    END IF;

    SELECT vagas_totais INTO v_vagas_totais FROM evento WHERE id_evento = NEW.id_evento;
    SELECT COUNT(*) INTO v_inscritos 
    FROM inscricao 
    WHERE id_evento = NEW.id_evento AND status = 'CONFIRMADA';

    IF v_inscritos >= v_vagas_totais AND NEW.status = 'CONFIRMADA' THEN
        NEW.status = 'LISTA_ESPERA';
        RAISE NOTICE 'Evento lotado. Inscrição adicionada à lista de espera.';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_verifica_vagas
BEFORE INSERT ON inscricao
FOR EACH ROW EXECUTE FUNCTION fn_verifica_vagas();

-- Trigger 3: Impede conflito de reserva no mesmo espaço/horário
CREATE OR REPLACE FUNCTION fn_verifica_conflito_reserva()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_conflito INT;
BEGIN
    IF NEW.status != 'APROVADA' THEN
        RETURN NEW;
    END IF;

    SELECT COUNT(*) INTO v_conflito
    FROM reserva_espaco
    WHERE id_espaco = NEW.id_espaco
      AND data_uso  = NEW.data_uso
      AND status    = 'APROVADA'
      AND id_reserva != COALESCE(NEW.id_reserva, 0)
      AND (horario_inicio, horario_fim) OVERLAPS (NEW.horario_inicio, NEW.horario_fim);

    IF v_conflito > 0 THEN
        RAISE EXCEPTION 'Conflito de horário: espaço já reservado neste período.';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_verifica_conflito_reserva
BEFORE INSERT OR UPDATE ON reserva_espaco
FOR EACH ROW EXECUTE FUNCTION fn_verifica_conflito_reserva();

-- Trigger 4: Bloqueia emissão de certificado sem presença
CREATE OR REPLACE FUNCTION fn_verifica_presenca_certificado()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_presente BOOLEAN;
BEGIN
    SELECT presente INTO v_presente FROM inscricao WHERE id_inscricao = NEW.id_inscricao;
    IF NOT v_presente THEN
        RAISE EXCEPTION 'Certificado não pode ser emitido: participante não marcou presença.';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_verifica_presenca_certificado
BEFORE INSERT ON certificado
FOR EACH ROW EXECUTE FUNCTION fn_verifica_presenca_certificado();

-- Trigger 5: Promove lista de espera ao cancelar inscrição
CREATE OR REPLACE FUNCTION fn_promove_lista_espera()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_proximo INT;
BEGIN
    IF NEW.status = 'CANCELADA' AND OLD.status = 'CONFIRMADA' THEN
        SELECT id_inscricao INTO v_proximo
        FROM inscricao
        WHERE id_evento = OLD.id_evento AND status = 'LISTA_ESPERA'
        ORDER BY data_inscricao ASC
        LIMIT 1;

        IF v_proximo IS NOT NULL THEN
            UPDATE inscricao SET status = 'CONFIRMADA' WHERE id_inscricao = v_proximo;
            INSERT INTO notificacao(mensagem, tipo, id_pessoa, id_evento)
            SELECT 'Sua inscrição foi confirmada! Uma vaga ficou disponível no evento.',
                   'SISTEMA', i.id_pessoa, i.id_evento
            FROM inscricao i WHERE i.id_inscricao = v_proximo;
            RAISE NOTICE 'Inscrição % promovida da lista de espera.', v_proximo;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_promove_lista_espera
AFTER UPDATE ON inscricao
FOR EACH ROW EXECUTE FUNCTION fn_promove_lista_espera();

-- Trigger 6: Log de auditoria em eventos
CREATE OR REPLACE FUNCTION fn_log_evento()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO log_auditoria(tabela, operacao, id_registro, dado_novo)
        VALUES ('evento', 'INSERT', NEW.id_evento, row_to_json(NEW)::JSONB);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO log_auditoria(tabela, operacao, id_registro, dado_antigo, dado_novo)
        VALUES ('evento', 'UPDATE', NEW.id_evento, row_to_json(OLD)::JSONB, row_to_json(NEW)::JSONB);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO log_auditoria(tabela, operacao, id_registro, dado_antigo)
        VALUES ('evento', 'DELETE', OLD.id_evento, row_to_json(OLD)::JSONB);
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_log_evento
AFTER INSERT OR UPDATE OR DELETE ON evento
FOR EACH ROW EXECUTE FUNCTION fn_log_evento();

-- Trigger 7: Notifica inscritos quando evento for cancelado
CREATE OR REPLACE FUNCTION fn_notifica_cancelamento()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.status = 'CANCELADO' AND OLD.status != 'CANCELADO' THEN
        INSERT INTO notificacao(mensagem, tipo, id_pessoa, id_evento)
        SELECT 
            'O evento "' || NEW.titulo || '" foi cancelado. Lamentamos o inconveniente.',
            'SISTEMA', i.id_pessoa, NEW.id_evento
        FROM inscricao i
        WHERE i.id_evento = NEW.id_evento AND i.status = 'CONFIRMADA';
        RAISE NOTICE 'Notificações de cancelamento enviadas.';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notifica_cancelamento
AFTER UPDATE ON evento
FOR EACH ROW EXECUTE FUNCTION fn_notifica_cancelamento();

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- Procedure 1: Inscrever pessoa em evento
CREATE OR REPLACE PROCEDURE sp_inscrever_pessoa(
    p_id_evento INT,
    p_id_pessoa INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_evento evento%ROWTYPE;
BEGIN
    SELECT * INTO v_evento FROM evento WHERE id_evento = p_id_evento;

    IF v_evento.id_evento IS NULL THEN
        RAISE EXCEPTION 'Evento % não encontrado.', p_id_evento;
    END IF;

    IF v_evento.status NOT IN ('PUBLICADO','EM_ANDAMENTO') THEN
        RAISE EXCEPTION 'Evento não está disponível para inscrições. Status: %', v_evento.status;
    END IF;

    IF EXISTS (SELECT 1 FROM inscricao WHERE id_evento = p_id_evento AND id_pessoa = p_id_pessoa AND status != 'CANCELADA') THEN
        RAISE EXCEPTION 'Pessoa já está inscrita neste evento.';
    END IF;

    INSERT INTO inscricao(id_evento, id_pessoa) VALUES (p_id_evento, p_id_pessoa);

    INSERT INTO notificacao(mensagem, tipo, id_pessoa, id_evento)
    VALUES ('Inscrição realizada com sucesso no evento: ' || v_evento.titulo, 'SISTEMA', p_id_pessoa, p_id_evento);

    RAISE NOTICE 'Inscrição realizada para pessoa % no evento %.', p_id_pessoa, p_id_evento;
END;
$$;

-- Procedure 2: Emitir certificados em lote para um evento
CREATE OR REPLACE PROCEDURE sp_emitir_certificados(
    p_id_evento    INT,
    p_carga_horaria DECIMAL
) LANGUAGE plpgsql AS $$
DECLARE
    v_inscricao RECORD;
    v_count     INT := 0;
BEGIN
    FOR v_inscricao IN
        SELECT i.id_inscricao FROM inscricao i
        WHERE i.id_evento = p_id_evento
          AND i.presente = TRUE
          AND i.status = 'CONFIRMADA'
          AND NOT EXISTS (SELECT 1 FROM certificado c WHERE c.id_inscricao = i.id_inscricao)
    LOOP
        INSERT INTO certificado(carga_horaria, id_inscricao)
        VALUES (p_carga_horaria, v_inscricao.id_inscricao);
        v_count := v_count + 1;
    END LOOP;

    RAISE NOTICE '% certificados emitidos para o evento %.', v_count, p_id_evento;
END;
$$;

-- Procedure 3: Cancelar evento e notificar inscritos
CREATE OR REPLACE PROCEDURE sp_cancelar_evento(
    p_id_evento INT,
    p_motivo    TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE evento 
    SET status = 'CANCELADO', descricao = descricao || E'\n\nMotivo do cancelamento: ' || p_motivo
    WHERE id_evento = p_id_evento;

    UPDATE reserva_espaco SET status = 'CANCELADA'
    WHERE id_evento = p_id_evento AND status IN ('PENDENTE','APROVADA');

    RAISE NOTICE 'Evento % cancelado. Inscritos notificados automaticamente pelo trigger.', p_id_evento;
END;
$$;

-- Procedure 4: Registrar presença em lote via lista de matriculas
CREATE OR REPLACE PROCEDURE sp_registrar_presencas(
    p_id_evento     INT,
    p_ids_pessoa    INT[]
) LANGUAGE plpgsql AS $$
DECLARE
    v_id INT;
BEGIN
    FOREACH v_id IN ARRAY p_ids_pessoa LOOP
        UPDATE inscricao
        SET presente = TRUE
        WHERE id_evento = p_id_evento AND id_pessoa = v_id AND status = 'CONFIRMADA';
    END LOOP;
    RAISE NOTICE 'Presenças registradas para % participantes.', array_length(p_ids_pessoa,1);
END;
$$;

-- Procedure 5: Aprovar reserva de espaço
CREATE OR REPLACE PROCEDURE sp_aprovar_reserva(
    p_id_reserva INT
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE reserva_espaco SET status = 'APROVADA' WHERE id_reserva = p_id_reserva;
    RAISE NOTICE 'Reserva % aprovada.', p_id_reserva;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao aprovar reserva: %', SQLERRM;
END;
$$;

-- ============================================================
-- FUNCTIONS (retornam valores)
-- ============================================================

-- Function 1: Retorna vagas disponíveis de um evento
CREATE OR REPLACE FUNCTION fn_vagas_disponiveis(p_id_evento INT)
RETURNS INT LANGUAGE plpgsql AS $$
DECLARE
    v_total    INT;
    v_inscritos INT;
BEGIN
    SELECT vagas_totais INTO v_total FROM evento WHERE id_evento = p_id_evento;
    SELECT COUNT(*) INTO v_inscritos FROM inscricao 
    WHERE id_evento = p_id_evento AND status = 'CONFIRMADA';
    RETURN GREATEST(v_total - v_inscritos, 0);
END;
$$;

-- Function 2: Valida código de certificado
CREATE OR REPLACE FUNCTION fn_validar_certificado(p_codigo VARCHAR)
RETURNS TABLE(
    participante VARCHAR, evento VARCHAR, data_emissao TIMESTAMP, carga_horaria DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT p.nome, ev.titulo, c.data_emissao, c.carga_horaria
    FROM certificado c
    JOIN inscricao i ON c.id_inscricao = i.id_inscricao
    JOIN pessoa p    ON i.id_pessoa = p.id_pessoa
    JOIN evento ev   ON i.id_evento = ev.id_evento
    WHERE c.codigo_validacao = p_codigo;
END;
$$;
