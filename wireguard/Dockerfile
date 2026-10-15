FROM alpine:3.20
RUN apk add --no-cache wireguard-tools iproute2 iputils tcpdump tshark
COPY peer.sh /peer.sh
RUN chmod +x /peer.sh
ENTRYPOINT ["/peer.sh"]
