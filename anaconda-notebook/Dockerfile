
FROM frolvlad/alpine-glibc:alpine-3.7
USER root

ENV ANACONDA_VERSION 5.1.0
ENV ANACONDA_INSTALL_SH Anaconda3-$ANACONDA_VERSION-Linux-x86_64.sh 
ENV ANACONDA_INSTALL_DIR /opt
ENV PATH /bin:/sbin:$ANACONDA_INSTALL_DIR/anaconda/bin:/usr/bin
ENV NOTEBOOK_ROOT /notebook

# put your package at here
# 自己的包放这里
ENV PYTHONPATH $NOTEBOOK_ROOT/lib
# change login password at here 
# 登陆密码
ENV PASSWORD 'coolyaolei'

# Change mirror site For China
# 切换到清华的镜像
RUN echo 'https://mirror.tuna.tsinghua.edu.cn/alpine/v3.7/main' > /etc/apk/repositories && \
    echo 'https://mirror.tuna.tsinghua.edu.cn/alpine/v3.7/community' >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache openssl tini bash libstdc++ && \
    wget -q https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/$ANACONDA_INSTALL_SH && \
    # wget -q https://repo.continuum.io/archive/$ANACONDA_INSTALL_SH
    mkdir -p $ANACONDA_INSTALL_DIR && \
    bash ./$ANACONDA_INSTALL_SH -b -p $ANACONDA_INSTALL_DIR/anaconda && \
    rm $ANACONDA_INSTALL_SH && \
    mkdir -p /notebook && \
    jupyter-notebook --generate-config --allow-root

# add some packages 
# 自己要用的包
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple selenium psycopg2-binary

VOLUME ['/notebook']

EXPOSE 8888

ENTRYPOINT [ "/sbin/tini", "--" ]

CMD echo c.NotebookApp.password =\'`python -c "from notebook.auth import passwd; print(passwd('$PASSWORD'),end='')"`\' >> /root/.jupyter/jupyter_notebook_config.py && \
jupyter-notebook --allow-root --no-browser --notebook-dir=/notebook --ip=0.0.0.0
