# dataease-mac

安装说明：
1. Mac 系统中安装 Docker  
   
         下载地址： https://docs.docker.com/desktop/mac/install/  
   
2. 下载并解压 DataEase 安装包   
   
   2.1 下载 DataEase 最新版安装包（当前为 v1.17.1）
       
         下载地址： https://community.fit2cloud.com/#/products/dataease/downloads  
       
          
          注意：下载时需根据 MacBook 的芯片选择安装包
          
          Inter 芯片：选择 “DataEase v1.17.1” 安装包；
          
          Apple 芯片：选择 “DataEase v1.17.1 ARM64” 安装包。
          
   2.2 解压安装包
           
           tar -zxvf dataease-v1.17.1-offline.tar.gz
   
3. 下载 dataease-mac.git 部署文件 
   
      
         手动复制 dataease-mac 中的 install.sh 到解压目录 dataease-v1.17.1-offline 中，替换原有的 install.sh
         

4. 手动复制 envsubst 脚本到 /usr/local/bin/
   
   并且执行 "sudo chmod u+x /usr/local/bin/envsubst" 赋予可执行权限  
       
          注意：这是 Perl 脚本，仅在以下情况下才可用
          
          a. 你不想安装附件包 gettext；
          
          b. gettext 安装有问题（通常使用 "brew install gettext" 命令，该命令应包含命令 envsubst）
          
          c. 它将替换 Linux 命令 envsubst
      

5. 编辑 install.conf  
      
         DE_BASE=/Users/User_Dir  #更换为自己的用户目录
         
         DE_ENGINE_MODE=simple 或 local #按需更改
  

6. 执行安装  

         进入到解压目录，执行 
         sudo chmod +x install.sh && sudo ./install.sh
      
   
7. 在浏览器访问 http://localhost  
