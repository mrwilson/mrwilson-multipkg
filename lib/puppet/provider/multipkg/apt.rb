Puppet::Type.type(:multipkg).provide(:apt) do
  commands :apt  => '/usr/bin/apt-get',
           :dpkg => '/usr/bin/dpkg'

  def exists?
    cmd = ['--get-selections']
    cmd << @resource[:packages]
    output = dpkg(cmd).split("\n")
    for pkg in @resource[:packages] do
      return false if output.include?("No packages found matching #{pkg}.")
    end
    return true
  end

  def destroy
    cmd = ['remove']
    cmd << '-q' << '-y' << @resource[:packages]
    apt(cmd)
  end

  def create
    cmd = ['install']
    cmd << '-q' << '-y' << @resource[:packages]
    apt(cmd)
  end

  def packages
    @resource[:packages]
  end

end
