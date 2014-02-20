Puppet::Type.newtype(:multipkg) do
  desc "Puppet type to avoid the overhead of multiple installation runs"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Transaction name"
    munge do |value|
      value.downcase
    end
    def insync?(is)
      is.downcase == should.downcase
    end
  end

  newproperty(:packages, :array_matching => :all) do
    desc "Array of packages to install"
  end

end
