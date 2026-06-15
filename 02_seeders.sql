-- ============================================================
-- SEEDERS — Dados de Exemplo para o Sistema UPE Eventos
-- ============================================================
SET search_path = upe_eventos;

-- ============================================================
-- CAMPUS UPE
-- ============================================================
INSERT INTO campus (nome, endereco, cidade, telefone, email_institucional) VALUES
('UPE Campus Garanhuns',      'Rua Capitão Pedro Rodrigues, 105 - São José',     'Garanhuns',  '(87) 3764-5555', 'garanhuns@upe.br'),
('UPE Campus Recife',         'Rua Arnóbio Marques, 310 - Santo Amaro',          'Recife',     '(81) 3183-3500', 'recife@upe.br'),
('UPE Campus Caruaru',        'BR 104, km 62 - Nova Caruaru',                    'Caruaru',    '(81) 3721-2025', 'caruaru@upe.br'),
('UPE Campus Petrolina',      'Avenida Senador Helvídio Nunes, 4173 - Pedral',   'Petrolina',  '(87) 3866-7320', 'petrolina@upe.br'),
('UPE Campus Serra Talhada',  'Avenida Afonso Magalhães, s/n - Junco',           'Serra Talhada','(87) 3831-2260', 'serratalhada@upe.br');

-- ============================================================
-- DEPARTAMENTOS
-- ============================================================
INSERT INTO departamento (nome, sigla, id_campus) VALUES
('Colegiado de Ciência da Computação',       'CCOMP',  1),
('Colegiado de Sistemas de Informação',      'SI',     1),
('Colegiado de Licenciatura em Computação',  'LC',     1),
('Colegiado de Enfermagem',                  'ENF',    1),
('Colegiado de Medicina',                    'MED',    2),
('Colegiado de Engenharia Civil',            'ECIV',   2),
('Colegiado de Administração',               'ADM',    3),
('Colegiado de Letras',                      'LET',    3),
('Colegiado de Pedagogia',                   'PED',    4),
('Colegiado de Psicologia',                  'PSI',    2);

-- ============================================================
-- PESSOAS
-- ============================================================
INSERT INTO pessoa (nome, cpf, email, telefone, tipo) VALUES
-- Professores
('Dr. Antônio Ferreira Lima',        '111.222.333-01', 'antonio.lima@upe.br',       '(87) 99901-1111', 'PROFESSOR'),
('Dra. Carla Mendes Souza',          '111.222.333-02', 'carla.souza@upe.br',        '(87) 99901-2222', 'PROFESSOR'),
('Dr. Ricardo Alves Nascimento',     '111.222.333-03', 'ricardo.nascimento@upe.br', '(81) 99901-3333', 'PROFESSOR'),
('Dra. Juliana Barbosa Santos',      '111.222.333-04', 'juliana.santos@upe.br',     '(87) 99901-4444', 'PROFESSOR'),
('Dr. Marcos Vinícius Rodrigues',    '111.222.333-05', 'marcos.rodrigues@upe.br',   '(87) 99901-5555', 'PROFESSOR'),
-- Servidores
('Ana Paula Oliveira',               '222.333.444-01', 'ana.oliveira@upe.br',       '(87) 99902-1111', 'SERVIDOR'),
('Carlos Eduardo Pereira',           '222.333.444-02', 'carlos.pereira@upe.br',     '(87) 99902-2222', 'SERVIDOR'),
-- Alunos
('João Pedro Alves',                 '333.444.555-01', 'joao.alves@upe.br',         '(87) 99903-1111', 'ALUNO'),
('Maria Clara Ferreira',             '333.444.555-02', 'maria.ferreira@upe.br',     '(87) 99903-2222', 'ALUNO'),
('Lucas Henrique Costa',             '333.444.555-03', 'lucas.costa@upe.br',        '(81) 99903-3333', 'ALUNO'),
('Beatriz Santos Lima',              '333.444.555-04', 'beatriz.lima@upe.br',       '(87) 99903-4444', 'ALUNO'),
('Rafael Moura Carvalho',            '333.444.555-05', 'rafael.carvalho@upe.br',    '(87) 99903-5555', 'ALUNO'),
('Isabela Rocha Nunes',              '333.444.555-06', 'isabela.nunes@upe.br',      '(87) 99903-6666', 'ALUNO'),
('Gabriel Souza Medeiros',           '333.444.555-07', 'gabriel.medeiros@upe.br',   '(87) 99903-7777', 'ALUNO'),
('Larissa Vieira Oliveira',          '333.444.555-08', 'larissa.oliveira@upe.br',   '(81) 99903-8888', 'ALUNO'),
-- Externos
('Dr. Felipe Andrade',               '444.555.666-01', 'felipe.andrade@gmail.com',  '(81) 99904-1111', 'EXTERNO'),
('Dra. Simone Castro',               '444.555.666-02', 'simone.castro@gmail.com',   '(87) 99904-2222', 'EXTERNO'),
('Paulo Roberto Teixeira',           '444.555.666-03', 'paulo.teixeira@empresa.com','(81) 99904-3333', 'EXTERNO'),
('Fernanda Lima Gomes',              '444.555.666-04', 'fernanda.gomes@gmail.com',  '(87) 99904-4444', 'EXTERNO'),
('Rodrigo Menezes Albuquerque',      '444.555.666-05', 'rodrigo.albuquerque@org.br','(81) 99904-5555', 'EXTERNO');

