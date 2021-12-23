module SpreeOnlyOneLineItemPerOrder
  VERSION = '0.0.2'.freeze

  module_function

  # Returns the version of the currently loaded SpreeOnlyOneLineItemPerOrder as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION
  end
end
