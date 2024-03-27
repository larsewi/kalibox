Vagrant.configure(2) do |config|
  config.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 4096
    v.gui = false
  end
  config.vm.synced_folder '~/ntech/', '/ntech/'

  config.vm.provision "shell" do |s|
      ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
      s.inline = <<-SHELL
        echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
        echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
      SHELL
    end

  config.vm.define "hub" do |hub|
    hub.vm.box = 'ubuntu/jammy64'
    hub.vm.hostname = "hub"
    hub.vm.network "private_network", ip: "192.168.56.10"
    hub.vm.network :forwarded_port, guest: 443, host: 9002
  end

  # config.vm.define "feeder" do |hub|
  #   hub.vm.box = 'ubuntu/jammy64'
  #   hub.vm.hostname = "hub"
  #   hub.vm.network "private_network", ip: "192.168.56.11"
  #   hub.vm.network :forwarded_port, guest: 443, host: 9003
  # end

  config.vm.define "kali" do |kali|
    kali.vm.box = 'kalilinux/rolling'
    kali.vm.hostname = "kali"
    kali.vm.network "private_network", ip: "192.168.56.12"
  end

end

