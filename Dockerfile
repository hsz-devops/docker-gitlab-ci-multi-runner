FROM ubuntu:16.04
LABEL maintainer="webmaster@highskillz.com"

# combining some elements from [ sameersbn/docker-ubuntu ] with [ digitallumberjack/docker-gitlab-ci-multi-runner ]

ENV GITLAB_CI_MULTI_RUNNER_USER=gitlab_ci_multi_runner \
    GITLAB_CI_MULTI_RUNNER_HOME_DIR="/home/gitlab_ci_multi_runner"
ENV GITLAB_CI_MULTI_RUNNER_DATA_DIR="${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/data"

ENV CA_CERTIFICATES_PATH=''
ENV RUNNER_CONCURRENT=''
ENV CI_SERVER_URL=''
ENV RUNNER_TOKEN=''
ENV RUNNER_EXECUTOR='docker'
ENV RUNNER_DESCRIPTION=''

ENV RUNNER_DOCKER_IMAGE='docker:latest'
ENV RUNNER_DOCKER_MODE='socket'
ENV RUNNER_DOCKER_PRIVATE_REGISTRY_URL=''
ENV RUNNER_DOCKER_PRIVATE_REGISTRY_TOKEN=''
ENV RUNNER_DOCKER_ADDITIONAL_VOLUME=''
ENV RUNNER_OUTPUT_LIMIT='4096'
ENV RUNNER_AUTOUNREGISTER='false'

RUN \
    echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
      apt-get install -y \
        wget sudo net-tools ca-certificates unzip apt-transport-https \
        git-core openssh-client curl libapparmor1 \
        nano \
        less \
 && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
 && DEBIAN_FRONTEND=noninteractive \
      apt-get install -y \
        git-lfs \
 && curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash \
 && DEBIAN_FRONTEND=noninteractive \
      apt-get install -y \
        gitlab-runner \
 && adduser --disabled-login --gecos 'GitLab CI Runner' ${GITLAB_CI_MULTI_RUNNER_USER} \
 && sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} ln -sf ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh ${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/.ssh \
 && DEBIAN_FRONTEND=noninteractive \
      apt-get autoclean -y \
 && rm -rf /var/lib/apt/lists/* \
 && echo "Done!"

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

VOLUME ["${GITLAB_CI_MULTI_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_CI_MULTI_RUNNER_HOME_DIR}"
ENTRYPOINT ["/sbin/entrypoint.sh"]
