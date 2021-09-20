package com.example.dwstart;

import io.dropwizard.Application;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import com.example.dwstart.resources.FibonacciMembersResource;
// import com.example.dwstart.health.FibonacciHealthCheck;

public class FibonacciMembersApp extends Application<FibonacciMembersConfig> {
    public static void main(String[] args) throws Exception {
        new FibonacciMembersApp().run(args);
    }

    @Override
    public void initialize(Bootstrap<FibonacciMembersConfig> bootstrap) {
        // nothing to do yet
    }

    @Override
    public void run(FibonacciMembersConfig configuration, Environment environment) {
        final FibonacciMembersResource resource = new FibonacciMembersResource(configuration.getMemberCount(),
                configuration.getSequence(), configuration.getTotal());
        // final TemplateHealthCheck healthCheck = new
        // FibonacciHealthCheck(configuration.getSequence());
        // environment.healthChecks().register("template", healthCheck);
        environment.jersey().register(resource);
    }

}