-- ============================================================
-- ALUNOS (vinculando às pessoas)
-- ============================================================
INSERT INTO aluno (id_pessoa, matricula, curso, periodo, id_departamento) VALUES
(8,  '2021001', 'Ciência da Computação',      5, 1),
(9,  '2021002', 'Sistemas de Informação',      4, 2),
(10, '2020001', 'Ciência da Computação',      6, 1),
(11, '2022001', 'Licenciatura em Computação', 3, 3),
(12, '2022002', 'Sistemas de Informação',      2, 2),
(13, '2021003', 'Enfermagem',                  5, 4),
(14, '2023001', 'Ciência da Computação',      1, 1),
(15, '2020002', 'Sistemas de Informação',      7, 2);

-- ============================================================
-- PROFESSORES
-- ============================================================
INSERT INTO professor (id_pessoa, siape, titulacao, id_departamento) VALUES
(1, 'SIAPE-001', 'DOUTORADO',   1),
(2, 'SIAPE-002', 'DOUTORADO',   2),
(3, 'SIAPE-003', 'MESTRADO',    5),
(4, 'SIAPE-004', 'DOUTORADO',   1),
(5, 'SIAPE-005', 'POS_DOUTORADO', 1);

-- ============================================================
-- SERVIDORES
-- ============================================================
INSERT INTO servidor (id_pessoa, matricula_siape, cargo, id_departamento) VALUES
(6, 'SERV-001', 'Técnico Administrativo', 1),
(7, 'SERV-002', 'Assistente em Administração', 2);

-- ============================================================
-- ESPAÇOS
-- ============================================================
INSERT INTO espaco (nome, tipo, capacidade, localizacao, recursos_disponiveis, id_campus) VALUES
('Auditório Principal',           'AUDITORIO',    200, 'Bloco A - Térreo',   'Projetor, som, ar-condicionado, palco',               1),
('Auditório Secundário',          'AUDITORIO',     80, 'Bloco B - 1º Andar', 'Projetor, som, ar-condicionado',                      1),
('Laboratório de Informática 1',  'LABORATORIO',   40, 'Bloco C - Térreo',   '40 computadores, projetor, internet',                 1),
('Laboratório de Informática 2',  'LABORATORIO',   40, 'Bloco C - 1º Andar', '40 computadores, projetor, internet',                 1),
('Sala de Reuniões',              'SALA',          20, 'Bloco A - 2º Andar', 'Tv 55", quadro branco, videoconferência',             1),
('Sala de Aula 101',              'SALA',          50, 'Bloco D - Térreo',   'Projetor, quadro',                                    1),
('Sala de Aula 201',              'SALA',          50, 'Bloco D - 1º Andar', 'Projetor, quadro',                                    1),
('Quadra Poliesportiva',          'QUADRA',       300, 'Área Externa Norte', 'Vestiários, iluminação',                              1),
('Área Verde / Anfiteatro',       'AREA_EXTERNA', 500, 'Área Central',       'Palco portátil, iluminação externa',                  1),
('Auditório FACET',               'AUDITORIO',    150, 'Bloco FACET',        'Projetor, som profissional, ar-condicionado',         2);

