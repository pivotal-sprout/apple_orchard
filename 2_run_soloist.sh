#!/bin/bash
set -e

ssh $IMAGE_USER@$IMAGE_HOST "
  cd /tmp &&
  git clone https://github.com/pivotalexperimental/apple_orchard.git &&
  git clone https://github.com/hiremaga/sprout-wrap.git"

if [[ $PIVOTAL_LABS ]]; then
  ssh $IMAGE_USER@$IMAGE_HOST 'eval `ssh-agent` &&
    ssh-add  ~/.ssh/id_github_lion &&
    ( ssh -o StrictHostKeyChecking=no git@github.com exit; : ) &&
    cd /tmp &&
    git clone git@github.com:pivotalprivate/pivotal_workstation_private.git &&
    echo "cookbook \"pivotal_workstation_private\", :path => \"/tmp/pivotal_workstation_private\"" >> /tmp/sprout-wrap/Cheffile'
fi

ssh $IMAGE_USER@$IMAGE_HOST 'sudo pmset sleep 0' # prevent machine from sleeping (otherwise will lose build)
ssh $IMAGE_USER@$IMAGE_HOST 'gem list | grep soloist || sudo gem install soloist'
ssh $IMAGE_USER@$IMAGE_HOST 'cd /tmp/sprout-wrap && soloist'

if [[ $PIVOTAL_LABS ]]; then
  ssh $IMAGE_USER@$IMAGE_HOST 'cd /tmp/sprout-wrap && soloist run_recipe meta::pivotal_specifics'
  ssh $IMAGE_USER@$IMAGE_HOST 'cd /tmp/sprout-wrap && soloist run_recipe pivotal_workstation_private::meta_lion_image'

  # Successful run, let's do the tagging, etc...
  ssh $IMAGE_USER@$IMAGE_HOST 'eval `ssh-agent` &&
    ssh-add  ~/.ssh/id_github_lion &&
    pushd /tmp/sprout-wrap/cookbooks/pivotal_workstation &&
    git remote set-url origin git@github.com:pivotal/pivotal_workstation.git
    git tag success/`date +%Y%m%d%H%M%S` &&
    git tag -f success/latest &&
    git push --force --tags &&
    git remote set-url origin https://github.com/pivotal/pivotal_workstation.git'
fi

# post-install, set the machine name to NEWLY_IMAGED
ssh $IMAGE_USER@$IMAGE_HOST 'sudo hostname NEWLY_IMAGED
  sudo scutil --set ComputerName   NEWLY_IMAGED
  sudo scutil --set LocalHostName  NEWLY_IMAGED
  sudo scutil --set HostName       NEWLY_IMAGED
  sudo diskutil rename /           NEWLY_IMAGED'

ssh $IMAGE_USER@$IMAGE_HOST 'sudo cp /tmp/apple_orchard/assets/com.pivotallabs.first_run.plist  /Library/LaunchAgents/'
ssh $IMAGE_USER@$IMAGE_HOST 'mkdir ~/bin; sudo cp /tmp/apple_orchard/assets/first_run.rb /usr/sbin/'
ssh $IMAGE_USER@$IMAGE_HOST 'mkdir ~/bin; sudo cp /tmp/apple_orchard/assets/auto_set_hostname.rb /usr/sbin/'

# turn off vmware tools (VMware Shared Folders) if installed
ssh $IMAGE_USER@$IMAGE_HOST 'for PLIST in \
  /Library/LaunchAgents/com.vmware.launchd.vmware-tools-userd.plist \
  /Library/LaunchDaemons/com.vmware.launchd.tools.plist
do
  [ -f $PLIST ] &&
  sudo defaults write $PLIST RunAtLoad -bool false &&
  sudo plutil -convert xml1 $PLIST &&
  sudo chmod 444 $PLIST
done
rm ~/Desktop/VMWare\ Shared\ Folders
true'

# reboot to Persistent
ssh $IMAGE_USER@$IMAGE_HOST 'sudo bless --mount /Volumes/Persistent --setboot'
ssh $IMAGE_USER@$IMAGE_HOST 'rm -fr ~/.ssh/id_github_lion ~/.ssh/authorized_keys && sudo shutdown -r now'
