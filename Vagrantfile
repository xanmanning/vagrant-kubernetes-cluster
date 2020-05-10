# Cluster Prefix
PREFIX = "kube-"

# OS Image
# BOX = "centos/7"
# BOX = "ubuntu/bionic64"
BOX = "bento/opensuse-leap-15.1"

# Size of nodes
CPU = 2
MEMORY = 2048

# Number of Kubernetes nodes
# This MUST be > 1
N = 3

# /24 networks
KUBE_NETWORK="10.10.9"
STORAGE_NETWORK="10.10.11"

# Provisioning Scripts
$provisioningScript = <<-SCRIPT
if [[ ! -f /VAGRANT_PROVISION ]] ; then
  echo "Provisioning VM, this may take a while!" | tee -a /VAGRANT_PROVISION
  echo "" | tee -a /VAGRANT_PROVISION

  echo "Installing extra virtualbox guest packages ... " | tee -a /VAGRANT_PROVISION
  sudo zypper install -y virtualbox-guest-tools >> /VAGRANT_PROVISION && echo "Done"

  echo "Installing ansible dependencies ... " | tee -a /VAGRANT_PROVISION
  sudo zypper install -y python-urllib3 python-xml >> /VAGRANT_PROVISION && echo "Done"

  echo "Done"
else
  echo "Already Provisioned"
fi
SCRIPT

## Shared Drive Script

$shareScript = <<-SCRIPT
IS_VAGRANT_MOUNTED="$(mount | grep vagrant || true)"
sudo test -d /vagrant || mkdir /vagrant
grep "vboxsf" /etc/fstab || echo "vagrant /vagrant vboxsf defaults 0 0" | sudo tee -a /etc/fstab
if [[ "${IS_VAGRANT_MOUNTED}" == "" ]] ;  then
  sudo mount -t vboxsf -o uid=$(id -u vagrant),gid=$(id -g vagrant) vagrant /vagrant
fi
SCRIPT

# Using Vagrant version 2.
Vagrant.configure("2") do |config|
    VAGRANT_ROOT = File.join(File.dirname(File.expand_path(__FILE__)), '.vagrant/')
    PROJECT_ROOT = File.dirname(File.expand_path(__FILE__))
    # Iterate for nodes
    (1..N).each do |node_id|
        nid = (node_id - 1)
        file_to_disk_0 = File.join(VAGRANT_ROOT, "#{PREFIX}#{nid}", 'disk0.vdi')
        file_to_disk_1 = File.join(VAGRANT_ROOT, "#{PREFIX}#{nid}", 'disk1.vdi')
        file_to_disk_2 = File.join(VAGRANT_ROOT, "#{PREFIX}#{nid}", 'disk2.vdi')
        file_to_disk_3 = File.join(VAGRANT_ROOT, "#{PREFIX}#{nid}", 'disk3.vdi')
        file_to_disk_4 = File.join(VAGRANT_ROOT, "#{PREFIX}#{nid}", 'disk4.vdi')
        file_to_disk_5 = File.join(VAGRANT_ROOT, "#{PREFIX}#{nid}", 'disk5.vdi')
        config.vm.define "#{PREFIX}#{nid}" do |n|
            n.vm.box = BOX
            n.vm.boot_timeout = 600
            n.vm.hostname = "#{PREFIX}#{nid}"
            n.vm.network "private_network", ip: "#{KUBE_NETWORK}.#{2 + nid}"
            n.vm.network "private_network", ip: "#{STORAGE_NETWORK}.#{2 + nid}"
            n.vm.synced_folder ".", "/vagrant", disabled: true

            n.vm.provider "virtualbox" do |vb|
                vb.name = "#{PREFIX}#{nid}"
                vb.cpus = CPU
                vb.memory = MEMORY
                vb.customize ['sharedfolder', 'add', :id, '--name', 'vagrant', '--hostpath', PROJECT_ROOT]
                unless File.exist?(file_to_disk_0)
                    vb.customize ['createhd', '--filename', file_to_disk_0, '--size', 8 * 1024]
                    vb.customize ['storagectl', :id, '--name', "#{PREFIX}#{nid}", '--add', 'sas', '--controller', 'LSILogicSAS']
                end
                unless File.exist?(file_to_disk_1)
                    vb.customize ['createhd', '--filename', file_to_disk_1, '--size', 8 * 1024]
                end
                unless File.exist?(file_to_disk_2)
                    vb.customize ['createhd', '--filename', file_to_disk_2, '--size', 8 * 1024]
                end
                unless File.exist?(file_to_disk_3)
                    vb.customize ['createhd', '--filename', file_to_disk_3, '--size', 8 * 1024]
                end
                unless File.exist?(file_to_disk_4)
                    vb.customize ['createhd', '--filename', file_to_disk_4, '--size', 8 * 1024]
                end
                unless File.exist?(file_to_disk_5)
                    vb.customize ['createhd', '--filename', file_to_disk_5, '--size', 8 * 1024]
                end
                vb.customize ['storageattach', :id, '--storagectl', "#{PREFIX}#{nid}", '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk_0]
                vb.customize ['storageattach', :id, '--storagectl', "#{PREFIX}#{nid}", '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk_1]
                vb.customize ['storageattach', :id, '--storagectl', "#{PREFIX}#{nid}", '--port', 3, '--device', 0, '--type', 'hdd', '--medium', file_to_disk_2]
                vb.customize ['storageattach', :id, '--storagectl', "#{PREFIX}#{nid}", '--port', 4, '--device', 0, '--type', 'hdd', '--medium', file_to_disk_3]
                vb.customize ['storageattach', :id, '--storagectl', "#{PREFIX}#{nid}", '--port', 5, '--device', 0, '--type', 'hdd', '--medium', file_to_disk_4]
                vb.customize ['storageattach', :id, '--storagectl', "#{PREFIX}#{nid}", '--port', 6, '--device', 0, '--type', 'hdd', '--medium', file_to_disk_5]
            end

            n.vm.provision "shell", inline: $provisioningScript
            n.vm.provision "shell", inline: $shareScript, run: "always"
            n.vm.provision "shell", path: ".provision/scripts/fix_fstab_uuid.sh"

            if node_id == N
                n.vm.provision "ansible" do |a|
                    a.limit = "all"
                    a.extra_vars = {
                        k3s_control_workers: true,
                        k3s_become_for_all: true,
                        kube_prefix: "kube-",
                        k3s_use_docker: false,
                        k3s_no_servicelb: true,
                        k3s_flannel_interface: "eth1",
                        k3s_release_version: "v1.17.5+k3s1",
                        # k3s_control_node: true,
                        # k3s_dqlite_datastore: true,
                        # k3s_use_experimental: true,
                        k3s_kubelet_args: [
                            { 'volume-plugin-dir': '/etc/kubernetes/kubelet-plugins/volume/exec' }
                        ]
                    }
                    a.playbook = "playbooks/kube-bootstrap.yml"
                end
            end
        end
    end
end
