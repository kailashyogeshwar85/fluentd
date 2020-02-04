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
require "openssl"
require "base64"
require "json"

module Fluent
  module Plugin
    class CipherFilter < Fluent::Plugin::Filter
      Fluent::Plugin.register_filter("cipher", self)

      config_param :encryption_key, :default => nil
      config_param :encryption_iv, :default => nil
      config_param :encryption_divider, :default => nil
      config_param :active_key, :default => nil
      config_param :active_key_name, :default => nil

      def filter(tag, time, record)
          if @encryption_iv.nil?
          raise Fluent::ConfigError, "encryption_iv parameter is required"
        end
  
        if @encryption_key.nil?
          raise Fluent::ConfigError, "encryption_key is required"
        end

        logs = record
        record.map do |log|
          message = log['message']
          log["message"] = encrypt(message, @encryption_key, @encryption_iv)
          log
        end
        logs
      end

      def getActiveKey()
        if !@active_key.nil? && !@active_key_name.nil?
          return {
            key: active_key,
            name: active_key_name
          }
        return nil
        end
      end

      def encrypt(data, key, iv)
        active_key = getActiveKey()
        if !active_key.nil?
          key = active_key[:key]
        end
        cipher = OpenSSL::Cipher::AES.new(256, :CBC)
        cipher.encrypt
        cipher.key = key
        cipher.iv = iv

        data = cipher.update(data) + cipher.final
        data = Base64.encode64(data).encode('utf-8')
        if !active_key.nil?
          data = "#{active_key[:name]}#{@encryption_divider}#{data}"
        end
        return data
      end

    end
  end
end
