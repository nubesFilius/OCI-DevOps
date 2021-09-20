package com.example.dwstart;

import io.dropwizard.Configuration;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.Arrays;
import javax.validation.constraints.NotNull;

public class FibonacciMembersConfig extends Configuration {
    // @NotEmpty
    // private int memberCount;

    @NotNull(message = "Please enter a member-count")
    private int defaultMemberCount = 6;

    // @NotNull(message = "Sequence is empty")
    private int[] sequence = {};

    @NotNull(message = "Total is empty")
    private int total;

    @JsonProperty
    public int getMemberCount() {
        return defaultMemberCount;
    }

    // @JsonProperty
    // public int setMemberCount(int customMemberCount) {
    // this.defaultMemberCount = customMemberCount;
    // }

    @JsonProperty
    public int[] getSequence() {
        for (int i = 0; sequence.length < defaultMemberCount; i++) {
            if (i == 0) {
                sequence = Arrays.copyOf(sequence, sequence.length + 1);
                sequence[i] = 1;
            } else if (i == 1) {
                sequence = Arrays.copyOf(sequence, sequence.length + 1);
                sequence[i] = 2;
            } else {
                sequence = Arrays.copyOf(sequence, sequence.length + 1);
                sequence[sequence.length - 1] = sequence[sequence.length - 2] + sequence[sequence.length - 3];
            }
        }
        return sequence;

    }

    @JsonProperty
    public int getTotal() {
        for (int i = 0; i < sequence.length; i++) {
            total += sequence[i];
        }
        return total;
    }
}
