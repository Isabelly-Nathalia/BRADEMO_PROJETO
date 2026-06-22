FROM eclipse-temurin:21-jdk

WORKDIR /app

COPY moviematch_back/ .

RUN chmod +x mvnw

RUN ./mvnw clean package -DskipTests

EXPOSE 8080

CMD ["java", "-jar", "target/moviemach-0.0.1-SNAPSHOT.jar"]

