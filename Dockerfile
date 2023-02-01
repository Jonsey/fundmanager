FROM alpine

RUN apk update
RUN apk add nodejs
RUN apk add yarn

MAINTAINER AMR Software <damian@amrsoftware.com>

RUN yarn global add elm
RUN yarn global add elm-test
RUN yarn global add highcharts

ENTRYPOINT ["elm"]
