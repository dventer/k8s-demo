FROM python:3.8.12-alpine3.14
RUN apk add --update gcc libc-dev fortify-headers linux-headers
RUN pip install --upgrade pip
RUN adduser -D sample-app
USER sample-app
WORKDIR /home/sample-app

COPY --chown=sample-app:sample-app requirements.txt requirements.txt
RUN pip uninstall flask && pip install --user -r requirements.txt

ENV PATH="/home/sample-app/.local/bin:${PATH}"

COPY --chown=sample-app:sample-app app/main.py .

CMD python main.py
