FROM innovanon/poobuntu-dev:latest
#FROM innovanon/poobuntu:latest
MAINTAINER Innovations Anonymous <InnovAnon-Inc@protonmail.com>

LABEL version="1.0"                                                       \
      maintainer="Innovations Anonymous <InnovAnon-Inc@protonmail.com>"   \
      about="dockerized apt-cacher-ng"                                    \
      org.label-schema.build-date=$BUILD_DATE                             \
      org.label-schema.license="PDL (Public Domain License)"              \
      org.label-schema.name="apt-cacher-ng"                               \
      org.label-schema.url="InnovAnon-Inc.github.io/docker-apt-cacher-ng" \
      org.label-schema.vcs-ref=$VCS_REF                                   \
      org.label-schema.vcs-type="Git"                                     \
      org.label-schema.vcs-url="https://github.com/InnovAnon-Inc/docker-apt-cacher-ng"

RUN for k in `find /etc/apt/sources.list /etc/apt/sources.list.d -type f` ; do \
      /bin/echo "`cat $k`\n`sed 's/^deb/deb-src/' $k`" > $k                  ; \
    done \
 && apt-fast update

RUN apt-fast install firejail

RUN mkdir -pv /usr/src /usr/out /usr/local/bin
#RUN mkdir -pv /usr/src
#VOLUME ["/usr/out"]
#VOLUME ["/dpkg.list"]
WORKDIR /usr/src
COPY buildworld.sh /
ADD https://raw.githubusercontent.com/InnovAnon-Inc/repo/master/repo.sh  /
ADD https://raw.githubusercontent.com/InnovAnon-Inc/repo/master/march.sh /usr/local/bin/
ADD https://raw.githubusercontent.com/InnovAnon-Inc/repo/master/mtune.sh /usr/local/bin/
RUN mv /usr/local/bin/march.sh /usr/local/bin/march \
 && mv /usr/local/bin/mtune.sh /usr/local/bin/mtune \
 && chmod -v +x /repo.sh /usr/local/bin/march /usr/local/bin/mtune
ENTRYPOINT ["/buildworld.sh"]

