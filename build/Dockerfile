# render markdown to html

FROM python:slim as render

COPY build/requirements.txt /tmp/requirements.txt

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y git \
 && pip install -U pip \
 && pip install -r /tmp/requirements.txt

COPY build /usr/src
COPY www /usr/local/www

RUN python /usr/src/render.py /usr/local/www /usr/src/templates \
 && rm `find /usr/local/www -name "*.md"`


# create an entrypoint.sh to trap the httpd process

FROM busybox as httpd

RUN addgroup -S www \
 && adduser -DHS -G www -s /bin/sh www \
 && touch /etc/httpd.conf \
 && echo "/bin/httpd -c /etc/httpd.conf -f -h /var/www -p 0.0.0.0:80" > /usr/sbin/entrypoint.sh \
 && chmod +x /usr/sbin/entrypoint.sh

COPY --from=render /usr/local/www /var/www

USER www

ENTRYPOINT ["/bin/sh", "-c", "/usr/sbin/entrypoint.sh"]
