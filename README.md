# dataease-mac

安装说明：
1. Mac 系统中安装 Docker  
   
         下载地址： https://docs.docker.com/desktop/mac/install/  
   
2. 下载并解压 DataEase 安装包   
   
   2.1 下载 DataEase 最新版安装包（当前为 v1.18.2）
       
         下载地址： https://community.fit2cloud.com/#/products/dataease/downloads  
       
          
          注意：下载时需根据 MacBook 的芯片选择安装包
          
          Inter 芯片：选择 “DataEase v1.18.2” 安装包；
          
          Apple 芯片：选择 “DataEase v1.18.2 ARM64” 安装包。
          
   2.2 解压安装包
           
           tar -zxvf dataease-v1.18.2-offline.tar.gz
   
3. 下载 dataease-mac.git 部署文件 
   
      
         手动复制 dataease-mac 中的 install.sh 到解压目录 dataease-v1.18.2-offline 中，替换原有的 install.sh
        
      
4. 编辑 install.conf  
      
         DE_BASE=/Users/User_Dir  #更换为自己的用户目录
         
         DE_ENGINE_MODE=simple 或 local #按需更改
  

5. 执行安装  

         进入到解压目录，执行 
         sudo chmod +x install.sh && sudo ./install.sh
      
         注：
         安装过程中，会自动在 /usr/local/bin/ 创建环境变量文件 envsubst，
         #!/usr/bin/perl -p
         $_ =~ s/\Q${$1||$2}/$ENV{$1?$2:$4}/ while $_ =~ /(\$\{([^}]+)})|(\$(\w+))/g;

   
6. 在浏览器访问 http://localhost  
