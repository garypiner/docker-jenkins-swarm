FROM openjdk:8-jdk

ENV JENKINS_SWARM_VERSION 3.19
ENV HOME /home/jenkins-slave

RUN apt-get update && apt-get install -y net-tools sudo && rm -rf /var/lib/apt/lists/*

RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
  unzip awscli-bundle.zip && \
  sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# RUN sudo wget https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip -O /tmp/terraform_linux_amd64.zip && \
#   sudo unzip /tmp/terraform_linux_amd64.zip -d /usr/local/bin

RUN git clone https://github.com/tfutils/tfenv.git /usr/tfenv && \
  ln -s /usr/tfenv/bin/* /usr/local/bin && \
  tfenv install 0.12.28 && \
  tfenv use 0.12.28

# RUN wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.25.2/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt && \
#   chmod 755 /usr/local/bin/terra*

RUN git clone https://github.com/cunymatthieu/tgenv.git /usr/tgenv && \
  ln -s /usr/tgenv/bin/* /usr/local/bin && \
  tgenv install 0.25.2 && \
  tgenv use 0.25.2

RUN useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave && \
  chown -R jenkins-slave:jenkins-slave $HOME
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
  && chmod 755 /usr/share/jenkins

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

RUN chmod 755 /usr/local/bin/jenkins-slave.sh

USER jenkins-slave
VOLUME /home/jenkins-slave

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]