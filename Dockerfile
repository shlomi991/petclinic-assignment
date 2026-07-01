# Use a lightweight JRE base image for runtime
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Create a non-root user and group for security (Best Practice)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy the compiled jar from the Jenkins workspace
COPY target/spring-petclinic-*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]