FROM openjdk:12
ADD ../target/*.jar /app/poc-aks.jar
EXPOSE 80
VOLUME /app/logs
ENTRYPOINT ["java", "-jar", "/app/poc-aks.jar"]
