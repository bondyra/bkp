package bkp.search.model;

import java.time.LocalDateTime;

public class Offer {
  private String indexedId;
  private String link;
  private LocalDateTime gatherDate;
  private String title;

  public Offer(String indexedId, String link, LocalDateTime gatherDate, String title) {
    this.indexedId = indexedId;
    this.link = link;
    this.gatherDate = gatherDate;
    this.title = title;
  }

  public Offer() {
  }

  public String getIndexedId() {
    return indexedId;
  }

  public void setIndexedId(String indexedId) {
    this.indexedId = indexedId;
  }

  public String getLink() {
    return link;
  }

  public void setLink(String link) {
    this.link = link;
  }

  public LocalDateTime getGatherDate() {
    return gatherDate;
  }

  public void setGatherDate(LocalDateTime gatherDate) {
    this.gatherDate = gatherDate;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }
}
