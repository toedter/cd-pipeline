FROM jenkins:2.46.3

USER root
RUN apt-get update \
      && apt-get install -y sudo curl\
      && rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN usermod -G users jenkins

# getting the docker-cli
# --- Attention: docker.sock needs to be mounted as volume in docker-compose.yml
# see: https://issues.jenkins-ci.org/browse/JENKINS-35025
# see: https://get.docker.com/builds/
# see: https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Custom+Build+Environment+Plugin#CloudBeesDockerCustomBuildEnvironmentPlugin-DockerinDocker
RUN curl -sSL -O https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz && tar -xvzf docker-latest.tgz
RUN mv docker/* /usr/bin/


# installing specific list of plugins. see: https://github.com/jenkinsci/docker#preinstalling-plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN xargs /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

#USER jenkins

# Adding default Jenkins Jobs
COPY jobs/1-ms60min-job.xml /usr/share/jenkins/ref/jobs/1-ms60min-job/config.xml

# Jenkins settings
COPY config.xml /usr/share/jenkins/ref/config.xml

# Material Design Theme
COPY theme/org.codefirst.SimpleThemeDecorator.xml /usr/share/jenkins/ref/org.codefirst.SimpleThemeDecorator.xml