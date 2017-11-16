FROM python:3

LABEL \
    org.label-schema.name = "rdf.sh" \
    org.label-schema.description = "A multi-tool shell script for doing Semantic Web jobs on the command line." \
    org.label-schema.url="https://github.com/seebi/rdf.sh" \
    org.label-schema.vcs-url = "https://github.com/seebi/rdf.sh" \
    org.label-schema.vendor = "Sebastian Tramp" \
    org.label-schema.schema-version = "1.0"

# install dependencies
RUN apt-get update && \
    apt-get install -y curl uuid jq gawk && \
    apt-get install -y raptor2-utils rasqal-utils && \
    rm -rf /var/lib/apt/lists/* && \
    pip install Pygments && \
    cd /tmp && wget https://github.com/gniezen/n3pygments/archive/master.tar.gz && \
    tar xvzf master.tar.gz && \
    cd n3pygments-master && \
    python setup.py install && \
    cd .. && \
    rm -rf master.tar.gz n3pygments-master

# copy main script
COPY rdf /usr/local/bin

# prepopulate the namespace prefix cache from prefix.cc
RUN mkdir -p ~/.cache/rdf.sh/ && curl -s http://prefix.cc/popular/all.file.txt | sed -e "s/\t/|/" >~/.cache/rdf.sh/prefix.cache

ENTRYPOINT ["/usr/local/bin/rdf"]
