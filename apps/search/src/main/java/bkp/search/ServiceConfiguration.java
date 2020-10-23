package bkp.search;

import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ServiceConfiguration {
  @Bean
  public RestHighLevelClient elasticsearchClient(ServiceProperties props){
    return new RestHighLevelClient(
      RestClient.builder(
        new HttpHost(props.getHost(), props.getPort(), props.getScheme())));
  }

  @Bean
  public String indexName(ServiceProperties props){
    return props.getIndexName();
  }
}
