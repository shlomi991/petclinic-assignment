# Force linux/amd64 platform to prevent Apple Silicon (ARM) manifest mismatch issues
FROM --platform=linux/amd64 eclipse-temurin:17-jre-alpine

# Security: patch OS packages to fix known Alpine CVEs (e.g. p11-kit)
RUN apk --no-cache upgrade

WORKDIR /app

# Create a non-root user and group for security (Best Practice)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy the compiled jar from the Jenkins workspace
COPY target/spring-petclinic-*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]