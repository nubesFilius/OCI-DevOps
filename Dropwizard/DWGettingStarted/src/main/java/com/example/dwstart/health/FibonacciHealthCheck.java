package com.example.dwstart.health;

import com.codahale.metrics.health.HealthCheck;

public class FibonacciHealthCheck extends HealthCheck {
    private final int defaultMemberCount;

    public FibonacciHealthCheck(int defaultMemberCount) {
        this.defaultMemberCount = defaultMemberCount;
    }

    @Override
    protected Result check() throws Exception {
        if (defaultMemberCount == 0) {
            return Result.unhealthy("Default member is 0");
        }
        return Result.healthy();
    }

}
