Vagrant.configure(2) do |config|
  config.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 4096
    v.gui = false
  end
  config.vm.synced_folder '~/ntech/', '/ntech/'

  config.vm.define "kali" do |kali|
    kali.vm.box = 'kalilinux/rolling'
    kali.vm.hostname = "host"
    kali.vm.network "private_network", ip: "192.168.56.12"
  end

end

