ARG PYTHON

FROM python:${PYTHON}-stretch

RUN apt-get update && apt-get install -y pandoc

RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python && \
    /root/.poetry/bin/poetry config settings.virtualenvs.create false && ln -sf /root/.poetry/bin/poetry /usr/local/bin/poetry

ADD poetry.lock /tmp
ADD pyproject.toml /tmp
RUN cd /tmp && poetry install

ADD requirements.txt /tmp/requirements-docs.txt
RUN pip install -r /tmp/requirements-docs.txt

ADD . /ntc_dummies

WORKDIR "/ntc_dummies"

RUN poetry install
