FROM python:3.11-bookworm

USER root

ADD https://github.com/gdraheim/docker-systemctl-replacement/raw/master/files/docker/systemctl3.py /usr/bin/systemctl

RUN chmod 755 /usr/bin/systemctl

RUN --mount=type=bind,target=/tmp/hexvault.run,source=hexvault.run \
  echo "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\ny\n\n\nroot\n\n\n\n\n" | /tmp/hexvault.run

RUN systemctl enable hexvault

WORKDIR /workdir
VOLUME /workdir

# note: hexvault does not accept custom paths at many places, even if there's a command option for override, so we do symlink magic :)

RUN ln -s /workdir/hexvault.hexlic /opt/hexvault/teamssrv-stub.hexlic
# see start.sh for why we don't change hexvault.conf now
#RUN rm -rf /opt/hexvault/hexvault.conf && ln -sf /workdir/hexvault.conf /opt/hexvault/hexvault.conf
RUN rm -rf /opt/hexvault/files && ln -sf /workdir/files /opt/hexvault/files


RUN python3 -c 'd=open("/opt/hexvault/vault_server", "rb").read(); d=d.replace(bytes.fromhex("ED FD 42 5C F9 78 54 6E 89 11 22 58 84 43 6C 57"), bytes.fromhex("ED FD 42 CB F9 78 54 6E 89 11 22 58 84 43 6C 57")); open("/opt/hexvault/vault_server", "wb").write(d)'
#ADD vault_server /opt/hexvault/vault_server

ADD start.sh /

#CMD /opt/hexvault/vault_server -v -e 100 -L /workdir/hexvault.hexlic -c /workdir/hexvault.crt -k /workdir/hexvault.key -d /workdir/files/store
CMD bash /start.sh

EXPOSE 65433