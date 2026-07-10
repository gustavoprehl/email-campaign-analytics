-- Dimensao de subscribers (contatos de e-mail marketing)
-- Fonte: dim_subscriber (raw)
select
    id_subscriber,
    nome_fake,
    email_fake,
    id_marca_principal,
    segmento,
    cast(dat_cadastro as date) as dat_cadastro
from {{ source('email_campaign_raw', 'dim_subscriber') }}
