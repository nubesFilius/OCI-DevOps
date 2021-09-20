package com.example.dwstart.api;

import com.fasterxml.jackson.annotation.JsonProperty;

public class Fibonacci {
  private int defaultMemberCount;

  private int[] sequence;

  private int total;

  public Fibonacci() {
    // Jackson deserialization
  }

  public Fibonacci(int defaultMemberCount, int[] sequence, int total) {
    this.defaultMemberCount = defaultMemberCount;
    this.sequence = sequence;
    this.total = total;
  }

  @JsonProperty
  public int getMemberCount() {
    return defaultMemberCount;
  }

  @JsonProperty
  public int[] getSequence() {
    return sequence;
  }

  @JsonProperty
  public int getTotal() {
    return total;
  }

  @Override
  public String toString() {
    return "Fibonacci{ member-count=" + defaultMemberCount + ", sequence=" + sequence + ", total=" + total + " }";
  }
}