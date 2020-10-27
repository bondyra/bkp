package bkp.search.controller;

import bkp.search.logic.SearchException;
import bkp.search.logic.SearchService;
import bkp.search.model.Offer;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDateTime;
import java.util.Arrays;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class SearchControllerIntegrationTest {
  @LocalServerPort
  private int port;

  @MockBean
  private SearchService service;

  @Autowired
  private TestRestTemplate restTemplate;

  private String searchUrl(String pattern){
    return UriComponentsBuilder.fromHttpUrl("http://localhost:" + port + "/search")
      .queryParam("pattern", pattern)
      .toUriString();
  }

  @Test
  void httpGet_returnsResults() throws SearchException {
    var offer1 = new Offer("indexedId1", "link1", LocalDateTime.now(), "title1");
    var offer2 = new Offer("indexedId2", "link2", LocalDateTime.now(), "title2");
    when(service.getOffersThatHaveText("text")).thenReturn(Arrays.asList(offer1, offer2));

    var results = restTemplate.getForObject(searchUrl("text"), Offer[].class);

    assertThat(results).usingFieldByFieldElementComparator().hasSameElementsAs(Arrays.asList(offer1, offer2));
  }

  @Test
  void httpGet_returnsServiceUnavailable_whenSomethingWentWrong() throws SearchException {
    when(service.getOffersThatHaveText("pattern"))
      .thenThrow(SearchException.class);

    var response = restTemplate.getForEntity(searchUrl("pattern"), ResponseEntity.class);

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.SERVICE_UNAVAILABLE);
  }
}
