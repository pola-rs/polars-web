# compile the http server
# with musl instead of libc to reduce even further the size of the executable

FROM alpine:latest as build-http

WORKDIR /usr/src

COPY thttpd.patch /tmp/thttpd.patch

ARG THTTPD_VERSION=2.29
RUN apk --no-cache add curl gcc make musl-dev patch tar \
 && curl -sf -o thttpd-${THTTPD_VERSION}.tar.gz http://acme.com/software/thttpd/thttpd-${THTTPD_VERSION}.tar.gz \
 && tar -xf thttpd-${THTTPD_VERSION}.tar.gz \
 && cd thttpd-${THTTPD_VERSION} \
 && for p in /tmp/*.patch; do patch -p1 < $p; done \
 && ./configure \
 && make CCOPT='-O2 -g -static' thttpd \
 && install -m 755 thttpd /usr/local/bin


# render (equation, syntax highlighting, etc.) and minify the html content
# not used at the moment, but leaving this here for further reference

FROM python:slim as build-html

WORKDIR /usr/src

COPY www /usr/src

RUN mkdir /usr/local/www \
 && cp index.html style.css style-code.css /usr/local/www \
 && cp -r blog /usr/local/www

#COPY requirements.txt /tmp/requirements.txt
#COPY render.py render.py

#RUN mkdir /usr/local/www \
# && pip install -r /tmp/requirements.txt \
# && python render.py *html /usr/local/www


# run as root, but there is literally NOTHING in this container
# also, this is for local development

FROM scratch

WORKDIR /

COPY --from=build-http /usr/local/bin/thttpd /bin/thttpd
COPY --from=build-html /usr/local/www /www

ENTRYPOINT ["/bin/thttpd", "-D", "-l", "/dev/null", "-d", "/www"]
