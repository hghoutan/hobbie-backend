FROM maven:3.8.4-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn package -DskipTests

FROM openjdk:17-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENV JAVA_OPTS="-Xmx256m -XX:MaxRAMPercentage=75.0 -Djdk.internal.platform.cgroupMetricsRecording=false -XX:+UseContainerSupport -Dspring.metrics.export.enabled=false"
ENTRYPOINT ["java", "-Xmx256m", "-Djdk.internal.platform.cgroupMetricsRecording=false", "-jar", "app.jar"]
