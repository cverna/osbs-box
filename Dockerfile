FROM registry.fedoraproject.org/fedora:27
ADD ./fedora-infra-tags.repo /etc/yum.repos.d/fedora-infra-tags.repo
RUN  dnf -y install git python2-requests python2-dockerfile-parse python2-requests-kerberos python2-six python2-dateutil \ 
     && git clone https://github.com/projectatomic/osbs-client.git /tmp/osbs-client
RUN  cd /tmp/osbs-client && git checkout 0.42 && python setup.py install --prefix /usr/

RUN dnf -y install --refresh dnf-plugins-core && dnf -y install docker git python-setuptools e2fsprogs koji python-backports-lzma gssproxy fedpkg python-docker-squash atomic-reactor python-atomic-reactor* go-md2man
ADD osbs-box.tar /etc/pki/ca-trust/source/
RUN update-ca-trust
CMD ["python2", "/usr/bin/atomic-reactor", "--verbose", "inside-build"]
