package bkp.search;

import org.apache.http.HttpHost;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.elasticsearch.action.search.SearchResponse;

import javax.annotation.PreDestroy;
import java.io.IOException;


@SpringBootApplication
@RestController
public class SearchApplication {
	static RestHighLevelClient client;

	public static void main(String[] args) {
		client = new RestHighLevelClient(
			RestClient.builder(
				new HttpHost("elasticsearch-service", 9200, "http")));
		SpringApplication.run(SearchApplication.class, args);
	}

	@GetMapping("/text")
	public String text(@RequestParam(value = "pattern", defaultValue = "") String pattern) {
		SearchRequest searchRequest = new SearchRequest("test");
		SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
		searchSourceBuilder.query(QueryBuilders.matchQuery("content.text", pattern));
		searchRequest.source(searchSourceBuilder);
		try {
			SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
			return searchResponse.toString();
		} catch (IOException e) {
			throw new ExampleException("dupacipa " + e.getMessage());
		}
	}

	@ResponseStatus(value = HttpStatus.SERVICE_UNAVAILABLE, reason="Kutasie")
	public class ExampleException extends RuntimeException {
		String s;
		public ExampleException(String s){
			super();
			this.s = s;
		}
	}

	@PreDestroy
	public void onExit() {
		try {
			client.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
