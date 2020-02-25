FROM node:12-alpine
USER root

#  This installs open-java-1.8, Jenkins-slave, Node12

ARG VERSION=3.35
ARG user=jenkins
ARG group=jenkins
ARG uid=9000
ARG gid=9000
ARG AGENT_WORKDIR=/home/${user}/agent
ARG TERRAFORM=0.12.12
ARG TERRAGRUNT=v0.20.4

COPY files/jenkins-agent /usr/local/bin/jenkins-agent

ADD https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT}/terragrunt_linux_amd64 /usr/bin/terragrunt
ADD files/xvfb-chromium /usr/bin/xvfb-chromium


RUN mkdir /var/lib/jenkins \
    && addgroup -g ${gid} ${group} \
    && adduser -h /home/${user} -u ${uid} -G ${group} -D ${user} \
    && set -x \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk --no-cache  update \
    && apk --no-cache  upgrade \
    && apk add --no-cache libtool \
    openjdk8 \
    libintl \
    python3 \
    git \
    py-setuptools \
    ansible \
    jq \
    make g++\
    awscli \
    unzip curl sed \
    gifsicle pngquant optipng libjpeg-turbo-utils udev ttf-opensans chromium ca-certificates \
    bash git git-lfs openssh-client openssl procps xvfb fluxbox rsync \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && rm -rf /var/cache/apk/* /tmp/* \
    && pip3 install --upgrade pip setuptools \
    && pip --no-cache-dir install \
    boto \
    boto3 \
    hvac \
    gitpython \
    ansible-lint \
    && npm install -g @angular/cli \
    && npm install -g @angular-devkit/build-angular \
    && mkdir -p /etc/ansible \
    && echo 'localhost' > /etc/ansible/hosts \
    && cd /usr/local \
    && curl --insecure -o ./sonarscanner.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip \
    && unzip sonarscanner.zip \
    && rm sonarscanner.zip \
    && mv sonar-scanner-3.3.0.1492-linux /usr/lib/sonar-scanner \
    && ln -s /usr/lib/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner \
    && sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /usr/lib/sonar-scanner/bin/sonar-scanner \
    && curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/agent.jar \
    && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar \
    && mkdir -p /home/${user}/.jenkins \
    && mkdir -p ${AGENT_WORKDIR} \
    && curl --insecure -fsSLo ./terraform_${TERRAFORM}_linux_amd64.zip -L https://releases.hashicorp.com/terraform/${TERRAFORM}/terraform_${TERRAFORM}_linux_amd64.zip \
    && unzip ./terraform_${TERRAFORM}_linux_amd64.zip -d /usr/bin/ \
    && rm -f ./terraform_${TERRAFORM}_linux_amd64.zip \
    && chmod +x /usr/local/bin/jenkins-agent /usr/bin/terragrunt /usr/bin/terraform /usr/bin/xvfb-chromium \
    && ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave \
    && ln -sf /usr/bin/xvfb-chromium /usr/bin/google-chrome \
    && rm /usr/bin/python \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && rm -vrf /var/cache/apk/* /tmp/*


ENV CHROME_BIN=/usr/bin/google-chrome \
    CHROME_PATH=/usr/lib/chromium/ \
    SONAR_RUNNER_HOME=/usr/lib/sonar-scanner \
    HOME=/var/lib/jenkins \
    AWS_DEFAULT_REGION=us-east-1 \
    PATH=$PATH:$SONAR_RUNNER_HOME/bin:$CHROME_PATH \
    AGENT_WORKDIR=${AGENT_WORKDIR}

VOLUME /var/lib/jenkins \
       ${AGENT_WORKDIR}

WORKDIR /var/lib/jenkins
