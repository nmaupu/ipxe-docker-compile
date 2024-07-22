FROM ubuntu:24.10

ENV HOME /tmp

ARG UID
ARG GID

RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential git liblzma-dev mkisofs unzip wget coreutils isolinux

RUN \
  (groupadd -g ${GID} || true) && \
  (useradd -u ${UID} -g ${GID} || true)

ADD ./build.sh /bin/build.sh

RUN chmod +x /bin/build.sh

VOLUME /compile /opt/ipxe.local

RUN mkdir /compile && chown -R $UID:$GID /compile

USER ${UID}

CMD ["/bin/build.sh"]
