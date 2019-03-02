FROM jupyter/pyspark-notebook

LABEL maintainer="Ogi Stancevic <ognjen.stancevic@westpac.com.au>"

RUN conda config --add channels conda-forge &&\ 
    conda update --yes --all

RUN jupyter labextension install --no-build @jupyterlab/toc && \ 
 jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager && \
 jupyter labextension install --no-build @jupyterlab/hub-extension && \
 jupyter lab build

USER root

# RSpark config
ENV R_LIBS_USER $SPARK_HOME/R/lib
RUN fix-permissions $R_LIBS_USER


# Teradata pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gdebi-core \
    openssh-client \
    sshfs \
    dpkg \
    libcairo2-dev \
    unixodbc-dev  \
    lib32stdc++6 && \
    apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/*


# R and essential R packages
RUN conda install --yes \  
	mro-base 
RUN conda install --yes \
	r-irkernel \
	r-tidyverse 


#setup R configs
RUN echo ".libPaths('/opt/conda/lib/R/library')" >> ~/.Rprofile

# Install additional R packages here
#COPY install_packages.R /tmp/install_packages.R 
#RUN R --no-save </tmp/install_packages.R 


RUN conda install -c conda-forge \
	jupyter_contrib_nbextensions \
	rpy2 \
	altair \
	vega \
	jira \
	tzlocal \
	saspy \
	sas_kernel \ 
	colorama \
	feather-format \
	pyarrow \
	pandas-profiling \
	python-docx && \
	conda clean -tipsy && \
        rm -rf /home/$NB_USER/.local && \
	fix-permissions $CONDA_DIR && \
	fix-permissions /home/$NB_USER

RUN pip install jupyterlab_templates\
	sql_magic && \
  jupyter labextension install jupyterlab_templates && \
  jupyter serverextension enable --py jupyterlab_templates


EXPOSE 8787

USER $NB_UID
WORKDIR /home/$NB_USER

#setup R configs
RUN echo ".libPaths('/opt/conda/lib/R/library')" >> ~/.Rprofile

# Enable Jupyter extensions here
RUN jupyter nbextension enable collapsible_headings/main && \
 jupyter nbextension enable snippets_menu/main && \
 jupyter nbextension enable toc2/main && \
 jupyter nbextension enable varInspector/main && \
 jupyter nbextension enable highlighter/highlighter && \
 jupyter nbextension enable hide_input/main && \
 jupyter nbextension enable python-markdown/main && \
 jupyter nbextension enable spellchecker/main && \
 jupyter nbextension enable hide_input_all/main && \
 jupyter nbextension enable execute_time/ExecuteTime && \
 jupyter nbextension enable export_embedded/main && \
 jupyter nbextension enable tree-filter/index

