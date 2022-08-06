# syntax=docker/dockerfile:1.3-labs

#FROM redis:6.0-alpine
FROM ruby:alpine
WORKDIR /data

RUN apk add iproute2 redis make gcc libc-dev

COPY . ./
RUN bundle update --bundler && bundle install && rm -rf *

ARG entrypoint=/usr/local/bin/entrypoint
RUN echo "entrypoint: $entrypoint"

ENTRYPOINT $entrypoint
CMD /bin/sh

# docker run -it --rm -v `pwd`:/data --net=host --name rls

COPY <<EOF hi
hi there world
EOF

# prepopulate console history
COPY <<EOF /root/.ash_history
tc qdisc replace dev eth0 root netem delay 1ms
tc qdisc change dev eth0 root netem rate 1gbit
tc qdisc change dev eth0 root netem loss 1
tc qdisc del dev eth0 root netem
latency
bm
ls -l /usr/local/bin/
EOF


COPY <<EOF $entrypoint
#!/bin/sh

echo "bundle exec ruby spec/benchmark.rb" > /usr/local/bin/bm
echo "timeout 1s redis-cli -h $REDIS --latency" > /usr/local/bin/latency

chmod +x /usr/local/bin/*


# https://man7.org/linux/man-pages/man8/tc-netem.8.html
tc qdisc replace dev eth0 root netem delay 1ms
tc qdisc change dev eth0 root netem rate 1gbit

latency | tee -a out
bm | tee -a out


exec "\$@"
EOF

RUN chmod +x $entrypoint
