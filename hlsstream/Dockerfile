# built with "docker buildx build --platform linux/arm64,linux/amd64 -t m5p3nc3r/hlsstream . --push"
#FROM ubuntu:latest

#RUN apt-get update && \
#    DEBIAN_FRONTEND=noninteractive apt-get install -y gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-tools

FROM alpine:edge

RUN apk update && apk add gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gstreamer-tools


COPY ./stream.sh /bin/stream.sh

ENTRYPOINT ["/bin/stream.sh"]
CMD [""]