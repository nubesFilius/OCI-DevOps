package com.example.dwstart.resources;

import com.example.dwstart.api.Fibonacci;
import com.codahale.metrics.annotation.Timed;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import java.util.Optional;

@Path("/fibonacci-members")
@Produces(MediaType.APPLICATION_JSON)
public class FibonacciMembersResource {

  private final int defaultMemberCount;
  private final int[] sequence;
  private final int total;

  public FibonacciMembersResource(int defaultMemberCount, int[] sequence, int total) {

    this.defaultMemberCount = defaultMemberCount;
    this.sequence = sequence;
    this.total = total;
  }

  @GET
  @Timed
  public Fibonacci showFibonacci() {
    return new Fibonacci(defaultMemberCount, sequence, total);
  }
}