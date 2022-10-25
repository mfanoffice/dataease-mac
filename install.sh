#!/bin/bash

CURRENT_DIR=$(
   cd "$(dirname "$0")"
   pwd
)

function log() {
   message="[DATAEASE Log]: $1 "
   echo -e "${message}" 2>&1 | tee -a ${CURRENT_DIR}/install.log
}

args=$@
os=`uname -a`

if which docker >/dev/null; then
   log "Docker is installed. Moving on..."
else
   log "Docker is Not yet installed, please install Docker first"
   exit 1
fi

docker_config_folder="/etc/docker"
compose_files="-f docker-compose.yml"

if [ -f /usr/local/bin/dectl ]; then
   # 获取已安装的 DataEase 的运行目录
   DE_BASE=`grep "^DE_BASE=" /usr/bin/dectl | cut -d'=' -f2`
   dectl uninstall
fi

set -a
if [[ $DE_BASE ]] && [[ -f $DE_BASE/dataease/.env ]]; then
   source $DE_BASE/dataease/.env
else
   source ${CURRENT_DIR}/install.conf
fi
set +a

DE_RUN_BASE=$DE_BASE/dataease
conf_folder=${DE_RUN_BASE}/conf
templates_folder=${DE_RUN_BASE}/templates
mysql_container_name="mysql"
if [ -f ${DE_RUN_BASE}/docker-compose-mysql.yml ]; then
   mysql_container_name=`grep "container_name" ${DE_RUN_BASE}/docker-compose-mysql.yml | awk -F': ' '{print $2}'`
fi

dataease_conf=${conf_folder}/dataease.properties

function prop {
   [ -f "$1" ] | grep -P "^\s*[^#]?${2}=.*$" $1 | cut -d'=' -f2
}

if [ "x${DE_ENGINE_MODE}" = "x" ]; then
   export DE_ENGINE_MODE="local"
fi

if [ "x${DE_DOCKER_SUBNET}" = "x" ]; then
   export DE_DOCKER_SUBNET=`grep "^[[:blank:]]*- subnet" ${DE_RUN_BASE}/docker-compose.yml | awk -F': ' '{print $2}'`
fi

if [ "x${DE_DOCKER_GATEWAY}" = "x" ]; then
   export DE_DOCKER_GATEWAY=`grep "^[[:blank:]]*gateway" ${DE_RUN_BASE}/docker-compose.yml | awk -F': ' '{print $2}'`
fi

if [ "x${DE_DORIS_FE_IP}" = "x" ]; then
   DE_DORIS_FE_IP=`grep "^[[:blank:]]*ipv4_address" ${DE_RUN_BASE}/docker-compose-doris.yml | awk -F': ' '{print $2}' | head -n 1`
   export DE_DORIS_FE_IP
fi

if [ "x${DE_DORIS_BE_IP}" = "x" ]; then
   DE_DORIS_BE_IP=`grep "^[[:blank:]]*ipv4_address" ${DE_RUN_BASE}/docker-compose-doris.yml | awk -F': ' '{print $2}' | tail -n 1`
   export DE_DORIS_BE_IP
fi

echo -e "*******************************************************\n" 2>&1 | tee -a ${CURRENT_DIR}/install.log
echo -e " 当前部署模式为 ${DE_ENGINE_MODE}，如需切换模式，\n 请修改 $DE_BASE/dataease/.env 中的 DE_ENGINE_MODE 变量后，\n 重新执行 bash install.sh 即可\n" 2>&1 | tee -a ${CURRENT_DIR}/install.log
echo -e "*******************************************************\n" 2>&1 | tee -a ${CURRENT_DIR}/install.log


if [[ -f $dataease_conf ]] && [[ ! ${DE_EXTERNAL_DORIS} ]]; then
   export DE_DORIS_DB=$(prop $dataease_conf doris.db)
   export DE_DORIS_USER=$(prop $dataease_conf doris.user)
   export DE_DORIS_PASSWORD=$(prop $dataease_conf doris.password)
   export DE_DORIS_HOST=$(prop $dataease_conf doris.host)
   export DE_DORIS_PORT=$(prop $dataease_conf doris.port)
   export DE_DORIS_HTTPPORT=$(prop $dataease_conf doris.httpPort)

   if [ ${DE_DORIS_HOST} = "doris-fe" ]; then
      export DE_EXTERNAL_DORIS="false"
   else
      export DE_EXTERNAL_DORIS="true"
   fi
fi

if [ ${DE_EXTERNAL_DORIS} = "false" ] && [ ${DE_ENGINE_MODE} = "local" ]; then
   compose_files="${compose_files} -f docker-compose-doris.yml"
fi

if [[ -f $dataease_conf ]] && [[ ! ${DE_EXTERNAL_KETTLE} ]]; then
   export DE_CARTE_HOST=$(prop $dataease_conf carte.host)
   export DE_CARTE_PORT=$(prop $dataease_conf carte.port)
   export DE_CARTE_USER=$(prop $dataease_conf carte.user)
   export DE_CARTE_PASSWORD=$(prop $dataease_conf carte.passwd)

   if [ ${DE_CARTE_HOST} = "kettle" ]; then
      export DE_EXTERNAL_KETTLE="false"
   else
      export DE_EXTERNAL_KETTLE="true"
   fi
