import os
from pathlib import Path
from tempfile import TemporaryDirectory
from pyspark.sql import SparkSession

if __name__ == "__main__":
    destino = Path("/output")
    host = os.environ["POSTGRES_HOST"]
    banco = os.environ["POSTGRES_DB"]
    url = f"jdbc:postgresql://{host}:5432/{banco}"
    propriedades = {
        "user": os.environ["POSTGRES_USER"],
        "password": os.environ["POSTGRES_PASSWORD"],
        "driver": "org.postgresql.Driver",
    }

    spark = (SparkSession.builder
            .appName("desafio")
            .master("local[2]")
            .config("spark.jars", "/opt/jars/postgresql.jar")
            .getOrCreate())

    try:
        for tabela in ("associado", "conta", "cartao", "movimento"):
            spark.read.jdbc(url, f"public.{tabela}", properties = propriedades).createOrReplaceTempView(tabela)

        consulta = Path(__file__).with_name("movimento_flat.sql").read_text(encoding = "utf-8")
        dados = spark.sql(consulta)

        arquivo = destino / "movimento_flat.csv"

        with TemporaryDirectory(dir = destino) as temporario:
            partes = Path(temporario) / "partes"
            dados.coalesce(1).write.option("header", True).option("escape", '"').csv(str(partes))
            next(partes.glob("part-*.csv")).replace(arquivo)
            
        print(f"CSV gerado: {arquivo.resolve()}")
    finally:
        spark.stop()