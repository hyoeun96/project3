# Stage 1: Build stage
FROM alpine:3.14 AS build

# TOMCAT VERSION, HOME DIRECTORY 환경변수 설정
ENV TOMCAT_VERSION=9.0.71
ENV CATALINA_HOME=/opt/tomcat

# 필요한 Package 설치
RUN apk update && \
    apk add --no-cache wget tar openjdk8-jre && \
    rm -rf /var/cache/apk/*

# TOMCAT 설치 및 설치파일 삭제
RUN mkdir $CATALINA_HOME && \
    wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tar.gz && \
    tar xvfz /tmp/tomcat.tar.gz -C $CATALINA_HOME --strip-components=1 && \
    rm -rf /tmp/tomcat.tar.gz && \
    wget https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/2.7.2/mariadb-java-client-2.7.2.jar -P $CATALINA_HOME/lib

# 불필요한 파일 삭제
RUN rm -rf $CATALINA_HOME/webapps/* && \
    rm -rf $CATALINA_HOME/bin/*.bat

# 메인페이지 디렉터리 생성 및 파일 복사
RUN mkdir $CATALINA_HOME/webapps/ROOT
COPY ROOT $CATALINA_HOME/webapps/ROOT
COPY context.xml $CATALINA_HOME/conf/context.xml

# 실행파일 권한 설정
RUN chmod +x $CATALINA_HOME/bin/catalina.sh

# Stage 2: Final stage
FROM alpine:3.14

# TOMCAT 실행을 위한 JDK 설치
RUN apk add --no-cache openjdk8-jre-base tzdata && \
    rm -rf /var/cache/apk/*

# TOMCAT HOME DIRECTORY 및 시간대 설정
ENV CATALINA_HOME=/opt/tomcat
ENV TZ=Asia/Seoul

# Stage 1에서 설치한 TOMCAT 및 메인페이지 복사
COPY --from=build $CATALINA_HOME $CATALINA_HOME

# 포트번호 노출
EXPOSE 8080

# TOMCAT 실행
CMD ["sh", "-c", "$CATALINA_HOME/bin/catalina.sh run"]