fi

if [ ${DE_EXTERNAL_KETTLE} = "false" ] && [ ${DE_ENGINE_MODE} = "local" ]; then
   compose_files="${compose_files} -f docker-compose-kettle.yml"
fi


echo -e "======================= 开始安装 =======================" 2>&1 | tee -a ${CURRENT_DIR}/install.log

mkdir -p ${DE_RUN_BASE}
cp -r ./dataease/* ${DE_RUN_BASE}/

cd $DE_RUN_BASE
env | grep DE_ >.env

mkdir -p $conf_folder
mkdir -p ${DE_RUN_BASE}/data/kettle
chmod -R 777 ${DE_RUN_BASE}/data
mkdir -p ${DE_RUN_BASE}/data/fe
mkdir -p ${DE_RUN_BASE}/data/be
mkdir -p ${DE_RUN_BASE}/data/mysql
chmod -R 777 ${DE_RUN_BASE}/data/mysql
mkdir -p ${DE_RUN_BASE}/data/static-resource
mkdir -p ${DE_RUN_BASE}/custom-drivers
mkdir -p ${DE_RUN_BASE}/data/business
chmod -R 777 ${DE_RUN_BASE}/logs
DE_MYSQL_HOST_ORIGIN=$DE_MYSQL_HOST
DE_MYSQL_PORT_ORIGIN=$DE_MYSQL_PORT

if [ ${DE_EXTERNAL_MYSQL} = "false" ]; then
   compose_files="${compose_files} -f docker-compose-mysql.yml"
   export DE_MYSQL_HOST=$mysql_container_name
   export DE_MYSQL_PORT=3306
   sed -i "s/^    container_name: mysql/    container_name: ${DE_MYSQL_HOST}/g" docker-compose-mysql.yml
else
   sed -i -e "/^    depends_on/,+2d" docker-compose.yml
fi


log "拷贝配置文件模板文件  -> $conf_folder"
cd $DE_RUN_BASE
cp -r $templates_folder/* $conf_folder
cp -r $templates_folder/.kettle $conf_folder

log "根据安装配置参数调整配置文件"
cd ${templates_folder}
templates_files=( dataease.properties mysql.env )
for i in ${templates_files[@]}; do
   if [ -f $i ]; then
      envsubst < $i > $conf_folder/$i
   fi
done

export DE_MYSQL_HOST=$DE_MYSQL_HOST_ORIGIN
export DE_MYSQL_PORT=$DE_MYSQL_PORT_ORIGIN

cd ${CURRENT_DIR}
sed -i -e "s#DE_BASE=.*#DE_BASE=${DE_BASE}#g" dectl
\cp dectl /usr/local/bin && chmod +x /usr/local/bin/dectl
if [ ! -f /usr/bin/dectl ]; then
  ln -s /usr/local/bin/dectl /usr/bin/dectl 2>/dev/null
fi

echo "time: $(date)"

export COMPOSE_HTTP_TIMEOUT=180
cd ${CURRENT_DIR}
# 加载镜像
if [[ -d images ]]; then
   log "加载镜像"
   for i in $(ls images); do
      if [ ${DE_ENGINE_MODE} != "local" ]; then
         if [[ $i =~ "doris" ]] || [[ $i =~ "kettle" ]]; then
            continue
         fi
      fi
      docker load -i images/$i 2>&1 | tee -a ${CURRENT_DIR}/install.log
   done
else
   log "拉取镜像"
   cd ${DE_RUN_BASE} && docker-compose $compose_files pull 2>&1
   cd -
fi

http_code=`curl -sILw "%{http_code}\n" http://localhost:${DE_PORT} -o /dev/null`
if [[ $http_code == 200 ]];then
   log "停止服务进行升级..."
   dectl uninstall
fi

log "启动服务"
dectl reload | tee -a ${CURRENT_DIR}/install.log
dectl status 2>&1 | tee -a ${CURRENT_DIR}/install.log

for b in {1..30}
do
   sleep 3
   http_code=`curl -sILw "%{http_code}\n" http://localhost:${DE_PORT} -o /dev/null`
   if [[ $http_code == 000 ]];then
      log "服务启动中，请稍候 ..."
   elif [[ $http_code == 200 ]];then
      log "服务启动成功!"
      break;
   else
      log "服务启动出错!"
      exit 1
   fi
done

if [[ $http_code != 200 ]];then
   log "【警告】服务在等待时间内未完全启动！请稍后使用 dectl status 检查服务运行状况。"
fi

echo -e "======================= 安装完成 =======================\n" 2>&1 | tee -a ${CURRENT_DIR}/install.log
echo -e "请通过以下方式访问:\n URL: http://\$LOCAL_IP:$DE_PORT\n 用户名: admin\n 初始密码: dataease" 2>&1 | tee -a ${CURRENT_DIR}/install.log
