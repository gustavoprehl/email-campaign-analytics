-- Dimensao calendario, cobrindo o range de datas do dataset sintetico
-- (2025-07 a 2026-06). Essencial para medidas de serie temporal no Power BI
-- (DATEADD, SAMEPERIODLASTYEAR), que exigem uma tabela de datas continua e
-- sem furos marcada como Date Table.
with spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2025-07-01' as date)",
        end_date="cast('2026-07-01' as date)"
    ) }}
),

calendario as (
    select
        date_day as dat_referencia,
        extract(year from date_day) as ano,
        extract(month from date_day) as mes,
        extract(quarter from date_day) as trimestre,
        extract(dayofweek from date_day) as dia_semana_num
    from spine
)

select
    dat_referencia,
    ano,
    mes,
    trimestre,
    case mes
        when 1 then 'Janeiro' when 2 then 'Fevereiro' when 3 then 'Marco'
        when 4 then 'Abril' when 5 then 'Maio' when 6 then 'Junho'
        when 7 then 'Julho' when 8 then 'Agosto' when 9 then 'Setembro'
        when 10 then 'Outubro' when 11 then 'Novembro' when 12 then 'Dezembro'
    end as nome_mes,
    case dia_semana_num
        when 1 then 'Domingo' when 2 then 'Segunda-feira' when 3 then 'Terca-feira'
        when 4 then 'Quarta-feira' when 5 then 'Quinta-feira' when 6 then 'Sexta-feira'
        when 7 then 'Sabado'
    end as dia_semana,
    dia_semana_num in (1, 7) as flg_fim_de_semana
from calendario
