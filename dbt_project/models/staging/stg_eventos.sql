-- Eventos individuais de campanha (sent/open/click/bounce/unsubscribe)
-- Fonte: fato_evento (raw)
select
    id_evento,
    id_campanha,
    id_subscriber,
    tipo_evento,
    timestamp(dat_evento) as dat_evento,
    id_disparo
from {{ source('email_campaign_raw', 'fato_evento') }}
