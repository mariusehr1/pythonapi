FROM ubuntu:19.04


RUN apt-get update -y && \
    apt-get install -y python-pip python-dev wget

RUN pip install Flask
RUN pip install pandas

WORKDIR /app/api.iktos.com/
COPY ./api.py /app/api.iktos.com/

RUN wget https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data
EXPOSE 5000
CMD python api.py

