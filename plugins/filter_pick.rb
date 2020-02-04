#
# Copyright 2019- TODO: Write your name
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/filter"
module Fluent
  module Plugin
    class PickFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("pick", self)

        config_param :keys_to_extract, :default => nil

        def filter(tag, time, record)
          if @keys_to_extract.nil? || @keys_to_extract.empty?
            raise "keys_to_extract missing"
          end
          keys = keys_to_extract.to_s.split(",")
          # if record["type"].match(/input|output/)
          #   record = record.select { |key, _| keys.include? key }
          #   record
          # end

          msgs = ['action started', 'action completed', 'preparing to execute workflow', 'processing inputs']
          if (msgs.index record["message"]).nil? && record['type'] != 'bill'
            record = record.select { |key, _| keys.include? key }
            record
          end
        end
    end
  end
end
