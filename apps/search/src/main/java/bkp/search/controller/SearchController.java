package bkp.search.controller;

import bkp.search.logic.SearchService;
import bkp.search.model.Offer;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class SearchController {
  private SearchService service;

  @RequestMapping(method = RequestMethod.GET)
  ResponseEntity<List<Offer>> fullTextSearch(@RequestParam(value = "pattern", defaultValue = "") String pattern) {
    return ResponseEntity.ok(service.getOffersThatHaveText(pattern));
  }
}
