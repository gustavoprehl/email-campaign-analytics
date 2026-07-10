-- Conecta o pipeline de analytics ao gabarito de anomalias injetadas
-- artificialmente pelo projeto 1, permitindo visualizar no dashboard quais
-- campanhas tiveram anomalias, em que datas e de que tipo.
select
    f.id_campanha,
    f.id_disparo,
    f.dat_referencia,
    f.id_marca,
    f.tipo_campanha,
    f.qtd_enviados,
    f.qtd_bounces,
    f.qtd_entregues,
    f.qtd_abertos,
    f.qtd_clicks,
    f.taxa_abertura,
    f.ctr,
    f.ctor,
    a.flg_anomalia_injetada,
    a.tipo_anomalia_injetada
from {{ ref('fato_agregado_diario') }} as f
left join {{ ref('stg_anomalias') }} as a
    on f.id_campanha = a.id_campanha and f.id_disparo = a.id_disparo
