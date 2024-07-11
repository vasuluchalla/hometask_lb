FROM apache/airflow:2.9.2
# Copy your requirements.txt file to the container
COPY requirements.txt ./
# Install the required Python packages
##RUN pip install -r requirements.txt

RUN pip install --no-cache-dir apache-airflow==${AIRFLOW_VERSION} -r /requirements.txt

# install dbt-snowflake in a virtual env
RUN export PIP_USER=false && python -m venv dbt_venv && source dbt_venv/bin/activate && \
    pip install --no-cache-dir dbt-snowflake && \
    deactivate