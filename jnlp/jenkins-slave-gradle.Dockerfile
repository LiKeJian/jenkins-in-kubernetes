# FROM jenkins/jnlp-slave:alpine
FROM registry.cn-hangzhou.aliyuncs.com/rancococ/jenkins-jnlp-slave:3.29.5-alpine

MAINTAINER liangbo <bo.liang0212@gmail.com>

# set arg info
ARG USER=jenkins
ARG GRADLE_VERSION=6.1
ARG GRADLE_HOME=/usr/local/gradle
ARG GRADLE_REPO=/home/${USER}/.gradle/repository
ARG GRADLE_URL=https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip

# set environment
ENV GRADLE_HOME=${GRADLE_HOME}
ENV GRADLE_USER_HOME=${GRADLE_REPO}

# set current user
USER root

# install gradle
RUN curl --create-dirs -fsSLo /tmp/gradle/gradle.zip ${GRADLE_URL} && \
    mkdir -p ${GRADLE_HOME} && \
    unzip -qo /tmp/gradle/gradle.zip -d /tmp/gradle/ && \
    \cp -rf /tmp/gradle/gradle-${GRADLE_VERSION}/. ${GRADLE_HOME} && \
    chown -R jenkins:jenkins ${GRADLE_HOME} && \
    ln -s ${GRADLE_HOME}/bin/gradle /usr/bin/gradle && \
    \rm -rf /tmp/gradle

# set current user
USER ${USER}

# mkdir .gradle and generate init.gradle
RUN mkdir /home/${USER}/.gradle && \
    mkdir -p /home/${USER}/.gradle/repository && \
    touch /home/${USER}/.gradle/init.gradle && \
    echo 'allprojects {' >> /home/${USER}/.gradle/init.gradle && \
    echo '    repositories {' >> /home/${USER}/.gradle/init.gradle && \
    echo '        mavenLocal()' >> /home/${USER}/.gradle/init.gradle && \
    echo '        maven { url 'https://maven.aliyun.com/repository/public/' }' >> /home/${USER}/.gradle/init.gradle && \
    echo '    }' >> /home/${USER}/.gradle/init.gradle && \
    echo '}' >> /home/${USER}/.gradle/init.gradle

# set volume info
VOLUME /home/${USER}/.gradle