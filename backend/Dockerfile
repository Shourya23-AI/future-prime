FROM eclipse-temurin:21-jre

WORKDIR /opt/app

# Expect the built JAR to be mounted at /opt/app/app.jar (or copied in during image build)
ENV JAVA_OPTS=""

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /opt/app/app.jar"]
