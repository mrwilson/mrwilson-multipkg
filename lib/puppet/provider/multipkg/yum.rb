Puppet::Type.type(:multipkg).provide(:yum) do
commands :yum => '/usr/bin/yum'
commands :rpm => '/bin/rpm'

  def exists?
    desired_packages = []
    yum_lookup_arr = []
    group_packages = []
    return true if @resource[:packages].size == 0
    # Separate group packages from normal yum packages
    @resource[:packages].each {|package|
      if package.start_with?("@") then
        group_packages << package
      else
        # Save all packages to verify later
        desired_packages << package
        # We need to take off arch because rpm command doesn't accept them
        yum_lookup_arr << package.sub(/\.(i686|x86_64)$/, '')
      end
    }

    # Test yum packages
    if desired_packages.any? then
      output = pkg_list("list", yum_lookup_arr)
      # Verify each package
      for pkg in desired_packages
        # DEBUG: puts "checking " + pkg
        # DEBUG: puts output.grep(/^#{Regexp.escape pkg}/).to_s
        # All returned packages have arch so we should check if they start with string, not match
        unless output.grep(/^#{Regexp.escape pkg}/).size > 0
          return false
        end
      end
    end

    # Test group packages
    if group_packages.any? then
      output = pkg_list("grouplist", group_packages)
      if ! output.size then
        return false
      end
    end

    # If all packages and groups are already installed return true
    return true
  end

  def pkg_list(arg, pkg)
    cmd = []
    output = []
    # fix yum list output
    if arg=="list" then
      # Use rpm for cleaner output
      cmd << "--query" << "--all" << "--queryformat" << "[%{NAME}.%{ARCH}\n]" << pkg
      output = rpm(cmd).split("\n")
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
      #Puppet.notice("Installing #{@resource[:packages]} in a transaction")
      yum(cmd)
    end
  end

  def packages
    @resource[:packages]
  end

end
