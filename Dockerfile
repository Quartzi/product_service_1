# Stage 1: Build stage
FROM maven:3.9-amazoncorretto-21 AS builder

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Dummy secret för build
ENV JWT_SECRET=dummysecret
ENV JWT_EXPIRATION=3600000
ENV BACKEND_PORT=8080
ENV MASTER_KEY=some_secure_key

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Runtime stage
FROM amazoncorretto:21-alpine

# Set working directory
WORKDIR /app

# Sätt fallback JWT_SECRET och BACKEND_PORT
ENV JWT_SECRET=dummysecret
ENV JWT_EXPIRATION=3600000
ENV BACKEND_PORT=8080
ENV MASTER_KEY=some_secure_key

# Copy the JAR file from the build stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port 8080
EXPOSE 8080
Expose 8081

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
