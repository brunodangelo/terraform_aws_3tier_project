#!/bin/bash                                                  
yum update -y
export HOME=/home/ec2-user
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
# Download and install Node.js:
nvm install 22
npm -v
yum install git -y
#git config --global credential.helper '!aws codecommit credential-helper $@'
#git config --global credential.UseHttpPath true
git clone https://github.com/brunodangelo/simple-dynamodb-aws-node

cd simple-dynamodb-aws-node
cd back

#Credenciales de AWS, reemplazar los valores por los de tu cuenta
cat <<EOF > .env
ACCESS_KEY_ID=''
SECRET_ACCESS_KEY=''
EOF

npm install
node app.js