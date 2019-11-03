# Cluster Prefix
PREFIX = "kube-"

# OS Image
BOX = "centos/7"

# Size of nodes
CPU = 2
MEMORY = 2048

# Number of Kubernetes nodes
# This MUST be > 1
N = 3

# /24 network
NETWORK="10.10.9"

# Using Vagrant version 2.
Vagrant.configure("2") do |config|
    config.vm.define "#{PREFIX}nfs" do |s|
        s.vm.box = BOX
        s.vm.boot_timeout = 600
        s.vm.hostname = "#{PREFIX}nfs"
        s.vm.network "private_network", ip: "#{NETWORK}.254"

        s.vm.provider "virtualbox" do |vb|
            vb.name = "#{PREFIX}nfs"
            vb.cpus = 1
            vb.memory = 512
        end

        s.vm.provision "ansible" do |a|
            a.playbook = "playbooks/nfs-bootstrap.yml"
        end
    end
    # Iterate for nodes
    (1..N).each do |node_id|
        nid = (node_id - 1)
        config.vm.define "#{PREFIX}#{nid}" do |n|
            n.vm.box = BOX
            n.vm.boot_timeout = 600
            n.vm.hostname = "#{PREFIX}#{nid}"
            n.vm.network "private_network", ip: "#{NETWORK}.#{2 + nid}"

            n.vm.provider "virtualbox" do |vb|
                vb.name = "#{PREFIX}#{nid}"
                vb.cpus = CPU
                vb.memory = MEMORY
            end

            if node_id == N
                n.vm.provision "ansible" do |a|
                    a.limit = "!#{PREFIX}nfs"
                    a.inventory_path = "inventory.yml"
                    a.playbook = "playbooks/kube-bootstrap.yml"
                end
            end
        end
    end

end

