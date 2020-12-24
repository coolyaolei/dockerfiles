
FROM frolvlad/alpine-glibc:alpine-3.12
USER root

ENV CONDA_INSTALL_FILE Miniconda3-py38_4.9.2-Linux-x86_64.sh
ENV CONDA_INSTALL_DIR /opt
ENV PATH /bin:/sbin:$CONDA_INSTALL_DIR/miniconda/bin:/usr/bin
ENV NOTEBOOK_ROOT /notebook

# put your package at here
ENV PYTHONPATH $NOTEBOOK_ROOT/lib
# change login password at here 
ENV PASSWORD '123456'
ENV LANG='zh_CN.UTF8'
# copy some fonts in this dir 
# or comment this line
ADD winfont /usr/share/fonts/winfont
# can comment this line and uncomment the DOWNLOAD line (wget -q .....)
ADD ${CONDA_INSTALL_FILE} /root/
RUN cd && \
    # Change mirror site For China
    sed -i 's/dl-cdn.alpinelinux.org/opentuna.cn/g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache openssl tini bash libstdc++ font-adobe-100dpi git nodejs npm tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    npm config set registry https://registry.npm.taobao.org && \
    cd /usr/share/fonts && fc-cache -f && cd && \
    # download line
    # wget -q https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/$CONDA_INSTALL_FILE && \
    mkdir -p $CONDA_INSTALL_DIR && \
    bash ./$CONDA_INSTALL_FILE -b -p $CONDA_INSTALL_DIR/miniconda && \
    rm $CONDA_INSTALL_FILE && \
    mkdir -p /notebook && \
    pip config set global.index-url https://opentuna.cn/pypi/web/simple && \
    pip install pip -U && \
    # conda update -n base -c defaults conda && \
    pip install \
    # 大数据处理工具
    pandas datatable h5py tables pandas_datareader \
    dask \
    # excel文件读写,xlrd 2.0.1开始不支持xlsx
    xlrd xlwt openpyxl \
    # 自动化测试
    selenium \
    apscheduler \
    # 数据库
    psycopg2-binary \
    mysql-connector-python \
    pymongo \
    mongoengine \
    sqlalchemy \
    # flask及插件
    flask \
    # 数据可视化
    altair vega_datasets \
    bokeh \
    # 其他
    autopep8 \
    yapf \
    # jupyter notebook 相关
    jupyter  \
    # 以下是否有用？
    jupyterlab jupyter-dash jupyterlab-dash\
    cufflinks chart_studio \
    # dash相关
    dash plotly-express dash_bootstrap_components && \
    jupyter-notebook --generate-config --allow-root && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
    conda config --set show_channel_urls yes && \
    pip install jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --user --skip-running-check && \
    ########################################### jupyterlab插件
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    # toc插件
    jupyter labextension install @jupyterlab/toc && \
    # github插件
    # jupyter labextension install @jupyterlab/github && \
    # git插件
    pip install --upgrade jupyterlab-git && \
    jupyter labextension install @jupyterlab/git && \
    jupyter serverextension enable --py jupyterlab_git && \
    # latex插件
    jupyter labextension install @jupyterlab/latex && \
    # draw.io插件
    jupyter labextension install jupyterlab-drawio && \
    # plotly显示插件 
    jupyter labextension install jupyterlab-plotly && \
    # dash 显示插件
    jupyter labextension install jupyterlab-dash && \
    # bokeh 显示插件
    jupyter labextension install @bokeh/jupyter_bokeh && \
    # excel查看
    jupyter labextension install jupyterlab-spreadsheet && \
    # 函数定义跳转
    jupyter labextension install @krassowski/jupyterlab_go_to_definition && \
    # 变量探查
    jupyter labextension install @lckr/jupyterlab_variableinspector && \
    # 执行时间
    jupyter labextension install jupyterlab-execute-time && \
    # 自动补全
    wget -q -O ./kite-installer https://linux.kite.com/linux/current/kite-installer && \
    chmod 755 ./kite-installer && ./kite-installer install && \
    pip install jupyter-kite && \
    jupyter labextension install @kiteco/jupyterlab-kite && \
    # jupyter labextension install @krassowski/jupyterlab-lsp && \
    # pip install python-language-server[all] && \
    # 调试插件（需要xeus-python内核)
    pip install xeus-python && \
    jupyter labextension install @jupyterlab/debugger && \
    ##########################################################################
    # conda update --all && \
    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

VOLUME ["/notebook"]

EXPOSE 8888

ENTRYPOINT [ "/sbin/tini", "--" ]

CMD echo c.NotebookApp.password =\'`python -c "from notebook.auth import passwd; print(passwd('$PASSWORD'),end='')"`\' >> /root/.jupyter/jupyter_notebook_config.py && \
    jupyter-lab --allow-root --no-browser --notebook-dir=/notebook --ip=0.0.0.0
