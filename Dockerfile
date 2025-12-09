#
# MIT License
#
# (C) Copyright 2022-2023 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
FROM registry.suse.com/suse/sle15:15.5 AS base
ARG SLE_VERSION
ARG TARGETARCH
ARG user=jenkins
ARG group=jenkins
ARG uid=10000
ARG gid=10000

ENV HOME=/home/${user}
RUN groupadd -g ${gid} ${group} && useradd -l -c "Jenkins USER" -d $HOME -u ${uid} -g ${gid} -m ${user}

RUN sed -i -E "s/^.*(rpm\.install\.excludedocs).*/\1 = yes/" /etc/zypp/zypp.conf

RUN zypper --non-interactive install --no-recommends --force-resolution suseconnect-ng \
    && zypper clean -a

RUN --mount=type=secret,id=SLES_REGISTRATION_CODE suseconnect -r "$(cat /run/secrets/SLES_REGISTRATION_CODE)"

RUN if [ "$TARGETARCH" = 'arm64' ]; then SUSEConnect -p "PackageHub/${SLE_VERSION}/aarch64" ; fi
RUN if [ "$TARGETARCH" = 'amd64' ]; then SUSEConnect -p "PackageHub/${SLE_VERSION}/x86_64" ; fi
RUN if [ "$TARGETARCH" = 'arm64' ]; then SUSEConnect -p "sle-module-web-scripting/${SLE_VERSION}/aarch64" ; fi
RUN if [ "$TARGETARCH" = 'amd64' ]; then SUSEConnect -p "sle-module-web-scripting/${SLE_VERSION}/x86_64" ; fi
RUN if [ "$TARGETARCH" = 'amd64' ]; then SUSEConnect -p "sle-module-desktop-applications/${SLE_VERSION}/x86_64" ; fi
RUN if [ "$TARGETARCH" = 'arm64' ]; then SUSEConnect -p "sle-module-desktop-applications/${SLE_VERSION}/aarch64" ; fi
RUN if [ "$TARGETARCH" = 'amd64' ]; then SUSEConnect -p "sle-module-development-tools/${SLE_VERSION}/x86_64" ; fi
RUN if [ "$TARGETARCH" = 'arm64' ]; then SUSEConnect -p "sle-module-development-tools/${SLE_VERSION}/aarch64" ; fi

CMD ["/bin/bash"]
FROM base AS product

RUN zypper --gpg-auto-import-keys refresh \
    && zypper --non-interactive install --no-recommends --force-resolution --allow-vendor-change \
        binutils-gold \
    && zypper --non-interactive install --no-recommends --force-resolution --allow-vendor-change \
        autoconf \
        automake \
        binutils \
        binutils-devel \
        createrepo_c \
        curl \
        docker \
        gcc \
        gcc14 \
        gcc-c++ \
        gdbm-devel \
        git \
        glibc-locale-base \
        gnu_parallel \
        jq \
        libcurl-devel \
        libopenssl-devel \
        libpcap-devel \
        libtool \
        make \
        ncurses-devel \
        npm18 \
        openssh \
        openssl \
        pam-devel \
        readline-devel \
        rpm-build \
        rpmlint \
        rsync \
        ruby2.5 \
        skopeo \
        sqlite3-devel \
        sudo \
        unzip \
        util-linux \
        vim \
        wget \
        which \
        xz-devel \
        yq \
        zlib-devel \
        && zypper clean -a \
        && suseconnect --cleanup

ENV LANG=en_US.UTF-8

# Install git-vendor
RUN curl -sSL https://git.io/vzN5m | bash /dev/stdin

# Install bundler (can't use Zypper, latest bundler is <v2).
RUN gem install bundler:2.3.2 \
    && ln -snf bundle.ruby2.5 /usr/bin/bundle \
    && ln -snf bundler.ruby2.5 /usr/bin/bundler

WORKDIR /build
