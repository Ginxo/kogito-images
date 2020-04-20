@quay.io/kiegroup/kogito-springboot-ubi8-s2i
Feature: kogito-springboot-ubi8-s2i image tests

  Scenario: Verify if the s2i build is finished as expected
    Given s2i build https://github.com/kiegroup/kogito-examples.git from process-springboot-example using 0.9.x and runtime-image quay.io/kiegroup/kogito-springboot-ubi8:latest
      | variable            | value        |
      | JAVA_OPTIONS        | -Ddebug=true |
    Then check that page is served
      | property             | value     |
      | port                 | 8080      |
      | path                 | /orders/1 |
      | wait                 | 80        |
      | expected_status_code | 204       |
    And file /home/kogito/bin/process-springboot-example.jar should exist
    And container log should contain DEBUG 1 --- [           main] o.s.boot.SpringApplication
    And run sh -c 'echo $JAVA_OPTIONS' in container and immediately check its output for -Ddebug=true

  Scenario: Verify if the s2i build is finished as expected
    Given s2i build https://github.com/kiegroup/kogito-examples.git from process-springboot-example using 0.9.x
      | variable            | value        |
      | JAVA_OPTIONS        | -Ddebug=true |
    Then check that page is served
      | property             | value     |
      | port                 | 8080      |
      | path                 | /orders/1 |
      | wait                 | 80        |
      | expected_status_code | 204       |
    And file /home/kogito/bin/process-springboot-example.jar should exist
    And container log should contain DEBUG 1 --- [           main] o.s.boot.SpringApplication
    And run sh -c 'echo $JAVA_OPTIONS' in container and immediately check its output for -Ddebug=true

  Scenario: Verify if the s2i build is finished as expected performing a native build and if it is listening on the expected port, test uses custom properties file to test the port configuration.
    Given s2i build /tmp/kogito-examples from process-springboot-example using 0.9.x and runtime-image quay.io/kiegroup/kogito-springboot-ubi8:latest
      | variable            | value        |
    Then check that page is served
      | property             | value     |
      | port                 | 8080      |
      | path                 | /orders/1 |
      | wait                 | 80        |
      | expected_status_code | 204       |
    And file /home/kogito/bin/process-springboot-example.jar should exist
    And container log should contain Tomcat initialized with port(s): 8080 (http)

  Scenario: Verify if the s2i build is finished as expected performing a non native build with persistence enabled
    Given s2i build https://github.com/kiegroup/kogito-examples.git from process-springboot-example using 0.9.x and runtime-image quay.io/kiegroup/kogito-springboot-ubi8:latest
      | variable          | value         |
      | MAVEN_ARGS_APPEND | -Ppersistence |
    Then file /home/kogito/bin/process-springboot-example.jar should exist
    And s2i build log should contain '/home/kogito/bin/demo.orders.proto' -> '/home/kogito/data/protobufs/demo.orders.proto'
    And s2i build log should contain '/home/kogito/bin/persons.proto' -> '/home/kogito/data/protobufs/persons.proto'
    And s2i build log should contain ---> [persistence] generating md5 for persistence files
    And run sh -c 'cat /home/kogito/data/protobufs/persons-md5.txt' in container and immediately check its output for b19f6d73a0a1fea0bfbd8e2e30701d78
    And run sh -c 'cat /home/kogito/data/protobufs/demo.orders-md5.txt' in container and immediately check its output for 02b40df868ebda3acb3b318b6ebcc055

  Scenario: Verify if the s2i build is finished as expected using multi-module build
    Given s2i build https://github.com/kiegroup/kogito-examples.git from . using 0.9.x and runtime-image quay.io/kiegroup/kogito-springboot-ubi8:latest
      | variable            | value                           |
      | JAVA_OPTIONS        | -Ddebug=true                    |
      | ARTIFACT_DIR        | process-springboot-example/target   |
      | MAVEN_ARGS_APPEND   | -pl process-springboot-example -am  |
    Then check that page is served
      | property             | value     |
      | port                 | 8080      |
      | path                 | /orders/1 |
      | wait                 | 80        |
      | expected_status_code | 204       |
    And file /home/kogito/bin/process-springboot-example.jar should exist
    And container log should contain DEBUG 1 --- [           main] o.s.boot.SpringApplication
    And run sh -c 'echo $JAVA_OPTIONS' in container and immediately check its output for -Ddebug=true

  Scenario: Scenario: Perform a incremental s2i build
    Given s2i build https://github.com/kiegroup/kogito-examples.git from process-springboot-example with env and incremental using 0.9.x
    Then check that page is served
      | property             | value     |
      | port                 | 8080      |
      | path                 | /orders/1 |
      | wait                 | 80        |
      | expected_status_code | 204       |
    And file /home/kogito/bin/process-springboot-example.jar should exist

  # Since the same image is used we can do a subsequent incremental build and verify if it is working as expected.
  Scenario: Perform a second incremental s2i build
    Given s2i build https://github.com/kiegroup/kogito-examples.git from process-springboot-example with env and incremental using 0.9.x
    Then s2i build log should contain Expanding artifacts from incremental build...
    And s2i build log should not contain WARNING: Clean build will be performed because of error saving previous build artifacts

  Scenario: verify if all labels are correctly set.
    Given image is built
    Then the image should contain label maintainer with value kogito <kogito@kiegroup.com>
    And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
    And the image should contain label io.openshift.s2i.destination with value /tmp
    And the image should contain label io.openshift.expose-services with value 8080:http
    And the image should contain label io.k8s.description with value Platform for building Kogito based on SpringBoot
    And the image should contain label io.k8s.display-name with value Kogito based on SpringBoot
    And the image should contain label io.openshift.tags with value builder,kogito,springboot

  Scenario: verify if the maven and java installation is correct
    When container is started with command bash
    Then run sh -c 'echo $JAVA_HOME' in container and immediately check its output for /usr/lib/jvm/java-11
    And run sh -c 'echo $JAVA_VENDOR' in container and immediately check its output for openjdk
    And run sh -c 'echo $JAVA_VERSION' in container and immediately check its output for 11
    And run sh -c 'echo $MAVEN_HOME' in container and immediately check its output for /usr/share/maven
    And run sh -c 'echo $MAVEN_VERSION' in container and immediately check its output for 3.6.2
