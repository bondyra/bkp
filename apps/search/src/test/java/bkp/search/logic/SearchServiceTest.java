package bkp.search.logic;

import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

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
    when(clientMock.search(any(SearchRequest.class), eq(RequestOptions.DEFAULT)))
      .thenReturn(new SearchResponse());
    var expectedRequest = new SearchRequest(testIndexName);
    SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
    searchSourceBuilder.query(QueryBuilders.matchQuery("content.text", "pattern"));
    expectedRequest.source(searchSourceBuilder);

    var offers = toTest.getOffersThatHaveText("pattern");
    verify(clientMock, times(1)).search(eq(expectedRequest), eq(RequestOptions.DEFAULT));
    assertThat(offers).isEmpty();
  }

  @Test
  void getOffersThatHaveText_throwsSpecificException_whenElasticsearchThrowsException() throws IOException {
    when(clientMock.search(any(SearchRequest.class), eq(RequestOptions.DEFAULT))).thenThrow(IOException.class);

    var exception = catchThrowable(() -> toTest.getOffersThatHaveText("dummy"));

    verify(clientMock, times(1)).search(any(SearchRequest.class), eq(RequestOptions.DEFAULT));
    assertThat(exception).isInstanceOf(SearchException.class);
  }
}
