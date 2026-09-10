BEGIN;

CREATE TYPE tipo_conta AS ENUM ('CORRENTE', 'POUPANCA');

CREATE TABLE associado (
    id integer PRIMARY KEY,
    nome varchar(100) NOT NULL,
    sobrenome varchar(100) NOT NULL,
    idade integer NOT NULL CHECK (idade BETWEEN 0 AND 130),
    email varchar(254) NOT NULL UNIQUE
);

CREATE TABLE conta (
    id integer PRIMARY KEY,
    tipo tipo_conta NOT NULL,
    data_criacao timestamp NOT NULL,
    id_associado integer NOT NULL REFERENCES associado(id),
    UNIQUE (id, id_associado)
);

CREATE TABLE cartao (
    id integer PRIMARY KEY,
    num_cartao varchar(19) NOT NULL UNIQUE CHECK (num_cartao ~ '^[0-9]{13,19}$'),
    nom_impresso varchar(100) NOT NULL,
    data_criacao timestamp NOT NULL,
    id_conta integer NOT NULL,
    id_associado integer NOT NULL REFERENCES associado(id),
    FOREIGN KEY (id_conta, id_associado) REFERENCES conta(id, id_associado)
);

CREATE TABLE movimento (
    id integer PRIMARY KEY,
    vlr_transacao decimal(10,2) NOT NULL,
    des_transacao varchar(255) NOT NULL,
    data_movimento timestamp NOT NULL,
    id_cartao integer NOT NULL REFERENCES cartao(id)
);

CREATE INDEX ON conta(id_associado);
CREATE INDEX ON cartao(id_conta, id_associado);
CREATE INDEX ON cartao(id_associado);
CREATE INDEX ON movimento(id_cartao);

COMMIT;
