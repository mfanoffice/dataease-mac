# dataease-mac
Installation instruction:

1. Install Docker first
   https://docs.docker.com/desktop/mac/install/
  
2. Unpack dataease-v1.6.2-offline.tar.gz

3. Replace install.sh under dataease-v1.6.2-offline
   Manually copy install.sh to folder dataease-v1.6.2-offline

4. Manually copy script envsubst to /usr/local/hobin
   and execute command  "chmod u+x envsubst" to give the exection permission
   * Notice: This is Perl script and is the option only when:
      a. You don't want to install addition package gettext
      b. There's trouble in gettext installtion (usually using the command 'brew install gettext', which is supposed to contain the command envsubst)
      c. It is to substitute the Linux command envsubst. 

5. edit install.conf
   DE_BASE=/Users/<homedir>
   DE_EXTERNAL_DORIS=true
   DE_EXTERNAL_KETTLE=true

6. run install.sh

7  Visit http://localhost from browser

-----------------------------------------------------------

安装说明：
1. 首先安装Docker
   下载地址： https://docs.docker.com/desktop/mac/install/

2. 解压dataease-v1.6.2-offline.tar.gz安装包
   下载地址： https://community.fit2cloud.com/#/products/dataease/downloads

3. 替换dataease-v1.6.2-offline目录中的install.sh
   手动复制 install.sh 到 dataease-v1.6.2-offline 目录

4. 手动复制envsubst脚本到/usr/local/hobin
   并且执行"chmod u+x envsubst"命令给与可执行权限

   * 注意：这是Perl脚本，仅在以下情况下才可用： 
   a. 你不想安装附件包gettext
   b. gettext安装有问题（通常使用“brew install gettext”命令，该命令应包含命令envsubst）
   c. 它将替换Linux命令envsubst

5. 编辑install.conf
   DE_BASE=/Users/<homedir>
   DE_EXTERNAL_DORIS=true
   DE_EXTERNAL_KETTLE=true

6. 执行 install.sh

7. 在浏览器访问 http://localhost
