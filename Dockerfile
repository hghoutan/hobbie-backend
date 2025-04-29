# Stage 1: Build the application
FROM maven:3.8-openjdk-11 AS build
WORKDIR /app

# Copy pom.xml first for better layer caching
COPY pom.xml .
# Download dependencies (this layer can be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline

# Copy the rest of the project files
COPY src/ ./src/

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Create the production image
FROM openjdk:11-jre-slim
WORKDIR /app

# Copy the built JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port the app runs on (Railway automatically sets PORT)
EXPOSE 8080

# Add health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=60s --retries=3 CMD wget --quiet --tries=1 --spider http://localhost:${PORT:-8080}/actuator/health || exit 1

# Command to run the application
# This will use Railway's PORT env variable if set, otherwise default to 8080
CMD ["sh", "-c", "java -jar -Dserver.port=${PORT:-8080} -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE:-prod} app.jar"]