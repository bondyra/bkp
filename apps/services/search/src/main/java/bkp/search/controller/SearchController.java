package bkp.search.controller;

import bkp.search.logic.SearchException;
import bkp.search.logic.SearchService;
import bkp.search.model.Offer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequestMapping("/search")
public class SearchController {
  private static Logger logger = LoggerFactory.getLogger(SearchController.class);
  private final SearchService service;

  public SearchController(SearchService service) {
    this.service = service;
  }

  @RequestMapping(method = RequestMethod.GET)
  ResponseEntity<List<Offer>> fullTextSearch(
    @RequestParam(value = "pattern", defaultValue = "") String pattern
  ) throws SearchException {
    var results = service.getOffersThatHaveText(pattern);
    return ResponseEntity.ok(results);
  }

  @ExceptionHandler(SearchException.class)
  ResponseEntity<String> handleSearchException(SearchException e) {
    logger.error("Search has failed", e);
    return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).build();
  }
}
