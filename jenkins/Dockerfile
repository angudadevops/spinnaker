FROM jenkins/jenkins:lts
USER root
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
RUN cp jq-linux64 /usr/local/bin/jq
RUN chmod +x /usr/local/bin/jq
USER jenkins
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
