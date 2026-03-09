FROM quay.io/almalinuxorg/10-minimal:10

USER 0

RUN dnf update -y

USER 1001

ENTRYPOINT ["/bin/sh"]