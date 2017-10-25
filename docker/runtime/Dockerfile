FROM alpine

ENV http_proxy=http://194.145.60.1:9400
ENV https_proxy=http://194.145.60.1:9400

RUN apk add --no-cache bash
RUN apk add --no-cache curl
RUN apk add --no-cache sed

COPY pipeline-create.sh ./pipeline-create.sh

CMD bash ./pipeline-create.sh

