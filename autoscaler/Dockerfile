FROM python:3.8

WORKDIR /srv

COPY requirements.txt /srv/requirements.txt
RUN pip install -r requirements.txt
COPY autoscaler.py /srv/autoscaler.py
RUN chmod +x /srv/autoscaler.py

CMD ["python", "/srv/autoscaler.py"]
