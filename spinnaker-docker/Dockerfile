FROM gcr.io/spinnaker-marketplace/halyard:stable
USER root
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
RUN cp jq-linux64 /usr/local/bin/jq
RUN chmod +x /usr/local/bin/jq
USER spinnaker
COPY start.sh jenkins-job.xml ./
CMD ./start.sh
