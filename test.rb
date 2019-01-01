require 'uri'

url = "www.google.com"
 puts  url =~ URI::regexp

 if url=~ URI::regexp
    puts 'double yup'
end

unless url.empty? || url =~ URI::regexp
    puts "why"
end
