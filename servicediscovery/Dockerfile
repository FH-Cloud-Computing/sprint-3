FROM python

WORKDIR /srv

RUN mkdir -p /srv/service-discovery
VOLUME ["/srv/service-discovery"]

COPY requirements.txt /srv/requirements.txt
RUN pip install -r requirements.txt
COPY sd.py /srv/sd.py

CMD ["/srv/sd.py"]
