def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_zone)
	records={}
	dns_zone.each do |rec|
			rec_split=rec.split(", ")
			if records[rec_split[0]].nil?
				records[rec_split[0]]={ rec_split[1] => rec_split[2].chomp }
			else
				records[rec_split[0]][rec_split[1]] = rec_split[2].chomp
			end
	end
	records
end

def resolve(dns_records, lookup_chain, domain)
	dns_records.each do |key_type,record|
		record.each do |key,next_domain|
			if key==domain
				if key_type=="A"
					lookup_chain+=[next_domain]
				elsif key_type=="CNAME"
					lookup_chain+=[next_domain]
					lookup_chain=resolve(dns_records, lookup_chain, next_domain)
				end
				return lookup_chain
			end
		end
	end
	return lookup_chain+=["Domain Name not Found"]
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
