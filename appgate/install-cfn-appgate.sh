mkdir cfn
curl -s -o /usr/local/bin/cfn.tar.gz https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz
sudo apt update
sudo apt install -y python3-pip
pip install /usr/local/bin/cfn.tar.gz
rm /usr/local/bin/cfn.tar.gz