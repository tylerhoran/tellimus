# this generator based on rails_admin's install generator.
# https://www.github.com/sferik/rails_admin/master/lib/generators/rails_admin/install_generator.rb

require 'rails/generators'

# http://guides.rubyonrails.org/generators.html
# http://rdoc.info/github/wycats/thor/master/Thor/Actions.html

module Tellimus
  class ViewsGenerator < Rails::Generators::Base

    # Not sure what this does.
    source_root "#{Tellimus::Engine.root}/app/views/tellimus/subscriptions"

    include Rails::Generators::Migration

    desc "Tellimus installation generator"

    def install

      # all entries in app/views/tellimus/subscriptions without . and ..
      # ==> all FILES in the directory
      files_to_copy = Dir.entries("#{Tellimus::Engine.root}/app/views/tellimus/subscriptions") - %w[. ..]
      files_to_copy.each do |file|
        copy_file file, "app/views/tellimus/subscriptions/#{file}"
      end

    end

  end
end
