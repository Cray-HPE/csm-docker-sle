# MIT License
# 
# (C) Copyright [2021-2022] Hewlett Packard Enterprise Development LP
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
FROM registry.suse.com/suse/sle15:15.2 AS base

ARG user=jenkins
ARG group=jenkins
ARG uid=10000
ARG gid=10000

ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group} && useradd -l -c "Jenkins USER" -d $HOME -u ${uid} -g ${gid} -m ${user}

# No repositories are defined in SP2, and there is no SP2 version of this repo:
RUN zypper addrepo https://updates.suse.com/SUSE/Products/SLE-BCI/15-SP3/x86_64/product/ SLE_BCI

RUN zypper --non-interactive install --no-recommends --force-resolution SUSEConnect \
    && zypper clean -a \
    && zypper rr SLE_BCI

RUN --mount=type=secret,id=SLES_REGISTRATION_CODE SUSEConnect -r "$(cat /run/secrets/SLES_REGISTRATION_CODE)"

RUN SUSEConnect -p sle-module-desktop-applications/15.2/x86_64 \
    && SUSEConnect -p sle-module-development-tools/15.2/x86_64 \
    && SUSEConnect -p sle-module-containers/15.2/x86_64

CMD ["/bin/bash"]
FROM base as product

RUN zypper refresh \
    && zypper --non-interactive install --no-recommends --force-resolution \
        autoconf \
        automake \
        createrepo_c \
        curl \
        docker \
        gcc \
        gcc-c++ \
        gdbm-devel \
        git \
        libopenssl-devel \
        libpcap-devel \
        libtool \
        make \
        ncurses-devel \
        openssh \
        openssl \
        pam-devel \
        readline-devel \
        rpm-build \
        rpmlint \
        skopeo \
        sqlite3-devel \
        unzip \
        util-linux \
        which \
        xz-devel \
        zlib-devel \
        && zypper clean -a \
        && SUSEConnect --cleanup

WORKDIR /build
