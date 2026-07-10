-- Agrega stg_eventos (estrutura longa, uma linha por evento) em metricas de
-- funil por campanha e disparo. Usa COUNT(DISTINCT ... IF tipo_evento = X)
-- em vez de JOINs entre tipos de evento, o que distorceria as contagens
-- (um subscriber pode gerar varios eventos do mesmo tipo no mesmo disparo).
select
    id_campanha,
    id_disparo,
    date(min(dat_evento)) as dat_referencia,
    count(distinct if(tipo_evento = 'sent', id_subscriber, null))
        as qtd_enviados,
    count(distinct if(tipo_evento = 'bounce', id_subscriber, null))
        as qtd_bounces,
    count(distinct if(tipo_evento = 'sent', id_subscriber, null))
    - count(distinct if(tipo_evento = 'bounce', id_subscriber, null))
        as qtd_entregues,
    count(distinct if(tipo_evento = 'open', id_subscriber, null))
        as qtd_abertos,
    count(distinct if(tipo_evento = 'click', id_subscriber, null))
        as qtd_clicks
from {{ ref('stg_eventos') }}
group by id_campanha, id_disparo
