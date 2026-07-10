-- Dimensao de campanhas (jornadas de e-mail marketing)
-- Fonte: dim_campanha (raw)
select
    id_campanha,
    id_marca,
    nome_jornada,
    tipo_campanha,
    cast(dat_inicio as date) as dat_inicio,
    cast(dat_fim as date) as dat_fim
from {{ source('email_campaign_raw', 'dim_campanha') }}
