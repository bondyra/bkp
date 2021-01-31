import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;

import java.util.Arrays;
import java.util.List;

public class App {
    public static void main(String[] args) {
        SparkSession spark = SparkSession.builder().getOrCreate();
        List<CustomRow> data = Arrays.asList(
                new CustomRow("dummy1", 2137),
                new CustomRow("dummy2", 11),
                new CustomRow("dummy3", 39)
        );

        Dataset<Row> df = spark.createDataFrame(data, CustomRow.class);

        df.createOrReplaceTempView("tmpview");

        spark.sql("select name as nm, age as ag from tmpview where age>20").show();

        spark.stop();
    }
}