-- ============================================================
-- CATEGORIAS DE EVENTOS
-- ============================================================
INSERT INTO categoria_evento (nome, descricao) VALUES
('Semana Acadêmica',       'Eventos acadêmicos anuais dos cursos'),
('Workshop',               'Oficinas práticas de curta duração'),
('Palestra',               'Apresentações com especialistas convidados'),
('Hackathon',              'Competições de programação e inovação'),
('Simpósio',               'Encontros científicos com apresentação de trabalhos'),
('Feira de Extensão',      'Exposição de projetos de extensão universitária'),
('Curso de Extensão',      'Cursos abertos à comunidade'),
('Conferência',            'Eventos de grande porte com múltiplos temas'),
('Encontro Estudantil',    'Eventos organizados pelos centros acadêmicos'),
('Evento Cultural',        'Shows, apresentações artísticas e culturais');

-- ============================================================
-- EVENTOS
-- ============================================================
INSERT INTO evento (titulo, descricao, data_inicio, data_fim, horario_inicio, horario_fim, status, publico_alvo, vagas_totais, id_categoria, id_organizador, id_departamento, id_campus) VALUES
('SECOMP 2024 — Semana da Computação UPE Garanhuns',
 'Maior evento de computação do interior pernambucano, reunindo palestrantes nacionais, workshops práticos e feira de projetos.',
 '2026-11-11', '2026-11-15', '08:00', '22:00', 'CONCLUIDO',
 'Estudantes de computação, profissionais de TI e comunidade em geral', 300, 1, 1, 1, 1),

('Workshop de Inteligência Artificial — Mão na Massa',
 'Oficina prática de 4 horas cobrindo Python, scikit-learn e deep learning com TensorFlow.',
 '2026-09-20', '2026-09-20', '14:00', '18:00', 'CONCLUIDO',
 'Alunos de computação e áreas correlatas', 40, 2, 2, 2, 1),

('I Simpósio de Enfermagem UPE Garanhuns',
 'Simpósio científico com apresentação de trabalhos de pesquisa e extensão em enfermagem.',
 '2026-10-10', '2026-10-11', '08:00', '18:00', 'CONCLUIDO',
 'Estudantes e profissionais de enfermagem e saúde', 150, 5, 4, 4, 1),

('Hackathon UPE — Soluções para o Agreste',
 'Maratona de 24h para desenvolver soluções tecnológicas para problemas regionais.',
 '2025-04-05', '2025-04-06', '09:00', '09:00', 'CONCLUIDO',
 'Estudantes de computação, design e áreas correlatas', 80, 4, 5, 1, 1),

('Palestra: Mercado de Trabalho em TI — 2025 e Além',
 'Painel com profissionais e recrutadores de grandes empresas sobre o mercado de TI.',
 '2025-03-15', '2025-03-15', '19:00', '21:30', 'CONCLUIDO',
 'Estudantes e recém-formados em TI', 200, 3, 1, 1, 1),

('Curso de Extensão: Desenvolvimento Web com React',
 'Curso de 40 horas de desenvolvimento front-end moderno com React e TypeScript.',
 '2025-07-07', '2025-08-15', '18:00', '22:00', 'PUBLICADO',
 'Estudantes e comunidade externa', 30, 7, 2, 2, 1),

('II Semana da Computação UPE Garanhuns 2025',
 'Segunda edição do evento com trilhas em IA, Segurança, Cloud e Empreendedorismo.',
 '2025-11-10', '2025-11-14', '08:00', '22:00', 'PUBLICADO',
 'Estudantes, profissionais e comunidade', 400, 1, 1, 1, 1),

('Feira de Extensão 2024',
 'Exposição dos projetos de extensão desenvolvidos pelos cursos durante o semestre.',
 '2026-12-05', '2026-12-05', '09:00', '17:00', 'CONCLUIDO',
 'Comunidade interna e externa', 500, 6, 6, 1, 1),

('Workshop: Segurança da Informação e LGPD',
 'Introdução à segurança cibernética e boas práticas de proteção de dados.',
 '2025-05-22', '2025-05-22', '14:00', '18:00', 'CONCLUIDO',
 'Alunos e servidores', 50, 2, 5, 1, 1),

