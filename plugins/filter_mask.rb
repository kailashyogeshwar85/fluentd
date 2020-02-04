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
require 'securerandom'

module Fluent
  module Plugin
    class MaskFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("mask", self)

        config_param :keys_to_mask, :default => nil
        config_param :mask_key, :default => "*****"

        def filter(tag, time, record)
          if @keys_to_mask.nil? || @keys_to_mask.empty?
            raise "keys_to_mask missing"
          end
          keys = keys_to_mask.to_s.split(",")
          if record["tenant_uid"].nil? || record["project_uid"].nil? || record["flow_uid"].nil?
            return []
          end
          logs = record['logs']
          mLogs = logs.map do |log|
            # This if condition is to avoid  any boolean or strng type value in array of logs object
            # as it is not a valid values
            if !log.is_a?(FalseClass) && !log.is_a?(TrueClass) && !log.is_a?(String) && !log.nil?
              message = log['message']
              if log["mask"] == "maskAll" && log["type"].match(/input|output/)
                log = maskLog(log)
              elsif log["type"].match(/input/)
                log["message"] = maskTokens(keys, message)
              end
              log["uid"] = "log-#{SecureRandom.uuid}"
              # log["created_at"] = Time.new.utc.iso8601
              # log["updated_at"] = Time.new.utc.iso8601
              log
            end
          end
          # compact will remove all the nil values from the array of objects
          mLogs = mLogs.compact
          # mLogs.compact
          mLogs
        end

      def maskLog(data)
        if data["type"] == "input"
          data["message"] = "Input data is masked"
        elsif data["type"] == "output"
          data["message"] = "Output data is masked"
        end
        return data
      end

      def maskTokens(keys, message)
        begin
          message = JSON.parse(message)
        rescue
          return message
        end
        for i in keys do
          if !message[i].nil?
            message[i] = mask_key
          end
        end
        return message.to_json
      end
    end
  end
end
