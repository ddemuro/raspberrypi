#!/bin/bash
###########################################
#Control Relay module USB with Crelay     #
###########################################
readonly graphic='libx11-.*'
readonly toinstall='zsh'
readonly install_path='/opt/scripts/'
readonly webmin_path='http://prdownloads.sourceforge.net/webadmin/webmin_1.791_all.deb'

read -r -p "Do you want us to remove graphic libraries from this Raspberry? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        apt-get -y remove --auto-remove --purge $graphic
        ;;
    *)
        echo "Leaving graphic stack as is..."
        ;;
esac

read -r -p "Would you like zshell and other goodies installed to this Raspberry? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        apt-get -y install $toinstall
		cd ~
		sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
        ;;
    *)
        echo "Not installing."
        ;;
esac

read -r -p "Would you like Webmin installed to this Raspberry? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        apt-get -y install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python
		wget -O webmin.deb $webmin_path
		dpkg --install webmin.deb
		rm webmin.deb
        ;;
    *)
        echo "Not installing."
        ;;
esac