module Jekyll
  module CommonFilters
    def file_size(path, rel = nil)
      return 0 if path.nil?
      path = File.join('episodes', path)
      File.size(path)
    end
  end
end
