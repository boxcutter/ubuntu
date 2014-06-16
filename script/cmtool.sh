#!/bin/bash -eux

# CM and CM_VERSION variables should be set inside of the Packer template:
#
# Values for CM can be:
#   'nocm'               -- build a box without a configuration management tool
#   'chef'               -- build a box with Chef
#   'chefdk'             -- build a box with Chef Development Kit
#   'salt'               -- build a box with Salt
#   'puppet'             -- build a box with Puppet
#
# Values for CM_VERSION can be (when CM is chef|chefdk|salt|puppet):
#   'x.y.z'              -- build a box with version x.y.z of Chef
#   'x.y'                -- build a box with version x.y of Salt
#   'x.y.z-apuppetlabsb' -- build a box with package version of Puppet
#   'latest'             -- build a box with the latest version
#
# Set CM_VERSION to 'latest' if unset because it can be problematic
# to set variables in pairs with Packer (and Packer does not support
# multi-value variables).
CM_VERSION=${CM_VERSION:-latest}

#
# Provisioner installs.
#

install_chef()
{
    echo "==> Installing Chef"
    if [[ ${CM_VERSION} == 'latest' ]]; then
        echo "Installing latest Chef version"
        curl -L https://www.getchef.com/chef/install.sh | bash
    else
        echo "Installing Chef version ${CM_VERSION}"
        curl -L https://www.getchef.com/chef/install.sh | bash -s -- -v $CM_VERSION
    fi

    if [[ ${CM_SET_PATH:-} == 'true' ]]; then
        echo "Automatically setting vagrant PATH to Chef Client"
        echo 'export PATH="/opt/chef/embedded/bin:$PATH"' >> /home/vagrant/.bash_profile
        # Handy to have these packages install for native extension compiles
        apt-get install -y libxslt-dev libxml2-dev
    fi
}

install_chef_dk()
{
    echo "==> Installing Chef Development Kit"
    if [[ ${CM_VERSION:-} == 'latest' ]]; then
        echo "==> Installing latest Chef Development Kit version"
        curl -L https://www.getchef.com/chef/install.sh | sh -s -- -P chefdk
    else
        echo "==> Installing Chef Development Kit ${CM_VERSION}"
        curl -L https://www.getchef.com/chef/install.sh | sh -s -- -P chefdk -v ${CM_VERSION}
    fi

    if [[ ${CM_SET_PATH:-} == 'true' ]]; then
        echo "Automatically setting vagrant PATH to Chef Development Kit"
        echo 'export PATH="/opt/chefdk/embedded/bin:/home/vagrant/.chefdk/gem/ruby/2.1.0/bin:$PATH"' >> /home/vagrant/.bash_profile
    fi
}

install_salt()
{
    echo "==> Installing Salt"
    if [[ ${CM_VERSION:-} == 'latest' ]]; then
        echo "Installing latest Salt version"
        wget -O - http://bootstrap.saltstack.org | sudo sh
    else
        echo "Installing Salt version $CM_VERSION"
        curl -L http://bootstrap.saltstack.org | sudo sh -s -- git $CM_VERSION
    fi
}

install_puppet()
{
    echo "==> Installing Puppet"
    . /etc/lsb-release

    DEB_NAME=puppetlabs-release-${DISTRIB_CODENAME}.deb
    wget http://apt.puppetlabs.com/${DEB_NAME}
    dpkg -i ${DEB_NAME}
    if [[ ${CM_VERSION:-} == 'latest' ]]; then
      echo "Installing latest Puppet version"
      apt-get install -y puppet
    else
      echo "Installing Puppet version $CM_VERSION"
      apt-get install -y puppet-common=$CM_VERSION puppet=$CM_VERSION
    fi
    rm -f ${DEB_NAME}
}

#
# Main script
#

case "${CM}" in
  'chef')
    install_chef
    ;;

  'chefdk')
    install_chef_dk
    ;;

  'salt')
    install_salt
    ;;

  'puppet')
    install_puppet
    ;;

  *)
    echo "==> Building box without baking in a configuration management tool"
    ;;
esac
