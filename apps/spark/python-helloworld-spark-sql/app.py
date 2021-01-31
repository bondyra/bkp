import pyspark.sql as s
from pyspark.sql.types import StructType, StructField, StringType, IntegerType


def main():
    ss = s.SparkSession.Builder().getOrCreate()
    data = [
        ('dummy1', 2137),
        ('dummy2', 11),
        ('dummy3', 39)
    ]
    schema = StructType([
        StructField("name", StringType(), True),
        StructField("age", IntegerType(), True)]
    )

    df = ss.createDataFrame(data, schema)
    df.createOrReplaceTempView('mytmpview')

    ss.sql('select name as nm, age as ag from mytmpview where age>20').show()


if __name__ == '__main__':
    main()
