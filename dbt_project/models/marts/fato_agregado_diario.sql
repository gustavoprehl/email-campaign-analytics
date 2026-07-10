-- Fato de performance por campanha e disparo. Usa SAFE_DIVIDE em vez de
-- divisao direta para evitar erros quando qtd_entregues ou qtd_abertos sao
-- zero (disparo sem nenhuma entrega/abertura registrada).
select
    f.id_campanha,
    f.id_disparo,
    f.dat_referencia,
    c.id_marca,
    c.tipo_campanha,
    f.qtd_enviados,
    f.qtd_bounces,
    f.qtd_entregues,
    f.qtd_abertos,
    f.qtd_clicks,
    safe_divide(f.qtd_abertos, f.qtd_entregues) as taxa_abertura,
    safe_divide(f.qtd_clicks, f.qtd_entregues) as ctr,
    safe_divide(f.qtd_clicks, f.qtd_abertos) as ctor
from {{ ref('int_funil_por_disparo') }} as f
left join {{ ref('dim_campanha') }} as c
    on f.id_campanha = c.id_campanha
