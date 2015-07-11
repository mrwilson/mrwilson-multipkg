Puppet::Type.type(:multipkg).provide(:yum) do
commands :yum => '/usr/bin/yum'

  def exists?
    yum_packages = []
    group_packages = []
    return true if @resource[:packages].size == 0
    # Separate group packages from normal yum packages
    @resource[:packages].each {|package|
      if package.start_with?("@") then
        group_packages << package
      else
        yum_packages << package 
      end
    }

    # Test yum packages
    output = pkg_list("list", yum_packages)
    if output.size != ( yum_packages.size) then
      return false
    end

    # Test group packages
    output = pkg_list("grouplist", group_packages)
    if ! output.size then
      return false
    end

    return true
  end

  def pkg_list(arg, pkg)
    cmd = []
    output = []
    # fix yum list output
    if arg=="list" then
      cmd << arg << "-q" << "-e0" << pkg
      output = yum(cmd).split("\n")
      # column formatting is inconsistant
      output.reject! { |item| item.start_with?(" ") }
      # only take package name
      output.map! {|item | item.split(".").first}
      output.map!(&:downcase)
      # remove duplicates (i.e. kernel-*)
      output.uniq!
      output = output.slice( (output.index("installed packages") +1)..(output.index("available packages") -1))
    # fix grouplist output
    elsif arg=="grouplist"
      cmd << "-v" << arg << "-e0" 
      output = yum(cmd).split("\n")
      output.map!(&:downcase)
      output = output.slice( (output.index("installed groups:") +1)..(output.index("available groups:") -1))
      # get package shortnames for installed packages
      # This is a mess because rhel 6/ruby 1.8 don't have all the features we want
      output.map!{|item| '@' + item.scan(/\(([^)]+)\)/).flatten.first.to_s}
      # desired groups - installed groups
      return pkg - output
    end
    return output
  end

  def destroy
    if @resource[:packages].size != 0
      cmd = ['remove']
      cmd << '-q' << '-y' << '-e0' << @resource[:packages]
      yum(cmd)
    end
  end

  def create
    if @resource[:packages].size != 0
      cmd = ['install']
      cmd << '-q' << '-y' << '-e0' << @resource[:packages]
      Puppet.notice("Installing #{@resource[:packages]} in a transaction")
      yum(cmd)
    end
  end

  def packages
    @resource[:packages]
  end

end
