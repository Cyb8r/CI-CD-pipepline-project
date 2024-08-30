# Stage 1: Build the application
FROM maven:3.8.1-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package

# Stage 2: Create the runtime image
FROM eclipse-temurin:17-jdk-alpine
ENV APP_HOME /usr/src/app
WORKDIR $APP_HOME
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
