#dennyhalim.com
# if dependencies is not installed, the user will need sudo yum privilege
# sudo yum install -y autoconf automake bison gcc-c++ libtool readline-devel sqlite-devel zlib-devel openssl-devel
# sudo yum install -y libffi-devel libyaml-devel ImageMagick-devel 
# http://rvm.io/rvm/install
# fix curl returned status '35': yum -y update nss*
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
source .rvm/scripts/rvm


rvm install 2.3
rvm --default use 2.3
gem install rails -v 4.2
gem install bundler

#now you can install ruby/rails -based applications
#tar zxvf redmine-3.3.5.tar.gz

