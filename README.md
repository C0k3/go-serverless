1. Copy the contents of this file into the UserData field of your Amazon Linux instance during the install to automatically install the Go Server and Agent
  1. When copying, replace the https://github.com/C0k3/session with the Git location of your serverless code
  1. If you have a private repo then put then either use an s3 object to store them as shown or just ehco the variables into the file such as:
  
          echo "export GIT_USER=MyUsername" > /etc/gitPasswd
          echo "export GIT_PASSWORD=MyPassword" >> /etc/gitPasswd
