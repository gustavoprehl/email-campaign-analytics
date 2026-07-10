select
    id_subscriber,
    nome_fake,
    email_fake,
    id_marca_principal,
    segmento,
    dat_cadastro
from {{ ref('stg_subscribers') }}