('Encontro de Egressos UPE Garanhuns',
 'Evento de reencontro e networking para ex-alunos de todos os cursos do campus.',
 '2025-09-20', '2025-09-20', '09:00', '18:00', 'PUBLICADO',
 'Ex-alunos, docentes e discentes', 200, 9, 1, 1, 1);

-- ============================================================
-- EDIÇÕES DOS EVENTOS RECORRENTES
-- ============================================================
INSERT INTO edicao_evento (numero_edicao, ano, id_evento) VALUES
(1, 2026, 1),
(1, 2026, 3),
(1, 2025, 4),
(2, 2025, 7);

-- ============================================================
-- RESERVAS DE ESPAÇO
-- ============================================================
INSERT INTO reserva_espaco (data_uso, horario_inicio, horario_fim, status, justificativa, id_espaco, id_evento, id_solicitante) VALUES
('2024-11-11', '08:00', '22:00', 'APROVADA', 'Abertura e palestras principais da SECOMP', 1, 1, 1),
('2024-11-12', '08:00', '22:00', 'APROVADA', 'Workshops e minicursos', 3, 1, 1),
('2024-11-13', '08:00', '22:00', 'APROVADA', 'Workshops e minicursos', 4, 1, 1),
('2024-09-20', '14:00', '18:00', 'APROVADA', 'Workshop de IA', 3, 2, 2),
('2024-10-10', '08:00', '18:00', 'APROVADA', 'Simpósio de Enfermagem - dia 1', 2, 3, 4),
('2024-10-11', '08:00', '18:00', 'APROVADA', 'Simpósio de Enfermagem - dia 2', 2, 3, 4),
('2025-04-05', '09:00', '23:59', 'APROVADA', 'Hackathon - dia 1', 3, 4, 5),
('2025-04-06', '00:00', '09:00', 'APROVADA', 'Hackathon - dia 2', 3, 4, 5),
('2025-03-15', '19:00', '21:30', 'APROVADA', 'Palestra Mercado de TI', 1, 5, 1),
('2025-05-22', '14:00', '18:00', 'APROVADA', 'Workshop LGPD', 5, 9, 5);

-- ============================================================
-- INSCRIÇÕES
-- ============================================================
INSERT INTO inscricao (id_evento, id_pessoa, status, presente) VALUES
-- SECOMP 2026 (evento 1) — concluído
(1,  8,  'CONFIRMADA', TRUE),
(1,  9,  'CONFIRMADA', TRUE),
(1,  10, 'CONFIRMADA', TRUE),
(1,  11, 'CONFIRMADA', FALSE),
(1,  12, 'CONFIRMADA', TRUE),
(1,  13, 'CONFIRMADA', TRUE),
(1,  14, 'CONFIRMADA', TRUE),
(1,  15, 'CONFIRMADA', FALSE),
(1,  16, 'CONFIRMADA', TRUE),
(1,  17, 'CONFIRMADA', TRUE),
-- Workshop IA (evento 2)
(2,  8,  'CONFIRMADA', TRUE),
(2,  9,  'CONFIRMADA', TRUE),
(2,  10, 'CONFIRMADA', TRUE),
(2,  14, 'CONFIRMADA', FALSE),
-- Simpósio Enfermagem (evento 3)
(3,  13, 'CONFIRMADA', TRUE),
(3,  11, 'CONFIRMADA', TRUE),
(3,  17, 'CONFIRMADA', TRUE),
-- Hackathon (evento 4)
(4,  8,  'CONFIRMADA', TRUE),
(4,  9,  'CONFIRMADA', TRUE),
(4,  10, 'CONFIRMADA', TRUE),
(4,  12, 'CONFIRMADA', FALSE),
-- Palestra TI (evento 5)
(5,  8,  'CONFIRMADA', TRUE),
(5,  9,  'CONFIRMADA', TRUE),
(5,  14, 'CONFIRMADA', TRUE),
(5,  15, 'CONFIRMADA', TRUE),
(5,  16, 'CONFIRMADA', FALSE),
-- Workshop LGPD (evento 9)
(9,  8,  'CONFIRMADA', TRUE),
(9,  10, 'CONFIRMADA', TRUE),
(9,  12, 'CONFIRMADA', TRUE),
-- Curso React (evento 6) - publicado, inscrições abertas
(6,  8,  'CONFIRMADA', FALSE),
(6,  9,  'CONFIRMADA', FALSE),
(6,  12, 'CONFIRMADA', FALSE),
(6,  14, 'CONFIRMADA', FALSE);

