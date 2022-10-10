 #!/bin/bash
  yum -y update
  yum -y install httpd
  echo "<h2>WebServer</h2><br>Built by Terraform!"  >  /var/www/html/index.html
  sudo service httpd start
  chkconfig httpd on
