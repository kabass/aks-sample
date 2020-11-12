FROM openjdk:12
ADD ../target/*.jar /app/
EXPOSE 80
VOLUME /app/logs
ENTRYPOINT ["java", "-jar", "user-mysql.jar"]
