#!/bin/bash -eux

# CM and CM_VERSION variables should be set inside of Packer's template:
#
# Values for CM can be:
#   'nocm'            -- build a box without a configuration management tool
#   'chef'            -- build a box with Chef
#   'chefdk'          -- build a box with Chef Development Kit
#   'salt'            -- build a box with Salt
#   'puppet'          -- build a box with Puppet
#
# Values for CM_VERSION can be (when CM is chef|salt|puppet):
#   'x.y.z'           -- build a box with version x.y.z of Chef
#   'x.y'             -- build a box with version x.y of Salt
#   'latest'          -- build a box with the latest version
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
        apt-get update
        apt-get install -y libxslt-dev libxml2-dev
    fi
}

install_chef_dk()
{
    echo "==> Installing Chef Development Kit"
    platform=`grep DISTRIB_ID /etc/lsb-release | cut -d "=" -f 2 | tr '[A-Z]' '[a-z]'`
    platform_version=`grep DISTRIB_RELEASE /etc/lsb-release | cut -d "=" -f 2`
    echo "==> platform=$platform"
    echo "==> platform_version=$platform_version"
  
    CHEF_DK_DEB=chefdk_0.1.0-1_amd64.deb 
    CHEF_DK_DEB_PATH=/tmp/${CHEF_DK_DEB}
    if [[ $platform_version == 12.04 ]]; then
        CHEF_DK_URL=https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/${CHEF_DK_DEB}
    elif [[ $platform_version == 13.10 || $platform_version == 14.04 ]]; then
        CHEF_DK_URL=https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/13.10/x86_64/${CHEF_DK_DEB}
    else
        echo "==> Unsupported platform for Chef Development Kit"
    fi

    echo "==> Downloading ${CHEF_DK_URL}"
    wget ${CHEF_DK_URL} -qO ${CHEF_DK_DEB_PATH}
    echo "==> Installing ${CHEF_DK_DEB_PATH}"
    sudo dpkg -i ${CHEF_DK_DEB_PATH}
    rm ${CHEF_DK_DEB_PATH}

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
    apt-get update
    apt-get install -y puppet facter
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
