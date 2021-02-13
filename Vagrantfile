# Cluster Prefix
PREFIX = "kube-"

# OS Image
BOX = "ubuntu/focal64"

# Size of nodes
CPU = 2
MEMORY = 2048

# Number of Kubernetes nodes
# This MUST be > 1
N = 3

# /24 networks
KUBE_NETWORK="10.10.9"
STORAGE_NETWORK="10.10.11"

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

            n.vm.provision "shell", path: ".provision/scripts/fix_fstab_uuid.sh"

            if node_id == N
                n.vm.provision "ansible" do |a|
                    a.limit = "all"
                    a.playbook = "playbooks/kube-bootstrap.yml"
                end
            end
        end
    end
end
