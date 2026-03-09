FROM https://quay.io/repository/almalinuxorg/10-minimal

USER 0

RUN dnf update -y

USER 1001

ENTRYPOINT ["/bin/sh"]