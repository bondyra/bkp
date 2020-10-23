package bkp.search.controller;

import bkp.search.logic.SearchException;
import bkp.search.logic.SearchService;
import bkp.search.model.Offer;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Arrays;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class SearchControllerIntegrationTest {
  @LocalServerPort
  private int port;

  @MockBean
  private SearchService service;

  @Autowired
  private TestRestTemplate restTemplate;

  @Test
  void httpGet_returnsResults() throws SearchException {
    when(service.getOffersThatHaveText("text"))
      .thenReturn(Arrays.asList(new Offer(), new Offer()));

    var url = UriComponentsBuilder.fromHttpUrl("http://localhost:" + port + "/search")
      .queryParam("pattern", "text")
      .toUriString();
    var results = restTemplate.getForObject(url, Offer[].class);

    assertThat(results).hasSize(2);
  }

  @Test
  void httpGet_returns503_whenSomethingWentWrong() throws SearchException {
    when(service.getOffersThatHaveText("pattern"))
      .thenThrow(SearchException.class);

    // TODO
  }
}
