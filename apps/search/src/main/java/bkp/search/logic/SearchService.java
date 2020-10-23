package bkp.search.logic;

import bkp.search.model.Offer;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Component
public class SearchService {
  private RestHighLevelClient elasticsearchClient;
  private String indexName;

  public SearchService(RestHighLevelClient elasticsearchClient, String indexName){
    this.elasticsearchClient = elasticsearchClient;
    this.indexName = indexName;
  }

  public List<Offer> getOffersThatHaveText(String pattern) throws SearchException {
    SearchRequest searchRequest = new SearchRequest(this.indexName);
    SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
    searchSourceBuilder.query(QueryBuilders.matchQuery("content.text", pattern));
    searchRequest.source(searchSourceBuilder);
    try {
      SearchResponse searchResponse = this.elasticsearchClient.search(searchRequest, RequestOptions.DEFAULT);
      return new ArrayList<>(); // searchResponse.getHits(); TODO
    } catch (IOException e) {
      throw new SearchException("Something went wrong: " + e.toString());
    }
  }
}
