# Medidas DAX — email_campaign_analytics.pbix

Todas as medidas abaixo sao criadas na tabela `fato_agregado_diario` (ou
`fato_anomalias`, quando indicado), consumindo o modelo estrela publicado
pelo dbt no dataset `email_campaign_dbt`.

## Por que recalcular via SUM em vez de usar as colunas taxa_abertura/ctr/ctor do fato?

O fato `fato_agregado_diario` ja traz `taxa_abertura`, `ctr` e `ctor`
pre-calculados por linha (grao = campanha + disparo). Uma medida DAX que
faz `AVERAGE(fato_agregado_diario[ctr])` produziria uma **media de medias**,
distorcida quando os disparos tem volumes de envio muito diferentes entre si
(um disparo de 50 envios pesaria igual a um de 5.000). As medidas abaixo
recalculam a partir de `SUM(qtd_clicks)/SUM(qtd_entregues)` etc., garantindo
que o calculo seja ponderado corretamente em qualquer nivel de agregacao
(dia, mes, campanha, marca) que o usuario escolher nos filtros do relatorio.

## Medidas principais

Os nomes `CTR` e `CTOR` colidiriam com as colunas `ctr`/`ctor` ja existentes
em `fato_agregado_diario` (o Power BI trata nomes de medida/coluna como
case-insensitive dentro da mesma tabela), por isso as medidas usam o sufixo
`%` para diferenciar claramente "medida calculada" de "coluna bruta do fato".

```dax
Taxa de Abertura =
DIVIDE(SUM(fato_agregado_diario[qtd_abertos]), SUM(fato_agregado_diario[qtd_entregues]))

CTR % =
DIVIDE(SUM(fato_agregado_diario[qtd_clicks]), SUM(fato_agregado_diario[qtd_entregues]))

CTOR % =
DIVIDE(SUM(fato_agregado_diario[qtd_clicks]), SUM(fato_agregado_diario[qtd_abertos]))

Total Disparos =
DISTINCTCOUNT(fato_agregado_diario[id_disparo])

Total Anomalias =
CALCULATE(
    COUNTROWS(fato_anomalias),
    fato_anomalias[flg_anomalia_injetada] = TRUE()
)

CTR MoM % =
VAR CTRAtual = [CTR %]
VAR CTRMesAnterior = CALCULATE([CTR %], DATEADD(dim_data[dat_referencia], -1, MONTH))
RETURN DIVIDE(CTRAtual - CTRMesAnterior, CTRMesAnterior)
```

## Pre-requisito para CTR MoM %

A medida `CTR MoM %` depende de `DATEADD`, que exige uma Date Table valida:

1. Selecionar a tabela `dim_data` no painel de campos.
2. Modelagem > Marcar como tabela de datas > coluna `dat_referencia`.
3. Confirmar que existe um relacionamento 1:N de `dim_data[dat_referencia]`
   para `fato_agregado_diario[dat_referencia]` (e para `fato_anomalias[dat_referencia]`).

Alem disso, como `fato_agregado_diario` e `fato_anomalias` sao duas tabelas
fato separadas que compartilham as mesmas dimensoes, tambem e necessario
criar manualmente (o autodetect do Power BI so pega relacionamentos que
envolvem `fato_agregado_diario`):
- `fato_anomalias[id_campanha]` -> `dim_campanha[id_campanha]`
- `fato_anomalias[id_marca]` -> `dim_marca[id_marca]`
