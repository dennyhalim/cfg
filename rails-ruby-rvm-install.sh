#dennyhalim.com
# if dependencies is not installed, the user will need sudo yum privilege
# sudo yum install -y autoconf automake bison gcc-c++ libtool readline-devel zlib-devel openssl-devel sqlite-devel mysql-devel
# on rhel these might need additional discs:
# sudo yum install -y libffi-devel libyaml-devel ImageMagick-devel
# http://rvm.io/rvm/install
# fix curl returned status '35': yum -y update nss*

gpg --keyserver hkp://keys.gnupg.net:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
#gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
source .rvm/scripts/rvm


rvm install 2.6
rvm use 2.6 --default
gem install rails -v 5.2
gem install bundler #-v 1.17

#now you can install ruby/rails -based applications
#tar zxvf redmine-3.3.5.tar.gz

