"""Carrega os CSVs brutos do projeto email-campaign-anomaly-detection no BigQuery.

Uso:
    python load_to_bigquery.py [caminho_para_data_raw]

O caminho para a pasta data/raw/ do projeto 1 pode ser passado como argumento
posicional ou definido via variavel de ambiente SOURCE_DATA_PATH. O projeto
de destino no BigQuery e definido via GCP_PROJECT_ID (default: o projeto
sandbox criado para este portfolio).
"""
import logging
import os
import sys
from pathlib import Path

import pandas as pd
from google.cloud import bigquery

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

PROJECT_ID = os.environ.get("GCP_PROJECT_ID", "email-campaign-analytics-gp")
DATASET_ID = "email_campaign_raw"
DATASET_LOCATION = "US"

DEFAULT_SOURCE_PATH = Path(__file__).resolve().parents[2] / "email-campaign-anomaly-detection" / "data" / "raw"

# Colunas de cada tabela que exigem cast explicito de data/timestamp antes do load.
# O restante do schema e inferido automaticamente pelo BigQuery a partir dos dtypes do dataframe.
DATE_CAST_COLUMNS = {
    "dim_marca": {"date": [], "timestamp": []},
    "dim_campanha": {"date": ["dat_inicio", "dat_fim"], "timestamp": []},
    "dim_subscriber": {"date": ["dat_cadastro"], "timestamp": []},
    "fato_evento": {"date": [], "timestamp": ["dat_evento"]},
    "gabarito_anomalias": {"date": [], "timestamp": []},
}

BOOL_CAST_COLUMNS = {
    "gabarito_anomalias": ["flg_anomalia_injetada"],
}


def load_csv(raw_path: Path, table_name: str) -> pd.DataFrame:
    df = pd.read_csv(raw_path / f"{table_name}.csv")

    for col in DATE_CAST_COLUMNS[table_name]["date"]:
        df[col] = pd.to_datetime(df[col]).dt.date

    for col in DATE_CAST_COLUMNS[table_name]["timestamp"]:
        df[col] = pd.to_datetime(df[col], format="ISO8601")

    for col in BOOL_CAST_COLUMNS.get(table_name, []):
        df[col] = df[col].astype(bool)

    return df


def ensure_dataset(client: bigquery.Client) -> None:
    dataset_ref = bigquery.DatasetReference(client.project, DATASET_ID)
    try:
        client.get_dataset(dataset_ref)
    except Exception:
        dataset = bigquery.Dataset(dataset_ref)
        dataset.location = DATASET_LOCATION
        client.create_dataset(dataset)
        logger.info("Dataset %s criado em %s", DATASET_ID, DATASET_LOCATION)


def load_table(client: bigquery.Client, df: pd.DataFrame, table_name: str) -> None:
    table_id = f"{client.project}.{DATASET_ID}.{table_name}"
    job_config = bigquery.LoadJobConfig(
        autodetect=True,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )
    job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
    job.result()
    logger.info("%s: %d linhas carregadas em %s", table_name, len(df), table_id)


def resolve_raw_path() -> Path:
    arg_path = sys.argv[1] if len(sys.argv) > 1 else None
    candidate = arg_path or os.environ.get("SOURCE_DATA_PATH") or DEFAULT_SOURCE_PATH
    return Path(candidate)


def main() -> None:
    raw_path = resolve_raw_path()
    if not raw_path.exists():
        logger.error(
            "Caminho de dados nao encontrado: %s. Informe via argumento posicional ou SOURCE_DATA_PATH.",
            raw_path,
        )
        sys.exit(1)

    client = bigquery.Client(project=PROJECT_ID)
    ensure_dataset(client)

    for table_name in DATE_CAST_COLUMNS:
        df = load_csv(raw_path, table_name)
        load_table(client, df, table_name)

    logger.info("Ingestao concluida com sucesso.")


if __name__ == "__main__":
    main()
