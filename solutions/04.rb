module Patterns
  HOSTNAME  = /([[:alnum:]][-[:alnum:]]{0,62}(?<![_-])\.)+[A-Za-z]{2,3}(\.[A-Za-z]{2})?/
  EMAIL     = /\b([[:alnum:]][-+.\w]{,200})@(#{HOSTNAME})\b/
  CODE      = /((?<![\+\w])0(?!0)|(\b00[1-9]\d{,2}|\+[1-9]\d{,2}))/
  PHONE     = /#{CODE}([ \-\(\)]{,2}(\d[ \-\(\)]{,2}){6,10}\d)/
  IP        = /(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])){3}/
  NUMBER    = /-?(0(\.\d+)?|[1-9]\d*(\.\d+)?)/
  INTEGER   = /-?(0|[1-9]\d*)/
  DATE      = /\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])/
  TIME      = /([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]/
  DATE_TIME = /#{DATE}[ T]#{TIME}/
end

class Validations
  def self.email?(value)
    !!(value =~ /\A#{Patterns::EMAIL}\z/)
  end

  def self.hostname?(value)
    !!(value =~ /\A#{Patterns::HOSTNAME}\z/)
  end

  def self.phone?(value)
    !!(value =~ /\A#{Patterns::PHONE}\z/)
  end

  def self.ip_address?(value)
    !!(value =~ /\A#{Patterns::IP}\z/)
  end

  def self.number?(value)
    !!(value =~ /\A#{Patterns::NUMBER}\z/)
  end

  def self.integer?(value)
    !!(value =~ /\A#{Patterns::INTEGER}\z/)
  end

  def self.date?(value)
    !!(value =~ /\A#{Patterns::DATE}\z/)
  end

  def self.time?(value)
    !!(value =~ /\A#{Patterns::TIME}\z/)
  end

  def self.date_time?(value)
    !!(value =~ /\A#{Patterns::DATE_TIME}\z/)
  end
end

class PrivacyFilter
  attr_accessor :preserve_phone_country_code,
                :preserve_email_hostname,
                :partially_preserve_email_username,
                :text

  def initialize(text)
    @preserve_phone_country_code = false
    @preserve_email_hostname = false
    @partially_preserve_email_username = false
    @text = text
  end

  def filtered
    phone_filter(email_filter(text))
  end

  private

  def email_filter(text)
    text.gsub(/#{Patterns::EMAIL}/) do |match|
      if    partially_preserve_email_username and $1.length >= 6 then "#{$1[0..2]}[FILTERED]@#{$2}"
      elsif preserve_email_hostname or partially_preserve_email_username then "[FILTERED]@#{$2}"
      else  "[EMAIL]"
      end
    end
  end

  def phone_filter(text)
    text.gsub(/#{Patterns::PHONE}/) do |match|
      if   preserve_phone_country_code and $1 != "0" then "#{$1} [FILTERED]"
      else "[PHONE]"
      end
    end
  end
end