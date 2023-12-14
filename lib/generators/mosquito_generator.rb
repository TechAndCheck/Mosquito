class MosquitoGenerator < Rails::Generators::Base
  source_root(File.expand_path(File.dirname(__FILE__)))
  def copy_initializer
    copy_file "mosquito.rb", "config/initializers/mosquito.rb"
  end
end
