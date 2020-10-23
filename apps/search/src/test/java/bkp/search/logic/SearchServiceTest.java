package bkp.search.logic;

import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.catchThrowable;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class SearchServiceTest {
  @Test
  void getOffersThatHaveText_worksOk() throws SearchException, IOException {
    var clientMock = mock(RestHighLevelClient.class);
    var service = new SearchService(clientMock, "dummy");
    when(clientMock.search(any(SearchRequest.class), eq(RequestOptions.DEFAULT)))  // TODO specific request match?
      .thenReturn(new SearchResponse());

    var offers = service.getOffersThatHaveText("pattern");

    var expectedRequest = new SearchRequest("dummy");
    SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
    searchSourceBuilder.query(QueryBuilders.matchQuery("content.text", "pattern"));
    expectedRequest.source(searchSourceBuilder);
    verify(clientMock, times(1)).search(eq(expectedRequest), eq(RequestOptions.DEFAULT));
    assertThat(offers).isEmpty();
  }

  @Test
  void getOffersThatHaveText_throwsSpecificException_whenElasticsearchThrowsException() throws IOException {
    var clientMock = mock(RestHighLevelClient.class);
    var service = new SearchService(clientMock, "dummy");
    when(clientMock.search(any(SearchRequest.class), eq(RequestOptions.DEFAULT))).thenThrow(IOException.class);

    var exception = catchThrowable(() -> service.getOffersThatHaveText("dummy"));

    verify(clientMock, times(1)).search(any(SearchRequest.class), eq(RequestOptions.DEFAULT));
    assertThat(exception).isInstanceOf(SearchException.class);
  }
}