-- ============================================================
-- CERTIFICADOS (apenas para quem teve presença)
-- ============================================================
INSERT INTO certificado (carga_horaria, id_inscricao) VALUES
-- SECOMP (40h) — inscrições com presente=TRUE
(40, 1), (40, 2), (40, 3), (40, 5), (40, 6), (40, 7), (40, 9), (40, 10),
-- Workshop IA (4h)
(4, 11), (4, 12), (4, 13),
-- Simpósio Enfermagem (16h)
(16, 15), (16, 16), (16, 17),
-- Hackathon (24h)
(24, 18), (24, 19), (24, 20),
-- Palestra TI (2.5h)
(2.5, 22), (2.5, 23), (2.5, 24), (2.5, 25),
-- Workshop LGPD (4h)
(4, 27), (4, 28), (4, 29);

-- ============================================================
-- PALESTRANTES
-- ============================================================
INSERT INTO palestrante (nome, instituicao, mini_bio, email, linkedin) VALUES
('Dr. André Luiz Carvalho',    'UFPE',                     'Doutor em IA pela UFPE com 15 anos de experiência em ML.',                'andre.carvalho@ufpe.br',  'linkedin.com/in/andrecarvalho'),
('MSc. Priscila Fonseca',      'Empresa ThinkData',         'Engenheira de dados com expertise em Big Data e Spark.',                  'priscila@thinkdata.com',  'linkedin.com/in/priscilafonseca'),
('Dr. Henrique Melo',          'CESAR School',             'Especialista em segurança cibernética e LGPD.',                           'henrique@cesar.org.br',   'linkedin.com/in/henriquemelo'),
('Dra. Vanessa Almeida',       'UPE Recife',               'Pesquisadora em saúde coletiva e epidemiologia.',                         'vanessa.almeida@upe.br',  'linkedin.com/in/vanessaalmeida'),
('Esp. Bruno Santos',          'Freelancer / YouTube',      'Desenvolvedor full-stack com 300k seguidores no YouTube.',                'bruno@brunodev.com.br',   'linkedin.com/in/brunosantos'),
('Dr. Cláudio Pereira',        'SERPRO',                   'Arquiteto de soluções em cloud e DevOps no governo federal.',             'claudio@serpro.gov.br',   'linkedin.com/in/claudiopereira'),
('MSc. Rebeca Lima',           'Startup Agritech',         'Co-fundadora de startup de agricultura de precisão.',                     'rebeca@agritech.com.br',  'linkedin.com/in/rebecalima'),
('Dr. Fábio Nunes',            'UNIVASF',                  'Professor de algoritmos e estruturas de dados.',                          'fabio.nunes@univasf.edu.br','linkedin.com/in/fabionunes');

-- ============================================================
-- PROGRAMAÇÃO DOS EVENTOS
-- ============================================================
INSERT INTO programacao (titulo, descricao, data, horario_inicio, horario_fim, tipo, id_evento, id_espaco) VALUES
-- SECOMP 2024
('Abertura Oficial SECOMP 2024',        'Cerimônia de abertura com autoridades do campus.',     '2026-11-11', '08:00', '09:00', 'APRESENTACAO', 1, 1),
('IA Generativa: Estado da Arte',       'Panorama das tecnologias de IA generativa em 2024.',   '2026-11-11', '09:00', '11:00', 'PALESTRA',     1, 1),
('Workshop: Python para Data Science',  'Oficina prática com pandas, matplotlib e sklearn.',    '2026-11-12', '08:00', '12:00', 'WORKSHOP',     1, 3),
('Segurança em Aplicações Web',         'OWASP Top 10 e testes de penetração.',                 '2026-11-12', '14:00', '16:00', 'PALESTRA',     1, 1),
('Mesa: Empreendedorismo em TI',        'Debate com empreendedores da região.',                 '2026-11-13', '09:00', '11:00', 'MESA_REDONDA', 1, 1),
-- Workshop IA
('Introdução ao Machine Learning',      'Fundamentos de ML com scikit-learn.',                  '2026-09-20', '14:00', '16:00', 'PALESTRA',     2, 3),
('Prática: Criando seu primeiro modelo','Hands-on com regressão e classificação.',              '2026-09-20', '16:00', '18:00', 'WORKSHOP',     2, 3),
-- Hackathon
('Abertura e Briefing do Hackathon',    'Apresentação dos desafios e regras.',                  '2025-04-05', '09:00', '10:00', 'APRESENTACAO', 4, 3),
('Mentorias Técnicas',                  'Sessões de mentoria com especialistas.',               '2025-04-05', '14:00', '17:00', 'WORKSHOP',     4, 3),
('Apresentação dos Projetos',           'Pitches das equipes para os jurados.',                 '2025-04-06', '07:00', '09:00', 'APRESENTACAO', 4, 3);

