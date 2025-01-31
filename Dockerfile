# BUILD STAGE
FROM ubuntu:22.04

# Install git
RUN apt update
RUN apt install -y git
RUN apt install -y curl

COPY ./zulu23.30.13-ca-crac-jdk23.0.1-linux_aarch64.tar.gz .
RUN tar -xzvf zulu23.30.13-ca-crac-jdk23.0.1-linux_aarch64.tar.gz

ENV PATH="$PATH:/zulu23.30.13-ca-crac-jdk23.0.1-linux_aarch64/bin"

# Clone and build SpringBoot PetClinic Java service
RUN git clone https://github.com/spring-projects/spring-petclinic
# Checkout a specific commit to pin the PetClinic service to a known working version. Comment this out to get latest version.
RUN cd ./spring-petclinic && git checkout 923e2b7aa331b8194a6579da99fb6388f15d7f3e
# Build SpringBoot PetClinic Java service
RUN cd ./spring-petclinic && ./mvnw -Dmaven.test.skip=true clean package

# Add New Relic Java agent jar to work directory
RUN curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic.jar

# SpringBoot listens on port 8080 by default
# To change it set the -Dserver.port=8083 system propery in the following CMD step
# Alternatively, change the SERVER_PORT and port mapping in docker-compose.yml
EXPOSE 8080

# Configure Java agent
ENV NEW_RELIC_APP_NAME=JavaPetClinic
ENV NEW_RELIC_LICENSE_KEY='<license_key>'
ENV NEW_RELIC_JFR_ENABLED=true

ENV NEW_RELIC_HOST=collector.newrelic.com
ENV NEW_RELIC_API_HOST=rpm.newrelic.com
ENV NEW_RELIC_METRIC_INGEST_URI=https://metric-api.newrelic.com/metric/v1
ENV NEW_RELIC_EVENT_INGEST_URI=https://insights-collector.newrelic.com/v1/accounts/events

# Run SpringBoot PetClinic Java service with the New Relic Java agent attached
CMD java -javaagent:newrelic.jar -jar /spring-petclinic/target/spring-petclinic*.jar
# TODO Use below line instead to run without the Java agent
#CMD java -jar spring-petclinic*.jar
