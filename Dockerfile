# Dockerfile

# --- Stage 1: Build the application using Maven ---
# We use an official Maven image that includes the Java Development Kit (JDK)
FROM maven:3.8.5-openjdk-17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the project's dependency definition file
COPY pom.xml .

# Copy the rest of the application source code
COPY src ./src

# Run the Maven command to build the application into a .jar file
# '-DskipTests' is used to speed up the build in CI/CD
RUN mvn package -DskipTests


# --- Stage 2: Create the final, lightweight production image ---
# We use a slim image with just the Java Runtime Environment (JRE) for security and size.
FROM eclipse-temurin:17-jre-jammy

# Set the working directory
WORKDIR /app

# Copy ONLY the built .jar file from the 'build' stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port the application runs on (Spring Boot default is 8080)
EXPOSE 8080

# The command to run when the container starts
ENTRYPOINT ["java", "-jar", "app.jar"]