-- ============================================================
-- PROGRAMAÇÃO x PALESTRANTES
-- ============================================================
INSERT INTO programacao_palestrante (id_programacao, id_palestrante, papel) VALUES
(2, 1, 'PALESTRANTE'),
(3, 2, 'PALESTRANTE'),
(4, 3, 'PALESTRANTE'),
(5, 7, 'MEDIADOR'),
(5, 6, 'DEBATEDOR'),
(6, 1, 'PALESTRANTE'),
(7, 2, 'PALESTRANTE'),
(9, 8, 'MEDIADOR');

-- ============================================================
-- PATROCINADORES
-- ============================================================
INSERT INTO patrocinador (nome, cnpj, website, contato_nome, contato_email) VALUES
('ThinkData Soluções',     '11.222.333/0001-44', 'thinkdata.com.br',    'Carlos Viana',    'carlos@thinkdata.com.br'),
('Infosys Brasil',         '22.333.444/0001-55', 'infosys.com/br',      'Amanda Costa',    'amanda.costa@infosys.com'),
('Prefeitura de Garanhuns','00.111.222/0001-66', 'garanhuns.pe.gov.br', 'Secretaria TI',   'ti@garanhuns.pe.gov.br'),
('Google Developers',      '33.444.555/0001-77', 'developers.google.com','GDG Coordinator', 'gdg@google.com'),
('SEBRAE Pernambuco',      '44.555.666/0001-88', 'pe.sebrae.com.br',    'Fernanda Rego',   'fernanda@sebrae.pe');

-- ============================================================
-- PATROCÍNIOS
-- ============================================================
INSERT INTO patrocinio (valor, tipo, descricao, id_evento, id_patrocinador) VALUES
(5000.00, 'FINANCEIRO', 'Patrocínio gold para premiação e coffe break',   1, 1),
(3000.00, 'FINANCEIRO', 'Patrocínio silver para material impresso',        1, 2),
(2000.00, 'MATERIAL',   'Camisas e brindes para os participantes',         1, 3),
(1000.00, 'FINANCEIRO', 'Google credits para o hackathon',                 4, 4),
(1500.00, 'SERVICO',    'Consultoria empreendedorismo para hackathon',     4, 5),
(2500.00, 'FINANCEIRO', 'Apoio ao simpósio de enfermagem',                 3, 2);

-- ============================================================
-- RECURSOS
-- ============================================================
INSERT INTO recurso (nome, tipo, descricao, quantidade_disponivel) VALUES
('Projetor Multimídia',   'EQUIPAMENTO', 'Projetor Full HD 3000 lumens',           5),
('Notebook Emprestável',  'EQUIPAMENTO', 'Notebook para palestrantes',             3),
('Sistema de Som',        'EQUIPAMENTO', 'Caixas de som + microfone sem fio',      3),
('Extensão/Régua',        'EQUIPAMENTO', 'Extensão elétrica 5 metros',            10),
('Crachá/Identificação',  'MATERIAL',    'Crachás para participantes e staff',    500),
('Caneta e Bloco',        'MATERIAL',    'Kit papelaria para participantes',      200),
('Coffee Break',          'SERVICO',     'Serviço de coffee break por turno',      20),
('Filmagem e Edição',     'SERVICO',     'Gravação profissional do evento',         2),
('Transmissão ao Vivo',   'SERVICO',     'Live streaming para YouTube',             1),
('Banner/Totem',          'MATERIAL',    'Banners e totens personalizados',        10);

