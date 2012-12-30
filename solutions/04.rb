class Validations
  def self.email?(value)
    regexp = /\A[[:alnum:]][-+_.[:alnum:]]{,200}@/
    !!(value =~ regexp) and hostname? regexp.match(value).post_match
  end

  def self.hostname?(value)
   !!(value =~ /\A(([[:alnum:]][-[:alnum:]]{0,61}[[:alnum]]|[[:alnum:]]{1,2})\.)+[[:alpha:]]{2,3}(\.[[:alpha:]]{2})?\z/)
  end

  def self.phone?(value)
    !!(value =~ /\A((0{2}|\+)[1-9]\d{,2}|0)([- \(\)]?[- \(\)]?\d){6,11}\z/)
  end

  def self.ip_address?(value)
    !!(value =~ /\A(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])){3}\z/)
  end

  def self.number?(value)
    !!(value =~ /\A-?(0(\.\d+)?|[1-9]\d*(\.\d+)?)\z/)
  end

  def self.integer?(value)
    !!(value =~ /\A-?(0|[1-9]\d*)/)
  end

  def self.date?(value)
    !!(value =~ /\A\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])\z/)
  end

  def self.time?(value)
    !!(value =~ /\A([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]\z/)
  end

  def self.date_time?(value)
    regexp = /[ T]/
    return false if regexp !~ value
    date? regexp.match(value).pre_match and time? regexp.match(value).post_match
  end
end

class PrivacyFilter
  attr_accessor :preserve_phone_country_code, :preserve_email_hostname, :partially
  attr_accessor :text

  def initialize(text)
    @preserve_phone_country_code = false
    @preserve_email_hostname = false
    @partially = false
    @text = text
  end

  def email_filter(text)
    E = /(?<user>[[:alnum:]][-+_.[:alnum:]]{,200})@(?<host>(([[:alnum:]][-[:alnum:]]{0,61}
      [[:alnum]]|[[:alnum:]]{1,2})\.)+[[:alpha:]]{2,3}(\.[[:alpha:]]{2})?)/x
    text.gsub(E) do |m| if partially and E[:user].length >= 6 then "#{E[:user][0..2]}[FILTERED]@#{E[:host]}" end
      if preserve_email_hostname and partially then "[FILTERED]@#{EMAIL[:host]}"
      else "[EMAIL]"
      end
    end
  end

  def phone_filter(text)
    phone = /(?<code>(0{2}|\+)[1-9]\d{,2}|0)(?<number>([- \(\)]?[- \(\)]?\d){6,11})/
    text.gsub(phone) do |match|
      if preserve_phone_country_code then "[FILTERED]@#{phone[:number]}"
      else "[PHONE]"
      end
    end
  end

  def filtered
    text_filter = @text
    phone_filter(email_filter(text_filter))
  end
end