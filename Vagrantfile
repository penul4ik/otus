MACHINES = {
  :"kernel-update" => {
              :box => "generic/centos7",
              :box_version => "4.2.16",
              :cpus => 2,
              :memory => 1024,
            }
}

Vagrant.configure("2") do |config|
    MACHINES.each do |boxname, boxconfig|
        config.vm.synced_folder ".", "/vagrant", disabled: true
        config.vm.define boxname do |box|
            box.vm.box = boxconfig[:box]
            box.vm.box_version = boxconfig[:box_version]
            box.vm.provider "virtualbox" do |v|
                v.memory = boxconfig[:memory]
                v.cpus = boxconfig[:cpus]
            end
        end
    end
end