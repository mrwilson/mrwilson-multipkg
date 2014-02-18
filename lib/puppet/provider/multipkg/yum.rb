Puppet::Type.type(:multipkg).provide(:yum) do
  commands :yum => '/usr/bin/yum'

  def exists?
    cmd = ['list']
    cmd << '-q' << 'installed' << @resource[:packages]

    begin
      output = yum(cmd).split("\n")
    rescue Puppet::ExecutionFailure => e
      return false
    end

    if output.size  != @resource[:packages].size + 1 then
      return false
    end

    return true
  end

  def destroy
    cmd = ['remove']
    cmd << '-q' << '-y' << @resource[:packages]
    yum(cmd)
  end

  def create
    cmd = ['install']
    cmd << '-q' << '-y' << @resource[:packages]
    Puppet.notice("Installing #{@resource[:packages]} in a transaction")
    yum(cmd)
  end

  def packages
    @resource[:packages]
  end

end