-- ============================================================
-- SOLICITAÇÕES DE RECURSOS
-- ============================================================
INSERT INTO solicitacao_recurso (quantidade_solicitada, status, id_recurso, id_evento, id_solicitante) VALUES
(2, 'APROVADA', 1, 1, 1),
(1, 'APROVADA', 2, 1, 1),
(2, 'APROVADA', 3, 1, 1),
(1, 'APROVADA', 8, 1, 1),
(1, 'APROVADA', 9, 1, 1),
(1, 'APROVADA', 1, 2, 2),
(1, 'APROVADA', 3, 2, 2),
(1, 'APROVADA', 7, 1, 6),
(3, 'APROVADA', 5, 1, 6),
(1, 'PENDENTE', 1, 7, 1);

-- ============================================================
-- EQUIPE DE ORGANIZAÇÃO
-- ============================================================
INSERT INTO equipe_organizacao (funcao, id_evento, id_pessoa) VALUES
('COORDENADOR', 1,  1),
('SECRETARIA',  1,  6),
('VOLUNTARIO',  1,  8),
('VOLUNTARIO',  1,  9),
('VOLUNTARIO',  1, 12),
('APOIO',       1,  7),
('COORDENADOR', 2,  2),
('VOLUNTARIO',  2, 10),
('COORDENADOR', 4,  5),
('VOLUNTARIO',  4, 11),
('VOLUNTARIO',  4, 14),
('COORDENADOR', 3,  4),
('SECRETARIA',  3,  6);

-- ============================================================
-- AVALIAÇÕES
-- ============================================================
INSERT INTO avaliacao_evento (nota, comentario, id_inscricao) VALUES
(5, 'Evento excelente! Palestrantes de altíssimo nível e organização impecável.', 1),
(5, 'Melhor semana acadêmica que já participei. Parabéns à organização!',          2),
(4, 'Ótimo evento, mas os workshops poderiam ter mais horas.',                     3),
(4, 'Muito bom! A qualidade das palestras foi impressionante.',                    5),
(5, 'Aprendi muito e fiz ótimos contatos. Voltarei com certeza.',                 6),
(3, 'Bom evento mas o coffee break poderia ser melhor.',                           7),
(5, 'Incrível! Já estou ansioso para a próxima edição.',                          9),
(4, 'Excelente conteúdo. Só o horário que ficou apertado.',                       10),
(5, 'Workshop muito prático e objetivo. Saí com código funcionando!',             11),
(4, 'Conteúdo muito bom mas poderia ter mais tempo de prática.',                  12),
(5, 'Perfeito! Exatamente o que precisava para o meu projeto.',                   13),
(5, 'Simpósio de alto nível. Apresentações de qualidade.',                        15),
(4, 'Evento muito bem organizado para o tamanho do campus.',                      18),
(5, 'Hackathon desafiador e super produtivo! Adorei!',                            19),
(5, 'Experiência única! Aprendizado intenso em 24h.',                             20),
(4, 'Palestra muito relevante para quem está entrando no mercado.',               22),
(5, 'Abriu minha mente sobre as oportunidades em TI.',                            23),
(5, 'Workshop essencial para qualquer profissional de TI.',                       27);

-- ============================================================
-- NOTIFICAÇÕES
-- ============================================================
INSERT INTO notificacao (mensagem, tipo, lida, id_pessoa, id_evento) VALUES
('Sua inscrição na SECOMP 2024 foi confirmada!',                       'SISTEMA', TRUE,  8,  1),
('Sua inscrição na SECOMP 2024 foi confirmada!',                       'SISTEMA', TRUE,  9,  1),
('Seu certificado da SECOMP 2024 está disponível!',                    'EMAIL',   FALSE, 8,  1),
('Seu certificado da SECOMP 2024 está disponível!',                    'EMAIL',   FALSE, 9,  1),
('Você foi inscrito no Workshop de IA. Confirme sua presença.',        'SISTEMA', TRUE,  8,  2),
('Lembrete: Workshop de IA acontece amanhã às 14h.',                   'SMS',     TRUE,  9,  2),
('Seu certificado do Workshop de IA foi emitido!',                     'EMAIL',   TRUE,  8,  2),
('Inscrições abertas: Curso de Extensão React. Vagas limitadas!',      'SISTEMA', FALSE, 8,  6),
('Inscrições abertas: Curso de Extensão React. Vagas limitadas!',      'SISTEMA', FALSE, 10, 6),
('Hackathon UPE: Você está inscrito! Prepare-se para 24h de código.', 'SISTEMA', TRUE,  8,  4);
