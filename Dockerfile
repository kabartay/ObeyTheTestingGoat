FROM ubuntu:16.04
#Layer for python and gdal support
RUN apt-get update && apt-get install -y software-properties-common curl \
    && add-apt-repository ppa:ubuntugis/ubuntugis-unstable && apt-get update \
    && apt-get install -y python3-pip libssl-dev libffi-dev python3-gdal \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
    && update-alternatives --install /usr/bin/pip    pip    /usr/bin/pip3    10 \
    && rm -rf /var/lib/apt/lists/*
#Begin of mandatory layers for Microsoft ODBC Driver 13 for Linux
RUN apt-get update && apt-get install -y apt-transport-https wget
RUN sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/mssql-ubuntu-xenial-release/ xenial main" > /etc/apt/sources.list.d/mssqlpreview.list'
RUN apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
RUN apt-get update -y
RUN apt-get install -y libodbc1-utf16 unixodbc-utf16 unixodbc-dev-utf16
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql
RUN apt-get install -y locales
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen
RUN PATH=$PATH:/usr/bin
#End of mandatory layers for Microsoft ODBC Driver 13 for Linux
RUN apt-get remove -y curl
#Layers for the django app
ARG db_pass=''
ENV db_pass=${db_pass}
RUN mkdir /code
WORKDIR /code
ADD . /code/
RUN pip3 install pip --upgrade
RUN pip3 install -r /code/requirements.txt
ENV DJANGO_SETTINGS_MODULE=superlists.settings
RUN pip install whitenoise
RUN python /code/manage.py collectstatic --noinput
EXPOSE 8000
RUN cp /code/deploy-tools/entrypoint.sh /code/
WORKDIR /code
RUN ls
ENTRYPOINT ["sh", "entrypoint.sh"]
