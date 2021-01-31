package bkp.search.logic;

import bkp.search.model.Offer;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.SearchHits;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.catchThrowable;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class SearchServiceTest {
  private RestHighLevelClient clientMock;
  private final String testIndexName = "dummy";
  private SearchService toTest;

  @BeforeEach
  public void setUp() {
    this.clientMock = mock(RestHighLevelClient.class);
    this.toTest = new SearchService(clientMock, testIndexName);
  }


  @Test
  void getOffersThatHaveText_worksOk() throws SearchException, IOException {
    var response = mock(SearchResponse.class);
    var hit1 = mock(SearchHit.class);
    when(hit1.getId()).thenReturn("id1");
    var map1 = new HashMap<String, Object>();
    map1.put("link", "link1");
    map1.put("gather_date", "2005-04-02T21:37:01");
    map1.put("content", Collections.singletonMap("title", "title1"));
    when(hit1.getSourceAsMap()).thenReturn(map1);
    var hit2 = mock(SearchHit.class);
    when(hit2.getId()).thenReturn("id2");
    var map2 = new HashMap<String, Object>();
    map2.put("link", "link2");
    map2.put("gather_date", "2005-04-02T21:37:02");
    map2.put("content", Collections.singletonMap("title", "title2"));
    when(hit2.getSourceAsMap()).thenReturn(map2);
    var hitsMock = mock(SearchHits.class);
    when(hitsMock.getHits()).thenReturn(new SearchHit[]{hit1, hit2});
    when(response.getHits()).thenReturn(hitsMock);

    when(clientMock.search(any(SearchRequest.class), eq(RequestOptions.DEFAULT))).thenReturn(response);
    var expectedRequest = new SearchRequest(testIndexName);
    SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
    searchSourceBuilder.query(QueryBuilders.matchQuery("content.text", "pattern"));
    expectedRequest.source(searchSourceBuilder);

    var offers = toTest.getOffersThatHaveText("pattern");
    verify(clientMock, times(1)).search(eq(expectedRequest), eq(RequestOptions.DEFAULT));
    assertThat(offers).usingFieldByFieldElementComparator()
      .hasSameElementsAs(
        Arrays.asList(
          new Offer("id1", "link1",
            LocalDateTime.of(2005, 4, 2, 21, 37, 1), "title1"),
          new Offer("id2", "link2",
            LocalDateTime.of(2005, 4, 2, 21, 37, 2), "title2")
        )
      );
  }

  @Test
  void getOffersThatHaveText_throwsSpecificException_whenElasticsearchThrowsException() throws IOException {
    when(clientMock.search(any(SearchRequest.class), eq(RequestOptions.DEFAULT))).thenThrow(IOException.class);

    var exception = catchThrowable(() -> toTest.getOffersThatHaveText("dummy"));

    verify(clientMock, times(1)).search(any(SearchRequest.class), eq(RequestOptions.DEFAULT));
    assertThat(exception).isInstanceOf(SearchException.class);
  }
}
