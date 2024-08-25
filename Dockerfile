#
# Build a UBI-based container image with OpenShift clients.
#
# Reference: https://github.com/RHsyseng/container-rhel-examples
#
# podman login registry.redhat.io
#
# FROM registry.access.redhat.com/ubi9/podman:9.4-12
FROM registry.access.redhat.com/ubi8/podman
MAINTAINER Bob Kozdemba <bkozdemba@gmail.com>
    
### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root
RUN mkdir -p ${APP_ROOT}/{bin,src} && \
    chmod -R u+x ${APP_ROOT}/bin && chgrp -R 0 ${APP_ROOT} && chmod -R g=u ${APP_ROOT}
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}

# Install OCP client binaries.
RUN yum -y install jq bind-utils net-tools git wget python3-pip python38 python3.11 python3.12 python39 && yum clean all -y

# RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz | tar zxf - --directory=${APP_ROOT}/bin && \
#     wget https://dl.bintray.com/odo/odo/latest/linux-amd64/odo -O ${APP_ROOT}/bin/odo && \    
#     chmod u=rwx,g=rx,o=rx ${APP_ROOT}/bin/odo

### Containers should NOT run as root as a good practice
USER 1001
WORKDIR ${APP_ROOT}

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
# ENTRYPOINT [ "uid_entrypoint" ]

VOLUME ${APP_ROOT}/logs ${APP_ROOT}/data

COPY index.html .

### Just wait forever. Allows this container to act as a debugging tool.
# CMD /usr/bin/tail -f /dev/null
CMD python3 -m http.server 8080
