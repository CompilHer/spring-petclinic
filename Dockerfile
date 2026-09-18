# STAGE 1: Build the application
# Use an official JDK image to compile the code
FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /app

# Copy the Maven wrapper and configuration files
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Download dependencies (caching step)
RUN ./mvnw dependency:go-offline

# Copy the actual source code and build the application
COPY src src
# We skip tests here because Jenkins will have already run them in a previous stage
RUN ./mvnw clean package -DskipTests

# STAGE 2: Create the production image
# Use a lighter JRE image since we only need to run the compiled code, not build it
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Copy the compiled .jar file from the 'build' stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port the Spring Boot app runs on
EXPOSE 8080

# Define the command to start the application
ENTRYPOINT ["java", "-jar", "app.jar"]