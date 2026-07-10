-- Dimensao de marcas anunciantes
-- Fonte: dim_marca (raw)
select
    id_marca,
    nome_marca
from {{ source('email_campaign_raw', 'dim_marca') }}
